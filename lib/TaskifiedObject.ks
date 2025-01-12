// TaskifiedObject
// Author: Eddie Kerman 
// Version: 1.1
//
// A class wrapper that automatically converts methods into scheduled tasks.
// Extends the KOSY Object System to provide seamless task creation and management.
//
//
// Usage:
// 1. Extend TaskifiedObject instead of Object:
//    function MyClass {
//        local self is TaskifiedObject():extend.
//
// 2. Define methods normally - they'll be automatically taskified:
//    self:public("myMethod", {
//        parameter input.
//        // Method body
//    }).
//
// 3. Use for-loop style tasks:
//    self:for(
//        { parameter s. return s:i < 10. },    // Condition
//        { parameter s. print s:i. },          // Work
//        { parameter s. set s:i to s:i + 1. }, // Increment (optional)
//        0                                     // Delay between iterations in seconds (optional)
//    ).
//
// 4. Use while-loop style tasks:
//    self:while(
//        { parameter s. return s:val < 5. },   // Condition
//        { parameter s. print s:val. },        // Work
//        0                                     // Delay in seconds (optional)
//    ).
//
// 5. Using Callbacks for Task Communication:
//    Due to the asynchronous nature of tasks you must 
//    use a function callback if you need a loop to return a value.
//
//    GOOD Example:
//    local function checkInputFunc {
//        parameter callback.
//        self:while(
//            { parameter s. return true. },
//            { parameter s.
//                if someCondition {
//                    callback(result).  // Proper way to communicate
//                }
//            }
//        ).
//    }.
//
//    This works too, but can be buggy because you dont know exactly when lastResut is set:
//    local lastResult is 0.  
//    local function checkInputFunc {
//        self:while(
//            { parameter s. return true. },
//            { parameter s.
//                if someCondition {
//                    set lastResult to result. 
//                }
//            }
//        ).
//    }.
//
// Parameters:
// - condition: Delegate that returns boolean, determines if task continues
// - func: Delegate containing the work to be performed each iteration
// - increment: (Optional) Delegate for incrementing loop variables
// - delay: (Optional) Time in seconds to wait between iterations
//
// Notes:
// - Requires a global 'scheduler' (TaskScheduler instance) to be available
// - All taskified methods and loops are automatically added to the scheduler
// - Tasks run once by default for regular methods
// - For-loops and While-loops run based on their conditions
// - Tasks maintain their own state in lexicons
// - Use callbacks to communicate between tasks and outer scope
// - Taskified while-loops are just taskified for-loops without increment step
//
// Dependencies:
// - TaskScheduler.ks: Task scheduling system
// - KObject.ks: KOSY Object System base
// - Task.ks: Task definition system



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
