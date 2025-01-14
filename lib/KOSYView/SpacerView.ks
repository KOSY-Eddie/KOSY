runOncePath("/KOSY/lib/KOSYView/View").
function SpacerView {
    local self is View():extend.
    self:setClassName("SpacerView").
    
    // Resize to fill available space
    self:public("fillSpace", {
        if not isNull(self:parent) {
            local parentWidth is self:parent:getWidth().
            local parentHeight is self:parent:getHeight().
            local usedWidth is 0.
            local spacing is self:parent:spacing.
            local childCount is self:parent:getChildren():length.
            
            // Calculate space used by siblings including spacing
            for child in self:parent:getChildren() {
                if not child:equals(self) {
                    set usedWidth to usedWidth + child:getWidth().
                }
            }
            
            // Account for spacing between elements
            if childCount > 1 {
                set usedWidth to usedWidth + (spacing * (childCount - 1)).
            }
            
            // Fill remaining space
            self:setWidth(max(0, parentWidth - usedWidth)).
            
            // Set height based on parent container type
            if self:parent:getClassName() = "HContainerView" {
                self:setHeight(parentHeight).
            } else {
                self:setHeight(spacing).
            }
        }
    }).

    
    return defineObject(self).
}
