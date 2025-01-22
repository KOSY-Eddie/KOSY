runOncePath("/KOSY/lib/KOSYView/ContainerView").

function MenuItem {
    local self is VContainerView():extend.
    self:setClassName("MenuItem").
    
    self:protected("selected", false).
    local standardCursor is "> ".
    local submenuCursor is "v ".
    local submenuExpanded is false.
    self:protected("action", { }).
    local currentCursor is standardCursor.
    self:protected("originalText", "").
    local submenu is null.
    
    self:protected("textLabel", TextView():new).
    self:addChild(self:textLabel).
    
    self:protected("determineCursor", {
        parameter textIn is self:originalText.
        local showCursor is self:selected and (not isNull(self:parent) and self:parent:getInputStatus()).


        if showCursor {
            if subMenuExpanded
                self:textLabel:setText(submenuCursor + textIn).
            else
                self:textLabel:setText(currentCursor + textIn).
        } else {
            self:textLabel:setText("":padRight(standardCursor:length) + textIn).
        }
    

        // if self:originalText:contains("Task"){
        //     clearscreen.
        //     print self:getText().
        //     print "selected: " +self:selected.
        //     print "not parentIsNull: " + not isNull(self:parent).
        //     print "parentInput: " + (choose "parent is null" if isNull(self:parent) else self:parent:getInputStatus()).
        //     wait 1.
        // }
    }).

    local super_draw is self:draw.
    self:public("draw",{
        parameter boundsIn.
        self:determineCursor().
        super_draw(boundsIn).
    }).
    local super_addChild is self:addChild.
    self:public("addChild",{
        parameter childIn.
        set submenu to childIn.
        set self:action to {
            super_addChild(submenu).
            submenu:setInput(true).
            self:drawAll().
        }.
        childIn:setBackCallBack({
            set currentCursor to standardCursor.
            self:parent:setInput(true).
            self:removeChild(submenu).
            self:drawAll().
        }).
    }).


    self:public("setAction", {
        parameter actionIn.
        set self:action to actionIn.
    }).

    self:public("getText", { 
        return self:textLabel:getText().
    }).

    self:public("setText", {
        parameter textIn.
        set self:originalText to textIn.
        self:determineCursor().
    }).
    
    self:public("triggerAction", {
        if not isNull(submenu) {
            set currentCursor to  submenuCursor.
            //self:addChild(submenu).
            //self:drawAll().

        } 
        self:action().
    }).
    
    self:public("setSelected", {
        parameter isSelected.
        set self:selected to isSelected.
        self:determineCursor().
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

