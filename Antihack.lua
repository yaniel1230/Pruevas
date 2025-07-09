local PLAYER_EVENT_ON_UPDATE = 27
local CHEAT_CHECK_INTERVAL = 3000 -- 3 segundos

-- ================= CONFIGURACIÓN PRINCIPAL =================
local CONFIG = {
    -- Umbrales de detección
    MAX_SPEED = 10.0,                -- Velocidad máxima permitida (7.0 es normal)
    MAX_JUMP_HEIGHT = 8.0,           -- Altura de salto realista (en yards)
    TELEPORT_THRESHOLD = 50,         -- Distancia máxima entre updates (yards)
    WALLCLIMB_ANGLE = 1.5,           -- Ángulo en radianes (≈85°)
    WALLCLIMB_DISTANCE = 3.0,        -- Distancia vertical mínima para escalada
    FALL_DAMAGE_THRESHOLD = 60,      -- Daño mínimo esperado al caer (%)

    -- Sanciones (1=Advertencia, 2=Kick, 3=Ban Temp, 4=Ban Perm)
    VIOLATIONS_FOR_KICK = 2,
    VIOLATIONS_FOR_BAN_TEMP = 3,
    VIOLATIONS_FOR_BAN_PERM = 5,

    -- Mensajes
    WARNING_MSG = "|cFFFF0000[ANTICHEAT]|r Advertencia: %s",
    KICK_MSG = "|cFFFF0000[ANTICHEAT]|r Expulsado por: %s",
    BAN_MSG = "|cFFFF0000[ANTICHEAT]|r %s baneado por: %s"
}

-- ================= VARIABLES GLOBALES =================
local playerViolations = {}          -- GUID = conteo de violaciones
local playerMovementHistory = {}     -- Seguimiento para WallClimb
local playerFallData = {}            -- Datos para NoFallDamage

-- ================= FUNCIONES AUXILIARES =================
local function CalculateFallDamage(startZ, endZ)
    local fallHeight = startZ - endZ
    if fallHeight <= 15 then return 0 end
    return math.min(100, (fallHeight - 15) * 2) -- Fórmula aproximada de WoW
end

-- ================= SISTEMA DE SANCIÓNES =================
local function BanAccount(player, duration, reason)
    local accountId = player:GetAccountId()
    local banTime = duration == -1 and os.time() + 31536000 or os.time() + duration -- -1 = permaban
    CharDBExecute(string.format(
        "INSERT INTO account_banned (id, bandate, unbandate, bannedby, banreason) VALUES (%d, %d, %d, 'AntiCheat', '%s')",
        accountId, os.time(), banTime, reason
    ))
    player:KickPlayer()
    SendWorldMessage(string.format(CONFIG.BAN_MSG, player:GetName(), reason))
end

local function ApplySanction(player, reason, severity)
    local guid = player:GetGUIDLow()
    playerViolations[guid] = (playerViolations[guid] or 0) + 1
    local violations = playerViolations[guid]

    -- Log en consola
    print(string.format("[ANTICHEAT] %s (GUID: %d) - %s. Violación %d",
        player:GetName(), guid, reason, violations))

    -- Aplicar sanción según gravedad y violaciones acumuladas
    if severity == 1 then -- Advertencia
        player:SendBroadcastMessage(string.format(CONFIG.WARNING_MSG, reason))

    elseif severity == 2 and violations >= CONFIG.VIOLATIONS_FOR_KICK then -- Kick
        player:SendBroadcastMessage(string.format(CONFIG.KICK_MSG, reason))
        player:KickPlayer()

    elseif severity == 3 and violations >= CONFIG.VIOLATIONS_FOR_BAN_TEMP then -- Ban Temporal
        BanAccount(player, 86400, reason)

    elseif severity == 4 and violations >= CONFIG.VIOLATIONS_FOR_BAN_PERM then -- Ban Permanente
        BanAccount(player, -1, reason)
    end
end

-- ================= DETECCIÓN DE HACKS =================

-- 1. NoFallDamage (Versión optimizada)
local function CheckNoFallDamage(player, damage)
    local guid = player:GetGUIDLow()
    
    if player:IsFalling() then
        playerFallData[guid] = { startZ = player:GetZ() }
        return
    end

    if playerFallData[guid] then
        local expectedDamage = CalculateFallDamage(playerFallData[guid].startZ, player:GetZ())
        if expectedDamage > 0 and damage < (expectedDamage * CONFIG.FALL_DAMAGE_THRESHOLD / 100) then
            ApplySanction(player, 
                string.format("NoFallDamage (Altura: %.1fy, Daño esperado: %d%%, Daño real: %d%%)", 
                playerFallData[guid].startZ - player:GetZ(), expectedDamage, damage), 
                3)
        end
        playerFallData[guid] = nil
    end
end

