-----------------------------------------------------------------------------------------
-- Nivel 1 del laberinto
-----------------------------------------------------------------------------------------

local composer = require("composer")
local physics = require("physics")
local jugadorModule = require("jugador")

local scene = composer.newScene()

local jugador
local muros = {}
local enemigos = {}
local meta

local btnArriba, btnAbajo, btnIzquierda, btnDerecha

local collisionListenerActive = false
local enterFrameListenerActive = false

function scene:create(event)
    local sceneGroup = self.view
    
    scene.mensajeActivo = false
    
    local fondo = display.newRect(sceneGroup, _W/2, _H/2, _W, _H)
    fondo:setFillColor(0.1, 0.1, 0.1) 
    
    -- Crear muros del laberinto
    local function crearMuro(x, y, ancho, alto)
        local muro = display.newRect(sceneGroup, x, y, ancho, alto)
        muro:setFillColor(0.5, 0.5, 0.5) 
        physics.addBody(muro, "static", {bounce = 0, friction = 0.3})
        muro.tipo = "muro"
        table.insert(muros, muro)
        return muro
    end
    
    -- Crear muros del borde 
    crearMuro(_W/2, 10, _W, 20) 
    crearMuro(_W/2, _H-10, _W, 20) 
    crearMuro(10, _H/2, 20, _H) 
    crearMuro(_W-10, _H/2, 20, _H) 
    
    -- Crear muros internos del laberinto 
    -- Patrón principal horizontal
    crearMuro(_W*0.25, _H*0.2, _W*0.4, 15)
    crearMuro(_W*0.7, _H*0.3, _W*0.5, 15)
    crearMuro(_W*0.35, _H*0.5, _W*0.5, 15)
    crearMuro(_W*0.65, _H*0.7, _W*0.6, 15)
    crearMuro(_W*0.25, _H*0.85, _W*0.35, 15)

    -- Patrón principal vertical
    crearMuro(_W*0.2, _H*0.35, 15, _H*0.3)
    crearMuro(_W*0.35, _H*0.7, 15, _H*0.4)
    crearMuro(_W*0.5, _H*0.25, 15, _H*0.25)
    crearMuro(_W*0.65, _H*0.5, 15, _H*0.25)
    crearMuro(_W*0.8, _H*0.6, 15, _H*0.35)

    -- Nuevos muros horizontales
    crearMuro(_W*0.15, _H*0.4, _W*0.1, 15)
    crearMuro(_W*0.85, _H*0.2, _W*0.1, 15)
    crearMuro(_W*0.45, _H*0.65, _W*0.15, 15)
    crearMuro(_W*0.15, _H*0.75, _W*0.1, 15)

    -- Nuevos muros verticales
    crearMuro(_W*0.3, _H*0.1, 15, _H*0.1)
    crearMuro(_W*0.7, _H*0.45, 15, _H*0.15)
    crearMuro(_W*0.4, _H*0.75, 15, _H*0.1)
    crearMuro(_W*0.9, _H*0.4, 15, _H*0.2)
    
    local function crearDecoracion(x, y, tipo)
        local decoracion = display.newGroup()
        sceneGroup:insert(decoracion)
        
        if tipo == "estrella" then
            
            local estrella = display.newPolygon(decoracion, 0, 0, {
                0, -10, 3, -3, 10, -3, 5, 2, 7, 10, 0, 5, -7, 10, -5, 2, -10, -3, -3, -3
            })
            estrella:setFillColor(1, 1, 0.4) 
            
            transition.to(estrella, {
                time = 2000,
                rotation = 360,
                iterations = -1
            })
        elseif tipo == "luz" then
            
            local luz = display.newCircle(decoracion, 0, 0, 8)
            luz:setFillColor(0.3, 0.8, 1) 
            
            transition.to(luz, {
                time = 1500,
                alpha = 0.6,
                xScale = 0.8,
                yScale = 0.8,
                iterations = -1,
                transition = easing.continuousLoop
            })
        elseif tipo == "flecha" then
            
            local flecha = display.newPolygon(decoracion, 0, 0, {
                0, -10, 10, 0, 0, 10, 0, 5, -10, 5, -10, -5, 0, -5
            })
            flecha:setFillColor(0.2, 0.9, 0.3) 
            flecha.rotation = math.random(0, 360) 
        end
        
        decoracion.x = x
        decoracion.y = y
        
        return decoracion
    end

    crearDecoracion(_W*0.15, _H*0.15, "estrella")
    crearDecoracion(_W*0.85, _H*0.85, "estrella")
    crearDecoracion(_W*0.5, _H*0.15, "luz")
    crearDecoracion(_W*0.15, _H*0.5, "luz")
    crearDecoracion(_W*0.85, _H*0.5, "luz")
    crearDecoracion(_W*0.5, _H*0.85, "luz")
    crearDecoracion(_W*0.7, _H*0.4, "flecha")
    crearDecoracion(_W*0.3, _H*0.6, "flecha")
    

    local function crearEnemigo(x, y)
        
        local grupoEnemigo = display.newGroup()
        sceneGroup:insert(grupoEnemigo)
        
        local cuerpo = display.newCircle(grupoEnemigo, 0, 0, 20)
        cuerpo:setFillColor(0.8, 0.2, 0.2) 
        
        -- Ojos
        local ojoIzq = display.newCircle(grupoEnemigo, -7, -5, 5)
        ojoIzq:setFillColor(1, 1, 1)
        local pupilIzq = display.newCircle(grupoEnemigo, -7, -5, 2)
        pupilIzq:setFillColor(0, 0, 0)
        
        local ojoDer = display.newCircle(grupoEnemigo, 7, -5, 5)
        ojoDer:setFillColor(1, 1, 1)
        local pupilDer = display.newCircle(grupoEnemigo, 7, -5, 2)
        pupilDer:setFillColor(0, 0, 0)
        
        -- Boca
        local boca = display.newRect(grupoEnemigo, 0, 8, 15, 2)
        boca:setFillColor(0, 0, 0)
        
        grupoEnemigo.x = x
        grupoEnemigo.y = y
        
        physics.addBody(grupoEnemigo, "dynamic", {
            density = 1.0,
            friction = 0,
            bounce = 1.0,
            radius = 20
        })
        
        grupoEnemigo.tipo = "enemigo"
        grupoEnemigo.velocidadX = math.random(-50, 50)
        grupoEnemigo.velocidadY = math.random(-50, 50)
        table.insert(enemigos, grupoEnemigo)
        
        return grupoEnemigo
    end
    
    crearEnemigo(_W*0.3, _H*0.4)
    crearEnemigo(_W*0.6, _H*0.6)
    crearEnemigo(_W*0.8, _H*0.2)
    crearEnemigo(_W*0.2, _H*0.7)
    crearEnemigo(_W*0.5, _H*0.3)
    crearEnemigo(_W*0.75, _H*0.8)
    
    local grupoMeta = display.newGroup()
    sceneGroup:insert(grupoMeta)
    
    local circuloMeta = display.newCircle(grupoMeta, 0, 0, 25)
    circuloMeta:setFillColor(0, 0.8, 0) 
    
    -- Estrella en el centro
    for i = 1, 5 do
        local angulo = (i-1) * 72 - 18 
        local radianes = math.rad(angulo)
        local x1 = math.cos(radianes) * 10
        local y1 = math.sin(radianes) * 10
        
        radianes = math.rad(angulo + 36) 
        local x2 = math.cos(radianes) * 18
        local y2 = math.sin(radianes) * 18
        
        local linea = display.newLine(grupoMeta, 0, 0, x1, y1)
        linea:append(x2, y2)
        linea.strokeWidth = 4
        linea:setStrokeColor(1, 1, 0) 
    end
    
    local textoMeta = display.newText(grupoMeta, "META", 0, 40, native.systemFontBold, 16)
    textoMeta:setFillColor(1, 1, 1)

    grupoMeta.x = _W*0.9
    grupoMeta.y = _H*0.9
    
    physics.addBody(grupoMeta, "static", {isSensor = true, radius = 25})
    grupoMeta.tipo = "meta"
    
    transition.to(grupoMeta, {
        time = 3000,
        rotation = 360,
        iterations = -1
    })
    
    meta = grupoMeta
    
    jugador = jugadorModule.nuevo(_W*0.1, _H*0.1)
    sceneGroup:insert(jugador)
    
    -- Crear botones de control
    local function crearBoton(x, y, ancho, alto, texto)
        local btn = display.newRoundedRect(sceneGroup, x, y, ancho, alto, 12)
        btn:setFillColor(0.2, 0.2, 0.4, 0.7)
        btn.texto = display.newText(sceneGroup, texto, x, y, native.systemFont, 20)
        btn.texto:setFillColor(1)
        return btn
    end
    
    local btnSize = 45
    
    btnArriba = crearBoton(_W*0.10, _H*0.80, btnSize, btnSize, "↑")
    btnAbajo = crearBoton(_W*0.10, _H*0.92, btnSize, btnSize, "↓")
    btnIzquierda = crearBoton(_W*0.05, _H*0.86, btnSize, btnSize, "←")
    btnDerecha = crearBoton(_W*0.15, _H*0.86, btnSize, btnSize, "→")
