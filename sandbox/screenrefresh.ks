local width is terminal:width.
local height is terminal:height - 1.
local screenBuffer is "":padRight(width*height).


function updateBuffer{
    parameter buffer, replacement, posX, posY.

    set bufferIdx to xy_to_bufferIdx(posX, posY).
    set buffer to buffer:insert(bufferIdx,replacement).
    set buffer to buffer:remove(bufferIdx + replacement:length, replacement:length).
    
    return buffer.
}

function clearBuffer{
    parameter buffer.
    local bufferLen is buffer:length.
    set buffer to "":padRight(bufferLen).
    return buffer.
}

function xy_to_bufferIdx{
    parameter x, y.
    return y*width + x.
}

function updatePos{
    parameter pos, vel, bdgBox.

    set pos:x to pos:x + vel:x.
    set pos:y to pos:y + vel:y.

    if(pos:x + bdgBox:width > width or pos:x < 0){
        set vel:x to -vel:x.
        set pos:x to pos:x + 2*vel:x.
    }
    if(pos:y + bdgBox:height > height or pos:y < 0){
        set vel:y to -vel:y.
        set pos:y to pos:y + 2*vel:y.
    }

    set pos:x to round(pos:x).
    set pos:y to round(pos:y).

    return lex("pos", pos, "vel", vel).
}

clearscreen.
local str is "HULLO!".
local bounds_ is lex("width",str:length, "height", 1).

local initAngle is random() * (60 - 30) + 30.
local initVel is lex("x",cos(initAngle),"y",sin(initAngle)).
local initPos is lex("x",round(random()*width),"y",round(random()*height)).
local posData is lex("pos",initPos,"vel", initVel).
until false {
    set posData to updatePos(posData:pos, posData:vel, bounds_).
    set screenBuffer to clearBuffer(screenBuffer).
    set screenBuffer to updateBuffer(screenBuffer,str,posData:pos:x,posData:pos:y).
    print screenBuffer.
    wait .05.
}