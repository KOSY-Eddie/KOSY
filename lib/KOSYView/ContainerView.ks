runOncePath("/KOSY/lib/KOSYView/View").

function ContainerView {
    local self is View():extend.
    self:setClassName("ContainerView").
    local children is list().
    
    // Children management
    self:public("getChildren", {return children:copy().}).
    self:public("addChild", {
        parameter childIn.

        children:add(childIn).
        childIn:parent:set(self).
        //childIn:visible:set(true).
    }).

    local function getViewIdx{
        parameter view, collection.
        local viewIdx is 0.
        for item in collection{
            if item:hasKey("getObjID") and item:equals(view)
                return viewIdx.
            set viewIdx to viewIdx+1.
        }

        return -1.
    }

    self:public("vAlign",{
        parameter valignIn.
        for child in children:copy()
            child:vAlign(valignIn).
    }).

    self:public("hAlign",{
        parameter halignIn.
        for child in children:copy()
            child:hAlign(halignIn).
    }).

    self:public("removeChild", {
        parameter child.
        
        // if child:hasKey("getChildren") {
        //     for subChild in child:getChildren() {
        //         self:removeChild(subChild).
        //     }.
        // }
        
        // Remove from parent
        local childIdx is getViewIdx(child,children:copy()).
        if childIdx >= 0 {
            children:remove(childIdx).
        }.

        child:parent:set(null).
        
    }).


    self:public("switchContent", {
        parameter newView, setInput is false.
        
        self:clean().        
        self:addChild(newView).
        newView:onLoad().
        if setInput
            newView:setInput(true).
        newView:drawAll().
        // self:drawAll().      
    }).

    self:public("clean",{
        for child in children:copy(){
            self:removeChild(child).
        }
    }).
    
    // Internal measurement storage
    local measuredSizes is lex().
    
    // New internal measurement pass
    local function measureChildren {
        set measuredSizes to lex().
        for child in children:copy() {
            local size is lex(
                "width", child:getContentWidth(),
                "height", child:getContentHeight()
            ).
            set measuredSizes[child:getObjID()+""] to size.
        }
    }.
    
    self:protected("drawBorder", {
        parameter boundsIn.
        
        // Draw top border
        local topBorder is "+".
        from {local i is 0.} until i >= boundsIn:width - 2 step {set i to i + 1.} do {
            set topBorder to topBorder + "-".
        }
        set topBorder to topBorder + "+".
        screenBuffer:place(topBorder, boundsIn:x, boundsIn:y).
        
        // Draw side borders
        from {local i is 1.} until i >= boundsIn:height - 1 step {set i to i + 1.} do {
            screenBuffer:place("|", boundsIn:x, boundsIn:y + i).
            screenBuffer:place("|", boundsIn:x + boundsIn:width - 1, boundsIn:y + i).
        }
        
        // Draw bottom border
        local bottomBorder is "+".
        from {local i is 0.} until i >= boundsIn:width - 2 step {set i to i + 1.} do {
            set bottomBorder to bottomBorder + "-".
        }
        set bottomBorder to bottomBorder + "+".
        screenBuffer:place(bottomBorder, boundsIn:x, boundsIn:y + boundsIn:height - 1).
    }).

    self:protected("calculateMyBounds", {
        parameter boundsIn.
        // Measure children first
        measureChildren().
        
        local width is boundsIn:width.
        local height is boundsIn:height.

        if self:manualWidth >= 0 {
            set width to self:manualWidth.
        } else if not self:expandX {
            set width to self:getContentWidth().
        }

        if self:manualHeight >= 0 {
            set height to self:manualHeight.
        } else if not self:expandY {
            set height to self:getContentHeight().
        }

        local boundsOut is boundsIn:copy().
        set boundsOut:width to width.
        set boundsOut:height to height.

        return boundsOut.
    }).

    self:protected("calculateChildBounds",{}).

    return defineObject(self).
}

local function DirectionalContainerFactory{
    parameter isHorizontal.
    local self is ContainerView():extend.
    self:setClassName(choose "HContainerView" if isHorizontal else "VContainerView").

    local super_draw is self:draw.
    self:public("draw", {
        parameter boundsIn.
        super_draw(boundsIn).

        local myBounds is self:calculateMyBounds(boundsIn).
        local remainingBounds is myBounds:copy().
        local children is self:getChildren():copy().
        
        from {local i is 0.} until i >= children:length step {set i to i + 1.} do {
            local child is children[i].
            local grantedBounds is self:calculateChildBounds(i, remainingBounds).
            local takenBounds is childWantedBounds(child, grantedBounds).
            
            child:draw(takenBounds).
            
            local spacing is choose self:spacing if i < children:length - 1 else 0.
            if isHorizontal {
                set remainingBounds:x to takenBounds:x + takenBounds:width + spacing.
                set remainingBounds:width to remainingBounds:width - takenBounds:width - spacing.
            } else {
                set remainingBounds:y to takenBounds:y + takenBounds:height + spacing.
                set remainingBounds:height to remainingBounds:height - takenBounds:height - spacing.
            }
        }
    }).

    self:protected("calculateChildBounds", {
        parameter childIdx, containerBounds.
        local childCount is self:getChildren():length.
        
        local width is containerBounds:width.
        local height is containerBounds:height.
        local xStart is containerBounds:x.
        local yStart is containerBounds:y.
        
        local availableSpace is choose width if isHorizontal else height.
        local remainingChildren is (childCount - childIdx).
        local remainingSpacing is (remainingChildren - 1) * self:spacing.
        local childSize is floor((availableSpace - remainingSpacing) / remainingChildren).
        
        local boundsOut is containerBounds:copy().
        set boundsOut:x to xStart.
        set boundsOut:y to yStart.
        set boundsOut:width to choose childSize if isHorizontal else width.
        set boundsOut:height to choose height if isHorizontal else childSize. 

        return boundsOut.
    }).

    local function childWantedBounds{
        parameter child, grantedBounds.
        local wantedBounds is grantedBounds:copy().
        if not child:expandX:get() {
            set wantedBounds:width to min(child:getContentWidth(), grantedBounds:width).
        }
        if not child:expandY:get() {
            set wantedBounds:height to min(child:getContentHeight(), grantedBounds:height).
        }
        return wantedBounds.
    }

    // getContentSize remains the same as it works correctly
    self:public("getContentSize", {
        parameter isWidthDim.
        
        if isWidthDim and self:manualWidth >= 0 {
            return self:manualWidth.
        }
        if (not isWidthDim) and self:manualHeight >= 0 {
            return self:manualHeight.
        }

        local shouldSum is (isWidthDim = isHorizontal).
        local total is 0.
        
        for child in self:getChildren():copy() {
            local size is child:getContentSize(isWidthDim).
            if shouldSum {
                set total to total + size.
            } else {
                set total to max(total, size).
            }
        }
        
        if shouldSum {
            return total + (self:spacing * (self:getChildren():length - 1)).
        }
        return total.
    }).

    return defineObject(self).
}



function HContainerView {
    return DirectionalContainerFactory(true).
}

function VContainerView {
    return DirectionalContainerFactory(false).
}
