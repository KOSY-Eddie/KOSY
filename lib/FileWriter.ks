// KOSY File Writer
// Author: Eddie Kerman
// Version: 1.0
//
// Asynchronous file writing system that manages file I/O operations
// through tasks to minimize program lag from file operations.
//
// Purpose:
// File I/O slow and blocking. FileWriter creates individual
// tasks for write operations to spread out the performance impact,
// making the overall program more responsive.
//
// Usage:
// 1. Access the global instance:
//    global fwriter should be available system-wide.
//
// 2. Write operations:
//    // Basic write:
//    fwriter:write(lex(
//        "filePath", "/path/to/file.txt",
//        "message", "content"
//    )).
//    
//    // Write with options:
//    fwriter:write(lex(
//        "filePath", "/path/to/file.txt",
//        "message", "content",
//        "overwrite", true,    // Optional: overwrite existing file
//        "isJson", true        // Optional: write as JSON
//    )).
//
//    // Write system config:
//    fwriter:writeConfig(configObject).
//
// Operation:
// - Each write operation creates a new task
// - Tasks are processed by the scheduler
// - Files are created automatically if they don't exist
// - Writes are processed in order of task creation
//
// Notes:
// - Using this means file operations are not immediate. If that is a concern 
//   then consider using some other form of storage since file I/O is inherently slow.
// Dependencies:
// - BaseObject.ks
// - Task.ks


runoncepath("/KOSY/lib/kobject").
runoncepath("/KOSY/lib/task").

function FileWriter {
    local self is BaseObject():extend.
    self:setClassName("FileWriter").
    
    self:public("write", {
        parameter writeData.
        if not (writeData:haskey("filePath") and writeData:haskey("message")) {
            //print "Error: Write data must include filePath and message".
            return.
        }
        
        local taskParams is lex("name", "File Write",
            "work", {
                if writeData:haskey("overwrite") and writeData:overwrite and exists(writeData:filePath) {
                    deletepath(writeData:filePath).
                }
                if writeData:haskey("isJson") and writeData:isJson {
                    writeJSON(writeData:message, writeData:filePath).
                } else {
                    log writeData:message to writeData:filePath.
                }
            }
        ).
        scheduler:addTask(Task(taskParams):new).
    }).
    
    // Listen for config changes
    sysEvents:subscribe("configChangeRequested", {
        parameter configIn.
        
        self:write(lex(
            "filePath", path(sysVars:sysConfigPath):combine("system.json"),
            "message", configIn,
            "overwrite", true,
            "isJson", true
        )).
    }, self:getClassName()).
    
    return defineObject(self).
}
