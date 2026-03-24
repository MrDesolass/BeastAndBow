-- BeastAndBow TBC Bestiary data
BeastAndBow = BeastAndBow or {}
local BAB = BeastAndBow
BAB._RawPetData = BAB._RawPetData or {}

local function FindSubgroupById(subgroups, subgroupId)
  if type(subgroups) ~= "table" then return nil end
  for _, subgroup in ipairs(subgroups) do
    if subgroup.id == subgroupId then return subgroup end
    local nested = FindSubgroupById(subgroup.subgroups, subgroupId)
    if nested then return nested end
  end
end

local function AddSpeciesToSubgroup(categoryId, subgroupId, speciesEntries)
  local category = BAB.GetPetCategoryById and BAB.GetPetCategoryById(categoryId)
  if not category then return end
  local subgroup = FindSubgroupById(category.subgroups, subgroupId)
  if not subgroup then return end
  subgroup.species = subgroup.species or {}
  for _, species in ipairs(speciesEntries) do
    table.insert(subgroup.species, species)
  end
end

table.insert(BAB._RawPetData,
  {
    id = "Ravagers",
    name = BAB.Locale and BAB.Locale["CATEGORY_RAVAGERS"] or "Ravagers",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Ravager",
    subgroups = {
      {
        id = "BlackPurpleRoseRavagers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAVAGERS_BLACKPURPLEROSERAVAGERS"] or "Black, Purple & Rose Ravagers",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Thornfang Venomspitter", level = {62,63}, zone = "Hellfire Peninsula", learns = { {spell="Bite", rank=8} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20063 },
        }
      },
      {
        id = "GreenIndigoRavagers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAVAGERS_GREENINDIGORAVAGERS"] or "Green & Indigo Ravagers",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Quillfang Skitterer", level = {61,62}, zone = "Hellfire Peninsula", learns = { {spell="Gore", rank=8} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20062 },
        }
      },
      {
        id = "GreenYellowRavagers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAVAGERS_GREENYELLOWRAVAGERS"] or "Green & Yellow Ravagers",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Enraged Ravager", level = {16,17}, zone = "Bloodmyst Isle", learns = { {spell="Gore", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 17062 },
        }
      },
      {
        id = "OrangeBlackRavagers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAVAGERS_ORANGEBLACKRAVAGERS"] or "Orange & Black Ravagers",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Razorfang Hatchling", level = {59,60}, zone = "Hellfire Peninsula", learns = { {spell="Dash", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 19844 },
        }
      },
      {
        id = "OrangeCrimsonRavagers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAVAGERS_ORANGECRIMSONRAVAGERS"] or "Orange & Crimson Ravagers",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Ravager Specimen", level = {9,10}, zone = "Azuremyst Isle", learns = { {spell="Bite", rank=2}, {spell="Gore", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 16885 },
          { name = "Nethermine Ravager", level = 70, zone = "Shadowmoon Valley", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 20284 },
        }
      },
      {
        id = "ColorChangingOrangePurpleRavagers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAVAGERS_COLORCHANGINGORANGEPURPLERAVAGERS"] or "Colour-Changing Orange - Purple Ravagers",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Rip-Blade Ravager", level = 63, zone = "Blade's Edge Mountains", learns = { {spell="Dash", rank=3}, {spell="Gore", rank=9} }, attackSpeed = 2.0, canBeTamed = true, displayId = 17086, notes = { en = "Appearance changer. Pets with this look will randomly appear in one of the above 3 colours each time they're summoned. For the individual looks, see: Orange & Crimson, Orange & Indigo and Purple, Rose & Blue.", de = "Aussehenswechsler. Begleiter mit diesem Aussehen erscheinen bei jeder Beschwörung zufällig in einer der oben genannten drei Farben. Für die einzelnen Varianten siehe: Orange & Karmesinrot, Orange & Indigo und Violett, Rosa & Blau." } },
        }
      },
    }
  }
)

