runOncePath("/KOSY/lib/taskifiedobject.ks").

function Header {
    local self is TaskifiedObject():extend.
    
    self:public("title", "KOSY").
    self:public("text", "").
    
    // Format time as HH:MM:SS
    local function formatTime {
        parameter seconds.
        local hours is floor(seconds / 3600).
        local minutes is floor((seconds - (hours * 3600)) / 60).
        local secs is floor(seconds - (hours * 3600) - (minutes * 60)).
        
        return padding(hours) + ":" + padding(minutes) + ":" + padding(secs).
    }.

    
    // Add leading zero if needed
    local function padding{
        parameter num.
        if num < 10 {
            return "0" + num.
        }
        return num:tostring.
    }.
    self:protected("startClock",{
        self:while({return not systemVars:shutdown.},
            {local spacing is terminal:width - self:title:length - time:FULL:length - 1.
            print self:title + "":padleft(spacing) + time:FULL at (0,0).
            //self:draw().
            },
            1
        ).
    }).

    self:startClock().
    
    return defineObject(self).
}