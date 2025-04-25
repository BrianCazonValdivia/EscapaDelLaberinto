-----------------------------------------------------------------------------------------
-- Menú principal del juego
-----------------------------------------------------------------------------------------

local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view
    
    -- Crear fondo
    local fondo = display.newRect(sceneGroup, _W/2, _H/2, _W, _H)
    fondo:setFillColor(0.05, 0.05, 0.2) 
    
    -- Título del juego
    local titulo = display.newText(sceneGroup, "ESCAPA DEL LABERINTO", _W/2, _H*0.25, native.systemFontBold, 36)
    titulo:setFillColor(1, 1, 0) 
    
    -- Subtítulo
    local subtitulo = display.newText(sceneGroup, "¡Encuentra la salida y evita a los enemigos!", _W/2, _H*0.35, native.systemFont, 18)
    subtitulo:setFillColor(0.8, 0.8, 1)
    
    -- Crear botones de nivel
    local function crearBotonNivel(y, texto, escena)
        local btn = display.newRoundedRect(sceneGroup, _W/2, y, _W*0.7, 60, 12)
        btn:setFillColor(0.2, 0.6, 0.2) 
        
        local textoBtn = display.newText(sceneGroup, texto, _W/2, y, native.systemFontBold, 24)
        textoBtn:setFillColor(1)
        
        btn:addEventListener("tap", function()
            composer.gotoScene(escena, {effect = "fade", time = 500})
        end)
        
        return btn
    end
    
    -- Botones de niveles 
    local btnNivel1 = crearBotonNivel(_H*0.5, "Nivel 1", "nivel1")
    local btnNivel2 = crearBotonNivel(_H*0.65, "Nivel 2", "nivel2")
    
    local info = display.newText(sceneGroup, "Desarrollado por Kevin Productions :3", _W/2, _H*0.9, native.systemFont, 14)
    info:setFillColor(0.7, 0.7, 0.7)
    
    -- Decoración
    for i = 1, 15 do
        local x, y = math.random(_W*0.1, _W*0.9), math.random(_H*0.1, _H*0.9)
        local tamano = math.random(5, 15)
        
        if math.random() > 0.5 then
            -- Pequeños cuadrados
            local cuadrado = display.newRect(sceneGroup, x, y, tamano, tamano)
            cuadrado:setFillColor(math.random(5, 10)/10, math.random(5, 10)/10, math.random(5, 10)/10)
            cuadrado.alpha = 0.3
            
            -- Animar los elementos de fondo
            transition.to(cuadrado, {
                time = math.random(3000, 6000),
                x = x + math.random(-30, 30),
                y = y + math.random(-30, 30),
                alpha = math.random(1, 5)/10,
                iterations = -1,
                transition = easing.inOutQuad
            })
        else
            -- Pequeños círculos
            local circulo = display.newCircle(sceneGroup, x, y, tamano/2)
            circulo:setFillColor(math.random(5, 10)/10, math.random(5, 10)/10, math.random(5, 10)/10)
            circulo.alpha = 0.3
            
            -- Animar los elementos de fondo
            transition.to(circulo, {
                time = math.random(3000, 6000),
                x = x + math.random(-30, 30),
                y = y + math.random(-30, 30),
                alpha = math.random(1, 5)/10,
                iterations = -1,
                transition = easing.inOutQuad
            })
        end
    end
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "did" then
        
        physics.stop()
        physics.start()
        physics.setGravity(0, 0)
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Detener todas las transiciones para evitar errores
        transition.cancel()
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    transition.cancel()
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene