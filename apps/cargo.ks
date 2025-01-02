function CargoApp {
    parameter drawableAreaIn.
    local self is View(drawableAreaIn):extend.
    set self:isFocusable to true.
    
    self:setClassName("Cargo").
    self:setDrawCallback(displayUpdate@).
    
    set self:isControllable to true.

    local midDivider is (self:drawableArea:firstLine + self:drawableArea:lastLine)/2.
    local payloadBayIsOpen is false. // false is closed
    local rampStatus is null. // false is closed
    local currentSelection is 0.
    local rampDeployLimits is lex("closed", 0, "flat", 25, "extended", 60, "max", 100).
    local menuItems is list("Toggle Payload Bay", "Toggle Cargo Ramp").

    // Find all cargo bays on the vessel
    local cargoBays is ship:partstagged("payloadbay").

    local function toggleCargoBay{
       
        for bay in cargoBays {
                bay:getmodule("ModuleAnimateGeneric"):doaction("toggle bay doors", not payloadBayisOpen). //false is open
            }

        set payloadBayisOpen to not payLoadBayisOpen.
    }

    local function getFrontWheelStress{
        return ship:partsdubbed("frontgear")[0]:
                                getmodule("KSPWheelDamage"):
                                getfield("wheel stress").
    }

    local function toggleCargoRamp{
       //local startingWheelStress is getFrontWheelStress().

       local cargoRampModule is getCargoRampModule().
        cargoRampModule:doaction("toggle ramp", true). //true or false doesnt matter

            local continueRunning is true.
            self:while({return continueRunning.}, {
                set rampStatus to cargoRampModule:getfield("status").
                if not rampStatus:contains("Moving"){
                    set continueRunning to false.
                    self:draw().
                    waitForMoveComplete(findGround@).
                }

            },0.1).
        
    }

    local function waitForMoveComplete{
        parameter callback is {}.
         local cargoRampModule is getCargoRampModule().

            local continueRunning is true.
            self:while({return continueRunning.}, {
                set rampStatus to cargoRampModule:getfield("status").
                if not rampStatus:contains("Moving"){
                    set continueRunning to false.
                    self:draw().
                    callback().
                }

            },0.1).
    }

    local function getCargoRampModule{
        local cargoRamp is ship:partstagged("ramp").
        if cargoRamp:length > 0
            return cargoRamp[0]:getmodule("ModuleAnimateGeneric").
    }

    local function resetRampToLevel{
        local cargoRampModule is getCargoRampModule().
        if cargoRampModule:getfield("status"):contains("Clamped"){
            local rampPos is cargoRampModule:getfield("deploy limit").
            local continueRunning is rampPos >= rampDeployLimits:extended.
            if not continueRunning{
                cargoRampModule:doaction("toggle ramp", false).
                waitForMoveComplete().
            }else{
                self:while({return continueRunning.},{
                    set rampPos to rampPos - 1.
                    cargoRampModule:setfield("deploy limit", rampPos).
                    if rampPos < rampDeployLimits:extended{
                        set continueRunning to false.
                        wait .1.
                        resetRampToLevel().
                    }
                },0.01).
            }
        }


    }

    local function findGround{
        local startingWheelStress is getFrontWheelStress().
        local cargoRampModule is getCargoRampModule().
        if startingWheelStress = 0 or cargoRampModule:getfield("status"):contains("Locked") //sanity checks
            return.
        
        
        local continueRunning is true.
        local stressDelta is .1.
        local deployInc is 1.
        local rampPos is cargoRampModule:getfield("deploy limit").
        set rampStatus to "finding ground...".
        self:draw().

        //TODO: Maybe add easing if the wheel is overstressed, i.e. the ramp is overextended
        self:while({return continueRunning.}, {

            if abs(getFrontWheelStress() - startingWheelStress) > stressDelta{
                cargoRampModule:setfield("deploy limit", rampPos - deployInc).
                set continueRunning to false.
                set rampStatus to cargoRampModule:getfield("status").
                self:draw().
            }else{
                set rampPos to rampPos + deployInc. 
                cargoRampModule:setfield("deploy limit", rampPos).
            }

        },0.01).
    }

        
    local function displayUpdate {
        self:clearArea().
        set rampStatus to getCargoRampModule():getfield("status").
        print "Payload Bay Status: " + (choose "OPEN" if payloadBayIsOpen else "CLOSED") 
            at (self:drawableArea:firstCol, self:drawableArea:firstLine + 1).
        print "Cargo Ramp Status: " + rampStatus
            at (self:drawableArea:firstCol, self:drawableArea:firstLine + 2).
        
        from { local i is 0. } until i = menuItems:length step { set i to i + 1. } do {
            local prefix is "  ".
            if i = currentSelection {
                set prefix to "> ".
            }
            print prefix + menuItems[i] at (self:drawableArea:firstCol, self:drawableArea:firstLine + 3 + i).
        }
    }.

    self:protected("handleInput", {
        parameter input.
        local needsRedraw is false.
        
        if input = "UP" {
            set currentSelection to max(0, currentSelection - 1).
            set needsRedraw to true.
        }
        else if input = "DOWN" {
            set currentSelection to min(menuItems:length - 1, currentSelection + 1).
            set needsRedraw to true.
        }
        else if input = "CONFIRM" {
            if currentSelection = 0{
                toggleCargoBay().
            }else if currentSelection = 1{
                if rampStatus:contains("Locked")
                    toggleCargoRamp().
                else if rampStatus:contains("Clamped")
                    resetRampToLevel().
                
                set needsRedraw to true.
            }
        }
        else if input = "LEFT" or input = "ESCAPE" {
            self:deactivate().
        }
        
        if needsRedraw {
            self:draw().
        }
    }).
    
    return defineObject(self).
}

// Register the app
appRegistry:register("Cargo", CargoApp@).
