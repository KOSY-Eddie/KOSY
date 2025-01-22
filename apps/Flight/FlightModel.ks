runoncepath("/KOSY/lib/orbital/manuver_executor").
function FlightModel {
    local self is TaskifiedObject():extend.
    self:setClassName("FlightModel").
    
    self:protected("_view", NULL).
    self:protected("viewElements", lexicon()).
    
    self:public("setView", {
        parameter viewIn.
        set self:_view to viewIn.
        set self:viewElements to viewIn:elements:get().
        
        // Start update task
        local updateTask is lex(
            "condition", { return not isNull(self:_view:parent:get()). },
            "work", self:_update@,
            "delay", 0.1,
            "name", "Flight Display Update"
        ).
        scheduler:addTask(Task(updateTask):new).
        set takeoffParams to lex("launchHeading", 90, "initialPitch",0,"rotationSpeed",100,"rotationPitch",12.5,"gearupaltitude",100,"finalPitch",20).
        self:viewElements:launchItem:setOnSelect(self:takeoff:bind(takeoffParams)@).
    }).

    self:public("takeoff",{
        parameter params.

        self:activateMainEngines().
        self:airBreathingMode().
        lock steering to heading(params:launchHeading, params:initialPitch).
        lock throttle to 1.

        takeoffRoll().

        function takeoffRoll{
            local running is true.
            brakes off.

            self:while({return running.},{
                local desiredHeading is get_runway_heading().
                lock steering to heading(desiredHeading,params:initialPitch).
                if ship:groundspeed >= params:rotationSpeed {
                    //self:updateStatus("Rotation speed achieved. Pitching to " + rotationPitch + "°").
                    set running to false.
                    lock steering to heading(desiredHeading, params:rotationPitch).
                    climbToPatternAlt().
                }
            },.01).
        }

        local function climbToPatternAlt{
            local running is true.
            self:while({return running.},{
                //self:updateStatus("Climbing... " + round(ship:altitude) + "/" + gearUpAltitude + "m").
                if ship:altitude >= params:gearUpAltitude {
                    set running to false.
                    //self:updateStatus("Raising landing gear").
                    gear off.
                    finalizetakeoff().
                }
            },.01).
        }

        local function finalizetakeoff{
            lock steering to heading(params:launchHeading, params:finalPitch).
            set ship:control:pilotmainthrottle to 1.
            set ship:control:neutralize to true.
            set sasmode to "STABILITY".
            sas on.
            climb(lex("orbitalInc", 0, 
            "climbPitch", 15, 
            "targetAltitude", 10000, 
            "transitionAltitude", 8000, "maxClimbRate", 30, "machLimit", 3.3, "maxBankAngle", 30)).
        }

    }).

    local function climb{
        parameter paramsIn. //lex("orbitalInc", 0, "climbPitch", 15, "targetAltitude", 10000, "transitionAltitude", 9000, "maxClimbRate", 30, "machLimit", 3.3, "maxBankAngle", 30)

        function calculateClimbHeading {
            parameter targetInc.
            local lat is ship:latitude.
            if abs(targetInc) > abs(lat) {
                return arcsin(cos(targetInc) / cos(lat)).
            } else {
                return 90. // Default to eastward if inclination not achievable
            }
        }

        local climbHeading is calculateClimbHeading(paramsIn:orbitalInc).

        function headingDiff {
            local diff is climbHeading - get_compass_heading(SHIP:FACING:VECTOR).
            if diff > 180 { set diff to diff - 360. }
            if diff < -180 { set diff to diff + 360. }
            return diff.
        }

        function getDesiredVerticalSpeed {
            parameter currentAlt.
            
            if currentAlt <= paramsIn:transitionAltitude {
                return paramsIn:maxClimbRate.
            } else {
                local slope is -paramsIn:maxClimbRate / (paramsIn:targetAltitude - paramsIn:transitionAltitude).
                local intercept is paramsIn:maxClimbRate - slope * paramsIn:transitionAltitude.
                return slope * currentAlt + intercept.
            }
        }

        
        function initialClimb{
            sas off.
            local running is true.
            self:while(
                { return running. },
                {
                    local diff is headingDiff().
                    local bankAngle is min(abs(diff), paramsIn:maxBankAngle) * (diff/abs(diff)).
                    
                    lock steering to heading(climbHeading, paramsIn:climbPitch, bankAngle).
                    lock throttle to 1.
                    
                    // self:updateStatus("Initial climb phase..." + 
                    //     char(10) + "Bank Angle: " + round(bankAngle, 1) + "°" +
                    //     char(10) + "Diff: " + round(diff, 1) + "°").
                        
                    if ship:altitude > paramsIn:transitionAltitude {
                        set running to false.
                        transitionClimb().
                    }
                }, 0.1
            ).
        }

        function transitionClimb {
    local running is true.
    
    self:while({
        return running.
    }, {
        if ADDONS:FAR:MACH > paramsIn:machLimit {
            set running to false.
            self:ascentToOrbit(lex(
                "initialPitch", 20,
                "finalPitch", 40,
                "targetApoapsis", 80000,
                "velDropThresh", .5
            )).
        } else {
            local diff is headingDiff().
            local bankAngle is min(abs(diff), paramsIn:maxBankAngle) * (diff/abs(diff)).
            local desiredVS is getDesiredVerticalSpeed(ship:altitude).
            
            // Simple linear interpolation for pitch adjustment
            local vsError is desiredVS - ship:verticalspeed.
            local pitchAdjust is clamp(vsError * 0.5, -10, 10).  // 0.5 degree per m/s of error
            
            lock steering to heading(climbHeading, 
                clamp(paramsIn:climbPitch + pitchAdjust, -10, 30),
                bankAngle).
        }
    }, 0.1).
}


        initialClimb().


    }

    self:public("ascentToOrbit",{
        parameter paramsIn. //lex("initialPitch", 20, "finalPitch", 40, "targetApoapsis",8000,"velDropThresh",.5)

        local ascentHeading is get_compass_heading().

        function initialPitch{
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
                        monitorVelocity().
                    } else {
                        local currentPitch is progress * paramsIn:initialPitch.
                        lock steering to heading(ascentHeading, currentPitch).
                         //print "Current Pitch: " + round(currentPitch, 1) + "°".
                    }
                }
            ).
        }

        function monitorVelocity{
            local running is true.
            local maxVelocity is 0.

            self:while(
                { return running. },
                {
                    if ship:airspeed > maxVelocity {
                        set maxVelocity to ship:airspeed.
                    } else if ship:airspeed < (maxVelocity - paramsIn:velDropThresh) {
                        set running to false.
                        finalPitch().
                    }
                    // self:updateStatus("Monitoring velocity", 
                    print     "Max Speed: " + round(maxVelocity, 1) + " m/s" at (0,terminal:height -1 ).
                }
            ).
        }

        function finalPitch{
            local running is true.
            local startTime is time:seconds.
            local pitchTime is 20.

            self:rocketMode().
            self:while(
                { return running. },
                {
                    local progress is (time:seconds - startTime) / pitchTime.
                    if progress >= 1 {
                        set running to false.
                        burnToApoapsis().
                    } else {
                        local currentPitch is paramsIn:initialPitch + (paramsIn:finalPitch - paramsIn:initialPitch) * progress.
                        lock steering to heading(ascentHeading, currentPitch).
                        // self:updateStatus("Final pitch phase", 
                        print     "Current Pitch: " + round(currentPitch, 1) + "°" at (0,terminal:height-1).
                    }
                }
            ).

        }

        function burnToApoapsis{
            local running is true.
        
            self:while(
                { return running. },
                {
                    if ship:apoapsis >= paramsIn:targetApoapsis {
                        set running to false.
                        coastToSpace().
                    }
                    lock steering to heading(ascentHeading, paramsIn:finalPitch).
                    // self:updateStatus("Burning to apoapsis", 
                    //print     "Target: " + round(targetApoapsis) + " m" at (0,terminal:height-1).
                }
            ).
        }

        function coastToSpace{
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
                        local executor is ManeuverExecutor():new.
                        executor:createCircNodeAtAp().
                        executor:executeNode({ sas on. rcs off. }).
                    }
                    //self:updateStatus("Coasting to space").
                }, 0.1
            ).
        
         }

        initialPitch().
    }).
        

    self:public("shudownMainEngines",{

        local rapierEngines is ship:partsnamed("rapier").

        for engine in rapierEngines
            engine:shutdown.

    }).

    self:public("activateMainEngines",{

        local rapierEngines is ship:partsnamed("rapier").

        for engine in rapierEngines
            engine:activate.

    }).

    self:public("airBreathingMode",{
        intakes on.
        local rapierEngines is ship:partsnamed("rapier").

        for engine in rapierEngines{
            set engine:autoswitch to false.
            if engine:mode = "ClosedCycle"
                engine:togglemode().
        }
    }).

    self:public("rocketMode",{
        local rapierEngines is ship:partsnamed("rapier").

        for engine in rapierEngines{
            if engine:mode = "AirBreathing"
                engine:togglemode().
        }
        intakes off.
    }).
    
    self:protected("_update", {
        //if isNull(self:_view:parent:get()) return.
        
        // Update hold indicators
        self:viewElements["spdHold"]:setText(choose "SPD HOLD" if false else "[SPD HOLD]").
        self:viewElements["hdgHold"]:setText(choose "HDG HOLD" if false else "[HDG HOLD]").
        self:viewElements["altHold"]:setText(choose "ALT HOLD" if true else "[ALT HOLD]").

        // Update primary values
        self:viewElements["speedText"]:setText("SPD: " + round(ship:airspeed, 1) + "m/s").
        self:viewElements["headingText"]:setText("HDG: " + round(get_compass_heading(), 1) + "°").
        self:viewElements["altitudeText"]:setText("ALT: " + round(ship:altitude, 0) + "m").

        // Update secondary values
        local machSpd is 0.
        if ADDONS:AVAILABLE("FAR")
            set machSpd to ADDONS:FAR:MACH.
        else 
            set machSpd to ship:airspeed / 343.2.

        self:viewElements["machText"]:setText("MACH: " + round(machSpd, 2)).
        self:viewElements["vsiText"]:setText("VSI: " + round(ship:verticalspeed, 1)).
        self:viewElements["twrText"]:setText("TWR: " + round(ship:availablethrust / (ship:mass * 9.81), 2)).
        self:viewElements["enduranceText"]:setText("END: " + round(ship:deltaV:current, 0) + "dv").
    }).
    
    return defineObject(self).
}
