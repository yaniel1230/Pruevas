local NPC_ID = 100077
local MAX_PVP_RANGE = 70 -- metros
local SCAN_INTERVAL = 3000 -- ms (3 segundos)
local WARNING_MESSAGE = "¡El combate JcJ no está permitido en esta zona cuando los jugadores están a más de 70 metros de distancia!"
local JAIL_LOCATION = {map = 1, x = -10772.6, y = -3792.67, z = 22.9, o = 1.54} -- Jaula debajo de Isla MJ
local STUN_SPELL = 13005 -- Aturdir (6 segundos)

-- Función optimizada para verificar PvP
local function IsPvPActive(player)
    return player:IsPvP() or player:IsFFAPvP() or player:IsInSanctuary() or player:IsHostileToPlayers()
end

-- Función de distancia compatible con 3.3.5
local function GetDistanceBetweenPlayers(player1, player2)
    if player1:GetMapId() ~= player2:GetMapId() then
        return math.huge
    end
    local x1, y1, z1 = player1:GetLocation()
    local x2, y2, z2 = player2:GetLocation()
    return math.sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
end

-- Función de teletransporte segura
local function TeleportToJail(player)
    if not player then return end
    
    -- Detener cualquier combate
    player:CombatStop()
    player:RemoveAllAuras()
    
    -- Aplicar aturdimiento antes del teleport
    player:CastSpell(player, STUN_SPELL, true)
    
    -- Mensaje al jugador
    player:SendBroadcastMessage("|cFFFF0000[Guardian Anti-PvP]|r Has sido enviado a la jaula por violar las reglas de JcJ.")
    
    -- Teletransporte seguro con verificación
    if JAIL_LOCATION.map and JAIL_LOCATION.x then
        player:Teleport(JAIL_LOCATION.map, JAIL_LOCATION.x, JAIL_LOCATION.y, JAIL_LOCATION.z, JAIL_LOCATION.o)
    else
        player:Teleport(0, -9000, -3000, 100, 0) -- Ubicación alternativa si hay error
    end
end

-- Función principal de detección PvP
local function HandlePvP(eventId, delay, repeats, creature)
    if not creature or not creature:IsInWorld() then return end
    
    local players = creature:GetPlayersInRange(MAX_PVP_RANGE * 1.5)
    if not players then return end
    
    local pvpParticipants = {}
    
    -- Primera pasada: identificar jugadores en PvP
    for _, player in pairs(players) do
        if player and player:IsInWorld() and IsPvPActive(player) then
            table.insert(pvpParticipants, player)
        end
    end
    
    -- Segunda pasada: verificar combates ilegales
    for i = 1, #pvpParticipants do
        for j = i + 1, #pvpParticipants do
            local player1 = pvpParticipants[i]
            local player2 = pvpParticipants[j]
            
            if player1 and player2 and player1:IsInWorld() and player2:IsInWorld() then
                if player1:IsHostileTo(player2) and player1:IsInCombat() and player2:IsInCombat() then
                    local distance = GetDistanceBetweenPlayers(player1, player2)
                    
                    if distance > MAX_PVP_RANGE then
                        -- Mensajes de advertencia
                        player1:SendBroadcastMessage(WARNING_MESSAGE)
                        player2:SendBroadcastMessage(WARNING_MESSAGE)
                        
                        -- Teletransporte
                        TeleportToJail(player1)
                        TeleportToJail(player2)
                        
                        -- Anuncio del guardián
                        creature:SendUnitSay("¡Infractores detectados! Teletransportando a la jaula...", 0)
                    end
                end
            end
        end
    end
end

-- Evento de spawn
local function OnSpawn(event, creature)
    creature:RegisterEvent(HandlePvP, SCAN_INTERVAL, 0)
    creature:SendUnitSay("Vigilando actividad de JcJ. Distancia máxima permitida: 70 metros.", 0)
end

-- Evento de combate
local function OnEnterCombat(event, creature, target)
    if target and target:ToPlayer() and IsPvPActive(target:ToPlayer()) then
        creature:SendUnitSay("¡Infractor detectado! Serás teletransportado en 3 segundos!", 0)
        
        -- Programar teletransporte después de 3 segundos
        creature:RegisterEvent(function(e, d, r, c, t)
            if c and c:IsInWorld() and t and t:ToPlayer() then
                TeleportToJail(t:ToPlayer())
            end
        end, 3000, 1, creature, target)
    else
        creature:AttackStop()
        creature:RemoveAllAuras()
    end
end

-- Registro de eventos
RegisterCreatureEvent(NPC_ID, 5, OnSpawn) -- EVENT_ON_SPAWN
RegisterCreatureEvent(NPC_ID, 1, OnEnterCombat) -- EVENT_ON_ENTER_COMBAT

-- Evento para evitar daño de jugadores JcE
local function OnDamageTaken(event, creature, attacker, damage)
    if attacker and attacker:ToPlayer() and not IsPvPActive(attacker:ToPlayer()) then
        creature:SendUnitSay("No ataco a jugadores en modo JcE", 0)
        return false
    end
    return true
end

RegisterCreatureEvent(NPC_ID, 9, OnDamageTaken) -- EVENT_ON_DAMAGE_TAKEN
