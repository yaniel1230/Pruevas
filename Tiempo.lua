local REWARD_INTERVAL = 3600 -- 1 hora en segundos
local REWARD_ITEM = 49426 -- Emblema de Escarcha
local REWARD_COUNT = 2

local function OnLogin(event, player)
    local guid = player:GetGUIDLow()
    local currentTime = GetTime() -- Función nativa de AzerothCore
    
    -- Consultar último premio desde la BD
    local result = CharDBQuery("SELECT last_reward FROM character_rewards WHERE guid = " .. guid)
    
    if result then
        local lastReward = result:GetUInt32(0)
        local timeSinceLastReward = currentTime - lastReward
        
        if timeSinceLastReward >= REWARD_INTERVAL then
            local rewardsDue = math.floor(timeSinceLastReward / REWARD_INTERVAL)
            player:AddItem(REWARD_ITEM, REWARD_COUNT * rewardsDue)
            player:SendBroadcastMessage("Has recibido " .. (REWARD_COUNT * rewardsDue) .. " emblemas por " .. rewardsDue .. " hora(s) de juego.")
            
            -- Actualizar BD
            CharDBExecute("UPDATE character_rewards SET last_reward = " .. currentTime .. " WHERE guid = " .. guid)
        end
    else
        -- Primera vez del jugador
        CharDBExecute("INSERT INTO character_rewards (guid, last_reward) VALUES (" .. guid .. ", " .. currentTime .. ")")
    end
end

RegisterPlayerEvent(3, OnLogin) -- EVENT_ON_LOGIN

-- Crear tabla necesaria (ejecutar solo una vez en la BD)
-- CREATE TABLE IF NOT EXISTS character_rewards (guid INT PRIMARY KEY, last_reward INT DEFAULT 0);
