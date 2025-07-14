local NPC_ENTRY = 50000 -- DEBES configurar este ID con uno válido de tu creature_template
local WELCOME_DISTANCE = 2 -- Yardas (rango de bienvenida)
local COOLDOWN = 30 -- Segundos entre saludos
local GREET_MESSAGE = "¡Bienvenido a la Isla Castilvania, |cFF00FF00%s|r! Que las sombras te protejan."

-- Efectos compatibles con la tabla spell.dbc
local FIREWORK_SPELLS = {
    26344,  -- Red Firework
    26345,  -- Blue Firework
    26346,  -- Green Firework
    26351   -- Large Red Firework
}

local greetedPlayers = {}

-- Función optimizada para AzerothCore
local function PlayFireworks(creature)
    if not creature or not creature:IsInWorld() then return end
    
    -- Lanzar efecto principal
    creature:CastSpell(creature, FIREWORK_SPELLS[math.random(#FIREWORK_SPELLS)], false)
    
    -- Secuencia de efectos secundarios
    for i = 1, 2 do
        creature:RegisterEvent(function()
            if creature and creature:IsInWorld() then
                creature:CastSpell(creature, FIREWORK_SPELLS[math.random(#FIREWORK_SPELLS)], false)
            end
        end, i * 800, 1) -- 0.8 segundos entre efectos
    end
end

-- Gossip Hello - Compatible con la tabla gossip_menu
local function OnGossipHello(event, player, creature)
    player:GossipClearMenu() -- Limpiar menú previo
    
    -- Añadir opciones usando AddGossipItemForPlayer
    player:GossipMenuAddItem(0, "¿Qué es este lugar?", 0, 1, false, "Siempre curioso, ¿eh?")
    player:GossipMenuAddItem(0, "¿Por qué los fuegos artificiales?", 0, 2)
    player:GossipMenuAddItem(0, "Adiós", 0, 3)
    
    -- Enviar menú usando SendGossipMenu
    player:GossipSendMenu(0x7FFFFFFF, creature) -- Usando menu_id estándar
end

-- Gossip Select - Compatible con gossip_menu_option
local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then
        player:GossipComplete()
        creature:SendUnitSay("La Isla Castilvania es un lugar de secretos ancestrales. ¡Explora con cuidado!", 0)
    elseif intid == 2 then
        player:GossipComplete()
        creature:SendUnitSay("Es nuestra tradición dar la bienvenida con fuegos de alegría!", 0)
        PlayFireworks(creature)
    elseif intid == 3 then
        player:GossipComplete()
    end
end

-- Evento de movimiento optimizado
local function OnPlayerMove(event, player)
    if not player or not player:IsInWorld() then return end
    
    local creature = player:GetNearestCreature(WELCOME_DISTANCE, NPC_ENTRY)
    if not creature then return end
    
    local guid = player:GetGUID():GetCounter()
    local now = GetGameTime()
    
    if not greetedPlayers[guid] or (now - greetedPlayers[guid]) > COOLDOWN then
        greetedPlayers[guid] = now
        creature:SendUnitSay(string.format(GREET_MESSAGE, player:GetName()), 0)
        PlayFireworks(creature)
        
        -- Compatible con la tabla creature_text
        creature:SendUnitYell("¡Un nuevo visitante para Castilvania!", 0)
    end
end

-- Registro de eventos seguro
local function OnServerStart(event)
    -- Verificar que el NPC existe en creature_template
    local result = CharDBQuery("SELECT entry FROM creature_template WHERE entry = "..NPC_ENTRY)
    if not result then
        print("[Castilvania NPC] Error: NPC entry "..NPC_ENTRY.." no existe en creature_template!")
        return
    end
    
    -- Registrar eventos solo si el NPC existe
    RegisterCreatureGossipEvent(NPC_ENTRY, 1, OnGossipHello)
    RegisterCreatureGossipEvent(NPC_ENTRY, 2, OnGossipSelect)
    RegisterPlayerEvent(27, OnPlayerMove) -- EVENT_ON_PLAYER_MOVE
    
    print("[Castilvania NPC] NPC de bienvenida cargado correctamente para entry "..NPC_ENTRY)
end

RegisterServerEvent(33, OnServerStart) -- EVENT_ON_SERVER_START
