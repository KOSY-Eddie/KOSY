// boot.ks
clearscreen.
print "KOSY Boot Sequence Initiated...".
print " ".
global systemvars is lex("DEBUG", false).
// Load essential classes
print "Loading Core Systems...".
runOncePath("/KOSY/lib/FileWriter").
runOncePath("/KOSY/lib/TaskScheduler").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").
runOncePath("/KOSY/lib/InputHandler").
runOncePath("/KOSY/lib/AppRegistry").
runOncePath("/KOSY/lib/utils").
print "Core Systems Loaded.".
print " ".

// Set up globals
print "Initializing Global Services...".
global screenBuffer is DisplayBuffer(terminal:width, terminal:height-1):new.
global inputHandler is SystemInputHandler():new.
global scheduler is TaskScheduler():new.
global fwriter is FileWriter():new.
print "Global Services Initialized.".

global appRegistry is AppRegistryObject():new.
// Scan and load apps
print "Scanning for Applications...".
local appDirs is getDirectories("/KOSY/sys").

local pwd is path().
for dir in appDirs{
    cd(dir).
    list files in fileList.
    for file in fileList{
        if file = "app.ks"{
            print "Found " + dir.
            runOncePath(file).
        }
    }
}
cd(pwd).
print "Applications Loaded.".

// Launch environment
print "Launching Environment...".
local registeredApps is appRegistry:apps:get().

if registeredApps:hasKey("AppLauncher") {
    registeredApps:AppLauncher(registeredApps).

    until false {
        scheduler:step().
        screenBuffer:render().
        inputHandler:checkInput().
    }.

} else {
    print "Error: AppLauncher not found!".
}
