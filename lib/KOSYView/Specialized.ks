runOncePath("/KOSY/lib/KOSYView/Core").

function TextView {
    parameter drawableAreaIn, initialText.
    local self is View(drawableAreaIn):extend.
    self:setClassName("TextView").

    self:protected("text", initialText).

    // Set new text content
    self:public("setText", {
        parameter newText.
        set self:text to newText.
        self:draw().
    }).

    // Override draw to render text within drawable area
    self:public("draw", {
        globalBuffer:place(self:text, 
            self:drawableArea:firstCol:get(), 
            self:drawableArea:firstLine:get()).
    }).

    return defineObject(self).
}


// SpacerView - A view that expands to fill available space
function SpacerView {
    local self is View():extend.
    self:setClassName("SpacerView").
    
    self:public("isSpacerView", true).
    
    return defineObject(self).
}