table.insert(BAB._RawPetData,
  {
    id = "NetherRays",
    name = BAB.Locale and BAB.Locale["CATEGORY_NETHERRAYS"] or "Nether Rays",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_NetherRay",
    subgroups = {
      {
        id = "BlueNetherRays",
        name = BAB.Locale and BAB.Locale["SUBGROUP_NETHERRAYS_BLUENETHERRAYS"] or "Blue Nether Rays",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Marshfang Ripper", level = {60,61}, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19404 },
          { name = "Marshfang Slicer", level = {62,63}, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19404 },
        }
      },
      {
        id = "GreenNetherRays",
        name = BAB.Locale and BAB.Locale["SUBGROUP_NETHERRAYS_GREENNETHERRAYS"] or "Green Nether Rays",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Bloodthirsty Marshfang", level = {61,62}, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19405 },
          { name = "Fen Ray", level = 64, zone = "The Underbog (Dungeon)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 19405 },
          { name = "Coilfang Ray", level = {64,70}, zone = "The Slave Pens (Dungeon)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 19405 },
        }
      },
      {
        id = "PurpleNetherRays",
        name = BAB.Locale and BAB.Locale["SUBGROUP_NETHERRAYS_PURPLENETHERRAYS"] or "Purple Nether Rays",
        diet = "Meat, Raw Meat",
        species = {
          { name = "\"Count\" Ungula", level = 63, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19400 },
          { name = "Nether Ray", level = {67,68}, zone = "Netherstorm", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19400 },
          { name = "Netherwing Ray", level = {69,70}, zone = "Shadowmoon Valley", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19400 },
        }
      },
      {
        id = "RedNetherRays",
        name = BAB.Locale and BAB.Locale["SUBGROUP_NETHERRAYS_REDNETHERRAYS"] or "Red Nether Rays",
        diet = "Meat, Raw Meat",
        species = {
          { name = "Netherskate", level = 70, zone = "Shadowmoon Valley", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 20596 },
        }
      }
    }
  }
)

