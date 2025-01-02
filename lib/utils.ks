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
