function AppRegistryObject {
    local self is Object():extend.
      self:setClassName("AppRegistry").
    
    // Public properties will automatically get getters/setters
    self:public("apps", lexicon()).
    self:public("metadata", lexicon()).
    
    // Public methods
    self:public("register", {
        parameter name, appClass.
        print "Registering " + name.
        self:apps:add(name, appClass).
        if not self:metadata:haskey(name) {
            self:metadata:add(name, lexicon()).
        }.
    }).
    
    return defineObject(self).
}.
