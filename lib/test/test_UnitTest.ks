runOncePath("/KOSY/lib/test/UnitTest.ks").
// First ensure results directory exists
if not exists("results") {
    createDir("results").
}

function UnitTestTests {
    local self is UnitTest():extend.
    self:setClassName("UnitTest Framework Tests").
    
    // Test basic assertions
    self:test("Basic Assertions", {
        // Test assert
        self:assert(true, "True assertion should pass").
        self:assertEqual(self:getPassCount(), 1, "Pass count should increment").
        self:assertEqual(self:getFailCount(), 0, "Fail count should not increment").
        
        // Test assertEqual
        self:assertEqual(5, 5, "Equal values should pass").
        self:assertEqual("test", "test", "Equal strings should pass").
        
        // Test assertNotEqual
        self:assertNotEqual(5, 6, "Different values should pass").
        self:assertNotEqual("test", "different", "Different strings should pass").
    }).
    
    // Test timing functionality
    self:test("Timing Tests", {
        local startTime is time:seconds.
        wait 0.5.
        local endTime is time:seconds.
        local elapsed is endTime - startTime.
        
        self:assert(elapsed >= 0.5, "Time tracking should work").
        self:assert(self:getTotalTime() > 0, "Total time should accumulate").
    }).
    
    // Test test registration
    self:test("Test Registration", {
        local testInstance is UnitTest():new.
        testInstance:test("Test 1", { return true. }).
        testInstance:test("Test 2", { return true. }).
        
        testInstance:runAll().
        self:assertEqual(testInstance:getPassCount(), 0, "Pass count should start at 0").
    }).
    
    return defineObject(self).
}

function RunnerTests {
    local self is UnitTest():extend.
    self:setClassName("TestRunner Tests").
    
    // Test suite management
    self:test("Suite Management", {
        local runner is UnitTestRunner():new.
        
        // Add suites
        runner:addSuite(UnitTest():new).
        runner:addSuite(UnitTest():new).
        
        // Run with file output
        local result is runner:runAll(true, "results/runner_test_output.txt").
        
        // Verify file was created
        self:assert(exists("results/runner_test_output.txt"), "Output file should be created").
    }).
    
    // Test failed test tracking
    self:test("Failed Test Tracking", {
        local failingSuite is UnitTest():new.
        failingSuite:test("Failing Test", {
            failingSuite:assert(false, "This should fail").
        }).
        
        local runner is UnitTestRunner():new.
        runner:addSuite(failingSuite).
        local result is runner:runAll().
        
        self:assert(not result, "Runner should return false for failed tests").
    }).
    
    return defineObject(self).
}

function TestFrameworkTests {
    local self is UnitTest():extend.
    self:setClassName("Framework Integration Tests").
    
    self:test("Full Integration", {
        // Create a test hierarchy
        local runner is UnitTestRunner():new.
        runner:addSuite(UnitTestTests():new).
        runner:addSuite(RunnerTests():new).
        
        // Run with output
        local result is runner:runAll(true, "results/integration_test.txt").
        
        // Verify results
        self:assert(exists("results/integration_test.txt"), "Integration test file should exist").
    }).
    
    return defineObject(self).
}

// Run all framework tests
clearscreen.
print "Running Framework Tests".
print "======================".

local frameworkRunner is UnitTestRunner():new.
frameworkRunner:addSuite(UnitTestTests():new).
frameworkRunner:addSuite(RunnerTests():new).
frameworkRunner:addSuite(TestFrameworkTests():new).
frameworkRunner:runAll(true, "results/framework_test_results.txt").