end

local function mostrarMensajeColision(escena, tipo)
    physics.pause()
    
    
    if collisionListenerActive then
        Runtime:removeEventListener("collision", escena.manejarColision)
        collisionListenerActive = false
    end
    
    if enterFrameListenerActive then
        Runtime:removeEventListener("enterFrame", escena.actualizarEnemigos)
        enterFrameListenerActive = false
    end
    
    if escena.moverJugador then
        btnArriba:removeEventListener("touch", escena.moverJugador)
        btnAbajo:removeEventListener("touch", escena.moverJugador)
        btnIzquierda:removeEventListener("touch", escena.moverJugador)
        btnDerecha:removeEventListener("touch", escena.moverJugador)
    end
    
    
    escena.mensajeActivo = true
    
    -- Crear grupo para contener la interfaz de mensaje
    local mensajeGrupo = display.newGroup()
    escena.view:insert(mensajeGrupo)
    
    -- Fondo semitransparente
    local fondoMensaje = display.newRect(mensajeGrupo, _W/2, _H/2, _W, _H)
    fondoMensaje:setFillColor(0, 0, 0, 0.7)
    
    local mensaje, color, acciones
    
    if tipo == "enemigo" then
        mensaje = "¡Perdiste!"
        color = {1, 0, 0}
        acciones = {
            {texto = "Volver a intentar", color = {0.8, 0.2, 0.2}, accion = "reintentar"},
            {texto = "Volver al menú", color = {0.2, 0.4, 0.8}, accion = "menu"}
        }
    elseif tipo == "meta" then
        mensaje = "¡Nivel completado!"
        color = {0, 1, 0}
        
        if _G.actualizarProgreso then
            _G.actualizarProgreso("nivel1")
        end
        
        acciones = {
            {texto = "Siguiente nivel", color = {0.2, 0.8, 0.2}, accion = "siguiente"},
            {texto = "Volver al menú", color = {0.2, 0.4, 0.8}, accion = "menu"}
        }
    end
    
    -- Mostrar mensaje
    local textoMensaje = display.newText(mensajeGrupo, mensaje, _W/2, _H/2, native.systemFontBold, 36)
    textoMensaje:setFillColor(unpack(color))
    
    -- Crear botones para acciones
    for i, accion in ipairs(acciones) do
        local y = _H * (0.6 + (i-1) * 0.1)
        local btn = display.newRoundedRect(mensajeGrupo, _W/2, y, 200, 50, 12)
        btn:setFillColor(unpack(accion.color))
        
        local textoBtn = display.newText(mensajeGrupo, accion.texto, _W/2, y, native.systemFont, 20)
        textoBtn:setFillColor(1)
        
        btn:addEventListener("tap", function()
            
            display.remove(mensajeGrupo)
            
            physics.start()
            physics.setGravity(0, 0)
            
            -- Determinar la acción a realizar
            if accion.accion == "reintentar" then
                composer.removeScene("nivel1")
                composer.gotoScene("nivel1")
            elseif accion.accion == "menu" then
                composer.removeScene("nivel1")
                composer.gotoScene("menu")
            elseif accion.accion == "siguiente" then
                
                if collisionListenerActive then
                    Runtime:removeEventListener("collision", escena.manejarColision)
                    collisionListenerActive = false
                end
                
                if enterFrameListenerActive then
                    Runtime:removeEventListener("enterFrame", escena.actualizarEnemigos)
                    enterFrameListenerActive = false
                end
                
                
                display.remove(mensajeGrupo)
                escena.mensajeGrupo = nil
                
                
                timer.performWithDelay(50, function()
                    composer.removeScene("nivel1")
                    composer.gotoScene("nivel2", {effect = "fade", time = 800})
                end)
            end
        end)
    end
    
    
    escena.mensajeGrupo = mensajeGrupo
