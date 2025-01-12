
function FileWriter {
    local self is BaseObject():extend.
    self:setClassName("FileWriter").
    
    local fwQueue is Queue().
    local watchdog is 0.

    self:public("start", {
        local taskParams is lex(
            "condition", { return true. },
            "work", {
                if not fwQueue:empty {
                    local writeData is fwQueue:pop().
                    log writeData:message to writeData:filePath.
                }
            },
            "increment", {}
        ).
        set watchdog to Task(taskParams):new.
        scheduler:addTask(watchdog).
    }).

    self:public("queueWrite", {
        parameter filePath, message.
        //print "Queuing write to: " + filePath.  // Debug
        fwQueue:push(lex(
            "filePath", filePath,
            "message", message
        )).
    }).
    
    return defineObject(self).
}


global fWriter is FileWriter():new.
