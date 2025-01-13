function TextView {
    local self is View():extend.
    self:setClassName("TextView").
    
    // Text properties
    local text is "".
    self:protected("text", text).
    
    // Clear method to handle content removal
    local function clearContent {
        local pos is self:getPosition().
        local clearText is " ":padRight(text:length).
        screenBuffer:place(clearText, pos:x, pos:y).
    }.
    
    // Override hide to clear content
    self:public("hide", {
        if self:visible {
            clearContent().
            set self:visible to false.
            set self:dirty to true.
        }
    }).
    
    // Set text content
    self:public("setText", {
        parameter newText.
        if not (text = newText) {
            if self:visible { clearContent(). }  // Clear old content if visible
            set text to newText.
            self:setWidth(text:length).
            self:setHeight(text:split(char(10)):length).
            set self:dirty to true.
        }
    }).
    
    // Override draw to handle text rendering
    local originalDraw is self:draw.
    self:public("draw", {
        if not self:visible { return. }
        if not self:dirty { return. }
        
        local pos is self:getPosition().
        screenBuffer:place(text, pos:x, pos:y).
        
        originalDraw().
    }).
    
    return defineObject(self).
}
