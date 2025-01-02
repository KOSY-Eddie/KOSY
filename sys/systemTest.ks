function SystemApp {
    parameter drawableArea.
    local self is View(drawableArea):extend.
    
    // Set class name
    self:setClassName("SYSTEM").
    self:setDrawCallback(displayInfo@).
    
    local function displayInfo{
        local area is drawableArea.
            
        self:while({return views:peek():equals(self).},
        {
            // Draw system information
            print "System Information" at (area:firstCol, area:firstLine).
            print "─────────────────" at (area:firstCol, area:firstLine + 1).
            print "CPU Load: " + scheduler:getCPUUsage() + "%" 
                at (area:firstCol, area:firstLine + 3).
            print "Memory: " + core:currentvolume:freespace + "/" + 
                core:currentvolume:capacity 
                at (area:firstCol, area:firstLine + 4).
            print "Scheduled Tasks: " + scheduler:scheduledTasks()
                at (area:firstCol, area:firstLine + 5).
            print "Pending Tasks: " + scheduler:pendingTasks()
                at (area:firstCol, area:firstLine + 6).
        },1).
    }
    
    return defineObject(self).
}.

// Register the app
appRegistry:register("SYSTEM", SystemApp@).
