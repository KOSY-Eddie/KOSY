runOncePath("/KOSY/lib/taskifiedobject.ks").

function Text {
    parameter xIn, yIn, textIn.
    local self is TaskifiedObject():extend.
    
    self:protected("posX", xIn). 
    self:protected("posX", yIn).
    self:protected("text", textIn).
    
    
    return defineObject(self).
}