// System/System.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/Application").

runOncePath("/KOSY/sys/System/TaskMonitorView.ks").


// System/System.ks
function SystemApp {
    local self is Application():extend.
    self:setClassName("SystemApp").
    
    local container is HContainerView():new.
    local mainMenu is MenuList():new.
    mainMenu:expandY:set(false).
    mainMenu:setBackCallBack({
        //go back to app launcher
        appMenu:setInput(true).
    }).
    //mainMenu:setSpacing(2).
    
    // Set up main menu
    local item_taskMon is MenuItem():new.
    local item_sysConfig is MenuItem():new.
    item_taskMon:setText("Task Monitor").
    local taskMonView is TaskMonitorView():new.

    taskMonView:setbackCallBack({
        self:mainView:switchContent(mainMenu, true).
    }).
    
    
    item_taskMon:setAction({
        self:mainView:switchContent(taskMonView, true). 
    }).

    item_sysConfig:setText("System Config").
    
    local configView is SystemConfigView():new.

    configView:setBackCallBack({
        self:mainView:switchContent(mainMenu, true).
    }).

    item_sysConfig:setAction({
        self:mainView:switchContent(configView, true). 
        //configView:setInput(true).
        //configView:drawAll().
    }).


    mainMenu:addChild(item_taskMon).
    mainMenu:addChild(item_sysConfig).  
    mainMenu:hAlign("left").  

    // mainMenu:setBackCallback({
    //     appMenu:setFocus(true).
    // }).
    
    
    //mainMenu:setFocus(true).
    container:addChild(mainMenu).
    mainMenu:setInput(true).

    set self:mainView to container.

    return defineObject(self).
}

function SystemConfigView {
    local self is MenuList():extend.
    self:setClassName("SystemConfigView").
    
    local clockSettings is MenuItem():new.
    clockSettings:expandY:set(false).
    clockSettings:setText("Clock Settings").

    local clockSettingsSubMenu is MenuList():new.
    local metItem is MenuItem():new.
    metItem:setText(choose "MET*" if sysConfig:getConfig():clock:type = "met" else "MET").
    local kstItem is MenuItem():new.
    kstItem:setText("KST").
    kstItem:setText(choose "KST*" if sysConfig:getConfig():clock:type = "kst" else "KST").

    kstItem:setAction({
        local tmpConfig is sysConfig:getConfig().
        set tmpConfig:clock:type to "kst".
        kstItem:setText("KST *").
        metItem:setText("MET").
        sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
    }).

    metItem:setAction({
        local tmpConfig is sysConfig:getConfig().
        set tmpConfig:clock:type to "met".
        kstItem:setText("KST").
        metItem:setText("MET *").
        sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
    }).

    clockSettingsSubMenu:addChild(metItem).
    clockSettingsSubMenu:addChild(kstItem).

    clockSettings:addChild(clockSettingsSubMenu). //this should trigger submenulogic

    // local clockConfig is self:createOptionMenu(lex(
    //     "text", "Clock Settings",
    //     "options", list(
    //         lex(
    //             "id", "kst",
    //             "text", choose "KST *" if systemConfig:clock:type = "kst" else "KST",
    //             "onSelect", { parameter items. return {
    //                 local tmpConfig is systemConfig:copy().
    //                 set tmpConfig:clock:type to "kst".
    //                 items["kst"]:setText("KST *").
    //                 items["met"]:setText("MET").
    //                 sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
    //             }.}
    //         ),
    //         lex(
    //             "id", "met",
    //             "text", choose "MET *" if systemConfig:clock:type = "met" else "MET",
    //             "onSelect", { parameter items. return {
    //                 local tmpConfig is systemConfig:copy().
    //                 set tmpConfig:clock:type to "met".
    //                 items["met"]:setText("MET *").
    //                 items["kst"]:setText("KST").
    //                 sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
    //             }.}
    //         )
    //     )
    // )).
    
    self:addChild(clockSettings).
    //self:setFocus(true).
    return defineObject(self).
}



// Register with AppRegistry
appRegistry:register("System", SystemApp@).
