
display.setStatusBar(display.HiddenStatusBar)

local composer = require("composer")
local physics = require("physics")

physics.start()
physics.setGravity(0, 0) -- Sin gravedad para que el personaje no caiga
physics.setDrawMode("normal") -- Opciones: "normal", "hybrid", "debug"

_W = display.contentWidth
_H = display.contentHeight

composer.gotoScene("menu")