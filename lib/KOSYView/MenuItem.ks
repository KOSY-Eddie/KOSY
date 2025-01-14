runOncePath("/KOSY/lib/KOSYView/ContainerView").

function MenuItem {
    local self is TextView():extend.
    self:setClassName("MenuItem").
    
    local selected is false.
    local cursorIndicator is "> ".
    local onSelect is { }.  // Default empty delegate
    
    // Set the action to perform when selected
    self:public("setOnSelect", {
        parameter action.
        set onSelect to action.
    }).
    
    // Trigger the select action
    self:public("triggerSelect", {
        onSelect().
    }).
    
    self:public("setSelected", {
        parameter isSelected.
        set selected to isSelected.
        local text is self:getText().
        
        if selected {
            self:setText(cursorIndicator + text).
        } else {
            if text:startsWith(cursorIndicator) {
                self:settext(text:substring(cursorIndicator:length, text:length - cursorIndicator:length)).
            }
        }
        

    }).
    
    return defineObject(self).
}
