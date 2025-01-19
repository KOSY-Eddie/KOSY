// boot.ks
clearscreen.
print "KOSY Boot Sequence Initiated...".
print " ".
global sysVars is lex("DEBUG", false, "sysConfigPath","/KOSY/var/syscfg","logDir","/KOSY/var/log").
// Load essential classes
print "Loading Core Systems...".
runOncePath("/KOSY/lib/FileWriter").
runOncePath("/KOSY/lib/TaskScheduler").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").
runOncePath("/KOSY/lib/InputHandler").
runOncePath("/KOSY/lib/AppRegistry").
runOncePath("/KOSY/lib/SystemEvents").
runOncePath("/KOSY/lib/utils").
print "Core Systems Loaded.".
print " ".

// Set up globals
print "Initializing Global Services...".
global screenBuffer is DisplayBuffer(terminal:width, terminal:height-1):new.
global inputHandler is SystemInputHandler():new.
global scheduler is TaskScheduler():new.
global sysEvents is SystemEvents():new.
global fwriter is FileWriter():new.
global appRegistry is AppRegistryObject():new.

local configPath is path(sysVars:sysConfigPath):combine("system.json").
global systemConfig is lexicon().
if exists(configPath) {
    set systemConfig to readJSON(configPath).
} else {
    // Create default config
    set systemConfig to lexicon(
        "clock", lexicon(
            "type", "kst"  // default
        )
        // Future system configs go here
    ).
    writeJSON(systemConfig, configPath).
}

//system events
sysEvents:subscribe("configChangeRequested", {
    parameter newConfigIn.
    set systemConfig to newConfigIn:copy().
    // Notify system of change
    sysEvents:emit("systemConfigChanged", systemConfig,"System").
}, "System").

print "Global Services Initialized.".

// App Path Management
function buildAppRegistry {
    parameter appDir.
    
    local appDirNames is getDirectories(appDir).
    local pwd is path().
    local appPaths is list().
    
    for dir in appDirNames {
        local fullPath is appDir:combine(dir:name).
        cd(fullPath).
        
        for file in dir {
            local fn is file:name:split(".")[0].
            if fn = dir {
                runOncePath(fullPath:combine(file:name)).
            }
        }
    }
    cd(pwd).
}

Print "Building System App Registry...".
buildAppRegistry(path("/KOSY/sys")).

Print "Building User App Registry...".
buildAppRegistry(path("/KOSY/apps")).

// Launch environment
print "Launching Environment...".
runPath("/KOSY/lib/applauncher").

until false {
    scheduler:step().
    screenBuffer:render().
    inputHandler:checkInput().
}.