table.insert(BAB._RawPetData,
  {
    id = "Serpents",
    name = BAB.Locale and BAB.Locale["CATEGORY_SERPENTS"] or "Serpents",
    icon = "Interface\\Icons\\Spell_Nature_GuardianWard",
    subgroups = {
      {
        id = "BlueSerpents",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SERPENTS_BLUESERPENTS"] or "Blue Serpent",
        diet = "Fish, Raw Fish, Meat, Raw Meat",
        species = {
          { name = "Deviate Adder", level = {18,19}, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Poison Spit", rank=1} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4317 },
          { name = "Murk Slitherer", level = {45,46}, zone = "The Temple of Atal'Hakkar, Swamp of Sorrows", learns = { {spell="Poison Spit", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4317, notes = { en = "These serpents wander the halls of the Sunken Temple, but outside the dungeon. They are not found inside the instance.", de = "Diese Schlangen wandern durch die Hallen des Versunkenen Tempels, aber außerhalb des Dungeons. Sie befinden sich nicht in der Instanz." } },
          { name = "Razzashi Adder", level = 60, zone = "Zul'Gurub (Raid)", learns = { {spell="Poison Spit", rank=3} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4317 },
        }
      },
      {
        id = "BrownSerpents",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SERPENTS_BROWNSERPENTS"] or "Brown Serpent",
        diet = "Fish, Raw Fish, Meat, Raw Meat",
        species = {
          { name = "Razzashi Adder", level = 60, zone = "Zul'Gurub (Raid)", learns = { {spell="Poison Spit", rank=3} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 15150 },
          { name = "Razzashi Serpent", level = 60, zone = "Zul'Gurub (Raid)", learns = { {spell="Poison Spit", rank=3} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 15150 },
        }
      },
      {
        id = "PurpleSerpents",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SERPENTS_PURPLESERPENTS"] or "Purple Serpent",
        diet = "Fish, Raw Fish, Meat, Raw Meat",
        species = {
          { name = "Deviate Viper", level = {19,20}, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Poison Spit", rank=1} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4312 },
        }
      },
      {
        id = "TealSerpents",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SERPENTS_TEALSERPENTS"] or "Teal Serpent",
        diet = "Fish, Raw Fish, Meat, Raw Meat",
        species = {
          { name = "Murk Spitter", level = {46,47}, zone = "The Temple of Atal'Hakkar, Swamp of Sorrows", learns = { {spell="Poison Spit", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4768, notes = { en = "These serpents wander the halls of the Sunken Temple, but outside the dungeon. They are not found inside the instance.", de = "Diese Schlangen wandern durch die Hallen des Versunkenen Tempels, aber außerhalb des Dungeons. Sie befinden sich nicht in der Instanz." } },
        }
      },
      {
        id = "WhiteSerpents",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SERPENTS_WHITESERPENTS"] or "White Serpent",
        diet = "Fish, Raw Fish, Meat, Raw Meat",
        species = {
          { name = "Deviate Moccasin", level = 19, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Poison Spit", rank=1} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4305, notes = { en = "Three of these snakes spawn as the first wave of attackers while the Disciple of Naralex is attempting to wake Naralex.", de = "Drei dieser Schlangen erscheinen als erste Angriffswelle, während der Junger von Naralex versucht, Naralex zu erwecken." } },
          { name = "Sandfury Guardian", level = {45,46}, zone = "Zul'Farrak (Dungeon)", learns = { {spell="Poison Spit", rank=2} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4305 },
          { name = "Razzashi Cobra", level = 60, zone = "Zul'Gurub (Raid)", learns = { {spell="Poison Spit", rank=3} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4305 },
          { name = "Coilskar Cobra", level = 68, zone = "Shadowmoon Valley", learns = { {spell="Poison Spit", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4305 },
        }
      },
    }
  }
)

table.insert(BAB._RawPetData,
  {
    id = "Dragonhawks",
    name = BAB.Locale and BAB.Locale["CATEGORY_DRAGONHAWKS"] or "Dragonhawks",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",
    subgroups = {
      {
        id = "OrangeDragonhawks",
        name = BAB.Locale and BAB.Locale["SUBGROUP_DRAGONHAWKS_ORANGEDRAGONHAWKS"] or "Orange Dragonhawk",
        diet = "Fish, Raw Fish, Fruit, Meat, Raw Meat",
        species = {
          { name = "Feral Dragonhawk Hatchling", level = {5,6}, zone = "Eversong Woods", learns = { {spell="Fire Breath", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 17547 },
        }
      },
      {
        id = "OrangeRedDragonhawks",
        name = BAB.Locale and BAB.Locale["SUBGROUP_DRAGONHAWKS_ORANGEREDDRAGONHAWKS"] or "Orange & Red Dragonhawk",
        diet = "Fish, Raw Fish, Fruit, Meat, Raw Meat",
        species = {
          { name = "Crazed Dragonhawk", level = {7,8}, zone = "Eversong Woods", learns = { {spell="Fire Breath", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 17545 },
        }
      },
      {
        id = "PinkPurpleDragonhawks",
        name = BAB.Locale and BAB.Locale["SUBGROUP_DRAGONHAWKS_PINKPURPLEDRAGONHAWKS"] or "Pink & Purple Dragonhawk",
        diet = "Fish, Raw Fish, Fruit, Meat, Raw Meat",
        species = {
          { name = "Eclipsion Dragonhawk", level = {67,68}, zone = "Shadowmoon Valley", learns = { {spell="Fire Breath", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20263 },
        }
      },
    }
  }
)

table.insert(BAB._RawPetData,
  {
    id = "WarpStalkers",
    name = BAB.Locale and BAB.Locale["CATEGORY_WARPSTALKERS"] or "Warp Stalkers",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_WarpStalker",
    subgroups = {
      {
        id = "TurquoiseWarpStalkers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_WARPSTALKERS_TURQUOISEWARPSTALKERS"] or "Turquoise Warp Stalker",
        diet = "Fish, Raw Fish, Fruit",
        species = {
          { name = "Warp Chaser", level = {67,68}, zone = "Netherstorm", learns = { {spell="Warp", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 19979 },
        }
      },
      {
        id = "WhiteWarpStalkers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_WARPSTALKERS_WHITEWARPSTALKERS"] or "White Warp Stalker",
        diet = "Fish, Raw Fish, Fruit",
        species = {
          { name = "Warp Stalker", level = {63,64}, zone = "Terokkar Forest", learns = { {spell="Warp", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20025 },
          { name = "Warp Hunter", level = {64,65}, zone = "Terokkar Forest", learns = { {spell="Warp", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20025 },
          { name = "Blackwind Warp Chaser", level = {69,70}, zone = "Terokkar Forest", learns = { {spell="Warp", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20025 },
        }
      },
    }
  }
)

table.insert(BAB._RawPetData,
  {
    id = "Sporebats",
    name = BAB.Locale and BAB.Locale["CATEGORY_SPOREBATS"] or "Sporebats",
    icon = "Interface\\Icons\\ability_hunter_pet_sporebat",
    subgroups = {
      {
        id = "BlueSporebats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SPOREBATS_BLUESPOREBATS"] or "Blue Sporebats",
        diet = "Bread, Cheese, Fruit, Fungus",
        species = {
          { name = "Sporebat", level = {61,62}, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17751 },
        }
      },
      {
        id = "BrownSporebats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SPOREBATS_BROWNSPOREBATS"] or "Brown Sporebats",
        diet = "Bread, Cheese, Fruit, Fungus",
        species = {
          { name = "Sporewing", level = 62, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 18029 },
        }
      },
      {
        id = "GreenSporebats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SPOREBATS_GREENSPOREBATS"] or "Green Sporebats",
        diet = "Bread, Cheese, Fruit, Fungus",
        species = {
          { name = "Young Sporebat", level = {60,61}, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17753 },
          { name = "Greater Sporebat", level = {62,63}, zone = "Zangarmarsh", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17753 },
          { name = "Underbat", level = {62,70}, elite = true, zone = "The Underbog (Dungeon)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17753 },
        }
      },
    },
  }
)

AddSpeciesToSubgroup("Bats", "BrownBats", {
  { name = "Mistbat", level = {9,10}, zone = "Ghostlands", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 4732 },
  { name = "Vampiric Mistbat", level = {13,15}, zone = "Ghostlands", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 4732 },
  { name = "Lesser Scourgebat", level = {16,18}, zone = "Ghostlands", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 4732 },
})

AddSpeciesToSubgroup("Bats", "TanBats", {
  { name = "Shadowbat", level = {69,70}, zone = "Karazhan (Raid)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 1955 },
  { name = "Greater Shadowbat", level = {70,71}, zone = "Karazhan (Raid)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 1955 },
})

AddSpeciesToSubgroup("Bears", "BrownBears", {
  { name = "Brown Bear", level = {9,10}, zone = "Bloodmyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
  { name = "Grizzled Brown Bear", level = {12,13}, zone = "Bloodmyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
})

AddSpeciesToSubgroup("Bears", "DarkBrownBears", {
  { name = "Elder Brown Bear", level = {15,16}, zone = "Bloodmyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 820 },
})

AddSpeciesToSubgroup("Bears", "SicklyDarkBrownBears", {
  { name = "Deathclaw", level = 17, zone = "Bloodmyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 9276 },
})

AddSpeciesToSubgroup("Boars", "Black", {
  { name = "Dire Mottled Boar", level = {6,7}, zone = "Durotar", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=1} }, attackSpeed = 2.0, displayId = 381 },
  { name = "Large Crag Boar", level = {6,7}, zone = "Dun Morogh", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=1} }, attackSpeed = 2.0, displayId = 381 },
  { name = "Corrupted Mottled Boar", level = {10,11}, zone = "Durotar", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=2} }, attackSpeed = 2.0, displayId = 381 },
})

AddSpeciesToSubgroup("Boars", "Brown", {
  { name = "Mountain Boar", level = {10,11}, zone = "Loch Modan", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=2} }, attackSpeed = 2.0, displayId = 1208 },
  { name = "Elder Mountain Boar", level = {16,17}, zone = "Loch Modan", canBeTamed = true, learns = { {spell="Charge", rank=2}, {spell="Gore", rank=3} }, attackSpeed = 2.0, displayId = 1208 },
  { name = "Bellygrub", level = 24, zone = "Redridge Mountains", canBeTamed = true, learns = { {spell="Charge", rank=3}, {spell="Gore", rank=4} }, attackSpeed = 2.0, displayId = 1208 },
})

AddSpeciesToSubgroup("Boars", "Pale", {
  { name = "Elder Mottled Boar", level = {8,9}, zone = "Durotar", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=2} }, attackSpeed = 2.0, displayId = 193 },
  { name = "Rockhide Boar", level = {7,8}, zone = "Elwynn Forest", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=1} }, attackSpeed = 2.0, displayId = 193 },
})

AddSpeciesToSubgroup("Boars", "PlaguedBoars", {
  { name = "Plagued Swine", level = 60, zone = "Eastern Plaguelands", canBeTamed = true, learns = { {spell="Charge", rank=6}, {spell="Gore", rank=8} }, attackSpeed = 2.0, displayId = 6121 },
})

AddSpeciesToSubgroup("Boars", "Red", {
  { name = "Thistle Boar", level = {2,3}, zone = "Teldrassil", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=1} }, attackSpeed = 2.0, displayId = 3035 },
  { name = "Bristleback Battleboar", level = {4,5}, zone = "Mulgore", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=1} }, attackSpeed = 2.0, displayId = 3035 },
  { name = "Goretusk", level = {14,15}, zone = "Westfall", canBeTamed = true, learns = { {spell="Charge", rank=2}, {spell="Gore", rank=2} }, attackSpeed = 2.0, displayId = 3035 },
  { name = "Great Goretusk", level = {16,17}, zone = "Redridge Mountains; Westfall", canBeTamed = true, learns = { {spell="Charge", rank=2}, {spell="Gore", rank=3} }, attackSpeed = 2.0, notes = { en = "Found mainly in the western regions of the Redridge Mountains, and the south-east of Westfall.", de = "Vor allem in den westlichen Regionen des Rotkammgebirges und im Südosten von Westfall zu finden." }, displayId = 3035 },
  { name = "Ashmane Boar", level = {48,49}, zone = "Blasted Lands", canBeTamed = true, learns = { {spell="Charge", rank=5}, {spell="Gore", rank=7} }, attackSpeed = 2.0, notes = { en = "Unfortunately these boars do not keep their pretty blue mist after they are tamed.", de = "Leider behalten diese Eber ihren hübschen blauen Nebel nach dem Zähmen nicht." }, displayId = 3035 },
})

AddSpeciesToSubgroup("Boars", "Yellow", {
  { name = "Battleboar", level = {3,4}, zone = "Mulgore", canBeTamed = true, learns = { {spell="Charge", rank=1}, {spell="Gore", rank=1} }, attackSpeed = 2.0, displayId = 8869 },
})

AddSpeciesToSubgroup("CarrionBirds", "BlackStormcrow", {
  { name = "Dire Raven", level = {67,68}, zone = "Blade's Edge Mountains", learns = { {spell="Dive", rank=3}, {spell="Screech", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20013 },
})

AddSpeciesToSubgroup("CarrionBirds", "RedTwoHeadedVultures", {
  { name = "Bonestripper Buzzard", level = {58,59}, zone = "Hellfire Peninsula", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 16880 },
  { name = "Bonestripper Vulture", level = {61,62}, zone = "Hellfire Peninsula", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 16880 },
})

AddSpeciesToSubgroup("CarrionBirds", "WhiteTwoHeadedVultures", {
  { name = "Trachela", level = 65, zone = "Terokkar Forest", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 20348 },
})

AddSpeciesToSubgroup("Cats", "BlackStripedCats", {
  { name = "Infected Nightstalker Runt", level = {7,8}, zone = "Azuremyst Isle", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 11454 },
  { name = "Nightstalker", level = {8,9}, zone = "Azuremyst Isle", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 11454 },
})

AddSpeciesToSubgroup("Cats", "BrownLynxes", {
  { name = "Elder Springpaw", level = {8,9}, zone = "Eversong Woods", learns = { {spell="Claw", rank=2} }, attackSpeed = 1.5, canBeTamed = true, displayId = 18167 },
  { name = "Starving Ghostclaw", level = {9,10}, zone = "Ghostlands", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 18167 },
  { name = "Ghostclaw Lynx", level = {13,14}, zone = "Ghostlands", learns = { {spell="Claw", rank=2} }, attackSpeed = 1.5, canBeTamed = true, displayId = 18167 },
  { name = "Ghostclaw Ravager", level = {16,17}, zone = "Ghostlands", learns = { {spell="Bite", rank=3}, {spell="Claw", rank=3} }, attackSpeed = 1.5, canBeTamed = true, displayId = 18167 },
  { name = "Grovestalker Lynx", level = {65,66}, zone = "Blade's Edge Mountains", learns = { {spell="Cower", rank=7} }, attackSpeed = 1.5, canBeTamed = true, displayId = 18167 },
  { name = "Ripfang Lynx", level = {68,69}, zone = "Netherstorm", learns = { {spell="Claw", rank=9}, {spell="Cower", rank=7} }, attackSpeed = 1.5, canBeTamed = true, displayId = 18167 },
  { name = "Amani Elder Lynx", level = 70, zone = "Zul'Aman (Raid)", learns = {  }, attackSpeed = 1.5, canBeTamed = true, elite = true, displayId = 18167 },
  { name = "Amani Lynx", level = 70, zone = "Zul'Aman (Raid)", learns = {  }, attackSpeed = 1.5, canBeTamed = true, elite = true, displayId = 18167 },
})

AddSpeciesToSubgroup("Cats", "RedLynxes", {
  { name = "Springpaw Cub", level = 1, zone = "Eversong Woods", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 15507 },
  { name = "Springpaw Lynx", level = {2,3}, zone = "Eversong Woods", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 15507 },
  { name = "Springpaw Stalker", level = {6,7}, zone = "Eversong Woods", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 15507 },
})

AddSpeciesToSubgroup("Cats", "SpottedCats", {
  { name = "Sable Jaguar", level = {67,68}, zone = "The Black Morass (Dungeon)", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 11448 },
})

AddSpeciesToSubgroup("Cats", "StripedWhiteCats", {
  { name = "King Bangalash (Elite)", level = 43, zone = "Stranglethorn Vale", learns = { {spell="Claw", rank=6}, {spell="Cobra Reflexes", rank=1}, {spell="Dash", rank=2} }, attackSpeed = 1.4, canBeTamed = true, displayId = 616, notes = { en = "Has Cobra Reflexes passive (30% attack speed increase, damage reduced). This passive is lost if untamed.", de = "Hat die passive Fähigkeit Kobrareflexe (30% erhöhte Angriffsgeschwindigkeit, verringerter Schaden). Diese passive Fähigkeit geht verloren, wenn er nicht gezähmt wird." } },
})

AddSpeciesToSubgroup("Cats", "WhiteStripedBlackCats", {
  { name = "Blackwind Sabercat", level = {70,71}, zone = "Terokkar Forest", learns = {  }, attackSpeed = 1.5, canBeTamed = true, displayId = 11449 },
})

AddSpeciesToSubgroup("Crabs", "BronzeCrabs", {
  { name = "Barbed Crawler", level = {7,9}, zone = "Azuremyst Isle", attackSpeed = 2.0, canBeTamed = true, displayId = 342 },
})

AddSpeciesToSubgroup("Crocolisks", "GreenCrocolisk", {
  { name = "Tamed Amani Crocolisk", level = 70, zone = "Zul'Aman (Raid)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 1035 },
})

AddSpeciesToSubgroup("Crocolisks", "GreyCrocolisk", {
  { name = "Goretooth", level = 65, zone = "Nagrand", attackSpeed = 2.0, canBeTamed = true, rare = true, displayId = 1250 },
  { name = "Darkwater Crocolisk", level = {67,68}, zone = "The Black Morass (Dungeon)", attackSpeed = 2.0, canBeTamed = true, displayId = 1250 },
  { name = "Amani Crocolisk", level = 70, zone = "Zul'Aman (Raid)", attackSpeed = 2.0, canBeTamed = true, displayId = 1250 },
})

AddSpeciesToSubgroup("Crocolisks", "WhiteCrocolisk", {
  { name = "Barbscale Crocolisk", level = {68,69}, zone = "Netherstorm", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 2996 },
})

AddSpeciesToSubgroup("Owls", "BlackOwls", {
  { name = "Kaliri Swooper", level = 60, zone = "Hellfire Peninsula", learns = { {spell="Dive", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 16724 },
  { name = "Male Kaliri Hatchling", level = 61, zone = "Den of Haal'esh, Hellfire Peninsula", learns = { {spell="Claw", rank=8} }, attackSpeed = 2.0, canBeTamed = true, displayId = 16724 },
  { name = "Windroc Matriarch", level = 66, zone = "Nagrand", learns = { {spell="Dive", rank=3}, {spell="Screech", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 16724 },
  { name = "Gutripper", level = 67, zone = "Nagrand", learns = { {spell="Claw", rank=9}, {spell="Screech", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 16724 },
})

AddSpeciesToSubgroup("Owls", "BrownOwls", {
  { name = "Female Kaliri Hatchling", level = 62, zone = "Den of Haal'esh, Hellfire Peninsula", learns = { {spell="Claw", rank=8} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4615 },
  { name = "Kaliri Matriarch", level = 63, zone = "Hellfire Peninsula", learns = { {spell="Screech", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4615 },
  { name = "Windroc", level = {64,65}, zone = "Nagrand", learns = { {spell="Dive", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4615 },
  { name = "Ravenous Windroc", level = {65,66}, zone = "Nagrand", learns = { {spell="Claw", rank=9} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4615 },
  { name = "Greater Windroc", level = {66,67}, zone = "Nagrand", learns = { {spell="Claw", rank=9}, {spell="Screech", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4615 },
})

AddSpeciesToSubgroup("Owls", "DarkBrownOwls", {
  { name = "Avian Darkhawk", level = {67,70}, zone = "Sethekk Halls (Dungeon)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 20725 },
  { name = "Akkarai Hatchling", level = 70, zone = "Skettis, Terokkar Forest", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 20725 },
})

AddSpeciesToSubgroup("Owls", "GreyOwls", {
  { name = "Shadowwing Owl", level = {66,67}, zone = "Shadowmoon Valley", learns = { {spell="Claw", rank=9}, {spell="Dive", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6212 },
})

AddSpeciesToSubgroup("Owls", "RedOwls", {
  { name = "Avian Ripper", level = {67,70}, zone = "Sethekk Halls (Dungeon)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 20730 },
})

AddSpeciesToSubgroup("Owls", "RedPurpleOwls", {
  { name = "Avian Warhawk", level = {68,71}, zone = "Sethekk Halls (Dungeon)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 20729 },
  { name = "Skettis Kaliri", level = 70, zone = "Terokkar Forest", learns = { {spell="Dive", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20729 },
})

AddSpeciesToSubgroup("Raptors", "BlackSpikedRaptors", {
  { name = "Daggermaw Blackhide", level = {65,66}, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19770 },
  { name = "Bladespire Ravager", level = 67, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 19770 },
})

AddSpeciesToSubgroup("Raptors", "BrownSpikedRaptors", {
  { name = "Bladespire Raptor", level = {65,66}, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19758 },
  { name = "Scythetooth Raptor", level = {68,69}, zone = "Netherstorm", learns = { {spell="Bite", rank=9}, {spell="Dash", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 19758 },
})

AddSpeciesToSubgroup("Raptors", "GreenSpikedRaptors", {
  { name = "Felsworn Daggermaw", level = {67,68}, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19742 },
})

AddSpeciesToSubgroup("Raptors", "RedSpikedRaptors", {
  { name = "Daggermaw Lashtail", level = {66,67}, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 19759 },
})

AddSpeciesToSubgroup("Scorpids", "BlackScorpids", {
  { name = "Scorchshell Pincer", level = {68,69}, zone = "Shadowmoon Valley", learns = { {spell="Fire Resistance", rank=5}, {spell="Scorpid Poison", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6068 },
})

AddSpeciesToSubgroup("Scorpids", "PinkScorpids", {
  { name = "Scorpid Bonecrawler", level = {64,65}, zone = "Terokkar Forest", learns = { {spell="Claw", rank=9}, {spell="Natural Armor", rank=10}, {spell="Scorpid Poison", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 2414 },
})

AddSpeciesToSubgroup("Spiders", "BlackWidowSpiders", {
  { name = "Dreadfang Widow", level = {64,65}, zone = "Terokkar Forest", learns = { {spell="Bite", rank=9} }, attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
})

AddSpeciesToSubgroup("Spiders", "CrystalSpiders", {
  { name = "Coldmist Stalker", level = {69,70}, zone = "Karazhan (Raid)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4456 },
  { name = "Coldmist Widow", level = {69,71}, zone = "Karazhan (Raid)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 4456 },
})

AddSpeciesToSubgroup("Spiders", "GreyTarantulas", {
  { name = "Blackfang Tarantula", level = {67,68}, zone = "The Black Morass (Dungeon)", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
})

AddSpeciesToSubgroup("Spiders", "OliveSpiders", {
  { name = "Cavern Crawler", level = 65, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 1088 },
})

AddSpeciesToSubgroup("Spiders", "OrangeBlackBarbedSpiders", {
  { name = "Myst Leecher", level = {17,18}, zone = "Bloodmyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 18043 },
  { name = "Deathskitter", level = 64, zone = "Terokkar Forest", learns = {  }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 18043 },
})

AddSpeciesToSubgroup("Spiders", "RedBlackBarbedSpiders", {
  { name = "Zarakh", level = 19, zone = "Bloodmyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17180 },
})

AddSpeciesToSubgroup("Spiders", "RedYellowBarbedSpiders", {
  { name = "Myst Spinner", level = {16,17}, zone = "Bloodmyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17346 },
  { name = "Ridgespine Stalker", level = {66,67}, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17346 },
  { name = "Ridgespine Horror", level = {67,68}, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 17346 },
})

AddSpeciesToSubgroup("Spiders", "TanSpiders", {
  { name = "Mature Cavern Crawler", level = 65, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 711 },
})

AddSpeciesToSubgroup("Tallstriders", "BrownTallstrider", {
  { name = "Timberstrider Fledgling", level = {5,7}, zone = "Azuremyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
  { name = "Timberstrider", level = {6,8}, zone = "Azuremyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
  { name = "Greater Timberstrider", level = {7,9}, zone = "Azuremyst Isle", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
})

AddSpeciesToSubgroup("Tallstriders", "PurpleTallstrider", {
  { name = "Lost Torranche", level = 70, zone = "Terokkar Forest", learns = { {spell="Cower", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 21087 },
})

AddSpeciesToSubgroup("WindSerpents", "BlueSpikedWindSerpents", {
  { name = "Swiftwing Shredder", level = {68,69}, zone = "Netherstorm", learns = { {spell="Lightning Breath", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 19709 },
  { name = "Cobalt Serpent", level = {68,71}, zone = "Sethekk Halls (Dungeon)", learns = { {spell="Lightning Breath", rank=6} }, attackSpeed = 2.0, canBeTamed = true, elite = true, displayId = 19709 },
})

AddSpeciesToSubgroup("WindSerpents", "DarkBlueWindSerpent", {
  { name = "Soulflayer", level = 61, elite = true, zone = "Zul'Gurub (Raid)", learns = { {spell="Lightning Breath", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3006 },
})

AddSpeciesToSubgroup("WindSerpents", "GreenSpikedWindSerpents", {
  { name = "Felsworn Scalewing", level = {66,67}, zone = "Blade's Edge Mountains", learns = { {spell="Lightning Breath", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20094 },
})

AddSpeciesToSubgroup("WindSerpents", "RedSpikedWindSerpents", {
  { name = "Scalewing Serpent", level = {66,67}, zone = "Blade's Edge Mountains", learns = { {spell="Lightning Breath", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 20838 },
})

AddSpeciesToSubgroup("Wolves", "BlackWolves", {
  { name = "Rema", level = 66, zone = "Blade's Edge Mountains", learns = { {spell="Bite", rank=9}, {spell="Furious Howl", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 782 },
  { name = "Bloodmaul Battle Worg", level = {66,67}, zone = "Blade's Edge Mountains", learns = { {spell="Furious Howl", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 782 },
})

AddSpeciesToSubgroup("Wolves", "BlackWorgs", {
  { name = "Ripp", level = {58,59}, zone = "Hellfire Peninsula", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 11421 },
  { name = "Bleeding Hollow Worg", level = 60, zone = "Hellfire Peninsula", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 11421 },
  { name = "Feng", level = 60, zone = "Hellfire Peninsula", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 11421 },
  { name = "Dark Worg", level = {64,65}, zone = "Nagrand", learns = { {spell="Furious Howl", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 11421 },
})

AddSpeciesToSubgroup("Wolves", "BrownGreyWorgs", {
  { name = "Ironjaw", level = {63,64}, zone = "Terokkar Forest", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 18063 },
})

AddSpeciesToSubgroup("Wolves", "LightGreyWorgs", {
  { name = "Timber Worg", level = {62,63}, zone = "Terokkar Forest", learns = { {spell="Furious Howl", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 11413 },
  { name = "Timber Worg Alpha", level = {63,64}, zone = "Terokkar Forest", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 11413 },
})

AddSpeciesToSubgroup("Wolves", "RedWorgs", {
  { name = "Thunderlord Dire Wolf", level = {65,66}, zone = "Blade's Edge Mountains", learns = {  }, attackSpeed = 2.0, canBeTamed = true, displayId = 11420 },
})

AddSpeciesToSubgroup("Wolves", "TanWolves", {
  { name = "Bloodmaul Dire Wolf", level = 65, zone = "Blade's Edge Mountains", learns = { {spell="Furious Howl", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 161 },
})

local tbcSkillData = {
  [1] = { "Feueratem 1", "Aufspießen 1" },
  [8] = { "Aufspießen 2" },
  [16] = { "Aufspießen 3" },
  [24] = { "Aufspießen 4" },
  [30] = { "Vermeidung 1", "Cobra Reflexes 1" },
  [32] = { "Aufspießen 5" },
  [40] = { "Aufspießen 6" },
  [48] = { "Aufspießen 7" },
  [56] = { "Aufspießen 8" },
  [60] = { "Vermeidung 2", "Feueratem 2", "Sphärensprung 1" },
  [63] = { "Aufspießen 9" },
}

for level, entries in pairs(tbcSkillData) do
  local current = BAB.SkillLevelData[level]
  local partsList = {}
  if type(current) == "string" and current ~= "" then
    for entry in string.gmatch(current, "[^,]+") do
      table.insert(partsList, (entry:gsub("^%s+", ""):gsub("%s+$", "")))
    end
  end
  for _, entry in ipairs(entries) do
    table.insert(partsList, entry)
  end
  BAB.SkillLevelData[level] = table.concat(partsList, ", ")
end

local tbcAbilitiesByLevel = {
  [1] = {
    { id = "Fire Breath", name = "Feueratem", rank = 1 },
    { id = "Gore", name = "Aufspießen", rank = 1 },
  },
  [8] = {
    { id = "Gore", name = "Aufspießen", rank = 2 },
  },
  [16] = {
    { id = "Gore", name = "Aufspießen", rank = 3 },
  },
  [24] = {
    { id = "Gore", name = "Aufspießen", rank = 4 },
  },
  [30] = {
    { id = "Avoidance", name = "Vermeidung", rank = 1 },
    { id = "Cobra Reflexes", name = "Cobra Reflexes", rank = 1 },
  },
  [32] = {
    { id = "Gore", name = "Aufspießen", rank = 5 },
  },
  [40] = {
    { id = "Gore", name = "Aufspießen", rank = 6 },
  },
  [48] = {
    { id = "Gore", name = "Aufspießen", rank = 7 },
  },
  [56] = {
    { id = "Gore", name = "Aufspießen", rank = 8 },
  },
  [60] = {
    { id = "Avoidance", name = "Vermeidung", rank = 2 },
    { id = "Fire Breath", name = "Feueratem", rank = 2 },
    { id = "Warp", name = "Sphärensprung", rank = 1 },
  },
  [63] = {
    { id = "Gore", name = "Aufspießen", rank = 9 },
  },
}

for level, entries in pairs(tbcAbilitiesByLevel) do
  BAB.AbilitiesByLevel[level] = BAB.AbilitiesByLevel[level] or {}
  for _, entry in ipairs(entries) do
    table.insert(BAB.AbilitiesByLevel[level], entry)
  end
end

local tbcAbilityIcons = {
  { name = "Fire Breath", path = "Interface\\Icons\\spell_fire_burnout" },
  { name = "Gore", path = "Interface\\Icons\\inv_weapon_shortblade_28" },
  { name = "Warp", path = "Interface\\Icons\\spell_arcane_arcane04" },
  { name = "Avoidance", path = "Interface\\Icons\\spell_magic_lesserinvisibilty" },
  { name = "Cobra Reflexes", path = "Interface\\Icons\\spell_nature_guardianward" },
}
for _, entry in ipairs(tbcAbilityIcons) do
  table.insert(BAB.AbilityIcons, entry)
end

local tbcAbilityOrder = { "Fire Breath", "Gore", "Warp", "Avoidance", "Cobra Reflexes" }
for _, entry in ipairs(tbcAbilityOrder) do
  table.insert(BAB.AbilityOrder, entry)
end

BAB._parsedSkillLevels = nil
