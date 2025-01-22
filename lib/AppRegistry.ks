function AppRegistryObject {
    local self is Object():extend.
      self:setClassName("AppRegistry").
    
    // Public properties will automatically get getters/setters
    local apps is lex().
    
    // Public methods
    self:public("register", {
        parameter name, appLaunchFunc.
        print "Registering " + name.

        set apps[name] to appLaunchFunc.
    }).


    self:public("getApps",{return apps.}).

    self:public("buildAppRegistry", {
      parameter appDir.
      
      local appDirNames is getDirectories(appDir).
      local pwd is path().
      //local appPaths is list().
      
      for dir in appDirNames {
          local fullPath is appDir:combine(dir:name).
          cd(fullPath).
          
          for file in dir {
              local fn is file:name:split(".")[0].
              if fn = dir {
                  runOncePath(fullPath:combine(file:name)).
              }
          }
      }
      cd(pwd).
    }). 
    
    return defineObject(self).
}.
