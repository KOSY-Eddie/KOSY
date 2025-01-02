clearscreen.
runOncePath("/KOSY/lib/test/UnitTest.ks").
runOncePath("/KOSY/lib/taskscheduler.ks").

function TaskSchedulerTests {
    local self is UnitTest():extend().
    self:showTestTimes().
    
    self:test("Manual Task Execution", {
        local scheduler is TaskScheduler():new.
        local state is lex(
            "executed", false,
            "executionCount", 0
        ).
        
        // More explicit task that we can track
        local taskParams is lex(
            "condition", { 
                // Only run once
                return state:executionCount = 0. 
            },
            "work", { 
                set state:executed to true.
                set state:executionCount to state:executionCount + 1.
            },
            "increment", 0
        ).

        local newTask is Task(taskParams):new.
        //print newTask. wait 10.
        
        scheduler:addTask(newTask).
        self:assertEqual(
            scheduler:pendingTasks(),
            1,
            "Should have one pending task initially"
        ).
        
        self:assert(
            not state:executed,
            "Task should not execute before step"
        ).
        
        scheduler:step().
        
        self:assert(
            state:executed,
            "Task should execute after step"
        ).
        self:assertEqual(
            state:executionCount,
            1,
            "Task should execute exactly once"
        ).
        self:assertEqual(
            scheduler:pendingTasks(),
            0,
            "No tasks should be pending after completion"
        ).
    }).

    
    self:test("Multiple Step Task", {
        local scheduler is TaskScheduler():new.
        local state is lex(
            "count", 0
        ).
        
        local taskParams is lex(
            "condition", { return state:count < 3. },
            "work", { set state:count to state:count + 1. },
            "increment", 0
        ).
        
        scheduler:addTask(Task(taskParams):new).
        
        scheduler:step().
        self:assertEqual(state:count, 1, "First step execution").
        
        scheduler:step().
        self:assertEqual(state:count, 2, "Second step execution").
        
        scheduler:step().
        self:assertEqual(state:count, 3, "Final step execution").
        self:assertEqual(scheduler:pendingTasks(), 0, "All tasks complete").
    }).
    
    self:test("Delayed Task Integration", {
        local scheduler is TaskScheduler():new.
        local state is lex(
            "executed", false,
            "readyTime", 0
        ).
        
        local taskParams is lex(
            "condition", { return true. },
            "work", { 
                set state:executed to true.
                set state:readyTime to time:seconds.
            },
            "increment", 0
        ).
        
        local task is Task(taskParams):new.
        local startTime is time:seconds.
        scheduler:addDelayedTask(task, 0.1).
        
        // First step - shouldn't execute
        scheduler:step().
        self:assert(
            not state:executed,
            "Task should not execute before delay"
        ).
        
        // Wait and verify
        wait 0.2.
        local beforeStepTime is time:seconds.
        scheduler:step().
        
        // Debug info
        print "Start time: " + startTime.
        print "Before second step: " + beforeStepTime.
        print "Ready time: " + state:readyTime.
        print "Delay elapsed: " + (beforeStepTime - startTime).
        print "Pending tasks: " + scheduler:pendingTasks().
        
        self:assert(
            state:executed,
            "Task should execute after delay and step"
        ).
    }).


    
    self:test("CPU Usage Tracking", {
        local scheduler is TaskScheduler():new.
        local taskParams is lex(
            "condition", { return true. },
            "work", { wait 0.01. },
            "increment", 0
        ).
        
        scheduler:addTask(Task(taskParams):new).
        scheduler:step().
        
        local usage is scheduler:getCPUUsage().
        self:assert(usage > 0, "CPU usage should be tracked during step").
        self:assert(usage <= 100, "CPU usage should not exceed 100%").
    }).
    
    return defineObject(self).
}

// Run the tests
local tests is TaskSchedulerTests():new.
tests:runAll().
