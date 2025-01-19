// KOSY System Events
// Author: Eddie Kerman
// Version: 1.0
//
// Event bus for system-wide notifications, specifically designed for
// one-to-many communication patterns where multiple components need
// to react to system-level changes.
//
// Purpose:
// Provides a way for system components to be notified of important
// system-level changes without direct coupling. Best used for cases
// where multiple parts of the system need to react to the same event.
//
// Intended Usage:
// - System configuration changes
// - System-wide notifications
//
// Example:
// When system config changes:
// 1. Config component emits change event
// 2. FileWriter saves new config
// 3. UI updates to reflect changes
// 4. Other systems adapt to new settings
//
// Usage:
//    sysEvents:subscribe("configChangeRequested", {
//        parameter newConfig.
//        // React to config change
//    }, "ComponentName").
//
//    sysEvents:emit("configChangeRequested", configData, "ConfigManager").
//
// Notes:
// - Best for system-level changes affecting multiple components
// - Not intended for general message passing
// - Use direct calls for one-to-one communication
//
// Dependencies:
// - TaskifiedObject.ks (Base class)


runOncePath("/KOSY/lib/TaskifiedObject").

function SystemEvents {
    local self is TaskifiedObject():extend.
    self:setClassName("SystemEvents").
    
    local subscribers is lexicon().
    
    self:public("subscribe", {
        parameter eventName, callback, subscriberName is "Unknown".
        if not subscribers:haskey(eventName) {
            subscribers:add(eventName, list()).
        }
        subscribers[eventName]:add(callback).
    }).
    
    self:public("emit", {
        parameter eventName, data, emitterName is "Unknown".
        if subscribers:haskey(eventName) {
            for callback in subscribers[eventName] {
                callback(data).
            }
        }
    }).

    self:public("unsubscribe", {
        parameter eventName, callback, subscriberName is "Unknown".
        if subscribers:haskey(eventName) {
            local idx is subscribers[eventName]:find(callback).
            if idx >= 0 {
                subscribers[eventName]:remove(idx).
            }
        }
    }).
    
    return defineObject(self).
}
