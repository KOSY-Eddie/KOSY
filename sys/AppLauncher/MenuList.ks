runOncePath("/KOSY/lib/KOSYView/ContainerView").
function MenuList {
    local self is VContainerView():extend.
    self:setClassName("MenuList").
    
    local cursorIndex is 0.
    local totalMenuItems is 0.

    // Method to add a menu item
    self:public("addMenuItem", {
        parameter menuItem.
        self:addChild(menuItem).
        set totalMenuItems to self:getChildren():length().  // Update total menu items
    }).

    // Method to handle input for cursor navigation
    self:public("handleInput", {
        if keyPressed("UP") {
            set cursorIndex to mod((cursorIndex - 1 + totalMenuItems), totalMenuItems).
        } else if keyPressed("DOWN") {
            set cursorIndex to mod((cursorIndex + 1) , totalMenuItems).
        }
    }).

    // Method to draw all menu items with highlighting
    self:public("draw", {
        if not self:visible { return. }
        
        // Draw all children (menu items)
        for i from 0 to totalMenuItems - 1 {
            local menuItem is self:getChildren()[i].
            
            // Highlight selected item
            if i = cursorIndex {
                menuItem:setText("-> " + menuItem:getText() + " <-"). // Add arrows for highlighting
            } else {
                menuItem:setText(menuItem:getText().replace("-> ", "").replace(" <-", "")).
            }
            
            menuItem:draw().
        }
    }).

    return defineObject(self).
}
