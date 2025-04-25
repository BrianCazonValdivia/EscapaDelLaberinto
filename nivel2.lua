-----------------------------------------------------------------------------------------
-- Nivel 2 del laberinto
-----------------------------------------------------------------------------------------

local composer = require("composer")
local physics = require("physics")
local jugadorModule = require("jugador")

local scene = composer.newScene()

local jugador
local muros = {}
local enemigos = {}
local trampas = {}
local meta

local btnArriba, btnAbajo, btnIzquierda, btnDerecha

-- Variables para rastrear si los listener están activos
local collisionListenerActive = false
local enterFrameListenerActive = false

function scene:create(event)
    local sceneGroup = self.view
    
    scene.mensajeActivo = false
    
    -- Crear fondo
    local fondo = display.newRect(sceneGroup, _W/2, _H/2, _W, _H)
    fondo:setFillColor(0.05, 0.05, 0.15) 
    
    -- Crear muros del laberinto
    local function crearMuro(x, y, ancho, alto)
        local muro = display.newRect(sceneGroup, x, y, ancho, alto)
        muro:setFillColor(0.4, 0.4, 0.6) 
        physics.addBody(muro, "static", {bounce = 0, friction = 0.3})
        muro.tipo = "muro"
        table.insert(muros, muro)
        return muro
    end
    
    -- Crear muros del borde (más gruesos para cerrar el laberinto)
    crearMuro(_W/2, 10, _W, 20) 
    crearMuro(_W/2, _H-10, _W, 20)
    crearMuro(10, _H/2, 20, _H) 
    crearMuro(_W-10, _H/2, 20, _H) 
    
    -- Crear muros internos del laberinto 
    crearMuro(_W*0.2, _H*0.2, _W*0.4, 15)  
    crearMuro(_W*0.2, _H*0.4, _W*0.6, 15)  
    crearMuro(_W*0.2, _H*0.6, _W*0.8, 15)  
    crearMuro(_W*0.2, _H*0.8, _W*0.4, 15)  

    crearMuro(_W*0.2, _H*0.3, 15, _H*0.2)  
    crearMuro(_W*0.4, _H*0.5, 15, _H*0.2)  
    crearMuro(_W*0.6, _H*0.3, 15, _H*0.2)  
    crearMuro(_W*0.8, _H*0.5, 15, _H*0.2)  

    -- Laberinto extendido con pasajes más estrechos
    crearMuro(_W*0.3, _H*0.1, 15, _H*0.1)  
    crearMuro(_W*0.5, _H*0.1, 15, _H*0.1)  
    crearMuro(_W*0.7, _H*0.1, 15, _H*0.1)  
    crearMuro(_W*0.9, _H*0.1, 15, _H*0.1)  

    crearMuro(_W*0.3, _H*0.9, 15, _H*0.1)  
    crearMuro(_W*0.5, _H*0.9, 15, _H*0.1)  
    crearMuro(_W*0.7, _H*0.9, 15, _H*0.1)  
    crearMuro(_W*0.9, _H*0.9, 15, _H*0.1)  

    -- Obstrucciones y callejones sin salida
    crearMuro(_W*0.3, _H*0.3, _W*0.1, 15)  
    crearMuro(_W*0.7, _H*0.7, _W*0.1, 15)  
    crearMuro(_W*0.5, _H*0.7, 15, _H*0.1)  
    crearMuro(_W*0.9, _H*0.3, 15, _H*0.1)  

    -- Zona central más compleja con "sala del tesoro"
    crearMuro(_W*0.45, _H*0.45, _W*0.1, 15)   
    crearMuro(_W*0.45, _H*0.55, _W*0.1, 15)   
    crearMuro(_W*0.4, _H*0.5, 15, _H*0.1)     
    crearMuro(_W*0.5, _H*0.5, 15, _H*0.1)     

    -- Zigzag en el lado derecho
    crearMuro(_W*0.65, _H*0.25, _W*0.1, 15)
    crearMuro(_W*0.75, _H*0.35, _W*0.1, 15)
    crearMuro(_W*0.65, _H*0.45, _W*0.1, 15)
    crearMuro(_W*0.75, _H*0.55, _W*0.1, 15)
    
    -- decoraciones
    local function crearDecoracionAvanzada(x, y, tipo)
        local decoracion = display.newGroup()
        sceneGroup:insert(decoracion)
        
        if tipo == "portal" then
        
            local basePortal = display.newCircle(decoracion, 0, 0, 15)
            basePortal:setFillColor(0.3, 0, 0.5) 
            
            for i = 1, 3 do
                local anillo = display.newCircle(decoracion, 0, 0, 15 - i*3)
                anillo:setFillColor(0.5 + i*0.1, 0, 0.8 - i*0.1)
                anillo.alpha = 0.7
                
            
                transition.to(anillo, {
                    time = 2000 - i*500,
                    rotation = 360,
                    iterations = -1
                })
            end
            
            
            transition.to(decoracion, {
                time = 1500,
                xScale = 1.1,
                yScale = 1.1,
                iterations = -1,
                transition = easing.continuousLoop
            })
        elseif tipo == "cristal" then
            
            local base = display.newPolygon(decoracion, 0, 0, {
                0, -12, 8, -4, 8, 8, 0, 12, -8, 8, -8, -4
            })
            base:setFillColor(0, 0.6, 0.8) 
            
            local nucleo = display.newPolygon(decoracion, 0, 0, {
                0, -6, 4, -2, 4, 4, 0, 6, -4, 4, -4, -2
            })
            nucleo:setFillColor(0.2, 0.9, 1)
            
            
            transition.to(nucleo, {
                time = 800,
                alpha = 0.6,
                iterations = -1,
                transition = easing.continuousLoop
            })
        elseif tipo == "fuego" then
            
            local baseFlama = display.newRect(decoracion, 0, 0, 20, 6)
            baseFlama:setFillColor(0.8, 0.3, 0) 
            
            for i = 1, 3 do
                local flama = display.newPolygon(decoracion, 0, -i*4, {
                    -5+i, 0, 0, -10+i*2, 5-i, 0
                })
                flama:setFillColor(1, 0.5 - i*0.1, 0) 
                
                
                transition.to(flama, {
                    time = 500 + i*200,
                    y = flama.y - math.random(1, 3),
                    xScale = 0.9 + math.random()*0.2,
                    iterations = -1,
                    transition = easing.continuousLoop
                })
            end
        end
        
        
        decoracion.x = x
        decoracion.y = y
        
        return decoracion
    end

    -- Añadir decoraciones avanzadas por el laberinto
    crearDecoracionAvanzada(_W*0.2, _H*0.1, "cristal")
    crearDecoracionAvanzada(_W*0.8, _H*0.1, "cristal")
    crearDecoracionAvanzada(_W*0.2, _H*0.9, "cristal")
    crearDecoracionAvanzada(_W*0.8, _H*0.9, "cristal")
    crearDecoracionAvanzada(_W*0.45, _H*0.5, "portal") 
    crearDecoracionAvanzada(_W*0.1, _H*0.5, "fuego")
    crearDecoracionAvanzada(_W*0.9, _H*0.5, "fuego")
    crearDecoracionAvanzada(_W*0.5, _H*0.1, "fuego")
    crearDecoracionAvanzada(_W*0.5, _H*0.9, "fuego")
    
    -- trampas
    local function crearTrampa(x, y)
        -- Grupo para la trampa
        local grupoTrampa = display.newGroup()
        sceneGroup:insert(grupoTrampa)
        
        
        local base = display.newRect(grupoTrampa, 0, 0, 40, 40)
        base:setFillColor(0.6, 0.3, 0)
        
        -- Pinchos
        for i = 1, 3 do
            for j = 1, 3 do
                if not (i == 2 and j == 2) then 
                    local pincho = display.newRect(grupoTrampa, 
                                                  (i-2)*12, 
                                                  (j-2)*12, 
                                                  6, 6)
                    pincho:setFillColor(1, 0.3, 0) 
                end
            end
        end
        
        -- Símbolo de peligro en el centro
        local simbolo = display.newText(grupoTrampa, "!", 0, 0, native.systemFontBold, 24)
        simbolo:setFillColor(1, 1, 0) 
        
    
        grupoTrampa.x = x
        grupoTrampa.y = y
        
        -- Añadimos física
        physics.addBody(grupoTrampa, "static", {isSensor = true})
        grupoTrampa.tipo = "trampa"
        
        
        transition.to(grupoTrampa, {
            time = 1000,
            alpha = 0.7,
            xScale = 0.9, 
            yScale = 0.9,
            iterations = -1,
            transition = easing.continuousLoop
        })
        
        table.insert(trampas, grupoTrampa)
        return grupoTrampa
    end
    
    -- Añadir más trampas para aumentar la dificultad
    crearTrampa(_W*0.5, _H*0.3)   
    crearTrampa(_W*0.3, _H*0.5)   
    crearTrampa(_W*0.7, _H*0.5)   
    crearTrampa(_W*0.5, _H*0.7)   
    crearTrampa(_W*0.35, _H*0.35) 
    crearTrampa(_W*0.65, _H*0.65) 
    crearTrampa(_W*0.65, _H*0.35) 
    crearTrampa(_W*0.35, _H*0.65) 
    
    -- Crear enemigos
    local function crearEnemigo(x, y)
        -- Creamos un grupo para los enemigo 
        local grupoEnemigo = display.newGroup()
        sceneGroup:insert(grupoEnemigo)
        
        local cuerpo = display.newCircle(grupoEnemigo, 0, 0, 20)
        cuerpo:setFillColor(0.8, 0.1, 0.1) 
        
        -- Decoración para nivel 2 
        local puntas = {}
        for i = 1, 6 do
            local angulo = (i-1) * (360/6)
            local radianes = math.rad(angulo)
            local punta = display.newRect(grupoEnemigo, 
                                         math.cos(radianes) * 22, 
                                         math.sin(radianes) * 22, 
                                         7, 7)
            punta:setFillColor(0.9, 0.3, 0)
            punta.rotation = angulo
            table.insert(puntas, punta)
        end
        
        -- Ojos
        local ojoIzq = display.newCircle(grupoEnemigo, -7, -5, 5)
        ojoIzq:setFillColor(1, 0.9, 0.2) 
        local pupilIzq = display.newCircle(grupoEnemigo, -7, -5, 2)
        pupilIzq:setFillColor(0, 0, 0)
        
        local ojoDer = display.newCircle(grupoEnemigo, 7, -5, 5)
        ojoDer:setFillColor(1, 0.9, 0.2)
        local pupilDer = display.newCircle(grupoEnemigo, 7, -5, 2)
        pupilDer:setFillColor(0, 0, 0)
        
        -- Boca
        local boca = display.newRect(grupoEnemigo, 0, 8, 15, 3)
        boca:setFillColor(0, 0, 0)
        
        grupoEnemigo.x = x
        grupoEnemigo.y = y
        
        -- Añadimos física al grupo (solo afecta al centro)
        physics.addBody(grupoEnemigo, "dynamic", {
            density = 1.0,
            friction = 0,
            bounce = 1.0,
            radius = 20
        })
        
        grupoEnemigo.tipo = "enemigo"
        grupoEnemigo.velocidadX = math.random(-60, 60)
        grupoEnemigo.velocidadY = math.random(-60, 60)
        table.insert(enemigos, grupoEnemigo)
        
        return grupoEnemigo
    end
    
    -- Añadir más enemigos para nivel 2
    crearEnemigo(_W*0.3, _H*0.3)
    crearEnemigo(_W*0.7, _H*0.3)
    crearEnemigo(_W*0.3, _H*0.7)
    crearEnemigo(_W*0.7, _H*0.7)
    crearEnemigo(_W*0.5, _H*0.5)
    crearEnemigo(_W*0.2, _H*0.5)
    crearEnemigo(_W*0.8, _H*0.5)
    crearEnemigo(_W*0.5, _H*0.2)
    crearEnemigo(_W*0.5, _H*0.8)
    
    -- Crear meta
    local grupoMeta = display.newGroup()
    sceneGroup:insert(grupoMeta)

    local circuloMeta = display.newCircle(grupoMeta, 0, 0, 25)
    circuloMeta:setFillColor(0, 0.8, 0) 
    
    -- Decoración especial para la meta del nivel 2
    for i = 1, 8 do
        local angulo = (i-1) * 45 
        local radianes = math.rad(angulo)
        local destello = display.newRect(grupoMeta,
                                        math.cos(radianes) * 30,
                                        math.sin(radianes) * 30,
                                        10, 10)
        destello:setFillColor(1, 1, 0) 
        destello.rotation = angulo
    end
    
    -- Texto de "META"
    local textoMeta = display.newText(grupoMeta, "META", 0, 40, native.systemFontBold, 16)
    textoMeta:setFillColor(1, 1, 1)
    

    grupoMeta.x = _W*0.1
    grupoMeta.y = _H*0.9
    
    -- Añadimos física
    physics.addBody(grupoMeta, "static", {isSensor = true, radius = 25})
    grupoMeta.tipo = "meta"
    

    transition.to(grupoMeta, {
        time = 2000,
        rotation = 360,
        iterations = -1
    })
    
    meta = grupoMeta
    
    -- Crear jugador
    jugador = jugadorModule.nuevo(_W*0.9, _H*0.1) 
    sceneGroup:insert(jugador)
    
    -- Crear botones de control
    local function crearBoton(x, y, ancho, alto, texto)
        local btn = display.newRoundedRect(sceneGroup, x, y, ancho, alto, 12)
        btn:setFillColor(0.2, 0.2, 0.4, 0.7)
        btn.texto = display.newText(sceneGroup, texto, x, y, native.systemFont, 20)
        btn.texto:setFillColor(1)
        return btn
    end
    
    -- Tamaño de botones
    local btnSize = 45

    btnArriba = crearBoton(_W*0.10, _H*0.80, btnSize, btnSize, "↑")
    btnAbajo = crearBoton(_W*0.10, _H*0.92, btnSize, btnSize, "↓")
    btnIzquierda = crearBoton(_W*0.05, _H*0.86, btnSize, btnSize, "←")
    btnDerecha = crearBoton(_W*0.15, _H*0.86, btnSize, btnSize, "→")
