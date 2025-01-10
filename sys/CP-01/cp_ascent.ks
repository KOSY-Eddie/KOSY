runOncePath("/KOSY/lib/orbital/manuver_executor").
runOncePath("/KOSY/lib/utils").

function CPAscent {
    parameter drawableArea.
    local self is View(drawableArea):extend.
    self:setClassName("CPAscent").
    
    // Ascent parameters
    local initialPitch is 20.
    local finalPitch is 40.
    local ascentHeading is get_compass_heading().
    local targetApoapsis is 80000.
    local velDropThresh is 0.5.
    
    // Status display method
    self:public("updateStatus", {
        parameter message, extraInfo is "".
        local area is self:drawableArea.
        local width is area:lastCol - area:firstCol.
        
        print self:fitText(message):padright(width) at (area:firstCol, area:firstLine).
        print self:fitText("Speed: " + round(ship:airspeed, 1) + " m/s"):padright(width) at (area:firstCol, area:firstLine + 2).
        print self:fitText("Altitude: " + round(ship:altitude) + " m"):padright(width) at (area:firstCol, area:firstLine + 3).
        print self:fitText("Apoapsis: " + round(ship:apoapsis) + " m"):padright(width) at (area:firstCol, area:firstLine + 4).
        if extraInfo:length > 0 {
            print self:fitText(extraInfo):padright(width) at (area:firstCol, area:firstLine + 5).
        }
    }).

    
    // Initial pitch phase
    self:public("initialPitch", {
        parameter callback.
        local running is true.
        local startTime is time:seconds.
        local pitchTime is 30.
        
        lock throttle to 1.
        sas off.
        
        self:while(
            { return running. },
            {
                local progress is (time:seconds - startTime) / pitchTime.
                if progress >= 1 {
                    set running to false.
                    callback().
                } else {
                    local currentPitch is progress * initialPitch.
                    lock steering to heading(ascentHeading, currentPitch).
                    self:updateStatus("Initial pitch phase", 
                        "Current Pitch: " + round(currentPitch, 1) + "°").
                }
            }
        ).
    }).
    
    // Monitor velocity phase
    self:public("monitorVelocity", {
        parameter callback.
        local running is true.
        local maxVelocity is 0.
        
        self:while(
            { return running. },
            {
                if ship:airspeed > maxVelocity {
                    set maxVelocity to ship:airspeed.
                } else if ship:airspeed < (maxVelocity - velDropThresh) {
                    set running to false.
                    callback().
                }
                self:updateStatus("Monitoring velocity", 
                    "Max Speed: " + round(maxVelocity, 1) + " m/s").
            }
        ).
    }).

    function isRapierUsingOxidizer {
        parameter eng.
        
        local isUsingOxidizer is false.
        for resource in eng:consumedresources:values {
            if resource:name = "OXIDIZER" {
                set isUsingOxidizer to true.
            }
        }
        return isUsingOxidizer.
    }

    function setRapiersToClosedCycle {
        self:updateStatus("Setting RAPIER engines to closed cycle mode...").
        for eng in ship:engines {
            if eng:name:contains("RAPIER") {
                if not isRapierUsingOxidizer(eng) {
                    self:updateStatus( "  Found RAPIER in air-breathing mode - switching to closed cycle").
                    eng:togglemode.
                } else {
                    self:updateStatus("  Found RAPIER already in closed cycle mode").
                }
            }
        }
    }
    
    // Final pitch phase
    self:public("finalPitch", {
        parameter callback.
        local running is true.
        local startTime is time:seconds.
        local pitchTime is 20.
        
        setRapiersToClosedCycle().
        intakes off.
        
        self:while(
            { return running. },
            {
                local progress is (time:seconds - startTime) / pitchTime.
                if progress >= 1 {
                    set running to false.
                    callback().
                } else {
                    local currentPitch is initialPitch + (finalPitch - initialPitch) * progress.
                    lock steering to heading(ascentHeading, currentPitch).
                    self:updateStatus("Final pitch phase", 
                        "Current Pitch: " + round(currentPitch, 1) + "°").
                }
            }
        ).
    }).
    
    // Burn to apoapsis
    self:public("burnToApoapsis", {
        parameter callback.
        local running is true.
        
        self:while(
            { return running. },
            {
                if ship:apoapsis >= targetApoapsis {
                    set running to false.
                    callback().
                }
                lock steering to heading(ascentHeading, finalPitch).
                self:updateStatus("Burning to apoapsis", 
                    "Target: " + round(targetApoapsis) + " m").
            }
        ).
    }).
    
    // Coast to space
    self:public("coastToSpace", {
        parameter callback.
        local running is true.
        
        lock throttle to 0.
        lock steering to prograde.
        rcs on.
        
        self:while(
            { return running. },
            {
                if ship:altitude > 70000 {
                    set running to false.
                    rcs off.
                    callback().
                }
                self:updateStatus("Coasting to space").
            }, 0.1
        ).
    }).
    
    // Override draw method from View
    self:protected("draw", {
        if self:isActive() {
            self:updateStatus("CP Ascent Sequence").
        }
    }).
    
    // Override handleInput from View
    self:protected("handleInput", {
        parameter input.
        if input = "CANCEL" {
            self:focusRoot().
        }
    }).
    
    // Main ascent sequence
    self:public("execute", {
        self:clearArea().
        self:updateStatus("Starting ascent sequence...").
        
        self:initialPitch({
            self:monitorVelocity({
                self:finalPitch({
                    self:burnToApoapsis({
                        self:coastToSpace({
                            self:clearArea().
                            self:updateStatus("Ascent complete - in space!").
                            local executor is ManeuverExecutor(self:DrawableArea):new.
                            executor:createCircNodeAtAp().
                            executor:executeNode({ sas on. rcs off. }).
                        }).
                    }).
                }).
            }).
        }).
    }).
    
    return defineObject(self).
}
