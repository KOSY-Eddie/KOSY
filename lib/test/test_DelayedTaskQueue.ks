runoncepath("/KOSY/lib/DelayedTaskQueue.ks").
runOncePath("/KOSY/lib/test/unittest.ks").

clearscreen.
// Test task for our delayed queue
function TestTask {
    parameter name.
    local self is Object():extend.
    
    self:public("execute", {
        print "Executing " + name + " at " + time:seconds.
    }).
    
    // Add toString for better test output
    self:public("toString", {
        return "Task(" + name + ")".
    }).
    
    return defineObject(self).
}

function DelayedTaskQueueTests {
    local self is UnitTest():extend().
    
    // Helper function to create test tasks
    local function createTask {
        parameter name.
        return TestTask(name):new.
    }.
    
    // Basic Operations
    self:test("Basic Operations", {
        local taskList is DelayedTaskQueue():new.
        
        // Empty state tests
        self:assert(taskList:isEmpty(), "List starts empty").
        self:assertEqual(taskList:count(), 0, "Empty list count is 0").
        self:assertEqual(taskList:peek(), null, "Peek on empty list returns NONE").
        self:assertEqual(taskList:pop(), null, "Pop on empty list returns NONE").
        
        // Single task operations
        taskList:addTask(createTask("Task1"), 1).
        
        self:assert(not taskList:isEmpty(), "List not empty after add").
        self:assertEqual(taskList:count(), 1, "List count is 1").
        self:assertNotEqual(taskList:peek(), null, "Peek returns task wrapper").
        
        // Pop the task and verify empty state again
        local popped is taskList:pop().
        self:assertNotEqual(popped, null, "Popped task is not NONE").
        self:assert(taskList:isEmpty(), "List empty after pop").
    }).
    
    // Edge Cases
    self:test("Edge Cases", {
        local taskList is DelayedTaskQueue():new.
        
        // Add task with zero delay
        taskList:addTask(createTask("ZeroDelay"), 0).
        self:assertEqual(taskList:count(), 1, "Zero delay task added").
        
        // Add task with negative delay (should be ready immediately)
        taskList:addTask(createTask("NegativeDelay"), -1).
        self:assertEqual(taskList:count(), 2, "Negative delay task added").
        
        // Add task with very large delay
        taskList:addTask(createTask("LargeDelay"), 999999).
        self:assertEqual(taskList:count(), 3, "Large delay task added").
        
        // Check ready tasks
        local readyTasks is taskList:getReadyTasks().
        self:assertEqual(readyTasks:length, 2, "Zero and negative delay tasks ready immediately").
    }).
    
    // Sorting Tests
    self:test("Complex Sorting", {
        local taskList is DelayedTaskQueue():new.
        
        // Add multiple tasks with same delay
        taskList:addTask(createTask("Same1"), 1).
        taskList:addTask(createTask("Same2"), 1).
        taskList:addTask(createTask("Same3"), 1).
        
        // Add tasks with very close delays
        taskList:addTask(createTask("Close1"), 1.001).
        taskList:addTask(createTask("Close2"), 1.002).
        
        self:assertEqual(taskList:count(), 5, "All tasks added").
        
        // Check sorting order
        local prev is taskList:pop():executeAt:get().
        until taskList:isEmpty() {
            local current is taskList:pop():executeAt:get().
            self:assert(current >= prev, "Tasks properly sorted with close times").
            set prev to current.
        }.
    }).
    
    // Rapid Operations
    self:test("Rapid Operations", {
        local taskList is DelayedTaskQueue():new.
        
        // Rapidly add and remove tasks
        from { local i is 0. } until i >= 10 step { set i to i + 1. } do {
            taskList:addTask(createTask("Rapid" + i), 0.1 * i).
        }.
        
        self:assertEqual(taskList:count(), 10, "All rapid tasks added").
        
        // Rapid peek/pop operations
        from { local i is 0. } until i >= 5 step { set i to i + 1. } do {
            taskList:peek().
            taskList:pop().
        }.
        
        self:assertEqual(taskList:count(), 5, "Half of tasks removed").
    }).
    
    // Ready Task Timing
    self:test("Ready Task Timing", {
        local taskList is DelayedTaskQueue():new.
        local startTime is time:seconds.
        
        // Add tasks with more realistic delays
        taskList:addTask(createTask("Quick"), 1).    // 1 second
        taskList:addTask(createTask("Medium"), 2).   // 2 seconds
        taskList:addTask(createTask("Slow"), 3).     // 3 seconds
        
        // Initial check
        local readyTasks is taskList:getReadyTasks().
        self:assertEqual(readyTasks:length, 0, "No tasks ready immediately").
        
        // Check after first delay
        wait 1.1.  // Wait slightly longer than first delay
        set readyTasks to taskList:getReadyTasks().
        self:assertEqual(readyTasks:length, 1, "One task ready after ~1s").
        
        // Check after second delay
        wait 1.1.
        set readyTasks to taskList:getReadyTasks().
        self:assertEqual(readyTasks:length, 1, "One more task ready after ~2s").
        
        // Check after all should be ready
        wait 1.1.
        set readyTasks to taskList:getReadyTasks().
        self:assertEqual(readyTasks:length, 1, "Final task ready after ~3s").
    }).
    
    return defineObject(self).
}


// Run the tests
local runner is UnitTestRunner():new.
runner:addSuite(DelayedTaskQueueTests():new).
runner:runAll().
