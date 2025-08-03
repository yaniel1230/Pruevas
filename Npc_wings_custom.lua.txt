local NPC_ID = 999998 -- Change this to your NPC entry

local WING_SPELLS = {
    [1] = {
        spellId = 100167,
        name = "Tyrael Wings Orange",
        icon = "inv_misc_monsterscales_15",
    },
    [2] = {
        spellId = 100168,
        name = "Wings of Priest Apotheosis",
        icon = "inv_misc_monsterscales_15",
    },
    [3] = {
        spellId = 100169,
        name = "Wings of Flame State Black",
        icon = "inv_misc_monsterscales_15",
    },
    [4] = {
        spellId = 100170,
        name = "Tyrael Wings White",
        icon = "inv_misc_monsterscales_15",
    },
    [5] = {
        spellId = 100171,
        name = "Tyrael Wings Red",
        icon = "inv_misc_monsterscales_15",
    },
    [6] = {
        spellId = 100172,
        name = "Tyrael Demon Wings Blue",
        icon = "inv_misc_monsterscales_15",
    },
    [7] = {
        spellId = 100173,
        name = "Tyrael Demon Wings Cyan",
        icon = "inv_misc_monsterscales_15",
    },
    [8] = {
        spellId = 100174,
        name = "Tyrael Demon Wings Red",
        icon = "inv_misc_monsterscales_15",
    },
    [9] = {
        spellId = 100175,
        name = "Tyrael Demon Wings Yellow",
        icon = "inv_misc_monsterscales_15",
    },
    [10] = {
        spellId = 100176,
        name = "Tyrael Two Wings Blue",
        icon = "inv_misc_monsterscales_15",
    },
    [11] = {
        spellId = 100177,
        name = "Tyrael Two Wings Gold",
        icon = "inv_misc_monsterscales_15",
    },
    [12] = {
        spellId = 100178,
        name = "Tyrael Two Wings Green",
        icon = "inv_misc_monsterscales_15",
    },
    [13] = {
        spellId = 100179,
        name = "Tyrael Two Wings Purple",
        icon = "inv_misc_monsterscales_15",
    },
    [14] = {
        spellId = 100180,
        name = "Wings of Flame State Original",
        icon = "inv_misc_monsterscales_15",
    },
    [15] = {
        spellId = 100181,
        name = "Wings of Flame State Flame",
        icon = "inv_misc_monsterscales_15",
    },
    [16] = {
        spellId = 100182,
        name = "Cape Wings Crane",
        icon = "inv_misc_monsterscales_15",
    },
    [17] = {
        spellId = 100183,
        name = "Cape Wings Dragon",
        icon = "inv_misc_monsterscales_15",
    },
    [18] = {
        spellId = 100184,
        name = "Cape Wings Tiger",
        icon = "inv_misc_monsterscales_15",
    },
    [19] = {
        spellId = 100185,
        name = "Tera Wings Fire",
        icon = "inv_misc_monsterscales_15",
    },
    [20] = {
        spellId = 100186,
        name = "Tera Wings Ice",
        icon = "inv_misc_monsterscales_15",
    }
}

local function ApplyWings(player, spellId, name)
    -- Check if the spell exists
    if not GetSpellInfo(spellId) then
        player:SendBroadcastMessage("Error: These wings are temporarily unavailable!")
        return
    end

    -- Remove any other active aura from wings
    for _, wing in pairs(WING_SPELLS) do
        if player:HasAura(wing.spellId) then
            player:RemoveAura(wing.spellId)
        end
    end

    -- Apply new aura
    player:AddAura(spellId, player)

    -- Message to the player
    player:SendBroadcastMessage(string.format("You have obtained %s!", name))

end

local function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Select your custom wings|r", 1, 9999)
    player:GossipMenuAddItem(3, "Wings", 1, 1)
    player:GossipSendMenu(1, creature)
end


local WINGS_PER_PAGE = 10 -- Limit show Wings in menu

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if sender == 1 and intid == 1 then
        -- Page 1
        player:GossipClearMenu()
        local page = 1
        local startIndex = (page - 1) * WINGS_PER_PAGE + 1
        local endIndex = math.min(startIndex + WINGS_PER_PAGE - 1, #WING_SPELLS)

        for i = startIndex, endIndex do
            local wing = WING_SPELLS[i]
            player:GossipMenuAddItem(3, string.format("|TInterface\\Icons\\%s:25|t %s", wing.icon, wing.name), 2, i)
        end

        if endIndex < #WING_SPELLS then
            player:GossipMenuAddItem(0, "Next", 1, 100 + page + 1)
        end

        player:GossipMenuAddItem(0, "Back", 1, 99)
        player:GossipSendMenu(1, creature)

    elseif sender == 1 and intid >= 101 then
        -- Page later
        player:GossipClearMenu()
        local page = intid - 100
        local startIndex = (page - 1) * WINGS_PER_PAGE + 1
        local endIndex = math.min(startIndex + WINGS_PER_PAGE - 1, #WING_SPELLS)

        for i = startIndex, endIndex do
            local wing = WING_SPELLS[i]
            player:GossipMenuAddItem(3, string.format("|TInterface\\Icons\\%s:25|t %s", wing.icon, wing.name), 2, i)
        end

        if startIndex > 1 then
            player:GossipMenuAddItem(0, "Previous", 1, 100 + page - 1)
        end
        if endIndex < #WING_SPELLS then
            player:GossipMenuAddItem(0, "Next", 1, 100 + page + 1)
        end

        player:GossipMenuAddItem(0, "Back", 1, 99)
        player:GossipSendMenu(1, creature)

    elseif sender == 2 and WING_SPELLS[intid] then
        -- Apply selected wings
        local wing = WING_SPELLS[intid]
        ApplyWings(player, wing.spellId, wing.name)
        player:GossipComplete()

    elseif sender == 1 and intid == 99 then
        -- Return to main menu
        OnGossipHello(event, player, creature)
    end
end

-- Log events
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)

print("[Eluna] NPC Custom Wings loaded successfully.")
