local CONFIG = {
    ENABLED = true,                     -- Activar/desactivar el sistema
    INTERVAL_MINUTES = 15,              -- Frecuencia de anuncios (15-30 mins recomendado)
    MAX_DISPLAYED_PLAYERS = 20,         -- Jugadores visibles antes de "+X más"
    
    -- Configuración de visualización
    USE_COLOR_ROTATION = true,          -- Rotación automática de colores
    SHOW_UPTIME = true,                 -- Mostrar tiempo activo del servidor
    SHORT_LOCATIONS = true,             -- Acortar nombres de zonas largas
    
    -- Textos personalizables (UTF-8 compatible)
    HEADER = "|cFF00CCFF[Estado del Servidor]|r",
    UPTIME_TEXT = "Tiempo activo:",
    PLAYER_TEXT = "Jugadores conectados:",
    FOOTER = "Actualizado: %s",         -- %s será reemplazado por la hora
    
    -- Formato de jugador (variables: name, level, race, class, zone, online, color)
    PLAYER_FORMAT = "|cFF{color}{name}|r (Nv.{level}) {race} {class} en |cFF{color}{zone}|r - |cFFAAAAAA{online}|r"
}

--------------------------------------------------
-- DATOS COMPATIBLES CON AZEROTHCORE (WOTLK 3.3.5a)
--------------------------------------------------
local RACES = {
    [1] = "|cFFC79C6EHumano|r",      [2] = "|cFFF58CBAOrco|r",
    [3] = "|cFFAAD372Enano|r",       [4] = "|cFFFFF468Elfo de la Noche|r",
    [5] = "|cFF9482C9No-Muerto|r",    [6] = "|cFF00FF96Tauren|r",
    [7] = "|cFFFFFFFFGnomo|r",        [8] = "|cFFFF7C0ATrol|r",
    [10] = "|cFFFF7C0AElfo de Sangre|r", [11] = "|cFF0070DDDraenei|r"
}

local CLASSES = {
    [1] = "|cFFC69B6DGuerrero|r",    [2] = "|cFFF48CBAPaladín|r",
    [3] = "|cFFAAD372Cazador|r",     [4] = "|cFFFFF468Pícaro|r",
    [5] = "|cFFFFFFFFSacerdote|r",    [6] = "|cFFC41F3BCaballero de la Muerte|r",
    [7] = "|cFF0070DDChamán|r",      [8] = "|cFF3FC7EBMago|r",
    [9] = "|cFF8788EEBrujo|r",       [11] = "|cFFFF7C0ADruida|r"
}

local COLORS = {"FF3399", "33FF99", "9933FF", "FF33FF", "33FFFF", "FF9933"}
local currentColorIndex = 1

--------------------------------------------------
-- FUNCIONES COMPATIBLES CON ELUNA (AZEROTHCORE)
--------------------------------------------------
local function GetFormattedTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    return string.format("%02dh %02dm", hours, minutes)
end

local function GetPlayerZone(player)
    local zone = player:GetZoneName()
    if CONFIG.SHORT_LOCATIONS and string.len(zone) > 15 then
        return string.sub(zone, 1, 12)..".."
    end
    return zone
end

local function UpdateColorRotation()
    currentColorIndex = currentColorIndex % #COLORS + 1
    return COLORS[currentColorIndex]
end

--------------------------------------------------
-- SISTEMA DE SEGUIMIENTO DE TIEMPO CONECTADO
--------------------------------------------------
local playerOnlineTimes = {}

local function UpdateOnlineTimes()
    local players = GetPlayersInWorld()
    local currentTime = os.time()
    
    for _, player in ipairs(players) do
        local guid = player:GetGUIDLow()
        if not playerOnlineTimes[guid] then
            playerOnlineTimes[guid] = {
                loginTime = currentTime,
                lastUpdate = currentTime
            }
        else
            -- Actualizar tiempo acumulado
            playerOnlineTimes[guid].totalTime = (playerOnlineTimes[guid].totalTime or 0) + 
                                              (currentTime - playerOnlineTimes[guid].lastUpdate)
            playerOnlineTimes[guid].lastUpdate = currentTime
        end
    end
