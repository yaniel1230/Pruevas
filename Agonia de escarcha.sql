-- 1) Elimina el ítem si existe
DELETE FROM item_template WHERE entry = 90000;

-- 2) Inserta ítem con modelo, stats, Chaos Bane + aura buff
INSERT INTO item_template (
 entry, class, subclass, name, displayid, Quality, Flags, BuyCount, BuyPrice, SellPrice,
 InventoryType, AllowableClass, AllowableRace, ItemLevel, RequiredLevel,
 StatsCount, stat_type1, stat_value1, stat_type2, stat_value2, stat_type3, stat_value3,
 dmg_min1, dmg_max1, dmg_type1, delay,
 spellid_1, spelltrigger_1, spellid_2, spelltrigger_2,
 bonding, description, MaxDurability, sheath
) VALUES (
 90000, 2, 8, "Agonía de Escarcha", 65333, 5, 0, 1, 0, 0,
 17, -1, -1, 284, 80,
 3, 3, 198, 4, 198, 7, 198,
 2239.0, 3726.0, 0, 3700,
 71903, 1,
 90001, 1,
 1, "Portador de Agonía de Escarcha — Rey Exánime nato", 125, 1
);

-- 3) Elimina spell custom si existe
DELETE FROM spell_template WHERE Id = 90001;

-- 4) Crea spell buff con aura pasiva
INSERT INTO spell_template (
 Id, Attributes, AttributesEx, Effects_0, EffectApplyAuraName_0, EffectMiscValue_0,
 DurationIndex, Description_lang
) VALUES (
 90001, 0, 0,
 6, 152, 0,
 1,
 "Portador de Agonía de Escarcha — Rey Exánime nato"
);
