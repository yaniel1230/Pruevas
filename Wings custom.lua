local NPC_ID = 100000 -- Cambia esto al entry de tu NPC

-- Configuración completa de 20 alas con spells
local WING_SPELLS = {
    [1] = {
        spellId = 60001,
        name = "Alas de Fénix",
        desc = "Alas llameantes que brillan con intensidad",
        icon = "ability_mount_wingedlion",
        displayId = 27500 -- ID de modelo visual
    },
    [2] = {
        spellId = 60002,
        name = "Alas de Dragón",
        desc = "Alas poderosas de dragón ancestral",
        icon = "inv_misc_monsterscales_15",
        displayId = 27501
    },
    [3] = {
        spellId = 60003,
        name = "Alas Arcana",
        desc = "Energía mágica pura en forma de alas",
        icon = "spell_nature_astralrecal",
        displayId = 27502
    },
    [4] = {
        spellId = 60004,
        name = "Alas Angelicales",
        desc = "Pureza celestial en cada pluma",
        icon = "spell_holy_angelicfeather",
        displayId = 27503
    },
    [5] = {
        spellId = 60005,
        name = "Alas Demoníacas",
        desc = "Corrupción vil que forma alas",
        icon = "spell_shadow_shadowfiend",
        displayId = 27504
    },
    [6] = {
        spellId = 60006,
        name = "Alas de Murciélago",
        desc = "Sombras de la noche hechas alas",
        icon = "ability_hunter_pet_bat",
        displayId = 27505
    },
    [7] = {
        spellId = 60007,
        name = "Alas de Mariposa",
        desc = "Coloridas y delicadas alas",
        icon = "inv_misc_herb_whispervine",
        displayId = 27506
    },
    [8] = {
        spellId = 60008,
        name = "Alas de Cristal",
        desc = "Transparencia cristalina pura",
        icon = "inv_misc_gem_pearl_06",
        displayId = 27507
    },
    [9] = {
        spellId = 60009,
        name = "Alas de Tormenta",
        desc = "Energía eléctrica en movimiento",
        icon = "spell_nature_lightning",
        displayId = 27508
    },
    [10] = {
        spellId = 60010,
        name = "Alas de Hielo",
        desc = "Frío glacial que forma alas",
        icon = "spell_frost_arcticwinds",
        displayId = 27509
    },
    [11] = {
        spellId = 60011,
        name = "Alas de Cuervo",
        desc = "Misterio y oscuridad emplumada",
        icon = "spell_nature_ravenform",
        displayId = 27510
    },
    [12] = {
        spellId = 60012,
        name = "Alas de Titán",
        desc = "Tecnología arcana avanzada",
        icon = "spell_arcane_teleportdalaran",
        displayId = 27511
    },
    [13] = {
        spellId = 60013,
        name = "Alas Féericas",
        desc = "Magia natural de los bosques",
        icon = "spell_nature_faeriefire",
        displayId = 27512
    },
    [14] = {
        spellId = 60014,
        name = "Alas de Vapor",
        desc = "Niebla mágica condensada",
        icon = "spell_fire_blueflamebolt",
        displayId = 27513
    },
    [15] = {
        spellId = 60015,
        name = "Alas de Obsidiana",
        desc = "Piedra volcánica endurecida",
        icon = "inv_ore_obsidian",
        displayId = 27514
    },
    [16] = {
        spellId = 60016,
        name = "Alas Estelares",
        desc = "El cosmos en tus espaldas",
        icon = "spell_arcane_starfire",
        displayId = 27515
    },
    [17] = {
        spellId = 60017,
        name = "Alas de Vendaval",
        desc = "Vientos huracanados",
        icon = "spell_nature_cyclone",
        displayId = 27516
    },
    [18] = {
        spellId = 60018,
        name = "Alas Espectrales",
        desc = "Espectros del más allá",
        icon = "spell_shadow_spectralsight",
        displayId = 27517
    },
    [19] = {
        spellId = 60019,
        name = "Alas de Rubí",
        desc = "Resplandor rojo ardiente",
        icon = "inv_misc_gem_ruby_01",
        displayId = 27518
    },
    [20] = {
        spellId = 60020,
        name = "Alas de Ébano",
        desc = "Oscuridad pura materializada",
        icon = "ability_mount_drake_twilight",
        displayId = 27519
    }
}

local DURATION = 10 -- Duración en segundos

local function ApplyWings(player, spellId, displayId, name)
    -- Verificar si el spell existe
    if not GetSpellInfo(spellId) then
        player:SendBroadcastMessage("¡Error: Estas alas no están disponibles temporalmente!")
        return
    end
    
    -- Aplicar transformación visual
    player:SetDisplayId(displayId)
    
    -- Aplicar aura (si es necesaria para efectos adicionales)
    player:AddAura(spellId, player)
    
    -- Mensaje al jugador
    player:SendBroadcastMessage(string.format("¡Has obtenido %s por %d segundos!", name, DURATION))
    
    -- Programar remoción de alas
    player:RegisterEvent(function()
        player:DeMorph() -- Quitar transformación
        player:RemoveAura(spellId) -- Remover aura si aún existe
        player:SendBroadcastMessage(string.format("Tus %s han desaparecido.", name))
    end, DURATION * 1000, 1)
end

local function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    
    -- Encabezado
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\ability_mount_wingedlion:35|t |cFF00FFFFMaestro de Alas|r", 0, 0)
    player:GossipMenuAddItem(0, "|cFF00FF00Elige unas alas temporales:|r", 0, 0)
    player:GossipMenuAddItem(0, "|cFF00FF00Duración: 10 segundos|r", 0, 0)
    
    -- Mostrar alas en grupos de 5
    local page = tonumber(code) or 1
    local itemsPerPage = 5
    local startIdx = (page-1)*itemsPerPage + 1
    local endIdx = math.min(page*itemsPerPage, #WING_SPELLS)
    
    -- Añadir items de la página actual
    for i = startIdx, endIdx do
        local wing = WING_SPELLS[i]
        player:GossipMenuAddItem(0, 
            string.format("|TInterface\\Icons\\%s:25|t |cFFFFFFFF%s|r\n|cFF808080%s|r", 
            wing.icon, wing.name, wing.desc), 
            0, i)
    end
    
    -- Navegación entre páginas
    if page > 1 then
        player:GossipMenuAddItem(0, "|TInterface\\CHATFRAME\\UI-ChatIcon-ScrollUp-Up:20|t Página anterior", 0, 1000, false, tostring(page-1))
    end
    if endIdx < #WING_SPELLS then
        player:GossipMenuAddItem(0, "|TInterface\\CHATFRAME\\UI-ChatIcon-ScrollDown-Up:20|t Página siguiente", 0, 1001, false, tostring(page+1))
    end
    
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    -- Manejar navegación
    if intid == 1000 or intid == 1001 then
        OnGossipHello(event, player, creature)
        return
    end
    
    -- Aplicar alas seleccionadas
    if WING_SPELLS[intid] then
        local wing = WING_SPELLS[intid]
        ApplyWings(player, wing.spellId, wing.displayId, wing.name)
    end
    
    player:GossipComplete()
end

-- Registrar eventos
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)

print("[Eluna] NPC de Alas Temporales cargado correctamente")
