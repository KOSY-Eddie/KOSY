// FlightControl/FlightControl.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").
runOncePath("/KOSY/lib/Application").

function Flight {
    local self is Application():extend.
    self:setClassName("Flight").
    
    local container is VContainerView():new.
    
    // Top section - Flight Display
    local flightDisplay is FlightDisplayView():new.
    container:addChild(flightDisplay).
    
    // Bottom section - Mode Menu
    local modeMenu is MenuList():new.
    local launchItem is MenuItem():new.
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
    local spdHold is TextView():new.
    local hdgHold is TextView():new.
    local altHold is TextView():new.
    holdContainer:addChild(spdHold).
    holdContainer:addChild(hdgHold).
    holdContainer:addChild(altHold).
    
    // Primary values row
    local primaryContainer is HContainerView():new.
    local speedText is TextView():new.
    local headingText is TextView():new.
    local altitudeText is TextView():new.
    primaryContainer:addChild(speedText).
    primaryContainer:addChild(headingText).
    primaryContainer:addChild(altitudeText).
    
    // Secondary values row
    local secondaryContainer is HContainerView():new.
    local machText is TextView():new.
    local vsiText is TextView():new.
    local twrText is TextView():new.
    local enduranceText is TextView():new.
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
        "condition", { return self:isFocused. },
        "work", {
            // Update display values here
            speedText:setText("SPD: " + round(ship:airspeed, 1)).
            // etc...
        },
        "delay", 0.1,
        "name", "Flight Display Update"
    ).
    
    scheduler:addTask(Task(updateDisplayParams):new).
    return defineObject(self).
}

// Register with AppRegistry
appRegistry:register("Flight", Flight@).
