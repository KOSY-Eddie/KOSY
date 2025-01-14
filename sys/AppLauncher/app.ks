// /KOSY/sys/AppLauncher/app.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("HeaderView").

function AppLauncher {
    parameter registeredApps.
    local self is TaskifiedObject():extend.
    self:setClassName("AppLauncher").

    registeredApps:remove("AppLauncher"). //remove self
    local apps is registeredApps.
    local appContainer is HContainerView():new.

    function createMenu {
        local menuList_ is MenuList():new.

        for app in apps:keys {

            local menuItem_ is MenuItem():new.
            menuItem_:setText(app).
            menuItem_:setOnSelect({
                //if appcontainer has a child an app is running, put in code to sleep it and remove it
                appContainer:addChild(apps:app()).
            }).
            menuList_:addChild(menuItem_).
        }

        return menuList_.
    }

    local function createApp {
        local mainContainer is VContainerView():new.
        mainContainer:setPosition(0, 0).
        mainContainer:setSpacing(1).

        // Create and add header
        local headerView_ is HeaderView():new.
        mainContainer:addChild(headerView_).

        // Create and add menu
        local menuView_ is createMenu().
        mainContainer:addChild(menuView_).
        menuView_:setFocus(true).
        mainContainer:draw().
    }

    createApp().

    return defineObject(self).
}

// Register with AppRegistry
appRegistry:register("AppLauncher", AppLauncher@).

