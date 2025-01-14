function TextView {
    local self is View():extend.
    self:setClassName("TextView").
    
    // Text properties
    local text is null.

    
    // Override hide to clear content
    self:public("hide", {
        if self:visible {
            self:clearBufferRegion().
            set self:visible to false.
            set self:dirty to true.
        }
    }).
    self:public("getText",{return text.}).
    
    // Set text content
    self:public("setText", {
        parameter newText.

        self:setWidth(max(self:getWidth(), newText:length)).
        self:setHeight(max(self:getHeight(), newText:split(char(10)):length)).
        set text to newText.
        
        set self:dirty to true.
        self:draw().
    }).
    
    // Override draw to handle text rendering
    local originalDraw is self:draw.
    self:public("draw", {
        //if not originalDraw()
         //   return false.
        

        local pos is self:getPosition().
        self:clearBufferRegion().
        screenBuffer:place(text, pos:x, pos:y).
        return true.
    }).
    
    return defineObject(self).
}
