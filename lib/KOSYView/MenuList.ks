runOncePath("/KOSY/lib/KOSYView/ContainerView").

function MenuList {
    local self is VContainerView():extend.
    self:setClassName("MenuList").
    
    // Track focus and selected item
    local hasFocus is false.
    local selectedIndex is 0.
    
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
            inputhandler:unregisterCallback(self:handleInput@).
        }
    }).
    
    self:public("hasFocus", {
        return hasFocus.
    }).
    
    self:public("handleInput", {
        parameter key.

        if key = "up" {
            if selectedIndex > 0 {
                self:getChildren()[selectedIndex]:setSelected(false).
                set selectedIndex to selectedIndex - 1.
                self:getChildren()[selectedIndex]:setSelected(true).
            }
        } else if key = "down" {
            if selectedIndex < self:getChildren():length - 1 {
                self:getChildren()[selectedIndex]:setSelected(false).
                set selectedIndex to selectedIndex + 1.
                self:getChildren()[selectedIndex]:setSelected(true).
            }
        } else if key = "confirm" {
            if selectedIndex >= 0 and selectedIndex < self:getChildren():length {
                self:getChildren()[selectedIndex]:triggerSelect().
            }
        }
    }).

    return defineObject(self).
}
