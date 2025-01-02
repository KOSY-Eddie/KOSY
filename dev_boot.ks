// boot.ks candidate
switch to 0.
cd("/remote/KOSY/").

clearscreen.

print "KOSY Boot Sequence Starting...".

print "Loading Core Modules:".

print "TaskScheduler".
runOncePath("/KOSY/lib/TaskScheduler.ks").

print "AppRegistry".
runOncePath("/KOSY/lib/AppRegistry.ks").


print "Initializing System...".

// Initialize global systems
print "Initializing Task Scheduler".
global scheduler is TaskScheduler():new.

print "Initializing App Registry".
global appRegistry is AppRegistryObject():new.

print "Loading Applications...".

// Function to load apps from a directory
function loadApps {
    parameter directory, appType.
    print "Loading " + appType + " Apps from: " + directory.
    cd(directory).
    local fileList is list().
    LIST FILES IN fileList.
    for file in fileList {
        if file:extension = "ks" {
            //print "Loading " + file:name + "...".
            runOncePath(file:name).
        }.
    }.
}.

// Load system apps first
loadApps("/KOSY/sys", "System").
// Load user apps next
loadApps("/KOSY/apps", "User").


print "Initializing Interface...".
print "Initializing Input Handler".
runOncePath("/KOSY/lib/menu/InputHandler.ks").
global inputHandler is SystemInputHandler():new.
//inputHandler:start().

//system constants
global systemVars is lex(
    "shutdown", false,
    "areas", lex(
        "header", lex(
            "firstCol", 0,
            "lastCol", terminal:width,
            "firstLine", 0,
            "lastLine", 0
        ),
        "footer", lex(
            "firstCol", 0,
            "lastCol", terminal:width,
            "firstLine", terminal:height,
            "lastLine", terminal:height
        ),
        "menu", lex(
            "firstCol", 0,
            "lastCol", 19,  // 20 columns wide (0-19)
            "firstLine", 1, // Start after header
            "lastLine", terminal:height - 2  // End before footer
        ),
        "app", lex(
            "firstCol", 20, // Start after menu
            "lastCol", terminal:width-1,
            "firstLine", 1, // Start after header
            "lastLine", terminal:height - 2  // End before footer
        )
    )
).

global kout is {
    parameter msg.
    print msg at(systemVars:areas:footer:firstCol,
                             systemVars:areas:footer:lastLine).
}.

global kerr is {
    parameter msg.
    print "ERROR: " + msg at(systemVars:areas:footer:firstCol,
                            footer:lastLine).
    set line to line + 1.
}.


cd("/KOSY/").
// Initialize and run display system
print "Creating Display".

runOncePath("/KOSY/lib/menu/Display.ks").
Display().

// main system loop
until systemVars:shutdown {
    if scheduler:pendingTasks() > 0 
        scheduler:step().
}.
print "System Shutdown Complete.".
