function FlightHolds {
    local self is TaskifiedObject():extend.

    local maxBank is 30.
    local hdgHold is false.

    self:public("headingTarget", 90).

    // Add method to set target heading
    self:public("setTargetHeading", {
        parameter newTarget.
        set self:headingTarget to newTarget.
    }).

    self:public("engageHeadingHold", {
        set hdgHold to true.
        sas off.
        self:while({return hdgHold.}, {
            local shipPitch is 90 - VANG(SHIP:FACING:VECTOR, SHIP:UP:VECTOR).
            local currentHeading is get_compass_heading().

            // Use ANGLEDELTA for proper heading difference calculation
            lock steering to heading(
                self:headingTarget, 
                0, 
                clamp(currentHeading - self:headingTarget, -maxBank, maxBank)
            ).
        }).
    }).

    // Rename to match FlightModel's call
    self:public("releaseHeadingHold", {
        set hdgHold to false.
        unlock steering. // Make sure to unlock steering when disengaging
    }).

    return defineObject(self).
}
