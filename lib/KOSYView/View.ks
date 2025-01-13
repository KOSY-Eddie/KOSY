runOncePath("/KOSY/lib/TaskifiedObject.ks").

function View {
    parameter initWidth is 0, initHeight is 0.
    local self is Object():extend.
    self:setClassName("View").
    
    // Basic properties
    self:protected("position", lex("x", 0, "y", 0)).
    local position is lex("x",0,"y",0).
    local dimensions is lex("width", initWidth, "height", initHeight).
    self:protected("visible", true).
    self:public("parent", null).
    self:protected("dirty", true).
    

    self:public("getWidth",{return dimensions:width.}).
    self:public("getHeight",{return dimensions:height.}).

    self:public("setWidth",{parameter w. set dimensions:width to w.}).
    self:public("setHeight",{parameter h. set dimensions:height to h.}).
    
    self:public("isDirty",{return self:dirty.}).
    // Position management
    self:public("setPosition", {
        parameter x, y.
        set position:x to x.
        set position:y to y.
        set self:dirty to true.
    }).

    self:public("getPosition",{return position.}).
    
    // Visibility
    self:public("show", {
        set self:visible to true.
        set self:dirty to true.
    }).
    
    self:public("hide", {
        set self:visible to false.
        set self:dirty to true.
    }).
    
    // Drawing
    self:public("draw", {
        if not self:visible { return. }
        if not self:dirty { return. }
        
        // Actual drawing implementation will be in child classes
        set self:dirty to false.
    }).
    
    return defineObject(self).
}