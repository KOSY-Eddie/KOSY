runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/SpacerView").

function SystemHeader {
    local self is HContainerView():extend.
    self:setClassName("SystemHeader").
    
    local missionStartTime is time:seconds.
    
    // Create header container
    local headerContainer is HContainerView():new.
    
    // Current app text
    local mainName is TextView():new.
    mainName:setText("KOSY").
    mainName:hAlign("left").
    local currentAppText is TextView():new.
    currentAppText:setText("AppLauncher").
    currentAppText:hAlign("center").
    
    // Clock text
    local clockText is TextView():new.
    clockText:setText("Y000 D00 00:00:00").
    clockText:halign("right").
    
    // Add components to container
    headerContainer:addChild(mainName).
    headerContainer:addChild(currentAppText).
    headerContainer:addChild(clockText).
    
    // Add container to self
    self:addChild(headerContainer).

        local function calculateTimeUnits {
        parameter secondsIn, hoursPerDay.
        local SECONDS_PER_MINUTE is 60.
        local MINUTES_PER_HOUR is 60.
        
        local totalMinutes is floor(secondsIn / SECONDS_PER_MINUTE).
        local totalHours is floor(totalMinutes / MINUTES_PER_HOUR).
        local days is floor(totalHours / hoursPerDay).
        
        local secs is floor(mod(secondsIn, SECONDS_PER_MINUTE)).
        local minutes is mod(totalMinutes, MINUTES_PER_HOUR).
        local hours is mod(totalHours, hoursPerDay).
        
        return lex(
            "days", days,
            "hours", hours,
            "minutes", minutes,
            "seconds", secs
        ).
    }

    local function formatKerbinTime {
        parameter totalSeconds.
        local DAYS_PER_YEAR is 426.
        local HOURS_PER_DAY is 6.
        
        local units is calculateTimeUnits(totalSeconds, HOURS_PER_DAY).
        local years is floor(units:days / DAYS_PER_YEAR) + 1.
        local days is mod(units:days, DAYS_PER_YEAR) + 1.

        local timeStr is "Y" + years + " D" + padding(days) + " " + 
            padding(units:hours) + ":" + padding(units:minutes) + ":" + 
            padding(units:seconds).
        log "KST length: " + timeStr:length + " string: '" + timeStr + "'" to "debug.log".
        return timeStr.
    }

    local function formatMETTime {
        parameter secondsIn.
        local HOURS_PER_DAY is 24.
        
        local units is calculateTimeUnits(secondsIn, HOURS_PER_DAY).
        local timeStr is "T+" + (choose (units:days + "d ") if units:days > 0 else "") +
            padding(units:hours) + ":" + padding(units:minutes) + ":" + padding(units:seconds).
        log "MET length: " + timeStr:length + " string: '" + timeStr + "'" to "debug.log".
        return timeStr.
    }


    local function padding {
        parameter num.
        if num < 10 {
            return "0" + num.
        }
        return num:tostring.
    }

    // Clock update task
    local clockTaskParams is lex(
        "condition", {return true.},
        "work", {
            if systemConfig:clock:type = "met" {
                clockText:setText(formatMETTime(MISSIONTIME):padLeft(20)).
            } else {
                clockText:setText(formatKerbinTime(time:seconds):padLeft(20)).
            }
        },
        "delay", 1
    ).
    
    local clockTask is Task(clockTaskParams):new.
    scheduler:addTask(clockTask).

    // Public methods
    self:public("setAppTitle", {
        parameter titleText. 
        currentAppText:setText(titleText).
    }).
    
    return defineObject(self).
}
