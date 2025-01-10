runOncePath("CP-01/cp_ascent").
runoncepath("/KOSY/lib/utils").

function CPClimb {
    parameter drawableArea.
    local self is View(drawableArea):extend.
    self:setClassName("CPClimb").
    
    
    // Flight parameters. TODO: read these params from a config file
    local orbitalInc is 0. 
    local climbPitch is 15.
    local targetAltitude is 10000.
    local transitionAltitude is 9000.
    local maxClimbRate is 30.
    local machLimit is 3.3.
    local maxBankAngle is 30.    // Maximum bank angle during turns
    
    // PID Controller
    local vsController is PIDLOOP(0.75, 0.1, 0.01, -30, 30).
    local climbHeading is calculateClimbHeading(orbitalInc).

        // Calculate heading based on inclination
    function calculateClimbHeading {
        parameter targetInc.
        local lat is ship:latitude.
        if abs(targetInc) > abs(lat) {
            return arcsin(cos(targetInc) / cos(lat)).
        } else {
            return 90. // Default to eastward if inclination not achievable
        }
    }
    
    // Heading difference calculation
    function headingDiff {
        local diff is climbHeading - get_compass_heading(SHIP:FACING:VECTOR).
        if diff > 180 { set diff to diff - 360. }
        if diff < -180 { set diff to diff + 360. }
        return diff.
    }
    
    // Status display method
    self:public("updateStatus", {
        parameter message.
        local area is self:drawableArea.
        local width is area:lastCol - area:firstCol.
        
        print self:fitText(message):padright(width) at (area:firstCol, area:firstLine).
        print self:fitText("Current Alt: " + round(ship:altitude) + "m"):padright(width) at (area:firstCol, area:firstLine + 2).
        print self:fitText("Target Alt: " + round(targetAltitude) + "m"):padright(width) at (area:firstCol, area:firstLine + 3).
        print self:fitText("Vertical Speed: " + round(ship:verticalspeed, 1) + "m/s"):padright(width) at (area:firstCol, area:firstLine + 4).
        print self:fitText("Mach: " + round(ADDONS:FAR:MACH, 2)):padright(width) at (area:firstCol, area:firstLine + 5).
        print self:fitText("Heading Error: " + round(headingDiff(), 1) + "°"):padright(width) at (area:firstCol, area:firstLine + 6).
    }).

    // Calculate desired vertical speed
    function getDesiredVerticalSpeed {
        parameter currentAlt.
        
        if currentAlt <= transitionAltitude {
            return maxClimbRate.
        } else {
            local slope is -maxClimbRate / (targetAltitude - transitionAltitude).
            local intercept is maxClimbRate - slope * transitionAltitude.
            return slope * currentAlt + intercept.
        }
    }
    
    // Initial climb phase
    self:public("initialClimb", {
        parameter callback.
        local running is true.
        sas off.
        
        self:while(
            { return running. },
            {
                local diff is headingDiff().
                local bankAngle is min(abs(diff), maxBankAngle) * (diff/abs(diff)).
                
                lock steering to heading(climbHeading, climbPitch, bankAngle).
                lock throttle to 1.
                
                self:updateStatus("Initial climb phase..." + 
                    char(10) + "Bank Angle: " + round(bankAngle, 1) + "°" +
                    char(10) + "Diff: " + round(diff, 1) + "°").
                    
                if ship:altitude > transitionAltitude {
                    set running to false.
                    callback().
                }
            }, 0.1
        ).
    }).
    
    // Transition phase
    self:public("transitionClimb", {
        parameter callback.
        local running is true.
        
        self:while(
            { return running. },
            {
                if ADDONS:FAR:MACH > machLimit {
                    set running to false.
                    callback().
                } else {
                    local diff is headingDiff().
                    local bankAngle is min(abs(diff), maxBankAngle) * (diff/abs(diff)).
                    local desiredVS is getDesiredVerticalSpeed(ship:altitude).
                    set vsController:SETPOINT to desiredVS.
                    local pitchAdjust is vsController:UPDATE(TIME:SECONDS, ship:verticalspeed).
                    
                    lock steering to heading(climbHeading, 
                        max(min(climbPitch + pitchAdjust, 30), -10),
                        bankAngle).
                    
                    self:updateStatus("Transition climb phase..." + 
                        char(10) + "Target VS: " + round(desiredVS, 1) + "m/s" +
                        char(10) + "Pitch Adjustment: " + round(pitchAdjust, 1) + "°" +
                        char(10) + "Bank Angle: " + round(bankAngle, 1) + "°").
                }
            }, 0.1
        ).
    }).
    
    self:protected("draw", {
        if self:isActive() {
            self:updateStatus("CP Climb Sequence").
        }
    }).
    
    self:protected("handleInput", {
        parameter input.
        if input = "CANCEL" {
            self:focusRoot().
        }
    }).
    
    self:public("execute", {
        self:clearArea().
        self:updateStatus("Starting climb sequence...").
        
        local function beginClimb {
            self:initialClimb(startTransition@).
        }
        
        local function startTransition {
            self:transitionClimb(completeClimb@).
        }
        
        local function completeClimb {
            self:clearArea().
            self:updateStatus("Mach " + machLimit + " reached - climb complete").
            local ascent is CPAscent(self:drawableArea):new.
            ascent:activate().
            ascent:execute().
        }
        
        beginClimb().
    }).
    
    return defineObject(self).
}
