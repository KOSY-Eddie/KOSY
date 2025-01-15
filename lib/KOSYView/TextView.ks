function TextView {
    local self is View():extend.
    self:setClassName("TextView").
    
    local text is "".
    local halign is "center".    // left, center, right
    local valign is "center".         // top, middle, bottom
    local cachedBounds is null.

    local function cachedDraw{
        if not isNull(cachedBounds)
            self:draw(cachedBounds).
    }
    
    self:public("getText", { return text. }).
    self:public("setText", {
        parameter newText.
        set text to newText.
        cachedDraw().
        //self:drawAll().
    }).
    
    self:public("halign", {
        parameter j.
        set halign to j.
        cachedDraw().
        //self:drawAll().
    }).
    
    self:public("valign", {
        parameter a.
        set valign to a.
        cachedDraw().
        //self:drawAll().
    }).

    self:public("getContentSize", {
        parameter isWidthDim.
        
        local textHeight is text:split(char(10)):length.
        local textWidth is ceiling(text:length/textHeight).
        if isWidthDim
            return textWidth.
        else 
            return textHeight.
    }).
    
    local function getBoundedText {
        parameter textIn, width.
        if textIn:length > width {
            return textIn:substring(0, width).
        }
        return textIn.
    }.
    
    local function getAlignedX {
        parameter boundsIn, textLength.
        if halign = "left" {
            return boundsIn:x.
        }
        if halign = "right" {
            return boundsIn:x + (boundsIn:width - textLength).
        }
        // center
        return boundsIn:x + floor((boundsIn:width -textLength)/ 2).
    }.
    
    local function getAlignedY {
        parameter boundsIn.
        if valign = "top" {
            return boundsIn:y.
        }
        if valign = "bottom" {
            return boundsIn:y + (boundsIn:height - 1).
        }
        // middle
        return boundsIn:y + floor(boundsIn:height / 2).
    }.
    
    self:public("draw", {
        parameter boundsIn.

        set cachedBounds to boundsIn.
       //print self:getClassName() + " drawing:".
        //print "  boundsIn: x:" + boundsIn:x + " y:" + boundsIn:y + " w:" + boundsIn:width + " h:" + boundsIn:height.
        local boundedText is getBoundedText(text, boundsIn:width).
        local x is getAlignedX(boundsIn, boundedText:length).
        local y is getAlignedY(boundsIn).
        
        //print "  final position: x:" + x + " y:" + y.
        screenBuffer:clearRegion(boundsIn:x, boundsIn:y, boundsIn:width, boundsIn:height).
        screenBuffer:place(boundedText, x, y).
    }).

    
    return defineObject(self).
}
