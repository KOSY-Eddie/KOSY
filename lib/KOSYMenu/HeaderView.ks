runOncePath("/KOSY/lib/KOSYView/core").
runOncePath("/KOSY/lib/KOSYView/specialized").

function HeaderView {
    parameter drawableAreaIn, titleText.
    local self is View(drawableAreaIn):extend.
    self:setClassName("HeaderView").

    // Create title and time text views
    local titleView is TextView(DrawableArea(0,titleText:length,0,0):new,titleText):new.
    local timeView is TextView(DrawableArea(self:drawableArea:lastCol:get()-15,self:drawableArea:lastCol:get(),0,0):new,""):new.

    // Format time as Y# D## HH:MM:SS in Kerbin time
    function formatKerbinTime {
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

    local function clock{
        self:while({return true.},{
            local scheduledTasks is scheduler:scheduledTasks().
            local pendingTasks is scheduler:pendingTasks().
            titleView:setText("Tasks: " + scheduledTasks+ " Pending: " + pendingTasks).
            timeView:setText(formatKerbinTime(time:seconds)).
        }, 1).
    }


    clock().

    return defineObject(self).
}
