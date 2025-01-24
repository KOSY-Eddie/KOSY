// EngineApp.ks
runOncePath("EngineView").

function EngineApp {
    local self is Application():extend.
    self:setClassName("Engines").
    
    set self:mainView to EngineView():new.
    
    return defineObject(self).
}

// Register the app
appRegistry:register("Engines", EngineApp@).
