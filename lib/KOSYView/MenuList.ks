runOncePath("/KOSY/lib/KOSYView/ContainerView").

function MenuList {
    parameter isHorizontal is false.
    local self is null.
    if isHorizontal
        set self to HContainerView():extend.
    else
        set self to VContainerView():extend.

    self:setClassName("MenuList").
    
    // Track focus and selected item
    local hasFocus is false.
    local selectedIndex is 0.
    local alignment is "left".
    
    // Callback storage
    local backCallback is { }.    // Default empty callback
    local nextCallback is { }.    // Default empty callback

    // Callback setters
    self:public("setBackCallback", {
        parameter callback.
        set backCallback to callback.
    }).

    self:public("setNextCallback", {
        parameter callback.
        set nextCallback to callback.
    }).

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
    
    // Focus management
    self:public("setFocus", {
        parameter focused.
        set hasFocus to focused.
        
        if hasFocus {
            // Register for input events
            inputhandler:registerCallback(self:handleInput@).
            
            // Select first item if nothing selected
            if selectedIndex = 0 and self:getChildren():length > 0 {
                self:getChildren()[0]:setSelected(true).
            }
        } else {
            // Unregister when losing focus
            inputhandler:unregisterCallback().
        }
    }).
    
    self:public("hasFocus", {
        return hasFocus.
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
            backCallback().
        } else if key = nextKey {
            nextCallback().
        } else if key = "cancel"{
            appMenu:setFocus(true).
        }
    }).


    return defineObject(self).
}
