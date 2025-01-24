runOncePath("SteeringModel").
runOncePath("SteeringViewModel").
runOncePath("SteeringView").

function SteeringControlApp {
    local self is Application():extend.
    
    local model is SteeringModel():new.
    local viewModel is SteeringViewModel():new.
    set self:mainView to SteeringView():new.
    
    viewModel:setModel(model).
    viewModel:setView(self:mainView).
    
    return defineObject(self).
}

appRegistry:register("Steering", SteeringControlApp@).