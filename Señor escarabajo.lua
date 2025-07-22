local NPC_ID = 990099 -- ID único para el NPC (asegúrate que no entre en conflicto)
local TITLE_ID = 142 -- ID correcto para "Señor Escarabajo" en AzerothCore
local SCARAB_MOUNT_ID = 25863 -- ID correcto para "Escarabajo Carmesí" (AQ40)

-- Lista verificada de misiones para el título
local QUEST_IDS = {
    8519, -- A Call to Arms: The Plaguelands!
    8731, -- Field Duty (Horda)
    8732, -- Field Duty Papers (Horda)
    8745, -- The Champion's Charge (Alianza)
    8746, -- The Might of Kalimdor (Alianza)
    8767, -- A Humble Offering
    8788, -- A Thief's Reward
    8791, -- The Fall of Ossirian
    -- Las siguientes son específicas por facción:
    8792, -- The Horde Needs Your Help! (Horda)
    8793, -- The Horde Needs Your Help! (Horda)
    8794, -- The Horde Needs Your Help! (Horda)
    8795, -- The Alliance Needs Your Help! (Alianza)
    8796, -- The Alliance Needs Your Help! (Alianza)
    8797  -- The Alliance Needs Your Help! (Alianza)
}

local function OnGossipHello(event, player, creature)
    -- Verificar si el jugador ya tiene el título
    if player:HasTitle(TITLE_ID) then
        player:GossipMenuAddItem(0, "Ya posees el título de Señor Escarabajo. ¿Deseas algo más?", 0, 0)
    else
        player:GossipMenuAddItem(0, "¡Saludos, campeón de Ahn'Qiraj! ¿Deseas completar todas las misiones necesarias para convertirte en Señor Escarabajo?", 0, 1)
    end
    
    -- Opción para obtener la montura si no la tiene
    if not player:HasSpell(SCARAB_MOUNT_ID) then
        player:GossipMenuAddItem(0, "¿Podrías concederme el glorioso Escarabajo Carmesí?", 0, 2)
    end
    
    player:GossipMenuAddItem(0, "No, gracias.", 0, 3)
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then
        -- Autocompletar solo las misiones correspondientes a la facción
        for _, questId in ipairs(QUEST_IDS) do
            -- Saltar misiones de la facción opuesta
            if (player:GetTeam() == 0 and (questId == 8792 or questId == 8793 or questId == 8794)) or
               (player:GetTeam() == 1 and (questId == 8795 or questId == 8796 or questId == 8797)) then
                goto continue
            end
            
            if not player:HasFinishedQuest(questId) then
                if not player:GetQuestRewardStatus(questId) then
                    player:AddQuest(questId)
                    player:CompleteQuest(questId)
                    player:RewardQuest(questId)
                end
            end
            ::continue::
        end
        
        -- Otorgar el título
        player:SetKnownTitle(TITLE_ID)
        player:SendBroadcastMessage("¡Felicidades! La Puerta de Ahn'Qiraj reconoce tu esfuerzo. Ahora eres un Señor Escarabajo.")
        player:GossipComplete()
        
    elseif intid == 2 then
        -- Dar la montura
        player:LearnSpell(SCARAB_MOUNT_ID)
        player:SendBroadcastMessage("¡El majestuoso Escarabajo Carmesí es ahora tuyo para montar!")
        player:GossipComplete()
        
    elseif intid == 3 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)

local function OnSpawn(event, creature)
    creature:SetNPCFlags(1) -- Flag para gossip
    creature:SetDisplayId(19646) -- Modelo de humano genérico
end

RegisterCreatureEvent(NPC_ID, 5, OnSpawn)

print("[AhnQiraj] NPC Señor Escarabajo cargado correctamente.")
