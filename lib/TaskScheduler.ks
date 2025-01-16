// KOSY Task Scheduler
// Author: Eddie Kerman
// Version: 1.0
//
// Core scheduling system that manages task execution and CPU usage monitoring.
// Handles both immediate and delayed tasks with priority-based execution.
//
// Core Features:
// - Priority-based task execution using MinHeap
// - Delayed task management
// - CPU usage monitoring with moving average
// - Unique task ID generation
//
// Usage:
// The scheduler is typically accessed through the global instance:
//    global scheduler is TaskScheduler():new.
//
// Adding Tasks:
// 1. Immediate execution:
//    scheduler:addTask(someTask).
//
// 2. Delayed execution:
//    scheduler:addDelayedTask(someTask, 5).  // 5 second delay
//
// Main Loop Integration:
// until false {
//     scheduler:step().  // Process next task if available
// }
//
// Public Methods:
// - addTask(task): Add task for immediate scheduling
// - addDelayedTask(task, delay): Schedule task with delay
// - step(): Execute next task if available
// - getCPUUsage(): Get current CPU usage (0-100)
// - stop(): Stop scheduler execution
// - scheduledTasks(): Get count of immediate tasks
// - pendingTasks(): Get total task count (immediate + delayed)
// - newTaskID(): Generate unique task ID
//
// CPU Usage Monitoring:
// - CPU usage represents percentage of time spent executing tasks relative 
//   to the scheduler's step cycle
// - Calculated as: (task_execution_time * physics_tick_rate * 100)%
//   where physics_tick_rate is 50 ticks/second (1/0.02s)
//   Example: 0.01s execution = (0.01 * 50 * 100) = 50% CPU usage
// - Capped at 100% for readability
// - Uses moving average to smooth out usage spikes
// - Records 0% when no tasks are running
// - Note: This differs from traditional OS CPU usage - only measures
//   time consumed by tasks in our scheduler
//
// Task Priority:
// - Based on cumulative runtime
// - Lower runtime = higher priority
// - Tasks with equal runtime ordered by ID
//
// Notes:
// - Scheduler must be stepped regularly
// - CPU usage is approximate
// - Delayed tasks are managed separately
//
// Dependencies:
// - DelayedTaskQueue.ks
// - MinHeap.ks
// - Task.ks
// - KObject.ks

runOncePath("/KOSY/lib/DelayedTaskQueue.ks").
runOncePath("/KOSY/lib/MinHeap.ks").
runOncePath("/KOSY/lib/Task.ks").

function TaskScheduler {
    local self is Object():extend.
    self:setClassName("TaskScheduler").
    local heap is MinHeap():new.
    local _delayedTaskQueue is DelayedTaskQueue():new.
    local task_count is 0.
    local running is true.
    local cpuUsage is 0.
    local nextTaskId is 0.
    
    // CPU usage smoothing
    local cpu_window is list().
    local window_size is 50.
    
    self:public("newTaskID", {
        local taskId is nextTaskId.
        set nextTaskId to nextTaskId + 1.
        return taskId.
    }).
        
    self:public("addTask", {
        parameter newTask.
        heap:insert(newTask).
        set task_count to task_count + 1.
    }).

    self:public("addDelayedTask", {
        parameter taskIn, delay.  
        _delayedTaskQueue:addTask(taskIn, delay).
    }).

    self:protected("executeNext", {
        local startTime is time:seconds.
        
        local currentTask is heap:extract_min().
        set task_count to task_count - 1.
        currentTask:execute(self).
        
        local cycleTime is (time:seconds - startTime).
        local current_usage is min(100, round((cycleTime * 50) * 100, 2)).
        
        // Moving average
        cpu_window:add(current_usage).
        if cpu_window:length > window_size {
            cpu_window:remove(0).
        }
        
        // Average over window
        local total is 0.
        for usage in cpu_window {
            set total to total + usage.
        }
        set cpuUsage to total / cpu_window:length.
    }).

    self:public("step", {
        if running {
            log "Tasks in queue: " + task_count to logPath.
            if _delayedTaskQueue:isReady() {
                log "Delayed queue is ready" to logPath.
                local readyTasks is _delayedTaskQueue:getReadyTasks().
                if readyTasks:isType("list") {
                    log "Ready tasks: " + readyTasks:length to logPath.
                    for t in readyTasks {
                        self:addTask(t).
                    }
                }
            }
            
            if task_count > 0 {
                self:executeNext().
            } else {
                cpu_window:add(0).
                if cpu_window:length > window_size {
                    cpu_window:remove(0).
                }
                local total is 0.
                for usage in cpu_window {
                    set total to total + usage.
                }
                set cpuUsage to total / cpu_window:length.
            }
        }
    }).

    
    self:public("getCPUUsage", {
        return cpuUsage.
    }).

    self:public("stop", {
        set running to false.
    }).

    self:public("scheduledTasks", {
        return task_count.
    }).

    self:public("pendingTasks", {
        return task_count + _delayedTaskQueue:count().
    }).
    
    return defineObject(self).
}