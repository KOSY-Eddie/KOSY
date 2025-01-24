// SolitaireView.ks
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").

function SolitaireView {
    local self is VContainerView():extend.
    self:setClassName("SolitaireView").
    
    // Create containers
    local scoreContainer is HContainerView():new.
    local topRowContainer is HContainerView():new.
    local foundationContainer is HContainerView():new.
    local tableauContainer is HContainerView():new.
    
    // Create text views
        local scoreView is TextView():new.
        local stockView is TextView():new.
        local wasteView is TextView():new.
        local foundationViews is list().
        local tableauViews is list().

    
    // Cursor position
    local row is 0.
    local col is 0.
    
    // Card formatting helpers
    local function formatHiddenCard {
        return "  |---|".
    }
    
    local function formatStackedCard {
        parameter value, suit.
        return "  |" + value:padRight(2) + suit + "|".
    }
    
    local function formatFullCard {
        parameter value, suit.
        return "  |---|" + char(10) + 
               "  |" + value:padRight(2) + suit + "|" + char(10) + 
               "  |___|".
    }
    
    // Mock data for testing layout
    local mockScore is 100.
    local mockStock is 24.
    local mockWaste is formatFullCard("10","H").
    local mockFoundation is list(
        formatFullCard("A","H"),
        formatFullCard("2","C"),
        formatFullCard("5","D"),
        formatFullCard("K","S")
    ).
    local mockTableau is list(
        list(formatHiddenCard(), formatStackedCard("A","H"), formatStackedCard("2","H"), formatFullCard("3","H")),
        list(formatHiddenCard(), formatStackedCard("Q","H"), formatFullCard("K","S")),
        list(formatHiddenCard(), formatHiddenCard(), formatStackedCard("7","S"), formatStackedCard("6","H"), 
             formatStackedCard("5","D"), formatFullCard("4","C")),
        list(formatHiddenCard(), formatStackedCard("J","D"), formatFullCard("Q","C")),
        list(formatHiddenCard(), formatHiddenCard(), formatStackedCard("8","C"), formatStackedCard("7","D"), 
             formatFullCard("6","H")),
        list(formatHiddenCard(), formatStackedCard("2","D"), formatFullCard("3","H")),
        list(formatFullCard("9","H"))
    ).
    
    // Add cursor to text
    local function addCursor {
        parameter text, isSelected.
        if isSelected {
            return "> " + text:substring(2, text:length - 2).
        }
        return text.
    }
    
    // Update display with current cursor position
    self:protected("updateDisplay", {
        // Score at top
        scoreView:setText("Score: " + mockScore).
        
        // Stock and Waste side by side
        local stockCard is choose formatFullCard("O"," ") if mockStock = 0 else formatFullCard("o"," ").
        stockView:setText("Stock" + char(10) + 
            addCursor(stockCard, row = 0 and col = 4)).
            
        wasteView:setText("Waste" + char(10) + 
            addCursor(mockWaste, row = 0 and col = 5)).
        
        // Foundation piles
        for i in range(4) {
            local cardText is addCursor(mockFoundation[i], row = 0 and col = i).
            foundationViews[i]:setText(cardText).
        }
        
        // Tableau piles
        for i in range(7) {
            local pileText is "".
            local pile is mockTableau[i].
            
            for cardIdx in range(pile:length) {
                if pileText:length > 0 {
                    set pileText to pileText + char(10).
                }
                set pileText to pileText + addCursor(pile[cardIdx], 
                    row > 0 and row-1 = cardIdx and col = i).
            }
            
            tableauViews[i]:setText(pileText).
        }
    }).
    
    // Initialize layout
    local function initializeLayout {
        // Score at top
        scoreContainer:addChild(scoreView).
        scoreContainer:expandY:set(false).
        
        // Stock and Waste side by side
        topRowContainer:addChild(foundationContainer).
        topRowContainer:addChild(stockView).
        topRowContainer:addChild(wasteView).
        
        // Foundation piles side by side
        for i in range(4) {
            local foundationView is TextView():new.
            foundationViews:add(foundationView).
            foundationContainer:addChild(foundationView).
        }
        
        // Tableau piles side by side
        for i in range(7) {
            local tableauView is TextView():new.
            tableauViews:add(tableauView).
            tableauContainer:addChild(tableauView).
        }
        
        // Add all containers to main view
        self:addChild(scoreContainer).
        self:addChild(topRowContainer).
        local spacerView is TextView():new.
        spacerView:expandY:set(false).
        self:addChild(spacerView).
        self:addChild(tableauContainer).
        topRowContainer:expandY:set(false).
        self:valign("top").
        
        self:updateDisplay().
    }.
    
    // Input handling
    local super_setInput is self:setInput.
    self:public("setInput", {
        parameter inputIn.
        super_setInput(inputIn).
        self:updateDisplay().
    }).
    
    self:public("handleInput", {
        parameter key.
        
        if key = "UNFOCUS" {
            self:setInput(false).
            return.
        }
        
        local oldRow is row.
        local oldCol is col.
        
        if key = "LEFT" {
            if row = 0 {
                // Top row: F1-F4, Stock, Waste
                set col to mod(col - 1 + 6, 6).
            } else {
                // Tableau row
                set col to mod(col - 1 + 7, 7).
            }
        } else if key = "RIGHT" {
            if row = 0 {
                // Top row: F1-F4, Stock, Waste
                set col to mod(col + 1, 6).
            } else {
                // Tableau row
                set col to mod(col + 1, 7).
            }
        } else if key = "UP" {
            if row > 0 {
                set row to row - 1.
                // Adjust column when moving up to top row (which has 6 spots vs 7)
                if row = 0 and col = 6 {
                    set col to 5.
                }
            }
        } else if key = "DOWN" {
            if row = 0 {
                set row to 1.
            } else {
                // Check if there are more cards in this tableau pile
                local pileHeight is mockTableau[col]:length.
                if row < pileHeight {
                    set row to row + 1.
                }
            }
        }
        
        if oldRow <> row or oldCol <> col {
            self:updateDisplay().
        }
    }).
    
    self:public("onLoad", {
        self:setInput(true).
    }).
    
    // Initialize on creation
    initializeLayout().
    
    return defineObject(self).
}
