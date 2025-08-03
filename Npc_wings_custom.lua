local NPC_ID = 999998 -- Change this to your NPC entry

local WING_SPELLS = {
	--Add spell ID here
    [1] = {
        spellId = 100167,
        name = "Tyrael Wings Orange",
        icon = "ability_priest_angelicfeather",
		cost = 0,
        requiresItem = true, -- Enable(true) or Disable(false) Required Item
        requiredItemId = 49426,  -- Emblem of Frost (Change for other item ID)
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [2] = {
        spellId = 100168,
        name = "Wings of Priest Apotheosis",
        icon = "ability_priest_angelicfeather",
		cost = 10,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 2,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [3] = {
        spellId = 100169,
        name = "Wings of Flame State Black",
        icon = "ability_priest_angelicfeather",
		cost = 1000,
		requiresItem = false,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [4] = {
        spellId = 100170,
        name = "Tyrael Wings White",
        icon = "ability_priest_angelicfeather",
		cost = 11010,
		requiresItem = false,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [5] = {
        spellId = 100171,
        name = "Tyrael Wings Red",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = false,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [6] = {
        spellId = 100172,
        name = "Tyrael Demon Wings Blue",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [7] = {
        spellId = 100173,
        name = "Tyrael Demon Wings Cyan",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [8] = {
        spellId = 100174,
        name = "Tyrael Demon Wings Red",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [9] = {
        spellId = 100175,
        name = "Tyrael Demon Wings Yellow",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [10] = {
        spellId = 100176,
        name = "Tyrael Two Wings Blue",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [11] = {
        spellId = 100177,
        name = "Tyrael Two Wings Gold",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [12] = {
        spellId = 100178,
        name = "Tyrael Two Wings Green",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [13] = {
        spellId = 100179,
        name = "Tyrael Two Wings Purple",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [14] = {
        spellId = 100180,
        name = "Wings of Flame State Original",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [15] = {
        spellId = 100181,
        name = "Wings of Flame State Flame",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [16] = {
        spellId = 100182,
        name = "Cape Wings Crane",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [17] = {
        spellId = 100183,
        name = "Cape Wings Dragon",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = true,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [18] = {
        spellId = 100184,
        name = "Cape Wings Tiger",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = false,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [19] = {
        spellId = 100185,
        name = "Tera Wings Fire",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = false,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    },
    [20] = {
        spellId = 100186,
        name = "Tera Wings Ice",
        icon = "ability_priest_angelicfeather",
		cost = 10000,
		requiresItem = false,
        requiredItemId = 49426,
        requiredItemCount = 1,
        requiredItemIcon = "inv_misc_frostemblem_01",
    }
}

-- Gold/Silver/Copper
local function FormatCoins(amount)
    local g = math.floor(amount / 10000)
    local s = math.floor((amount % 10000) / 100)
    local c = amount % 100
    return string.format("%d|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t %d|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t %d|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t", g, s, c)
end


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
    player:GossipMenuAddItem(0, "Select your custom wings|r", 1, 99)
    player:GossipMenuAddItem(3, "Wings", 1, 1)
    player:GossipSendMenu(1, creature)
end


local WINGS_PER_PAGE = 10 -- Limit show Wings in menu

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if sender == 1 and intid == 1 or (intid >= 101 and intid <= 199) then
        player:GossipClearMenu()
        local page = (intid == 1) and 1 or (intid - 100)
        local startIndex = (page - 1) * WINGS_PER_PAGE + 1
        local endIndex = math.min(startIndex + WINGS_PER_PAGE - 1, #WING_SPELLS)

        for i = startIndex, endIndex do
            local wing = WING_SPELLS[i]
            local itemInfo = ""
            if wing.requiresItem and wing.requiredItemId and wing.requiredItemIcon then
                local itemCount = wing.requiredItemCount or 1
                itemInfo = string.format("|TInterface\\Icons\\%s:16|t x%d", wing.requiredItemIcon, itemCount)
            end

            player:GossipMenuAddItem(
                3,
                string.format("|TInterface\\Icons\\%s:25|t %s:\n%s %s", wing.icon, wing.name, FormatCoins(wing.cost), itemInfo),
                2,
                i
            )
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
        local wing = WING_SPELLS[intid]
        local cost = wing.cost or 0
        local requiresItem = wing.requiresItem or false
        local requiredItemId = wing.requiredItemId
        local requiredItemCount = wing.requiredItemCount or 1

        if player:GetCoinage() >= cost then
            if requiresItem then
                if requiredItemId and player:HasItem(requiredItemId, requiredItemCount) then
                    player:RemoveItem(requiredItemId, requiredItemCount)
                    player:ModifyMoney(-cost)
                    ApplyWings(player, wing.spellId, wing.name)
                    local itemName = GetItemLink(requiredItemId) or "item"
                    player:SendBroadcastMessage(string.format("You have bought |cffffff00%s|r for %s y %dx %s.", wing.name, FormatCoins(cost), requiredItemCount, itemName))
                else
                    local itemName = GetItemLink(requiredItemId) or "required item"
                    player:SendBroadcastMessage("You need at least " .. requiredItemCount .. "x " .. itemName .. " to buy these wings.")
                end
            else
                player:ModifyMoney(-cost)
                ApplyWings(player, wing.spellId, wing.name)
                player:SendBroadcastMessage(string.format("You have bought |cffffff00%s|r for %s.", wing.name, FormatCoins(cost)))
            end
        else
            player:SendBroadcastMessage("You don't have enough gold to buy these wings.")
        end
        player:GossipComplete()

    elseif sender == 1 and intid == 99 then
        OnGossipHello(event, player, creature)
    end
end

-- Log events
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)

print("[Eluna] NPC Custom Wings loaded successfully.")
