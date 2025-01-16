runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").

function Application {
    local self is TaskifiedObject():extend.

    self:protected("mainView", null).

    set self:mainView to VContainerView():new.
    local textView_ is TextView():new.
    textView_:settext(self:getClassName()).
    self:mainView:addChild(textView_).

    self:public("launch",{
        parameter callback.
        callback(lex("title", self:getClassName(), "mainView", self:mainView)).
    }).

    self:public("switchToView", {
        parameter newView.
        parameter parentView is null.

        // Clean current view
        self:mainView:clean().
        
        // Set parent menu if applicable
        if newView:hasKey("setParentMenu") {
            newView:setParentMenu(parentView).
        }
        
        // Add new view and set focus
        self:mainView:addChild(newView).
        newView:setFocus(true).
        
        // Redraw the main view
        self:mainView:drawAll().
    }).

    
    return defineObject(self).
}