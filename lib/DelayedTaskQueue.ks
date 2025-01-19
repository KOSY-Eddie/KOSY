// KOSY Delayed Task Queue
// Author: Eddie Kerman
// Version: 1.0
//
// A priority queue system for scheduling tasks with future execution times.
// Used internally by the Task Scheduler to manage delayed task execution.
//
// Components:
// 1. TaskWrapper:
//    Attaches timing metadata to tasks:
//    - Execution time: When the task should run
//    - Insertion order: Used as a tiebreaker when multiple tasks
//      share the same execution time, ensuring consistent ordering
//    This wrapper allows the queue to sort tasks by time while
//    maintaining predictable execution order for simultaneous tasks.
//
// 2. DelayedTaskQueue:
//    Core queue implementation using a MinHeap for task management.
//    Tracks the next scheduled execution time for optimal task checking.
//    Provides methods for adding delayed tasks and retrieving ready ones.
//
// Internal Operation:
// - Tasks are stored with their intended execution time
// - MinHeap keeps tasks ordered by execution time
// - When tasks share execution times, their original insertion order
//   determines priority, providing consistent, predictable execution
// - Queue tracks next ready time to avoid unnecessary checking
//
// Public Methods:
// - addTask(task, delay): Schedules task for future execution
// - getReadyTasks(): Retrieves all currently executable tasks
// - count(): Returns queue size
// - isReady(): Checks if any tasks are due for execution
//
// Notes:
// - Primarily used by TaskScheduler
// - Empty queue indicated by nextReadyTime = 0
//
// Dependencies:
// - MinHeap.ks
// - KObject.ks


runOncePath("/KOSY/lib/MinHeap.ks").

function TaskWrapper {
    parameter taskToWrap, executionTime, idx.
    local self is Object():extend.
    self:setClassName("TaskWrapper").
    
    self:public("task", taskToWrap).
    self:public("value", executionTime).
    self:public("insertionIdx",idx).
    
    self:public("compare", {
        parameter other.
        if self:value = other:value:get()
            return self:insertionIdx - other:insertionIdx:get().
            
        return self:value - other:value:get().
    }).
    
    return defineObject(self).
}

function DelayedTaskQueue {
    local self is MinHeap():extend.
    self:setClassName("DelayedTaskQueue").
    
    local nextReadyTime is 0.
    local insertionCounter is 0.
    
    self:public("addTask", {
        parameter taskIn, delay.
        set insertionCounter to insertionCounter + 1.
        local wrappedTask is TaskWrapper(taskIn, time:seconds + delay, insertionCounter):new.
        
        // Only set nextReadyTime if queue was empty
        if nextReadyTime = 0 {
            set nextReadyTime to wrappedTask:value:get().
        }
        self:insert(wrappedTask).
    }).
    
    self:public("getReadyTasks", {
        local readyTasks is list().
        local currentTime is time:seconds.
        
        until self:isEmpty() {
            local nextTask is self:peek().
            if nextTask:value:get() > currentTime {
                set nextReadyTime to nextTask:value:get().
                break.
            }
            
            readyTasks:add(nextTask:task:get()).
            self:extract_min().
        }
        
        if self:isEmpty() {
            set nextReadyTime to 0.
        }
        
        return readyTasks.
    }).
    
    self:public("isReady", {
        return nextReadyTime > 0 and time:seconds >= nextReadyTime.
    }).
    
    return defineObject(self).
}
