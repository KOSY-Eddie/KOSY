// SolitaireModel.ks
function CardObject {
    parameter suitIn, valueIn.
    local self is Object():extend.
    self:setClassName("CardObject").
    
    self:protected("_suit", "").
    self:protected("_value", 0).
    self:protected("_faceUp", false).
    self:protected("_color", "").  // "red" or "black"

    set self:_suit to suitIn.
    set self:_value to valueIn.
    set self:_color to choose "red" if (suitIn = "Hearts" or suitIn = "Diamonds") else "black".

    
    self:public("getSuit", { return self:_suit. }).
    self:public("getValue", { return self:_value. }).
    self:public("getColor", { return self:_color. }).
    self:public("isFaceUp", { return self:_faceUp. }).
    self:public("flip", { set self:_faceUp to not self:_faceUp. }).
    self:public("setFaceUp", { parameter state. set self:_faceUp to state. }).
    
    return defineObject(self).
}

function SolitaireModel {
    local self is TaskifiedObject():extend.
    self:setClassName("SolitaireModel").
    
    // Game state
    self:protected("_deck", list()).
    self:protected("_tableau", list()).    // 7 piles
    self:protected("_foundation", list()). // 4 piles (one per suit)
    self:protected("_waste", list()).
    self:protected("_stock", list()).
    self:protected("_score", 0).
    
    // Initialize new game
    self:public("newGame", {
        // Clear all piles
        self:_tableau:clear().
        self:_foundation:clear().
        self:_waste:clear().
        self:_stock:clear().
        set self:_score to 0.
        
        self:initializeDeck().
        self:dealCards().
    }).
    
    // Create and shuffle deck
    self:protected("initializeDeck", {
        self:_deck:clear().
        local suits is list("Hearts", "Diamonds", "Clubs", "Spades").
        for suit in suits {
            for value in range(1, 14) {
                self:_deck:add(CardObject(suit, value):new).
            }
        }
        self:shuffleDeck().
    }).
    
    // Fisher-Yates shuffle
    self:protected("shuffleDeck", {
        local n is self:_deck:length.
        local newDeck is list().
        
        // First copy all cards to new deck
        for card in self:_deck {
            newDeck:add(card).
        }
        
        // Now do the shuffle on the new deck
        from {local i is n - 1.} until i = 0 step {set i to i - 1.} do {
            local j is round(random() * i).
            local temp is newDeck[i].
            set newDeck[i] to newDeck[j].
            set newDeck[j] to temp.
        }
        
        // Replace old deck with new shuffled deck
        self:_deck:clear().
        for card in newDeck {
            self:_deck:add(card).
        }
    }).



    
    // Deal initial tableau
    self:protected("dealCards", {
        // Deal tableau
        for i in range(7) {
            local pile is list().
            for j in range(i + 1) {
                //pop operation
                local card is self:_deck[self:_deck:length - 1].
                self:_deck:remove(self:_deck:length - 1).   
                if j = i {
                    card:setFaceUp(true).
                }
                pile:add(card).
            }
            self:_tableau:add(pile).
        }
        
        // Initialize empty foundation piles
        for i in range(4) {
            self:_foundation:add(list()).
        }
        
        // Rest goes to stock
        set self:_stock to self:_deck:copy().
        self:_deck:clear().
    }).
    
    // Draw card from stock to waste
    self:publicS("drawCard", {
        if self:_stock:empty {
            if self:_waste:empty {
                return false.
            }
            // Flip waste back to stock
            for card in self:_waste:reversed {
                card:setFaceUp(false).
                self:_stock:add(card).
            }
            self:_waste:clear().
            return true.
        }
        
        local card is self:_deck[self:_deck:length - 1].
        self:_deck:remove(self:_deck:length - 1).
        card:setFaceUp(true).
        self:_waste:add(card).
        return true.
    }).
    
    // Validate if card can be selected
    self:publicS("canSelectCard", {
        parameter area, pileIndex, cardIndex.
        
        if area = "tableau" {
            if pileIndex < 0 or pileIndex >= self:_tableau:length return false.
            local pile is self:_tableau[pileIndex].
            if cardIndex < 0 or cardIndex >= pile:length return false.
            return pile[cardIndex]:isFaceUp().
        }
        
        if area = "foundation" {
            if pileIndex < 0 or pileIndex >= self:_foundation:length return false.
            local pile is self:_foundation[pileIndex].
            return not pile:empty and cardIndex = pile:length - 1.
        }
        
        if area = "waste" {
            return not self:_waste:empty and cardIndex = self:_waste:length - 1.
        }
        
        return false.
    }).
    
    // Check if card can be moved to foundation
    self:protected("canMoveToFoundation", {
        parameter card, foundationIndex.
        
        local targetPile is self:_foundation[foundationIndex].
        if targetPile:empty {
            return card:getValue() = 1.  // Only Aces can start foundation piles
        }
        
        local topCard is targetPile[targetPile:length - 1].
        return card:getSuit() = topCard:getSuit() and 
               card:getValue() = topCard:getValue() + 1.
    }).
    
    // Check if card can be moved to tableau
    self:protected("canMoveToTableau", {
        parameter card, tableauIndex.
        
        local targetPile is self:_tableau[tableauIndex].
        if targetPile:empty {
            return card:getValue() = 13.  // Only Kings can start empty tableau piles
        }
        
        local topCard is targetPile[targetPile:length - 1].
        return topCard:isFaceUp() and
               card:getColor() <> topCard:getColor() and
               card:getValue() = topCard:getValue() - 1.
    }).
    
    // Move card between piles
    self:publicS("moveCard", {
        parameter fromArea, fromPile, fromCard,
                  toArea, toPile.
        
        local sourceCard is 0.
        local sourcePile is 0.
        local cardsToMove is list().
        
        // Get source cards
        if fromArea = "tableau" {
            set sourcePile to self:_tableau[fromPile].
            for i in range(fromCard, sourcePile:length) {
                cardsToMove:add(sourcePile[i]).
            }
        } else if fromArea = "foundation" {
            set sourcePile to self:_foundation[fromPile].
            cardsToMove:add(sourcePile[sourcePile:length - 1]).
        } else if fromArea = "waste" {
            set sourcePile to self:_waste.
            cardsToMove:add(sourcePile[sourcePile:length - 1]).
        } else {
            return false.
        }
        
        // Validate move
        if toArea = "foundation" {
            if cardsToMove:length > 1 return false.
            if not self:canMoveToFoundation(cardsToMove[0], toPile) return false.
            
            // Move card
            self:_foundation[toPile]:add(cardsToMove[0]).
            sourcePile:remove(sourcePile:length - 1).
            
            // Reveal next card if from tableau
            if fromArea = "tableau" and not sourcePile:empty {
                sourcePile[sourcePile:length - 1]:setFaceUp(true).
            }
            
            set self:_score to self:_score + 10.
            return true.
        }
        
        if toArea = "tableau" {
            if not self:canMoveToTableau(cardsToMove[0], toPile) return false.
            
            // Move cards
            for card in cardsToMove {
                self:_tableau[toPile]:add(card).
                sourcePile:remove(sourcePile:length - 1).
            }
            
            // Reveal next card if from tableau
            if fromArea = "tableau" and not sourcePile:empty {
                sourcePile[sourcePile:length - 1]:setFaceUp(true).
            }
            
            return true.
        }
        
        return false.
    }).
    
    // Get current game state
    self:publicS("getGameState", {
        return lexicon(
            "tableau", self:_tableau:copy(),
            "foundation", self:_foundation:copy(),
            "waste", self:_waste:copy(),
            "stock", self:_stock:copy(),
            "score", self:_score
        ).
    }).
    
    // Check for win condition
    self:publicS("checkWin", {
        for pile in self:_foundation {
            if pile:length <> 13 return false.
        }
        return true.
    }).
    
    return defineObject(self).
}
