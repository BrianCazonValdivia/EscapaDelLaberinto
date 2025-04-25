-----------------------------------------------------------------------------------------
-- Módulo del jugador
-----------------------------------------------------------------------------------------

local M = {}

function M.nuevo(x, y)
    local grupo = display.newGroup()
    
    local options = {
        width = 34.2,        
        height = 40,       
        numFrames = 20,     
        sheetContentWidth = 171,    
        sheetContentHeight = 160   
    }
    
    local sheet = graphics.newImageSheet("ninja_spritesheet.png", options)
    
    local secuencias = {
        {
            name = "quieto",
            frames = { 8 },
            time = 800,
            loopCount = 0
        },
        {
            name = "derecha",
            frames = { 1, 2, 3, 4, 5},
            time = 500,
            loopCount = 0
        },
        {
            name = "izquierda",
            frames = { 11,12, 13, 14, 15 },
            time = 500,
            loopCount = 0
        },
        {
            name = "arriba",
            frames = { 16, 17, 18, 19, 20 },
            time = 500,
            loopCount = 0
        },
        {
            name = "abajo",
            frames = { 6, 7, 8, 9, 10 },
            time = 500,
            loopCount = 0
        }
    }
    
    local sprite = display.newSprite(grupo, sheet, secuencias)
    sprite:setSequence("quieto")
    sprite:play()
    
    sprite.xScale = 1  
    sprite.yScale = 1
    
    
    local radius = 15    
    physics.addBody(grupo, "dynamic", {
        density = 1.0,
        friction = 0.5,
        bounce = 0.2,
        radius = radius
    })
    
    grupo.x = x
    grupo.y = y
    
    grupo.tipo = "jugador"
    
    local movimientoActivo = {
        arriba = false,
        abajo = false,
        izquierda = false,
        derecha = false
    }
    
    function grupo:mover(vx, vy, direccion)
        
        movimientoActivo[direccion] = true
        --Movimiento segun la dirección
        if movimientoActivo.derecha and not movimientoActivo.izquierda then
            sprite:setSequence("derecha")
            sprite:play()
        elseif movimientoActivo.izquierda and not movimientoActivo.derecha then
            sprite:setSequence("izquierda")
            sprite:play()
        elseif movimientoActivo.arriba and not movimientoActivo.abajo then
            sprite:setSequence("arriba")
            sprite:play()
        elseif movimientoActivo.abajo and not movimientoActivo.arriba then
            sprite:setSequence("abajo")
            sprite:play()
        end
        
        self:setLinearVelocity(
            (movimientoActivo.derecha and 90 or 0) + (movimientoActivo.izquierda and -90 or 0),
            (movimientoActivo.abajo and 90 or 0) + (movimientoActivo.arriba and -90 or 0)
        )
    end
    
    function grupo:detener(direccion)
        movimientoActivo[direccion] = false
        
        if not (movimientoActivo.arriba or movimientoActivo.abajo or 
                movimientoActivo.izquierda or movimientoActivo.derecha) then
            
            self:setLinearVelocity(0, 0)
            
            sprite:setSequence("quieto")
            sprite:play()
        else
            -- Recalcular velocidad basada en teclas activas
            self:setLinearVelocity(
                (movimientoActivo.derecha and 90 or 0) + (movimientoActivo.izquierda and -90 or 0),
                (movimientoActivo.abajo and 90 or 0) + (movimientoActivo.arriba and -90 or 0)
            )
            
            -- Actualizar animación 
            if movimientoActivo.derecha and not movimientoActivo.izquierda then
                sprite:setSequence("derecha")
                sprite:play()
            elseif movimientoActivo.izquierda and not movimientoActivo.derecha then
                sprite:setSequence("izquierda")
                sprite:play()
            elseif movimientoActivo.arriba and not movimientoActivo.abajo then
                sprite:setSequence("arriba")
                sprite:play()
            elseif movimientoActivo.abajo and not movimientoActivo.arriba then
                sprite:setSequence("abajo")
                sprite:play()
            end
        end
    end
    
    return grupo
end

return M