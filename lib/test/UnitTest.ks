runoncepath("/KOSY/lib/kobject.ks").

// KOSY Unit Testing Framework
// ==========================
// Simple unit testing framework for KOSY classes
// 
// Usage:
// ------
// function MyTests {
//     local self is UnitTest():extend().
//     
//     // Show individual test times (optional)
//     self:showTestTimes().
//     
//     self:test("Description", {
//         self:assert(1 + 1 = 2, "Math works").
//         self:assertEqual(someValue, expectedValue, "Values match").
//     }).
//     
//     return defineObject(self).
// }
// 
// local tests is MyTests():new.
// tests:runAll().
// UnitTest.ks - Base testing framework
// KOSY Unit Testing Framework
// ==========================
// Provides unit testing with detailed failure reporting
// and test suite management.

function UnitTest {
    local self is Object():extend.
    
    // Internal state
    local tests is list().
    local passCount is 0.
    local failCount is 0.
    local currentTest is "".
    local showTimes is false.
    local testTimes is lex().
    local totalTime is 0.
    local outputLog is "".
    local failureDetails is list().
    
    // Helper to both print and log
    self:protected("log", {
        parameter message.
        print message.
        set outputLog to outputLog + message + char(10).
    }).
    
    // Helper to record failure
    self:protected("recordFailure", {
        parameter message, expected is "", actual is "".
        local detail is lex(
            "test", currentTest,
            "message", message
        ).
        if expected <> "" {
            set detail:expected to expected.
            set detail:actual to actual.
        }
        failureDetails:add(detail).
    }).
    
    // Getters for runner
    self:public("getPassCount", {
        return passCount.
    }).
    
    self:public("getFailCount", {
        return failCount.
    }).
    
    self:public("getTotalTime", {
        return totalTime.
    }).
    
    self:public("getOutput", {
        return outputLog.
    }).
    
    // Display control
    self:public("showTestTimes", {
        set showTimes to true.
    }).
    
    // Test registration
    self:public("test", {
        parameter description, testFunc.
        tests:add(list(description, testFunc)).
    }).
    
    // Assertion methods
    self:public("assert", {
        parameter condition, message.
        if condition {
            set passCount to passCount + 1.
            self:log("  ✓ " + message).
        } else {
            set failCount to failCount + 1.
            self:log("  ✗ " + message).
            self:recordFailure(message).
        }
    }).
    
    self:public("assertEqual", {
        parameter actual, expected, message.
        if actual = expected {
            set passCount to passCount + 1.
            self:log("  ✓ " + message).
        } else {
            set failCount to failCount + 1.
            self:log("  ✗ " + message).
            self:log("    Expected: " + expected).
            self:log("    Got: " + actual).
            self:recordFailure(message, expected, actual).
        }
    }).
    
    self:public("assertNotEqual", {
        parameter actual, expected, message.
        if not (actual = expected) {
            set passCount to passCount + 1.
            self:log("  ✓ " + message).
        } else {
            set failCount to failCount + 1.
            self:log("  ✗ " + message + " (values should not be equal)").
            self:log("    Both values: " + actual).
            self:recordFailure(message + " (values should not be equal)", "different values", actual).
        }
    }).
    
    // Test runner
    self:public("runAll", {
        set passCount to 0.
        set failCount to 0.
        set totalTime to 0.
        set outputLog to "".
        set failureDetails to list().
        
        self:log("Running " + self:getClassName()).
        self:log("=============").
        
        for test in tests {
            set currentTest to test[0].
            self:log(currentTest + ":").
            
            local startTime is time:seconds.
            test[1]().
            
            local endTime is time:seconds.
            local testTime is endTime - startTime.
            
            set testTimes[currentTest] to testTime.
            set totalTime to totalTime + testTime.
            
            if showTimes {
                self:log("  Time: " + round(testTime, 3) + "s").
            }
            self:log("").
        }
        
        // Print summary
        self:log("Suite Summary").
        self:log("============").
        self:log("Total Tests: " + (passCount + failCount)).
        self:log("Passed: " + passCount).
        self:log("Failed: " + failCount).
        
        if failureDetails:length > 0 {
            self:log("").
            self:log("Failed Assertions:").
            self:log("------------------").
            for detail in failureDetails {
                self:log("In test: " + detail:test).
                self:log("  ✗ " + detail:message).
                if detail:haskey("expected") {
                    self:log("    Expected: " + detail:expected).
                    self:log("    Got: " + detail:actual).
                }
                self:log("").
            }
        }
        
        self:log("Suite Time: " + round(totalTime, 3) + "s").
        self:log("").
        
        return failCount = 0.
    }).
    
    return defineObject(self).
}

function UnitTestRunner {
    local self is Object():extend.
    
    local testSuites is list().
    local totalPass is 0.
    local totalFail is 0.
    local totalTime is 0.
    local outputLog is "".
    
    self:protected("log", {
        parameter message.
        print message.
        set outputLog to outputLog + message + char(10).
    }).
    
    // Add test suites to run
    self:public("addSuite", {
        parameter testSuite.
        testSuites:add(testSuite).
    }).
    
    // Run all test suites
    self:public("runAll", {
        parameter saveToFile is false.
        parameter fileName is "test_results.txt".
        
        set outputLog to "".
        self:log("Running All Test Suites").
        self:log("=====================").
        self:log("").
        
        for suite in testSuites {
            suite:runAll().
            set outputLog to outputLog + suite:getOutput().
            
            // Accumulate results
            set totalPass to totalPass + suite:getPassCount().
            set totalFail to totalFail + suite:getFailCount().
            set totalTime to totalTime + suite:getTotalTime().
        }
        
        if saveToFile {
            if exists(fileName) {
                deletePath(fileName).
                wait 0.1.
            }
            log outputLog to fileName.
            print "".
            print "Test results saved to " + fileName.
        }
        
        return totalFail = 0.
    }).
    
    return defineObject(self).
}
