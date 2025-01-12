// MenuItem - A horizontal container for menu options
function MenuItem {
    parameter drawableArea, menuText.
    local self is HContainerView():extend.
    self:setClassName("MenuItem").

    // Create cursor and text views
    local cursorView is TextView("  "):new.
    local textView_ is TextView(menuText):new.

    // Add views to container
    self:addChild(cursorView).
    self:addChild(textView_).

    // Method to set selected state
    self:public("setSelected", {
        parameter isSelected.
        cursorView:setText(choose "> " if isSelected else "  ").
    }).

    // Method to get/set text
    self:public("setText", {
        parameter newText.
        textView_:setText(newText).
        set self:height to textView_:getHeight().
    }).

    return defineObject(self).
}

function MenuView {
    local self is VContainerView():extend.
    self:setClassName("MenuView").

    local selectedIndex is 0.
    
    // Add a menu item
    self:public("addItem", {
        parameter text.
        local item is MenuItem(text):new.
        if self:getChildren():length = 0 {
            item:setSelected(true).
        }
        self:addChild(item).
    }).
    
    // Select next item
    self:public("selectNext", {
        local currentItem is self:getChildren()[selectedIndex].
        currentItem:setSelected(false).
        
        set selectedIndex to mod(selectedIndex + 1, self:getChildren():length).
        
        local nextItem is self:getChildren()[selectedIndex].
        nextItem:setSelected(true).
    }).
    
    // Select previous item
    self:public("selectPrevious", {
        local currentItem is self:getChildren()[selectedIndex].
        currentItem:setSelected(false).
        
        set selectedIndex to mod(selectedIndex - 1, self:getChildren():length).
        if selectedIndex < 0 {
            set selectedIndex to self:getChildren():length - 1.
        }
        
        local prevItem is self:getChildren()[selectedIndex].
        prevItem:setSelected(true).
    }).

    // Handle input when menu has focus
    local function handleInput {
        parameter inputType.
        if inputType = "UP" {
            self:selectPrevious().
        } else if inputType = "DOWN" {
            self:selectNext().
        } else if inputType = "CONFIRM" {
            // Handle selection
        }
    }
    
    // Register for input when menu gets focus
    self:public("focus", {
        INPUT:registerCallback(handleInput@).
    }).

    return defineObject(self).
}
