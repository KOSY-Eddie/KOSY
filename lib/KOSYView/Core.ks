// Core.ks
// Part of KOSYView
// Defines the base View class and container views

runOncePath("/KOSY/lib/TaskifiedObject").

// Base View Class
function View {
    parameter drawableAreaIn.
    local self is TaskifiedObject():extend.
    self:setClassName("View").
    
    // Each view manages its own buffer
    self:protected("drawableArea", drawableAreaIn).
    
    // Draw into our own buffer
    self:protected("draw", {
        // Subclasses implement their drawing logic here
    }).
    
    return defineObject(self).
}


function ContainerView {
    parameter drawableAreaIn.
    local self is View(drawableAreaIn):extend.
    self:setClassName("ContainerView").

    local children is list().
    local spacing is 0.

    self:public("addChild", {
        parameter child.
        children:add(child).
    }).

    self:publicS("getChildren", {
        return children.
    }).

    self:public("setSpacing", {
        parameter newSpacing.
        set spacing to newSpacing.
    }).

    // Layout logic now uses drawable area
    self:protected("layoutAndDraw", {
        parameter horizontal.
        local totalFixedSize is 0.
        local spacerCount is 0.

        // Use drawable area for dimensions
        local areaWidth is self:drawableArea:lastCol - self:drawableArea:firstCol + 1.
        local areaHeight is self:drawableArea:lastLine - self:drawableArea:firstLine + 1.

        for child in children {
            if child:hasKey("isSpacerView") {
                set spacerCount to spacerCount + 1.
            } else {
                set totalFixedSize to totalFixedSize + 
                    (choose child:drawableArea:width() if horizontal 
                     else child:drawableArea:height()).
            }
        }.

        // Calculate spacer size using area dimensions
        local remainingSpace is (choose areaWidth if horizontal else areaHeight) - totalFixedSize.
        local spacerSize is floor(remainingSpace / max(spacerCount, 1)).

        // Position starts at drawable area boundaries
        local currentPosX is self:drawableArea:firstCol.
        local currentPosY is self:drawableArea:firstLine.

        for child in children {
            if child:hasKey("isSpacerView") {
                if horizontal {
                    set currentPosX to currentPosX + spacerSize.
                } else {
                    set currentPosY to currentPosY + spacerSize.
                }
            } else {
                child:draw().  // Child knows its position from its drawable area
                if horizontal {
                    set currentPosX to currentPosX + child:drawableArea:width() + spacing.
                } else {
                    set currentPosY to currentPosY + child:drawableArea:height() + spacing.
                }
            }
        }.
    }).

    return defineObject(self).
}

function HContainerView {
    parameter drawableAreaIn.
    local self is ContainerView(drawableAreaIn):extend.
    self:setClassName("HContainerView").

    self:public("draw", {
        self:layoutAndDraw(true).
    }).

    return defineObject(self).
}

function VContainerView {
    parameter drawableAreaIn.
    local self is ContainerView(drawableAreaIn):extend.
    self:setClassName("VContainerView").

    self:public("draw", {
        self:layoutAndDraw(false).
    }).

    return defineObject(self).
}
