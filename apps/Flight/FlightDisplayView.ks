// FlightControl/Views/FlightDisplayView.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/MenuList").
runOncePath("/KOSY/lib/KOSYView/MenuItem").

function FlightDisplayView {
    local self is VContainerView():extend.
    self:setClassName("FlightDisplay").
    
    // Protected members
    self:protected("_holdContainer", HContainerView():new).
    self:protected("_primaryContainer", HContainerView():new).
    self:protected("_secondaryContainer", HContainerView():new).
    self:protected("_controlsContainer", HContainerView():new).
    
    // Hold indicators
    self:protected("_spdHoldInd", TextView():new).
    self:protected("_hdgHoldInd", TextView():new).
    self:protected("_altHoldInd", TextView():new).
    
    // Primary values
    self:protected("_speedText", TextView():new).
    self:protected("_headingText", TextView():new).
    self:protected("_altitudeText", TextView():new).
    
    // Secondary values
    self:protected("_machText", TextView():new).
    self:protected("_vsiText", TextView():new).
    self:protected("_twrText", TextView():new).
    self:protected("_enduranceText", TextView():new).
    
    // Menu setup
    //self:protected("_menu_flightHolds", MenuList():new).
    //self:_menu_flightHolds:expandY:set(false).
    self:protected("_hdgHoldMenuElements", CreateSetIncMenu("HDG Hold")).
    
    // Initialize view layout
    local function initializeLayout {
        // Set up hold indicators
        self:_holdContainer:addChild(self:_spdHoldInd).
        self:_holdContainer:addChild(self:_hdgHoldInd).
        self:_holdContainer:addChild(self:_altHoldInd).
        
        // Set up primary values
        self:_primaryContainer:addChild(self:_speedText).
        self:_primaryContainer:addChild(self:_headingText).
        self:_primaryContainer:addChild(self:_altitudeText).
        
        // Set up secondary values
        self:_secondaryContainer:addChild(self:_machText).
        self:_secondaryContainer:addChild(self:_vsiText).
        self:_secondaryContainer:addChild(self:_twrText).
        self:_secondaryContainer:addChild(self:_enduranceText).
        
        // Set up controls
        self:_hdgHoldMenuElements:menu:setBackCallBack({appMenu:setInput(true).}).
        //self:_menu_flightHolds:addChild(self:_hdgHoldMenuItems:menu).
        self:_controlsContainer:addChild(self:_hdgHoldMenuElements:container).
        
        // Add all containers to main view
        self:addChild(self:_holdContainer).
        self:addChild(self:_primaryContainer).
        self:addChild(self:_secondaryContainer).
        self:addChild(self:_controlsContainer).
    }.
    
    // Expose elements for the ViewModel
    self:public("elements", lexicon(
        "hdgHoldInd", self:_hdgHoldInd,
        "hdgHoldMenuElements", self:_hdgHoldMenuElements,
        "speedText", self:_speedText,
        "headingText", self:_headingText,
        "altitudeText", self:_altitudeText,
        "machText", self:_machText,
        "vsiText", self:_vsiText,
        "twrText", self:_twrText,
        "enduranceText", self:_enduranceText
    )).
    
    // Initialize on load
    self:public("onLoad", {
        self:elements:hdgHoldMenuElements:menu:setInput(true).
    }).
    
    // Initialize layout
    initializeLayout().
    
    return defineObject(self).
}

// Menu factory function
function CreateSetIncMenu {
    parameter menuName.
    
    // Create submenu with Set, Inc, and Toggle options
    local menu is MenuList():new.
    local setItem is MenuItem():new.
    local incItem is MenuItem():new.
    local toggleItem is MenuItem():new.
    
    toggleItem:setText("Toggle").
    setItem:setText("Set 0").
    incItem:setText("Inc 5").
    
    menu:addChild(toggleItem).
    menu:addChild(incItem).
    menu:addChild(setItem).
    
    // Create main menu item
    local menuLabel is TextView():new.
    menuLabel:setText(menuName).
    //menuLabel:halign("left").
    //menuLabel:valign("bottom").
    local menuContainer is VContainerView():new.

    menuContainer:addChild(menuLabel).
    menuContainer:addChild(menu).
    menuContainer:halign("center").
    
    return lexicon(
        "menu", menu,
        "container", menuContainer,
        "setItem", setItem,
        "incItem", incItem,
        "toggleItem", toggleItem
    ).
}
