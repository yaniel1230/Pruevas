local NPC_ID = 55000 -- Cambia este ID por uno único en tu servidor
local MONEDA_VIP_ENTRY = 12345 -- Reemplaza con el ID real de tu moneda VIP
local PRECIO_CAMBIO = 1 -- Cantidad de monedas VIP requeridas

-- Razas disponibles en WotLK 3.3.5a
local RAZAS = {
    [1] = {"Humano", 0},
    [2] = {"Orco", 1},
    [3] = {"Enano", 0},
    [4] = {"Elfo de la Noche", 0},
    [5] = {"No Muerto", 1},
    [6] = {"Tauren", 1},
    [7] = {"Gnomo", 0},
    [8] = {"Trol", 1},
    [10] = {"Elfo de Sangre", 1},
    [11] = {"Draenei", 0}
}

local function MostrarMenuPrincipal(player, creature)
    local tieneMoneda = player:GetItemCount(MONEDA_VIP_ENTRY) >= PRECIO_CAMBIO
    local colorFaccion = player:GetTeam() == 0 and "|cFF0078FF" or "|cFFFF0000"
    
    player:GossipClearMenu()
    player:GossipSetText(string.format("%s¡Saludos, %s!|r\n\nPuedo cambiar tu raza o facción por |cFFFFD700%d Moneda VIP|r.\n\nTienes: %s%d|r monedas VIP",
        colorFaccion, player:GetName(),
        PRECIO_CAMBIO,
        tieneMoneda and "|cFF00FF00" or "|cFFFF0000", player:GetItemCount(MONEDA_VIP_ENTRY)
    ))
    
    if tieneMoneda then
        player:GossipMenuAddItem(0, "Cambiar raza (misma facción)", 0, 1)
        player:GossipMenuAddItem(0, "Cambiar de facción", 0, 2)
    end
    
    player:GossipMenuAddItem(0, "¿Cómo obtener Monedas VIP?", 0, 3)
    player:GossipMenuAddItem(0, "Salir", 0, 4)
    
    player:GossipSendMenu(1, creature)
end

local function OnGossipHello(event, player, creature)
    MostrarMenuPrincipal(player, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then -- Menú de cambio de raza
        player:GossipClearMenu()
        local currentFaction = player:GetTeam()
        
        for raceId, raceInfo in pairs(RAZAS) do
            if raceInfo[2] == currentFaction then
                player:GossipMenuAddItem(0, raceInfo[1], 0, 10 + raceId)
            end
        end
        
        player:GossipMenuAddItem(0, "Volver", 0, 100)
        player:GossipSendMenu(1, creature)
        
    elseif intid == 2 then -- Menú de cambio de facción
        player:GossipClearMenu()
        player:GossipMenuAddItem(0, "Cambiar a Alianza", 0, 30, false, "¿Estás seguro de unirte a la Alianza? Perderás acceso a ciudades de la Horda.")
        player:GossipMenuAddItem(0, "Cambiar a Horda", 0, 31, false, "¿Estás seguro de unirte a la Horda? Perderás acceso a ciudades de la Alianza.")
        player:GossipMenuAddItem(0, "Volver", 0, 100)
        player:GossipSendMenu(1, creature)
        
    elseif intid == 3 then -- Info monedas VIP
        player:SendBroadcastMessage("|cFFFFD700Monedas VIP|r se pueden obtener:")
        player:SendBroadcastMessage("- Comprando en la |cFF00FF00Tienda del Juego|r")
        player:SendBroadcastMessage("- Con el |cFF00FF00NPC Vendedor VIP|r en la Isla Castilvania")
        player:SendBroadcastMessage("- Participando en eventos especiales del servidor")
        player:GossipComplete()
        
    elseif intid == 4 then -- Salir
        player:GossipComplete()
        
    elseif intid >= 11 and intid <= 21 then -- Cambio de raza (10 + raceId)
        local raceId = intid - 10
        if RAZAS[raceId] then
            if player:GetRace() ~= raceId then
                if player:RemoveItem(MONEDA_VIP_ENTRY, PRECIO_CAMBIO) then
                    player:SetRace(raceId)
                    player:SendBroadcastMessage(string.format("|cFF00FF00¡Ahora eres un %s!|r", RAZAS[raceId][1]))
                else
                    player:SendBroadcastMessage("|cFFFF0000Error al procesar el pago.|r")
                end
            else
                player:SendBroadcastMessage("|cFFFF0000¡Ya eres de esa raza!|r")
            end
            player:GossipComplete()
        end
        
    elseif intid == 30 or intid == 31 then -- Cambio de facción
        local newFaction = (intid == 30) and 0 or 1
        
        if player:GetTeam() ~= newFaction then
            if player:RemoveItem(MONEDA_VIP_ENTRY, PRECIO_CAMBIO) then
                -- Encontrar una raza de la nueva facción
                local newRace
                for raceId, raceInfo in pairs(RAZAS) do
                    if raceInfo[2] == newFaction then
                        newRace = raceId
                        break
                    end
                end
                
                if newRace then
                    player:SetRace(newRace)
                    player:SendBroadcastMessage(string.format("|cFF00FF00¡Ahora eres %s de la %s!|r", 
                        RAZAS[newRace][1], 
                        newFaction == 0 and "Alianza" or "Horda"))
                end
            else
                player:SendBroadcastMessage("|cFFFF0000Error al procesar el pago.|r")
            end
        else
            player:SendBroadcastMessage("|cFFFF0000¡Ya eres de esa facción!|r")
        end
        player:GossipComplete()
        
    elseif intid == 100 then -- Volver al menú principal
        MostrarMenuPrincipal(player, creature)
    end
end

local function OnSpawn(event, creature)
    creature:SetNPCFlags(1) -- Flag para gossip
end

RegisterCreatureEvent(NPC_ID, 5, OnSpawn) -- EVENT_ON_SPAWN
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello) -- GOSSIP_EVENT_ON_HELLO
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect) -- GOSSIP_EVENT_ON_SELECT
