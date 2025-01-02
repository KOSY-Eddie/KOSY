runOncePath("/KOSY/lib/test/UnitTest.ks").
runOncePath("/KOSY/lib/taskifiedObject.ks").

clearscreen.
runOncePath("/KOSY/lib/TaskScheduler.ks").

local function createMockScheduler {
    local scheduledTasks is list().
    return lex(
        "addTask", { 
            parameter task. 
            scheduledTasks:add(task).
        },
        "getScheduledTasks", {
            local tasksCopy is list().
            for task in scheduledTasks {
                tasksCopy:add(task).
            }
            return tasksCopy.
        },
        "clearTasks", {
            scheduledTasks:clear().
        },
        "executeAll", {
            until scheduledTasks:length = 0 {
                local task is scheduledTasks[0].
                scheduledTasks:remove(0).
                task:execute(scheduler).
            }.
        }
    ).
}

function TaskifiedObjectTests {
    local self is UnitTest():extend().
    self:showTestTimes().
    
    // Mock scheduler creation
    local function createMockScheduler {
        local scheduledTasks is list().
        return lex(
            "addTask", { 
                parameter task. 
                scheduledTasks:add(task).
            },
            "getScheduledTasks", {
                return scheduledTasks.
            },
            "clearTasks", {
                scheduledTasks:clear().
            }
        ).
    }
    
    // Test class with various parameter patterns
    local function TestClass {
        local self is TaskifiedObject():extend.
        
        // No parameters
        self:public("noParams", {
            return 42.
        }).
        
        // Single parameter
        self:public("singleParam", {
            parameter x.
            return x * 2.
        }).
        
        // Multiple parameters
        self:public("multiParams", {
            parameter x, y, z.
            return x + y + z.
        }).
        
        // Default parameters
        self:public("defaultParams", {
            parameter x, y is 10, z is 5.
            return x + y + z.
        }).
        
        // Variable parameters with state
        local counter is 0.
        self:public("stateWithParams", {
            parameter increment.
            set counter to counter + increment.
            return counter.
        }).
        
        // Nested function calls
        self:public("nestedCalls", {
            parameter x, y.
            local result is 0.
            local function inner {
                parameter a, b.
                return a * b.
            }
            return inner(x, y) + x.
        }).
        
        // Complex parameter types
        self:public("complexParams", {
            parameter listArg, lexArg.
            return listArg:length + lexArg:keys:length.
        }).
        
        // Method that returns a delegate
        self:public("returnDelegate", {
            parameter x.
            return { parameter y. return x + y. }.
        }).
        
        // Non-delegate property
        self:public("staticValue", 100).
        
        return defineObject(self).
    }
    
    self:test("No Parameters Method", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:noParams().
        local task is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task:getClassName() = "Task", "Task should be created for parameterless method").
        mockScheduler:clearTasks().
    }).
    
    self:test("Single Parameter Method", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:singleParam(5).
        local task is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task:getClassName() = "Task", "Task should be created with single parameter").
        mockScheduler:clearTasks().
    }).
    
    self:test("Multiple Parameters Method", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:multiParams(1, 2, 3).
        local task is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task:getClassName() = "Task", "Task should be created with multiple parameters").
        mockScheduler:clearTasks().
    }).
    
    self:test("Default Parameters Method", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:defaultParams(5).
        local task1 is mockScheduler:getScheduledTasks()[0].
        mockScheduler:clearTasks().
        
        testObj:defaultParams(5, 20).
        local task2 is mockScheduler:getScheduledTasks()[0].
        mockScheduler:clearTasks().
        
        testObj:defaultParams(5, 20, 10).
        local task3 is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task1:getClassName() = "Task" and task2:getClassName() = "Task"and task3:getClassName() = "Task", 
            "Tasks should be created with default parameters").
        mockScheduler:clearTasks().
    }).
    
    self:test("State With Parameters", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:stateWithParams(5).
        testObj:stateWithParams(10).
        
        self:assertEqual(
            mockScheduler:getScheduledTasks():length,
            2,
            "Multiple state-changing calls should create separate tasks"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("Nested Function Calls", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:nestedCalls(3, 4).
        local task is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task:getClassName() = "Task", "Task should be created for nested function calls").
        mockScheduler:clearTasks().
    }).
    
    self:test("Complex Parameter Types", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:complexParams(list(1,2,3), lex("a", 1, "b", 2)).
        local task is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task:getClassName() = "Task", "Task should handle complex parameter types").
        mockScheduler:clearTasks().
    }).
    
    self:test("Delegate Return Value", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:returnDelegate(5).
        local task is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task:getClassName() = "Task", "Task should handle methods returning delegates").
        mockScheduler:clearTasks().
    }).
    
    self:test("Multiple Method Chain", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        testObj:singleParam(1).
        testObj:multiParams(1,2,3).
        testObj:defaultParams(1).
        
        self:assertEqual(
            mockScheduler:getScheduledTasks():length,
            3,
            "Method chain should create separate tasks"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("Static Property Access", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        self:assertEqual(
            testObj:staticValue:get(),
            100,
            "Static properties should remain accessible"
        ).
        self:assertEqual(
            mockScheduler:getScheduledTasks():length,
            0,
            "Static property access should not create tasks"
        ).
    }).
    
    self:test("Parameter Type Preservation", {
        local testObj is TestClass():new.
        local mockScheduler is createMockScheduler().
        set scheduler to mockScheduler.
        
        local testList is list(1,2,3).
        local testLex is lex("a", 1).
        
        testObj:complexParams(testList, testLex).
        local task is mockScheduler:getScheduledTasks()[0].
        
        self:assert(task:getClassName() = "Task", "Complex parameter types should be preserved").
        mockScheduler:clearTasks().
    }).
    
    return defineObject(self).
}

