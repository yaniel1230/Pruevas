local function OnGossipHello(event, player, creature)
    -- Añadir opción de teletransporte
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_Arcade_Teleport:35:35:-15:0|t Teletransportarme al Cráter de Azhara", 0, 1, false, "¿Estás seguro de que quieres teleportarte al Cráter de Azhara?")
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if (intid == 1) then
        -- Coordenadas del Cráter de Azhara (Kalimdor)
        local x = 26.0
        local y = -77.0
        local z = 6.0
        local o = 0.0
        local mapId = 1  -- Mapa de Kalimdor
        
        -- Teletransportar al jugador
        player:Teleport(mapId, x, y, z, o)
        player:GossipComplete()
    end
end

local function OnGossipSelectWithCode(event, player, creature, sender, intid, code)
    -- No se necesita código en este caso
end

RegisterCreatureGossipEvent(ENTRY_ID_DEL_NPC, 1, OnGossipHello)
RegisterCreatureGossipEvent(ENTRY_ID_DEL_NPC, 2, OnGossipSelect)
RegisterCreatureGossipEvent(ENTRY_ID_DEL_NPC, 3, OnGossipSelectWithCode)