end

-- Función para mostrar mensaje de colisión
local function mostrarMensajeColision(escena, tipo)
    
    physics.pause()
    
    -- Remover listeners para evitar errores
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
    
    -- Marcar que hay un mensaje activo
    escena.mensajeActivo = true
    
    -- Crear grupo para contener la interfaz de mensaje
    local mensajeGrupo = display.newGroup()
    escena.view:insert(mensajeGrupo)
    
    
    local fondoMensaje = display.newRect(mensajeGrupo, _W/2, _H/2, _W, _H)
    fondoMensaje:setFillColor(0, 0, 0, 0.7)
    
    -- Configuración según el tipo de mensaje
    local mensaje, color, acciones
    
    if tipo == "enemigo" then
        mensaje = "¡Perdiste!"
        color = {1, 0, 0}
        acciones = {
            {texto = "Volver a intentar", color = {0.8, 0.2, 0.2}, accion = "reintentar"},
            {texto = "Volver al menú", color = {0.2, 0.4, 0.8}, accion = "menu"}
        }
    elseif tipo == "trampa" then
        mensaje = "¡Caíste en una trampa!"
        color = {1, 0.5, 0}
        acciones = {
            {texto = "Volver a intentar", color = {0.8, 0.2, 0.2}, accion = "reintentar"},
            {texto = "Volver al menú", color = {0.2, 0.4, 0.8}, accion = "menu"}
        }
    elseif tipo == "meta" then
        mensaje = "¡Has completado el juego!"
        color = {0, 1, 0}
        
        -- Actualizar el progreso 
        if _G.actualizarProgreso then
            _G.actualizarProgreso("nivel2")
        end
        
        acciones = {
            {texto = "¡Celebrar!", color = {0.2, 0.8, 0.2}, accion = "victoria"},
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
            -- Reiniciar el motor de física
            physics.start()
            physics.setGravity(0, 0)
            
            -- Determinar la acción a realizar
            if accion.accion == "reintentar" then
                
                display.remove(mensajeGrupo)
                escena.mensajeGrupo = nil
                
                composer.removeScene("nivel2")
                composer.gotoScene("nivel2")
            elseif accion.accion == "menu" then
                
                display.remove(mensajeGrupo)
                escena.mensajeGrupo = nil
                
                composer.removeScene("nivel2")
                composer.gotoScene("menu")
            elseif accion.accion == "victoria" then
                -- Limpiar todas las referencias
                if collisionListenerActive then
                    Runtime:removeEventListener("collision", escena.manejarColision)
                    collisionListenerActive = false
                end
                
                if enterFrameListenerActive then
                    Runtime:removeEventListener("enterFrame", escena.actualizarEnemigos)
                    enterFrameListenerActive = false
                end
                
                -- Asegurarnos de que el mensaje se elimine correctamente
                display.remove(mensajeGrupo) 
                escena.mensajeGrupo = nil
                
                -- Primero ir a la pantalla de victoria
                composer.gotoScene("victoria", {effect = "fade", time = 800})
                
                -- Luego, después de un breve retraso, eliminar la escena nivel2
                timer.performWithDelay(1000, function()
                    if composer.getSceneName("current") ~= "nivel2" then
                        composer.removeScene("nivel2")
                    end
                end)
            end
        end)
    end
    

    escena.mensajeGrupo = mensajeGrupo
