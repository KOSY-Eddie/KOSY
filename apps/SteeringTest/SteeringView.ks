function SteeringView {
    local self is VContainerView():extend.
    
    self:protected("_viewModel", NULL).
    self:protected("_selectedControl", "heading").
    self:protected("_editMode", false).
    
    // Create containers for set values and actual values
    local setContainer is HContainerView():new.
    local actualContainer is HContainerView():new.
    
    // Create text views for all values
    self:protected("_setPitch", TextView():new).
    self:protected("_setHeading", TextView():new).
    self:protected("_setRoll", TextView():new).
    self:protected("_actualPitch", TextView():new).
    self:protected("_actualHeading", TextView():new).
    self:protected("_actualRoll", TextView():new).
    
    // Add views to containers
    setContainer:addChild(self:_setPitch).
    setContainer:addChild(self:_setHeading).
    setContainer:addChild(self:_setRoll).
    actualContainer:addChild(self:_actualPitch).
    actualContainer:addChild(self:_actualHeading).
    actualContainer:addChild(self:_actualRoll).
    
    // Add containers to main view
    self:addChild(setContainer).
    self:addChild(actualContainer).
    
    self:public("elements", lexicon(
        "setPitch", self:_setPitch,
        "setHeading", self:_setHeading,
        "setRoll", self:_setRoll,
        "actualPitch", self:_actualPitch,
        "actualHeading", self:_actualHeading,
        "actualRoll", self:_actualRoll
    )).
    
    self:public("handleInput", {
        parameter key.
        
        if key = "UNFOCUS" {
            self:setInput(false).
            return.
        }
        
        if key = "LEFT" or key = "RIGHT" {
            local controls is list("heading", "pitch", "roll").
            local currentIdx is controls:find(self:_selectedControl).
            if key = "RIGHT" {
                set currentIdx to mod((currentIdx - 1 + controls:length), controls:length).
            } else {
                set currentIdx to mod((currentIdx + 1), controls:length).
            }
            set self:_selectedControl to controls[currentIdx].
            self:updateDisplay().
        } else if key = "UP" or key = "DOWN" {
            local delta is choose 5 if key = "UP" else -5.

            local currentValue is self:_viewModel:getFlightData()["set" + self:_selectedControl].
            local newValue is currentValue + delta.
            
            // Input validation
            if self:_selectedControl = "heading" {
                set newValue to mod(newValue + 360, 360).
            } else if self:_selectedControl = "pitch" {
                set newValue to max(min(newValue, 90), -90).
            } else if self:_selectedControl = "roll" {
                set newValue to max(min(newValue, 180), -180).
            }
            
            self:_viewModel:updateValue(self:_selectedControl, newValue).
            self:updateDisplay().
        }
    }).
    

    
    self:public("updateDisplay", {
        local data is self:_viewModel:getFlightData().
        
        // Update displays with visual indicators for selection and edit mode
        local pitchText is "Set Pitch: " + round(data:setPitch, 1).
        local hdgText is "Set Hdg: " + round(data:setHeading, 1).
        local rollText is "Set Roll: " + round(data:setRoll, 1).
        
        // Add indicators for selected control and edit mode
        if self:_selectedControl = "pitch" {
            set pitchText to (choose " *" if self:_editMode else " >") + pitchText .
        }
        if self:_selectedControl = "heading" {
            set hdgText to (choose " *" if self:_editMode else " >") + hdgText.
        } 
        if self:_selectedControl = "roll" {
            set rollText to (choose " *" if self:_editMode else " >") + rollText.
        }
        
        // Update view elements
        self:_setPitch:setText(pitchText).
        self:_setHeading:setText(hdgText).
        self:_setRoll:setText(rollText).
        
        self:_actualPitch:setText("Pitch: " + round(data:actualPitch, 1)).
        self:_actualHeading:setText("Hdg: " + round(data:actualHeading, 1)).
        self:_actualRoll:setText("Roll: " + round(data:actualRoll, 1)).
    }).
    
    self:public("onLoad", {
        self:setInput(true).
    }).
    
    self:public("setViewModel", {
        parameter vm.
        set self:_viewModel to vm.
    }).
    
    return defineObject(self).
}