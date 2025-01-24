// EngineView.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").

function EngineView {
    local self is VContainerView():extend.
    self:setClassName("EngineView").
    
    // Create rows for engine arrangement
    local row1 is HContainerView():new.
    local rowSJ is HContainerView():new.
    local row2 is HContainerView():new.
    
    // Create engine status views
    local e1View is TextView():new.
    local e2View is TextView():new.
    local e3View is TextView():new.
    local e4View is TextView():new.
    local sjView is TextView():new.
    
    local function formatEngineStatus {
        parameter num, mode, thrust.
        return "E" + num + " [" + mode + "] " + round(thrust,1) + "kN".
    }
    
local function updateDisplay {
    // Update engine displays with length checking first
    local e1Parts is ship:partstagged("E1").
    if e1Parts:length > 0 {
        e1View:setText(" " + formatEngineStatus(1, e1Parts[0]:mode, e1Parts[0]:thrust)).
    } else {
        e1View:setText(" E1 [LOST]").
    }
    
    local e2Parts is ship:partstagged("E2").
    if e2Parts:length > 0 {
        e2View:setText(" " + formatEngineStatus(2, e2Parts[0]:mode, e2Parts[0]:thrust)).
    } else {
        e2View:setText(" E2 [LOST]").
    }
    
    local e3Parts is ship:partstagged("E3").
    if e3Parts:length > 0 {
        e3View:setText(formatEngineStatus(3, e3Parts[0]:mode, e3Parts[0]:thrust)).
    } else {
        e3View:setText("E3 [LOST]").
    }
    
    local e4Parts is ship:partstagged("E4").
    if e4Parts:length > 0 {
        e4View:setText(formatEngineStatus(4, e4Parts[0]:mode, e4Parts[0]:thrust)).
    } else {
        e4View:setText("E4 [LOST]").
    }
    
    local sjParts is ship:partstagged("SJ").
    if sjParts:length > 0 {
        sjView:setText("  SJ [AIR] " + round(sjParts[0]:thrust,1) + "kN").
    } else {
        sjView:setText("  SJ [LOST]").
    }
}


    
    // Initialize layout
    row1:addChild(e1View).
    row1:addChild(e3View).
    
    rowSJ:addChild(sjView).
    
    row2:addChild(e2View).
    row2:addChild(e4View).
    
    self:addChild(row1).
    self:addChild(rowSJ).
    self:addChild(row2).
    
    local updateTask is Task(lex(
        "condition", { return not isNull(self:parent). },
        "work", { updateDisplay(). },
        "delay", 0.1,
        "name", "EngineView Update"
    )):new.
    
    // Schedule the task
    scheduler:addTask(updateTask).
    
    updateDisplay().
    
    return defineObject(self).
}
