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
    //mainMenu:setSpacing(2).
    
    // Set up main menu
    local item_taskMon is MenuItem():new.
    local item_sysConfig is MenuItem():new.
    item_taskMon:setText("Task Monitor").

    item_taskMon:setOnSelect({
        local taskMonView is TaskMonitorView():new.
        taskMonView:setParentView(mainMenu).
        self:mainView:switchContent(taskMonView). 
    }).

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
    
    local clockConfig is self:createOptionMenu(lex(
        "text", "Clock Settings",
        "options", list(
            lex(
                "id", "kst",
                "text", choose "KST *" if systemConfig:clock:type = "kst" else "KST",
                "onSelect", { parameter items. return {
                    local tmpConfig is systemConfig:copy().
                    set tmpConfig:clock:type to "kst".
                    items["kst"]:setText("KST *").
                    items["met"]:setText("MET").
                    sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
                }.}
            ),
            lex(
                "id", "met",
                "text", choose "MET *" if systemConfig:clock:type = "met" else "MET",
                "onSelect", { parameter items. return {
                    local tmpConfig is systemConfig:copy().
                    set tmpConfig:clock:type to "met".
                    items["met"]:setText("MET *").
                    items["kst"]:setText("KST").
                    sysEvents:emit("configChangeRequested", tmpConfig, self:getClassName()).
                }.}
            )
        )
    )).
    
    self:addChild(clockConfig).
    self:setFocus(true).
    return defineObject(self).
}



// Register with AppRegistry
appRegistry:register("System", SystemApp@).
