// /KOSY/sys/TestApp/app.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").

function TestApp {
    local self is TaskifiedObject():extend.
    self:setClassName("TestApp").

    // Create and return the app's view
    self:publicS("createView", {
        local container is VContainerView():new.
        
        local title is TextView():new.
        title:setText("Test App").
        
        local description is TextView():new.
        description:setText("This is a test app for switching").
     
        local statusView is TextView():new.
        statusView:setText("Status: Running").
        
        container:addChild(title).
        container:addChild(description).
        container:addChild(statusView).
        
        return container.
    }).

    // Return the view for the app switcher
    return defineObject(self).
}

// Register with AppRegistry
appRegistry:register("TestApp", TestApp():new:createView).