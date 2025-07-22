local TITLE_VENDOR_ENTRY = 50000 -- Cambia este ID por uno disponible
local GOSSIP_ICON_MONEY = 0
local GOSSIP_ICON_CHAT = 1

-- Lista de títulos disponibles en WoW 3.3.5
local wrathTitles = {
    -- Títulos de logros generales
    {id = 1, male = "El Pacífico", female = "La Pacífica", cost = 1000000}, -- 100 oro
    {id = 2, male = "El Valiente", female = "La Valiente", cost = 5000000}, -- 500 oro
    {id = 3, male = "El Noble", female = "La Noble", cost = 10000000}, -- 1000 oro
    {id = 42, male = "El Buscador", female = "La Buscadora", cost = 15000000},
    {id = 53, male = "El Amable", female = "La Amable", cost = 3000000},
    {id = 72, male = "El Amado", female = "La Amada", cost = 25000000},
    {id = 113, male = "El Insaciable", female = "La Insaciable", cost = 5000000},
    
    -- Títulos PvP
    {id = 28, male = "El Gladiador", female = "La Gladiadora", cost = 100000000},
    {id = 29, male = "El Señor de la Guerra", female = "La Señora de la Guerra", cost = 80000000},
    {id = 30, male = "El Gran Maestro de Arenas", female = "La Gran Maestra de Arenas", cost = 90000000},
    {id = 45, male = "El Justiciero", female = "La Justiciera", cost = 30000000},
    
    -- Títulos de profesiones
    {id = 92, male = "El Chef", female = "La Chef", cost = 10000000},
    {id = 169, male = "El Pesquero", female = "La Pesquera", cost = 8000000},
    
    -- Títulos de reputación
    {id = 64, male = "El Exaltado", female = "La Exaltada", cost = 40000000},
    {id = 77, male = "El Celador", female = "La Celadora", cost = 35000000},
    {id = 110, male = "El de Kirin Tor", female = "La de Kirin Tor", cost = 30000000},
    {id = 111, male = "El de los Cruzados Argenta", female = "La de los Cruzados Argenta", cost = 35000000},
    
    -- Títulos de raids
    {id = 38, male = "El Matador", female = "La Matadora", cost = 20000000},
    {id = 39, male = "El Asesino de Dragones", female = "La Asesina de Dragones", cost = 35000000},
    {id = 44, male = "El Campeón", female = "La Campeona", cost = 30000000},
    {id = 140, male = "El Inmortal", female = "La Inmortal", cost = 100000000},
    {id = 141, male = "El Invencible", female = "La Invencible", cost = 100000000},
    
    -- Títulos de eventos
    {id = 60, male = "El Amante", female = "La Amante", cost = 15000000},
    {id = 101, male = "El Misericordioso", female = "La Misericordiosa", cost = 10000000},
    {id = 126, male = "El del Festival del Fuego", female = "La del Festival del Fuego", cost = 12000000}
}

