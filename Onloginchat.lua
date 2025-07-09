function OnLoginJoin(event, player)
    -- Enviar mensaje de bienvenida a todos los jugadores
    player:SendAreaTriggerMessage("Bienvenido a DeluxeEch")
    
    -- Opción 1: Menú de gossip estándar (recomendado)
    if player:GetGMRank() > 0 then  -- Si es GM (rango > 0)
        player:GossipMenuAddItem(0, "Opciones para GM", 0, 1)
    else
        player:GossipMenuAddItem(0, "Opciones para jugador", 0, 1)
    end
    player:GossipSendMenu(556409, player)  -- Enviar el menú
    
    -- Opción 2: Si realmente necesitas una función personalizada como GoasiglendMenu
    -- (debes asegurarte que esté registrada en el core)
    -- player:GoasiglendMenu(556409, player, 1)  -- Último parámetro debe ser numérico
end

RegisterPlayerEvent(3, OnLoginJoin)  -- 3 = PLAYER_EVENT_ON_LOGIN
