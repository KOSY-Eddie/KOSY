runOncePath("/KOSY/lib/Kobject").

function NavigationNode {
    parameter viewIn, parentIn is null.
    local self is Object():extend.
    self:setClassName("NavigationNode").
    
    local children is list().
    local activeNode is null.
    self:public("parent", parentIn).
    self:public("value", viewIn).

    self:public("getChildren",{return children.}).

    self:public("setActiveNode",{
        parameter nodeIn. 
        set activeNode to nodeIn.
        local activeNodeView is activeNode:value:get().
        if activeNodeView:hasKey("focus"){
            activeNodeView:focus().
        }
    }).

    //forward navigation
    self:public("addChild", {
        parameter vIn.

        //create child
        local child is NavigationNode(vIn, self:new):new.
        set activeNode to child.
        child:setActiveNode(activeNode).
        children:add(child).
        if not isNull(self:parent)
            self:parent:value:get():addChild(vIn).
        vIn:drawAll().
        return child.
    }).

    self:public("navigateHome",{
        self:setActiveNode(self:getRoot():getChildren()[0]).

        activeNode:focus(). //should be the home menu, if not we got problems.
    }).

    //backNavigation
    self:public("removeChild", {
        parameter childIn.
        local idx is 0.
        for c in children {
            if c:equals(childIn) {
                children:remove(idx).
                childIn:parent:set(null).
                break.
            }
            set idx to idx + 1.
        }
    }).
    
    self:public("removeFromParent", {
        if not isNull(self:parent) {
            self:parent:removeChild(self:new).
            set self:parent to null.
        }
    }).
    
    // Get root by traversing parents
    self:public("getRoot", {
        local current is self:new.
        until isNull(current:parent:get()) {
            set current to current:parent:get().
        }
        return current.
    }).


    local function getIndexOf {
        parameter childIn.
        if isNull(self:parent) return -1.
        
        local idx is 0.
        for c in self:parent:getChildren() {
            if c:equals(childIn) {
                return idx.
            }
            set idx to idx + 1.
        }
        return -1.
    }


    self:public("getNextSibling", {
        if isNull(self:parent) return.
        
        local idx is getIndexOf(self:new).
        if idx < self:parent:getChildren():length - 1 {
            self:setActiveNode(self:parent:getChildren()[idx + 1]).
        }
    }).

    // Get previous sibling (for split views)
    self:public("getPrevSibling", {
        if isNull(self:parent) return.
        
        local idx is getIndexOf(self:new).
        if idx > 0 {
            self:setActiveNode(self:parent:getChildren()[idx - 1]).
        }
    }).

    
    return defineObject(self).
}

