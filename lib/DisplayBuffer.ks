runOncePath("/KOSY/lib/KObject").

function DisplayBuffer {
    parameter widthIn, heightIn.
    local self is Object():extend.
    self:setClassName("DisplayBuffer").

    local width is widthIn.
    local height is heightIn.
    local buffer is "":padRight(width * height).
    
    local function xy_to_bufferIdx {
        parameter x, y.
        return y * self:width + x.
    }
    
    self:public("updateBuffer", {
        parameter replacement, posX, posY.
        
        local bufferIdx is xy_to_bufferIdx(posX, posY).
        set buffer to buffer:insert(bufferIdx, replacement).
        set buffer to buffer:remove(bufferIdx + replacement:length, replacement:length).
    }).
    
    self:public("clearBuffer", {
        set self:buffer to "":padRight(self:buffer:length).
    }).

    self:public("clearRegion", {
        parameter x, y, regionWidth, regionHeight.
        
        set regionWidth to min(regionWidth, width - x).
        set regionHeight to min(regionHeight, height - y).
        
        local emptyLine is "":padRight(regionWidth).
        from {local i is 0.} until i >= regionHeight step {set i to i + 1.} do {
            self:updateBuffer(emptyLine,x,y+i).
        }.
    }).

    self:public("render", {
        print self:buffer.
    }).
    
    return self.
}
