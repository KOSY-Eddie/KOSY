runOncePath("/KOSY/lib/TaskifiedObject.ks").

function View {
    local self is Object():extend.
    self:setClassName("View").
    
    // Basic properties
    self:public("parent", null).
    self:protected("spacing", 0).

    self:protected("expandX", true).
    self:protected("expandY", true).
    
    // Add setters for expand flags
    self:public("setExpandX", {
        parameter expand.
        set self:expandX to expand.
        self:drawAll().
    }).
    
    self:public("setExpandY", {
        parameter expand.
        set self:expandY to expand.
        self:drawAll().
    }).

    self:public("getExpandX",{return self:expandX.}).
    self:public("getExpandY",{return self:expandY.}).
    
    self:public("setSpacing", {
        parameter val.
        set self:spacing to val.
    }).

    self:public("getContentSize", {
        parameter isWidthDim. 
        return 0.
    }).

    self:public("getContentWidth",{return self:getContentSize(true).}).
    self:public("getContentHeight",{return self:getContentSize(false).}).

    // Drawing
    self:public("draw", {
        parameter boundsIn. // lex("x", x, "y", y, "width", w, "height", h)
         
        // Component does its work (drawing) with provided bounds
        set self:dirty to false.
        return true.
    }).

    self:public("getRoot", {
        if isNull(self:parent) {
            return self:new.  // If no parent, this is the root
        } else {
            return self:parent:getRoot().  // Recursively find the root
        }
    }).

    self:public("drawAll",{
        screenBuffer:clearBuffer().
        self:getRoot():draw(lex("x", 0, "y", 0, "width", screenBuffer:getWidth(), "height", screenBuffer:getHeight())).
    }).

    
    
    return defineObject(self).
}