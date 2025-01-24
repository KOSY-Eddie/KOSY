// FlightControl/FlightControlApp.ks
runOncePath("FlightModel").
runOncePath("FlightViewModel").
runOncePath("FlightDisplayView").

function FlightControlApp {
    local self is Application():extend.
    self:setClassName("FlightControlApp").
    
    local model is FlightModel():new.
    local viewModel is FlightViewModel():new.
    set self:mainView to FlightDisplayView():new.
    
    viewModel:setModel(model).
    viewModel:setView(self:mainView).
    
    return defineObject(self).
}

appRegistry:register("Flight", FlightControlApp@).
