FUNCTION create_node_by_targetAltitude {
    PARAMETER targetAltitude, eventTimeUTC.

    // print "Creating maneuver node:".
    // print "  Target Altitude: " + ROUND(targetAltitude/1000, 2) + " km".

    local target_radius is targetAltitude + BODY:RADIUS.
    local radius_at_time_of_burn is get_radius_at_time(eventTimeUTC).
    local v1 is get_velocity_at_time(eventTimeUTC).
    local v2 is get_target_velocity(radius_at_time_of_burn, target_radius).
    // print "  DEBUG:".
    // print"   Altitude at time of burn: " + ROUND((radius_at_time_of_burn - BODY:RADIUS)/1000, 2) + " km".
    // print"   Velocity at time of burn: " + ROUND(v1, 2) + " m/s".
    // print"   Target velocity: " + ROUND(v2, 2) + " m/s".
    local delta_v is v2 - v1.
    
    // print "  Delta-V required: " + ROUND(delta_v, 2) + " m/s".

    ADD NODE(eventTimeUTC, 0, 0, delta_v).
}

function vis_viva {
    parameter r1,     // Radius (not altitude)
              a.     // Semi-major axis
    
    return sqrt(BODY:MU * (2/r1 - 1/a)).
}

function get_target_velocity {
    parameter current_radius,    // Already includes body radius
              target_radius.     // Already includes body radius
    
    local new_sma is (current_radius + target_radius) / 2.
    return vis_viva(current_radius, new_sma).
}

function get_radius_at_time {
    parameter future_time.
    
    local pos_vector is POSITIONAT(SHIP, future_time) - SHIP:BODY:POSITION.
    return pos_vector:MAG.
}

function get_velocity_at_time {
    parameter future_time.
    
    local r1 is get_radius_at_time(future_time).
    local a is SHIP:OBT:SEMIMAJORAXIS.
    
    return vis_viva(r1, a).
}



// Simplified circularization function using changePE
FUNCTION create_circ_node_at_ap {
    LOCAL currentAP is SHIP:OBT:APOAPSIS.
    create_node_by_targetAltitude(currentAP, TIMESTAMP() + ETA:APOAPSIS).
}


// Function to calculate burn duration based on Delta-V
FUNCTION calculate_burn_duration {
    PARAMETER delta_v. // Delta-V required for the maneuver

    LOCAL total_thrust IS 0.
    LOCAL vacuum_isp IS 0.
    LOCAL engine_count IS 0.

    // Iterate through all active engines
    LIST ENGINES IN englist.
    FOR eng IN englist {
        IF eng:AVAILABLETHRUST > 0 AND NOT eng:FLAMEOUT {
            SET total_thrust TO total_thrust + eng:MAXTHRUST.
            SET vacuum_isp TO vacuum_isp + (eng:VACUUMISP * eng:MAXTHRUST). // Weighted ISP
            SET engine_count TO engine_count + 1.
        }
    }

    IF engine_count = 0 {
        //// print "Error: No active engines found.".
        RETURN 0. // No engines, no burn possible
    }

    // Calculate average ISP
    SET vacuum_isp TO vacuum_isp / total_thrust.

    // Calculate initial and final accelerations
    LOCAL initial_mass IS SHIP:MASS.
    LOCAL final_mass IS SHIP:MASS - (delta_v / (vacuum_isp * 9.81)) * total_thrust / (vacuum_isp * 9.81).
    
    LOCAL a0 IS total_thrust / initial_mass. // Initial acceleration
    LOCAL a1 IS total_thrust / final_mass.   // Final acceleration

    // Calculate burn duration using average acceleration
    RETURN delta_v / ((a0 + a1) / 2).
}

// Calculate when to start the burn and its duration
FUNCTION calculate_burn_timing {
    PARAMETER nd.  // Maneuver node
    
    IF NOT HASNODE { RETURN FALSE. }
    
    LOCAL delta_v IS nd:DELTAV:MAG.
    LOCAL burn_duration IS calculate_burn_duration(delta_v).
    
    IF burn_duration = 0 {
        // print "Error: Unable to calculate burn duration.".
        RETURN FALSE.
    }
    
    LOCAL burn_start_time IS TIME:SECONDS + nd:ETA - (burn_duration / 2).
    
    // print "=== Burn Timing Calculations ===".
    // print "Delta-V Required: " + ROUND(delta_v, 1) + " m/s".
    // print "Burn Duration: " + ROUND(burn_duration, 1) + " seconds".
    // print "Burn starts at: T" + ROUND(burn_start_time - TIME:SECONDS, 1) + " seconds".
    
    RETURN LEXICON(
        "burn_start_time", burn_start_time,
        "burn_duration", burn_duration,
        "delta_v", delta_v
    ).
}

// Execute the maneuver node
FUNCTION execute_next_node {
    IF NOT HASNODE {
        // print "No maneuver node found.".
        RETURN FALSE.
    }

    LOCAL nd IS NEXTNODE.
    LOCAL timing IS calculate_burn_timing(nd).
    
    IF timing:ISTYPE("Lexicon") AND timing:HASKEY("burn_start_time") AND timing:HASKEY("burn_duration") {
    // Timing is valid, proceed
    } ELSE {
        // print "Invalid timing calculation.".
        RETURN FALSE.
    }
        
    // Align to maneuver vector
    // print "Aligning to maneuver vector...".
    LOCK STEERING TO nd:BURNVECTOR.
    WAIT UNTIL VANG(SHIP:FACING:VECTOR, nd:BURNVECTOR) < 0.5.
    // print "Alignment complete. Waiting for burn start...".

    // Wait until burn start time
    WAIT UNTIL TIME:SECONDS >= timing:burn_start_time.

    // Execute the burn dynamically
    // print "Starting burn...".
    LOCK THROTTLE TO 1.
    clearScreen.
    UNTIL nd:DELTAV:MAG < 0.1 {
        SET max_acc TO SHIP:MAXTHRUST / SHIP:MASS.

        LOCAL apo IS ROUND(SHIP:OBT:APOAPSIS / 1000, 1).
        LOCAL peri IS ROUND(SHIP:OBT:PERIAPSIS / 1000, 1).
        // print "Apoapsis: " + apo + " km" AT (0,15).
        // print "Periapsis: " + peri + " km" AT (0,16).

        LOCK THROTTLE TO MIN(nd:DELTAV:MAG / (max_acc * 4), 1).
        
        WAIT 0.1.
        // print "Remaining Delta-V: " + ROUND(nd:DELTAV:MAG, 2) + " m/s" AT (0,17).
    }

    // End the burn
    LOCK THROTTLE TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    UNLOCK THROTTLE.
    UNLOCK STEERING.
    
    FOR node IN ALLNODES {
        REMOVE node.
        WAIT 0.1.
    }
    // print "Burn complete.".
    
    RETURN TRUE.
}
