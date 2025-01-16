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
    
    return defineObject(self).
}.
