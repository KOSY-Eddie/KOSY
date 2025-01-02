// KOSY Object System Base
// Author: Eddie Kerman
// Version: 1.0
//
// A base implementation for object-oriented programming in KOS.
// Provides core functionality for creating objects with proper encapsulation.
//
// Usage:
// 1. Create a new class by extending Object:
//    function MyClass {
//        local self is Object():extend.
//
// 2. Define public methods and properties:
//    self:public("myMethod", {
//        parameter input.
//        // Method body
//    }).
//
//    self:public("myProperty", someValue).
//
// 3. Access properties in instantiated objects:
//    local myObj is MyClass():new.
//    myObj:myProperty:get().     // Get the value
//    myObj:myProperty:set(10).   // Set the value
//
// Notes:
// - All public properties must be accessed using get() and set() after instantiation
// - Protected members are only accessible within the class (including inherited calsses)
// - Each object instance has a unique identifier (GUID)
// - Objects can be compared for equality using equals()
//
// Dependencies:
// - None

global null to "NONE".

function isNull{
    parameter p.

    return p:isType("String") and p = null.
}

function Object{
    local self is lex().
    set self:new to lex().
    
    local object_id is create_guid().
    local class_name is "Object".

    self:add("public", setAccessors@).
    self:add("protected", {parameter name, maybeFunc. set self[name] to maybeFunc.}).

    function create_guid {
        local part_index is floor(random() * ship:parts:length).
        local random_part is ship:parts[part_index].
        
        local part_component is round(random_part:uid:substring(0, 4):tonumber() * random() * 10000).
        local time_component is round(time:seconds * random() * 10000).
        local random_component is round(random() * 10000 * random()).
        
        return part_component + "-" + time_component + "-" + random_component.
    }

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
    }).

    self:public("getClassName", {
        return class_name.
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

    return defineObject(self).
}

function defineObject{
    parameter obj.
    return lex("new", obj:new, "extend", obj).
}