function TaskifiedWhileTests {
    local self is UnitTest():extend().
    self:showTestTimes().
    
    
    local mockScheduler is createMockScheduler().
    set scheduler to mockScheduler.
    
    self:test("While Loop Task Creation", {
        local function TestSimpleWhile {
            local self is TaskifiedObject():extend.
            
            local state is lex("counter", 0).
            self:public("state", state).
            
            self:while(
                { return state:counter < 3. },
                { set state:counter to state:counter + 1. }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestSimpleWhile():new.
        local tasks is mockScheduler:getScheduledTasks().
        
        self:assert(
            tasks:length > 0,
            "While loop should create tasks"
        ).
        
        local firstTask is tasks[0].
        self:assertEqual(
            firstTask:getClassName(),
            "Task",
            "While loop should create Task objects"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("While Loop Condition Check", {
        local function TestSimpleWhile {
            local self is TaskifiedObject():extend.
            
            local state is lex(
                "condition_met", true,
                "execution_count", 0
            ).
            self:public("state", state).
            
            self:while(
                { return state:condition_met. },
                { 
                    set state:execution_count to state:execution_count + 1.
                    set state:condition_met to false.
                }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestSimpleWhile():new.
        mockScheduler:executeAll().
        
        local finalState is testObj:state:get().
        self:assertEqual(
            finalState:execution_count,
            1,
            "While loop should execute until condition is false"
        ).
        self:assert(
            not finalState:condition_met,
            "Condition should be updated during execution"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("Complex While Loop State", {
        local function TestComplexWhile {
            local self is TaskifiedObject():extend.
            
            local state is lex(
                "counter", 0,
                "sum", 0,
                "numbers", list(1, 2, 3, 4, 5)
            ).
            self:public("state", state).
            
            self:while(
                { return state:counter < state:numbers:length. },
                {
                    set state:sum to state:sum + state:numbers[state:counter].
                    set state:counter to state:counter + 1.
                }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestComplexWhile():new.
        mockScheduler:executeAll().
        
        local finalState is testObj:state:get().
        self:assertEqual(
            finalState:sum,
            15,
            "Sum should accumulate all numbers"
        ).
        self:assertEqual(
            finalState:counter,
            5,
            "Counter should reach array length"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("Multiple While Loops", {
        local function TestMultipleWhiles {
            local self is TaskifiedObject():extend.
            
            local state1 is lex("value", 0).
            local state2 is lex("value", 10).
            self:public("state1", state1).
            self:public("state2", state2).
            
            self:while(
                { return state1:value < 3. },
                { set state1:value to state1:value + 1. }
            ).
            
            self:while(
                { return state2:value > 7. },
                { set state2:value to state2:value - 1. }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestMultipleWhiles():new.
        local tasks is mockScheduler:getScheduledTasks().
        
        self:assert(
            tasks:length >= 2,
            "Multiple while loops should create multiple tasks"
        ).
        
        mockScheduler:executeAll().
        
        self:assertEqual(
            testObj:state1:get():value,
            3,
            "First while loop should increment state"
        ).
        self:assertEqual(
            testObj:state2:get():value,
            7,
            "Second while loop should decrement state"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("While Loop with Nested Operations", {
        local function TestNestedWhile {
            local self is TaskifiedObject():extend.
            
            local state is lex(
                "outer", 0,
                "inner", 0,
                "total", 0
            ).
            self:public("state", state).
            
            self:while(
                { return state:outer < 2. },
                {
                    set state:inner to state:inner + 1.
                    set state:total to state:total + state:inner.
                    set state:outer to state:outer + 1.
                }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestNestedWhile():new.
        mockScheduler:executeAll().
        
        local finalState is testObj:state:get().
        self:assertEqual(
            finalState:outer,
            2,
            "Outer counter should reach limit"
        ).
        self:assertEqual(
            finalState:inner,
            2,
            "Inner counter should increment correctly"
        ).
        self:assertEqual(
            finalState:total,
            3,
            "Total should accumulate nested operations"
        ).
        mockScheduler:clearTasks().
    }).
    
    return defineObject(self).
}

function TaskifiedForTests {
    local self is UnitTest():extend().
    self:showTestTimes().
    
    local mockScheduler is createMockScheduler().
    set scheduler to mockScheduler.
    
    self:test("For Loop With Increment", {
        local function TestForLoop {
            local self is TaskifiedObject():extend.
            
            local state is lex(
                "counter", 0,
                "sum", 0
            ).
            self:public("state", state).
            
            self:for(
                { return state:counter < 5. },
                { set state:sum to state:sum + state:counter. },
                { set state:counter to state:counter + 1. }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestForLoop():new.
        mockScheduler:executeAll().
        
        local finalState is testObj:state:get().
        self:assertEqual(
            finalState:sum,
            10,  // 0 + 1 + 2 + 3 + 4
            "For loop should accumulate sum with increment"
        ).
        self:assertEqual(
            finalState:counter,
            5,
            "Counter should reach limit"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("For Loop Without Increment", {
        local function TestForLoop {
            local self is TaskifiedObject():extend.
            
            local state is lex(
                "value", 0,
                "iterations", 0
            ).
            self:public("state", state).
            
            self:for(
                { 
                    set state:value to state:value + 1.
                    return state:value < 3.
                },
                { set state:iterations to state:iterations + 1. }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestForLoop():new.
        mockScheduler:executeAll().
        
        local finalState is testObj:state:get().
        self:assertEqual(
            finalState:iterations,
            1,
            "For loop should execute correct number of times"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("For Loop Execution Order", {
        local function TestForLoop {
            local self is TaskifiedObject():extend.
            
            local state is lex(
                "counter", 0,
                "sequence", list()
            ).
            self:public("state", state).
            
            self:for(
                { return state:counter < 3. },
                { state:sequence:add("work" + state:counter). },
                { 
                    state:sequence:add("increment" + state:counter).
                    set state:counter to state:counter + 1.
                }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestForLoop():new.
        mockScheduler:executeAll().
        
        local finalState is testObj:state:get().
        self:assertEqual(
            finalState:sequence:join(","),
            "work0,increment0,work1,increment1,work2,increment2",
            "For loop should execute work then increment in correct order"
        ).
        mockScheduler:clearTasks().
    }).
    
    self:test("For Loop Early Termination", {
        local function TestForLoop {
            local self is TaskifiedObject():extend.
            
            local state is lex(
                "counter", 0,
                "terminated", false
            ).
            self:public("state", state).
            
            self:for(
                { 
                    if state:counter >= 2 {
                        set state:terminated to true.
                        return false.
                    }
                    return true.
                },
                { set state:counter to state:counter + 1. }
            ).
            
            return defineObject(self).
        }
        
        local testObj is TestForLoop():new.
        mockScheduler:executeAll().
        
        local finalState is testObj:state:get().
        self:assertEqual(
            finalState:counter,
            2,
            "For loop should terminate when condition returns false"
        ).
        self:assert(
            finalState:terminated,
            "Termination condition should be triggered"
        ).
        mockScheduler:clearTasks().
    }).
    
    return defineObject(self).
}

// Run the tests
local tests is TaskifiedWhileTests():new.
tests:runAll().
