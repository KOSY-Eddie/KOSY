runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/ContainerView").

// MenuView.ks
function AppLauncherMenu {
    local self is VContainerView():extend.
    self:setClassName("MenuView").
    
    // Create menu list and status display
    local menuList_ is MenuList():new.
    local statusText is TextView():new.
    statusText:setText("Status: No item selected").
    statusText:setPosition(2, 8).
    
    // Add menu items
    local item1 is MenuItem():new.
    local item2 is MenuItem():new.
    local item3 is MenuItem():new.
    
    item1:setText("Calculator").
    item1:setOnSelect({
        statusText:setText("Status: Selected Calculator").
    }).
    
    item2:setText("Text Editor").
    item2:setOnSelect({
        statusText:setText("Status: Selected Text Editor").
    }).
    
    item3:setText("File Browser").
    item3:setOnSelect({
        statusText:setText("Status: Selected File Browser").
    }).
    
    // Add items to menu
    menuList_:addChild(item1).
    menuList_:addChild(item2).
    menuList_:addChild(item3).
    
    // Add components to self
    self:addChild(menuList_).
    self:addChild(statusText).
    
    // Give initial focus to menu
    menuList_:setFocus(true).
    
    return defineObject(self).
}
