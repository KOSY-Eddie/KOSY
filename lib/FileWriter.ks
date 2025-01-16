// KOSY File Writer
// Author: Eddie Kerman
// Version: 1.0
//
// Asynchronous file writing system that manages file I/O operations
// through a task-based queue to minimize program lag from file operations.
//
// Purpose:
// File I/O in KOS is slow and blocking. FileWriter distributes these
// operations across scheduled tasks to spread out the performance impact,
// making the overall program more responsive.
//
// Usage:
// 1. Create a global instance:
//    global fWriter is FileWriter():new.
//
// 2. Start the writer:
//    fWriter:start().  // Begins processing the write queue
//
// 3. Queue write operations:
//    // Append to existing file or create new file:
//    fWriter:queueWrite("/path/to/file.txt", "Some content").
//    
//    // Create new file or overwrite existing file:
//    fWriter:queueWrite("/path/to/file.txt", "New content", true).
//
// Operation:
// - Write requests are queued internally
// - A watchdog task processes the queue every 0.5 seconds
// - Files are created automatically if they don't exist
// - Writes happen in queue order (FIFO)
//
// Notes:
// - File operations are not immediate
// - Writes may take several seconds to complete
// - Queue processing continues as long as program runs
//
// Dependencies:
// - BaseObject (Direct usage)
// - Task.ks

runoncepath("/KOSY/lib/kobject").
runoncepath("/KOSY/lib/task").

function FileWriter {
    local self is BaseObject():extend.
    self:setClassName("FileWriter").
    
    sysEvents:subscribe("fileWriteRequested", {
        parameter writeData.
        local taskParams is lex(
            "work", {
                if writeData:overwrite and exists(writeData:filePath) {
                    deletepath(writeData:filePath).
                }
                if writeData:isJson {
                    writeJSON(writeData:message, writeData:filePath).
                } else {
                    log writeData:message to writeData:filePath.
                }
            }
        ).
        scheduler:addTask(Task(taskParams):new).
    },self:getClassName()).
        
        // Subscribe to config changes
    sysEvents:subscribe("systemConfigChanged", {
        parameter configIn.
        sysEvents:emit("fileWriteRequested", lex(
            "filePath", path(sysVars:sysConfigPath):combine("system.json"),
            "message", configIn,
            "overwrite", true,
            "isJson", true
        ), self:getClassName()).
    }, self:getClassName()).
    

    
    return defineObject(self).
}
