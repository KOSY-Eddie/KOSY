global systemvars is lex("DEBUG", true).

runOncePath("/KOSY/lib/FileWriter").
runOncePath("/KOSY/lib/TaskScheduler").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").

clearscreen.

global fWriter is FileWriter():new.
fWriter:start().

//fWriter:start().
set CONFIG:IPU to 2000.  // Fixed IPU

// Create display buffer
local screenBuffer is DisplayBuffer(terminal:width, terminal:height):new.

// Create bouncing text
function BouncingText {
    local self is TaskifiedObject():extend.
    self:setClassName("BouncingText").
    
    local str is "000".
    local bounds_ is lex("width", str:length, "height", 1).
    
    local pos is lex(
        "x", round(random() * (terminal:width - bounds_:width)),
        "y", round(random() * (terminal:height - bounds_:height - 1))
    ).
    
    local SPEED is 10.
    local initAngle is random() * (60 - 30) + 30.
    local vel is lex(
        "x", cos(initAngle) * SPEED,
        "y", sin(initAngle) * SPEED
    ).
    
    local lastPhysicsUpdate is time:seconds.
    local lastDisplayUpdate is time:seconds.
    local PHYSICS_RATE is 0.05.  // 50hz physics
    local DISPLAY_RATE is 0.05.  // 10hz display
    
    self:publicS("updatePhysics", {
        local currentTime is time:seconds.
        local dt is currentTime - lastPhysicsUpdate.

        //if dt >= PHYSICS_RATE {
            // Update position using dt
            set pos:x to pos:x + (vel:x * dt).
            set pos:y to pos:y + (vel:y * dt).
            
            // Bounce logic
            if(pos:x + bounds_:width >= terminal:width) {
                set pos:x to terminal:width - bounds_:width.
                set vel:x to -vel:x.
            } else if(pos:x < 0) {
                set pos:x to 0.
                set vel:x to -vel:x.
            }
            
            if(pos:y + bounds_:height >= terminal:height-1) {
                set pos:y to terminal:height - bounds_:height - 1.
                set vel:y to -vel:y.
            } else if(pos:y < 0) {
                set pos:y to 0.
                set vel:y to -vel:y.
            }
            
            set lastPhysicsUpdate to currentTime.
        //}
        
    }).
    
    self:publicS("updateDisplay", {
        //local currentTime is time:seconds.
        //if currentTime - lastDisplayUpdate >= DISPLAY_RATE {
            screenBuffer:clearBuffer().
            screenBuffer:place(round(scheduler:getCPUUsage()):toString(), round(pos:x), round(pos:y)).
            screenBuffer:render().
            //set lastDisplayUpdate to currentTime.
        //}
    }).

    self:public("greedyPhysics",{
        parameter greedyCount.
        local isDone is false.
       
        until greedyCount <=0 {
            self:updatePhysics().
            self:updateDisplay().
            //wait DISPLAY_RATE.
            set greedyCount to greedyCount - 1.
        }
    }).

    
    //Create separate tasks for physics and display
    scheduler:addTask(Task(lex(
        "condition", { return true. },
        "work", { scheduler:addTask(Task(lex("work",{self:greedyPhysics(100).})):new). },
        "delay", 1
    )):new).
    

    // local function auto {
    //     self:while({return true.}, {
    //         self:updatePhysics().
    //         self:updateDisplay().
    //     }, 0).
    // }
    // auto().
    return defineObject(self).
}


// Create bouncing text instance
local bouncer is BouncingText():new.

// Main loop
until false {
    scheduler:step().
    screenBuffer:render().
    //bouncer:updatePhysics().
    //bouncer:updateDisplay().
}.
