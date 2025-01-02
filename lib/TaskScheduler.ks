runOncePath("/KOSY/lib/MinHeap.ks").
runOncePath("/KOSY/lib/Task.ks").
runOncePath("/KOSY/lib/DelayedTaskQueue.ks").

function TaskScheduler {
    local self is Object():extend.
    self:setClassName("TaskScheduler").
    local heap is MinHeap():new.
    local _delayedTaskQueue is DelayedTaskQueue():new.
    local task_count is 0.
    local running is true.
    local cpuUsage is 0.
    
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
            
            set cycleTime to (time:seconds - startTime).
            set cpuUsage to min(100,round(cycleTime / 0.02,2)).
        
    }).

    self:public("step", {
        if running {
            
            // Check for delayed tasks that are ready
            local readyTasks is _delayedTaskQueue:getReadyTasks().
            if readyTasks:isType("list") {
                for t in readyTasks {
                    self:addTask(t).
                }
            }
            
            // Normal task execution
            if task_count > 0 {
                self:executeNext().
            } else {
                set cpuUsage to 0.
            }
        }
    }).
    
    self:public("getCPUUsage", {
        return cpuUsage.
    }).

    self:public("stop", {
        set running to false.
    }).

    self:public("scheduledTasks",{return task_count.}).

    self:public("pendingTasks", {
        return task_count + _delayedTaskQueue:count().
    }).

    
    return defineObject(self).
}