runoncepath("SolitaireModel").
runOncePath("SolitaireViewModel").
runOncePath("SolitaireView").

function SolitaireApp {
    local self is Application():extend.
    self:setClassName("SolitaireApp").
    
    set self:mainView to SolitaireView():new.
    
    
    return defineObject(self).
}

// Register the app
appRegistry:register("Solitaire", SolitaireApp@).