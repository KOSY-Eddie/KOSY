runOncePath("/KOSY/lib/orbital/orbital").  // Keep all the original orbital mechanics functions

function ManeuverExecutor {
    parameter drawableArea.
    local self is TaskifiedObject():extend.
    self:setClassName("ManeuverExecutor").
    
    // Status display method
    self:public("updateStatus", {
        parameter message, extraInfo is "".
        local width is drawableArea:lastCol - drawableArea:firstCol.
        print message:padright(width) at (drawableArea:firstCol, drawableArea:firstLine).
        if extraInfo:length > 0 {
            print extraInfo:padright(width) at (drawableArea:firstCol, drawableArea:firstLine + 1).
        }
    }).

    self:public("createCircNodeAtAp",create_circ_node_at_ap()).
    
    // Execute node sequence
    self:public("executeNode", {
        parameter callback.
        if not hasnode {
            self:updateStatus("No maneuver node found.").
            return.
        }

        local nd is nextnode.
        sas off.
        rcs on.
        local timing is calculate_burn_timing(nd).
        
        if timing:istype("Lexicon") and timing:haskey("burn_start_time") and timing:haskey("burn_duration") {
            self:alignToNode({
                self:waitForBurnStart(timing:burn_start_time, {
                    rcs off.
                    self:executeBurn(callback@).
                }).
            }).
        } else {
            self:updateStatus("Invalid timing calculation.").
        }
    }).
    
    // Alignment phase
    self:public("alignToNode", {
        parameter callback.
        local running is true.
        local nd is nextnode.
        
        self:updateStatus("Aligning to maneuver vector...").
        lock steering to nd:burnvector.
        
        self:while(
            { return running. },
            { 
                if vang(ship:facing:vector, nd:burnvector) <= 0.5 {
                    set running to false.
                    self:updateStatus("Alignment complete. Waiting for burn start...").
                    callback().
                }
            }
        ).
    }).
    
    // Wait for burn start
    self:public("waitForBurnStart", {
        parameter burn_start_time, callback.
        local running is true.
        
        self:while(
            { return running. },
            { 
                if time:seconds >= burn_start_time {
                    set running to false.
                    callback().
                }
                self:updateStatus("Waiting for burn start...",
                    "T-" + round(burn_start_time - time:seconds) + "s").
            }, 0.1
        ).
    }).
    
    // Execute burn
    self:public("executeBurn", {
        parameter callback.
        local running is true.
        local nd is nextnode.
        rcs on.
        
        lock throttle to 1.
        
        self:while(
            { return running. },
            {
                if nd:deltav:mag <= 0.1 {
                    set running to false.
                    lock throttle to 0.
                    lock steering to ship:facing.
                    wait 1.
                    set ship:control:pilotmainthrottle to 0.
                    set ship:control:neutralize to true.
                    unlock throttle.
                    unlock steering.
                    rcs off.
                    sas off.
                    
                    for node in allnodes { remove node. }
                    
                    self:updateStatus("Burn complete.").
                    callback().
                } else {
                    local max_acc is ship:maxthrust / ship:mass.
                    lock throttle to min(nd:deltav:mag / (max_acc * 4), 1).
                    self:updateStatus("Executing burn",
                        "Remaining dV: " + round(nd:deltav:mag, 1) + " m/s" + char(10) +
                        "Ap: " + round(ship:obt:apoapsis/1000, 1) + " km" + char(10) +
                        "Pe: " + round(ship:obt:periapsis/1000, 1) + " km").
                }
            }
        ).
    }).
    
    return defineObject(self).
}

