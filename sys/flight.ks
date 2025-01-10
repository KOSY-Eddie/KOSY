runOncePath("CP-01/takeoff").
runOncePath("CP-01/phaseManager").
function FlightApp {
    parameter drawableAreaIn.
    local self is View(drawableAreaIn):extend.
    set self:isFocusable to true.
    
    self:setClassName("FLIGHT").
    
    set self:isControllable to true.
    local menuItems is list("Orbit", "Atmosphere", "Launch to Orbit").
    local currentLaunchPhase is "IDLE".
    
    self:setDrawCallback(drawMenu@).

    local function drawMenu {
        print "FLIGHT APPLICATION" at (self:drawableArea:firstCol, self:drawableArea:firstLine).
        print "Altitude: " + round(ship:altitude) at (self:drawableArea:firstCol, self:drawableArea:firstLine + 2).
        
        from { local i is 0. } until i = menuItems:length step { set i to i + 1. } do {
            local prefix is "  ".
            if i = self:currentSelection {
                set prefix to "> ".
            }
            print prefix + menuItems[i] at (self:drawableArea:firstCol, self:drawableArea:firstLine + 4 + i).
        }
    }.
    
    local function drawFlight {
        parameter flightData.
        self:clearArea().
        
        print flightData:status at (self:drawableArea:firstCol, self:drawableArea:firstLine).
        print "Ground speed: " + flightData:groundspeed + " m/s" 
            at (self:drawableArea:firstCol, self:drawableArea:firstLine + 2).
        print "Altitude: " + flightData:altitude + " m" 
            at (self:drawableArea:firstCol, self:drawableArea:firstLine + 3).
        print "Vertical Speed: " + flightData:verticalspeed + " m/s" 
            at (self:drawableArea:firstCol, self:drawableArea:firstLine + 4).
    }.
    
    local function launchTakeoff{
        set currentLaunchPhase to "TAKEOFF".
        local takeoff is CPTakeoff(self:drawableArea):new.
        takeoff:activate().
        takeoff:execute().
    }
    
    self:protected("handleInput", {
        parameter input.
        local needsRedraw is false.

        if input = "UP" {
            if self:currentSelection > 0 {
                set self:currentSelection to self:currentSelection - 1.
                set needsRedraw to true.
            }
        } else if input = "DOWN" {
            if self:currentSelection < menuItems:length - 1 {
                set self:currentSelection to self:currentSelection + 1.
                set needsRedraw to true.
            }
        } else if input = "CONFIRM" {
            if self:currentSelection = 2 {
                launchTakeoff().
            }
        }else if input = "LEFT" {
            self:deactivate().
        }
        
        if needsRedraw {
            self:draw().
        }
    }).
    
    return defineObject(self).
}

appRegistry:register("Flight", FlightApp@).
