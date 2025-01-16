runOncePath("/KOSY/lib/KOSYView/View").

function ContainerView {
    local self is View():extend.
    self:setClassName("ContainerView").
    local children is list().

    // Manual size properties
    local manualWidth is -1.    // -1 indicates not set
    local manualHeight is -1.   // -1 indicates not set

    // Size setters
    self:public("setWidth", {
        parameter w.
        set manualWidth to w.
    }).

    self:public("setHeight", {
        parameter h.
        set manualHeight to h.
    }).

    // Size getters
    self:public("getManualWidth", {
        return manualWidth.
    }).

    self:public("getManualHeight", {
        return manualHeight.
    }).

    // Reset manual sizes
    self:public("resetManualSize", {
        set manualWidth to -1.
        set manualHeight to -1.
    }).

    self:public("width", 0).
    self:public("height", 0).
    set self:expandX to true.
    set self:expandY to true.
    
    // Children management
    self:public("getChildren", {return children.}).
    self:public("addChild", {
        parameter child.
        children:add(child).
        child:parent:set(self).
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

    self:public("removeChild", {
        parameter child.
        local childIdx is getViewIdx(child,children).
        if childIdx >= 0
            children:remove(childIdx).
        child:parent:set(null).
        set child to 0.
    }).

    self:public("switchContent", {
        parameter newView.
        
        self:clean().        
        self:addChild(newView).
        if newView:hasKey("setFocus")
            newView:setFocus(true).  
        self:drawAll().      
    }).

    self:public("clean",{
        for child in children:copy()
            self:removeChild(child).
    }).
    
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
        local width is boundsIn:width.
        local height is boundsIn:height.

        if manualWidth >= 0 {
            set width to manualWidth.
        } else if not self:expandX {
            set width to self:getContentWidth().
        }

        if manualHeight >= 0 {
            set height to manualHeight.
        } else if not self:expandY {
            set height to self:getContentHeight().
        }

        return lex(
            "x", boundsIn:x,
            "y", boundsIn:y,
            "width", width,
            "height", height
        ).
    }).

    //virtual method meant to be overriden
    self:protected("calculateChildBounds",{}).

    return defineObject(self).
}

local function DirectionalContainerFactory{
    parameter isHorizontal.
    local self is ContainerView():extend.
    self:setClassName(choose "HContainerView" if isHorizontal else "VContainerView").

    self:public("draw", {
        parameter boundsIn.

        local myBounds is self:calculateMyBounds(boundsIn).
        
        //self:drawBorder(myBounds). //for debugging
        
        local remainingBounds is myBounds.
        from {local i is 0.} until i >= self:getChildren():length step {set i to i + 1.} do {
            local child is self:getChildren()[i].

            local grantedChildBounds is self:calculateChildBounds(i, remainingBounds).
            local takenBounds is childWantedBounds(child,grantedChildBounds).   
            
            child:draw(takenBounds).
            
            // Only add spacing if this isn't the last element
            local spacing is choose self:spacing if i < self:getChildren():length - 1 else 0.
            
            // Update bounds based on container direction
            if isHorizontal {
                set remainingBounds to lex(
                    "x", takenBounds:x + takenBounds:width + spacing,
                    "y", remainingBounds:y,
                    "width", remainingBounds:width - takenBounds:width - spacing,
                    "height", remainingBounds:height
                ).
            } else {
                set remainingBounds to lex(
                    "x", remainingBounds:x,
                    "y", takenBounds:y + takenBounds:height + spacing,
                    "width", remainingBounds:width,
                    "height", remainingBounds:height - takenBounds:height - spacing
                ).
            }
        }
    }).


    // Override getContentSize to respect manual sizes
    self:public("getContentSize", {
        parameter isWidthDim.
        
        // Check if manual size is set
        if isWidthDim and self:getManualWidth() >= 0 {
            return self:getManualWidth().
        }
        if (not isWidthDim) and self:getManualHeight() >= 0 {
            return self:getManualHeight().
        }

        // Original content size calculation
        local shouldSum is (isWidthDim = isHorizontal).
        local total is 0.
        
        for child in self:getChildren() {
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

    local function childWantedBounds{
        parameter child, grantedBounds.

        local wantedBounds is grantedBounds:copy().
        if not child:getExpandX() {
            set wantedBounds:width to child:getContentWidth().
        }
        if not child:getExpandY() {
            set wantedBounds:height to child:getContentHeight().
        }

        return wantedBounds.
    }

    self:protected("calculateChildBounds", {
        parameter childIdx, containerBounds.
        local childCount is self:getChildren():length.
        local totalSpacing is (childCount - 1) * self:spacing.
        
        local width is containerBounds:width.
        local height is containerBounds:height.
        local xStart is containerBounds:x.
        local yStart is containerBounds:y.
        
        local availableSpace is choose width if isHorizontal else height.
        // Adjust available space for remaining spacing
        local remainingChildren is (childCount - childIdx).
        local remainingSpacing is (remainingChildren - 1) * self:spacing.
        local childSize is (availableSpace - remainingSpacing) / remainingChildren.
        
        return lex(
            "x", xStart,
            "y", yStart,
            "width", choose childSize if isHorizontal else width,
            "height", choose height if isHorizontal else childSize
        ).
    }).


    return defineObject(self).
}

function HContainerView {
    return DirectionalContainerFactory(true).
}

function VContainerView {
    return DirectionalContainerFactory(false).
}
