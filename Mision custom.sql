-- 1. CREAR LA MISIÓN (Quest Template)
INSERT INTO `quest_template` (
    `ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `QuestInfoID`,
    `SuggestedGroupNum`, `RewardNextQuest`, `RewardXPDifficulty`, `RewardMoney`,
    `RewardBonusMoney`, `RewardDisplaySpell`, `RewardSpell`, `RewardHonor`,
    `StartItem`, `Flags`, `LogTitle`, `LogDescription`, `QuestDescription`,
    `AreaDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGoCount1`,
    `ObjectiveText1`
) VALUES (
    90000,     -- ID de la misión
    1,         -- QuestType: 1 = Matar
    80,        -- QuestLevel: Nivel 80
    80,        -- MinLevel: Nivel mínimo 80
    0,         -- QuestSortID
    0,         -- QuestInfoID
    0,         -- SuggestedGroupNum
    0,         -- RewardNextQuest
    0,         -- RewardXPDifficulty
    0,         -- RewardMoney: 0 oro
    0,         -- RewardBonusMoney
    0,         -- RewardDisplaySpell
    0,         -- RewardSpell
    10000,     -- RewardHonor: 10,000 puntos de honor
    0,         -- StartItem
    0,         -- Flags
    'Eliminación del Jefe Supremo', 
    'Derrota al Jefe Supremo enemigo', 
    'Un poderoso jefe enemigo amenaza nuestra seguridad. ¡Elimínalo para recibir una gran recompensa de honor!', 
    '', 
    'Has eliminado al Jefe Supremo enemigo. ¡Buen trabajo!', 
    1234567,   -- ID de tu boss custom
    1,         -- Matar 1 vez
    'Mata al Jefe Supremo' 
);

-- 2. TEXTO DE RECOMPENSA (Quest Offer Reward)
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) 
VALUES (
    90000, 
    '¡Increíble! Has eliminado al jefe enemigo. Toma esta recompensa de honor por tu valentía en el campo de batalla.'
);

-- 3. TEXTO DURANTE LA MISIÓN (Quest Request Items)
INSERT INTO `quest_request_items` (`ID`, `CompletionText`) 
VALUES (
    90000, 
    '¿Has eliminado ya al Jefe Supremo? Regresa cuando hayas completado tu misión.'
);

-- 4. NPC QUE INICIA LA MISIÓN (445081)
INSERT INTO `creature_queststarter` (`id`, `quest`) 
VALUES (445081, 90000);

-- 5. NPC QUE COMPLETA LA MISIÓN (445082)
INSERT INTO `creature_questender` (`id`, `quest`) 
VALUES (445082, 90000);