end

-- Función para manejar colisiones
local function manejarColision(event)
    if event.phase == "began" then
        local obj1 = event.object1
        local obj2 = event.object2
        
        -- Verificar si ya hay un mensaje activo
        if scene.mensajeActivo then
            return
        end
        
        -- Verificar colisión jugador-enemigo
        if (obj1.tipo == "jugador" and obj2.tipo == "enemigo") or
           (obj1.tipo == "enemigo" and obj2.tipo == "jugador") then
            mostrarMensajeColision(scene, "enemigo")
        end
        
        -- Verificar colisión jugador-trampa (nuevo en nivel 2)
        if (obj1.tipo == "jugador" and obj2.tipo == "trampa") or
           (obj1.tipo == "trampa" and obj2.tipo == "jugador") then
            mostrarMensajeColision(scene, "trampa")
        end
        
        -- Verificar colisión jugador-meta
        if (obj1.tipo == "jugador" and obj2.tipo == "meta") or
           (obj1.tipo == "meta" and obj2.tipo == "jugador") then
            mostrarMensajeColision(scene, "meta")
        end
    end
end

-- Función para actualizar enemigos + Agresiva
local function actualizarEnemigosNivel2()
    -- Verificar si la escena sigue activa
    if not scene.view or scene.mensajeActivo then
        return
    end
    
    for i = 1, #enemigos do
        local e = enemigos[i]
        
        -- Verificar si el enemigo sigue existiendo
        if e and e.parent then
            
            local vx, vy = e:getLinearVelocity()
            
            -- Detectar colisiones con paredes (velocidad reducida drásticamente indica colisión)
            if math.abs(vx) < 20 or math.abs(vy) < 20 then
                -- Cambiar dirección para evitar atasco en esquinas
                e.velocidadX = -e.velocidadX * 1.2 + math.random(-40, 40)
                e.velocidadY = -e.velocidadY * 1.2 + math.random(-40, 40)
                
                -- Asegurar una velocidad mínima mayor para evitar estancamiento
                if math.abs(e.velocidadX) < 50 then
                    e.velocidadX = e.velocidadX < 0 and -50 or 50
                end
                if math.abs(e.velocidadY) < 50 then
                    e.velocidadY = e.velocidadY < 0 and -50 or 50
                end
                
                -- Aplicar un impulso  para salir de la esquina
                e:applyLinearImpulse(e.velocidadX * 0.8, e.velocidadY * 0.8, e.x, e.y)
            end
            
            -- Comportamiento más impredecible para nivel 2
            if math.random(1, 100) <= 4 then 
                
                e.velocidadX = e.velocidadX + math.random(-30, 30)
                e.velocidadY = e.velocidadY + math.random(-30, 30)
                
                -- Seguir al jugador ocasionalmente (comportamiento de persecución)
                if jugador and jugador.parent and math.random(1, 100) <= 30 then
                    local dx = jugador.x - e.x
                    local dy = jugador.y - e.y
                    -- Añadir componente de persecución a la velocidad
                    e.velocidadX = e.velocidadX + (dx > 0 and 20 or -20)
                    e.velocidadY = e.velocidadY + (dy > 0 and 20 or -20)
                end
                
                local maxVelocidad = 110
                if math.abs(e.velocidadX) > maxVelocidad then
                    e.velocidadX = e.velocidadX > 0 and maxVelocidad or -maxVelocidad
                end
                if math.abs(e.velocidadY) > maxVelocidad then
                    e.velocidadY = e.velocidadY > 0 and maxVelocidad or -maxVelocidad
                end
            end
            
            -- Aplicar velocidad
            e:setLinearVelocity(e.velocidadX, e.velocidadY)
            
            -- Girar el enemigo en la dirección del movimiento 
            if math.abs(vx) > math.abs(vy) then
                -- Movimiento horizontal predominante
                if vx > 0 then
                    e.rotation = 12  
                else
                    e.rotation = -12 
                end
            else
                -- Movimiento vertical predominante
                if vy > 0 then
                    e.rotation = 8  
                else
                    e.rotation = -8 
                end
            end
            
            -- Efecto visual de pulso cuando está cerca del jugador
            if jugador and jugador.parent then
                local distancia = math.sqrt((e.x - jugador.x)^2 + (e.y - jugador.y)^2)
                if distancia < 150 and not e.pulsando then
                    e.pulsando = true
                    transition.to(e, {
                        time = 300,
                        xScale = 1.2,
                        yScale = 1.2,
                        iterations = 2,
                        transition = easing.continuousLoop,
                        onComplete = function() 
                            if e and e.parent then
                                e.pulsando = false 
                            end
                        end
                    })
                end
            end
        end
    end
