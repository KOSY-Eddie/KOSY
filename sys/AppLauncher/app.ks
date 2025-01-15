// /KOSY/sys/AppLauncher/app.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("HeaderView").

function AppLauncher {
    parameter registeredApps.
    local self is TaskifiedObject():extend.
    self:setClassName("AppLauncher").

    // Main UI containers
    local mainContainer is VContainerView():new.
    local contentContainer is HContainerView():new.
    local appContainer is VContainerView():new.
    local header is HeaderView():new.
    
    // Create the menu list with app entries
    local function createAppMenu {
        local menu is MenuList():new.
        menu:setExpandX(false).
        menu:setExpandY(false).
        
        for appName in registeredApps:keys {
            local item is MenuItem():new.
            item:setText(appName).
            item:halign("left").
            item:valign("top").
            
            // When selected, launch the app
            item:setOnSelect({
                appContainer:clean().
                appContainer:addChild(registeredApps[appName]()).
                header:setAppTitle(appName).
            }).
            
            menu:addChild(item).
        }
        
        return menu.
    }

    // Create placeholder for app area
    local function createAppPlaceholder {
        local placeholder is TextView():new.
        placeholder:setText("Select an app to get started").
        placeholder:halign("center").
        placeholder:valign("middle").
        return placeholder.
    }

    // Initialize the UI
    local function initializeUI {
        // Setup header
        header:setExpandY(false).
        mainContainer:addChild(header).

        // Setup content area (menu + app container)
        local menu is createAppMenu().
        menu:setFocus(true).
        
        // Add placeholder to app container
        appContainer:addChild(createAppPlaceholder()).
        
        // Add menu and app container to content
        contentContainer:addChild(menu).
        contentContainer:addChild(appContainer).
        
        // Add content to main container
        mainContainer:addChild(contentContainer).
        
        // Initial draw
        mainContainer:drawAll().
    }

    // Initialize the app
    initializeUI().

    return defineObject(self).
}

// Register with AppRegistry
appRegistry:register("AppLauncher", AppLauncher@).
