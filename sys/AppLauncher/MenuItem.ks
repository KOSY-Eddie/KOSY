runOncePath("/KOSY/lib/KOSYView/ContainerView").

function MenuItem {
    local self is View():extend.
    self:setClassName("MenuItem").
    
    local itemText is TextView():new().
    
    // Set the text for the menu item
    self:public("setText", {
        parameter text.
        itemText:setText(text).
    }).

    // Draw method to display the menu item
    self:public("draw", {
        if not self:visible { return. }
        
        // Draw the text for the menu item
        itemText:draw().
    }).

    return defineObject(self).
}
