function MainMenu {
    parameter launchAppCallback.
    local self is View(systemVars:areas:menu):extend.
    
    self:setClassName("MainMenu").
    
    // Protected properties
    self:protected("menuItems", appRegistry:apps:get()).
    self:protected("launchApp", launchAppCallback).
    set self:isControllable to true.
    
    self:protected("drawMenuItem", {
        parameter text, isSelected, line.
        if line <= systemVars:areas:menu:lastLine {
            local cursor is "  ".
            if isSelected {  // Modified cursor condition
                set cursor to "> ".
            }.
            local menuText is (cursor + text).
            local menuWidth is systemVars:areas:menu:lastCol - systemVars:areas:menu:firstCol.
            if menuText:length > menuWidth {
                set menuText to menuText:substring(0, menuWidth -3) + "...".
            }.
            print menuText at (systemVars:areas:menu:firstCol, line).
        }.
    }).
    
    // Rest of the draw function remains the same
    self:protected("draw", {
        
        local menuArea is systemVars:areas:menu.
        local firstItemLine is menuArea:firstLine.

        for key in self:menuItems:keys {
            local itemLine is firstItemLine + self:menuItems:keys:find(key).
            if itemLine <= menuArea:lastLine - 2 {
                self:drawMenuItem(
                    key, 
                    self:menuItems:keys:find(key) = self:currentSelection, 
                    itemLine
                ).
            }.
        }.
        
        if menuArea:lastLine > firstItemLine + self:menuItems:length + 2 {
            local menuWidth is menuArea:lastCol - menuArea:firstCol + 1.
            local separator is padString("", menuWidth, "─").
            local helpText is "↑↓:Select  ENTER:Launch".
            
            local padding is (menuWidth - helpText:length) / 2.
            set helpText to padString("", padding, " ") + helpText.
            set helpText to padString(helpText, menuWidth, " ").
            
            print separator at (menuArea:firstCol, menuArea:lastLine - 1).
            print helpText at (menuArea:firstCol, menuArea:lastLine).
        }.
    }).

    local function activateSelectedApp{
        
        local selectedKey is self:menuItems:keys[self:currentSelection].
        local selectedApp is self:menuItems[selectedKey].
        local newApp is selectedApp(systemVars:areas:app):new.
 
        newApp:activate().
    }
    
    self:protected("handleInput", {
        parameter input.
        if input = "UP" {
            //set self:showCursor to true.  // Show cursor during navigation
            if self:currentSelection > 0 {
                set self:currentSelection to self:currentSelection - 1.
            }.
        } else if input = "DOWN" {
            //set self:showCursor to true.  // Show cursor during navigation
            if self:currentSelection < self:menuItems:length - 1 {
                set self:currentSelection to self:currentSelection + 1.
            }.
        }else if input = "RIGHT"{
            set showCursor to false.
            activateSelectedApp().
        } else if input = "CONFIRM" {
            activateSelectedApp().
        }.
        
        self:draw().
    }).
    
    
    return defineObject(self).
}.
