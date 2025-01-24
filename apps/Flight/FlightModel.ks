runoncePath("FlightHolds").

function FlightModel {
    local self is TaskifiedObject():extend.
    self:setClassName("FlightModel").
    
    local fltHlds is FlightHolds():new.
    // Protected members
    self:protected("_hdgHoldEnabled", false).
    self:protected("_hdgHoldTarget", 0).
    self:protected("_hdgHoldIncAmount", 5).
    self:protected("_engineState", lexicon(
        "mode", "airbreathing",
        "active", false
    )).
    
    // Public methods for getting state
    self:publicS("getFlightData", {

        return lexicon(
            "speed", ship:airspeed,
            "heading", get_compass_heading(),
            "altitude", ship:altitude,
            "mach", choose ADDONS:FAR:MACH if ADDONS:AVAILABLE("FAR") else ship:airspeed / 343.2,
            "vsi", ship:verticalspeed,
            "twr", ship:availablethrust / (ship:mass * 9.81),
            "deltaV", ship:deltaV:current,
            "engineState", self:_engineState,
            "hdgHoldEnabled", self:_hdgHoldEnabled,
            "hdgHoldTarget", self:_hdgHoldTarget,
            "hdgHoldIncAmount", self:_hdgHoldIncAmount
        ).
    }).

    

    // Heading Hold Controls
    self:public("toggleHdgHold", {
        set self:_hdgHoldEnabled to not self:_hdgHoldEnabled.
        if self:_hdgHoldEnabled {
            fltHlds:engageHeadingHold().
            fltHlds:setTargetHeading(self:_hdgHoldTarget).
        } else {
            // When disabling, let FBW know to release heading control
            fltHlds:releaseHeadingHold().
        }
    }).


    self:publicS("increaseHdgIncAmount", {
        local allowedValues is list(0.5, 1, 5, 10).
        local currentIndex is allowedValues:find(self:_hdgHoldIncAmount).
        if currentIndex < allowedValues:length - 1 {
            set self:_hdgHoldIncAmount to allowedValues[currentIndex + 1].
        }
        return self:_hdgHoldIncAmount.
    }).

    self:publicS("decreaseHdgIncAmount", {
        local allowedValues is list(0.5, 1, 5, 10).
        local currentIndex is allowedValues:find(self:_hdgHoldIncAmount).
        if currentIndex > 0 {
            set self:_hdgHoldIncAmount to allowedValues[currentIndex - 1].
        }
        return self:_hdgHoldIncAmount.
    }).


    self:publicS("incrementHdgTarget", {

        set self:_hdgHoldTarget to mod((self:_hdgHoldTarget + self:_hdgHoldIncAmount+360), 360).
        return self:_hdgHoldTarget.
    }).

    self:publicS("decrementHdgTarget", {
        set self:_hdgHoldTarget to mod((self:_hdgHoldTarget - self:_hdgHoldIncAmount+360), 360).
        return self:_hdgHoldTarget.
    }).

    // Engine Controls
    self:public("shutdownMainEngines", {
        local rapierEngines is ship:partsnamed("rapier").
        for engine in rapierEngines {
            engine:shutdown.
        }
        set self:_engineState:active to false.
    }).

    self:public("activateMainEngines", {
        local rapierEngines is ship:partsnamed("rapier").
        for engine in rapierEngines {
            engine:activate.
        }
        set self:_engineState:active to true.
    }).

    self:public("airBreathingMode", {
        intakes on.
        local rapierEngines is ship:partsnamed("rapier").
        for engine in rapierEngines {
            set engine:autoswitch to false.
            if engine:mode = "ClosedCycle" {
                engine:togglemode().
            }
        }
        set self:_engineState:mode to "airbreathing".
    }).

    self:public("rocketMode", {
        local rapierEngines is ship:partsnamed("rapier").
        for engine in rapierEngines {
            if engine:mode = "AirBreathing" {
                engine:togglemode().
            }
        }
        intakes off.
        set self:_engineState:mode to "rocket".
    }).
    
    // Protected methods
    self:protected("_update", {
        if self:_hdgHoldEnabled {
            lock steering to heading(self:_hdgHoldTarget, 0).
        }
    }).

    return defineObject(self).
}
