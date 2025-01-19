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
        set text to ""+newText.
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
        parameter boundsIn, textHeight.
        
        if valign = "top" {
            return boundsIn:y.
        }
        if valign = "bottom" {
            return boundsIn:y + (boundsIn:height - textHeight).
        }
        // middle
        return boundsIn:y + floor((boundsIn:height - textHeight) / 2).
    }

    
    local function wrapText {
        parameter textIn, width.
        
        local lines is list().
        
        // Split into paragraphs first
        local paragraphs is textIn:split(char(10)).
        
        for para in paragraphs {
            // Handle empty paragraphs (double newlines)
            if para:length = 0 {
                lines:add("").
            } else {
                // Process paragraph
                local words is para:split(" ").
                local currentLine is "".
                
                for word in words {
                    // Handle words longer than width
                    if word:length > width {
                        // Add current line if not empty
                        if currentLine:length > 0 {
                            lines:add(currentLine).
                            set currentLine to "".
                        }
                        // Split long word
                        from { local i is 0. } until i >= word:length step { set i to i + width. } do {
                            local endIndex is min(i + width, word:length).
                            lines:add(word:substring(i, endIndex - i)).
                        }
                    } else {
                        // Normal word processing
                        if currentLine:length + word:length + 1 <= width or currentLine:length = 0 {
                            if currentLine:length > 0 {
                                set currentLine to currentLine + " " + word.
                            } else {
                                set currentLine to word.
                            }
                        } else {
                            lines:add(currentLine).
                            set currentLine to word.
                        }
                    }
                }
                
                // Add remaining line from paragraph
                if currentLine:length > 0 {
                    lines:add(currentLine).
                }
            }
        }
        
        return lines.
    }



    // Modified draw method
    self:public("draw", {
        parameter boundsIn.
        set cachedBounds to boundsIn.
        
        local lines is text:split(char(10)).

        local availableHeight is boundsIn:height.
        //local x is getAlignedx(boundsIn, text:length).
        local startY is getAlignedY(boundsIn, self:getContentSize(false)).
        
        // Clear the entire region first
        screenBuffer:clearRegion(boundsIn:x, boundsIn:y, boundsIn:width, boundsIn:height).
        //screenBuffer:place(text, x, y).
        
        //Draw only the lines that fit in the available height
        from { local i is 0. }
        until i >= lines:length or i >= availableHeight
        step { set i to i + 1. } do {
            local line is lines[i].
            local x is getAlignedX(boundsIn, line:length).
            local y is startY + i.
            
            if y >= boundsIn:y and y < boundsIn:y + boundsIn:height {
                screenBuffer:place(line, x, y).
            }
        }
    }).

    // Modified content size calculation
    self:public("getContentSize", {
        parameter isWidthDim.
        
        if isNull(cachedBounds) {
            return choose 1 if isWidthDim else 1.
        }
        
        local lines is wrapText(text, cachedBounds:width).
        if isWidthDim {
            local maxWidth is 0.
            for line in lines {
                set maxWidth to max(maxWidth, line:length).
            }
            return maxWidth.
        } else {
            return lines:length.
        }
    }).

    return defineObject(self).
}