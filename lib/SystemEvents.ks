runOncePath("/KOSY/lib/TaskifiedObject").

function SystemEvents {
    local self is TaskifiedObject():extend.
    self:setClassName("SystemEvents").
    
    local subscribers is lexicon().
    local logPath is path(sysVars:logDir):combine("system_events.log").
    
    // Helper function for logging
    local function writeLog {
        parameter message.
        log "Time " + time:seconds + ": " + message to logPath.
    }.
    
    self:publicS("subscribe", {
        parameter eventName, callback, subscriberName is "Unknown".
        if not subscribers:haskey(eventName) {
            subscribers:add(eventName, list()).
        }
        subscribers[eventName]:add(callback).
        writeLog("Subscriber '" + subscriberName + "' subscribed to event: " + eventName).
    }).
    
    self:public("emit", {
        parameter eventName, data, emitterName is "Unknown".
        writeLog("Emitter '" + emitterName + "' emitted event: " + eventName).
        if subscribers:haskey(eventName) {
            for callback in subscribers[eventName] {
                callback(data).
            }
        }
    }).

    self:public("unsubscribe", {
        parameter eventName, callback, subscriberName is "Unknown".
        if subscribers:haskey(eventName) {
            local idx is subscribers[eventName]:find(callback).
            if idx >= 0 {
                subscribers[eventName]:remove(idx).
                writeLog("Subscriber '" + subscriberName + "' unsubscribed from event: " + eventName).
            }
        }
    }).
    
    return defineObject(self).
}
