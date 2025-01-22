// KOSY Taskified Object System
// Author: Eddie Kerman 
// Version: 1.1
//
// Extends the KOSY Object System to automatically convert methods into scheduled tasks.
// Provides a framework for cooperative multitasking through task-based loops.
//
// Usage:
// 1. Extend TaskifiedObject instead of Object:
//    function MyClass {
//        local self is TaskifiedObject():extend.
//
// 2. Methods automatically become scheduled tasks:
//    self:public("myMethod", {
//        parameter input.
//        // Method body
//    }).
//
// 3. Create cooperative loops that play nice with scheduler:
//    self:for(
//        { parameter s. return s:i < 10. },    // Continue condition
//        { parameter s. print s:i. },          // Work to perform
//        { parameter s. set s:i to s:i + 1. }, // Increment (optional)
//        0                                     // Delay between iterations (optional)
//    ).
//
//    self:while(
//        { parameter s. return s:val < 5. },   // Continue condition
//        { parameter s. print s:val. },        // Work to perform
//        0                                     // Delay (optional)
//    ).
//
// Task Communication:
// Due to asynchronous execution, use callbacks for task communication:
//
// RECOMMENDED:
// local function processInput {
//     parameter callback.
//     self:while(
//         { return true. },
//         { 
//             if haveInput {
//                 callback(input).  // Safe communication
//             }
//         }
//     ).
// }.
//
// NOT RECOMMENDED:
// local result is 0.  
// self:while(
//     { return true. },
//     { 
//         if haveInput {
//             set result to input.  // Race condition risk
//         }
//     }
// ).
//
// Parameters:
// - condition: Delegate returning boolean to continue task
// - func: Delegate containing work to perform
// - increment: Optional delegate for loop variable updates
// - delay: Optional seconds between iterations
//
// Notes:
// - Requires global 'scheduler' (TaskScheduler instance)
// - All public methods automatically become scheduled tasks
//
// Dependencies:
// - KObject.ks: Base object system
// - Task.ks: Task definition
// - Utils.ks: Utility functions

runOncePath("/KOSY/lib/KObject").
runOncePath("/KOSY/lib/Task").
runOncePath("/KOSY/lib/Utils").

function TaskifiedObject {
    local self is Object():extend.
    self:setClassName("TaskifiedObject").
    
    local parent_public is self:public.
    local emptyTaskLex is lex("condition",0,"increment",0,"work",0,"result",0).

    set self:for to {
        parameter condition, increment, func is 0, delay is 0.
        local taskParams is emptyTaskLex:copy().
        set taskParams:condition to condition@.
        set taskParams:work to func@.
        if increment:istype("userDelegate")
            set taskParams:increment to increment@.

        set taskParams["delay"] to delay.
        set taskParams["name"] to self:getClassName().

        scheduler:addTask(Task(taskParams):new).
    }.
    
    set self:while to {
        parameter condition, func, delay is 0.
        self:for(condition,0, func, delay).
    }.
    
    set self:publicS to parent_public.

    set self:public to {
        parameter name, maybeFunc, taskParams is emptyTaskLex:copy().
        
        if maybeFunc:istype("delegate") {
            local taskifiedMethod is {
                // Collect parameters directly like in DebugObject
                local params is list().
                local isDone is false.
                
                until isDone {
                    parameter arg is NULL.
                    if isNull(arg) {
                        set isDone to true.
                    } else {
                        params:add(arg).
                    }
                }

                // Bind parameters
                local boundFunc is maybeFunc.
                for param in params {
                    set boundFunc to boundFunc:bind(param).
                }
                
                set taskParams:work to boundFunc.
                set taskParams:name to "Taskified Func" + self:getClassName + "." + name.
                local taskifiedFunc is Task(taskParams):new.
                scheduler:addTask(taskifiedFunc).
            }.
            
            parent_public(name, taskifiedMethod).
        } else {
            parent_public(name, maybeFunc).
        }
    }.
        
    return defineObject(self).
}
