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
    
    local totalRuntime is 0.
    self:public("value", 0).
    
    self:public("execute", {
        parameter scheduler.
        //condition
        //work
        //increment
        //condition

        local startTime is time:seconds.
        if not taskParams:condition:isType("UserDelegate") or taskParams:condition(){
            if taskParams:work:isType("UserDelegate")
                taskParams:work().
        }
        set totalRuntime to totalRuntime + (time:seconds - startTime).
        set self:value to totalRuntime. //for the heap
        
        if taskParams:increment:isType("UserDelegate")
            taskParams:increment().
        
        if taskParams:condition:isType("UserDelegate") and taskParams:condition(){
            
            // Schedule next iteration
            if taskParams:hasKey("delay"){
                scheduler:addDelayedTask(self:new, taskParams:delay).}
            else
                scheduler:addTask(self:new).
        }
    }).
    //comparison function for heap operations
    self:public("compare", {
        parameter other.
        return self:value - other:value:get().
    }).
    
    return defineObject(self).
}