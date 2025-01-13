// KOSY Task System
// Author: Eddie Kerman
// Version: 1.1
//
// Represents a schedulable unit of work with optional repetition and delay.
// Tasks can be one-shot or recurring, with priority based on runtime.
//
// Task Creation:
// Tasks are created with a parameter lexicon containing:
// - work: Delegate       // Required: The work to perform
// - condition: Delegate  // Optional: Return true to continue task
// - increment: Delegate  // Optional: Called after work
// - delay: Scalar       // Optional: Time between executions
//                       // Negative delay gives constant priority (experimental!)
//
// Usage Examples:
// 1. One-shot task:
//    local simpleTask is Task(lex(
//        "work", { print "Hello!". }
//    )):new.
//
// 2. Recurring task with delay:
//    local timedTask is Task(lex(
//        "condition", { return true. },
//        "work", { print "Tick". },
//        "delay", 1  // Every second
//    )):new.
//
// 3. Cooperative loop task:
//    // Instead of hogging CPU with a direct loop,
//    // spread work across task schedule:
//    local loopTask is Task(lex(
//        "condition", { return count < 1000. },
//        "work", { 
//            // Do some work
//            set count to count + 1.
//        }
//    )):new.
//
// Priority System:
// - Tasks track total runtime for priority
// - Lower runtime gets higher priority
// - Same-runtime tasks ordered by taskId
// - Negative delay for constant priority (use with caution!)
//
// Notes:
// - Tasks auto-reschedule if condition returns true
// - Delayed tasks wait in DelayedTaskQueue
//
// Dependencies:
// - KObject.ks
// - TaskScheduler.ks


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
    local hasValidCondition is taskParams:hasKey("condition") and taskParams:condition:isType("UserDelegate").
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
