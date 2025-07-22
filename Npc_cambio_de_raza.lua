local NPC_ID = 55000 -- ID único para tu NPC
local PRECIO_ORO = 1000000 -- 10 de oro (en cobre: 1,000,000 = 10 oro)
local TEXTO_PRECIO = "10 de oro" -- Texto para mostrar el precio

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

local function TieneSuficienteOro(player)
    return player:GetCoinage() >= PRECIO_ORO
end

local function MostrarMenuPrincipal(player, creature)
    local tieneOro = TieneSuficienteOro(player)
    local colorFaccion = player:GetTeam() == 0 and "|cFF0078FF" or "|cFFFF0000"
    local oroActual = player:GetCoinage()
    
    -- Formatear el oro para mostrarlo bonito
    local oro, plata, cobre = math.floor(oroActual/10000), math.floor((oroActual%10000)/100), oroActual%100
    local textoOro = string.format("|cFFFFD700%d|r.|cFFC0C0C0%d|r.|cFFCD7F32%d|r", oro, plata, cobre)
    
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Información de Precios", 0, 3)
    
    if tieneOro then
        player:GossipMenuAddItem(0, "Cambiar raza (misma facción)", 0, 1)
        player:GossipMenuAddItem(0, "Cambiar de facción", 0, 2)
    else
        player:GossipMenuAddItem(0, "|cFFFF0000Necesitas "..TEXTO_PRECIO.."|r", 0, 0)
    end
    
    player:GossipMenuAddItem(0, "Salir", 0, 4)
    
    player:GossipSendMenu(1, creature, string.format("%s¡Saludos, %s!|r\n\nPuedo cambiar tu raza o facción por %s.\n\nTu oro actual: %s",
        colorFaccion, player:GetName(),
        TEXTO_PRECIO,
        textoOro
    ))
end

local function CobrarServicio(player)
    if TieneSuficienteOro(player) then
        player:ModifyMoney(-PRECIO_ORO)
        return true
    end
    return false
end

local function OnGossipHello(event, player, creature)
    MostrarMenuPrincipal(player, creature)
    return true
end

local function OnGossipSelect(event, player, creature, sender, intid, code, menuid)
    if intid == 0 then
        player:GossipComplete()
        return
    end

    -- Menú de cambio de raza
    if intid == 1 then
        player:GossipClearMenu()
        local currentFaction = player:GetTeam()
        
        for raceId, raceInfo in pairs(RAZAS) do
            if raceInfo[2] == currentFaction then
                player:GossipMenuAddItem(3, raceInfo[1], 0, 10 + raceId, false, "¿Estás seguro de cambiar tu raza a "..raceInfo[1].." por "..TEXTO_PRECIO.."?")
            end
        end
        
        player:GossipMenuAddItem(0, "Volver", 0, 100)
        player:GossipSendMenu(1, creature)
        return
    end

    -- Menú de cambio de facción
    if intid == 2 then
        player:GossipClearMenu()
        player:GossipMenuAddItem(3, "Cambiar a Alianza", 0, 30, false, "¿Estás seguro de unirte a la Alianza por "..TEXTO_PRECIO.."? Perderás acceso a ciudades de la Horda.")
        player:GossipMenuAddItem(3, "Cambiar a Horda", 0, 31, false, "¿Estás seguro de unirte a la Horda por "..TEXTO_PRECIO.."? Perderás acceso a ciudades de la Alianza.")
        player:GossipMenuAddItem(0, "Volver", 0, 100)
        player:GossipSendMenu(1, creature)
        return
    end

    -- Info precios
    if intid == 3 then
        player:SendBroadcastMessage("|cFFFFD700Precios de servicios:|r")
        player:SendBroadcastMessage("- Cambio de raza: "..TEXTO_PRECIO)
        player:SendBroadcastMessage("- Cambio de facción: "..TEXTO_PRECIO)
        player:GossipComplete()
        return
    end

    -- Salir
    if intid == 4 then
        player:GossipComplete()
        return
    end

    -- Cambio de raza (10 + raceId)
    if intid >= 11 and intid <= 21 then
        local raceId = intid - 10
        if RAZAS[raceId] then
            if player:GetRace() ~= raceId then
                if CobrarServicio(player) then
                    player:SetRace(raceId)
                    player:SendBroadcastMessage(string.format("|cFF00FF00¡Ahora eres un %s!|r (Costo: %s)", RAZAS[raceId][1], TEXTO_PRECIO))
                else
                    player:SendBroadcastMessage("|cFFFF0000No tienes suficiente oro.|r")
                end
            else
                player:SendBroadcastMessage("|cFFFF0000¡Ya eres de esa raza!|r")
            end
        end
        player:GossipComplete()
        return
    end

    -- Cambio de facción
    if intid == 30 or intid == 31 then
        local newFaction = (intid == 30) and 0 or 1
        
        if player:GetTeam() ~= newFaction then
            if CobrarServicio(player) then
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
                    player:SendBroadcastMessage(string.format("|cFF00FF00¡Ahora eres %s de la %s!|r (Costo: %s)", 
                        RAZAS[newRace][1], 
                        newFaction == 0 and "Alianza" or "Horda",
                        TEXTO_PRECIO))
                end
            else
                player:SendBroadcastMessage("|cFFFF0000No tienes suficiente oro.|r")
            end
        else
            player:SendBroadcastMessage("|cFFFF0000¡Ya eres de esa facción!|r")
        end
        player:GossipComplete()
        return
    end

    -- Volver al menú principal
    if intid == 100 then
        MostrarMenuPrincipal(player, creature)
        return
    end
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