end

-- Función para mover el jugador
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
        -- Reiniciar el motor de física
        physics.start()
        physics.setGravity(0, 0)
        
        -- Limpiar variables de control
        scene.mensajeActivo = false
        
        -- Añadir escuchadores de eventos
        scene.manejarColision = manejarColision
        scene.actualizarEnemigos = actualizarEnemigosNivel2
        scene.moverJugador = moverJugador
        
        Runtime:addEventListener("collision", manejarColision)
        collisionListenerActive = true
        
        btnArriba:addEventListener("touch", moverJugador)
        btnAbajo:addEventListener("touch", moverJugador)
        btnIzquierda:addEventListener("touch", moverJugador)
        btnDerecha:addEventListener("touch", moverJugador)
        
        Runtime:addEventListener("enterFrame", actualizarEnemigosNivel2)
        enterFrameListenerActive = true
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Remover todos los listeners
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
            Runtime:removeEventListener("enterFrame", actualizarEnemigosNivel2)
            enterFrameListenerActive = false
        end
        
        -- Limpiar cualquier mensaje activo
        if scene.mensajeGrupo then
            display.remove(scene.mensajeGrupo)
            scene.mensajeGrupo = nil
        end
        
        -- Detener física antes de cambiar de escena
        physics.pause()
    elseif phase == "did" then
        
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    
    -- Limpiar memoria si es necesario 
    if scene.mensajeGrupo then
        display.remove(scene.mensajeGrupo)
        scene.mensajeGrupo = nil
    end
    
    -- Limpiar las referencias a objetos
    jugador = nil
    muros = {}
    enemigos = {}
    trampas = {}
    meta = nil
    
    -- Asegurarse de que todas las transiciones se detengan
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