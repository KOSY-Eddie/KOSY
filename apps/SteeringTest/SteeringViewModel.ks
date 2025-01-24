function SteeringViewModel {
    local self is Object():extend.
    
    self:protected("_view", NULL).
    self:protected("_model", NULL).
    
    self:public("setView", {
        parameter viewIn.
        set self:_view to viewIn.
        viewIn:setViewModel(self).
        
        local updateTask is lex(
            "condition", { return not isNull(self:_view:parent). },
            "work", self:update@,
            "delay", 0.01,
            "name", "Steering Display Update"
        ).
        scheduler:addTask(Task(updateTask):new).
    }).
    
    self:public("setModel", {
        parameter modelIn.
        set self:_model to modelIn.
    }).
    
    self:public("updateValue", {
        parameter control, value.
        if control = "heading" {
            self:_model:setHeading(value).
        } else if control = "pitch" {
            self:_model:setPitch(value).
        } else if control = "roll" {
            self:_model:setRoll(value).
        }
    }).
    
    self:public("getFlightData", {
        return self:_model:getFlightData().
    }).
    
    self:protected("update", {
        if isNull(self:_model) or isNull(self:_view) return.
        self:_view:updateDisplay().
    }).
    
    return defineObject(self).
}