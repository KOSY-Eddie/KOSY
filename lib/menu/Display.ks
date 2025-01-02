runOncePath("/KOSY/lib/menu/view").
runOncePath("/KOSY/lib/menu/Header").
runOncePath("/KOSY/lib/menu/Footer").
runOncePath("/KOSY/lib/menu/MainMenu").

function Display {
       local displayArea is lex(
            "firstCol", 0,
            "lastCol", terminal:width,
            "firstLine", 0,
            "lastLine", terminal:height
        ).
    local self is View(displayArea):extend.
    clearscreen.
    local _header is Header():new.
    local _footer is Footer():new.

    self:public("launchApp", {
        parameter appName.
        local appClass is appRegistry:apps:get()[appName].
        print "launchapp".
        if appClass <> 0 {            
            // Create and activate new app
            local newApp is appClass():new.
            newApp:setActive(true).
        } else {
            _footer:setError("App not found: " + appName).
        }.
    }).
    
    self:public("shutdown", {
        set systemVars:shutdown to true.
    }).

    // Public interface to set errors
    self:public("setError", {
        parameter msg.
        _footer:setError(msg).
    }).
    
    self:public("clearError", {
        _footer:clearError().
    }).
    
    local main is MainMenu(self:launchApp@):new. //set callback for app launching
    
    return defineObject(self).
}


// // Test code
// clearscreen.
// global scheduler is TaskScheduler():new.

// local testDisplay is Display():new.

// // Taskified test loop
// local testObj is TaskifiedObject():extend.
// local i is 0.

// testObj:for(
//     { return i <= 5. },           // condition
//     {set i to i+1.}, //increment
//     { 
//         testDisplay:setError("Error #" + i).
//     },                            // work
//     2                             // delay of 2 seconds
// ).

// until false {
//     scheduler:step().
//     //testDisplay:draw().
//    // wait 0.001.
// }.
