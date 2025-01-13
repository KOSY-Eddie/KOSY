runOncePath("/KOSY/lib/TaskifiedObject.ks").

function HeaderView {
    parameter titleText.
    local self is View():extend.
    self:setClassName("HeaderView").
    
    // Initialize with full width, 1 line height
    self:init(terminal:width, 1).
    
    // Protected members
    self:protected("title", titleText).
    self:protected("timeText", "").
    
    // Format time as Y# D## HH:MM:SS in Kerbin time
    local function formatKerbinTime {
        parameter totalSeconds.
        
        // Kerbin time constants
        local SECONDS_PER_MINUTE is 60.
        local MINUTES_PER_HOUR is 60.
        local HOURS_PER_DAY is 6.
        local DAYS_PER_YEAR is 426.

        // Calculate time components
        local totalMinutes is floor(totalSeconds / SECONDS_PER_MINUTE).
        local totalHours is floor(totalMinutes / MINUTES_PER_HOUR).
        local totalDays is floor(totalHours / HOURS_PER_DAY).

        // Extract components
        local secs is floor(mod(totalSeconds, SECONDS_PER_MINUTE)).
        local minutes is mod(totalMinutes, MINUTES_PER_HOUR).
        local hours is mod(totalHours, HOURS_PER_DAY).
        local days is mod(totalDays, DAYS_PER_YEAR).
        local years is floor(totalDays / DAYS_PER_YEAR) + 1.

        // Format as Y# D## HH:MM:SS
        return "Y" + years + " D" + padding(days) + " " + 
            padding(hours) + ":" + 
            padding(minutes) + ":" + 
            padding(secs).
    }

    // Add leading zero if needed
    local function padding {
        parameter num.
        if num < 10 {
            return "0" + num.
        }
        return num:tostring.
    }
    
    // Override draw method
    self:public("draw", {
        if not self:visible { return. }
        
        local taskInfo is "Tasks: " + scheduler:scheduledTasks() + 
                         " Pending: " + scheduler:pendingTasks().
        local timeInfo is formatKerbinTime(time:seconds).
        
        // Draw task info on left
        screenBuffer:place(taskInfo, 
            self:position:x, 
            self:position:y).
            
        // Draw time on right
        screenBuffer:place(timeInfo, 
            self:position:x + self:dimensions:width - timeInfo:length,
            self:position:y).
            
        set self:dirty to false.
    }).
    
    // Start the update clock
    scheduler:addTask(Task(lex(
        "condition", { return true. },
        "work", { set self:dirty to true. },
        "delay", 1
    )):new).
    
    return defineObject(self).
}
