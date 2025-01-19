runOncePath("/KOSY/lib/TaskifiedObject.ks").

function View {
    local self is Object():extend.
    self:setClassName("View").
    
    self:protected("isFocused", false).
    self:protected("backcallBack", {appMenu:setFocus(true).}).
    self:protected("nextCallBack", {}).
    self:public("spacing", 0).
    self:public("parent", null).
    self:public("expandX", true).
    self:public("expandY", true).
    self:public("manualWidth", -1).    // -1 indicates not set
    self:public("manualHeight", -1).   // -1 indicates not set
    self:public("navigationNode",null).

    self:public("setBackCallback", {
        parameter callback.
        set self:backCallback to callback.
    }).

    self:public("setNextCallback", {
        parameter callback.
        set self:nextCallback to callback.
    }).

    self:public("resetManualSize", {
        set self:manualWidth to -1.
        set self:manualHeight to -1.
    }).

    //virtual method meant to be overriden
    self:public("getContentSize", {}).

    self:public("getContentWidth",{return self:getContentSize(true).}).
    self:public("getContentHeight",{return self:getContentSize(false).}).

    // Drawing
    self:public("draw", {
        parameter boundsIn. // lex("x", x, "y", y, "width", w, "height", h)
         
        // Component does its work (drawing) with provided bounds
        return true.
    }).

    self:public("getRoot", {
        if isNull(self:parent) {
            return self:new.
        } else {
            return self:parent:getRoot().  
        }
    }).

    self:public("drawAll",{
        screenBuffer:clearBuffer().
        self:getRoot():draw(lex("x", 0, "y", 0, "width", screenBuffer:getWidth(), "height", screenBuffer:getHeight())).
    }).   

    self:public("setParentView", {
        parameter parentView.
        self:setBackCallback({
            local parentContainer is self:parent.
            parentContainer:switchContent(parentView). 
        }).
    }).

    // Focus management
    self:public("setFocus", {
        parameter focused.
        set self:isFocused to focused.
        
        if self:isFocused {
            // Register for input events
            inputhandler:registerCallback(self:handleInput@).
            
        } else {
            // Unregister when losing focus
            inputhandler:unregisterCallback().
        }

    }).
    
    self:public("hasFocus", {
        return self:isFocused.
    }).
    
    self:public("handleInput", {
        parameter key.

        if key = "unfocus" {
            self:setFocus(false).
        } else if key = "left" {
            self:backCallback().
        } else if key = "right" {
            self:nextCallback().
        } else if key = "cancel"{
            self:backCallback().
        }
    }).
    
    return defineObject(self).
}