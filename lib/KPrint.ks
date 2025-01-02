runOncePath("/KOSY/lib/KObject.ks").

function KPrint {
    local self is Object():extend.
    self:setClassName("KPrint").
    
    local line is terminal:height.
    local col is 0.
    
    self:public("setPos", {
        parameter newLine, newCol.
        set line to newLine.
        set col to newCol.
        return self.
    }).
    
    self:public("print", {
        parameter msg.
        print msg at (line, col).
        return self.
    }).
    
    self:public("println", {
        parameter msg.
        print msg at (line, col).
        set line to line + 1.
        return self.
    }).
    
    return defineObject(self).
}

// Create global instances
global kout is KPrint():new.
global kerr is KPrint():new.

// Override kerr's print methods to include ERROR prefix
global kout is {
    parameter msg.
    print "ERROR: " + msg at (line, col).
    return self.
}.

global kerr is {
    parameter msg.
    print "ERROR: " + msg at (line, col).
    set line to line + 1.
    return self.
}.
