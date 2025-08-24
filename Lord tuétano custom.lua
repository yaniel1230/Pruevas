local BOSS_ENTRY = 50000  -- Cambia este ID por el entry de tu boss personalizado

-- Spells de WotLK existentes en la base de datos
local SPELL_BONE_SPIKE = 69057   -- Pincho óseo (usando el spell real de Marrowgar)
local SPELL_BONE_STORM = 69076   -- Tormenta ósea (usando el spell real de Marrowgar)
local SPELL_COLD_FLAME = 69146   -- Llama fría (usando el spell real de Marrowgar)
local SPELL_IMPALE = 69065       -- Empalar (usando el spell real de Marrowgar)
local SPELL_SABER_LASH = 69167   -- Latigazo (spell existente en WotLK)

local PHASE_NORMAL = 1
local PHASE_BONE_STORM = 2

local boneStormTargets = {}

local function GetRandomPlayer(creature)
    local players = creature:GetPlayersInRange(100)
    if players and #players > 0 then
        return players[math.random(1, #players)]
    end
    return nil
end

local function SpawnColdFlames(creature, target)
    if not target then return end
    
    local x, y, z = target:GetX(), target:GetY(), target:GetZ()
    local angle = creature:GetAngle(target)
    local distance = 5.0
    
    for i = 1, 5 do
        local flameX = x + math.cos(angle) * distance * i
        local flameY = y + math.sin(angle) * distance * i
        local flameZ = z
        
        -- Crear el efecto visual de llama fría
        creature:CastSpell(flameX, flameY, flameZ, SPELL_COLD_FLAME, true)
    end
end

local function CastBoneSpike(creature)
    local target = GetRandomPlayer(creature)
    if target then
        creature:CastSpell(target, SPELL_BONE_SPIKE, true)
    end
end

local function EnterBoneStorm(creature)
    creature:SetPhase(PHASE_BONE_STORM)
    creature:CastSpell(creature, SPELL_BONE_STORM, false)
    creature:SetWalk(false)
    creature:SetRun(true)
    creature:AttackStop()
    creature:SetReactState(0) -- ReactState passive durante la tormenta
    
    -- Limpiar tabla de objetivos
    boneStormTargets = {}
    
    -- Programar el final de la tormenta ósea
    creature:RegisterEvent(function()
        creature:SetPhase(PHASE_NORMAL)
        creature:RemoveAura(SPELL_BONE_STORM)
        creature:SetReactState(1) -- ReactState aggresive
        if creature:GetVictim() then
            creature:AttackStart(creature:GetVictim())
        end
    end, 20000, 1) -- 20 segundos de tormenta
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("¡El frío de la tumba os espera!", 0)
    
    -- Programar eventos de habilidades
    creature:RegisterEvent(BoneStormPhase, 60000, 0) -- Primera tormenta a los 60 segundos
    creature:RegisterEvent(CastBoneSpikeEvent, 15000, 0) -- Picos óseos cada 15 segundos
    creature:RegisterEvent(CastColdFlameEvent, 25000, 0) -- Llamas frías cada 25 segundos
    creature:RegisterEvent(CastImpaleEvent, 35000, 0) -- Empalar cada 35 segundos
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:SetPhase(PHASE_NORMAL)
    creature:RemoveAura(SPELL_BONE_STORM)
end

local function OnDied(event, creature, killer)
    creature:RemoveEvents()
    creature:SendUnitYell("¡El... frío... me... consume...!", 0)
end

local function BoneStormPhase(event, delay, repeats, creature)
    if creature:GetHealthPct() <= 20 then -- No hacer tormenta si está por debajo del 20%
        return
    end
    
    creature:SendUnitYell("¡Giran los huesos! ¡Os haré pedazos!", 0)
    EnterBoneStorm(creature)
    
    -- Reprogramar próxima tormenta
    creature:RegisterEvent(BoneStormPhase, 90000, 1) -- Siguiente tormenta en 90 segundos
end

local function CastBoneSpikeEvent(event, delay, repeats, creature)
    if creature:GetPhase() == PHASE_NORMAL then
        CastBoneSpike(creature)
    end
end

local function CastColdFlameEvent(event, delay, repeats, creature)
    if creature:GetPhase() == PHASE_NORMAL then
        local target = GetRandomPlayer(creature)
        if target then
            creature:SendUnitYell("¡Arderéis en llamas gélidas!", 0)
            SpawnColdFlames(creature, target)
        end
    end
end

local function CastImpaleEvent(event, delay, repeats, creature)
    if creature:GetPhase() == PHASE_NORMAL then
        local target = creature:GetVictim()
        if target then
            creature:CastSpell(target, SPELL_IMPALE, true)
        end
    end
end

local function OnDamageTaken(event, creature, attacker, damage)
    if creature:GetHealthPct() <= 30 and not creature:HasAura(SPELL_BONE_STORM) then
        -- Enfurecerse al llegar al 30% de vida
        creature:CastSpell(creature, 26662, true) -- Spell de enfurecimiento (Berserk)
        creature:SendUnitYell("¡LA CARNE SE DESGARRA! ¡LOS HUESOS CANTAN!", 0)
    end
    return damage
end

local function BoneStormMovement(event, delay, repeats, creature)
    if creature:GetPhase() == PHASE_BONE_STORM then
        local target = GetRandomPlayer(creature)
        if target then
            -- Mover al boss hacia un jugador aleatorio durante la tormenta
            creature:MoveTo(target:GetX(), target:GetY(), target:GetZ(), false)
            
            -- Aplicar daño a todos los jugadores cercanos
            local players = creature:GetPlayersInRange(10)
            if players then
                for _, player in ipairs(players) do
                    if not boneStormTargets[player:GetGUIDLow()] then
                        creature:DealDamage(player, math.random(1500, 2500))
                        boneStormTargets[player:GetGUIDLow()] = true
                    end
                end
            end
        end
    end
end

-- Registrar los eventos
RegisterCreatureEvent(BOSS_ENTRY, 1, OnEnterCombat)  -- EVENT_ON_ENTER_COMBAT
RegisterCreatureEvent(BOSS_ENTRY, 2, OnLeaveCombat)  -- EVENT_ON_LEAVE_COMBAT  
RegisterCreatureEvent(BOSS_ENTRY, 4, OnDied)        -- EVENT_ON_DIED
RegisterCreatureEvent(BOSS_ENTRY, 9, OnDamageTaken) -- EVENT_ON_DAMAGE_TAKEN

-- Evento personalizado para el movimiento durante la tormenta ósea
RegisterCreatureEvent(BOSS_ENTRY, 6, function(event, creature)
    creature:RegisterEvent(BoneStormMovement, 2000, 0) -- Actualizar movimiento cada 2 segundos durante la tormenta
end)
