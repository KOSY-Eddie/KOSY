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
runOncePath("/KOSY/lib/utils").
global NULL to lex().
local objectCounter is 0.

local function create_id {
    set objectCounter to objectCounter + 1.
    return objectCounter.
}

function isNull{
    parameter arg.

    return arg:isType("Lexicon") and arg = NULL.
}

function Object{
    if systemVars:DEBUG
        return DebugObject().
    return BaseObject().
}

function BaseObject{
    local self is lex().
    set self:new to lex().
    
    local object_id is create_id().
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

    self:public("toStr", {
        return self:getClassName() + "(" + self:getObjID() + ")".
    }).

    return defineObject(self).
}

function defineObject{
    parameter obj.
    return lex("new", obj:new, "extend", obj).
}

local function DebugObject {
    local self is BaseObject():extend.
    self:setClassName("DebugObject").
    
    local parent_public is self:public.
    local methodMetrics is lex().

    function initMethodMetrics {
        parameter methodName.
        if not methodMetrics:haskey(methodName) {
            set methodMetrics[methodName] to lex(
                "total_calls", 0,
                "total_time", 0,
                "max_time", 0,
                "min_time", 999999,
                "last_call_time", 0
            ).
        }
    }

    function updateMetrics {
        parameter methodName, duration.
        local metrics is methodMetrics[methodName].
        set metrics["total_calls"] to metrics["total_calls"] + 1.
        set metrics["total_time"] to metrics["total_time"] + duration.
        set metrics["last_call_time"] to duration.
        if duration > metrics["max_time"] {
            set metrics["max_time"] to duration.
        }
        if duration < metrics["min_time"] {
            set metrics["min_time"] to duration.
        }
    }

    function formatParam {
        parameter param.
        if param:isType("Lexicon") and param:hasKey("getClassName") {
            return param:toStr().
        }
        return param.
    }

    function formatParams {
        parameter paramList.
        local formattedParams is list().
        for param in paramList {
            formattedParams:add(formatParam(param)).
        }
        return formattedParams.
    }

    set self:public to {
        parameter name, maybeFunc.
        
        if maybeFunc:istype("delegate") {
            initMethodMetrics(name).
            
            local debugWrappedMethod is {
                local params is list().
                local isDone is false.
                
                until isDone {
                    parameter arg is NULL.
                    if isNull(arg) {
                        set isDone to true.
                    } else {
                        params:add(arg).
                    }
                }

                local startTime is time:seconds.
                local className is self:getClassName().
                local objId is self:getObjID().
                
                local dirPath is "/KOSY/var/log/debug/" + className.
                if not exists(dirPath) {
                    createDir(dirPath).
                }
                
                local logPath is dirPath + "/" + name + ".log".
                local formattedParams is formatParams(params).
                fWriter:queueWrite(logPath, "[" + startTime + "] ID:" + objId + " PARAMS:" + formattedParams).

                local boundFunc is maybeFunc.
                for param in params {
                    set boundFunc to boundFunc:bind(param).
                }
                
                local result is boundFunc().
                
                local endTime is time:seconds.
                local duration is endTime - startTime.
                updateMetrics(name, duration).
                
                fWriter:queueWrite(logPath, "END:" + endTime + " DURATION:" + duration + 
                    " TOTAL_CALLS:" + methodMetrics[name]["total_calls"] + 
                    " AVG_TIME:" + (methodMetrics[name]["total_time"] / methodMetrics[name]["total_calls"]) +
                    " MAX_TIME:" + methodMetrics[name]["max_time"] + 
                    " MIN_TIME:" + methodMetrics[name]["min_time"]).
                
                return result.
            }.
            
            return parent_public(name, debugWrappedMethod).
        } else {
            return parent_public(name, maybeFunc).
        }
    }.
    
    return defineObject(self).
}