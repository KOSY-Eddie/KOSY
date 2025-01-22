runOncePath("FlightDisplayView").
runOncePath("FlightModel").

function FlightApp {
    local self is Application():extend.
    self:setClassName("Flight").
    
    local appView is FlightDisplayView():new.
    local model is FlightModel():new.
    
    model:setView(appView).
    set self:mainView to appView.

    //appView:setfocus(true).
    
    return defineObject(self).
}

appRegistry:register("Flight", FlightApp@).
