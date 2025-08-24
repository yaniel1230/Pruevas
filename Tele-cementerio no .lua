local function OnPlayerDie(event, player)
    -- Verificar que el jugador existe y está en un mapa válido
    if not player or not player:GetMap() then
        return
    end
    
    local map = player:GetMap()
    
    -- Verificar si el jugador está en una mazmorra o raid
    if map:IsDungeon() or map:IsRaid() then
        -- Obtener información del grupo para evitar teletransportar si hay grupo activo
        local group = player:GetGroup()
        if group and group:GetMembersCount() > 1 then
            -- No teletransportar si el jugador está en grupo
            return
        end
        
        -- Obtener la entrada de la instancia
        local entrance = map:GetEntrance()
        if entrance then
            -- Eliminar el cadáver inmediatamente
            player:SetCorpseDelay(0)
            
            -- Revivir al jugador con 50% de salud/maná
            player:ResurrectPlayer(50)
            
            -- Teletransportar a la entrada de la instancia
            player:Teleport(entrance[1], entrance[2], entrance[3], entrance[4])
            
            -- Enviar mensaje al jugador
            player:SendBroadcastMessage("Has sido teletransportado a la entrada de la instancia.")
        else
            -- Fallback: enviar al cementerio más cercano
            player:RepopAtGraveyard()
            player:SendBroadcastMessage("No se pudo encontrar la entrada de la instancia. Has sido enviado al cementerio.")
        end
    end
end

-- Registrar el evento de muerte del jugador
RegisterPlayerEvent(8, OnPlayerDie) -- EVENT_ON_DIE

-- Comando opcional para activar/desactivar esta función
local function ToggleAutoTeleport(event, player, command)
    if command == "toggleautotp" then
        local autoTP = player:GetData("AutoTP")
        if autoTP == nil then
            autoTP = true -- Valor por defecto
        end
        
        player:SetData("AutoTP", not autoTP)
        
        if not autoTP then
            player:SendBroadcastMessage("Teletransporte automático ACTIVADO.")
        else
            player:SendBroadcastMessage("Teletransporte automático DESACTIVADO.")
        end
        
        return false
    end
end

-- Registrar el evento de comando
RegisterPlayerEvent(42, ToggleAutoTeleport) -- EVENT_ON_COMMAND
