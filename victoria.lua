-----------------------------------------------------------------------------------------
-- Pantalla de victoria
-----------------------------------------------------------------------------------------

local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view
    
    -- Crear fondo
    local fondo = display.newRect(sceneGroup, _W/2, _H/2, _W, _H)
    fondo:setFillColor(0, 0.2, 0) 
    
    -- Texto de victoria
    local titulo = display.newText(sceneGroup, "¡Victoria!", _W/2, _H*0.35, native.systemFontBold, 44)
    titulo:setFillColor(1, 1, 0) 
    
    local subtitulo = display.newText(sceneGroup, "¡Has escapado del laberinto!", _W/2, _H*0.45, native.systemFont, 24)
    subtitulo:setFillColor(1)
    
    -- Efectos visuales para celebrar
    for i = 1, 20 do
        local x = math.random(_W*0.1, _W*0.9)
        local y = math.random(_H*0.1, _H*0.9)
        local tamano = math.random(10, 30)
        
        local estrella = display.newPolygon(sceneGroup, x, y, { 
            0, -tamano, tamano/3, -tamano/3, tamano, 0, 
            tamano/3, tamano/3, 0, tamano, -tamano/3, tamano/3, 
            -tamano, 0, -tamano/3, -tamano/3 
        })
        
        estrella:setFillColor(math.random(5, 10)/10, math.random(5, 10)/10, 0)
        
        -- Animación de las estrellas
        transition.to(estrella, {
            time = math.random(1000, 3000),
            rotation = math.random(180, 360),
            alpha = 0.2,
            xScale = 0.5,
            yScale = 0.5,
            iterations = -1,
            transition = easing.continuousLoop
        })
    end
    
    -- Botón para volver a jugar
    local btnJugar = display.newRoundedRect(sceneGroup, _W/2, _H*0.65, 200, 50, 12)
    btnJugar:setFillColor(0.2, 0.6, 0.2)
    
    local textoBtn = display.newText(sceneGroup, "Volver a jugar", _W/2, _H*0.65, native.systemFont, 20)
    textoBtn:setFillColor(1)
    
    -- Botón para volver al menú
    local btnMenu = display.newRoundedRect(sceneGroup, _W/2, _H*0.75, 200, 50, 12)
    btnMenu:setFillColor(0.2, 0.4, 0.8)
    
    local textoMenu = display.newText(sceneGroup, "Volver al menú", _W/2, _H*0.75, native.systemFont, 20)
    textoMenu:setFillColor(1)
    
    
    transition.to(btnJugar, {
        time = 1500,
        xScale = 1.05,
        yScale = 1.05,
        iterations = -1,
        transition = easing.continuousLoop
    })
    
    btnJugar:addEventListener("tap", function()
        composer.removeScene("victoria")
        timer.performWithDelay(50, function()
            composer.gotoScene("nivel1")
        end)
        return true
    end)
    
    btnMenu:addEventListener("tap", function()
        composer.removeScene("victoria")
        timer.performWithDelay(50, function()
            composer.gotoScene("menu")
        end)
        return true
    end)
    
    local info = display.newText(sceneGroup, "Gracias por jugar", _W/2, _H*0.85, native.systemFont, 16)
    info:setFillColor(0.8, 0.8, 0.8)
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        
        physics.stop()
    elseif phase == "did" then
        
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        
    elseif phase == "did" then
        
        physics.start()
        physics.setGravity(0, 0)
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene