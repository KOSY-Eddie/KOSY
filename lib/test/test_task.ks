clearscreen.
runOncePath("/KOSY/lib/test/UnitTest.ks").
runOncePath("/KOSY/lib/task.ks").

function TaskTests {
    local self is UnitTest():extend().
    
    // Show execution times for performance analysis
    self:showTestTimes().
    
    self:test("Task Creation", {
        local params is lex(
            "condition", { return true. },
            "work", { return 0. },
            "increment", 0
        ).
        local task is Task(params):new.
        
        //self:assert(task:isType("userDelegate"), "Task should be created").
        self:assertEqual(task:getClassName(), "Task", "Class name should be Task").
        self:assertEqual(task:value:get(), 0, "Initial value should be 0").
    }).
    
    self:test("Task Execution - Simple", {
        local executed is false.
        local params is lex(
            "condition", { return true. },
            "work", { set executed to true. },
            "increment", 0
        ).
        
        local task is Task(params):new.
        local mockScheduler is lex("addTask", { parameter t. }).
        
        task:execute(mockScheduler).
        self:assert(executed, "Work should be executed").
    }).
    
    self:test("Task Condition Control", {
        local executionCount is 0.
        local params is lex(
            "condition", { return executionCount < 1. },
            "work", { set executionCount to executionCount + 1. },
            "increment", 0
        ).
        
        local task is Task(params):new.
        local mockScheduler is lex("addTask", { parameter t. }).
        
        task:execute(mockScheduler).
        task:execute(mockScheduler).
        
        self:assertEqual(executionCount, 1, "Task should execute only once").
    }).
    
    self:test("Task Comparison", {
        local params1 is lex(
            "condition", { return true. },
            "work", { return 0. },
            "increment", 0
        ).
        local params2 is lex(
            "condition", { return true. },
            "work", { return 0. },
            "increment", 0
        ).
        
        local task1 is Task(params1):new.
        local task2 is Task(params2):new.
        
        task1:value:set(5).
        task2:value:set(3).
        
        self:assert(task1:compare(task2) > 0, "Task1 should be greater than Task2").
    }).
    
    return defineObject(self).
}

function TaskExecutionTests {
    local self is UnitTest():extend().
    self:showTestTimes().
    
    // Mock scheduler for testing
    local function createMockScheduler {
        local scheduledTasks is list().
        return lex(
            "addTask", { 
                parameter task. 
                scheduledTasks:add(task).
            },
            "getScheduledTasks", {
                return scheduledTasks.
            }
        ).
    }
    
    self:test("Task State Persistence", {
        local counter is 0.
        local params is lex(
            "condition", { return counter < 3. },
            "work", { set counter to counter + 1. },
            "increment", 0
        ).
        
        local task is Task(params):new.
        local scheduler is createMockScheduler().
        
        // Execute multiple times
        task:execute(scheduler).
        task:execute(scheduler).
        task:execute(scheduler).
        
        self:assertEqual(counter, 3, "Counter should increment three times").
        self:assertEqual(scheduler:getScheduledTasks():length, 2, "Task should be scheduled twice").
    }).
    
    self:test("Runtime Tracking", {
        local executionCount is 0.
        local params is lex(
            "condition", { return executionCount < 2. },
            "work", { 
                wait 0.1.  // Deliberate delay
                set executionCount to executionCount + 1.
            },
            "increment", 0
        ).
        
        local task is Task(params):new.
        local scheduler is createMockScheduler().
        
        task:execute(scheduler).
        self:assert(task:value:get() > 0, "Runtime should be tracked after first execution").
        
        local firstRuntime is task:value:get().
        task:execute(scheduler).
        
        self:assert(task:value:get() > firstRuntime, "Runtime should accumulate across executions").
    }).
    
    self:test("Complex Condition Flow", {
        local state is lex(
            "phase", 0,
            "completed", false
        ).
        
        local params is lex(
            "condition", {  
                return not state:completed.
            },
            "work", {
                if state:phase = 0 {
                    set state:phase to 1.
                } else if state:phase = 1 {
                    set state:phase to 2.
                } else {
                    set state:completed to true.
                }
            },
            "increment", { 
                // Increment function that modifies state
                if state:phase = 2 {
                    set state:completed to true.
                }
            }
        ).
        
        local task is Task(params):new.
        local scheduler is createMockScheduler().
        
        task:execute(scheduler).
        self:assertEqual(state:phase, 1, "First phase completed").
        
        task:execute(scheduler).
        self:assertEqual(state:phase, 2, "Second phase completed").
        
        task:execute(scheduler).
        self:assert(state:completed, "Task should complete after third execution").
    }).
    
    self:test("Task Value Comparison", {
        local params1 is lex(
            "condition", { return true. },
            "work", { wait 0.1. },
            "increment", 0
        ).
        
        local params2 is lex(
            "condition", { return true. },
            "work", { wait 0.2. },
            "increment", 0
        ).
        
        local task1 is Task(params1):new.
        local task2 is Task(params2):new.
        local scheduler is createMockScheduler().
        
        task1:execute(scheduler).
        task2:execute(scheduler).
        
        self:assert(task1:compare(task2) < 0, "Task1 should have less runtime than Task2").
    }).
    
    return defineObject(self).
}

function TaskEdgeCaseTests {
    local self is UnitTest():extend().
    self:showTestTimes().
    
    local function createMockScheduler {
        local scheduledTasks is list().
        return lex(
            "addTask", { 
                parameter task. 
                scheduledTasks:add(task).
            },
            "getScheduledTasks", {
                return scheduledTasks.
            }
        ).
    }
    
    self:test("Increment Function Execution", {
        local incrementCalled is false.
        local workCalled is false.
        
        local params is lex(
            "condition", { return true. },
            "work", { set workCalled to true. },
            "increment", { set incrementCalled to true. }
        ).
        
        local task is Task(params):new.
        local scheduler is createMockScheduler().
        
        task:execute(scheduler).
        self:assert(workCalled, "Work function should be called").
        self:assert(incrementCalled, "Increment function should be called").
    }).
    
    self:test("State Modification During Execution", {
        local state is lex("value", 0).
        local params is lex(
            "condition", { return state:value < 2. },
            "work", { 
                set state:value to state:value + 1.
                return true.
            },
            "increment", { 
                if state:value = 2 {
                    set state:value to 3.
                }
            }
        ).
        
        local task is Task(params):new.
        local scheduler is createMockScheduler().
        
        task:execute(scheduler).
        self:assertEqual(state:value, 1, "First execution should increment value").
        
        task:execute(scheduler).
        self:assertEqual(state:value, 3, "Second execution should trigger increment function").
    }).
    
    self:test("Task Rescheduling Behavior", {
        local executionCount is 0.
        local schedulerCalls is 0.
        
        local params is lex(
            "condition", { return executionCount < 2. },
            "work", { set executionCount to executionCount + 1. },
            "increment", 0
        ).
        
        local scheduler is lex(
            "addTask", { 
                parameter task.
                set schedulerCalls to schedulerCalls + 1.
            }
        ).
        
        local task is Task(params):new.
        
        task:execute(scheduler).
        self:assertEqual(schedulerCalls, 1, "Task should be rescheduled after first execution").
        
        task:execute(scheduler).
        self:assertEqual(schedulerCalls, 1, "Task should not be rescheduled after completion").
    }).
    
    self:test("Nested Task State", {
        local outerState is lex("complete", false).
        local innerState is lex("count", 0).
        
        local params is lex(
            "condition", { return not outerState:complete. },
            "work", {
                set innerState:count to innerState:count + 1.
                if innerState:count >= 3 {
                    set outerState:complete to true.
                }
            },
            "increment", 0
        ).
        
        local task is Task(params):new.
        local scheduler is createMockScheduler().
        
        until outerState:complete {
            task:execute(scheduler).
        }
        
        self:assertEqual(innerState:count, 3, "Inner state should track executions").
        self:assert(outerState:complete, "Outer state should be updated").
    }).
    
    return defineObject(self).
}

// Run the additional tests
local edgeTests is TaskEdgeCaseTests():new.
edgeTests:runAll().
