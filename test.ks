clearscreen.

until false {
    local rightVector is vcrs(ship:up:vector, ship:facing:forevector).
    local rollAngle is vang(rightVector, ship:facing:starVector).
    if vdot(ship:facing:topVector, ship:up:vector) < 0 {
        set rollAngle to 360 - rollAngle.
    }

    local pitchAngle is 90 - vang(ship:facing:forevector, ship:up:vector).

    print "Roll: " + round(rollAngle,1) + "   " at (0,0).
    print "Pitch: " + round(pitchAngle,1) + "   " at (0,1).
    
    wait 0.1.
}
