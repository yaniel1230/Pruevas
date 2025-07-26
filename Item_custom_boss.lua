local BOSS_ENTRY = 1234 -- Reemplaza con el entry ID del boss (de la tabla creature_template)
local ITEM_ENTRY = 5678 -- Reemplaza con el entry ID del item (de la tabla item_template)
local ITEM_COUNT = 1    -- Cantidad del item a enviar
local MAIL_SUBJECT = "Recompensa por derrotar al boss"
local MAIL_BODY = "¡Felicidades por derrotar al poderoso boss! Aquí tienes tu recompensa."
local MAIL_STATIONERY = 41 -- 41 = Estacionería normal (61=GM, 62=Auction, etc)

local function OnBossDeath(event, killer, killed)
    -- Verificar si el asesino es un jugador y si lo matado es el boss que nos interesa
    if killer and killed and killer:GetObjectType() == "Player" and killed:ToCreature() and killed:GetEntry() == BOSS_ENTRY then
        -- Verificar si el item existe en la base de datos
        if not GetItemTemplate(ITEM_ENTRY) then
            killer:SendBroadcastMessage("|cFFFF0000Error: El item de recompensa no existe!|r")
            return
        end
        
        -- Enviar el correo con el item (método correcto para AzerothCore)
        killer:SendMail(MAIL_SUBJECT, 
                      MAIL_BODY, 
                      ITEM_ENTRY, 
                      ITEM_COUNT, 
                      0, -- codigo de estampa (0 para ninguno)
                      MAIL_STATIONERY, 
                      0, -- dinero adicional
                      0) -- retraso de entrega (0 para instantáneo)
        
        killer:SendBroadcastMessage("|cFF00FF00Has recibido un correo con tu recompensa por derrotar al boss!|r")
    end
end

RegisterPlayerEvent(7, OnBossDeath) -- EVENT_KILL_CREATURE
