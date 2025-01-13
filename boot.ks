clearscreen.
global systemvars is lex("DEBUG", false).

runOncePath("/KOSY/lib/FileWriter").
runOncePath("/KOSY/lib/TaskScheduler").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").

// Create display buffer
global screenBuffer is DisplayBuffer(terminal:width, terminal:height-1):new.

// Main vertical container for the whole layout
local mainContainer is VContainerView():new.
mainContainer:setPosition(2, 1).
mainContainer:setSpacing(1).

// Header section (horizontal)
local headerContainer is HContainerView():new.
headerContainer:setSpacing(3).

local title is TextView():new.
local timet is TextView():new.
title:setText("=== Kerbal Flight Computer ===").
timet:setText("T+: 10:23:45").
headerContainer:addChild(title).
headerContainer:addChild(timet).

// Stats section (two columns)
local statsContainer is HContainerView():new.
statsContainer:setSpacing(5).

// Left column of stats
local leftStats is VContainerView():new.
leftStats:setSpacing(1).
local altt is TextView():new.
local spd is TextView():new.
local apo is TextView():new.
altt:setText("Altitude: 100.5 km").
spd:setText("Speed: 2,250 m/s").
apo:setText("Apoapsis: 150.2 km").
leftStats:addChild(altt).
leftStats:addChild(spd).
leftStats:addChild(apo).

// Right column of stats
local rightStats is VContainerView():new.
rightStats:setSpacing(1).
local per is TextView():new.
local inc is TextView():new.
local fuel is TextView():new.
per:setText("Periapsis: 95.8 km").
inc:setText("Inclination: 5.3°").
fuel:setText("Fuel: 75%").
rightStats:addChild(per).
rightStats:addChild(inc).
rightStats:addChild(fuel).

// Add columns to stats container
statsContainer:addChild(leftStats).
statsContainer:addChild(rightStats).

// Footer section
local footer is TextView():new.
footer:setText("=== Press [ESC] to exit ===").

// Add all sections to main container
mainContainer:addChild(headerContainer).
mainContainer:addChild(statsContainer).
mainContainer:addChild(footer).

// Initial draw
mainContainer:draw().

// Main loop
until false {
    scheduler:step().
    screenBuffer:render().
}.
