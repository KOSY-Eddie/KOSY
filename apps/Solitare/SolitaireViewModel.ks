// SolitaireViewModel.ks
function SolitaireViewModel {
    local self is Object():extend.
    self:setClassName("SolitaireViewModel").
    
    self:protected("_model", NULL).
    self:protected("_view", NULL).
    self:protected("_selectedSource", lexicon("area", "", "pile", -1, "card", -1)).
    self:protected("_message", "").
    
    self:public("setModel", {
        parameter modelIn.
        set self:_model to modelIn.
    }).
    
    self:public("setView", {
        parameter viewIn.
        set self:_view to viewIn.
        viewIn:setViewModel(self).
    }).
    
    // Convert card data to display format
    self:protected("formatCard", {
        parameter card.
        if isNull(card) return "  ".
        if not card:isFaceUp() return "##".
        
        local suits is lexicon(
            "Hearts", "♥",
            "Diamonds", "♦",
            "Clubs", "♣",
            "Spades", "♠"
        ).
        
        local values is lexicon(
            1, "A",
            11, "J",
            12, "Q",
            13, "K"
        ).
        
        local valueStr is choose values[card:getValue()] if values:haskey(card:getValue()) else card:getValue():tostring.
        return valueStr + suits[card:getSuit()].
    }).
    
    // Get display data for view
    self:public("getDisplayState", {
        local modelState is self:_model:getGameState().
        
        // Format tableau piles
        local tableauDisplay is list().
        for pile in modelState:tableau {
            local pileDisplay is list().
            for card in pile {
                pileDisplay:add(self:formatCard(card)).
            }
            tableauDisplay:add(pileDisplay).
        }
        
        // Format foundation piles
        local foundationDisplay is list().
        for pile in modelState:foundation {
            if pile:empty {
                foundationDisplay:add("[]").
            } else {
                foundationDisplay:add(self:formatCard(pile[pile:length - 1])).
            }
        }
        
        // Format waste pile top card
        local wasteDisplay is choose self:formatCard(modelState:waste[modelState:waste:length - 1]) if modelState:waste:length > 0 else "[]".
        
        return lexicon(
            "tableau", tableauDisplay,
            "foundation", foundationDisplay,
            "stockCount", modelState:stock:length,
            "wasteTop", wasteDisplay,
            "score", modelState:score,
            "message", self:_message
        ).
    }).
    
    // Get height of a specific tableau pile for view navigation
    self:public("getPileHeight", {
        parameter pileIndex.
        return self:_model:getGameState():tableau[pileIndex]:length.
    }).
    
    // Handle card selection and movement
    self:public("selectCard", {
        parameter area, pileIndex, cardIndex.
        
        if self:_selectedSource:area = "" {
            // First selection - store source
            if self:_model:canSelectCard(area, pileIndex, cardIndex) {
                set self:_selectedSource to lexicon(
                    "area", area,
                    "pile", pileIndex,
                    "card", cardIndex
                ).
                set self:_message to "Selected card. Choose destination.".
            } else {
                set self:_message to "Cannot select that card.".
            }
        } else {
            // Second selection - attempt move
            if self:_model:moveCard(
                self:_selectedSource:area,
                self:_selectedSource:pile,
                self:_selectedSource:card,
                area,
                pileIndex
            ) {
                set self:_message to "Move successful.".
            } else {
                set self:_message to "Invalid move.".
            }
            // Clear selection
            set self:_selectedSource to lexicon("area", "", "pile", -1, "card", -1).
        }
    }).
    
    // Cancel current selection
    self:public("cancelSelection", {
        set self:_selectedSource to lexicon("area", "", "pile", -1, "card", -1).
        set self:_message to "Selection cancelled.".
    }).
    
    // Draw card from stock to waste
    self:public("drawCard", {
        if self:_model:drawCard() {
            set self:_message to "Drew card from stock.".
        } else {
            set self:_message to "No cards in stock.".
        }
    }).
    
    // Start new game
    self:public("newGame", {
        self:_model:newGame().
        set self:_message to "New game started.".
        set self:_selectedSource to lexicon("area", "", "pile", -1, "card", -1).
    }).
    
    return defineObject(self).
}
