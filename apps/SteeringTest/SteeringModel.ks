function SteeringModel {
    local self is TaskifiedObject():extend.
    
    self:protected("_targetPitch", 0).
    self:protected("_targetHeading", 90).
    self:protected("_maxBankAngle", 30).  // Maximum bank angle for turns
    self:protected("_bankFactor", 0.5).    // How aggressive the banking is

    self:public("setPitch", { parameter vIn. set self:_targetPitch to vIn. }).
    self:public("setHeading", { parameter vIn. set self:_targetHeading to vIn. }).

    // Calculate required bank angle based on heading difference
    self:protected("calculateBankAngle", {
        local currentHeading is get_compass_heading().
        local headingDiff is self:_targetHeading - currentHeading.
        
        // Normalize heading difference to -180 to +180
        until headingDiff <= 180 { set headingDiff to headingDiff - 360. }
        until headingDiff > -180 { set headingDiff to headingDiff + 360. }
        
        // Bank angle proportional to heading difference
        local desiredBank is headingDiff * self:_bankFactor.
        return max(min(desiredBank, self:_maxBankAngle), -self:_maxBankAngle).
    }).

    self:public("getFlightData", {
        return lexicon(
            "setPitch", self:_targetPitch,
            "setHeading", self:_targetHeading,
            "setRoll", get_roll(),
            "actualPitch", get_pitch(),
            "actualHeading", get_compass_heading(),
            "actualRoll", get_roll()
        ).
    }).

    // Main control loop
    self:while(
        { return true. },
        {
            local bankAngle is self:calculateBankAngle().
            // Command heading and pitch while specifying bank angle
            lock steering to heading(self:_targetHeading, self:_targetPitch, bankAngle).
        }
    ).

    
    return defineObject(self).
}
