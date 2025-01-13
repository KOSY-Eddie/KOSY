// KOSY Debug Object System
// Author: Eddie Kerman
// Version: 1.0
//
// Enhanced debugging functionality for the KOSY Object System.
// Automatically wraps methods with timing, logging, and metrics collection.
// Used when systemVars:DEBUG is true.
//
// Features:
// - Method call logging with parameters
// - Execution time tracking
// - Method metrics collection:
//   * Total calls
//   * Total execution time
//   * Average execution time
//   * Maximum execution time
//   * Minimum execution time
//   * Last call duration
//
// Logging Format:
// Method calls are logged to: /KOSY/var/log/debug/<ClassName>/<MethodName>.log
// Each method call generates two log entries:
// 1. Call start: [timestamp] ID:<objectId> PARAMS:[param1, param2, ...]
// 2. Call end: END:<timestamp> DURATION:<time> TOTAL_CALLS:<count> AVG_TIME:<avg> MAX_TIME:<max> MIN_TIME:<min>
//
//
// Usage:
// 1. Enable debug mode:
//    set systemVars:DEBUG to true.
//
// 2. Create objects normally - debug wrapping is automatic:
//    function MyClass {
//        local self is Object():extend.  // Will return DebugObject when DEBUG is true
//        self:public("myMethod", {
//            parameter x.
//            // Method body
//        }).
//    }
//
// Notes:
// - Debug logging will impact performance
// - Metrics and log files are created per public method
// - Logs are written asynchronously via FileWriter
// - Due to scheduled file I/O and CPU limitations, 
//   log files may take time to appear on disk
//
// Dependencies:
// - KObject.ks
// - global filewriter


function DebugObject {
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