runOncePath("/KOSY/lib/KObject").

function SystemConfig{
    set self to BaseObject():extend.

    local cfg is lex("DEBUG", false, "sysConfigPath","/KOSY/var/syscfg","logDir","/KOSY/var/log").
    local configFn is path(cfg:sysConfigPath):combine("system.json").

    function loadCfgFromFile {
        if exists(configFn) {
        set cfg to readJSON(configFn).
        } else {
            // Create default config
            set cfg to lexicon(
                "clock", lexicon(
                    "type", "kst"  // default
                )
                // Future system configs go here
            ).
            fwriter:write(lex(
                "filePath", configFn,
                "isJson", true
            )).
        }
    }

    self:public("getConfigValue",{
        parameter configKeyIn, defaultValIn.

        if cfg:hasKey(configKeyIn)
            return cfg[configKeyIn].

        set cfg[configKeyIn] to defaultValIn.
        return defaultValIn.
    }).


    self:public("changeConfig",{
        parameter newConfigIn.
        set localCfg to newConfigIn:copy().
        for key in localCfg
            set cfg[key] to localCfg[key].

        sysEvents:emit("systemConfigChanged", systemConfig,"System").
        //commented out file write because KOS keeps throwing permission denied errors due to my NAS
        // fwriter:write(lex(
        //     "filePath", path(sysVars:sysConfigPath):combine("system.json"),
        //     "message", newConfigIn,
        //     "overwrite", true,
        //     "isJson", true
        // )).
    }).

    loadCfgFromFile().
    return defineObject(self).
}

global sysConfig is SystemConfig():new.