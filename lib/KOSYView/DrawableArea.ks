function DrawableArea {
    parameter firstCol_, lastCol_, firstLine_, lastLine_.
    local self is Object():extend.
    
    self:public("firstCol", firstCol_).
    self:public("lastCol", lastCol_).
    self:public("firstLine", firstLine_).
    self:public("lastLine", lastLine_).
    
    self:public("width", {
        return lastCol_ - firstCol_ + 1.
    }).
    
    self:public("height", {
        return lastLine_ - firstLine_ + 1.
    }).
    
    return defineObject(self).
}