end


local function manejarColision(event)
    if event.phase == "began" then
        local obj1 = event.object1
        local obj2 = event.object2
        
        
        if scene.mensajeActivo then
            return
        end
        
        -- Verificar colisión jugador-enemigo
        if (obj1.tipo == "jugador" and obj2.tipo == "enemigo") or
           (obj1.tipo == "enemigo" and obj2.tipo == "jugador") then
            mostrarMensajeColision(scene, "enemigo")
        end
        
        -- Verificar colisión jugador-meta
        if (obj1.tipo == "jugador" and obj2.tipo == "meta") or
           (obj1.tipo == "meta" and obj2.tipo == "jugador") then
            mostrarMensajeColision(scene, "meta")
        end
    end
end


local function actualizarEnemigos()
    
    if not scene.view or scene.mensajeActivo then
        return
    end
    
    for i = 1, #enemigos do
        local e = enemigos[i]
        
        
        if e and e.parent then
            
            local vx, vy = e:getLinearVelocity()
            
            -- Detectar colisiones con paredes 
            if math.abs(vx) < 15 or math.abs(vy) < 15 then
                -- Cambiar dirección para evitar atasco en esquinas
                e.velocidadX = -e.velocidadX * 1.1 + math.random(-30, 30)
                e.velocidadY = -e.velocidadY * 1.1 + math.random(-30, 30)
                
                -- Asegurar una velocidad mínima para evitar estancamiento
                if math.abs(e.velocidadX) < 40 then
                    e.velocidadX = e.velocidadX < 0 and -40 or 40
                end
                if math.abs(e.velocidadY) < 40 then
                    e.velocidadY = e.velocidadY < 0 and -40 or 40
                end
                
                -- Aplicar un impulso para salir de la esquina
                e:applyLinearImpulse(e.velocidadX * 0.7, e.velocidadY * 0.7, e.x, e.y)
            end
            
            -- Comportamiento impredecible
            if math.random(1, 100) <= 2 then 
                
                e.velocidadX = e.velocidadX + math.random(-20, 20)
                e.velocidadY = e.velocidadY + math.random(-20, 20)
                
                
                local maxVelocidad = 90 
                if math.abs(e.velocidadX) > maxVelocidad then
                    e.velocidadX = e.velocidadX > 0 and maxVelocidad or -maxVelocidad
                end
                if math.abs(e.velocidadY) > maxVelocidad then
                    e.velocidadY = e.velocidadY > 0 and maxVelocidad or -maxVelocidad
                end
            end
            
             
            e:setLinearVelocity(e.velocidadX, e.velocidadY)
            
            -- Girar ligeramente el enemigo en la dirección del movimiento para feedback visual
            if math.abs(vx) > math.abs(vy) then
                
                if vx > 0 then
                    e.rotation = 8  
                else
                    e.rotation = -8 
                end
            else
                
                if vy > 0 then
                    e.rotation = 4  
                else
                    e.rotation = -4 
                end
            end
        end
    end
