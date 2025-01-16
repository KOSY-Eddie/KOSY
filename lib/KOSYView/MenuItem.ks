runOncePath("/KOSY/lib/KOSYView/ContainerView").

function MenuItem {
    local self is VContainerView():extend.
    self:setClassName("MenuItem").
    
    local selected is false.
    local standardCursor is "> ".
    local submenuCursor is "v ".
    local onSelect is { }.
    local currentCursor is standardCursor.
    local originalText is "".
    local submenu is 0.  
    local submenuContainer is 0.
    
    local textLabel is TextView():new.
    self:addChild(textLabel).
    
    local function updateLabelText {
        parameter textIn.
        if selected {
            textLabel:setText(currentCursor + textIn).
        } else {
            textLabel:setText(" ":padRight(standardCursor:length) + textIn).
        }
    }

    // In MenuItem, add type checking
    self:public("addSubmenu", {
        parameter menuItemIn.
        if menuItemIn:getClassName() <> "MenuList" {
            print "Error: Submenu must be a MenuList".
            return.
        }
        set submenu to menuItemIn.
        
        // Set up back navigation
        submenu:setBackCallback({
            self:triggerSelect().
            self:parent:setFocus(true).
        }).
        
        // Create horizontal container for indentation
        set submenuContainer to HContainerView():new.
        local spacer is TextView():new.
        spacer:setText("  ").
        spacer:setExpandX(false).
        
        submenuContainer:addChild(spacer).
        submenuContainer:addChild(submenu).
    }).



    self:public("setOnSelect", {
        parameter actionIn.
        set onSelect to actionIn.
    }).

    self:public("getText", { 
        return textLabel:getText().
    }).

    self:public("setText", {
        parameter textIn.
        set originalText to textIn.
        updateLabelText(originalText).
    }).
    
    self:public("triggerSelect", {
        if submenu <> 0 {
            set currentCursor to choose submenuCursor if currentCursor = standardCursor else standardCursor.
            updateLabelText(originalText).
            
            if currentCursor = submenuCursor {
                self:addChild(submenuContainer).
                submenu:setFocus(true).
            } else {
                self:removeChild(submenuContainer).
            }
            self:drawAll().
        }
        onSelect().
    }).
    
    self:public("setSelected", {
        parameter isSelected.
        set selected to isSelected.
        updateLabelText(originalText).
    }).

    self:public("hAlign", {
        parameter alignmentIn.
        textLabel:hAlign(alignmentIn).
    }).

    self:public("vAlign", {
        parameter alignmentIn.
        textLabel:vAlign(alignmentIn).
    }).
    
    return defineObject(self).
}

