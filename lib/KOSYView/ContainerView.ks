runOncePath("/KOSY/lib/KOSYView/View").

function ContainerView {
    local self is View():extend.
    self:setClassName("ContainerView").
    
    self:protected("children", list()).
    self:protected("spacing", 1).
    
    // Common spacing methods
    self:public("setSpacing", {
        parameter newSpacing.
        set self:spacing to newSpacing.
        self:recalculatePositions().
        set self:dirty to true.
    }).
    
    self:public("getChildren",{return self:children:copy().}).
    // Add a child view
    self:public("addChild", {
        parameter child.
        self:children:add(child).
        child:parent:set(self).
        set self:dirty to true.
        self:recalculatePositions().
    }).

    // Position handling
    local originalSetPosition is self:setPosition.
    self:public("setPosition", {
        parameter x, y.
        originalSetPosition(x, y).
        self:recalculatePositions().
    }).
    
    // Draw handling
    self:public("draw", {
        if not self:visible { return. }
        
        for child in self:children {
            if child:isDirty() or self:dirty {
                child:draw().
            }
        }
        set self:dirty to false.
    }).
    
    return defineObject(self).
}

function HContainerView {
    local self is ContainerView():extend.
    self:setClassName("HContainerView").
    
    // Calculate dimensions
    local function calculateDimensions {
        local totalWidth is 0.
        local maxHeight is 0.
        
        for child in self:children {
            set totalWidth to totalWidth + child:getWidth().
            set maxHeight to max(maxHeight, child:getHeight()).
        }
        
        if self:children:length > 0 {
            set totalWidth to totalWidth + (self:spacing * (self:children:length - 1)).
        }
        
        return lex("width", totalWidth, "height", maxHeight).
    }.
    
    // Recalculate positions and container size
    self:protected("recalculatePositions", {
        local currentX is self:getPosition():x.
        local dimensions is calculateDimensions().
        
        for child in self:children {
            child:setPosition(currentX, self:getPosition():y).
            set currentX to currentX + child:getWidth() + self:spacing.
        }
        
        self:setWidth(dimensions:width).
        self:setHeight(dimensions:height).
    }).
    
    return defineObject(self).
}

function VContainerView {
    local self is ContainerView():extend.
    self:setClassName("VContainerView").
    
    // Calculate dimensions
    local function calculateDimensions {
        local maxWidth is 0.
        local totalHeight is 0.
        
        for child in self:children {
            set maxWidth to max(maxWidth, child:getWidth()).
            set totalHeight to totalHeight + child:getHeight().
        }
        
        if self:children:length > 0 {
            set totalHeight to totalHeight + (self:spacing * (self:children:length - 1)).
        }
        
        return lex("width", maxWidth, "height", totalHeight).
    }.
    
    // Recalculate positions and container size
    self:protected("recalculatePositions", {
        local currentY is self:getPosition():y.
        local dimensions is calculateDimensions().
        
        for child in self:children {
            child:setPosition(self:getPosition():x, currentY).
            set currentY to currentY + child:getHeight() + self:spacing.
        }
        
        self:setWidth(dimensions:width).
        self:setHeight(dimensions:height).
    }).
    
    return defineObject(self).
}

