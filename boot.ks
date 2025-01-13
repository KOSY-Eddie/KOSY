clearscreen.
global systemvars is lex("DEBUG", false).

runOncePath("/KOSY/lib/FileWriter").
runOncePath("/KOSY/lib/TaskScheduler").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").
runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/SpacerView").

// Create display buffer
global screenBuffer is DisplayBuffer(terminal:width, terminal:height-1):new.

// Main vertical container for entire interface
local mainContainer is VContainerView():new.
mainContainer:setPosition(0, 0).
mainContainer:setSpacing(0).

// Header bar
local headerContainer is HContainerView():new.
local headerTitleText is TextView():new.
local headerLeftSpacer is SpacerView():new.
local headerRightSpacer is SpacerView():new.

headerTitleText:setText("=== KOSMOS Flight Computer v1.0 ===").
local headerWidth is headerTitleText:getWidth().
local headerSpacerWidth is floor((terminal:width - headerWidth) / 2).
headerLeftSpacer:setWidth(headerSpacerWidth).
headerRightSpacer:setWidth(headerSpacerWidth).

headerContainer:addChild(headerLeftSpacer).
headerContainer:addChild(headerTitleText).
headerContainer:addChild(headerRightSpacer).

// Time and Mission Status
local statusContainer is HContainerView():new.
local missionNameText is TextView():new.
local missionTimeText is TextView():new.
local statusMiddleSpacer is SpacerView():new.

missionNameText:setText("Mission: Orbital Insertion").
missionTimeText:setText("MET: T+01:23:45").
local statusWidth is missionNameText:getWidth() + missionTimeText:getWidth().
local statusSpacerWidth is floor((terminal:width - statusWidth) / 3).

statusMiddleSpacer:setWidth(statusSpacerWidth).

// Add components to status container
local svs is SpacerView():new().
svs:setWidth(statusSpacerWidth).
statusContainer:addChild(svs).
statusContainer:addChild(missionNameText).
statusContainer:addChild(statusMiddleSpacer).
statusContainer:addChild(missionTimeText).
statusContainer:addChild(svs).

// Main data section - Three columns
local dataContainer is HContainerView():new.
dataContainer:setSpacing(2).

// Left column - Orbital Data
local orbitalColumn is VContainerView():new.
orbitalColumn:setSpacing(0).
local orbitalTitleText is TextView():new.
orbitalTitleText:setText("=== Orbital Data ===").
local altitudeText is TextView():new.
local apoapsisText is TextView():new.
local periapsisText is TextView():new.
local inclinationText is TextView():new.

altitudeText:setText("Altitude:    100.5 km").
apoapsisText:setText("Apoapsis:   150.2 km").
periapsisText:setText("Periapsis:   95.8 km").
inclinationText:setText("Inclination:  5.3°").

orbitalColumn:addChild(orbitalTitleText).
orbitalColumn:addChild(altitudeText).
orbitalColumn:addChild(apoapsisText).
orbitalColumn:addChild(periapsisText).
orbitalColumn:addChild(inclinationText).

// Middle column - Vehicle Data
local vehicleColumn is VContainerView():new.
vehicleColumn:setSpacing(0).
local vehicleTitleText is TextView():new.
vehicleTitleText:setText("=== Vehicle Data ===").
local velocityText is TextView():new.
local accelerationText is TextView():new.
local twrText is TextView():new.
local massText is TextView():new.

velocityText:setText("Velocity:   2,250 m/s").
accelerationText:setText("Accel:      12.5 m/s²").
twrText:setText("TWR:        2.1").
massText:setText("Mass:       15.2 t").

vehicleColumn:addChild(vehicleTitleText).
vehicleColumn:addChild(velocityText).
vehicleColumn:addChild(accelerationText).
vehicleColumn:addChild(twrText).
vehicleColumn:addChild(massText).

// Right column - Resource Data
local resourceColumn is VContainerView():new.
resourceColumn:setSpacing(0).
local resourceTitleText is TextView():new.
resourceTitleText:setText("=== Resources ===").
local fuelAmountText is TextView():new.
local oxidizerAmountText is TextView():new.
local monopropAmountText is TextView():new.
local electricAmountText is TextView():new.

fuelAmountText:setText("LiquidFuel: 75%").
oxidizerAmountText:setText("Oxidizer:   75%").
monopropAmountText:setText("MonoProp:   95%").
electricAmountText:setText("Electric:   100%").

resourceColumn:addChild(resourceTitleText).
resourceColumn:addChild(fuelAmountText).
resourceColumn:addChild(oxidizerAmountText).
resourceColumn:addChild(monopropAmountText).
resourceColumn:addChild(electricAmountText).

// Add columns to data container with spacing
dataContainer:addChild(orbitalColumn).
local svw1 is SpacerView():new.
svw1:setWidth(2).
dataContainer:addChild(svw1).
dataContainer:addChild(vehicleColumn).
dataContainer:addChild(svw1).
dataContainer:addChild(resourceColumn).

// Footer status bar
local footerContainer is HContainerView():new.
local footerStatusBar is TextView():new().
//footerStatusBar:setClassName("footerStatusBar").
footerStatusBar:setPosition(0, terminal:height - 1).
footerStatusBar:setHeight(1).
footerStatusBar:setWidth(terminal:width).
footerStatusBar:show().

// Add all main sections to container with blank line spacers
mainContainer:addChild(headerContainer).
local tv1 is TextView():new().
tv1:setHeight(1).
tv1:hide().
mainContainer:addChild(tv1). // Blank line
mainContainer:addChild(statusContainer).
mainContainer:addChild(tv1). // Blank line
mainContainer:addChild(dataContainer).
mainContainer:addChild(tv1). // Blank line
mainContainer:addChild(footerStatusBar).

// Draw everything
mainContainer:draw().

// Main loop
until false {
    scheduler:step().
    screenBuffer:render().
}.