local function OnGossipHello(event, player, creature)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\Achievement_Character_Human_Male:35:35|t Comprar títulos", 0, 1)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\INV_Misc_Coin_01:35:35|t Ver todos los títulos", 0, 2)
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if (intid == 1) then
        -- Mostrar categorías
        player:GossipMenuAddItem(0, "|TInterface\\icons\\Achievement_General:35:35|t Títulos Generales", 0, 10)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\Achievement_PVP_A_01:35:35|t Títulos PvP", 0, 20)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\Achievement_Reputation_01:35:35|t Títulos de Reputación", 0, 30)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\INV_Helmet_52:35:35|t Títulos de Raids", 0, 40)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\Spell_Shadow_Twilight:35:35|t Títulos de Eventos", 0, 50)
        player:GossipMenuAddItem(0, "|TInterface\\PaperDollInfoFrame\\UI-GearManager-Undo:35:35|t Volver", 0, 0)
        player:GossipSendMenu(1, creature)
        
    elseif (intid == 2) then
        -- Mostrar todos los títulos
        player:GossipMenuAddItem(0, "|cff00ff00Todos los títulos disponibles:|r", 0, 0)
        
        for _, title in ipairs(wrathTitles) do
            local genderText = player:GetGender() == 0 and title.male or title.female
            player:GossipMenuAddItem(0, string.format("%s - |cffffffff%d|r|cffeda55f oro|r", genderText, title.cost/10000), 0, 0)
        end
        
        player:GossipMenuAddItem(0, "|TInterface\\PaperDollInfoFrame\\UI-GearManager-Undo:35:35|t Volver", 0, 0)
        player:GossipSendMenu(1, creature)
        
    elseif (intid >= 100) then
        -- Compra de título
        local titleId = intid - 100
        local title
        
        for _, t in ipairs(wrathTitles) do
            if t.id == titleId then
                title = t
                break
            end
        end
        
        if not title then
            player:SendNotification("Título no válido.")
            player:GossipComplete()
            return
        end
        
        if player:HasTitle(titleId) then
            player:SendNotification("¡Ya tienes este título!")
            player:GossipComplete()
            return
        end
        
        if not player:HasEnoughMoney(title.cost) then
            player:SendNotification("No tienes suficiente oro.")
            player:GossipComplete()
            return
        end
        
        player:ModifyMoney(-title.cost)
        player:SetKnownTitle(titleId)
        player:SetTitle(titleId)
        
        local genderText = player:GetGender() == 0 and title.male or title.female
        player:SendBroadcastMessage(string.format("|cff00ff00¡Felicidades! Ahora eres |cffffffff%s|cff00ff00!|r", genderText))
        creature:SendUnitSay(string.format("¡Felicidades %s, ahora eres conocido como %s!", player:GetName(), genderText), 0)
        
        player:GossipComplete()
        
    elseif (intid == 10) then
        -- Títulos Generales
        player:GossipMenuAddItem(0, "|cff00ccffTítulos Generales:|r", 0, 0)
        AddTitlesToMenu(player, creature, {1, 2, 3, 42, 53, 72, 113, 92, 169})
        
    elseif (intid == 20) then
        -- Títulos PvP
        player:GossipMenuAddItem(0, "|cffff6600Títulos PvP:|r", 0, 0)
        AddTitlesToMenu(player, creature, {28, 29, 30, 45})
        
    elseif (intid == 30) then
        -- Títulos de Reputación
        player:GossipMenuAddItem(0, "|cff33ff33Títulos de Reputación:|r", 0, 0)
        AddTitlesToMenu(player, creature, {64, 77, 110, 111})
        
    elseif (intid == 40) then
        -- Títulos de Raids
        player:GossipMenuAddItem(0, "|cffffcc00Títulos de Raids:|r", 0, 0)
        AddTitlesToMenu(player, creature, {38, 39, 44, 140, 141})
        
    elseif (intid == 50) then
        -- Títulos de Eventos
        player:GossipMenuAddItem(0, "|cffcc33ffTítulos de Eventos:|r", 0, 0)
        AddTitlesToMenu(player, creature, {60, 101, 126})
        
    else
        -- Volver al menú principal
        OnGossipHello(event, player, creature)
    end
end

-- Función auxiliar para añadir títulos al menú
local function AddTitlesToMenu(player, creature, titleIds)
    for _, titleId in ipairs(titleIds) do
        for _, title in ipairs(wrathTitles) do
            if title.id == titleId then
                local genderText = player:GetGender() == 0 and title.male or title.female
                local text = string.format("%s (|cffffffff%d|r|cffeda55f oro|r)", genderText, title.cost/10000)
                player:GossipMenuAddItem(0, text, 0, 100 + title.id, false, "¿Estás seguro de que quieres comprar este título?")
                break
            end
        end
    end
    player:GossipMenuAddItem(0, "|TInterface\\PaperDollInfoFrame\\UI-GearManager-Undo:35:35|t Volver", 0, 1)
    player:GossipSendMenu(1, creature)
end

RegisterCreatureGossipEvent(TITLE_VENDOR_ENTRY, 1, OnGossipHello)
RegisterCreatureGossipEvent(TITLE_VENDOR_ENTRY, 2, OnGossipSelect)
