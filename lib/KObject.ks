// KOSY Object System Base
// Author: Eddie Kerman
// Version: 1.1
//
// A base implementation for object-oriented programming in KOS.
// Provides core functionality for creating objects with proper encapsulation.
//
// Core Features:
// - Object creation and inheritance
// - Public/Protected member management
// - NULL object pattern for safe null checks
// - Debug integration when systemVars:DEBUG is true
//
// Usage:
// 1. Create a new class by extending Object:
//    function MyClass {
//        local self is Object():extend.
//        self:setClassName("MyClass").
//
// 2. Define protected members (accessible only within class hierarchy):
//    self:protected("_internalValue", 42).
//    self:protected("_helper", {
//        // Internal method
//    }).
//
// 3. Define public methods and properties:
//    self:public("calculate", {
//        parameter input.
//        return input + self["_internalValue"].
//    }).
//
//    self:public("value", 10).  // Creates accessor property
//
// 4. Create and use instances:
//    local myObj is MyClass():new.
//    myObj:value:set(20).           // Set property
//    print myObj:value:get().       // Get property
//    print myObj:calculate(10).     // Call method
//
// 5. Use NULL object pattern:
//    if not isNull(someObject) {
//        // Safe to use object
//    }
//
// Notes:
// - Public properties require get()/set() after instantiation
// - Data members are directly accessible within class
// - Each object has a unique numeric ID for comparison
// - Legacy GUID generation available but not used by default
// - Debug features active when systemVars:DEBUG is true
//
// Dependencies:
// - utils.ks
// - DebugObject.ks

runOncePath("/KOSY/lib/utils").
runOncePath("/KOSY/lib/DebugObject").

global NULL to lex().
local objectCounter is 0.

local function create_id {
    local newId is objectCounter.
    set objectCounter to objectCounter + 1.
    return newId.
}

function isNull{
    parameter arg.

    return arg:isType("Lexicon") and arg = NULL.
}

function Object{
    if sysVars:DEBUG
        return DebugObject().
    return BaseObject().
}

function BaseObject{
    local self is lex().
    set self:new to lex().
    
    local object_id is create_id().
    local class_name is "Object".
    local full_name is "Object".

    self:add("public", setAccessors@).
    self:add("protected", {parameter name, maybeFunc. set self[name] to maybeFunc.}).


    self:public("equals", {
        parameter other.

        if other:isType("Lexicon") and other:haskey("getObjID"){
            return other:getObjID() = object_id.
        }

        return false.
    }).

    self:protected("setClassName", {
        parameter name.
        set class_name to name.
        set full_name to full_name + "." + name.
    }).

    self:public("getClassName", {
        return class_name.
    }).

    self:public("getFullClassName", {
        return full_name.
    }).

    self:public("getObjID", {
        return object_id.
    }).

    function setAccessors{
        parameter name, maybeFunc.

        if maybeFunc:isType("delegate"){
            set self[name] to maybeFunc.
            set self["new"][name] to self[name]@.
        }else{
            setValueAcessor(name, maybeFunc).
        }
    }

    function setValueAcessor{
        parameter name, value.

        set self[name] to value.
        set self["new"][name] to lex().
        set self["new"][name]:get to {return self[name].}.
        set self["new"][name]:set to {
            parameter newVal.

            set self[name] to newVal.
        }.
    }

    self:public("toStr", {
        return self:getClassName() + "(" + self:getObjID() + ")".
    }).

    return defineObject(self).
}

function defineObject{
    parameter obj.
    return lex("new", obj:new, "extend", obj).
}
