runoncepath("/KOSY/lib/kobject").
runoncepath("/KOSY/lib/task").
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
                    if writeData:overwrite and exists(writeData:filePath) {
                        deletepath(writeData:filePath).
                    }
                    log writeData:message to writeData:filePath.
                }
            },
            "delay", .5
        ).
        set watchdog to Task(taskParams):new.
        scheduler:addTask(watchdog).
    }).

    self:public("queueWrite", {
        parameter filePath, message, overwrite is false.
        fwQueue:push(lex(
            "filePath", filePath,
            "message", message,
            "overwrite", overwrite
        )).
    }).

    return defineObject(self).
}