end


local function moverJugador(event)
    
    if not scene.view or scene.mensajeActivo then
        return true
    end
    
    
    if not jugador or not jugador.parent then
        return true
    end
    
    local impulso = 90 
    
    if event.phase == "began" then
        -- Iniciar movimiento según el botón presionado
        if event.target == btnArriba then
            jugador:mover(0, -impulso, "arriba")
        elseif event.target == btnAbajo then
            jugador:mover(0, impulso, "abajo")
        elseif event.target == btnIzquierda then
            jugador:mover(-impulso, 0, "izquierda")
        elseif event.target == btnDerecha then
            jugador:mover(impulso, 0, "derecha")
        end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        -- Detener el movimiento según el botón liberado
        if event.target == btnArriba then
            jugador:detener("arriba")
        elseif event.target == btnAbajo then
            jugador:detener("abajo")
        elseif event.target == btnIzquierda then
            jugador:detener("izquierda")
        elseif event.target == btnDerecha then
            jugador:detener("derecha")
        end
    end
    
    return true
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        
    elseif phase == "did" then
        
        physics.start()
        physics.setGravity(0, 0)
        
        
        scene.mensajeActivo = false
        
        
        scene.manejarColision = manejarColision
        scene.actualizarEnemigos = actualizarEnemigos
        scene.moverJugador = moverJugador
        
        Runtime:addEventListener("collision", manejarColision)
        collisionListenerActive = true
        
        btnArriba:addEventListener("touch", moverJugador)
        btnAbajo:addEventListener("touch", moverJugador)
        btnIzquierda:addEventListener("touch", moverJugador)
        btnDerecha:addEventListener("touch", moverJugador)
        
        Runtime:addEventListener("enterFrame", actualizarEnemigos)
        enterFrameListenerActive = true
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        
        if collisionListenerActive then
            Runtime:removeEventListener("collision", manejarColision)
            collisionListenerActive = false
        end
        
        if scene.moverJugador then
            btnArriba:removeEventListener("touch", scene.moverJugador)
            btnAbajo:removeEventListener("touch", scene.moverJugador)
            btnIzquierda:removeEventListener("touch", scene.moverJugador)
            btnDerecha:removeEventListener("touch", scene.moverJugador)
        end
        
        if enterFrameListenerActive then
            Runtime:removeEventListener("enterFrame", actualizarEnemigos)
            enterFrameListenerActive = false
        end
        
        -- Limpiar cualquier mensaje activo
        if scene.mensajeGrupo then
            display.remove(scene.mensajeGrupo)
            scene.mensajeGrupo = nil
        end
        
        
        physics.pause()
    elseif phase == "did" then
        
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    
    if scene.mensajeGrupo then
        scene.mensajeGrupo:removeSelf()
        scene.mensajeGrupo = nil
    end
    
    -- Limpiar las referencias a objetos
    jugador = nil
    muros = {}
    enemigos = {}
    meta = nil
    
    transition.cancel()
    
    -- Reiniciar la física
    physics.stop()
    physics.start()
    physics.setGravity(0, 0)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene