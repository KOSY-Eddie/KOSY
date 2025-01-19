runOncePath("/KOSY/lib/TaskifiedObject.ks").

function View {
    local self is Object():extend.
    self:setClassName("View").
    
    self:protected("isFocused", false).
    self:protected("backcallBack", {appMenu:setFocus(true).}).
    self:protected("nextCallBack", {}).
    self:public("spacing", 0).
    self:public("parent", null).
    self:public("expandX", true).
    self:public("expandY", true).
    self:public("manualWidth", -1).    // -1 indicates not set
    self:public("manualHeight", -1).   // -1 indicates not set
    self:public("name",null).
    self:public("visible", false).

    self:public("setBackCallback", {
        parameter callback.
        set self:backCallback to callback.
    }).

    self:public("setNextCallback", {
        parameter callback.
        set self:nextCallback to callback.
    }).

    self:public("resetManualSize", {
        set self:manualWidth to -1.
        set self:manualHeight to -1.
    }).

    //virtual method meant to be overriden
    self:public("getContentSize", {}).

    self:public("getContentWidth",{return self:getContentSize(true).}).
    self:public("getContentHeight",{return self:getContentSize(false).}).

    // Drawing
    self:public("draw", {
        parameter boundsIn. // lex("x", x, "y", y, "width", w, "height", h)
        if boundsIn:haskey("debug"){
            if boundsIn:debug
                self:debugBounds(boundsIn).
        }
        //Component does its work (drawing) with provided bounds
        return true.
    }).

    self:public("getRoot", {
        if isNull(self:parent) {
            return self.
        } else {
            return self:parent:getRoot().  
        }
    }).

    self:public("drawAll", {
        parameter debugIn is false.
        if debugIn {
            clearDebugDir().
        }.

        if not (defined screenBuffer) {
            print "screenBuffer not defined!".
            return.
        }

        local w is screenBuffer:getWidth().
        local h is screenBuffer:getHeight().
        if w = 0 or h = 0 {
            print "Invalid screen dimensions!".
            return.
        }

        screenBuffer:clearBuffer().
        self:getRoot():draw(lex("debug", debugIn, "x", 0, "y", 0, "width", w, "height", h)).
    }).


    self:public("setParentView", {
        parameter parentView.
        self:setBackCallback({
            local parentContainer is self:parent.
            parentContainer:switchContent(parentView). 
            parentView:setFocus(true).
            parentView:drawAll().
        }).
    }).

    // Focus management
    self:public("setFocus", {
        parameter focused.
        set self:isFocused to focused.
        
        if self:isFocused {
            // Register for input events
            inputhandler:registerCallback(self:handleInput@).
            
        } else {
            // Unregister when losing focus
            inputhandler:unregisterCallback().
        }

    }).
    
    self:public("hasFocus", {
        return self:isFocused.
    }).
    
    self:public("handleInput", {
        parameter key.

        if key = "unfocus" {
            self:setFocus(false).
        } else if key = "left" {
            self:backCallback().
        } else if key = "right" {
            self:nextCallback().
        } else if key = "cancel"{
            self:backCallback().
        }
    }).

    local function clearDebugDir {
        local debugDir is "/KOSY/var/debug/view".
        if not exists(debugDir)
            return.
        local pwd is path().
        cd(debugDir).
        // Get all files in directory
        list files in fileList.
        for file in fileList {
            if file:isfile {
                deletePath(file:name).
            }
        }.
        
        // Now delete the empty directory
        deletePath(debugDir).
        createDir(debugDir).
        cd(pwd).
    }.


    self:protected("debugBounds", {
        parameter boundsIn.
        
        local debugDir is "/KOSY/var/debug/view/".
        local filename is debugDir + self:getObjID() + ".txt".
        
        log "objID,class,parent,x,y,width,height" to filename.
        log self:getObjID() + "," +
            (choose self:getClassName() if isNull(self:name) else self:name + "(" + self:getClassName() + ")") + "," + 
            (choose self:parent:getObjID() if not isNull(self:parent) else "null") + "," +
            boundsIn:x + "," + 
            boundsIn:y + "," + 
            boundsIn:width + "," + 
            boundsIn:height to filename.
    }).


    
    return defineObject(self).
}