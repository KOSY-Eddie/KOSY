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

        return floor(y) * width + floor(x).
    }

    self:public("place", {
        parameter replacement, posX, posY.
        //dont even try to draw anything out of bounds
        if validateCoords(posX, posY)
            return 1.

        local bufferIdx is xy_to_bufferIdx(posX, posY).
        local initalLen is buffer:length.
        set buffer to buffer:insert(bufferIdx, replacement).
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

    local function validateCoords{
        parameter x, y.

        if(x > width - 1 or x < 0 or y > height - 1 or y < 0)
            return 1.
        return 0.
    }

    self:public("clearRegion", {
        parameter x, y, regionWidth, regionHeight.
        if validateCoords(x,y) or regionWidth <= 0 or regionHeight <=0
            return 1.

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

    self:public("getWidth",{return width.}).
    self:public("getHeight",{return height.}).
    
    return defineObject(self).
}
