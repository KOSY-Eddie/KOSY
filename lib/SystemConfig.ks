function SystemConfig{
    set self to Object():extend.

    local cfg is lex().
    local configPath is path(sysVars:sysConfigPath):combine("system.json").
    local sysVars is lex("DEBUG", false, "sysConfigPath","/KOSY/var/syscfg","logDir","/KOSY/var/log").

    if exists(configPath) {
        set cfg to readJSON(configPath).
    } else {
        // Create default config
        set cfg to lexicon(
            "clock", lexicon(
                "type", "kst"  // default
            )
            // Future system configs go here
        ).
        fwriter:write(lex(
            "filePath", configPath,
            "isJson", true
        )).
    }

    self:public("getConfig",{
        return cfg.
    }).

    self:public("changeConfig",{
        parameter newConfigIn.
        set cfg to newConfigIn:copy().
        sysEvents:emit("systemConfigChanged", systemConfig,"System").
        //commented out file write because KOS keeps throwing permission denied errors due to my NAS
        // fwriter:write(lex(
        //     "filePath", path(sysVars:sysConfigPath):combine("system.json"),
        //     "message", newConfigIn,
        //     "overwrite", true,
        //     "isJson", true
        // )).
    }).

    return defineObject(self).
}