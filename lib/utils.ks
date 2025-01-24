// KOSY Utility Functions
// Author: Eddie Kerman
// Version: 1.0
//
// The junk drawer of KOSY - random useful functions that don't have a proper home.
// Like that box of cables you keep "just in case" or those random screws
// you're convinced will be important someday. They probably will be.


function padString {
    parameter str, length, padChar.
    local result is str.
    until result:length >= length {
        set result to result + padChar.
    }.
    return result.
}.

FUNCTION map_range {
    PARAMETER value, in_min, in_max, out_min, out_max.
    RETURN (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min.
}

FUNCTION clamp {
    PARAMETER value, min_val, max_val.
    RETURN MIN(MAX(value, min_val), max_val).
}


FUNCTION get_runway_params {
    RETURN LEXICON(
        "half_width", 35,
        "max_distance", 100,
        "vector_draw_length", 5,
        "line_width", 1.0,
        "vector_width", 0.2,
        "start", LATLNG(-0.0485917, -74.7276306),
        "end", LATLNG(-0.0502359, -74.4893951)
    ).
}

FUNCTION get_runway_vectors {
    LOCAL params TO get_runway_params().
    LOCAL vec TO (params["end"]:POSITION - params["start"]:POSITION).
    LOCAL dir TO vec:NORMALIZED.
    
    RETURN LEXICON(
        "vec", vec,
        "dir", dir,
        "normal", VCRS(dir, UP:VECTOR):NORMALIZED,
        "length", vec:MAG
    ).
}

FUNCTION print_runway_debug {
    LOCAL params TO get_runway_params().
    LOCAL vecs TO get_runway_vectors().
    
    PRINT "Runway Start: " + params["start"]:LAT + ", " + params["start"]:LNG AT (0,8).
    PRINT "Runway End: " + params["end"]:LAT + ", " + params["end"]:LNG AT (0,9).
    PRINT "Runway Length: " + ROUND(vecs["length"], 2) + "m" AT (0,10).
    PRINT "Runway Half Width: " + params["half_width"] + "m" AT (0,11).
}

function get_compass_heading {
    PARAMETER pointing_vec is SHIP:FACING:VECTOR.
    LOCAL east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).
    LOCAL trig_x IS VDOT(SHIP:NORTH:VECTOR, pointing_vec).
    LOCAL trig_y IS VDOT(east, pointing_vec).
    LOCAL result IS ARCTAN2(trig_y, trig_x).
    RETURN CHOOSE result + 360 IF result < 0 ELSE result.
}

function get_pitch {
    return 90 - vectorangle(ship:up:forevector, ship:facing:forevector).
}

function get_roll {
    return arctan2(-vdot(ship:facing:starvector, ship:up:forevector),vdot(ship:facing:topvector, ship:up:forevector)).
}

FUNCTION get_runway_heading {
    LOCAL params TO get_runway_params().
    LOCAL runway_vecs TO get_runway_vectors().
    
    
    LOCAL function get_runway_projection {
        LOCAL vec_to_ship TO SHIP:POSITION - params["start"]:POSITION.
        LOCAL proj_length TO VDOT(vec_to_ship, runway_vecs["dir"]).
        LOCAL closest_point TO params["start"]:POSITION + (runway_vecs["dir"] * proj_length).
        RETURN LEXICON(
            "proj_length", proj_length,
            "closest_point", closest_point,
            "distance", MAX(0.0001, (SHIP:POSITION - closest_point):MAG)
        ).
    }
    
    LOCAL function get_correction_vector {
        LOCAL proj_data TO get_runway_projection().
        RETURN (proj_data["closest_point"] - SHIP:POSITION):NORMALIZED.
    }
    
    LOCAL proj_data TO get_runway_projection().
    LOCAL correction TO get_correction_vector().
    
    LOCAL vec_to_end TO (params["end"]:POSITION - SHIP:POSITION):NORMALIZED.
    LOCAL vec_to_start TO (params["start"]:POSITION - SHIP:POSITION):NORMALIZED.
    LOCAL runway_direction TO CHOOSE runway_vecs["dir"] 
        IF VDOT(SHIP:FACING:VECTOR, vec_to_end) > VDOT(SHIP:FACING:VECTOR, vec_to_start) 
        ELSE -runway_vecs["dir"].
    
    LOCAL weight_runway TO 1 - (MIN(proj_data["distance"], params["max_distance"]) / params["max_distance"]).
    LOCAL desired_vec TO (runway_direction * weight_runway + correction * (1 - weight_runway)):NORMALIZED.
    
    RETURN get_compass_heading(desired_vec).
}

function wrapWithParams {
    parameter funcToWrap.
    
    local params is list().
    local isDone is false.
    
    until isDone {
        parameter arg is NULL.
        if arg:isType("Lexicon") and arg = NULL {
            set isDone to true.
        } else {
            params:add(arg).
        }
    }
    
    local boundFunc is funcToWrap.
    for param in params {
        set boundFunc to boundFunc:bind(param).
    }
    
    return boundFunc.
}

function getDirectories{
    parameter pathIn.

    local dirs is list().

    if exists(pathIn){
        local pwd is path().
        cd(pathIn).
        list files in allFiles.
        for file in allFiles{
            if file:typeName = "VolumeDirectory" and not file:toString:startsWith(".")
                dirs:add(file).
        }
        cd(pwd).
    }else{
        print "[ERROR] Invalid Path! " + pathIn.
    }

    return dirs.
}

function create_guid {
    local part_index is floor(random() * ship:parts:length).
    local random_part is ship:parts[part_index].
    
    local part_component is round(random_part:uid:substring(0, 4):tonumber() * random() * 10000).
    local time_component is round(time:seconds * random() * 10000).
    local random_component is round(random() * 10000 * random()).
    
    return part_component + "-" + time_component + "-" + random_component.
}

function logDebug {
    parameter msg.
    log msg to "/KOSY/debug_focus.txt".
}