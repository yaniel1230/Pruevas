DELETE FROM `item_template` WHERE `entry` = 49623;

INSERT INTO `item_template` (
  `entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`,
  `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`,
  `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`,
  `dmg_min1`, `dmg_max1`, `dmg_type1`, `delay`, `spellid_1`, `spelltrigger_1`, `bonding`,
  `description`, `MaxDurability`, `sheath`
) VALUES (
  49623, 2, 8, "Agonía de las Sombras", 65484, 5, 0, 1, 0, 0,
  17, -1, -1, 284, 80,
  3, 3, 198, 4, 198, 7, 198,
  2239, 3726, 0, 3700, 71903, 1, 1,
  "Una terrible oscuridad persiste en esta hoja.", 125, 1
);
