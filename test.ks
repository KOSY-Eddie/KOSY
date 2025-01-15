runOncePath("/KOSY/lib/KOSYView/ContainerView").
runOncePath("/KOSY/lib/KOSYView/TextView").
runOncePath("/KOSY/lib/KOSYView/DisplayBuffer").

unset screenBuffer.
global screenBuffer is DisplayBuffer(terminal:width, terminal:height):new.
global systemvars is lex("DEBUG", false).

local starttime is time:seconds.
// Create root container
local ui_root is VContainerView():new.

// Create header
local ui_header is HContainerView():new.
local ui_title is TextView():new.
local ui_time is TextView():new.
ui_title:setText("Kerbal Flight Control").
ui_title:halign("left").
ui_time:setText("T+ 00:00:00").
ui_time:halign("right").
ui_header:addChild(ui_title).
ui_header:addChild(ui_time).
ui_header:height:set(2).

// Create main content area (horizontal split)
local ui_content is HContainerView():new.

// Left panel - Flight Data
local ui_leftPanel is VContainerView():new.
local ui_flightTitle is TextView():new.
local ui_altitude is TextView():new.
local ui_speed is TextView():new.
local ui_heading is TextView():new.
ui_flightTitle:setText("Flight Data").
ui_flightTitle:halign("center").
ui_flightTitle:valign("top").
ui_altitude:setText("Altitude: 100m").
ui_speed:setText("Speed: 100 m/s").
ui_heading:setText("Heading: 90°").
ui_leftPanel:addChild(ui_flightTitle).
ui_leftPanel:addChild(ui_altitude).
ui_leftPanel:addChild(ui_speed).
ui_leftPanel:addChild(ui_heading).

// Center panel - Resources
local ui_centerPanel is VContainerView():new.
local ui_resourceTitle is TextView():new.
local ui_fuel is TextView():new.
local ui_electric is TextView():new.
local ui_mono is TextView():new.
ui_resourceTitle:setText("Resources").
ui_resourceTitle:halign("center").
ui_fuel:setText("Fuel: 100%").
ui_electric:setText("Electric: 100%").
ui_mono:setText("MonoProp: 100%").
ui_centerPanel:addChild(ui_resourceTitle).
ui_centerPanel:addChild(ui_fuel).
ui_centerPanel:addChild(ui_electric).
ui_centerPanel:addChild(ui_mono).

// Right panel - Status
local ui_rightPanel is VContainerView():new.
local ui_statusTitle is TextView():new.
local ui_stage is TextView():new.
local ui_status is TextView():new.
local ui_warning is TextView():new.
ui_statusTitle:setText("Status").
ui_statusTitle:halign("center").
ui_stage:setText("Stage: 1/3").
ui_status:setText("All Systems GO").
ui_warning:setText("No Warnings").
ui_rightPanel:addChild(ui_statusTitle).
ui_rightPanel:addChild(ui_stage).
ui_rightPanel:addChild(ui_status).
ui_rightPanel:addChild(ui_warning).

// Add panels to content
ui_content:addChild(ui_leftPanel).
ui_content:addChild(ui_centerPanel).
ui_content:addChild(ui_rightPanel).

// Create footer
local ui_footer is HContainerView():new.
local ui_controls is TextView():new.
local ui_version is TextView():new.
ui_controls:setText("[Space] Stage  [G] Gear  [B] Brakes").
ui_controls:halign("left").
ui_version:setText("v1.0").
ui_version:halign("right").
ui_footer:addChild(ui_controls).
ui_footer:addChild(ui_version).

// Add everything to root
ui_root:addChild(ui_header).
ui_root:addChild(ui_content).
ui_root:addChild(ui_footer).
ui_root:drawAll().

// Initial draw
screenBuffer:render().
wait 10.