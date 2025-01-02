// PhaseManager
// Author: Eddie Kerman
// Version: 0.1
//
// A class for managing flight phases and transitions.
// Extends TaskifiedObject to provide task-based phase management.
//
// Features:
// - Phase registration and tracking
// - Automatic phase transition checking
// - Task-based execution
// - Callback-driven phase completion
//
// Usage:
// local phaseManager is PhaseManager():new.
// phaseManager:registerPhase("LAUNCH", 
//     { return ship:altitude > 1000. },
//     { print "Launch started". },
//     { print "Launch complete". }
// ).

function PhaseManager {
    local self is TaskifiedObject():extend.
    self:setClassName("PhaseManager").
    
    local phases is lex().
    local currentPhase is "MENU".
    local isRunning is false.
    
    // Helper function to standardize phase names
    local function normalizePhaseName {
        parameter name.
        return name:tostring:toupper.
    }
    
    self:public("registerPhase", {
        parameter phaseName,
                  checkCondition,
                  onEnter is { },
                  onExit is { }.
        
        local normalizedName is normalizePhaseName(phaseName).
        
        // Use SET syntax to safely overwrite or add a new phase
        set phases[normalizedName] to lex(
            "check", checkCondition,
            "onEnter", onEnter,
            "onExit", onExit
        ).
    }).
    
    self:public("setPhase", {
        parameter newPhase, callback is { }.
        local normalizedNewPhase is normalizePhaseName(newPhase).
        
        if phases:haskey(normalizedNewPhase) {
            local normalizedCurrentPhase is normalizePhaseName(currentPhase).
            if phases:haskey(normalizedCurrentPhase) {
                phases[normalizedCurrentPhase]["onExit"]().
            }
            set currentPhase to normalizedNewPhase.
            phases[normalizedNewPhase]["onEnter"]().
            callback().
        }
    }).
    
    self:public("getCurrentPhase", {
        return currentPhase.
    }).
    
    return defineObject(self).
}
