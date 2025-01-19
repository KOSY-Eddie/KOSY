// FlightControl/FlightControl.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/Application").

function FlightApp {
    local self is Application():extend.
    self:setClassName("Flight").
    
    local container is VContainerView():new.
    container:name:set("Flight app main container").
    
    // Top section - Flight Display
    local flightDisplay is FlightDisplayView():new.
    container:addChild(flightDisplay).
    
    // Bottom section - Mode Menu
    local modeMenu is MenuList():new.
    modeMenu:name:set("Flight Mode Menu").

    local launchItem is MenuItem():new.
    launchItem:name:set("Launch Mode Item").
    launchItem:setText("LAUNCH TO ORBIT").
    launchItem:setOnSelect({
        // Launch mode logic here
    }).
    modeMenu:addChild(launchItem).
    modeMenu:hAlign("left").
    container:addChild(modeMenu).
    
    set self:mainView to container.
    return defineObject(self).
}

function FlightDisplayView {
    local self is VContainerView():extend.
    self:setClassName("FlightDisplay").
    
    // Hold indicators row
    local holdContainer is HContainerView():new.
    holdContainer:name:set("Hold Indicators Container").

    local spdHold is TextView():new.
    spdHold:name:set("Speed Hold Indicator").

    local hdgHold is TextView():new.
    hdgHold:name:set("Heading Hold Indicator").

    local altHold is TextView():new.
    altHold:name:set("Altitude Hold Indicator").

    holdContainer:addChild(spdHold).
    holdContainer:addChild(hdgHold).
    holdContainer:addChild(altHold).
    
    // Primary values row
    local primaryContainer is HContainerView():new.
    primaryContainer:name:set("Primary Values Container").

    local speedText is TextView():new.
    speedText:name:set("Speed Display").

    local headingText is TextView():new.
    headingText:name:set("Heading Display").

    local altitudeText is TextView():new.
    altitudeText:name:set("Altitude Display").

    primaryContainer:addChild(speedText).
    primaryContainer:addChild(headingText).
    primaryContainer:addChild(altitudeText).
    
    // Secondary values row
    local secondaryContainer is HContainerView():new.
    secondaryContainer:name:set("Secondary Values Container").

    local machText is TextView():new.
    machText:name:set("Mach Display").

    local vsiText is TextView():new.
    vsiText:name:set("Vertical Speed Display").

    local twrText is TextView():new.
    twrText:name:set("TWR Display").

    local enduranceText is TextView():new.
    enduranceText:name:set("Endurance Display").

    secondaryContainer:addChild(machText).
    secondaryContainer:addChild(vsiText).
    secondaryContainer:addChild(twrText).
    secondaryContainer:addChild(enduranceText).
    
    // Add all rows to main container
    self:addChild(holdContainer).
    self:addChild(primaryContainer).
    self:addChild(secondaryContainer).
    
    // Update task
    local updateDisplayParams is lex(
        "condition", { return not isNull(self:parent). },
        "work", {
            // Hold indicators
            spdHold:setText(choose "SPD HOLD" if false else "[SPD HOLD]").  // Add your hold logic here
            hdgHold:setText(choose "HDG HOLD" if false else "[HDG HOLD]").
            altHold:setText(choose "ALT HOLD" if true else "[ALT HOLD]").

            // Primary values
            speedText:setText("SPD: " + round(ship:airspeed, 1) + "m/s").
            headingText:setText("HDG: " + round(get_compass_heading(), 1) + "°").
            altitudeText:setText("ALT: " + round(ship:altitude, 0) + "m").

            // Secondary values
            local machSpd is 0.
            if ADDONS:AVAILABLE("FAR")
                set machSpd to ADDONS:FAR:MACH.
            else 
                set machSpd to ship:airspeed / 343.2.

            machText:setText("MACH: " + round(machSpd, 2)). 
            vsiText:setText("VSI: " + round(ship:verticalspeed, 1)).
            twrText:setText("TWR: " + round(ship:availablethrust / (ship:mass * 9.81), 2)).
            enduranceText:setText("END: " + round(ship:deltaV:current, 0) + "dv").

        },
        "delay", 0.25,  // Faster update rate
        "name", "Flight Display Update"
    ).

    scheduler:addTask(Task(updateDisplayParams):new).
    return defineObject(self).
}

// Register with AppRegistry
appRegistry:register("Flight", FlightApp@).
