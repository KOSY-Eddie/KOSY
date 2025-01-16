// Import required libraries
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/SystemHeader").
runOncePath("/KOSY/lib/application").

// Main AppLauncher class
// Import required libraries
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/SystemHeader").
runOncePath("/KOSY/lib/application").

// Main AppLauncher class
function AppLauncher {
    // Initialize base class and set class name
    local self is Application():extend.
    self:setClassName("AppLauncher").

    // UI Components
    local header is SystemHeader():new.
    local mainContainer is VContainerView():new.
    local contentContainer is HContainerView():new.
    local appContainer is VContainerView():new.

    // App Management Functions
    local function launchApp {
        parameter app.
        appContainer:clean().
        appContainer:addChild(app:mainView).
        header:setAppTitle(app:title).
        appContainer:drawAll().
    }

    local function createAppPlaceholder {
        local placeholder is TextView():new.
        placeholder:setText("Select an app to get started").
        placeholder:halign("center").
        placeholder:valign("middle").
        return placeholder.
    }

    // Menu Management Functions
    local function createAppMenu {
        local menu is MenuList():new.
        menu:setExpandX(false).
        menu:setExpandY(false).
        menu:setWidth(15).
        local allapps is appRegistry:getApps().
        
        for appName in allapps:keys {
            local newMenuItem is MenuItem():new.
            newMenuItem:setText(appName).
            newMenuItem:halign("left").
            newMenuItem:valign("top").
            
            local appConstructor is allapps[appName].
            newMenuItem:setOnSelect({ 
                appConstructor():new:launch(launchApp@).
                local menuText is newMenuItem:getText().
                if not menu:hasFocus()
                    newMenuItem:setText(newMenuItem:getText():substring(2,menuText:length - 2)).
            }).
            
            menu:addChild(newMenuItem).
        }
        return menu.
    }

    // Rest of the code remains the same...
    local function setupHeader {
        header:setExpandY(false).
        mainContainer:addChild(header).
    }

    local function setupContentArea {
        global appMenu is createAppMenu().
        appMenu:setFocus(true).
        appContainer:addChild(createAppPlaceholder()).
        
        contentContainer:addChild(appMenu).
        contentContainer:addChild(appContainer).
        mainContainer:addChild(contentContainer).
    }

    local function initializeUI {
        setupHeader().
        setupContentArea().
        mainContainer:drawAll().
    }

    // Initialize and return
    initializeUI().
    return defineObject(self).
}
AppLauncher().
