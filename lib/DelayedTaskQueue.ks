runOncePath("/KOSY/lib/MinHeap.ks").

function TaskWrapper {
    parameter taskToWrap, executionTime, idx.
    local self is Object():extend.
    
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
    local self is Object():extend.
    self:setClassName("DelayedTaskQueue").
    
    local heap is MinHeap():new.
    local nextReadyTime is 0.
    local insertionCounter is 0.
    
    self:public("addTask", {
        parameter task, delay.
        set insertionCounter to insertionCounter + 1.
        local wrappedTask is TaskWrapper(task, time:seconds + delay, insertionCounter):new.
        
        // Only set nextReadyTime if queue was empty
        if nextReadyTime = 0 {
            set nextReadyTime to wrappedTask:value:get().
        }
        heap:insert(wrappedTask).
    }).
    
    self:public("getReadyTasks", {
        local readyTasks is list().
        local currentTime is time:seconds.
        
        until heap:isEmpty() {
            local nextTask is heap:peek().
            if nextTask:value:get() > currentTime {
                set nextReadyTime to nextTask:value:get().
                break.
            }
            
            readyTasks:add(nextTask:task:get()).
            heap:extract_min().
        }
        
        if heap:isEmpty() {
            set nextReadyTime to 0.
        }
        
        return readyTasks.
    }).
    
    self:public("count", {
        return heap:size().
    }).
    
    self:public("isReady", {
        return nextReadyTime > 0 and time:seconds >= nextReadyTime.
    }).
    
    return defineObject(self).
}
