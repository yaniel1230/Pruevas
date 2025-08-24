local NPC_ID = 190000 -- ID personalizado para el NPC
local GOLD_COST = 100000 -- 10 de oro (100000 cobre)
local COOLDOWN = 86400 -- 24 horas en segundos (opcional)

local RACES = {
    [1] = "Humano",      [2] = "Orco",        [3] = "Enano",
    [4] = "Elfo de la Noche", [5] = "No-Muerto",  [6] = "Tauren",
    [7] = "Gnomo",       [8] = "Trol",        [10] = "Sangre Elfo",
    [11] = "Draenei"
}

local FACTION_RACES = {
    ALLIANCE = {1, 3, 4, 7, 11},
    HORDE = {2, 5, 6, 8, 10}
}

local function GetRandomRace(player)
    local currentRace = player:GetRace()
    local team = player:GetTeam()
    
    local availableRaces = {}
    if team == 0 then -- Alianza
        availableRaces = FACTION_RACES.ALLIANCE
    else -- Horda
        availableRaces = FACTION_RACES.HORDE
    end
    
    -- Filtrar la raza actual
    local possibleRaces = {}
    for _, raceId in ipairs(availableRaces) do
        if raceId ~= currentRace then
            table.insert(possibleRaces, raceId)
        end
    end
    
    if #possibleRaces == 0 then
        return nil
    end
    
    return possibleRaces[math.random(#possibleRaces)]
end

local function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\inv_misc_coin_01:30:30:-15:0|t Cambio de Raza Aleatorio", 0, 1)
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\spell_chargepositive:30:30:-15:0|t Información", 0, 2)
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\achievement_general:30:30:-15:0|t Salir", 0, 3)
    
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then -- Cambio de raza
        if not player:HasEnoughMoney(GOLD_COST) then
            creature:SendUnitSay("No tienes suficiente oro. El costo es de " .. (GOLD_COST/10000) .. " de oro.", 0)
            player:GossipComplete()
            return
        end
        
        local newRace = GetRandomRace(player)
        if not newRace then
            creature:SendUnitSay("No hay razas disponibles para tu facción.", 0)
            player:GossipComplete()
            return
        end
        
        -- Confirmación
        player:GossipClearMenu()
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\inv_misc_coin_01:30:30:-15:0|t Confirmar (" .. (GOLD_COST/10000) .. " oro)", 0, 10, false, "¿Estás seguro de cambiar a " .. RACES[newRace] .. "?")
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\spell_chargenegative:30:30:-15:0|t Cancelar", 0, 11)
        player:GossipSendMenu(1, creature)
        
    elseif intid == 2 then -- Información
        creature:SendUnitSay("Te cambiaré a una raza aleatoria de tu facción por " .. (GOLD_COST/10000) .. " de oro.", 0)
        player:GossipComplete()
        
    elseif intid == 3 then -- Salir
        player:GossipComplete()
        
    elseif intid == 10 then -- Confirmar cambio
        player:ModifyMoney(-GOLD_COST)
        player:SetRace(GetRandomRace(player))
        creature:SendUnitSay("¡Cambio de raza completado! Bienvenido a tu nueva forma.", 0)
        player:GossipComplete()
        
    elseif intid == 11 then -- Cancelar
        creature:SendUnitSay("Cambio cancelado.", 0)
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)

-- Comando de consola para registrar el NPC (opcional)
print("NPC de cambio de raza cargado. ID: " .. NPC_ID)
