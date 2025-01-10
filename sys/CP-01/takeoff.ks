runOncePath("CP-01/cp_climb").

function CPTakeOff {
    parameter drawableArea.
    local self is View(drawableArea):extend.
    self:setClassName("SSTOLaunchView").
    
    // Flight parameters
    local launchHeading is get_runway_heading().
    local initialPitch is 0.
    local rotationPitch is 15.
    local finalPitch is 15.
    local rotationSpeed is 100.
    local gearUpAltitude is 100.
    local warningAltitude is 50.
    
    // Status display method
    self:public("updateStatus", {
        parameter message.
        local area is self:drawableArea.
        local width is area:lastCol - area:firstCol.
        
        print message:padright(width) at (area:firstCol, area:firstLine).
        print self:fitText("Ground speed: " + round(ship:groundspeed, 1) + " m/s"):padright(width) at (area:firstCol, area:firstLine + 2).
        print self:fitText("Altitude: " + round(ship:altitude, 1) + " m"):padright(width) at (area:firstCol, area:firstLine + 3).
        print self:fitText("Vertical Speed: " + round(ship:verticalspeed, 1) + " m/s"):padright(width) at (area:firstCol, area:firstLine + 4).
    }).

    
    // Engine setup
    self:public("setupEngines", {
        parameter callback.
        self:updateStatus("Shutting down all engines...").
        lock throttle to 0.
        for eng in ship:engines { eng:shutdown. }
        
        self:updateStatus("Activating RAPIER engines...").
        //setRapiersToAirBreathing().
        for eng in ship:engines {
            if eng:name:contains("RAPIER") { eng:activate. }
        }
        
        intakes on.
        brakes off.
        callback().
    }).
    
    // Initial flight setup
    self:public("initialSetup", {
        parameter callback.
        self:updateStatus("Setting course - heading: " + round(launchHeading) + "°, pitch: " + round(initialPitch) + "°").
        lock steering to heading(launchHeading, initialPitch).
        lock throttle to 1.
        callback().
    }).
    
    // Rotation phase
    self:public("performRotation", {
        parameter callback.
        local running is true.
        self:while(
            { return running. },
            { 
                self:updateStatus("Waiting for takeoff speed (" + rotationSpeed + " m/s)...").
                local desiredHeading is get_runway_heading().
                lock steering to heading(desiredHeading,initialPitch).
                if ship:groundspeed >= rotationSpeed {
                    self:updateStatus("Rotation speed achieved. Pitching to " + rotationPitch + "°").
                    set running to false.
                    lock steering to heading(desiredHeading, rotationPitch).
                    callback().
                }
            }, 0.01
        ).
    }).
    
    // Climb phase
    self:public("performClimb", {
        parameter callback.
        local running is true.
        self:while(
            { return running. },
            {
                self:updateStatus("Climbing... " + round(ship:altitude) + "/" + gearUpAltitude + "m").
                if ship:altitude < warningAltitude and ship:verticalspeed < 0 {
                    self:updateStatus("WARNING: Low altitude and descending!").
                }
                if ship:altitude >= gearUpAltitude {
                    set running to false.
                    self:updateStatus("Raising landing gear").
                    gear off.
                    callback().
                }
            }, 0.1
        ).
    }).
    
    // Final setup
    self:public("finalizeSetup", {
        parameter callback.
        lock steering to heading(launchHeading, finalPitch).
        set ship:control:pilotmainthrottle to 1.
        set ship:control:neutralize to true.
        set sasmode to "STABILITY".
        sas on.
        self:updateStatus("Launch sequence complete").
        callback().
    }).
    
    // Main launch sequence
    self:public("execute", {
        self:clearArea().
        
        local function onComplete {
            self:clearArea().
            self:updateStatus("Launch sequence complete - heading: " + 
                      round(launchHeading) + "°, pitch: " + 
                      round(finalPitch) + "°").
            local climb is CPClimb(self:drawableArea):new.
            climb:activate().
            climb:execute().
        }

        sas off.
        rcs off.
        
        self:setupEngines({
            self:initialSetup({
                self:performRotation({
                    self:performClimb({
                        self:finalizeSetup(onComplete@).
                    }).
                }).
            }).
        }).
    }).
    
    return defineObject(self).
}


