runOncePath("/KOSY/lib/TaskifiedObject").

function DisplayBuffer {
    parameter widthIn, heightIn.
    local self is Object():extend.
    self:setClassName("DisplayBuffer").

    local width is widthIn.
    local height is heightIn.
    local buffer is "":padRight(width * height).
    local dirty is false.
    
    local function xy_to_bufferIdx {
        parameter x, y.

        return y * width + x.
    }

    self:public("place", {
        parameter replacement, posX, posY.

        local bufferIdx is xy_to_bufferIdx(posX, posY).
        local initalLen is buffer:length.
        set buffer to buffer:insert(bufferIdx, replacement).
        //print "removeIdxStart: " + (bufferIdx + replacement:length) + " replacementlen: " 
        //+ replacement:length + " bufferlen: " + buffer:length + " initLen: " + initalLen.
        if bufferIdx + replacement:length > initalLen
            set buffer to buffer:remove(initalLen,buffer:length - initalLen).
        else
            set buffer to buffer:remove(bufferIdx + replacement:length, replacement:length).
        set dirty to true.
    }).

    self:public("clearBuffer", {
        set buffer to "":padRight(buffer:length).
        set dirty to true.
    }).

    self:public("clearRegion", {
        parameter x, y, regionWidth, regionHeight.
        
        set regionWidth to min(regionWidth, width - x).
        set regionHeight to min(regionHeight, height - y).
        
        local emptyLine is "":padRight(regionWidth).
        from {local i is 0.} until i >= regionHeight step {set i to i + 1.} do {
            self:place(emptyLine, x, y + i).  // Fixed: using place instead of updateBuffer
        }.
    }).

    self:public("render", {
        if dirty {
            print buffer.
            set dirty to false.  // Reset dirty flag after rendering
        }.
    }).

    // local function autoRender {
    //     self:while({return true.},{
    //         self:render().
    //     },.05).
    // }

    //autoRender().
    
    return defineObject(self).
}
