runOncePath("/KOSY/lib/taskifiedobject.ks").

function SystemInputHandler {
    local self is Object():extend.
    self:setClassName("InputHandler").
    
    // Input constants
    local INPUT_UP is "UP".
    local INPUT_DOWN is "DOWN".
    local INPUT_LEFT is "LEFT".
    local INPUT_RIGHT is "RIGHT".
    local INPUT_CONFIRM is "CONFIRM".
    local INPUT_CANCEL is "CANCEL".
    //local INPUT_NONE is "NONE".
    
    self:protected("callback", {}).
    //self:protected("lastInput", INPUT_NONE).
    local buttons is addons:kpm:buttons.

    local function lastInput{
        parameter val.
        self:callback(val).
    }
    
    local function setupKPMDelegates {
        if addons:available("kpm") {
            buttons:setdelegate(-3, self:callback@:bind(INPUT_UP)).
            buttons:setdelegate(-4, self:callback@:bind(INPUT_DOWN)).
            buttons:setdelegate(-5, self:callback@:bind(INPUT_LEFT)).
            buttons:setdelegate(-6, self:callback@:bind(INPUT_RIGHT)).
            buttons:setdelegate(-1, self:callback@:bind(INPUT_CONFIRM)).
            buttons:setdelegate(-2, self:callback@:bind(INPUT_CANCEL)).
        }.
    }.
    
    local function checkInputFunc {
        
        if terminal:input:haschar {
            local ch is terminal:input:getchar().
            if ch = terminal:input:upcursorone {
                self:callback(INPUT_UP).
            } else if ch = terminal:input:downcursorone {
                self:callback(INPUT_DOWN).
            } else if ch = terminal:input:leftcursorone {
                self:callback(INPUT_LEFT).
            } else if ch = terminal:input:rightcursorone {
                self:callback(INPUT_RIGHT).
            } else if ch = terminal:input:return {
                self:callback(INPUT_CONFIRM).
            } else if ch = "c" {
                self:callback(INPUT_CANCEL).
            }.
        }.

            
            
    }


    self:public("registerCallback", {
        parameter callbackFunc. 
        set self:callback to callbackFunc.
        setupKPMDelegates().
    }).
    
    self:public("checkInput",{checkInputFunc().}).
    
    return defineObject(self).
}
