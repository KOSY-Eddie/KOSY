runOncePath("/KOSY/lib/utils").

global views is ViewStack():new.

function view {
    parameter drawableAreaIn.
    local self is TaskifiedObject():extend.
    
    self:protected("drawableArea", drawableAreaIn).
    self:protected("currentSelection", 0).
    self:public("isControllable", false).

    local drawCallback is {}.
    
    local function draw{
        if views:peek():equals(self)
            drawCallback().
    }

    self:protected("setDrawCallback",{
        parameter callback.

        set drawCallBack to callback.
    }).
    
    self:protected("draw", {
        draw().
    }).
    
    self:protected("clearArea", {
        local width is self:drawableArea:lastCol - self:drawableArea:firstCol.
        from { local i is self:drawableArea:firstLine. } until i = self:drawableArea:lastLine step { set i to i + 1. } do {
            print "":padleft(width) at (self:drawableArea:firstCol, i).
        }.
    }).

    self:protected("fitText", {
    parameter text, width is self:drawableArea:lastCol - self:drawableArea:firstCol.
    
        if text:length > width {
            // Leave room for ellipsis
            return text:substring(0, width - 3) + "...".
        }
        return text:padright(width).
    }).

    // Override this method for interactivity
    self:protected("handleInput", {
        parameter input.

        if input = "UP" {
        } else if input = "DOWN" {
        } else if input = "LEFT" {
            self:deactivate().  //this returns to previous views by default. 
                                //If you have no sub views should do same as focusRoot() 
                                //Override for complex menu navigation.
        } else if input = "RIGHT" {
        } else if input = "CANCEL" {
            self:focusRoot(). //try to keep this standard. Cancel to return to menu.
                              //Override may be useful for fullscreen apps though.
        } else if input = "CONFIRM" {
        }.
    }).

    //for returning to menu
    self:protected("focusRoot",{
        local rootView is views:getRoot().
        inputHandler:registerCallback(rootView:handleInput).
        rootView:clearArea().
        rootView:draw().
    }).

    self:protected("isActive",{
        if views:peek():equals(self)
            return true.
        
        return false.
    }).

    //pushes this view on the stack and 
    self:public("activate", {
        //set self:currentSelection to 0.
        views:push(self).
        if self:isControllable
            inputHandler:registerCallback(self:handleInput).
        self:clearArea().
        self:draw().
    }).

    self:public("deactivate", {
        views:pop(). //discard current view
        local nextView is views:pop().
        nextView:activate().
    }).

    
    return defineObject(self).
}.

function ViewStack {
    local self is Object():extend.
    
    local _stack is Stack().
    local rootView is null.
    
    self:public("getRoot", {
        return rootView.
    }).

    self:public("push", {
        parameter viewIn.
        if isNull(rootView)
            set rootView to viewIn.
        _stack:push(viewIn).
    }).

    self:public("pop",{
        local poppedView is _stack:pop.
        if poppedView:equals(rootView)
            _stack:push(poppedView).
        return poppedView.
    }).

    self:public("peek",{
        return _stack:peek.
    }).

    self:public("clear",{
        return _stack:clear.
    }).
    
    return defineObject(self).
}