-- 2. WallClimb (Versión corregida)
local function CheckWallClimb(player)
    local guid = player:GetGUIDLow()
    local x, y, z = player:GetX(), player:GetY(), player:GetZ()
    
    if not playerMovementHistory[guid] then
        playerMovementHistory[guid] = { points = {} }
    end

    -- Almacenar puntos con timestamp
    table.insert(playerMovementHistory[guid].points, {x = x, y = y, z = z, time = os.time()})
    
    -- Eliminar puntos antiguos (>5 segundos)
    for i = #playerMovementHistory[guid].points, 1, -1 do
        if os.time() - playerMovementHistory[guid].points[i].time > 5 then
            table.remove(playerMovementHistory[guid].points, i)
        end
    end

    if #playerMovementHistory[guid].points >= 3 then
        local p1 = playerMovementHistory[guid].points[1]
        local p2 = playerMovementHistory[guid].points[#playerMovementHistory[guid].points]
        local deltaZ = p2.z - p1.z
        local deltaXY = math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)

        if deltaXY > 0 and deltaZ > CONFIG.WALLCLIMB_DISTANCE then
            local angle = math.atan2(deltaZ, deltaXY)
            if angle > CONFIG.WALLCLIMB_ANGLE then
                ApplySanction(player, 
                    string.format("WallClimb (Ángulo: %.1f°, Distancia: %.1fy)", 
                    math.deg(angle), deltaZ), 
                    2)
                player:Teleport(player:GetMapId(), p1.x, p1.y, p1.z) -- Revertir posición
            end
        end
    end
end

-- 3. Sistema principal (Versión final)
local function AntiCheatOnUpdate(event, player, diff)
    if player:IsGM() then return end -- Ignorar GMs

    local x, y, z = player:GetX(), player:GetY(), player:GetZ()
    local speed = player:GetSpeed()
    local isFlying = player:IsFlying()

    -- SpeedHack (con verificación de estados)
    if speed > CONFIG.MAX_SPEED and 
       not player:HasAuraType(SPELL_AURA_MOD_INCREASE_SPEED) and 
       not player:HasAuraType(SPELL_AURA_MOUNTED) then
        ApplySanction(player, 
            string.format("SpeedHack (Velocidad: %.1f u/s)", speed), 
            2)
        player:SetSpeed(1.0) -- Resetear velocidad
    end

    -- FlyHack (con más verificaciones)
    if isFlying and 
       not player:HasAuraType(SPELL_AURA_FLY) and 
       not player:HasAuraType(SPELL_AURA_MOD_INCREASE_MOUNTED_FLIGHT_SPEED) and 
       z > 20 then
        ApplySanction(player, "FlyHack", 2)
        player:Teleport(player:GetMapId(), x, y, z - 2) -- Ajustar posición
    end

    -- TeleportHack (con tiempo de verificación)
    if not player.lastPos then player.lastPos = {x = x, y = y, z = z, time = os.time()} end
    
    local distance = math.sqrt((x - player.lastPos.x)^2 + (y - player.lastPos.y)^2 + (z - player.lastPos.z)^2)
    local timeDiff = os.time() - player.lastPos.time
    
    if distance > CONFIG.TELEPORT_THRESHOLD and 
       timeDiff < 2 and -- Máximo 2 segundos entre movimientos
       not player:IsTaxiFlying() and 
       not player:IsBeingTeleported() then
        ApplySanction(player, 
            string.format("TeleportHack (Distancia: %.1fy en %ds)", distance, timeDiff), 
            3)
        player:Teleport(player:GetMapId(), player.lastPos.x, player.lastPos.y, player.lastPos.z)
    end
    
    player.lastPos = {x = x, y = y, z = z, time = os.time()}

    -- JumpHack (con gravedad verificada)
    if player:IsFalling() then
        if not player.lastGroundZ then player.lastGroundZ = z end
        if (z - player.lastGroundZ) > CONFIG.MAX_JUMP_HEIGHT then
            ApplySanction(player, 
                string.format("JumpHack (Altura: %.1fy)", z - player.lastGroundZ), 
                1)
        end
    else
        player.lastGroundZ = z
    end

    -- WallClimb
    CheckWallClimb(player)
end

-- ================= EVENTOS =================
local function OnDamageTaken(event, player, damage)
    if not player:IsGM() and damage > 0 then
        CheckNoFallDamage(player, damage)
    end
end

local function OnLogin(event, player)
    local guid = player:GetGUIDLow()
    player.lastPos = {x = player:GetX(), y = player:GetY(), z = player:GetZ(), time = os.time()}
    player.lastGroundZ = player:GetZ()
    playerMovementHistory[guid] = { points = {} }
    playerFallData[guid] = nil
end

-- ================= REGISTRO =================
RegisterPlayerEvent(PLAYER_EVENT_ON_UPDATE, AntiCheatOnUpdate)
RegisterPlayerEvent(3, OnLogin) -- EVENT_ON_LOGIN
RegisterPlayerEvent(9, OnDamageTaken) -- EVENT_ON_DAMAGE_TAKEN

print("[ANTICHEAT] Sistema cargado: SpeedHack | FlyHack | TeleportHack | JumpHack | WallClimb | NoFallDamage")
