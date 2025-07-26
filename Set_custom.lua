local BOSS_ENTRY = 36597 -- ID del Rey Exánime (Icecrown Citadel 25N)

-- =============================================
-- CONFIGURACIÓN PRINCIPAL (MODIFICA AQUÍ)
-- =============================================
local DK_SET = {
    -- Reemplaza los IDs con los de tu base de datos
    {itemId = 49488, count = 1, name = "Cabeza DK"},     -- Casco de Placas Épico
    {itemId = 49489, count = 1, name = "Hombros DK"},    -- Hombreras de Placas
    {itemId = 49490, count = 1, name = "Pecho DK"},      -- Coraza de Placas
    {itemId = 49491, count = 1, name = "Manos DK"},      -- Guantes de Placas
    {itemId = 49492, count = 1, name = "Piernas DK"},    -- Musleras de Placas
    {itemId = 49493, count = 1, name = "Botas DK"},      -- Botas de Placas
    {itemId = 49494, count = 1, name = "Cinturón DK"},   -- Cinturón de Placas
    {itemId = 49495, count = 1, name = "Brazales DK"},   -- Brazales de Placas
    {itemId = 50240, count = 1, name = "Capa DK"}        -- Capa Épica
}

local MAIL_SUBJECT = "Set DK Completo - Premio del Rey Exánime"
local MAIL_BODY = "¡Has reclamado las piezas del set DK al derrotar al Rey Exánime!"
-- =============================================

local function OnBossKill(event, killer, killed)
    -- Verificación segura
    if not killer or not killed then return end
    if not killer:IsPlayer() then return end
    if killed:GetEntry() ~= BOSS_ENTRY then return end

    -- Envío de items (método compatible con AzerothCore)
    for _, item in ipairs(DK_SET) do
        killer:SendMail(
            MAIL_SUBJECT,
            MAIL_BODY,
            item.itemId,
            item.count,
            0,  -- dinero
            0,  -- COD
            0   -- delay (0 = instantáneo)
        )
    end

    -- Notificación mejorada
    killer:SendBroadcastMessage("|cFFFF0000[Recompensa]|r Has recibido el |cFF00FF00Set DK Completo|r!")
    killer:SendBroadcastMessage("|cFF00FF00Contenido del correo:|r")
    for _, item in ipairs(DK_SET) do
        killer:SendBroadcastMessage(string.format("|cFF00FF00•|r %s (x%d)", item.name, item.count))
    end
end

-- Registro seguro del evento
if RegisterCreatureEvent then
    RegisterCreatureEvent(BOSS_ENTRY, 4, OnBossKill) -- 4 = EVENT_ON_DIED
    print("[DK Set Reward] Script cargado correctamente para el boss "..BOSS_ENTRY)
else
    print("ERROR: El entorno no soporta Eluna/Lua")
end
