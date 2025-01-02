runOncePath("/KOSY/lib/utils.ks").



function MainMenu {
    parameter launchAppCallback.
    local self is View(systemVars:areas:menu):extend.
    
    self:setClassName("MainMenu").
    
    // Protected properties
    self:protected("menuItems", appRegistry:apps:get()).
    self:protected("launchApp", launchAppCallback).
    set self:isControllable to true.
    local activeApp is null.

    // self:public("giveFocus", {
    //     set self:focus to true.
    //     set self:currentSelection to 0.  // Reset to first menu item
    //     self:draw().
    // }).
    
    self:protected("drawMenuItem", {
        parameter text, isSelected, line.
        if line <= systemVars:areas:menu:lastLine {
            local cursor is "  ".
            if isSelected {
                set cursor to "> ".
            }.
            local menuText is (cursor + text).
            local menuWidth is systemVars:areas:menu:lastCol - systemVars:areas:menu:firstCol.
            // Ensure text fits in menu width
            if menuText:length > menuWidth {
                set menuText to menuText:substring(0, menuWidth -3) + "...".
            }.
            print menuText at (systemVars:areas:menu:firstCol, line).
        }.
    }).
    
    self:protected("draw", {
        //Calculate available space for menu items
        local menuArea is systemVars:areas:menu.
        local firstItemLine is menuArea:firstLine.

        for key in self:menuItems:keys {
            local itemLine is firstItemLine + self:menuItems:keys:find(key).
            if itemLine <= menuArea:lastLine - 2 {  // Leave space for instructions
                self:drawMenuItem(
                    key, 
                    self:menuItems:keys:find(key) = self:currentSelection, 
                    itemLine
                ).
            }.
        }.
        
        
        // Draw navigation help at bottom
        if menuArea:lastLine > firstItemLine + self:menuItems:length + 2 {
            local menuWidth is menuArea:lastCol - menuArea:firstCol + 1.
            local separator is padString("", menuWidth, "─").
            local helpText is "↑↓:Select  ENTER:Launch".
            
            // Center the help text
            local padding is (menuWidth - helpText:length) / 2.
            set helpText to padString("", padding, " ") + helpText.
            set helpText to padString(helpText, menuWidth, " ").
            
            print separator at (menuArea:firstCol, menuArea:lastLine - 1).
            print helpText at (menuArea:firstCol, menuArea:lastLine).
        }.

    }).

    local function activateSelectedApp{
        // Clear app area
        // for line in range(systemVars:areas:app:firstLine, systemVars:areas:app:lastLine) {
        //     print " ":padright(systemVars:areas:app:lastCol - systemVars:areas:app:firstCol) 
        //         at (systemVars:areas:app:firstCol, line).
        //}.
        if not isNull(activeApp){
            kout(activeApp:getClassName()).
            activeApp:deactivate().
        }
        local selectedKey is self:menuItems:keys[self:currentSelection].
        local selectedApp is self:menuItems[selectedKey].
        local newApp is selectedApp(systemVars:areas:app):new.
        set activeApp to newApp.
        newApp:activate().
        
    }
    
    self:protected("handleInput", {
        parameter input.
        
        if input = "UP" {
            if self:currentSelection > 0 {
                set self:currentSelection to self:currentSelection - 1.
            }.
        } else if input = "DOWN" {
            //print "down".
            if self:currentSelection < self:menuItems:length - 1 {
                set self:currentSelection to self:currentSelection + 1.
            }.
        }else if input = "RIGHT"{
            activateSelectedApp().
        } else if input = "CONFIRM" {
            activateSelectedApp().
        }.
        

        self:draw().
        
    }).

    
    // Initialize
    self:activate().
    
    return defineObject(self).
}.
