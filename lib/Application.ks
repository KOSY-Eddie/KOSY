runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").

function Application {
    local self is TaskifiedObject():extend.

    self:public("mainView", null).

    set self:mainView to VContainerView():new.
    local textView_ is TextView():new.
    textView_:settext(self:getClassName()).
    self:mainView:addChild(textView_).

    // self:public("launch",{
    //     parameter callback.
    //     callback(lex("title", self:getClassName(), "mainView", self:mainView)).
    // }).

    
    return defineObject(self).
}