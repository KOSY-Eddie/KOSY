runOncePath("unittest.ks").

// Ensure results directory exists
if not exists("results") {
    createDir("results").
}

function TestBase {
    local self is Object():extend.
    self:setClassName("TestBase").
    
    local baseValue is "base".
    
    // Public interface
    self:public("getValue", {
        return baseValue.
    }).
    
    self:public("setValue", {
        parameter newValue.
        return self:internalSetValue(newValue).
    }).
    
    // Protected implementation
    self:protected("internalSetValue", {
        parameter newValue.
        set baseValue to newValue.
        return "Base: " + baseValue.
    }).
    
    return defineObject(self).
}

function TestDerived {
    local self is TestBase():extend.
    self:setClassName("TestDerived").
    
    // Store parent's version before override
    local parentSetValue is self:setValue.
    
    // Override public interface
    self:public("setValue", {
        parameter newValue.
        return "Derived: " + parentSetValue(newValue + " from derived").
    }).
    
    return defineObject(self).
}

function TestDerivedDeeper {
    local self is TestDerived():extend.
    self:setClassName("TestDerivedDeeper").
    
    // Store parent's version before override
    local parentSetValue is self:setValue.
    
    self:public("setValue", {
        parameter newValue.
        return "Deepest: " + parentSetValue(newValue + " from deepest").
    }).
    
    return defineObject(self).
}



function ObjectTests {
    local self is UnitTest():extend.
    self:setClassName("Object System Tests").
    
    // Test basic object creation and identity
    self:test("Object Identity", {
        local obj1 is TestBase():new.
        local obj2 is TestBase():new.
        
        self:assertNotEqual(obj1:getObjID(), obj2:getObjID(), 
            "Objects should have unique IDs").
    }).
    
    // Test method overriding through inheritance chain
    self:test("Method Override Chain", {
        local base is TestBase():new.
        local derived is TestDerived():new.
        local deepest is TestDerivedDeeper():new.
        
        // Test base behavior
        local baseResult is base:setValue("test").
        self:assertEqual(baseResult, "Base: test", 
            "Base method works independently").
        self:assertEqual(base:getValue(), "test",
            "Base state updated correctly").
            
        // Test first-level override
        local derivedResult is derived:setValue("test").
        self:assertEqual(derivedResult, "Derived: Base: test from derived", 
            "Derived override properly chains to base").
        self:assertEqual(derived:getValue(), "test from derived",
            "Derived state updated correctly").
            
        // Test deepest override
        local deepResult is deepest:setValue("test").
        self:assertEqual(deepResult, 
            "Deepest: Derived: Base: test from deepest from derived", 
            "Deep override properly chains through all levels").
        self:assertEqual(deepest:getValue(), "test from deepest from derived",
            "Deepest state updated correctly").
            
        // Verify state isolation
        self:assertEqual(base:getValue(), "test",
            "Base instance maintains original state").
        self:assertEqual(derived:getValue(), "test from derived",
            "Derived instance maintains its state").
    }).
    
    // Test state isolation between instances
    self:test("State Isolation", {
        local instance1 is TestBase():new.
        local instance2 is TestBase():new.
        
        instance1:setValue("instance1").
        instance2:setValue("instance2").
        
        self:assertEqual(instance1:getValue(), "instance1",
            "Instance 1 maintains its state").
        self:assertEqual(instance2:getValue(), "instance2",
            "Instance 2 maintains its state").
    }).
    
    return defineObject(self).
}

// Run the tests
clearscreen.
print "Running Object System Tests".
print "==========================".

local runner is UnitTestRunner():new.
runner:addSuite(ObjectTests():new).
runner:runAll(true, "results/object_tests.txt").
