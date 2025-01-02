runOncePath("/KOSY/lib/TaskifiedObject.ks").
runOncePath("/KOSY/lib/TaskScheduler.ks").

function Footer {
    local self is TaskifiedObject():extend.
    
    local kosyVer is "KOSY v1.0".
    local printableArea is terminal:width - kosyVer:length.
    local errorMsg is "".
    //self:public("text", "").
    
    // Get formatted line content
    self:protected("draw", {
        local spacing is printableArea - errorMsg:length - 1.
        //set self:text to errorMsg + " ":padright(spacing) + kosyVer.
        print errorMsg + " ":padright(spacing) + kosyVer at(0,systemVars:areas:footer:lastLine).
       // print self:text at(0,systemVars:footer:lastLine).
    }).
    
    // Set error message
    self:public("setError", {
        parameter message, autoClear is true.
        
        if message:isType("String"){
            if message:length >= printableArea
                set message to message:substring(0,printableArea - 3) + "...".
            
            set errorMsg to message.
            self:draw().
        }
    }).
    
    // Clear error message
    self:public("clearError", {
        set errorMsg to "".
        self:draw().
    }).

    self:draw().
    return defineObject(self).
}