runOncePath("/KOSY/lib/TaskifiedObject.ks").

function View {
    local self is Object():extend.
    self:setClassName("View").
    
    self:protected("hasInput", false).
    self:protected("backcallBack", null).
    self:protected("nextCallBack", null).
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

    self:public("hasBackCallBack",{
        return not isNull(self:backCallBack).
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

        local w is screenBuffer:getWidth().
        local h is screenBuffer:getHeight().

        screenBuffer:clearBuffer().
        self:getRoot():draw(lex("debug", debugIn, "x", 0, "y", 0, "width", w, "height", h)).
    }).


    // self:public("setParentView", {
    //     parameter parentView.
    //     self:setBackCallback({
    //         local parentContainer is self:parent.
    //         parentView:setInput(true).
    //         parentContainer:switchContent(parentView).
    //         self:drawAll().
    //     }).
    // }).

    self:public("onLoad",{}).

    self:public("getInputStatus",{
        return self:hasInput.
    }).

    // Focus management
    self:public("setInput", {
        parameter inputIn.
        set self:hasInput to inputIn.
        
        if self:hasInput {
            // Register for input events
            inputhandler:unregisterCallback().
            inputhandler:registerCallback(self:handleInput@).
            
        } else {
            // Unregister when losing focus
            //inputhandler:unregisterCallback().
        }

    }).
    
    self:public("handleInput", {
        parameter key.

        if key = "unfocus" {
            self:setInput(false).
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