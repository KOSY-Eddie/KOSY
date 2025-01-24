runOncePath("/KOSY/lib/KOSYView/MenuItem").

function AppMenuItem {
    local self is MenuItem():extend.
    self:setClassName("AppMenuItem").
    
    local standardCursor is "> ".
    local openCursor is "-> ".
    local isOpen is false.
    
    self:protected("updateLabelText", {
        parameter textIn.
        
        if self:selected {
            if isOpen {
                self:textLabel:setText(openCursor + textIn).
            } else {
                self:textLabel:setText(standardCursor + textIn).
            }
        } else {
            set isOpen to false.  // Reset open state when deselected
            self:textLabel:setText(" ":padRight(standardCursor:length) + textIn).
        }
    }).

    // Add method for MenuList to call
    self:public("resetOpenState", {
        set isOpen to false.
        self:updateLabelText(self:originalText).
    }).

    self:public("triggerSelect", {
        set isOpen to true.
        self:updateLabelText(self:originalText).
        self:onSelect().
    }).

    return defineObject(self).
}


// AppLauncher/AppLauncher.ks
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/SystemHeader").
runOncePath("/KOSY/lib/application").

function AppLauncher {
    local self is Application():extend.
    self:setClassName("AppLauncher").

    local header is SystemHeader():new.
    local mainContainer is VContainerView():new.
    local contentContainer is HContainerView():new.
    local appContainer is VContainerView():new.
    appContainer:name:set("App Container").

    local function launchApp {
        parameter app.
        header:setAppTitle(app:getClassName()).
        appContainer:switchContent(app:mainView:get()).
        //appContainer:addChild(app:mainView:get()).
        //appContainer:drawAll().
    }

    local function createAppPlaceholder {
        local placeholder is TextView():new.
        placeholder:setText("Select an app to get started").
        placeholder:halign("center").
        placeholder:valign("middle").
        return placeholder.
    }

    local function createAppMenu {
        local menu is MenuList():new.
        menu:expandX:set(false).
        menu:expandY:set(false).
        menu:manualWidth:set(15).
        local allapps is appRegistry:getApps().
        
        for appName in allapps:keys {
            local newMenuItem is MenuItem():new.
            newMenuItem:setText(appName).
            newMenuItem:halign("left").
            newMenuItem:valign("top").
            
            local appConstructor is allapps[appName].
            newMenuItem:setAction({ 
                launchApp(appConstructor():new).
            }).
            
            menu:addChild(newMenuItem).
        }
        return menu.
    }

    local function setupHeader {
        header:expandY:set(false).
        mainContainer:addChild(header).
    }

    local function setupContentArea {
        global appMenu is createAppMenu().
        appMenu:setInput(true).
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

    initializeUI().
    return defineObject(self).
}

AppLauncher().
