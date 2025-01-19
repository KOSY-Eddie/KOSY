function TaskMonitorView {
    local self is VcontainerView():extend.
    self:setClassName("TaskMonitor").
    
    // Component creation
    local function createInfoSection {
        local tvInfo is TextView():new.
        tvInfo:vAlign("bottom").
        //tvInfo:expandY:set(false).
        return tvInfo.
    }
    
    local function createHeaderItem {
        parameter textIn.
        local tvItem is TextView():new.
        tvItem:setText(textIn).
        return tvItem.
    }
    
    local function createTaskListHeader {
        parameter isScheduled.
        local container is HContainerView():new.
        container:expandY:set(false).
        container:addChild(createHeaderItem("Task Name")).
        if isScheduled {
            container:addChild(createHeaderItem("Run Count")).
            container:addChild(createHeaderItem("Last Runtime")).
        } else {
            container:addChild(createHeaderItem("Next Run")).
            container:addChild(createHeaderItem("Total Runtime")).
        }
        return container.
    }

    local function formatTime {
        parameter seconds.
        
        local hours is floor(seconds / 3600).
        local minutes is floor((seconds - (hours * 3600)) / 60).
        local secs is round(seconds - (hours * 3600) - (minutes * 60), 2).
        
        if hours > 0 {
            return hours + "h " + minutes + "m " + secs + "s".
        } else if minutes > 0 {
            return minutes + "m " + secs + "s".
        }
        return secs + "s".
    }

        
        local function createTaskDataRow {
        parameter taskIn, timeNow, isScheduled.
        local container is HContainerView():new.
        
        if isScheduled {
            local nameView is TextView():new.
            nameView:setText(taskIn:name:get()).
            
            local countView is TextView():new.
            countView:setText(taskIn:runCount()).
            
            local runtimeView is TextView():new.
            runtimeView:setText(formatTime(taskIn:value:get())).
            
            container:addChild(nameView).
            container:addChild(countView).
            container:addChild(runtimeView).
        } else {
            local unwrappedTask is taskIn:task:get().
            
            local nameView is TextView():new.
            nameView:setText(unwrappedTask:name:get()).
            
            local nextRunView is TextView():new.
            nextRunView:setText(formatTime(taskIn:value:get()-timeNow)).
            
            local runtimeView is TextView():new.
            runtimeView:setText(formatTime(unwrappedTask:value():get())).
            
            container:addChild(nameView).
            container:addChild(nextRunView).
            container:addChild(runtimeView).
        }
        return container.
    }

    
    // View setup
    local textView_info is createInfoSection().
    
    
    local waitingTaskList is VContainerView():new.
    waitingTaskList:expandY:set(false).
    local tv_waitTaskListLabel is TextView():new.
    tv_waitTaskListLabel:setText("Waiting Task List").
    tv_waitTaskListLabel:expandY:set(false).
    
    local scheduledTaskList is VContainerView():new.
    scheduledTaskList:expandY:set(false).
    local tv_schedTaskListLabel is TextView():new.
    tv_schedTaskListLabel:setText("Scheduled Task List").
    tv_schedTaskListLabel:expandY:set(false).
    
    // Layout construction
    self:addChild(textView_info).
    
    self:addChild(tv_waitTaskListLabel).
    self:addChild(createTaskListHeader(false)).
    self:addChild(waitingTaskList).
    
    self:addChild(tv_schedTaskListLabel).
    self:addChild(createTaskListHeader(true)).
    self:addChild(scheduledTaskList).
    
    // Update task
    local function updateDisplay {
        local scheduledTasks is scheduler:scheduledTasks(5).
        local waitingTasks is scheduler:waitingTasks(5).
        
        // Update info section
        textView_info:setText(
            "Waiting: " + waitingTasks:length + " Scheduled: " + scheduledTasks:length +
                 " CPU: " + scheduler:getCPUUsage() + "%"
        ).
        
        // Update waiting task list
        waitingTaskList:clean().
        local timeNow is time:seconds.
        for waitingTask in waitingTasks {
            waitingTaskList:addChild(createTaskDataRow(waitingTask, timeNow, false)).
        }
        
        // Update scheduled task list
        scheduledTaskList:clean().
        for schedTask in scheduledTasks {
            scheduledTaskList:addChild(createTaskDataRow(schedTask, timeNow, true)).
        }
        if not isNull(self:parent)
            self:drawAll().
    }
    
    local updateStatsTaskParams is lex(
        "condition", { return not isNull(self:parent). },
        "work", updateDisplay@,
        "delay", 0.1,
        "name", "Task Scheduler Stat Update"
    ).
    
    scheduler:addTask(Task(updateStatsTaskParams):new).
    return defineObject(self).
}
