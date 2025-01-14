// System/System.ks

function SystemApp {
    local self is TaskifiedObject():extend.
    
    function createMenu {
        local menuList is MenuList():new.
        
        local configItem is MenuItem():new.
        configItem:setText("System Configuration").
        configItem:setOnSelect({
            // TODO: Switch to config view
        }).
        
        local monitorItem is MenuItem():new.
        monitorItem:setText("System Monitor").
        monitorItem:setOnSelect({
            // TODO: Switch to monitor view
        }).
        
        menuList:addChild(configItem).
        menuList:addChild(monitorItem).
        
        return menuList.
    }

    // Main app creation (this is what gets registered)
    self:public("launchApp", {
        local mainView is VContainerView():new.
        local menu is createMenu().
        self:addChild(menu).
        menu:setFocus(true).
        return mainView.
    }).

    return defineObject(self).
}

// Register with AppRegistry
appRegistry:register("System", SystemApp():new:launchApp).

