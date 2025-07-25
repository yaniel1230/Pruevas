local NPC_ID = 99996
local CURRENCY_ID = 49426
local CURRENCY_COST = 20

local CUSTOM_WINGS = {
    { spellId = 36716, name = "|TInterface\\Icons\\spell_nature_riptide:25|t Alas Angelicales" },
    { spellId = 57399, name = "|TInterface\\Icons\\spell_holy_aspiration:25|t Alas de Fénix" },
    { spellId = 62969, name = "|TInterface\\Icons\\inv_misc_volatilelife:25|t Alas de Dragón" },
    { spellId = 72286, name = "|TInterface\\Icons\\ability_mount_drake_twilight:25|t Alas Oscuras" },
    { spellId = 101508, name = "|TInterface\\Icons\\spell_deathknight_gnaw_ghoul:25|t Alas Espectrales" },
}

local function OnGossipHello(event, player, creature)
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\achievement_guildperk_mobilebanking:25|t |cFF00FF00Tienda de Alas|r", 0, 99)
    player:GossipMenuAddItem(0, "|cFF00FFFFPrecio: 20 Monedas de Escarcha|r", 0, 98)
    
    for i, wings in ipairs(CUSTOM_WINGS) do
        if not player:HasSpell(wings.spellId) then
            player:GossipMenuAddItem(0, wings.name, 0, i)
        else
            player:GossipMenuAddItem(0, wings.name.." |cFF00FF00(Comprado)|r", 0, i)
        end
    end
    player:GossipMenuAddItem(0, "|TInterface\\Icons\\spell_shadow_teleport:25|t Salir", 0, 100)
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if (intid >= 1 and intid <= #CUSTOM_WINGS) then
        local wings = CUSTOM_WINGS[intid]
        
        if player:HasSpell(wings.spellId) then
            player:SendNotification("|cFFFF0000¡Ya tienes estas alas!|r")
        elseif player:GetItemCount(CURRENCY_ID) < CURRENCY_COST then
            player:SendNotification("|cFFFF0000¡Faltan Monedas de Escarcha!|r")
        else
            player:RemoveItem(CURRENCY_ID, CURRENCY_COST)
            player:LearnSpell(wings.spellId)
            player:CastSpell(player, wings.spellId, true)
            player:SendBroadcastMessage("|cFF00FF00¡Has obtenido: "..wings.name.."|r")
        end
    end
    player:GossipComplete()
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
