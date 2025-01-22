// boot.ks
clearscreen.
print "KOSY Boot Sequence Initiated...".
print " ".
// Load essential classes
print "Loading Core Systems...".
runOncePath("/KOSY/lib/FileWriter").
runOncePath("/KOSY/lib/TaskScheduler").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").
runOncePath("/KOSY/lib/InputHandler").
runOncePath("/KOSY/lib/AppRegistry").
runOncePath("/KOSY/lib/SystemEvents").
runOncePath("/KOSY/lib/SystemConfig").
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
global sysConfig is SystemConfig():new.
global appRegistry is AppRegistryObject():new.

print "Global Services Initialized.".

Print "Building System App Registry...".
appRegistry:buildAppRegistry(path("/KOSY/sys")).

Print "Building User App Registry...".
appRegistry:buildAppRegistry(path("/KOSY/apps")).

// Launch environment
print "Launching Environment...".
runPath("/KOSY/lib/applauncher").

until false {
    scheduler:step().
    screenBuffer:render().
    inputHandler:checkInput().
}.
