// Rendering.ks
// Part of KOSYView
// Handles display buffer management and rendering logic
runOncePath("/KOSY/lib/TaskifiedObject").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").

function ViewRenderer {
    parameter width, height.
    local self is TaskifiedObject():extend.
    self:setClassName("RenderingSystem").

    // Two buffers for double buffering
    local activeBuffer_ is DisplayBuffer(width, height):new.
    local pendingBuffer_ is DisplayBuffer(width, height):new.
    
    local rootView is null.
    local needsUpdate is false.

    self:public("setRootView", {
        parameter viewIn.
        set rootView to viewIn.
    }).

    // Views call this to request a redraw
    self:public("requestDraw", {
        set needsUpdate to true.
    }).

    // Main render loop
    self:public("render", {
        self:while({return true.},{
            if needsUpdate {
                if not isNull(rootView) {
                    // Draw to pending buffer
                    pendingBuffer_:clearBuffer().
                    rootView:draw(pendingBuffer_, 0, 0).
                    
                    // Print pending buffer
                    pendingBuffer_:render().
                    
                    // Swap buffer contents
                    local temp is activeBuffer_:getContent().
                    activeBuffer_:setContent(pendingBuffer_:getContent()).
                    pendingBuffer_:setContent(temp).
                }.
                set needsUpdate to false.
            }.
        },.1).
    }).

    return defineObject(self).
}
