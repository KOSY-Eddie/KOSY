// FlightControl/Views/FlightDisplayView.ks

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
    
    // Controls container
    local controlsContainer is HContainerView():new.
    controlsContainer:name:set("Controls Container").
    
    local modeMenu is MenuList():new.
    
    local launchItem is MenuItem():new.
    launchItem:setText("LAUNCH TO ORBIT").
    
    modeMenu:addChild(launchItem).
    modeMenu:hAlign("left").
    controlsContainer:addChild(modeMenu).
    
    // Add all containers to main view
    self:addChild(holdContainer).
    self:addChild(primaryContainer).
    self:addChild(secondaryContainer).
    self:addChild(controlsContainer).
    
    // Expose text elements for the model to update
    self:public("elements", lexicon(
        "spdHold", spdHold,
        "hdgHold", hdgHold,
        "altHold", altHold,
        "speedText", speedText,
        "headingText", headingText,
        "altitudeText", altitudeText,
        "machText", machText,
        "vsiText", vsiText,
        "twrText", twrText,
        "enduranceText", enduranceText,
        "launchItem", launchItem,
        "modeMenu", modeMenu,
        "orbitLaunch", launchItem
    )).

    local super_setFocus is self:setFocus.
    self:public("setFocus",{
        parameter focused.
        super_setFocus(focused).
        self:elements["modeMenu"]:setFocus(focused).

    }).
    
    return defineObject(self).
}
