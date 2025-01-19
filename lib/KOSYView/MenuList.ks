runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/utils").

function MenuList {
    parameter isHorizontal is false.
    local self is null.
    if isHorizontal
        set self to HContainerView():extend.
    else
        set self to VContainerView():extend.

    self:setClassName("MenuList").
    self:setFocus(true).
    
    // Track focus and selected item
    local selectedIndex is 0.
    local alignment is "left".


    self:public("hAlign",{
        parameter hAlignment.
        set alignment to hAlignment.
        for child in self:getChildren()
            child:hAlign(hAlignment).
    }).

    local super_addChild is self:addChild.
    self:public("addChild",{
        parameter child.
        child:hAlign(alignment).
        super_addChild(child).
    }).

    local parentSelfFocus is self:setFocus.
    self:public("setFocus", {
        parameter focused.
                
        if focused {
            // Only set cursor position if nothing is currently selected
            // This preserves cursor position when returning from submenus
            if selectedIndex = 0 and self:getChildren():length > 0 {
                self:getChildren()[0]:setSelected(true).
            }
        }

        parentSelfFocus(focused).
    }).


    self:public("createOptionMenu", {
        parameter configIn.  // lex with text, options
        if not (configIn:haskey("text") and configIn:haskey("options")) {
            return 0.
        }
        
        local menuItem is MenuItem():new.
        menuItem:setText(configIn:text).
        menuItem:vAlign("top").
        menuItem:expandY:set(false).
        
        local submenu is MenuList():new.
        
        // Create all menu items first so they can be referenced
        local optionItems is lex().
        for option in configIn:options {
            if not option:haskey("id") {
                print "Option must have id".
                continue.
            }
            local optionItem is MenuItem():new.
            optionItem:setText(option:text).
            optionItem:hAlign("left").
            optionItem:expandY:set(false).
            optionItems:add(option:id, optionItem).
        }
        
        // Now set up the onSelect handlers with access to all items
        for option in configIn:options {
            optionItems[option:id]:setOnSelect(option:onSelect(optionItems)).
            submenu:addChild(optionItems[option:id]).
        }
        
        menuItem:addSubmenu(submenu).
        return menuItem.
    }).


    
    self:public("handleInput", {
        parameter key.
        
        local prevSelectKey is choose "left" if isHorizontal else "up".
        local nextSelectKey is choose "right" if isHorizontal else "down".
        local backKey is choose "up" if isHorizontal else "left".
        local nextKey is choose "down" if isHorizontal else "right".

        if key = prevSelectKey {
            if selectedIndex > 0 {
                self:getChildren()[selectedIndex]:setSelected(false).
                set selectedIndex to selectedIndex - 1.
                self:getChildren()[selectedIndex]:setSelected(true).
            }
        } else if key = nextSelectKey {
            if selectedIndex < self:getChildren():length - 1 {
                self:getChildren()[selectedIndex]:setSelected(false).
                set selectedIndex to selectedIndex + 1.
                self:getChildren()[selectedIndex]:setSelected(true).
            }
        } else if key = "confirm" {
            if selectedIndex >= 0 and selectedIndex < self:getChildren():length {
                self:getChildren()[selectedIndex]:triggerSelect().
            }
        } else if key = "unfocus" {
            self:setFocus(false).
        } else if key = backKey {
            self:backCallback().
        } else if key = nextKey {
            self:nextCallback().
        } else if key = "cancel"{
            self:backCallback().
        }
    }).
    


    return defineObject(self).
}
