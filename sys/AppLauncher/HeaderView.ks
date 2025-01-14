runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/SpacerView").
// HeaderView.ks
function HeaderView {
    local self is HContainerView():extend.
    self:setClassName("HeaderView").
    
    // Create header container
    local headerContainer is HContainerView():new.
    
    // Current app text
    local currentAppText is TextView():new.
    currentAppText:setText("AppLauncher").
    
    // Create spacer
    local headerSpacer is SpacerView():new.
    headerSpacer:setWidth(terminal:width - currentAppText:getWidth() - 17).
    
    // Clock text
    local clockText is TextView():new.
    clockText:setText("00:00").
    
    // Add components to container
    headerContainer:addChild(currentAppText).
    headerContainer:addChild(headerSpacer).
    headerContainer:addChild(clockText).
    
    // Add container to self
    self:addChild(headerContainer).

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
    local clockTaskParams is lex("condition",{return true.},"work",{
        clockText:setText(formatKerbinTime(time:seconds)).
        },"delay",1).
    local clockTask is Task(clockTaskParams):new.
    scheduler:addTask(clockTask).

    
    return defineObject(self).
}
