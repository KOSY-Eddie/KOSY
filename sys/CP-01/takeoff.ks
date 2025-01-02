function TakeoffPhase {
    parameter flightApp.
    local self is TaskifiedObject():extend.
    self:setClassName("TakeoffPhase").
    
    // Flight parameters
    local launchHeading is 90.5.
    local initialPitch is 0.
    local rotationPitch is 15.
    local finalPitch is 15.
    local rotationSpeed is 100.
    local gearUpAltitude is 100.
    local warningAltitude is 50.
    
    // Phase state
    local isComplete is false.
    local currentStatus is "".
    local drawCallback is { }.
    
    self:public("start", {
        parameter onComplete, onDraw.
        set drawCallback to onDraw.
        
        // Initialize engines
        self:initializeEngines({
            self:accelerateToRotation({
                self:performRotation({
                    self:climbToGearUp({
                        self:finalizeTakeoff({
                            set isComplete to true.
                            onComplete().
                        }).
                    }).
                }).
            }).
        }).
    }).
    
    local function updateStatus {
        parameter message.
        set currentStatus to message.
        drawCallback(getFlightData()).
    }
    
    local function getFlightData {
        return lex(
            "status", currentStatus,
            "groundspeed", round(ship:groundspeed, 1),
            "altitude", round(ship:altitude, 1),
            "verticalspeed", round(ship:verticalspeed, 1)
        ).
    }
    
    self:protected("initializeEngines", {
        parameter callback.
        updateStatus("Initializing engines...").
        
        lock throttle to 0.
        for eng in ship:engines { eng:shutdown. }
        
        //setRapiersToAirBreathing(). //TODO: Write this.
        for eng in ship:engines {
            if eng:name:contains("RAPIER") { 
                eng:activate. 
            }
        }
        
        set ship:control:pilotmainthrottle to 1.
        intakes on.
        brakes off.
        
        lock steering to heading(launchHeading, initialPitch).
        lock throttle to 1.
        
        callback().
    }).
    
    self:protected("accelerateToRotation", {
        parameter callback.
        updateStatus("Accelerating to rotation speed...").
        
        self:while(
            { return ship:groundspeed <= rotationSpeed. },
            {
                updateStatus("Current speed: " + round(ship:groundspeed, 1) + "/" + rotationSpeed + " m/s").
            },
            0.1
        ).
        
        callback().
    }).
    
    self:protected("performRotation", {
        parameter callback.
        updateStatus("Rotating to climb attitude...").
        lock steering to heading(launchHeading, rotationPitch).
        
        // Brief wait for rotation
        self:while(
            { local count is 0. return { set count to count + 1. return count < 10. }. },
            { },
            0.1
        ).
        
        callback().
    }).
    
    self:protected("climbToGearUp", {
        parameter callback.
        updateStatus("Climbing to gear-up altitude...").
        
        self:while(
            { return ship:altitude <= gearUpAltitude. },
            {
                updateStatus("Altitude: " + round(ship:altitude, 1) + "/" + gearUpAltitude + " m").
                if ship:altitude < warningAltitude and ship:verticalspeed < 0 {
                    updateStatus("WARNING: Low altitude and descending!").
                }
            },
            0.1
        ).
        
        gear off.
        callback().
    }).
    
    self:protected("finalizeTakeoff", {
        parameter callback.
        updateStatus("Finalizing takeoff...").
        
        lock steering to heading(launchHeading, finalPitch).
        set ship:control:pilotmainthrottle to 1.
        set ship:control:neutralize to true.
        sas on.
        wait 0.1.
        set sasmode to "STABILITY".
        
        callback().
    }).
    
    return defineObject(self).
}
