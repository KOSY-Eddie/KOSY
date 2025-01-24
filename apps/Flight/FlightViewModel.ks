// FlightControl/ViewModels/FlightViewModel.ks
function FlightViewModel {
    local self is Object():extend.
    self:setClassName("FlightViewModel").
    
    // Protected members
    self:protected("_view", NULL).
    self:protected("_model", NULL).
    
    // Public methods
    self:public("setView", {
        parameter viewIn.
        set self:_view to viewIn.
        self:initializeCallbacks().
    }).

    self:public("setModel", {
        parameter modelIn.
        set self:_model to modelIn.
        
        // Start update task
        local updateTask is lex(
            "condition", { return not isNull(self:_view:parent). },
            "work", self:update@,
            "delay", 0.1,
            "name", "Flight Display Update"
        ).
        scheduler:addTask(Task(updateTask):new).
    }).

    // Protected methods
    self:protected("update", {
        if isNull(self:_model) or isNull(self:_view) return.
        local data is self:_model:getFlightData().
        self:updateFlightDisplay(data).
    }).

    self:protected("initializeCallbacks", {
        if isNull(self:_view) return.

        local menuElems is self:_view:elements:get():hdgHoldMenuElements.
        
        // Toggle callback
        menuElems:toggleItem:setAction({
            self:_model:toggleHdgHold().
        }).

        function nextCallBack{
            if menuElems:menu:getSelectedMenuItem():getText():contains("Set"){
                menuElems:setItem:setText("Set " + self:_model:incrementHdgTarget()).
            }
            else
                menuElems:incItem:setText("Inc " + self:_model:increaseHdgIncAmount()).
        }


        function backCallBack{
            if menuElems:menu:getSelectedMenuItem():getText():contains("Set")
                menuElems:setItem:setText("Set " + self:_model:decrementHdgTarget()).
            else
                menuElems:incItem:setText("Inc " + self:_model:decreaseHdgIncAmount()).
        }

        // Inc item callbacks
        menuElems:menu:setNextCallback({
            nextCallBack().
        }).
        menuElems:menu:setBackCallback({
            backCallBack().
        }).


    }).

    self:protected("updateFlightDisplay", {
        parameter data.

        // Update heading hold display
        local menuItems is self:_view:elements:get():hdgHoldMenuElements.
        menuItems:toggleItem:setText("Toggle " + (choose "Off" if data:hdgHoldEnabled else "On")).
        menuItems:setItem:setText("Set " + data:hdgHoldTarget).
        menuItems:incItem:setText("Inc " + data:hdgHoldIncAmount).
        self:_view:elements:get():hdgHoldInd:setText(
            (choose "[HDG HLD]" if data:hdgHoldEnabled else "HDG HLD") + 
            char(10) + data:hdgHoldTarget
        ).
        
        // Update primary values
        self:_view:elements:get():speedText:setText("SPD: " + round(data:speed, 1) + "m/s").
        self:_view:elements:get():headingText:setText("HDG: " + round(data:heading, 1) + "°").
        self:_view:elements:get():altitudeText:setText("ALT: " + round(data:altitude, 0) + "m").

        // Update secondary values
        self:_view:elements:get():machText:setText("MACH: " + round(data:mach, 2)).
        self:_view:elements:get():vsiText:setText("VSI: " + round(data:vsi, 1)).
        self:_view:elements:get():twrText:setText("TWR: " + round(data:twr, 2)).
        self:_view:elements:get():enduranceText:setText("END: " + round(data:deltaV, 0) + "dv").
    }).
    
    return defineObject(self).
}
