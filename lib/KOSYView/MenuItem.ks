runOncePath("/KOSY/lib/KOSYView/ContainerView").

function MenuItem {
    local self is VContainerView():extend.
    self:setClassName("MenuItem").
    
    self:protected("selected", false).
    local standardCursor is "> ".
    local submenuCursor is "v ".
    self:protected("onSelect", { }).
    local currentCursor is standardCursor.
    self:protected("originalText", "").
    local submenu is null.  
    local submenuContainer is null.
    
    self:protected("textLabel", TextView():new).
    self:addChild(self:textLabel).
    
    self:protected("updateLabelText", {
        parameter textIn.
        if self:selected {
            self:textLabel:setText(currentCursor + textIn).
        } else {
            self:textLabel:setText(" ":padRight(standardCursor:length) + textIn).
        }
    }).

    // In MenuItem, add type checking
    self:public("addSubmenu", {
        parameter menuItemIn.
        if menuItemIn:getClassName() <> "MenuList" {
            //print "Error: Submenu must be a MenuList".
            return.
        }
        set submenu to menuItemIn.
        
        // Set up back navigation
        submenu:setBackCallback({
            self:triggerSelect().
            self:removeChild(submenuContainer).
            self:parent:setFocus(true).
            self:drawAll().
        }).
        
        // Create horizontal container for indentation
        set submenuContainer to HContainerView():new.
        local spacer is TextView():new.
        spacer:setText("  ").
        spacer:expandx:set(false).
        
        submenuContainer:addChild(spacer).
        submenuContainer:addChild(submenu).
    }).



    self:public("setOnSelect", {
        parameter actionIn.
        set self:onSelect to actionIn.
    }).

    self:public("getText", { 
        return self:textLabel:getText().
    }).

    self:public("setText", {
        parameter textIn.
        set self:originalText to textIn.
        self:updateLabelText(self:originalText).
    }).
    
    self:public("triggerSelect", {
        if not isNull(submenu) {
            set currentCursor to choose submenuCursor if currentCursor = standardCursor else standardCursor.
            self:updateLabelText(self:originalText).
            
            if currentCursor = submenuCursor {
                self:addChild(submenuContainer).
                submenu:setFocus(true).
            } 
            self:drawAll().
        } 
        self:onSelect().
    }).

    self:public("hideCursor", {
        //print "teehee".
        //wait 2.
        self:textLabel:setText(" ":padRight(standardCursor:length) + self:originalText).
    }).
    
    self:public("setSelected", {
        parameter isSelected.
        set self:selected to isSelected.
        self:updateLabelText(self:originalText).
    }).

    self:public("hAlign", {
        parameter alignmentIn.
        self:textLabel:hAlign(alignmentIn).
    }).

    self:public("vAlign", {
        parameter alignmentIn.
        self:textLabel:vAlign(alignmentIn).
    }).
    
    return defineObject(self).
}

