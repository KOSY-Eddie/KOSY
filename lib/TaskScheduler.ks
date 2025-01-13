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
    local window_size is 100.
    
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
            if _delayedTaskQueue:isReady() {
                local readyTasks is _delayedTaskQueue:getReadyTasks().
                if readyTasks:isType("list") {
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

global scheduler is TaskScheduler():new.