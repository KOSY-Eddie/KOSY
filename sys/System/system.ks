// System/System.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/Application").


// System/System.ks
function SystemApp {
    local self is Application():extend.
    self:setClassName("SystemApp").
    
    local container is HContainerView():new.
    local mainMenu is MenuList():new.
    mainMenu:setExpandY(false).
    //mainMenu:setSpacing(2).
    
    // Set up main menu
    mainMenu:setExpandY(false).
    local item_taskMon is MenuItem():new.
    local item_sysConfig is MenuItem():new.
    item_taskMon:setText("Task Monitor").
    item_sysConfig:setText("System Config").
    
    item_sysConfig:setOnSelect({
        local configView is SystemConfigView():new.
        configView:setParentView(mainMenu).
        self:mainView:switchContent(configView). 
    }).

    mainMenu:addChild(item_taskMon).
    mainMenu:addChild(item_sysConfig).  
    mainMenu:hAlign("left").  

    mainMenu:setBackCallback({
        appMenu:setFocus(true).
    }).
    
    
    mainMenu:setFocus(true).
    container:addChild(mainMenu).

    set self:mainView to container.

    return defineObject(self).
}

function SystemConfigView {
    local self is MenuList():extend.
    self:setClassName("SystemConfigView").
    
    // Main clock settings item
    local clockConfig is MenuItem():new.
    clockConfig:setExpandY(false).
    clockConfig:setText("Clock Settings").
    
    local clockSubmenu is MenuList():new.

    // Add items to submenu
    local kstItem is MenuItem():new.
    kstItem:setText(choose "KST *" if systemConfig:clock:type = "kst" else "KST").
    kstItem:hAlign("left").
    kstItem:setOnSelect({
        local tmpConfig is systemConfig:copy().
        set tmpConfig:clock:type to "kst".
        kstItem:setText("KST *").
        metItem:setText("MET").
        sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
    }).

    local metItem is MenuItem():new.
    metItem:setText(choose "MET *" if systemConfig:clock:type = "met" else "MET").
    metItem:hAlign("left").
    metItem:setOnSelect({
        local tmpConfig is systemConfig:copy().
        set tmpConfig:clock:type to "met".
        metItem:setText("MET *").
        kstItem:setText("KST").
        sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
    }).

    // Add items to submenu
    clockSubmenu:addChild(kstItem).
    clockSubmenu:addChild(metItem).
    clockConfig:addSubmenu(clockSubmenu).
    self:addChild(clockConfig).
    
    self:public("setParentView", {
        parameter parentView.
        self:setBackCallback({
            local parentContainer is self:parent.
            parentContainer:switchContent(parentView). 
        }).
    }).
    
    return defineObject(self).
}

// Register with AppRegistry
appRegistry:register("System", SystemApp@).
