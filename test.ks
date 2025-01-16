runOncePath("/KOSY/lib/utils").
print "Scanning for Applications...".

local function getAppPaths{
    parameter appDir is path("/KOSY/sys").

    local appDirNames is getDirectories(appDir).
    local pwd is path().
    local appPaths is list().
    for dir in appDirNames{
        //print dir:lexicon():keys.
        //local appDir is systemAppPath:combine(dir).
        local fullPath is appDir:combine(dir:name).
        cd(fullPath).
        for file in dir{
            local fn is file:name:split(".")[0].
            if fn = dir {
                appPaths:add(fullPath:combine(file:name)).
            }
        }
    }
    cd(pwd).

    return appPaths.
}

print getAppPaths().