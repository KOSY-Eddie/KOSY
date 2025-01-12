// Task Library
// Author: Eddie Kerman
// Version: 1.0
//
// A task representation that mimics C-style for loop structure:
// for (initialState; conditionFunc; incrementFunc) {
//     workFunc;
// }
//
// Features:
// - State-based execution
// - Conditional looping
// - Runtime tracking for priority scheduling
// - Automatic rescheduling
//
// Parameters:
// initialState: Lexicon
//     Initial state variables for the task
//
// conditionFunc: Delegate
//     Function that determines if task should continue
//     parameter s: The current state
//     returns: Boolean indicating whether to continue
//
// incrementFunc: Delegate
//     Function called after work to update state
//     parameter s: The current state
//
// workFunc: Delegate
//     The actual work to be performed
//     parameter s: The current state
//
// Usage Example:
// local countTask is Task(
//     // Initial state
//     lex("count", 0),
//     // Condition
//     { parameter s. return s:count < 5. },
//     // Increment
//     { parameter s. set s:count to s:count + 1. },
//     // Work
//     { parameter s. print "Count: " + s:count. }
// ):new.
//
// Notes:
// - Tasks track their runtime for priority scheduling
// - Tasks automatically reschedule if condition remains true
// - All functions receive the current state as parameter
// - State is preserved between iterations

runOncePath("/KOSY/lib/TaskScheduler.ks").

function Task {
    parameter taskParamsIn.
    
    local self is Object():extend.
    self:setClassName("Task").

    local taskParams is taskParamsIn.
    self:public("taskId", scheduler:newTaskID()).
    local totalRuntime is 0.
    self:public("value", 0).
    
    // Cache these at creation
    local hasValidCondition is taskParams:condition:isType("UserDelegate").
    local hasValidWork is taskParams:work:isType("UserDelegate").
    local hasValidIncrement is taskParams:hasKey("increment") and taskParams:increment:isType("UserDelegate").
    local hasDelay is taskParams:hasKey("delay").
    local delayValue is choose taskParams:delay if hasDelay else 0.
    local useRuntime is not hasDelay or delayValue >= 0.
    
    self:public("execute", {
        parameter scheduler.
        local startTime is time:seconds.
        
        // Single condition check for work
        if (not hasValidCondition or taskParams:condition()) and hasValidWork {
            taskParams:work().
        }
        
        // Update value
        if useRuntime {
            set totalRuntime to totalRuntime + (time:seconds - startTime).
            set self:value to totalRuntime.
        }
        
        // Handle increment if it exists
        if hasValidIncrement {
            taskParams:increment().
        }
        
        // Simplified rescheduling
        if hasValidCondition and taskParams:condition() {
            if hasDelay and delayValue >= 0 {
                scheduler:addDelayedTask(self:new, delayValue).
            } else {
                scheduler:addTask(self:new).
            }
        }
    }).
    
    self:public("compare", {
        parameter other.
        if self:value = other:value:get()
           return self:taskId - other:taskId:get().
        return self:value - other:value:get().
    }).
    
    return defineObject(self).
}
