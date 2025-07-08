DELETE FROM `item_template` WHERE `entry` = 49623;

INSERT INTO `item_template` (
  `entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`,
  `AllowableRace`, `ItemLevel`, `RequiredLevel`, `RequiredSkill`, `RequiredSkillRank`, `RequiredSpell`, `RequiredHonorRank`, `RequiredCityRank`,
  `RequiredReputationFaction`, `RequiredReputationRank`, `maxcount`, `stackable`, `ContainerSlots`, `StatsCount`,
  `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `ScalingStatDistribution`, `ScalingStatValue`,
  `dmg_min1`, `dmg_max1`, `dmg_type1`, `delay`, `ammo_type`, `RangedModRange`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`,
  `spellcategory_1`, `spellcategorycooldown_1`, `bonding`, `description`, `PageText`, `LanguageID`, `PageMaterial`, `startquest`, `lockid`,
  `sheath`, `RandomProperty`, `RandomSuffix`, `block`, `itemset`, `MaxDurability`, `area`, `Map`, `BagFamily`, `TotemCategory`, `socketColor_1`,
  `socketColor_2`, `socketColor_3`, `socketBonus`, `GemProperties`, `ArmorDamageModifier`, `duration`, `ItemLimitCategory`, `HolidayId`,
  `ScriptName`
) VALUES (
  49623, 2, 8, "Agonía de las Sombras", 65542, 5, 0, 1, 0, 0, 17, -1,
  -1, 284, 80, 0, 0, 0, 0, 0,
  0, 0, 1, 0, 0, 3,
  3, 198, 4, 198, 7, 198, 0, 0,
  2239.0, 3726.0, 0, 3700, 0, 0, 71903, 1, 0, -1,
  0, -1, 1, "Una hoja creada con fragmentos del alma del Rey Exánime.", 0, 0, 0, 0, 0,
  1, 0, 0, 0, 0, 125, 0, 0, 0, 0, 2,
  8, 0, 3312, 0, 0.0, 0, 0, 0,
  ""
);