end

local function GetOnlineTime(guid)
    if not playerOnlineTimes[guid] then return 0 end
    local current = playerOnlineTimes[guid]
    return (current.totalTime or 0) + (os.time() - current.lastUpdate)
end

--------------------------------------------------
-- GENERADOR DEL MENSAJE PRINCIPAL
--------------------------------------------------
local function GenerateAnnouncement()
    local players = GetPlayersInWorld()
    if #players == 0 then return end
    
    -- Ordenar jugadores por tiempo conectado (mayor a menor)
    table.sort(players, function(a, b)
        return GetOnlineTime(a:GetGUIDLow()) > GetOnlineTime(b:GetGUIDLow())
    end)
    
    -- Configurar color actual
    local currentColor = CONFIG.USE_COLOR_ROTATION and UpdateColorRotation() or COLORS[1]
    
    -- Construir mensaje
    local message = {CONFIG.HEADER}
    
    -- Tiempo activo del servidor
    if CONFIG.SHOW_UPTIME then
        table.insert(message, string.format("|cFF%s%s |cFFAAAAAA%s|r",
            currentColor,
            CONFIG.UPTIME_TEXT,
            GetFormattedTime(GetUptime())))
    end
    
    -- Contador de jugadores
    table.insert(message, string.format("|cFF%s%s |cFFAAAAAA%d/%d|r",
        currentColor,
        CONFIG.PLAYER_TEXT,
        #players,
        GetMaxPlayers()))
    
    -- Lista de jugadores
    local displayCount = math.min(#players, CONFIG.MAX_DISPLAYED_PLAYERS)
    for i = 1, displayCount do
        local player = players[i]
        local guid = player:GetGUIDLow()
        
        local playerLine = string.gsub(CONFIG.PLAYER_FORMAT, "{(%w+)}", {
            name = player:GetName(),
            level = player:GetLevel(),
            race = RACES[player:GetRace()] or "|cFF888888???|r",
            class = CLASSES[player:GetClass()] or "|cFF888888???|r",
            zone = GetPlayerZone(player),
            online = GetFormattedTime(GetOnlineTime(guid)),
            color = currentColor
        })
        
        table.insert(message, playerLine)
    end
    
    -- Jugadores no mostrados
    if #players > CONFIG.MAX_DISPLAYED_PLAYERS then
        table.insert(message, string.format("|cFF%s... y |cFFAAAAAA%d|r |cFF%sjugadores más|r",
            currentColor,
            #players - CONFIG.MAX_DISPLAYED_PLAYERS,
            currentColor))
    end
    
    -- Pie de página con hora actual
    table.insert(message, string.format(CONFIG.FOOTER, os.date("%H:%M")))
    
    return table.concat(message, "\n")
end

--------------------------------------------------
-- SISTEMA PRINCIPAL (COMPATIBLE CON AZEROTHCORE)
--------------------------------------------------
if CONFIG.ENABLED then
    -- Programar anuncios periódicos
    CreateLuaEvent(function()
        UpdateOnlineTimes()
        local announcement = GenerateAnnouncement()
        if announcement then
            SendWorldMessage(announcement)
        end
    end, CONFIG.INTERVAL_MINUTES * 60 * 1000, 0)
    
    -- Limpiar datos al desconectar
    RegisterPlayerEvent(4, function(event, player) -- EVENT_ON_LOGOUT
        playerOnlineTimes[player:GetGUIDLow()] = nil
    end)
    
    -- Mensaje de activación en consola
    print("[AutoAnnounce] Sistema activado. Intervalo: "..CONFIG.INTERVAL_MINUTES.." minutos")
end
