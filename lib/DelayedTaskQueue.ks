runOncePath("/KOSY/lib/QuickSort.ks").
//runOncePath("/KOSY/lib/TaskifiedObject.ks").

local function TaskWrapper {
    parameter taskToWrap, executionTime.
    local self is Object():extend.
    
    self:public("task", taskToWrap).
    self:public("executeAt", executionTime).
    
    self:public("compare", {
        parameter other.
        return self:executeAt - other:executeAt:get().
    }).
    
    return defineObject(self).
}

function DelayedTaskQueue {
    local self is Object():extend.
    self:setClassName("DelayedTaskQueue").
    
    local items is list().
    local sorter is QuickSort():new.
    
    self:public("push", {
        parameter wrapper.
        items:add(wrapper).
        sorter:sort(items).
    }).
    
    self:public("pop", {
        if self:isEmpty() {
            return null.
        }
        local returnItem is items[0].
        items:remove(0).
        return returnItem.
    }).
    
    self:public("addTask", {
        parameter taskIn, delay.
        local wrapper is TaskWrapper(taskIn, time:seconds + delay):new.
        self:push(wrapper).
    }).

    self:public("count", {
        return items:length.
    }).
    
    self:public("isEmpty", {
        return items:length = 0.
    }).
    
    self:public("peek", {
        if self:isEmpty() {
            return null.
        }
        return items[0].
    }).
    
    self:public("getReadyTasks", {
        local readyTasks is list().
        local currentTime is time:seconds.
        local shouldContinue is true.
        
        until self:isEmpty() or not shouldContinue {
            local nextTask is self:peek().
            if nextTask:executeAt:get() > currentTime {
                set shouldContinue to false.
            } else {
                readyTasks:add(self:pop():task:get()).
            }
        }
        
        return readyTasks.
    }).
    
    self:public("count", {
        return items:length.
    }).
    
    return defineObject(self).
}



// // Test code
// function TestTask {
//     parameter name.
//     local self is Object():extend.
    
//     self:public("execute", {
//         print "Executing " + name + " at " + time:seconds.
//     }).
    
//     return defineObject(self).
// }