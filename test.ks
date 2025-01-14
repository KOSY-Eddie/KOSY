runOncePath("/KOSY/lib/utils").

local dirs is getDirectories("/KOSY/sys").

local pwd is path().
for dir in dirs{
    cd(dir).
    list files in fileList.
    for file in fileList
        if file = "app.ks"
            print "App found in " + dir + "!".
}

cd(pwd).