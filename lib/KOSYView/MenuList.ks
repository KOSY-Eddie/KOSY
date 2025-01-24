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

    local super_setInput is self:setInput.
    self:public("setInput", {
        parameter hasInputIN.
        super_setInput(hasInputIN).
                
        if self:getChildren():length > 0 {
            local child is self:getChildren()[selectedIndex].
            child:setSelected(hasInputIN).
        }

    }).

    self:public("getSelectedMenuItem",{
        return self:getChildren()[selectedIndex].
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
                self:getChildren()[selectedIndex]:triggerAction().
            }
        } else if key = "unfocus" {
            self:setInput(false).
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
