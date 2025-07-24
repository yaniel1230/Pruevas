local NPC_ID = 99999 -- ¡Cambia este ID por uno único en tu DB!

-- Configuración (ajusta estos valores)
local EXP_TO_GOLD_RATE = 0.1  -- 1 EXP = 0.1 de oro (en plata)
local GOLD_TO_EXP_RATE = 100  -- 100 de oro = 1 EXP
local MIN_LEVEL = 10          -- Nivel mínimo para usar el NPC

-- Función para formatear el oro (cobre, plata, oro)
local function FormatMoney(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copper = copper % 100
    return string.format("%dg %ds %dc", gold, silver, copper)
end

-- Menú principal
local function OnGossipHello(event, player, creature)
    -- Verificar nivel mínimo
    if (player:GetLevel() < MIN_LEVEL) then
        player:GossipMenuAddItem(0, "|cFFFF0000Requieres nivel "..MIN_LEVEL.." para usar este servicio.|r", 0, 99)
    else
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\achievement_guildperk_mobilebanking:25|t |cFF00FF00Intercambio de Experiencia y Oro|r", 0, 99)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\inv_misc_coin_01:25|t Comprar EXP con Oro", 0, 2)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\spell_magic_lesserinvisibilty:25|t Vender EXP por Oro", 0, 3)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\inv_misc_book_11:25|t Ver mis recursos", 0, 4)
    end
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\spell_shadow_teleport:25|t Salir", 0, 5)
    player:GossipSendMenu(1, creature)
end

-- Procesar selección del menú
local function OnGossipSelect(event, player, creature, sender, intid, code)
    -- Comprar EXP con Oro (pedir cantidad)
    if (intid == 2) then
        player:GossipMenuAddItem(0, "|cFF00FF00Escribe la cantidad de |cFFFFD700ORO|r a gastar:|r", 0, 20, true)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\spell_shadow_teleport:25|t Cancelar", 0, 1)
        player:GossipSendMenu(1, creature)
    
    -- Vender EXP por Oro (pedir cantidad)
    elseif (intid == 3) then
        player:GossipMenuAddItem(0, "|cFF00FF00Escribe la cantidad de |cFF00FF00EXP|r a vender:|r", 0, 30, true)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\spell_shadow_teleport:25|t Cancelar", 0, 1)
        player:GossipSendMenu(1, creature)
    
    -- Ver recursos del jugador
    elseif (intid == 4) then
        local currentGold = player:GetCoinage()
        local currentXP = player:GetXP()
        player:SendBroadcastMessage(string.format("|cFF00FF00Tus recursos:|r\n|cFFFFD700Oro:|r %s\n|cFF00FF00Experiencia:|r %d XP", FormatMoney(currentGold), currentXP))
        player:GossipComplete()
    
    -- Salir
    elseif (intid == 5) then
        player:GossipComplete()
    end
end

-- Procesar entrada de texto (Oro → EXP)
local function OnGossipInputGoldToExp(event, player, creature, sender, intid, code)
    if (intid == 20) then
        local goldAmount = tonumber(code)
        if (not goldAmount or goldAmount <= 0) then
            player:SendNotification("|cFFFF0000¡Cantidad inválida!|r")
            return
        end
        
        local playerGold = player:GetCoinage()
        local goldCopper = goldAmount * 10000  -- Convertir oro a cobre
        
        if (playerGold < goldCopper) then
            player:SendNotification(string.format("|cFFFF0000¡No tienes suficiente oro! (Necesitas %s)|r", FormatMoney(goldCopper)))
            return
        end
        
        local expToAdd = goldAmount * GOLD_TO_EXP_RATE
        player:ModifyMoney(-goldCopper)
        player:GiveXP(expToAdd)
        player:CastSpell(player, 43927, true)  -- Efecto visual de monedas
        player:SendBroadcastMessage(string.format("|cFF00FF00¡Has comprado |cFF00FF00%d EXP|r por |cFFFFD700%s|r!|r", expToAdd, FormatMoney(goldCopper)))
        player:GossipComplete()
    end
end

-- Procesar entrada de texto (EXP → Oro)
local function OnGossipInputExpToGold(event, player, creature, sender, intid, code)
    if (intid == 30) then
        local expAmount = tonumber(code)
        if (not expAmount or expAmount <= 0) then
            player:SendNotification("|cFFFF0000¡Cantidad inválida!|r")
            return
        end
        
        local playerXP = player:GetXP()
        if (playerXP < expAmount) then
            player:SendNotification(string.format("|cFFFF0000¡No tienes suficiente EXP! (Tienes %d)|r", playerXP))
            return
        end
        
        local goldToAdd = expAmount * EXP_TO_GOLD_RATE
        local goldCopper = goldToAdd * 10000  -- Convertir a cobre
        player:GiveXP(-expAmount)
        player:ModifyMoney(goldCopper)
        player:CastSpell(player, 47292, true)  -- Efecto visual de energía
        player:SendBroadcastMessage(string.format("|cFF00FF00¡Has vendido |cFF00FF00%d EXP|r por |cFFFFD700%s|r!|r", expAmount, FormatMoney(goldCopper)))
        player:GossipComplete()
    end
end

-- Registrar eventos
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)          -- Menú principal
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)         -- Opciones
RegisterCreatureGossipEvent(NPC_ID, 20, OnGossipInputGoldToExp) -- Oro → EXP
RegisterCreatureGossipEvent(NPC_ID, 30, OnGossipInputExpToGold) -- EXP → Oro
