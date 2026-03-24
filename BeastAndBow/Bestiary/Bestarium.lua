-- BeastAndBow Pet Encyclopedia Data
-- Categories with placeholder species entries; fill out progressively.
-- LAZY-LOADING: Data is stored in _RawPetData and initialized on-demand via GetPetCategories()
BeastAndBow = BeastAndBow or {}
BeastAndBow = BeastAndBow or {}
local BAB = BeastAndBow
-- Ensure Pets data can access localization table used by the addon
-- Use a metatable to dynamically look up BeastAndBow.L at runtime
BAB.Locale = setmetatable({}, {
    __index = function(self, key)
        if BeastAndBow and BeastAndBow.L and BeastAndBow.L[key] then
            return BeastAndBow.L[key]
        end
        return nil
    end
})
-- Define BuildAbilityDB early to avoid nil errors
function BeastAndBow.BuildAbilityDB()
    local abilityDB = {}
    local iconMap = {}
  local trainerFallbackSkills = {
    "Growl",
    "Great Stamina",
    "Natural Armor",
    "Avoidance",
    "Arcane Resistance",
    "Fire Resistance",
    "Frost Resistance",
    "Nature Resistance",
    "Shadow Resistance",
  }
    -- 1. Build Icon Map from BAB.AbilityIcons
    if BAB and BAB.AbilityIcons then
        for _, data in ipairs(BAB.AbilityIcons) do
            if data.name and data.path then
                iconMap[data.name] = data.path
            end
        end
    end
    -- 2. Build basic ability and rank info from BAB.AbilitiesByLevel
    if BAB.AbilitiesByLevel and next(BAB.AbilitiesByLevel) then
        for level, abilities in pairs(BAB.AbilitiesByLevel) do
            for _, abilityInfo in ipairs(abilities) do
                local id = abilityInfo.id or abilityInfo.name
                if id then
                    if not abilityDB[id] then
                        abilityDB[id] = {
                            id = id,
                            name = abilityInfo.name or id,
                            icon = iconMap[id] or "Interface\\Icons\\INV_Misc_QuestionMark",
                            ranks = {}
                        }
                    end
                    local rank = abilityInfo.rank or 1
                    abilityDB[id].ranks[rank] = {
                        rank = rank,
                        level = level,
                        pets = {}
                    }
                end
            end
        end
    end
    -- 3. Scan all pets and link them to the abilities they teach
    for _, category in ipairs(BeastAndBow.GetPetCategories() or {}) do
        local function processSpeciesList(speciesList, subgroupInfo)
            if not speciesList then return end
            for _, petInfo in ipairs(speciesList) do
                if petInfo.learns and #petInfo.learns > 0 then
                    for _, learnInfo in ipairs(petInfo.learns) do
                        local spell, rank = learnInfo.spell, learnInfo.rank
                        if spell and rank and abilityDB[spell] and abilityDB[spell].ranks[rank] then
                            table.insert(abilityDB[spell].ranks[rank].pets, {
                                petInfo = petInfo,
                                subgroupInfo = subgroupInfo
                            })
                        end
                    end
                end
            end
        end
        -- Handle nested and non-nested subgroups
        if category.subgroups then
            for _, sub1 in ipairs(category.subgroups) do
                if sub1.species then processSpeciesList(sub1.species, sub1) end
                if sub1.subgroups then
                    for _, sub2 in ipairs(sub1.subgroups) do
                        if sub2.species then processSpeciesList(sub2.species, sub2) end
                        if sub2.subgroups then
                             for _, sub3 in ipairs(sub2.subgroups) do
                                if sub3.species then processSpeciesList(sub3.species, sub3) end
                            end
                        end
                    end
                end
            end
        end
    end
    -- 4. Sort ranks within each ability
    -- 4a. Ensure trainer-taught skills are present if their icon exists in current dataset
    for _, skillName in ipairs(trainerFallbackSkills) do
      if not abilityDB[skillName] and iconMap[skillName] then
        abilityDB[skillName] = {
          id = skillName,
          name = skillName,
          icon = iconMap[skillName],
          ranks = {
            {
              rank = 1,
              level = 1,
              pets = {}
            }
          }
        }
      end
    end

    -- 4. Sort ranks within each ability
    for _, skillInfo in pairs(abilityDB) do
        local rankList = {}
        for _, rankData in pairs(skillInfo.ranks) do
            table.insert(rankList, rankData)
        end
        table.sort(rankList, function(a, b) return a.rank < b.rank end)
        skillInfo.ranks = rankList
    end
    BAB.AbilityDB = abilityDB
    return abilityDB
end
BAB._RawPetData = {
  {
    id = "Cats",
    name = BAB.Locale and BAB.Locale["CATEGORY_CATS"] or "Cats",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Cat",
    subgroups = {
      {
        id = "BlackCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_BLACKCATS"] or "Black Cats",
        diet = "Meat, Fish",
        species = {
          { name = "Young Panther", level = {30,31}, zone = "Stranglethorn Vale", learns = { {spell="Cower", rank=3} }, attackSpeed = 1.3, displayId = 2437 },
          { name = "Kurzen War Panther", level = {32,33}, zone = "Stranglethorn Vale", learns = {  }, attackSpeed = 1.3, displayId = 2437 },
          { name = "Panther", level = {32,33}, zone = "Stranglethorn Vale", learns = { {spell="Cower", rank=3} }, attackSpeed = 1.3, displayId = 2437 },
          { name = "Shadowmaw Panther", level = {37,38}, zone = "Stranglethorn Vale", learns = { {spell="Prowl", rank=1} }, attackSpeed = 1.5, displayId = 2437 },
          { name = "Shadow Panther", level = {39,40}, zone = "Swamp of Sorrows", learns = { {spell="Prowl", rank=1} }, attackSpeed = 1.6, displayId = 2437 },
          { name = "Bhag'thera (Elite)", level = 40, zone = "Stranglethorn Vale", learns = { {spell="Dash", rank=2} }, attackSpeed = 1.5, displayId = 2437 },
          { name = "Elder Shadowmaw Panther", level = {42,43}, zone = "Stranglethorn Vale", learns = { {spell="Dash", rank=2}, {spell="Prowl", rank=2} }, attackSpeed = 1.5, displayId = 2437 },
          { name = "Jaguero Stalker", level = 50, zone = "Stranglethorn Vale", learns = { {spell="Cower", rank=5}, {spell="Prowl", rank=3} }, attackSpeed = 2.0, displayId = 2437 },
          { name = "Zulian Panther (Elite)", level = 60, zone = "Zul'Gurub (Raid)", learns = { {spell="Dash", rank=3} }, attackSpeed = 2.0, displayId = 2437 },
          { name = "Zulian Prowler", level = 60, zone = "Zul'Gurub (Raid)", learns = {  }, attackSpeed = 1.6, displayId = 2437 },
        }
      },
      {
        id = "BlackStripedCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_BLACKSTRIPEDCATS"] or "Black-Striped",
        diet = "Meat, Fish",
        species = {
          { name = "Young Nightsaber", level = 1, zone = "Teldrassil", attackSpeed = 2.0, canBeTamed = true, displayId = 11454 },
          { name = "Nightsaber", level = {5,6}, zone = "Teldrassil", learns = { {spell="Cower", rank=1} }, attackSpeed = 1.4, canBeTamed = true, displayId = 11454 },
          { name = "Elder Nightsaber", level = {8,9}, zone = "Teldrassil", attackSpeed = 1.4, canBeTamed = true, displayId = 11454 },
          { name = "Feral Nightsaber", level = {10,11}, zone = "Teldrassil", attackSpeed = 1.5, canBeTamed = true, displayId = 11454 },
          { name = "Shadowclaw (Rare)", level = 13, zone = "Darkshore", attackSpeed = 1.5, canBeTamed = true, displayId = 11454 },
          { name = "Moonstalker Matriarch", level = {19,20}, zone = "Darkshore", attackSpeed = 1.3, canBeTamed = true, displayId = 11454 },
        }
      },
      {
        id = "WhiteStripedBlackCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_WHITESTRIPEDBLACKCATS"] or "White-Striped Black Cats",
        diet = "Meat, Fish",
        species = {
          { name = "Moonstalker Runt", level = {10,11}, zone = "Darkshore", learns = { {spell="Cower", rank=1} }, attackSpeed = 1.3, canBeTamed = true, displayId = 11449 },
          { name = "Moonstalker", level = {14,15}, zone = "Darkshore", attackSpeed = 1.3, canBeTamed = true, displayId = 11449 },
          { name = "Moonstalker Sire", level = {17,18}, zone = "Darkshore", learns = { {spell="Cower", rank=2} }, attackSpeed = 1.3, canBeTamed = true, displayId = 11449 },
        }
      },
      {
        id = "BrownTanCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_BROWNTANCATS"] or "Brown & Tan",
        diet = "Meat, Fish",
        species = {
          { name = "Araga (Rare)", level = 35, zone = "Alterac Mountains", attackSpeed = 1.4, displayId = 1933 },
        }
      },
      {
        id = "GoldenTanCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_GOLDENTANCATS"] or "Golden - Tan",
        diet = "Meat, Fish",
        species = {
          { name = "Mountain Cougar", level = 3, zone = "Mulgore", attackSpeed = 2.0, canBeTamed = true, displayId = 11451 },
          { name = "Flatland Cougar", level = {7,8}, zone = "Mulgore", learns = { {spell="Cower", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 11451 },
          { name = "Flatland Prowler", level = 9, zone = "Mulgore", attackSpeed = 2.0, canBeTamed = true, displayId = 11451 },
          { name = "Savannah Huntress", level = {11,12}, zone = "The Barrens", attackSpeed = 1.5, canBeTamed = true, displayId = 11451 },
          { name = "Savannah Matriarch", level = {17,18}, zone = "The Barrens", attackSpeed = 1.7, canBeTamed = true, displayId = 11451 },
          { name = "Starving Mountain Lion", level = {23,24}, zone = "Hillsbrad Foothills", learns = { {spell="Cower", rank=2} }, attackSpeed = 1.2, canBeTamed = true, displayId = 11451 },
          { name = "Feral Mountain Lion", level = {27,28}, zone = "Hillsbrad Foothills", learns = { {spell="Cower", rank=3} }, attackSpeed = 1.2, canBeTamed = true, displayId = 11451 },
          { name = "Needles Cougar", level = {27,28}, zone = "Thousand Needles", attackSpeed = 1.2, canBeTamed = true, displayId = 11451 },
          { name = "Mountain Lion", level = {32,33}, zone = "Alterac Mountains", learns = { {spell="Prowl", rank=1} }, attackSpeed = 1.4, canBeTamed = true, displayId = 11451 },
          { name = "Hulking Mountain Lion", level = {33,34}, zone = "Alterac Mountains", attackSpeed = 1.4, canBeTamed = true, displayId = 11451 },
          { name = "Broken Tooth (Rare)", level = 37, zone = "Badlands", learns = { {spell="Dash", rank=1} }, attackSpeed = 1.0, displayId = 11451 },
        }
      },
      {
        id = "GhostlyWhiteCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_GHOSTLYWHITECATS"] or "Ghostly Spotted White",
        diet = "Meat, Fish",
        species = {
          { name = "Ghost Saber", level = {19,20}, zone = "Ruins of Mathystra, Darkshore", attackSpeed = 2.0, learns = { {spell="Claw", rank=3} }, canBeTamed = true, displayId = 4472, notes = { en = "Remains ghostly after taming. Click Cat Figurines in the Ruins of Mathystra to spawn.", de = "Bleibt nach dem ZÃ¤hmen geistig. Klicke auf Katzenfiguren in den Ruinen von Mathystra, um sie zu spawnen." } },
        }
      },
      {
        id = "SpottedCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_SPOTTEDCATS"] or "Spotted",
        diet = "Meat, Fish",
        species = {
          { name = "Mangy Nightsaber", level = 2, zone = "Teldrassil", attackSpeed = 2.0, canBeTamed = true, displayId = 11448 },
          { name = "Nightsaber Stalker", level = {7,8}, zone = "Teldrassil", attackSpeed = 1.4, canBeTamed = true, displayId = 11448 },
          { name = "Duskstalker (Rare)", level = 9, zone = "Teldrassil", attackSpeed = 1.4, canBeTamed = true, displayId = 11448 },
          { name = "Twilight Runner", level = {23,24}, zone = "Stonetalon Mountains", learns = { {spell="Cower", rank=2} }, attackSpeed = 1.3, displayId = 11448 },
        }
      },
      {
        id = "StripedOrangeCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_STRIPEDORANGECATS"] or "Striped Orange",
        diet = "Meat, Fish",
        species = {
          { name = "Durotar Tiger", level = {7,8}, zone = "Durotar", learns = { {spell="Cower", rank=1} }, attackSpeed = 1.3, canBeTamed = true, displayId = 598 },
          { name = "Young Stranglethorn Tiger", level = {30,31}, zone = "Stranglethorn Vale", learns = { {spell="Cower", rank=3} }, attackSpeed = 1.3, canBeTamed = true, displayId = 598 },
          { name = "Kurzen War Tiger", level = {32,33}, zone = "Stranglethorn Vale", learns = { {spell="Dash", rank=1} }, attackSpeed = 1.3, canBeTamed = true, displayId = 598 },
          { name = "Stranglethorn Tiger", level = {32,33}, zone = "Stranglethorn Vale", learns = { {spell="Dash", rank=1} }, attackSpeed = 1.3, canBeTamed = true, displayId = 598 },
          { name = "Elder Stranglethorn Tiger", level = {34,35}, zone = "Stranglethorn Vale", attackSpeed = 1.3, canBeTamed = true, displayId = 598 },
          { name = "Sin'Dall", level = 37, zone = "Stranglethorn Vale", learns = { {spell="Dash", rank=1} }, attackSpeed = 1.3, canBeTamed = true, displayId = 598 },
          { name = "Stranglethorn Tigress", level = {37,38}, zone = "Stranglethorn Vale", attackSpeed = 1.3, canBeTamed = true, displayId = 598 },
          { name = "Zulian Cub", level = 60, zone = "Zul'Gurub (Raid)", attackSpeed = 2.0, canBeTamed = true, displayId = 598 },
          { name = "Zulian Tiger", level = 60, elite = true, zone = "Zul'Gurub (Raid)", attackSpeed = 2.0, displayId = 598 },
        }
      },
      {
        id = "SpottedWhiteCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_SPOTTEDWHITECATS"] or "Spotted White",
        diet = "Meat, Fish",
        species = {
          { name = "Juvenile Snow Leopard", level = {5,6}, zone = "Dun Morogh", learns = { {spell="Cower", rank=1} }, attackSpeed = 1.5, canBeTamed = true, displayId = 748 },
          { name = "Snow Leopard", level = {7,8}, zone = "Dun Morogh", attackSpeed = 2.0, canBeTamed = true, displayId = 748 },
        }
      },
      {
        id = "SpottedOrangeCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_SPOTTEDORANGECATS"] or "Spotted Orange",
        diet = "Meat, Fish",
        species = {
          { name = "Dishu (Rare)", level = 13, zone = "The Barrens", attackSpeed = 1.5, canBeTamed = true, displayId = 1043 },
          { name = "Crag Stalker", level = {25,26}, zone = "Thousand Needles", learns = { {spell="Cower", rank=3} }, attackSpeed = 1.6, canBeTamed = true, displayId = 1043 },
          { name = "Ridge Stalker", level = {36,37}, zone = "Badlands", learns = { {spell="Cower", rank=4}, {spell="Prowl", rank=1} }, attackSpeed = 1.3, canBeTamed = true, displayId = 1043 },
          { name = "Swamp Jaguar", level = {36,37}, zone = "Swamp of Sorrows", learns = { {spell="Dash", rank=1} }, attackSpeed = 1.2, canBeTamed = true, displayId = 1043 },
          { name = "Ridge Huntress", level = {38,39}, zone = "Badlands", learns = { {spell="Cower", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1043 },
          { name = "Ridge Stalker Patriarch", level = {40,41}, zone = "Badlands", learns = { {spell="Dash", rank=2}, {spell="Prowl", rank=2} }, attackSpeed = 1.3, canBeTamed = true, displayId = 1043 },
        }
      },
      {
        id = "StripedWhiteCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_STRIPEDWHITECATS"] or "Striped White",
        diet = "Meat, Fish",
        species = {
          { name = "Frostsaber", level = {56,57}, zone = "Winterspring", attackSpeed = 1.5, canBeTamed = true, displayId = 616 },
        }
      },
      {
        id = "WinterspringSabers",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_WINTERSPRINGSABERS"] or "Winterspring Sabers",
        diet = "Meat, Fish",
        species = {
          { name = "Frostsaber Cub", level = {55,56}, zone = "Winterspring", learns = { {spell="Cower", rank=6} }, attackSpeed = 1.5, canBeTamed = true, displayId = 11445 },
          { name = "Frostsaber Huntress", level = {58,59}, zone = "Winterspring", learns = { {spell="Dash", rank=3} }, attackSpeed = 1.5, canBeTamed = true, displayId = 11445 },
          { name = "Frostsaber Stalker", level = {59,60}, zone = "Winterspring", learns = { {spell="Dash", rank=3}, {spell="Prowl", rank=3} }, attackSpeed = 1.5, canBeTamed = true, displayId = 11445 },
          { name = "Rak'Shiri (Rare)", level = 57, zone = "Winterspring", learns = { {spell="Dash", rank=3} }, attackSpeed = 1.5, canBeTamed = true, displayId = 10113 },
          { name = "Shy-Rotam (Elite)", level = 60, zone = "Winterspring", attackSpeed = 1.5, canBeTamed = true, displayId = 10113 },
          { name = "Frostsaber Pride Watcher", level = {59,60}, zone = "Winterspring", attackSpeed = 1.5, canBeTamed = true, displayId = 9954 },
        }
      },
      {
        id = "Lions",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_LIONS"] or "Lions",
        diet = "Meat, Fish",
        species = {
          { name = "Humar The Pridelord (Rare)", level = 23, zone = "The Barrens", attackSpeed = 1.3, canBeTamed = true, displayId = 4424 },
          { name = "The Rake (Rare)", level = 10, zone = "Mulgore", attackSpeed = 1.2, canBeTamed = true, displayId = 1973 },
          { name = "Savannah Highmane", level = {12,13}, zone = "The Barrens", attackSpeed = 1.5, canBeTamed = true, displayId = 1973 },
          { name = "Savannah Prowler", level = {14,15}, zone = "The Barrens", attackSpeed = 1.4, canBeTamed = true, displayId = 1973 },
          { name = "Savannah Patriarch", level = {15,16}, zone = "The Barrens", learns = { {spell="Cower", rank=2} }, attackSpeed = 1.4, canBeTamed = true, displayId = 1973 },
          { name = "Echeyakee", level = 16, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 1934 },
          { name = "Sian-Rotam (Elite)", level = 60, zone = "Winterspring", attackSpeed = 2.0, displayId = 1934 },
        }
      },
      {
        id = "LynxCats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_LYNXCATS"] or "Lynx Cats",
        diet = "Meat, Fish",
        subgroups = {
          {
            id = "BrownLynxes",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_BROWNLYNXES"] or "Brown Lynxes",
            species = {
            }
          },
          {
            id = "RedLynxes",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CATS_REDLYNXES"] or "Red Lynxes",
            species = {
            }
          },
        }
      },
    },
  },
  {
    id = "Bats",
    name = BAB.Locale and BAB.Locale["CATEGORY_BATS"] or "Bats",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
    subgroups = {
      {
        id = "BrownBats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BATS_BROWNBATS"] or "Brown Bats",
        diet = "Fruit, Fungus",
        species = {
          { name = "Duskbat", level = {1,2}, zone = "Tirisfal Glades", attackSpeed = 2.0, canBeTamed = true, displayId = 4732 },
          { name = "Mangy Duskbat", level = {3,4}, zone = "Tirisfal Glades", attackSpeed = 2.0, canBeTamed = true, displayId = 4732 },
          { name = "Greater Duskbat", level = {6,7}, zone = "Tirisfal Glades", learns = { {spell="Cower", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4732 },
          { name = "Bloodseeker Bat", level = 60, zone = "Zul'Gurub (Raid)", attackSpeed = 1.0, canBeTamed = true, displayId = 4732 },
          { name = "Frenzied Bloodseeker Bat", level = 60, zone = "Zul'Gurub (Raid)", attackSpeed = 1.0, canBeTamed = true, displayId = 4732 },
        }
      },
      {
        id = "WhiteBats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BATS_WHITEBATS"] or "White Bats",
        diet = "Fruit, Fungus",
        species = {
          { name = "Ressan the Needler (Rare)", level = 11, zone = "Tirisfal Glades", attackSpeed = 2.0, canBeTamed = true, displayId = 9750 },
          { name = "Blind Hunter (Rare, Elite)", level = 32, elite = true, zone = "Razorfen Kraul (Dungeon)", learns = { {spell="Cower", rank=3}, {spell="Dive", rank=1} }, attackSpeed = 2.0, displayId = 9750 },
        },
      },
      {
        id = "PurpleRedBats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BATS_PURPLEREDBATS"] or "Purple/Red Bats",
        diet = "Fruit, Fungus",
        species = {
          { name = "Vampiric Duskbat", level = {8,9}, zone = "Tirisfal Glades", attackSpeed = 2.0, canBeTamed = true, displayId = 7897 },
          { name = "Vile Bat", level = {22,23}, elite = true, zone = "Shadowfang Keep (Dungeon)", attackSpeed = 2.0, canBeTamed = true, displayId = 7897 },
          { name = "Plaguebat", level = {53,55}, zone = "Eastern Plaguelands", learns = { {spell="Cower", rank=5}, {spell="Dive", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 7897 },
          { name = "Monstrous Plaguebat", level = {56,58}, zone = "Eastern Plaguelands", learns = { {spell="Cower", rank=6}, {spell="Screech", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 7897 },
        }
      },
      {
        id = "TanBats",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BATS_TANBATS"] or "Tan Bats",
        diet = "Fruit, Fungus",
        species = {
          { name = "Blood Seeker", level = {23,24}, elite = true, zone = "Shadowfang Keep (Dungeon)", attackSpeed = 2.0, canBeTamed = true, displayId = 1955 },
          { name = "Kraul Bat", level = {30,31}, elite = true, zone = "Razorfen Kraul (Dungeon)", learns = { {spell="Cower", rank=3}, {spell="Dive", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1955 },
          { name = "Greater Kraul Bat", level = 32, elite = true, zone = "Razorfen Kraul (Dungeon)", learns = { {spell="Cower", rank=3}, {spell="Dive", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1955 },
          { name = "Shrike Bat", level = {38,39}, elite = true, zone = "Uldaman (Dungeon)", learns = { {spell="Cower", rank=4}, {spell="Dive", rank=1}, {spell="Screech", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1955 },
          { name = "Dark Screecher", level = {50,52}, zone = "Blackrock Depths (Dungeon)", learns = { {spell="Cower", rank=5}, {spell="Dive", rank=3}, {spell="Screech", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1955 },
          { name = "Noxious Plaguebat", level = {54,56}, zone = "Eastern Plaguelands", learns = { {spell="Cower", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1955 },
        }
      },
    },
  },
  {
    id = "Boars",
    name = BAB.Locale and BAB.Locale["CATEGORY_BOARS"] or "Boars",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Boar",
    subgroups = {
      {
        id = "ArmouredBlack",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_ARMOUREDBLACK"] or "Armoured Black",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Rotting Agam'ar", level = 28, elite = true, zone = "Razorfen Kraul (Dungeon)", canBeTamed = true, learns = { {spell="Charge", rank=3} }, attackSpeed = 2.0, displayId = 4714 },
        },
      },
      {
        id = "ArmouredBrown",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_ARMOUREDBROWN"] or "Armoured Brown",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Agam'ar", level = {24,25}, elite = true, zone = "Razorfen Kraul (Dungeon)", canBeTamed = true, learns = { {spell="Charge", rank=3} }, attackSpeed = 2.0, displayId = 4713 },
        },
      },
      {
        id = "ArmouredPale",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_ARMOUREDPALE"] or "Armoured Pale",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Raging Agam'ar", level = {25,26}, elite = true, zone = "Razorfen Kraul (Dungeon)", canBeTamed = true, learns = { {spell="Charge", rank=3} }, attackSpeed = 2.0, displayId = 2453 },
        },
      },
      {
        id = "Brown",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_BROWN"] or "Brown",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Brown Boar", level = 7, zone = "Elwynn Forest", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, notes = { en = "Porcine Entourage. Accompanies Princess.", de = "Schweinisches Gefolge. Begleitet die Prinzessin." }, displayId = 1208 },
        },
      },
      {
        id = "Diseased",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_DISEASED"] or "Diseased",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Diseased Boar", level = 60, zone = "Eastern Plaguelands", canBeTamed = true, learns = { {spell="Charge", rank=6} }, attackSpeed = 2.0, displayId = 6121, notes = { en = "Plagued Swine", de = "Verseuchtes Schwein" } },
        },
      },
      {
        id = "Red",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_RED"] or "Red",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Mangy Mountain Boar", level = {14,15}, zone = "Loch Modan", canBeTamed = true, learns = { {spell="Charge", rank=2} }, attackSpeed = 2.0, displayId = 3035 },
        },
      },
      {
        id = "Pale",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_PALE"] or "Pale",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Mottled Boar", level = {1,2}, zone = "Durotar", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 193 },
          { name = "Stonetusk Boar", level = {7,8}, zone = "Elwynn Forest", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 193 },
          { name = "Scarred Crag Boar", level = {9,10}, zone = "Dun Morogh", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 193 },
        },
      },
      {
        id = "Black",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_BLACK"] or "Black",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Small Crag Boar", level = 3, zone = "Dun Morogh", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 381 },
          { name = "Crag Boar", level = {5,6}, zone = "Dun Morogh", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 381 },
          { name = "Elder Crag Boar", level = {7,8}, zone = "Dun Morogh", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 381 },
          { name = "Longsnout", level = {10,11}, zone = "Elwynn Forest", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 381 },
          { name = "Grunter (Rare)", level = 50, zone = "Blasted Lands", learns = { {spell="Charge", rank=5}, {spell="Dash", rank=3} }, attackSpeed = 2.0, displayId = 381 },
        },
      },
      {
        id = "Yellow",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_YELLOW"] or "Yellow",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
          { name = "Young Thistle Boar", level = {1,2}, zone = "Teldrassil", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 8869 },
          { name = "Princess", level = 9, zone = "Elwynn Forest", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 8869 },
          { name = "Porcine Entourage", level = 7, zone = "Elwynn Forest", canBeTamed = true, learns = { {spell="Charge", rank=1} }, attackSpeed = 2.0, displayId = 8869 },
          { name = "Young Goretusk", level = {12,13}, zone = "Westfall", canBeTamed = true, learns = { {spell="Charge", rank=2} }, attackSpeed = 2.0, displayId = 8869 },
        },
      },
      {
        id = "PlaguedBoars",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BOARS_PLAGUEDBOARS"] or "Plagued Boars",
        diet = "Bread, Cheese, Fish, Fruit,\nFungus, Meat",
        species = {
        },
      },
    },
  },
  {
    id = "Spiders",
    name = BAB.Locale and BAB.Locale["CATEGORY_SPIDERS"] or "Spiders",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Spider",
    subgroups = {
      {
        id = "Tarantulas",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_TARANTULAS"] or "Tarantulas",
        diet = "Meat",
        subgroups = {
          {
            id = "GreenTarantulas",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_TARANTULAS_GREENTARANTULAS"] or "Green Tarantulas",
            diet = "Meat",
            species = {
              { name = "Webwood Spider", level = {3,4}, zone = "Teldrassil", attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Githyiss the Vile", level = 5, zone = "Teldrassil", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Webwood Lurker", level = {5,6}, zone = "Teldrassil", attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Webwood Venomfang", level = {7,8}, zone = "Teldrassil", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Webwood Silkspinner", level = {8,9}, zone = "Teldrassil", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Giant Webwood Spider", level = {10,11}, zone = "Teldrassil", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Mist Creeper", level = {13,14}, zone = "Silverpine Forest", attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Deepmoss Creeper", level = {16,17}, zone = "Stonetalon Mountains", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, notes = { en = "Deepmoss spiders have a slightly narrower range of damage than most other spiders.", de = "Tiefmoosispinnen haben einen etwas engeren Schadensbereich als die meisten anderen Spinnen." }, displayId = 760 },
              { name = "Deepmoss Venomspitter", level = {17,18}, zone = "Stonetalon Mountains", attackSpeed = 2.0, canBeTamed = true, notes = { en = "Deepmoss spiders have a slightly narrower range of damage than most other spiders.", de = "Tiefmoosispinnen haben einen etwas engeren Schadensbereich als die meisten anderen Spinnen." }, displayId = 760 },
              { name = "Deepmoss Webspinner", level = {19,20}, zone = "Stonetalon Mountains", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, notes = { en = "Deepmoss spiders have a slightly narrower range of damage than most other spiders.", de = "Tiefmoosispinnen haben einen etwas engeren Schadensbereich als die meisten anderen Spinnen." }, displayId = 760 },
              { name = "Forest Moss Creeper", level = {20,21}, zone = "Hillsbrad Foothills", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Deepmoss Matriarch", level = 22, zone = "Stonetalon Mountains", attackSpeed = 2.0, canBeTamed = true, notes = { en = "Deepmoss spiders have a slightly narrower range of damage than most other spiders.", de = "Tiefmoosispinnen haben einen etwas engeren Schadensbereich als die meisten anderen Spinnen." }, displayId = 760 },
              { name = "Giant Moss Creeper", level = {24,25}, zone = "Hillsbrad Foothills", learns = { {spell="Bite", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Wildthorn Venomspitter", level = {24,25}, zone = "Ashenvale", attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
              { name = "Deathstrike Tarantula", level = {40,41}, zone = "Swamp of Sorrows", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 760 },
            }
          },
          {
            id = "RedTarantula",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_TARANTULAS_REDTARANTULA"] or "Red Tarantula",
            diet = "Meat",
            species = {
              { name = "Forest Lurker", level = {10,11}, zone = "Loch Modan", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Moss Stalker", level = {12,13}, zone = "Silverpine Forest", attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Cliff Lurker", level = {13,14}, zone = "Loch Modan", attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Wood Lurker", level = {17,18}, zone = "Loch Modan", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Greater Tarantula", level = {19,20}, zone = "Redridge Mountains", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Chatter", level = 23, rare = true, zone = "Redridge Mountains", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Elder Moss Creeper", level = {26,27}, zone = "Hillsbrad Foothills", learns = { {spell="Bite", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Timberweb Recluse", level = {47,48}, zone = "Azshara", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Cave Creeper", level = {50,52}, zone = "Blackrock Depths (Dungeon)", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
              { name = "Sand Skitterer", level = {55,56}, zone = "Silithus", attackSpeed = 2.0, canBeTamed = true, displayId = 8014 },
            }
          },
          {
            id = "GreyTarantulas",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_TARANTULAS_GREYTARANTULAS"] or "Grey Tarantulas",
            diet = "Meat",
            species = {
              { name = "Lady Sathrah", level = 12, zone = "Teldrassil", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Shanda the Spinner", level = 19, rare = true, zone = "Loch Modan", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Wildthorn Stalker", level = {20,21}, zone = "Ashenvale", attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Creepthess", level = 24, rare = true, zone = "Hillsbrad Foothills", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Wildthorn Lurker", level = {28,29}, zone = "Ashenvale", learns = { {spell="Bite", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Plains Creeper", level = {32,33}, zone = "Arathi Highlands", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Giant Plains Creeper", level = {35,36}, zone = "Arathi Highlands", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Carrion Lurker", level = {52,53}, zone = "Western Plaguelands", attackSpeed = 2.0, canBeTamed = true, displayId = 6214 },
              { name = "Gretheer", level = 57, rare = true, zone = "Silithus", attackSpeed = 2.0, canBeTamed = true, displayId = 6214, notes = { en = "May be found at one of four different locations in a band across the centre of the zone.", de = "Kann an einem von vier verschiedenen Orten in einem Streifen Ã¼ber die Mitte der Zone hinweg gefunden werden." } },
            }
          },
          {
            id = "OrangeTarantulas",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_TARANTULAS_ORANGETARANTULAS"] or "Orange Tarantulas",
            diet = "Meat",
            species = {
              { name = "Forest Spider", level = {5,6}, zone = "Elwynn Forest", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
              { name = "Tarantula", level = {15,16}, zone = "Redridge Mountains", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
              { name = "Besseleth", level = 21, zone = "Stonetalon Mountains", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, notes = { en = "Elite", de = "Elitebestie" }, displayId = 382 },
              { name = "Darkfang Spider", level = {35,36}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
              { name = "Darkfang Lurker", level = {36,37}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
              { name = "Sorrow Spinner", level = {36,37}, zone = "Swamp of Sorrows", attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
              { name = "Darkfang Venomspitter", level = {37,38}, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
              { name = "Darkfang Creeper", level = {38,39}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
              { name = "Giant Darkfang Spider", level = {40,41}, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 382 },
            }
          },
          {
            id = "LavaTarantulas",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_TARANTULAS_LAVATARANTULAS"] or "Lava Tarantulas",
            diet = "Meat",
            species = {
              { name = "Searing Lava Spider", level = {45,47}, zone = "Searing Gorge", attackSpeed = 2.0, canBeTamed = true, displayId = 4457 },
              { name = "Greater Lava Spider", level = {47,49}, zone = "Searing Gorge", attackSpeed = 2.0, canBeTamed = true, displayId = 4457 },
              { name = "Rekk'tilac", level = 48, rare = true, zone = "Searing Gorge", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 4457 },
            }
          },
        }
      },
      {
        id = "Spiders",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS"] or "Spiders",
        diet = "Meat",
        subgroups = {
          {
            id = "GreenSpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_GREENSPIDERS"] or "Green Spiders",
            diet = "Meat",
            species = {
              { name = "Mother Fang", level = 10, rare = true, zone = "Elwynn Forest", attackSpeed = 2.0, canBeTamed = true, displayId = 2541 },
              { name = "Deepmoss Hatchling", level = 14, zone = "Stonetalon Mountains", attackSpeed = 2.0, canBeTamed = true, notes = { en = "Deepmoss spiders have a slightly narrower range of damage than most other spiders.", de = "Tiefmoosispinnen haben einen etwas engeren Schadensbereich als die meisten anderen Spinnen." }, displayId = 2541 },
              { name = "Green Recluse", level = {21,22}, zone = "Duskwood", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 2541 },
              { name = "Carrion Recluse", level = {25,26}, zone = "Duskwood", attackSpeed = 2.0, canBeTamed = true, displayId = 2541 },
              { name = "Darkmist Spider", level = {35,36}, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 2541 },
              { name = "Darkmist Silkspinner", level = {38,39}, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 2541 },
            }
          },
          {
            id = "CrystalSpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_CRYSTALSPIDERS"] or "Crystal Spiders",
            diet = "Meat",
            species = {
              { name = "Crystal Spider", level = {43,45}, zone = "Searing Gorge", attackSpeed = 2.0, canBeTamed = true, displayId = 4456 },
              { name = "Glassweb Spider", level = {43,45}, zone = "Searing Gorge", attackSpeed = 2.0, canBeTamed = true, displayId = 4456 },
            }
          },
          {
            id = "GreySpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_GREYSPIDERS"] or "Grey Spiders",
            diet = "Meat",
            species = {
              { name = "Pygmy Venom Web Spider", level = {18,19}, zone = "Duskwood", attackSpeed = 2.0, canBeTamed = true, displayId = 958 },
              { name = "Venom Web Spider", level = {19,20}, zone = "Duskwood", attackSpeed = 2.0, canBeTamed = true, displayId = 958 },
              { name = "Cave Stalker", level = {21,22}, zone = "Wetlands", attackSpeed = 2.0, canBeTamed = true, displayId = 958 },
              { name = "Leech Widow", level = 24, rare = true, zone = "Wetlands", learns = { {spell="Bite", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 958 },
              { name = "Witherbark Broodguard", level = {44,45}, zone = "The Hinterlands", attackSpeed = 2.0, canBeTamed = true, displayId = 958 },
              { name = "Venom Mist Lurker", level = {50,51}, zone = "Western Plaguelands", attackSpeed = 2.0, canBeTamed = true, displayId = 958 },
              { name = "Razzashi Venombrood", level = 60, elite = true, zone = "Zul'Gurub (Raid)", attackSpeed = 2.0, canBeTamed = true, displayId = 958 },
            }
          },
          {
            id = "JungleSpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_JUNGLESPIDERS"] or "Jungle Spiders",
            diet = "Meat",
            species = {
              { name = "Darkmist Recluse", level = {36,37}, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 2539 },
              { name = "Darkmist Lurker", level = {37,38}, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 2539 },
              { name = "Darkmist Widow", level = 40, rare = true, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 2539 },
            }
          },
          {
            id = "BlackWidowSpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_BLACKWIDOWSPIDERS"] or "Black Widow Spiders",
            diet = "Meat",
            species = {
              { name = "Night Web Spider", level = {3,4}, zone = "Tirisfal Glades", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
              { name = "Night Web Matriarch", level = 5, zone = "Tirisfal Glades", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
              { name = "Mine Spider", level = {8,9}, zone = "Elwynn Forest", attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
              { name = "Vicious Night Web Spider", level = {9,10}, zone = "Tirisfal Glades", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
              { name = "Sri'skulk", level = 13, rare = true, zone = "Tirisfal Glades", attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
              { name = "Krethis Shadowspinner", level = 15, rare = true, zone = "Silverpine Forest", attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
              { name = "Black Widow Hatchling", level = {24,25}, zone = "Duskwood", attackSpeed = 2.0, canBeTamed = true, displayId = 368 },
            }
          },
          {
            id = "OliveSpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_OLIVESPIDERS"] or "Olive Spiders",
            diet = "Meat",
            species = {
              { name = "Young Night Web Spider", level = {2,3}, zone = "Tirisfal Glades", attackSpeed = 2.0, canBeTamed = true, displayId = 1088 },
              { name = "Plague Lurker", level = {54,55}, zone = "Western Plaguelands", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1088 },
            }
          },
          {
            id = "TanSpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_TANSPIDERS"] or "Tan Spiders",
            diet = "Meat",
            species = {
              { name = "Leech Stalker", level = {21,22}, zone = "Wetlands", attackSpeed = 2.0, canBeTamed = true, displayId = 711 },
              { name = "Rock Stalker", level = {57,58}, zone = "Silithus", attackSpeed = 2.0, canBeTamed = true, displayId = 711 },
              { name = "Spawn of Mar'li", level = 60, elite = true, zone = "Zul'Gurub (Raid)", attackSpeed = 1.4, canBeTamed = true, displayId = 711 },
            }
          },
          {
            id = "RedSpiders",
            name = BAB.Locale and BAB.Locale["SUBGROUP_SPIDERS_SPIDERS_REDSPIDERS"] or "Red Spiders",
            diet = "Meat",
            species = {
              { name = "Naraxis", level = 27, rare = true, zone = "Duskwood", learns = { {spell="Bite", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 963 },
            }
          },
        }
      },
      {
        id = "BarbedSpiders",
        name = "Barbed Spiders",
        diet = "Meat",
        subgroups = {
          {
            id = "OrangeBlackBarbedSpiders",
            name = "Orange & Black Barbed Spider",
            diet = "Meat",
            species = {
            }
          },
          {
            id = "RedBlackBarbedSpiders",
            name = "Red & Black Barbed Spider",
            diet = "Meat",
            species = {
            }
          },
          {
            id = "RedYellowBarbedSpiders",
            name = "Red & Yellow Barbed Spider",
            diet = "Meat",
            species = {
            }
          },
        }
      },
    },
  },
  {
    id = "Wolves",
    name = BAB.Locale and BAB.Locale["CATEGORY_WOLVES"] or "Wolves",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
    subgroups = {
      {
        id = "Wolves",
        name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WOLVES"] or "Wolves",
        diet = "Meat",
        subgroups = {
          {
            id = "BlackWolves",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WOLVES_BLACKWOLVES"] or "Black Wolves",
            diet = "Meat",
            species = {
              { name = "Snarler", rare = true, level = 42, zone = "Feralas", learns = { {spell="Bite", rank=6}, {spell="Furious Howl", rank=3} }, attackSpeed = 2.0, displayId = 782, notes = { en = "Snarler was once famous for having high resistances after he was tamed. Alas, this is no longer true.", de = "Snarler war einmal berÃ¼hmt dafÃ¼r, nach dem ZÃ¤hmen hohe WiderstÃ¤nde zu haben. Leider ist das nicht mehr der Fall." } },
              { name = "Vilebranch Wolf Pup", level = {46,47}, zone = "The Hinterlands", attackSpeed = 2.0, displayId = 782 },
              { name = "Vilebranch Raiding Wolf", elite = true, level = {50,51}, zone = "The Hinterlands", learns = { {spell="Bite", rank=7}, {spell="Dash", rank=3} }, attackSpeed = 1.7, displayId = 782 },
            }
          },
          {
            id = "DiseasedBlackWolves",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WOLVES_DISEASEDBLACKWOLVES"] or "Diseased Black Wolves",
            diet = "Meat",
            species = {
              { name = "Felpaw Wolf", level = {47,48}, zone = "Felwood", learns = { {spell="Bite", rank=6}, {spell="Furious Howl", rank=3} }, attackSpeed = 2.0, displayId = 4124 },
              { name = "Felpaw Scavenger", level = {49,50}, zone = "Felwood", attackSpeed = 2.0, displayId = 4124 },
              { name = "Felpaw Ravager", level = {51,52}, zone = "Felwood", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, displayId = 4124 },
              { name = "Diseased Wolf", level = {53,54}, zone = "Western Plaguelands", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, displayId = 4124 },
            }
          },
          {
            id = "GreyWolves",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WOLVES_GREYWOLVES"] or "Grey Wolves",
            diet = "Meat",
            species = {
              { name = "Young Scavenger", level = 1, zone = "Tirisfal Glades", attackSpeed = 2.0, displayId = 165 },
              { name = "Young Wolf", level = 1, zone = "Elwynn Forest", attackSpeed = 2.0, displayId = 165 },
              { name = "Timber Wolf", level = 2, zone = "Elwynn Forest", attackSpeed = 2.0, displayId = 165 },
              { name = "Ragged Scavenger", level = {2,3}, zone = "Tirisfal Glades", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, displayId = 165 },
              { name = "Mangy Wolf", level = {5,6}, zone = "Elwynn Forest", attackSpeed = 1.7, displayId = 165 },
              { name = "Snow Tracker Wolf", level = {6,7}, zone = "Dun Morogh", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, displayId = 165 },
              { name = "Gray Forest Wolf", level = {7,8}, zone = "Elwynn Forest", learns = { {spell="Bite", rank=1} }, attackSpeed = 1.7, displayId = 165 },
              { name = "Mist Howler", rare = true, level = 22, zone = "Ashenvale", learns = { {spell="Furious Howl", rank=1} }, attackSpeed = 1.3, displayId = 165 },
              { name = "Longtooth Runner", level = {40,41}, zone = "Feralas", learns = { {spell="Bite", rank=6}, {spell="Dash", rank=2}, {spell="Furious Howl", rank=3} }, attackSpeed = 2.0, displayId = 165 },
              { name = "Longtooth Howler", level = {43,44}, zone = "Feralas", learns = { {spell="Furious Howl", rank=3} }, attackSpeed = 2.0, displayId = 165 },
              { name = "Rabid Longtooth", level = {47,48}, zone = "Feralas", attackSpeed = 2.0, displayId = 165 },
            }
          },
          {
            id = "SilverGreyWolves",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WOLVES_SILVERGREYWOLVES"] or "Silver-Grey Wolves",
            diet = "Meat",
            species = {
              { name = "Ragged Young Wolf", level = 1, zone = "Dun Morogh", attackSpeed = 2.0, displayId = 802 },
              { name = "Ragged Timber Wolf", level = 2, zone = "Dun Morogh", attackSpeed = 2.0, displayId = 802 },
              { name = "Winter Wolf", level = {7,8}, zone = "Dun Morogh", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, displayId = 802 },
              { name = "Starving Winter Wolf", level = {8,9}, zone = "Dun Morogh", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, displayId = 802 },
              { name = "Bleak Worg", elite = true, level = {18,19}, zone = "Shadowfang Keep (Dungeon)", attackSpeed = 2.0, displayId = 802 },
              { name = "Ghostpaw Runner", level = {19,20}, zone = "Ashenvale", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, displayId = 802 },
              { name = "Starving Dire Wolf", level = {19,20}, zone = "Duskwood", attackSpeed = 2.0, displayId = 802 },
              { name = "Rabid Dire Wolf", level = {20,21}, zone = "Duskwood", attackSpeed = 2.0, displayId = 802 },
              { name = "Ghostpaw Howler", level = {23,24}, zone = "Ashenvale", attackSpeed = 2.0, displayId = 802 },
              { name = "Ghostpaw Alpha", level = {27,28}, zone = "Ashenvale", learns = { {spell="Bite", rank=4}, {spell="Furious Howl", rank=2} }, attackSpeed = 1.3, displayId = 802 },
            }
          },
          {
            id = "TanWolves",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WOLVES_TANWOLVES"] or "Tan Wolves",
            species = {
              { name = "Prairie Wolf", level = {5,6}, zone = "Mulgore", learns = { {spell="Bite", rank=1} }, attackSpeed = 1.5, displayId = 161 },
              { name = "Prairie Stalker", level = {7,8}, zone = "Mulgore", learns = { {spell="Bite", rank=1} }, attackSpeed = 1.5, displayId = 161 },
              { name = "Prairie Wolf Alpha", level = {9,10}, zone = "Mulgore", learns = { {spell="Bite", rank=2}, {spell="Furious Howl", rank=1} }, attackSpeed = 1.4, displayId = 161 },
              { name = "Coyote", level = {10,11}, zone = "Westfall", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, displayId = 161 },
              { name = "Coyote Packleader", level = {11,12}, zone = "Westfall", learns = { {spell="Bite", rank=2}, {spell="Furious Howl", rank=1} }, attackSpeed = 2.0, displayId = 161 },
              { name = "Spot", level = 35, zone = "Dustwallow Marsh", learns = { {spell="Dash", rank=1} }, attackSpeed = 2.0, displayId = 161, notes = { en = "This dog is friendly to the Alliance, and therefore can only be tamed by the Horde.", de = "Dieser Hund ist der Allianz freundlich gesinnt und kann daher nur von der Horde gezÃ¤hmt werden." } },
              { name = "Crag Coyote", level = {35,36}, zone = "Badlands", learns = { {spell="Bite", rank=5}, {spell="Dash", rank=1} }, attackSpeed = 2.0, displayId = 161 },
              { name = "Feral Crag Coyote", level = {37,38}, zone = "Badlands", learns = { {spell="Dash", rank=1} }, attackSpeed = 2.0, displayId = 161 },
              { name = "Elder Crag Coyote", level = {39,40}, zone = "Badlands", learns = { {spell="Dash", rank=1}, {spell="Furious Howl", rank=2} }, attackSpeed = 2.0, displayId = 161 },
              { name = "Rabid Crag Coyote", level = {42,43}, zone = "Badlands", learns = { {spell="Dash", rank=2} }, attackSpeed = 2.0, displayId = 161 },
            }
          }
        }
      },
      {
        id = "Worgs",
        name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WORGS"] or "Worgs",
        diet = "Meat",
        subgroups = {
          {
            id = "BlackWorgs",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WORGS_BLACKWORGS"] or "Black Worgs",
            species = {
              { name = "Worg", level = {10,11}, zone = "Silverpine Forest", learns = { {spell="Bite", rank=2}, {spell="Furious Howl", rank=1} }, attackSpeed = 2.0, displayId = 11421 },
              { name = "Mottled Worg", level = {11,12}, zone = "Silverpine Forest", attackSpeed = 2.0, displayId = 11421 },
              { name = "Bloodsnout Worg", level = {16,17}, zone = "Silverpine Forest", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, displayId = 11421 },
              { name = "Slavering Worg", elite = true, level = {18,19}, zone = "Shadowfang Keep (Dungeon)", attackSpeed = 1.2, displayId = 11421 },
              { name = "Young Black Ravager", level = {23,24}, zone = "Duskwood", attackSpeed = 2.0, displayId = 11421 },
              { name = "Enraged Stanley", level = 24, zone = "Hillsbrad Foothills", attackSpeed = 1.3, displayId = 11421, notes = { en = "Stanley transforms into Enraged Stanley during the Horde Elixir of Pain quest.", de = "Stanley verwandelt sich wÃ¤hrend der Hordenquest Elixier des Schmerzes in Zornigen Stanley." } },
              { name = "Black Ravager", level = {24,25}, zone = "Duskwood", learns = { {spell="Bite", rank=4} }, attackSpeed = 2.0, displayId = 11421 },
              { name = "Black Ravager Mastiff", level = {25,26}, zone = "Duskwood", learns = { {spell="Bite", rank=4}, {spell="Furious Howl", rank=2} }, attackSpeed = 2.0, displayId = 11421 },
              { name = "Bloodaxe Worg Pup", level = {52,53}, zone = "Blackrock Spire (Dungeon)", attackSpeed = 2.0, displayId = 11421 },
              { name = "Deathmaw", rare = true, level = 53, zone = "Burning Steppes", attackSpeed = 1.2, displayId = 11421 },
              { name = "Blackrock Worg", level = {54,55}, zone = "Burning Steppes", learns = { {spell="Dash", rank=3} }, attackSpeed = 2.0, displayId = 11421 },
              { name = "Bloodaxe Worg", level = {56,57}, zone = "Blackrock Spire (Dungeon)", learns = { {spell="Bite", rank=8}, {spell="Dash", rank=3}, {spell="Furious Howl", rank=4} }, attackSpeed = 1.5, displayId = 11421 },
            }
          },
          {
            id = "DarkGreyWorgs",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WORGS_DARKGREYWORGS"] or "Dark Grey Worgs",
            species = {
              { name = "Old Cliff Jumper", rare = true, level = 42, zone = "The Hinterlands", learns = { {spell="Bite", rank=6}, {spell="Dash", rank=2} }, attackSpeed = 2.0, displayId = 11414 },
            }
          },
          {
            id = "LightGreyWorgs",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WORGS_LIGHTGREYWORGS"] or "Light Grey Worgs",
            species = {
              { name = "Prowler", level = {9,10}, zone = "Elwynn Forest", learns = { {spell="Bite", rank=2} }, attackSpeed = 1.5, displayId = 11413 },
              { name = "Gorefang", rare = true, level = 13, zone = "Silverpine Forest", attackSpeed = 2.0, displayId = 11413 },
              { name = "Mangy Silvermane", level = {41,42}, zone = "The Hinterlands", attackSpeed = 2.0, displayId = 11413 },
              { name = "Silvermane Wolf", level = {43,44}, zone = "The Hinterlands", learns = { {spell="Furious Howl", rank=3} }, attackSpeed = 2.0, displayId = 11413 },
              { name = "Silvermane Howler", level = {45,46}, zone = "The Hinterlands", learns = { {spell="Furious Howl", rank=2} }, attackSpeed = 2.0, displayId = 11413 },
              { name = "Silvermane Stalker", level = {47,48}, zone = "The Hinterlands", learns = { {spell="Dash", rank=2} }, attackSpeed = 2.0, displayId = 11413 },
            }
          },
          {
            id = "BrownGreyWorgs",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WORGS_BROWNGREYWORGS"] or "Brown & Grey Worgs",
            species = {
            }
          },
          {
            id = "RedWorgs",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WORGS_REDWORGS"] or "Red Worgs",
            species = {
              { name = "Barnabus", rare = true, level = 38, zone = "Badlands", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, displayId = 11420 },
              { name = "Ember Worg", level = {51,52}, zone = "Burning Steppes", attackSpeed = 2.0, displayId = 11420 },
              { name = "Scarshield Worg", level = {53,54}, zone = "Blackrock Spire (Dungeon)", learns = { {spell="Dash", rank=3} }, attackSpeed = 1.5, displayId = 11420 },
              { name = "Slavering Ember Worg", level = {53,54}, zone = "Burning Steppes", attackSpeed = 2.0, displayId = 11420 },
              { name = "Giant Ember Worg", level = {55,56}, zone = "Burning Steppes", attackSpeed = 2.0, displayId = 11420 },
            }
          },
          {
            id = "SilverGreyWorgs",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WOLVES_WORGS_SILVERGREYWORGS"] or "Silver-Grey Worgs",
            species = {
              { name = "Timber", rare = true, level = 10, zone = "Dun Morogh", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, displayId = 11412 },
              { name = "Lupos", rare = true, level = 23, zone = "Duskwood", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, displayId = 11412, notes = { en = "Lupos was once everyone's favorite wolf because he inflicted shadow damage instead of physical damage with his attacks. Alas, this is no longer the case.", de = "Lupos war einmal jedermanns Lieblingswolf, weil er mit seinen Angriffen Schattenschaden statt physischen Schaden verursachte. Leider ist das nicht mehr der Fall." } },
              { name = "Death Howl", rare = true, level = 49, zone = "Felwood", learns = { {spell="Bite", rank=6}, {spell="Furious Howl", rank=3} }, attackSpeed = 2.0, displayId = 11412 },
              { name = "Frostwolf", level = {50,51}, zone = "Alterac Valley (Battleground)", attackSpeed = 2.0, displayId = 11412 },
            }
          },
        }
      }
    }
  },
  {
    id = "Raptors",
    name = BAB.Locale and BAB.Locale["CATEGORY_RAPTORS"] or "Raptors",
    icon = "Interface\\Icons\\Ability_Mount_Raptor",
    subgroups = {
      {
        id = "NormalRaptors",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_NORMALRAPTORS"] or "Normal Raptors",
        diet = "Meat",
        subgroups = {
          {
            id = "BlueRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_BLUERAPTORS"] or "Blue Raptors",
            diet = "Meat",
            species = {
              { name = "Deviate Slayer", elite = true, level = {16,17}, zone = "Wailing Caverns (Dungeon)", attackSpeed = 2.0, displayId = 949 },
              { name = "Deviate Guardian", elite = true, level = {18,19}, zone = "Wailing Caverns (Dungeon)", attackSpeed = 2.0, displayId = 949 },
              { name = "Mottled Screecher", level = {24,25}, zone = "Wetlands", attackSpeed = 2.0, displayId = 949 },
              { name = "Mottled Razormaw", level = {26,27}, zone = "Wetlands", attackSpeed = 2.0, displayId = 949 },
              { name = "Sarltooth", level = 29, zone = "Wetlands", attackSpeed = 2.0, displayId = 949 },
              { name = "Tethis", elite = true, level = 43, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 949 },
            }
          },
          {
            id = "GreenRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_GREENRAPTORS"] or "Green Raptors",
            diet = "Meat",
            species = {
              { name = "Mottled Scytheclaw", level = {25,26}, zone = "Wetlands", attackSpeed = 2.0, displayId = 648 },
              { name = "Young Jungle Stalker", level = {36,37}, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 648 },
            }
          },
          {
            id = "GreyRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_GREYRAPTORS"] or "Grey Raptors",
            diet = "Meat",
            species = {
              { name = "Deviate Stalker", elite = true, level = {15,17}, zone = "Wailing Caverns (Dungeon)", attackSpeed = 2.0, displayId = 1746 },
              { name = "Takk the Leaper", rare = true, elite = true, level = 19, zone = "The Barrens", attackSpeed = 2.0, displayId = 1746 },
            }
          },
          {
            id = "OrangeRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_ORANGERAPTORS"] or "Orange Raptors",
            diet = "Meat",
            species = {
              { name = "Highland Raptor", level = {23,24}, zone = "Wetlands", attackSpeed = 2.0, displayId = 788 },
              { name = "Highland Lashtail", level = {24,25}, zone = "Wetlands", attackSpeed = 2.0, displayId = 788 },
              { name = "Highland Scytheclaw", level = {25,26}, zone = "Wetlands", attackSpeed = 2.0, displayId = 788 },
              { name = "Highland Razormaw", level = {27,28}, zone = "Wetlands", attackSpeed = 2.0, displayId = 788 },
              { name = "Elder Razormaw", level = 29, zone = "Wetlands", attackSpeed = 2.0, displayId = 788 },
              { name = "Young Stranglethorn Raptor", level = {30,31}, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 788 },
              { name = "Highland Thrasher", level = {33,34}, zone = "Arathi Highlands", attackSpeed = 2.0, displayId = 788 },
              { name = "Stranglethorn Raptor", level = {33,34}, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 788 },
              { name = "Lashtail Raptor", level = {35,36}, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 788 },
              { name = "Dart", rare = true, level = 38, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 788 },
            }
          },
          {
            id = "PurpleRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_PURPLERAPTORS"] or "Purple Raptors",
            diet = "Meat",
            species = {
              { name = "Sunscale Lashtail", level = {11,13}, zone = "The Barrens", attackSpeed = 2.0, displayId = 1744 },
              { name = "Sunscale Screecher", level = {13,15}, zone = "The Barrens", attackSpeed = 2.0, displayId = 1744 },
              { name = "Deviate Creeper", elite = true, level = {15,16}, zone = "Wailing Caverns (Dungeon)", attackSpeed = 2.0, displayId = 1744 },
              { name = "Sunscale Scytheclaw", level = {16,18}, zone = "The Barrens", attackSpeed = 2.0, displayId = 1744 },
              { name = "Deviate Ravager", elite = true, level = {18,19}, zone = "Wailing Caverns (Dungeon)", attackSpeed = 2.0, displayId = 1744 },
              { name = "Mottled Raptor", level = {22,23}, zone = "Wetlands", attackSpeed = 2.0, displayId = 1744 },
              { name = "Jungle Stalker", level = {40,41}, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 1744 },
            }
          },
          {
            id = "RedRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_REDRAPTORS"] or "Red Raptors",
            diet = "Meat",
            species = {
              { name = "Bloodtalon Taillasher", level = {6,8}, zone = "Durotar", attackSpeed = 2.0, displayId = 2574 },
              { name = "Bloodtalon Scythemaw", level = {8,10}, zone = "Durotar", attackSpeed = 2.0, displayId = 2574 },
              { name = "Ishamuhale", level = 19, zone = "The Barrens", attackSpeed = 2.0, displayId = 2574, notes = { en = "Summoned during the Horde quest Ishamuhale.", de = "Wird wÃ¤hrend der Hordenquest Ishamuhale herbeigerufen." } },
              { name = "Young Lashtail Raptor", level = {33,34}, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 2574 },
              { name = "Bloodfen Raptor", level = {35,36}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 2574 },
              { name = "Bloodfen Screecher", level = {36,37}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 2574 },
              { name = "Bloodfen Scytheclaw", level = {37,38}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 2574 },
              { name = "Bloodfen Razormaw", level = {39,40}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 2574 },
              { name = "Bloodfen Lashtail", level = {40,41}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 2574 },
              { name = "Razzashi Raptor", elite = true, level = 60, zone = "Zul'Gurub (Raid)", attackSpeed = 2.0, displayId = 2574 },
            }
          },
          {
            id = "YellowRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_YELLOWRAPTORS"] or "Yellow Raptors",
            diet = "Meat",
            species = {
              { name = "Corrupted Bloodtalon Scythemaw", level = {10,11}, zone = "Durotar", attackSpeed = 2.0, displayId = 787 },
              { name = "Highland Strider", level = {30,31}, zone = "Arathi Highlands", attackSpeed = 2.0, displayId = 787 },
              { name = "Razormaw Matriarch", rare = true, level = 31, zone = "Wetlands", attackSpeed = 2.0, displayId = 787 },
              { name = "Highland Fleshstalker", level = {36,37}, zone = "Arathi Highlands", attackSpeed = 2.0, displayId = 787 },
            }
          },
        }
      },
      {
        id = "SpikyRaptors",
        name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_SPIKYRAPTORS"] or "Spiky Raptors",
        diet = "Meat",
        subgroups = {
          {
            id = "BlackSpikedRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_BLACKSPIKEDRAPTORS"] or "Black Spiked Raptor",
            diet = "Meat",
            species = {
            }
          },
          {
            id = "BrownSpikedRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_BROWNSPIKEDRAPTORS"] or "Brown Spiked Raptor",
            diet = "Meat",
            species = {
            }
          },
          {
            id = "GreenSpikedRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_GREENSPIKEDRAPTORS"] or "Green Spiked Raptor",
            diet = "Meat",
            species = {
            }
          },
          {
            id = "RedSpikedRaptors",
            name = BAB.Locale and BAB.Locale["SUBGROUP_RAPTORS_REDSPIKEDRAPTORS"] or "Red Spiked Raptor",
            diet = "Meat",
            species = {
            }
          },
        }
      }
    }
  },
  {
    id = "Turtles",
    name = BAB.Locale and BAB.Locale["CATEGORY_TURTLES"] or "Turtles",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Turtle",
    subgroups = {
      {
        id = "BlueTurtles",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TURTLES_BLUETURTLES"] or "Blue Turtles",
        diet = "Fish, Fruit, Fungus",
        species = {
          { name = "Oasis Snapjaw", level = {15,16}, zone = "The Barrens", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, displayId = 5126 },
          { name = "Kresh", elite = true, level = 20, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Bite", rank=3}, {spell="Shell Shield", rank=1} }, attackSpeed = 2.0, displayId = 5126 },
          { name = "Steeljaw Snapper", level = {42,43}, zone = "Tanaris", attackSpeed = 2.0, displayId = 5126 },
          { name = "Stolid Snapjaw", level = {46,47}, zone = "Maraudon (Dungeon)", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, displayId = 5126 },
          { name = "Surf Glider", level = {48,50}, zone = "Tanaris", attackSpeed = 2.0, displayId = 5126 },
        }
      },
      {
        id = "GreenTurtles",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TURTLES_GREENTURTLES"] or "Green Turtles",
        diet = "Fish, Fruit, Fungus",
        species = {
          { name = "Aku'mai Fisher", elite = true, level = {23,24}, zone = "Blackfathom Deeps (Dungeon)", learns = { {spell="Bite", rank=3}, {spell="Shell Shield", rank=1} }, attackSpeed = 2.0, displayId = 1244 },
          { name = "Snapjaw", level = {30,31}, zone = "Hillsbrad Foothills", learns = { {spell="Bite", rank=4}, {spell="Shell Shield", rank=1} }, attackSpeed = 2.0, displayId = 1244 },
        }
      },
      {
        id = "GreyTurtles",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TURTLES_GREYTURTLES"] or "Grey Turtles",
        diet = "Fish, Fruit, Fungus",
        species = {
          { name = "Mudrock Tortoise", level = {36,37}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, displayId = 4829 },
          { name = "Mudrock Spikeshell", level = {37,38}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 4829 },
          { name = "Mudrock Burrower", level = {39,40}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 4829 },
          { name = "Mudrock Snapjaw", level = {41,42}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, displayId = 4829 },
          { name = "Mudrock Borer", level = {42,43}, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 4829 },
          { name = "Ironback", rare = true, level = 51, zone = "The Hinterlands", learns = { {spell="Bite", rank=7}, {spell="Shell Shield", rank=1} }, attackSpeed = 2.0, displayId = 4829 },
        }
      },
      {
        id = "OrangeTurtles",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TURTLES_ORANGETURTLES"] or "Orange Turtles",
        diet = "Fish, Fruit, Fungus",
        species = {
          { name = "Ghamoo-ra", elite = true, level = 25, zone = "Blackfathom Deeps (Dungeon)", learns = { {spell="Bite", rank=4}, {spell="Shell Shield", rank=1} }, attackSpeed = 2.0, displayId = 5027 },
          { name = "Aku'mai Snapjaw", elite = true, level = {26,27}, zone = "Blackfathom Deeps (Dungeon)", learns = { {spell="Bite", rank=4}, {spell="Shell Shield", rank=1} }, attackSpeed = 2.0, displayId = 5027 },
          { name = "Cranky Benj", rare = true, level = 32, zone = "Alterac Mountains", learns = { {spell="Bite", rank=4}, {spell="Shell Shield", rank=1} }, attackSpeed = 2.0, displayId = 5027 },
          { name = "Saltwater Snapjaw", level = {49,50}, zone = "The Hinterlands", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, displayId = 5027 },
        }
      },
      {
        id = "WhiteTurtles",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TURTLES_WHITETURTLES"] or "White Turtles",
        diet = "Fish, Fruit, Fungus",
        species = {
          { name = "Sparkleshell Tortoise", level = {30,31}, zone = "Thousand Needles", attackSpeed = 2.0, displayId = 2307 },
          { name = "Sparkleshell Borer", level = {32,33}, zone = "Thousand Needles", attackSpeed = 2.0, displayId = 2307 },
          { name = "Sparkleshell Snapper", level = {34,35}, zone = "Thousand Needles", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, displayId = 2307 },
          { name = "Coralshell Tortoise", level = {50,52}, zone = "Azshara", attackSpeed = 2.0, displayId = 2307 },
          { name = "Coralshell Lurker", level = {53,54}, zone = "Azshara", attackSpeed = 2.0, displayId = 2307 },
        }
      }
    }
  },
  {
    id = "WindSerpents",
    name = BAB.Locale and BAB.Locale["CATEGORY_WINDSERPENTS"] or "Wind Serpents",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_WindSerpent",
    subgroups = {
      {
        id = "NormalWindSerpents",
        name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_NORMALWINDSERPENTS"] or "Wind Serpents",
        diet = "Bread, Cheese, Fish",
        subgroups = {
          {
            id = "DarkBlueWindSerpent",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_DARKBLUEWINDSERPENT"] or "Dark Blue Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
              { name = "Deviate Dreadfang", elite = true, level = {20,21}, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Lightning Breath", rank=2} }, attackSpeed = 2.0, displayId = 3006 },
            }
          },
          {
            id = "GreenWindSerpent",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_GREENWINDSERPENT"] or "Green Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
              { name = "Deviate Stinglash", elite = true, level = {16,17}, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Lightning Breath", rank=2} }, attackSpeed = 2.0, displayId = 4091 },
              { name = "Deviate Venomwing", elite = true, level = {20,21}, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Lightning Breath", rank=2} }, attackSpeed = 2.0, displayId = 4091 },
              { name = "Venomous Cloud Serpent", level = {26,28}, zone = "Thousand Needles", learns = { {spell="Lightning Breath", rank=3} }, attackSpeed = 2.0, displayId = 4091 },
            }
          },
          {
            id = "OrangeWindSerpent",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_ORANGEWINDSERPENT"] or "Orange Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
              { name = "Deviate Coiler", elite = true, level = {15,16}, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Lightning Breath", rank=2} }, attackSpeed = 2.0, displayId = 1974 },
              { name = "Thunderhawk Hatchling", level = {18,20}, zone = "The Barrens", learns = { {spell="Lightning Breath", rank=2} }, attackSpeed = 2.0, displayId = 1974 },
              { name = "Thunderhawk Cloudscraper", level = {20,22}, zone = "The Barrens", learns = { {spell="Lightning Breath", rank=2} }, attackSpeed = 2.0, displayId = 1974 },
              { name = "Greater Thunderhawk", level = {23,24}, zone = "The Barrens", learns = { {spell="Lightning Breath", rank=2} }, attackSpeed = 2.0, displayId = 1974 },
              { name = "Hakkari Sapper", elite = true, level = {49,50}, zone = "The Temple of Atal'Hakkar (Dungeon)", learns = { {spell="Lightning Breath", rank=5} }, attackSpeed = 2.0, displayId = 1974 },
            }
          },
          {
            id = "RedWindSerpent",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_REDWINDSERPENT"] or "Red Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
              { name = "Azzere the Skyblade", rare = true, level = 25, zone = "The Barrens", attackSpeed = 2.0, displayId = 2702 },
              { name = "Spawn of Hakkar", elite = true, level = 51, zone = "The Temple of Atal'Hakkar (Dungeon)", learns = { {spell="Dive", rank=3}, {spell="Lightning Breath", rank=5} }, attackSpeed = 2.0, displayId = 2702 },
              { name = "Son of Hakkar", elite = true, level = 60, zone = "Zul'Gurub (Raid)", learns = { {spell="Lightning Breath", rank=6} }, attackSpeed = 2.0, displayId = 2702 },
            }
          },
          {
            id = "RedOrangeWindSerpent",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_REDORANGEWINDSERPENT"] or "Red/Orange Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
              { name = "Washte Pawne", level = 25, zone = "The Barrens", learns = { {spell="Lightning Breath", rank=3} }, attackSpeed = 2.0, displayId = 2699 },
              { name = "Arikara", elite = true, level = 28, zone = "Thousand Needles", attackSpeed = 2.0, displayId = 2699, notes = { en = "Arikara only appears during the Horde quest Arikara, but she can be tamed by an Alliance player once she appears. Possible appearance bug: Back in original WoW, Arikara would appear in a puff of smoke and a thunder clap when she was called but a hunter, but sadly this isn't working in Classic.", de = "Arikara erscheint nur wÃ¤hrend der Hordenquest Arikara, kann aber von einem AllianzspÃ¤ler gezÃ¤hmt werden, sobald sie erscheint. MÃ¶glicher Anzeigebug: In der ursprÃ¼nglichen WoW wÃ¼rde Arikara in einer Rauchwolke und einem Donnerschlag erscheinen, wenn ein JÃ¤ger sie rief, aber leider funktioniert das in Classic nicht." } },
              { name = "Vale Screecher", level = {41,43}, zone = "Feralas", learns = { {spell="Dive", rank=2}, {spell="Lightning Breath", rank=4} }, attackSpeed = 2.0, displayId = 2699 },
              { name = "Rogue Vale Screecher", level = {44,46}, zone = "Feralas", learns = { {spell="Dive", rank=2}, {spell="Lightning Breath", rank=4} }, attackSpeed = 2.0, displayId = 2699 },
            }
          },
          {
            id = "WhiteWindSerpent",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_WHITEWINDSERPENT"] or "White Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
              { name = "Cloud Serpent", level = {25,26}, zone = "Thousand Needles", learns = { {spell="Lightning Breath", rank=3} }, attackSpeed = 2.0, displayId = 2705 },
              { name = "Elder Cloud Serpent", level = {27,29}, zone = "Thousand Needles", learns = { {spell="Lightning Breath", rank=3} }, attackSpeed = 2.0, displayId = 2705 },
              { name = "Hayoc", rare = true, level = 41, zone = "Dustwallow Marsh", attackSpeed = 2.0, displayId = 2705 },
              { name = "Arash-ethis", rare = true, level = 49, zone = "Feralas", learns = { {spell="Dive", rank=2}, {spell="Lightning Breath", rank=5} }, attackSpeed = 2.0, displayId = 2705 },
              { name = "Hakkari Frostwing", elite = true, level = {49,50}, zone = "The Temple of Atal'Hakkar (Dungeon)", learns = { {spell="Lightning Breath", rank=5} }, attackSpeed = 2.0, displayId = 2705 },
            }
          },
        }
      },
      {
        id = "SpikedWindSerpents",
        name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_SPIKEDWINDSERPENTS"] or "Spiked Wind Serpents",
        diet = "Bread, Cheese, Fish",
        subgroups = {
          {
            id = "BlueSpikedWindSerpents",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_BLUESPIKEDWINDSERPENTS"] or "Blue Spiked Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
            }
          },
          {
            id = "GreenSpikedWindSerpents",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_GREENSPIKEDWINDSERPENTS"] or "Green Spiked Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
            }
          },
          {
            id = "RedSpikedWindSerpents",
            name = BAB.Locale and BAB.Locale["SUBGROUP_WINDSERPENTS_REDSPIKEDWINDSERPENTS"] or "Red Spiked Wind Serpent",
            diet = "Bread, Cheese, Fish",
            species = {
            }
          },
        }
      }
    }
  },
  {
    id = "CarrionBirds",
    name = BAB.Locale and BAB.Locale["CATEGORY_CARRIONBIRDS"] or "Carrion Birds",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Vulture",
    subgroups = {
      {
        id = "NormalCarrionBirds",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_NORMALCARRIONBIRDS"] or "Normal Carrion Birds",
        diet = "Fish, Meat",
        subgroups = {
          {
            id = "Vultures",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_VULTURES"] or "Vultures",
            diet = "Fish, Meat",
            species = {
              { name = "Wiry Swoop", level = {5,7}, zone = "Mulgore", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Swoop", level = {7,9}, zone = "Mulgore", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Taloned Swoop", level = {8,10}, zone = "Mulgore", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Greater Fleshripper", level = {16,17}, zone = "Westfall", learns = { {spell="Screech", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Young Mesa Buzzard", level = {31,32}, zone = "Arathi Highlands", learns = { {spell="Dive", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Mesa Buzzard", level = {34,35}, zone = "Arathi Highlands", learns = { {spell="Dive", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Starving Buzzard", level = {35,37}, zone = "Badlands", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Wayward Buzzard", level = {35,37}, zone = "Badlands", learns = { {spell="Dive", rank=1} }, attackSpeed = 2.0, notes = { en = "These laid-back birds tend not to attack you while you are trying to tame them.", de = "Diese entspannten VÃ¶gel neigen nicht dazu, euch anzugreifen, wÃ¤hrend ihr versucht, sie zu zÃ¤hmen." }, canBeTamed = true, displayId = 1228 },
              { name = "Elder Mesa Buzzard", level = {37,38}, zone = "Arathi Highlands", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Buzzard", level = {37,39}, zone = "Badlands", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Giant Buzzard", level = {39,41}, zone = "Badlands", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Black Slayer", level = {46,48}, zone = "Blasted Lands", attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Carrion Vulture", level = {50,52}, zone = "Western Plaguelands", learns = { {spell="Dive", rank=3}, {spell="Screech", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1228 },
              { name = "Spiteflayer", level = 52, zone = "Blasted Lands", rare = true, learns = { {spell="Dive", rank=3} }, attackSpeed = 1.2, canBeTamed = true, displayId = 1228 },
            },
          },
          {
            id = "BlueVultures",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_BLUEVULTURES"] or "Blue Vultures",
            diet = "Fish, Meat",
            species = {
              { name = "Vultros", level = 26, rare = true, zone = "Westfall", attackSpeed = 2.0, canBeTamed = true, displayId = 1192 },
              { name = "Dread Swoop", level = {32,33}, zone = "Desolace", attackSpeed = 2.0, canBeTamed = true, displayId = 1192 },
              { name = "Dread Flyer", level = {36,37}, zone = "Desolace", learns = { {spell="Dive", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1192 },
              { name = "Dread Ripper", level = {39,40}, zone = "Desolace", learns = { {spell="Screech", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1192 },
            },
          },
          {
            id = "BrownVultures",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_BROWNVULTURES"] or "Brown Vultures",
            diet = "Fish, Meat",
            species = {
              { name = "Young Fleshripper", level = {10,11}, zone = "Westfall", attackSpeed = 2.0, canBeTamed = true, displayId = 410 },
              { name = "Fleshripper", level = {13,14}, zone = "Westfall", attackSpeed = 2.0, canBeTamed = true, displayId = 410 },
              { name = "Mountain Buzzard", level = {15,16}, zone = "Loch Modan", attackSpeed = 2.0, canBeTamed = true, displayId = 410 },
              { name = "Salt Flats Scavenger", level = {30,32}, zone = "Thousand Needles", attackSpeed = 2.0, canBeTamed = true, displayId = 410 },
              { name = "Salt Flats Vulture", level = {32,34}, zone = "Thousand Needles", learns = { {spell="Screech", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 410 },
              { name = "Carrion Horror", level = {35,37}, zone = "Desolace", attackSpeed = 2.0, canBeTamed = true, displayId = 410 },
            },
          },
          {
            id = "RedVultures",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_REDVULTURES"] or "Red Vultures",
            diet = "Fish, Meat",
            species = {
              { name = "Lord Condar", level = {15,16}, rare = true, zone = "Loch Modan", attackSpeed = 2.0, canBeTamed = true, displayId = 3248 },
              { name = "Dire Condor", level = {18,19}, zone = "Redridge Mountains", attackSpeed = 2.0, canBeTamed = true, displayId = 3248 },
              { name = "Roc", level = {42,43}, zone = "Tanaris", learns = { {spell="Dive", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3248 },
              { name = "Fire Roc", level = {43,45}, zone = "Tanaris", learns = { {spell="Dive", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3248 },
              { name = "Greater Firebird", level = 46, rare = true, zone = "Tanaris", learns = { {spell="Dive", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3248 },
              { name = "Searing Roc", level = {47,49}, zone = "Tanaris", learns = { {spell="Dive", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3248 },
              { name = "Zaricotl", level = 55, rare = true, elite = true, zone = "Badlands", learns = { {spell="Dive", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3248 },
            },
          },
        },
      },
      {
        id = "TwoHeadedCarrionBirds",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_TWOHEADEDCARRIONBIRDS"] or "Two Headed Carrion Birds",
        diet = "Fish, Meat",
        subgroups = {
          {
            id = "RedTwoHeadedVultures",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_REDTWOHEADEDVULTURES"] or "Red Two-Headed Vulture",
            diet = "Fish, Meat",
            species = {
            },
          },
          {
            id = "WhiteTwoHeadedVultures",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_WHITETWOHEADEDVULTURES"] or "White Two-Headed Vulture",
            diet = "Fish, Meat",
            species = {
            },
          },
        },
      },
      {
        id = "Stormcrows",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_STORMCROWS"] or "Stormcrows",
        diet = "Fish, Meat",
        subgroups = {
          {
            id = "BlackStormcrow",
            name = BAB.Locale and BAB.Locale["SUBGROUP_CARRIONBIRDS_BLACKSTORMCROW"] or "Black Stormcrow",
            species = {
            },
          },
        },
      },
    },
  },
  {
    id = "Bears",
    name = BAB.Locale and BAB.Locale["CATEGORY_BEARS"] or "Bears",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Bear",
    subgroups = {
      {
        id = "BlackBears",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BEARS_BLACKBEARS"] or "Black Bears",
        diet = "Bread, Cheese, Fish, Fruit, Fungus, Meat",
        species = {
          { name = "Young Black Bear", level = {5,6}, zone = "Dun Morogh", attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
          { name = "Black Bear", level = {6,7}, zone = "Dun Morogh", attackSpeed = 2.5, notes = { en = "This bear can be very hard to find! She's situated north of the hidden airfield above Ironforge and requires some skillful manoeuvring (and a long hike) to reach. She watches over her cubs northwest of the gryphon roost, by a waterfall. It's difficult to describe the route to the airport in text, but you can search for \"ironforge airport vanilla\" on the web and find handy videos like this one.", de = "Dieser BÃ¤r kann sehr schwer zu finden sein! Sie befindet sich nÃ¶rdlich des versteckten Flugplatzes Ã¼ber Eisenschmiede und erfordert geschickliches ManÃ¶vrieren (und eine lange Wanderung), um sie zu erreichen. Sie bewacht ihre Jungen nordwestlich des Greifenhorsts, an einem Wasserfall. Es ist schwierig, die Route zum Flughafen im Text zu beschreiben, aber ihr kÃ¶nnt im Web nach \"Eisenschmiede Flughafen Vanilla\" suchen und hilfreiche Videos wie dieses finden." }, canBeTamed = true, displayId = 706 },
          { name = "Elder Black Bear", level = {11,12}, zone = "Loch Modan", attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
          { name = "Grizzled Black Bear", level = {13,14}, zone = "Loch Modan", attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
          { name = "Black Bear Patriarch", level = {16,17}, zone = "Loch Modan", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
          { name = "Ol' Sooty", level = 20, elite = true, zone = "Loch Modan", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
          { name = "Big Samras", level = 27, rare = true, zone = "Hillsbrad Foothills", attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
          { name = "Ursol'lok", level = 31, rare = true, zone = "Ashenvale", attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
          { name = "Old Grizzlegut", level = 43, rare = true, zone = "Feralas", learns = { {spell="Claw", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 706 },
        },
      },
      {
        id = "BrownBears",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BEARS_BROWNBEARS"] or "Brown Bears",
        diet = "Bread, Cheese, Fish, Fruit, Fungus, Meat",
        species = {
          { name = "Young Forest Bear", level = {8,9}, zone = "Elwynn Forest", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.5, canBeTamed = true, displayId = 14316 },
          { name = "Thistle Cub", level = {9,10}, zone = "Darkshore", attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
          { name = "Ferocious Grizzled Bear", level = {11,12}, zone = "Silverpine Forest", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
          { name = "Thistle Bear", level = {11,12}, zone = "Darkshore", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
          { name = "Old Vicejaw", level = 14, rare = true, zone = "Silverpine Forest", attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
          { name = "Grizzled Thistle Bear", level = {16,17}, zone = "Darkshore", attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
          { name = "Elder Ashenvale Bear", level = {25,26}, zone = "Ashenvale", learns = { {spell="Claw", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
          { name = "Giant Ashenvale Bear", level = {29,30}, zone = "Ashenvale", attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
          { name = "Mongress", level = 50, rare = true, zone = "Felwood", learns = { {spell="Claw", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 14316 },
        },
      },
      {
        id = "DarkBrownBears",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BEARS_DARKBROWNBEARS"] or "Dark Brown Bears",
        diet = "Bread, Cheese, Fish, Fruit, Fungus, Meat",
        species = {
          { name = "Giant Grizzled Bear", level = {12,13}, zone = "Silverpine Forest", attackSpeed = 2.0, canBeTamed = true, displayId = 820 },
          { name = "Ashenvale Bear", level = {21,22}, zone = "Ashenvale", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 820 },
        },
      },
      {
        id = "GreyBears",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BEARS_GREYBEARS"] or "Grey Bears",
        diet = "Bread, Cheese, Fish, Fruit, Fungus, Meat",
        species = {
          { name = "Ice Claw Bear", level = {7,8}, zone = "Dun Morogh", learns = { {spell="Claw", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
          { name = "Den Mother", level = {18,19}, zone = "Darkshore", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, notes = { en = "The Den Mother is found inside a cave.", de = "Die HÃ¶hlenmatriarchin befindet sich in einer HÃ¶hle." }, canBeTamed = true, displayId = 3200 },
          { name = "Gray Bear", level = {21,22}, zone = "Hillsbrad Foothills", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
          { name = "Vicious Gray Bear", level = {22,23}, zone = "Hillsbrad Foothills", attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
          { name = "Elder Gray Bear", level = {25,26}, zone = "Hillsbrad Foothills", attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
          { name = "Ironfur Bear", level = {41,42}, zone = "Feralas", learns = { {spell="Claw", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
          { name = "Grizzled Ironfur Bear", level = {44,45}, zone = "Feralas", attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
          { name = "Ironfur Patriarch", level = {48,49}, zone = "Feralas", learns = { {spell="Claw", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
          { name = "Rabid Shardtooth", level = {59,60}, zone = "Winterspring", attackSpeed = 2.0, canBeTamed = true, displayId = 3200 },
        },
      },
      {
        id = "SicklyBlackBears",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BEARS_SICKLYBLACKBEARS"] or "Sickly Black Bears",
        diet = "Bread, Cheese, Fish, Fruit, Fungus, Meat",
        species = {
          { name = "Diseased Black Bear", level = {51,52}, zone = "Western Plaguelands", attackSpeed = 2.0, canBeTamed = true, displayId = 1082 },
        },
      },
      {
        id = "SicklyDarkBrownBears",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BEARS_SICKLYDARKBROWNBEARS"] or "Sickly Dark Brown Bears",
        diet = "Bread, Cheese, Fish, Fruit, Fungus, Meat",
        species = {
          { name = "Angerclaw Bear", level = {47,48}, zone = "Felwood", attackSpeed = 2.0, canBeTamed = true, displayId = 9276 },
          { name = "Angerclaw Mauler", level = {49,50}, zone = "Felwood", learns = { {spell="Claw", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 9276 },
          { name = "Angerclaw Grizzly", level = {51,52}, zone = "Felwood", attackSpeed = 2.0, canBeTamed = true, displayId = 9276 },
          { name = "Diseased Grizzly", level = {55,56}, zone = "Western Plaguelands", learns = { {spell="Claw", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 9276 },
        },
      },
      {
        id = "WhiteBears",
        name = BAB.Locale and BAB.Locale["SUBGROUP_BEARS_WHITEBEARS"] or "White Bears",
        diet = "Bread, Cheese, Fish, Fruit, Fungus, Meat",
        species = {
          { name = "Mangeclaw", level = 11, zone = "Dun Morogh", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 865 },
          { name = "Bjarn", level = 12, rare = true, zone = "Dun Morogh", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 865 },
          { name = "Shardtooth Bear", level = {53,54}, zone = "Winterspring", learns = { {spell="Claw", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 865 },
          { name = "Shardtooth Mauler", level = {55,56}, zone = "Winterspring", attackSpeed = 2.0, canBeTamed = true, displayId = 865 },
          { name = "Ursius", level = 56, elite = true, zone = "Winterspring", attackSpeed = 2.4, canBeTamed = true, displayId = 865 },
          { name = "Elder Shardtooth", level = {57,58}, zone = "Winterspring", learns = { {spell="Claw", rank=8} }, attackSpeed = 2.0, canBeTamed = true, displayId = 865 },
        },
      },
    },
  },
  {
    id = "Crocolisks",
    name = BAB.Locale and BAB.Locale["CATEGORY_CROCOLISKS"] or "Crocolisks",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Crocolisk",
    subgroups = {
      {
        id = "GreenCrocolisk",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CROCOLISKS_GREENCROCOLISK"] or "Green Crocolisk",
        diet = "Fish, Meat",
        species = {
          { name = "Young Wetlands Crocolisk", level = {21,22}, zone = "Wetlands", attackSpeed = 2.0, canBeTamed = true, displayId = 1035 },
          { name = "Wetlands Crocolisk", level = {23,24}, zone = "Wetlands", attackSpeed = 2.0, canBeTamed = true, displayId = 1035 },
          { name = "Giant Wetlands Crocolisk", level = {25,26}, zone = "Wetlands", learns = { {spell="Bite", rank=4} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1035 },
          { name = "Saltwater Crocolisk", level = {35,36}, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 1035 },
          { name = "Drywallow Vicejaw", level = {36,37}, zone = "Dustwallow Marsh", attackSpeed = 2.0, canBeTamed = true, displayId = 1035 },
          { name = "Elder Saltwater Crocolisk", level = 38, elite = true, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 1035 },
          { name = "Mottled Drywallow Crocolisk", level = {38,39}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1035 },
          { name = "Ripscale", level = 39, rare = true, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, displayId = 1035 },
        }
      },
      {
        id = "GreyCrocolisk",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CROCOLISKS_GREYCROCOLISK"] or "Grey Crocolisk",
        diet = "Fish, Meat",
        species = {
          { name = "Dreadmaw Crocolisk", level = {9,11}, zone = "Durotar", learns = { {spell="Bite", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1250 },
          { name = "River Crocolisk", level = {30,31}, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 1250 },
          { name = "Snapjaw Crocolisk", level = {35,36}, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 1250 },
          { name = "Zulian Crocolisk", level = 60, elite = true, zone = "Zul'Gurub (Raid)", attackSpeed = 2.0, canBeTamed = true, displayId = 1250 },
        }
      },
      {
        id = "WhiteCrocolisk",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CROCOLISKS_WHITECROCOLISK"] or "White Crocolisk",
        diet = "Fish, Meat",
        species = {
          { name = "Deviate Crocolisk", level = {18,19}, zone = "Wailing Caverns (Dungeon)", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 2996 },
          { name = "Deadmire", level = 45, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 2996 },
          { name = "Sewer Beast", level = 50, rare = true, zone = "Stormwind City", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 2996 },
        }
      },
      {
        id = "YellowCrocolisk",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CROCOLISKS_YELLOWCROCOLISK"] or "Yellow Crocolisk",
        diet = "Fish, Meat",
        species = {
          { name = "Corrupted Dreadmaw Crocolisk", level = {11,12}, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
          { name = "Loch Crocolisk", level = {14,15}, zone = "Loch Modan", learns = { {spell="Bite", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
          { name = "Large Loch Crocolisk", level = 22, rare = true, zone = "Loch Modan", learns = { {spell="Bite", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
          { name = "Drywallow Crocolisk", level = {35,36}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
          { name = "Young Sawtooth Crocolisk", level = {35,36}, zone = "Swamp of Sorrows", attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
          { name = "Drywallow Snapper", level = {37,38}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=5} }, attackSpeed = 2.0, canBeTamed = true, displayId = 831, notes = { en = "Normally crocolisks cannot use Claw. The Drywallow Snapper comes knowing Claw 5. But he loses it as soon as he zones, and he cannot be taught any other level of Claw.", de = "Normalerweise kÃ¶nnen Krokodile nicht Kralle verwenden. Der Drywallow Snapper kann Kralle 5. Er verliert sie aber, sobald er sich in einen anderen Bereich begibt, und kann keine anderen Kratzkombinationen erlernt werden." } },
          { name = "Sawtooth Crocolisk", level = {38,39}, zone = "Swamp of Sorrows", attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
          { name = "Drywallow Daggermaw", level = {40,41}, zone = "Dustwallow Marsh", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
          { name = "Sawtooth Snapper", level = {41,42}, zone = "Swamp of Sorrows", learns = { {spell="Bite", rank=6} }, attackSpeed = 2.0, canBeTamed = true, displayId = 831 },
        }
      }
    }
  },
  {
    id = "Gorillas",
    name = BAB.Locale and BAB.Locale["CATEGORY_GORILLAS"] or "Gorillas",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Gorilla",
    subgroups = {
      {
        id = "BlackGorilla",
        name = BAB.Locale and BAB.Locale["SUBGROUP_GORILLAS_BLACKGORILLA"] or "Black Gorilla",
        diet = "Fruit, Fungus",
        species = {
          { name = "Jungle Thunderer", level = {37,38}, zone = "Stranglethorn Vale", learns = { {spell="Thunderstomp", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 845 },
          { name = "Konda", level = 43, zone = "Spirit Den, Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 845, notes = { en = "Spawns as the second gorilla during the quest Stranglethorn Fever, at a cave at the north end of Mistvale Valley.", de = "Erscheint als zweiter Gorilla wÃ¤hrend der Quest Fieber von Strangledorn, in einer HÃ¶hle am Nordhang des Mistvale Valley." } },
          { name = "Skymane Gorilla", level = 50, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 845 },
        }
      },
      {
        id = "DarkGreyGorilla",
        name = BAB.Locale and BAB.Locale["SUBGROUP_GORILLAS_DARKGREYGORILLA"] or "Dark Grey Gorilla",
        diet = "Fruit, Fungus",
        species = {
          { name = "Enraged Silverback Gorilla", level = {41,42}, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 837 },
          { name = "Silverback Patriarch", level = {42,43}, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 837 },
          { name = "Un'Goro Gorilla", level = {50,51}, zone = "Un'Goro Crater", attackSpeed = 2.0, canBeTamed = true, displayId = 837 },
          { name = "Un'Goro Stomper", level = {51,52}, zone = "Un'Goro Crater", attackSpeed = 2.0, canBeTamed = true, displayId = 837 },
          { name = "Un'Goro Thunderer", level = {52,53}, zone = "Un'Goro Crater", learns = { {spell="Thunderstomp", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 837 },
        }
      },
      {
        id = "WhiteGorilla",
        name = BAB.Locale and BAB.Locale["SUBGROUP_GORILLAS_WHITEGORILLA"] or "White Gorilla",
        diet = "Fruit, Fungus",
        species = {
          { name = "Uhk'loc", level = 52, rare = true, zone = "Un'Goro Crater", learns = { {spell="Bite", rank=7} }, attackSpeed = 2.0, canBeTamed = true, displayId = 8129 },
        }
      },
      {
        id = "GreyGorilla",
        name = BAB.Locale and BAB.Locale["SUBGROUP_GORILLAS_GREYGORILLA"] or "Grey Gorilla",
        diet = "Fruit, Fungus",
        species = {
          { name = "Mistvale Gorilla", level = {32,33}, zone = "Stranglethorn Vale", learns = { {spell="Thunderstomp", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 843 },
          { name = "Elder Mistvale Gorilla", level = {40,41}, zone = "Stranglethorn Vale", learns = { {spell="Thunderstomp", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 843 },
        }
      },
      {
        id = "RedGorilla",
        name = BAB.Locale and BAB.Locale["SUBGROUP_GORILLAS_REDGORILLA"] or "Red Gorilla",
        diet = "Fruit, Fungus",
        species = {
          { name = "Kurmokk", level = 42, rare = true, zone = "Stranglethorn Vale", attackSpeed = 2.0, canBeTamed = true, displayId = 3186 },
          { name = "Groddoc Ape", level = {42,43}, zone = "Feralas", attackSpeed = 2.0, canBeTamed = true, displayId = 3186 },
          { name = "Groddoc Thunderer", level = {49,50}, zone = "Feralas", learns = { {spell="Thunderstomp", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3186 },
          { name = "U'cha", level = 55, zone = "Un'Goro Crater", learns = { {spell="Thunderstomp", rank=3} }, attackSpeed = 2.0, canBeTamed = true, displayId = 3186 },
        }
      }
    }
  },
  {
    id = "Hyenas",
    name = BAB.Locale and BAB.Locale["CATEGORY_HYENAS"] or "Hyenas",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Hyena",
    subgroups = {
      {
        id = "BrownHyena",
        name = BAB.Locale and BAB.Locale["SUBGROUP_HYENAS_BROWNHYENA"] or "Brown Hyena",
        diet = "Fruit, Meat",
        species = {
          { name = "Galak Packhound", level = 24, zone = "Thousand Needles", attackSpeed = 1.5, canBeTamed = true, displayId = 2726 },
          { name = "Starving Bonepaw", level = {30,32}, zone = "Desolace", attackSpeed = 2.0, canBeTamed = true, displayId = 2726 },
          { name = "Bonepaw Hyena", level = {33,35}, zone = "Desolace", learns = { {spell="Dash", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 2726 },
          { name = "Rabid Bonepaw", level = {36,38}, zone = "Desolace", attackSpeed = 2.0, canBeTamed = true, displayId = 2726 },
        }
      },
      {
        id = "GreyHyena",
        name = BAB.Locale and BAB.Locale["SUBGROUP_HYENAS_GREYHYENA"] or "Grey Hyena",
        diet = "Fruit, Meat",
        species = {
          { name = "Giggler", level = 34, rare = true, zone = "Desolace", attackSpeed = 2.0, canBeTamed = true, displayId = 2714 },
          { name = "Magram Bonepaw", level = {37,38}, zone = "Desolace", learns = { {spell="Dash", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 2714 },
          { name = "Starving Snickerfang", level = {45,46}, zone = "Blasted Lands", attackSpeed = 2.0, canBeTamed = true, displayId = 2714 },
          { name = "Snickerfang Hyena", level = {49,50}, zone = "Blasted Lands", attackSpeed = 2.0, canBeTamed = true, displayId = 2714 },
        }
      },
      {
        id = "OrangeHyena",
        name = BAB.Locale and BAB.Locale["SUBGROUP_HYENAS_ORANGEHYENA"] or "Orange Hyena",
        diet = "Fruit, Meat",
        species = {
          { name = "Kolkar Packhound", level = 13, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 1535 },
          { name = "Steelsnap", level = 30, zone = "Thousand Needles", attackSpeed = 2.0, canBeTamed = true, displayId = 1535 },
          { name = "Starving Blisterpaw", level = {41,42}, zone = "Tanaris", learns = { {spell="Dash", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1535 },
          { name = "Murderous Blisterpaw", level = 43, rare = true, zone = "Tanaris", learns = { {spell="Dash", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1535 },
          { name = "Rabid Blisterpaw", level = {47,48}, zone = "Tanaris", learns = { {spell="Dash", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1535 },
        }
      },
      {
        id = "OrangeHyenaDarker",
        name = BAB.Locale and BAB.Locale["SUBGROUP_HYENAS_ORANGEHYENADARKER"] or "Orange Hyena (Darker)",
        diet = "Fruit, Meat",
        species = {
          { name = "Blisterpaw Hyena (Darker)", level = {44,45}, zone = "Tanaris", learns = { {spell="Dash", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1536 },
        }
      },
      {
        id = "RedHyena",
        name = BAB.Locale and BAB.Locale["SUBGROUP_HYENAS_REDHYENA"] or "Red Hyena",
        diet = "Fruit, Meat",
        species = {
          { name = "Scarlet Tracking Hound", level = {33,34}, elite = true, zone = "Scarlet Monastery (Dungeon)", learns = { {spell="Dash", rank=1} }, attackSpeed = 1.5, notes = { en = "Found in the Library wing.", de = "Zu finden im BibliotheksflÃ¼gel." }, canBeTamed = true, displayId = 2709 },
        }
      },
      {
        id = "PurpleHyena",
        name = BAB.Locale and BAB.Locale["SUBGROUP_HYENAS_PURPLEHYENA"] or "Purple Hyena",
        diet = "Fruit, Meat",
        species = {
          { name = "Snort the Heckler", level = 17, rare = true, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 2713 },
          { name = "Pesterhide Hyena", level = {26,27}, zone = "Thousand Needles", attackSpeed = 2.0, canBeTamed = true, displayId = 2713 },
          { name = "Pesterhide Snarler", level = {28,29}, zone = "Thousand Needles", attackSpeed = 2.0, canBeTamed = true, displayId = 2713 },
          { name = "Ravage", level = 51, rare = true, zone = "Blasted Lands", learns = { {spell="Dash", rank=3} }, attackSpeed = 1.3, canBeTamed = true, displayId = 2713 },
        }
      },
      {
        id = "YellowHyena",
        name = BAB.Locale and BAB.Locale["SUBGROUP_HYENAS_YELLOWHYENA"] or "Yellow Hyena",
        diet = "Fruit, Meat",
        species = {
          { name = "Hecklefang Hyena", level = {15,16}, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 2710 },
          { name = "Hecklefang Snarler", level = {18,19}, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 2710 },
          { name = "Hecklefang Stalker", level = {22,23}, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 2710 },
          { name = "Maraudine Bonepaw", level = {37,38}, zone = "Desolace", attackSpeed = 2.0, spawn = true, canBeTamed = true, displayId = 2710 },
        }
      },
    }
  },
  {
    id = "Tallstriders",
    name = BAB.Locale and BAB.Locale["CATEGORY_TALLSTRIDERS"] or "Tallstriders",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Tallstrider",
    subgroups = {
      {
        id = "BrownTallstrider",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TALLSTRIDERS_BROWNTALLSTRIDER"] or "Brown Tallstrider",
        diet = "Cheese, Fruit, Fungus",
        species = {
          { name = "Plainstrider", level = {1,2}, zone = "Mulgore", attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
          { name = "Greater Plainstrider", level = {11,12}, zone = "The Barrens", attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
          { name = "Foreststrider Fledgling", level = {11,13}, zone = "Darkshore", learns = { {spell="Cower", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
          { name = "Foreststrider", level = {14,16}, zone = "Darkshore", attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
          { name = "Giant Foreststrider", level = {17,19}, zone = "Darkshore", learns = { {spell="Cower", rank=2} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1219 },
        }
      },
      {
        id = "GreyTallstrider",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TALLSTRIDERS_GREYTALLSTRIDER"] or "Grey Tallstrider",
        diet = "Cheese, Fruit, Fungus",
        species = {
          { name = "Adult Plainstrider", level = {6,7}, zone = "Mulgore", attackSpeed = 2.0, canBeTamed = true, displayId = 1220 },
          { name = "Ornery Plainstrider", level = {16,17}, zone = "The Barrens", learns = { {spell="Cower", rank=2} }, attackSpeed = 1.3, canBeTamed = true, displayId = 1220 },
        }
      },
      {
        id = "PinkTallstrider",
        diet = "Cheese, Fruit, Fungus",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TALLSTRIDERS_PINKTALLSTRIDER"] or "Pink Tallstrider",
        species = {
          { name = "Mazzranache", level = 9, rare = true, zone = "Mulgore", learns = { {spell="Cower", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1961 },
        }
      },
      {
        id = "TurquoiseTallstrider",
        diet = "Cheese, Fruit, Fungus",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TALLSTRIDERS_TURQUOISETALLSTRIDER"] or "Turquoise Tallstrider",
        species = {
          { name = "Strider Clutchmother", level = 20, rare = true, zone = "Darkshore", attackSpeed = 2.0, canBeTamed = true, displayId = 38 },
        }
      },
      {
        id = "WhiteTallstrider",
        diet = "Cheese, Fruit, Fungus",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TALLSTRIDERS_WHITETALLSTRIDER"] or "White Tallstrider",
        species = {
          { name = "Elder Plainstrider", level = {8,9}, zone = "Mulgore", learns = { {spell="Cower", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1221 },
          { name = "Fleeting Plainstrider", level = {12,13}, zone = "The Barrens", learns = { {spell="Cower", rank=1} }, attackSpeed = 2.0, canBeTamed = true, displayId = 1221 },
        }
      },
      {
        id = "PurpleTallstrider",
        diet = "Cheese, Fruit, Fungus",
        name = BAB.Locale and BAB.Locale["SUBGROUP_TALLSTRIDERS_PURPLETALLSTRIDER"] or "Purple Tallstriders",
        species = {
        }
      },
    },
  },
  {
    id = "Crabs",
    name = BAB.Locale and BAB.Locale["CATEGORY_CRABS"] or "Crabs",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Crab",
    subgroups = {
      {
        id = "BlueCrabs",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CRABS_BLUECRABS"] or "Blue Crabs",
        diet = "Bread, Fish, Fruit, Fungus",
        species = {
          { name = "Pygmy Tide Crawler", level = {9,10}, zone = "Darkshore", attackSpeed = 2.0, displayId = 9566 },
          { name = "Corrupted Surf Crawler", level = {10,11}, zone = "Durotar", attackSpeed = 2.0, displayId = 9566 },
          { name = "Tide Crawler", level = {12,14}, zone = "Darkshore", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.0, displayId = 9566 },
          { name = "Sea Crawler", level = {15,16}, zone = "Westfall", attackSpeed = 2.0, displayId = 9566 },
          { name = "Encrusted Tide Crawler", level = {18,20}, zone = "Darkshore", attackSpeed = 2.0, displayId = 9566 },
          { name = "Clattering Crawler", level = {19,20}, zone = "Ashenvale", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, displayId = 9566 },
          { name = "Southern Sand Crawler", level = {40,41}, zone = "Stranglethorn Vale", attackSpeed = 2.0, displayId = 9566 },
        }
      },
      {
        id = "BronzeCrabs",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CRABS_BRONZECRABS"] or "Bronze Crabs",
        diet = "Bread, Fish, Fruit, Fungus",
        species = {
          { name = "Sand Crawler", level = {13,14}, zone = "Westfall", attackSpeed = 2.0, displayId = 342 },
          { name = "Shore Crawler", level = {17,18}, zone = "Westfall", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, displayId = 342 },
          { name = "Silt Crawler", level = {40,41}, zone = "Swamp of Sorrows", learns = { {spell="Claw", rank=6} }, attackSpeed = 2.0, displayId = 342 },
          { name = "Monstrous Crawler", level = {43,44}, zone = "Swamp of Sorrows", learns = { {spell="Claw", rank=6} }, attackSpeed = 2.0, displayId = 342 },
        }
      },
      {
        id = "RedCrabs",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CRABS_REDCRABS"] or "Red Crabs",
        diet = "Bread, Fish, Fruit, Fungus",
        species = {
          { name = "Pygmy Surf Crawler", level = {5,6}, zone = "Durotar", learns = { {spell="Claw", rank=1} }, attackSpeed = 2.0, displayId = 1307 },
          { name = "Surf Crawler", level = {7,8}, zone = "Durotar", attackSpeed = 2.0, displayId = 1307 },
          { name = "Silithid Protector", level = {18,19}, zone = "The Barrens", attackSpeed = 2.0, displayId = 1307, notes = { en = "These crabs used to do an emote every time you summoned them, but alas that is no longer the case.", de = "Diese Krebse fÃ¼hrten frÃ¼her jedes Mal eine Animation auf, wenn man sie beschwor, aber das ist leider nicht mehr der Fall." } },
        }
      },
      {
        id = "WhiteCrabs",
        name = BAB.Locale and BAB.Locale["SUBGROUP_CRABS_WHITECRABS"] or "White Crabs",
        diet = "Bread, Fish, Fruit, Fungus",
        species = {
          { name = "Encrusted Surf Crawler", level = {9,10}, zone = "Durotar", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.0, displayId = 999 },
          { name = "Young Reef Crawler", level = {10,11}, zone = "Darkshore", attackSpeed = 2.0, displayId = 999 },
          { name = "Reef Crawler", level = {15,17}, zone = "Darkshore", attackSpeed = 2.0, displayId = 999 },
          { name = "Raging Reef Crawler", level = {20,21}, zone = "Darkshore", attackSpeed = 2.0, displayId = 999 },
          { name = "Spined Crawler", level = {20,21}, zone = "Ashenvale", attackSpeed = 2.0, displayId = 999 },
          { name = "Skittering Crustacean", elite = true, level = {22,23}, zone = "Blackfathom Deeps (Dungeon)", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, displayId = 999 },
          { name = "Snapping Crustacean", elite = true, level = {23,24}, zone = "Blackfathom Deeps (Dungeon)", learns = { {spell="Claw", rank=3} }, attackSpeed = 2.0, displayId = 999 },
          { name = "Barbed Crustacean", elite = true, level = {25,26}, zone = "Blackfathom Deeps (Dungeon)", learns = { {spell="Claw", rank=4} }, attackSpeed = 2.0, displayId = 999 },
          { name = "Enraged Reef Crawler", level = {30,32}, zone = "Desolace", attackSpeed = 2.0, displayId = 999 },
        }
      }
    }
  },
  {
    id = "Owls",
    name = BAB.Locale and BAB.Locale["CATEGORY_OWLS"] or "Owls",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
    subgroups = {
      {
        id = "GreyOwls",
        name = BAB.Locale and BAB.Locale["SUBGROUP_OWLS_GREYOWLS"] or "Grey Owls",
        diet = "Meat",
        species = {
          { name = "Strigid Owl", level = {5,6}, zone = "Teldrassil", learns = { {spell="Claw", rank=1} }, attackSpeed = 2.0, displayId = 10832 },
          { name = "Strigid Screecher", level = {7,8}, zone = "Teldrassil", attackSpeed = 2.0, displayId = 10832 },
          { name = "Strigid Hunter", level = {8,9}, zone = "Teldrassil", learns = { {spell="Claw", rank=2} }, attackSpeed = 2.0, displayId = 10832 },
          { name = "Ironbeak Owl", level = {48,49}, zone = "Felwood", learns = { {spell="Dive", rank=2}, {spell="Screech", rank=3} }, attackSpeed = 2.0, displayId = 10832 },
          { name = "Ironbeak Hunter", level = {50,51}, zone = "Felwood", learns = { {spell="Claw", rank=7}, {spell="Dive", rank=3} }, attackSpeed = 2.0, displayId = 10832 },
          { name = "Ironbeak Screecher", level = {52,53}, zone = "Felwood", learns = { {spell="Dive", rank=3} }, attackSpeed = 2.0, displayId = 10832 },
        }
      },
      {
        id = "WhiteOwls",
        name = BAB.Locale and BAB.Locale["SUBGROUP_OWLS_WHITEOWLS"] or "White Owls",
        diet = "Meat",
        species = {
          { name = "Olm the Wise", rare = true, level = 52, zone = "Felwood", learns = { {spell="Claw", rank=7}, {spell="Dive", rank=3} }, attackSpeed = 2.0, displayId = 6212, notes = { en = "The only pet with a faction! For some reason, Olm is part of the Cenarion Circle faction. You must be at war with Cenarion Circle to tame him. Note that taming him does not affect your faction, however.", de = "Das einzige Haustier mit einer Fraktion! Aus irgendeinem Grund ist Olm Teil der Zirkel-der-Zenarion-Fraktion. Du musst im Krieg mit dem Zirkel der Zenarion sein, um ihn zu zÃ¤hmen. Beachte jedoch, dass das ZÃ¤hmen deine Fraktionsbeziehung nicht beeinflusst." } },
          { name = "Stormpike Owl", level = {53,54}, zone = "Alterac Valley (Battleground)", attackSpeed = 2.0, displayId = 6212, notes = { en = "Available to Horde Hunters Only", de = "Nur fÃ¼r Horde-JÃ¤ger verfÃ¼gbar" } },
          { name = "Winterspring Owl", level = {54,56}, zone = "Winterspring", learns = { {spell="Claw", rank=7}, {spell="Dive", rank=3} }, attackSpeed = 2.0, displayId = 6212 },
          { name = "Winterspring Screecher", level = {57,59}, zone = "Winterspring", learns = { {spell="Claw", rank=8}, {spell="Dive", rank=3}, {spell="Screech", rank=4} }, attackSpeed = 2.0, displayId = 6212 },
        }
      },
      {
        id = "BlackOwls",
        name = BAB.Locale and BAB.Locale["SUBGROUP_OWLS_BLACKOWLS"] or "Black Owls",
        diet = "Meat",
        species = {
        }
      },
      {
        id = "BrownOwls",
        name = BAB.Locale and BAB.Locale["SUBGROUP_OWLS_BROWNOWLS"] or "Brown Owls",
        diet = "Meat",
        species = {
        }
      },
      {
        id = "DarkBrownOwls",
        name = BAB.Locale and BAB.Locale["SUBGROUP_OWLS_DARKBROWNOWLS"] or "Dark Brown Owls",
        diet = "Meat",
        species = {
        }
      },
      {
        id = "RedOwls",
        name = BAB.Locale and BAB.Locale["SUBGROUP_OWLS_REDOWLS"] or "Red Owls",
        diet = "Meat",
        species = {
        }
      },
      {
        id = "RedPurpleOwls",
        name = BAB.Locale and BAB.Locale["SUBGROUP_OWLS_REDPURPLEOWLS"] or "Red and Purple Owls",
        diet = "Meat",
        species = {
        }
      }
    }
  },
  {
    id = "Scorpids",
    name = BAB.Locale and BAB.Locale["CATEGORY_SCORPIDS"] or "Scorpids",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Scorpid",
    subgroups = {
      {
        id = "BlackScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_BLACKSCORPIDS"] or "Black Scorpids",
        diet = "Meat",
        species = {
          { name = "Sarkoth", level = 4, zone = "Durotar", learns = { {spell="Claw", rank=1} }, attackSpeed = 2.0, displayId = 6068 },
          { name = "Corrupted Scorpid", level = {10,11}, zone = "Durotar", learns = { {spell="Scorpid Poison", rank=1} }, attackSpeed = 2.0, displayId = 6068 },
          { name = "Death Flayer", rare = true, level = 11, zone = "Durotar", learns = { {spell="Claw", rank=2}, {spell="Scorpid Poison", rank=1} }, attackSpeed = 1.6, displayId = 6068 },
          { name = "Scorpid Terror", level = {33,34}, zone = "Thousand Needles", learns = { {spell="Scorpid Poison", rank=2} }, attackSpeed = 2.0, displayId = 6068 },
          { name = "Venomlash Scorpid", elite = true, level = {39,40}, zone = "Uldaman (Dungeon)", learns = { {spell="Claw", rank=5} }, attackSpeed = 2.0, displayId = 6068 },
          { name = "Scorpok Stinger", level = {50,51}, zone = "Blasted Lands", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 6068, notes = { en = "Note that this pet is too low level to retain Scorpid Poison Rank 5, so it will lose it as soon as you zone or logoff.", de = "Hinweis: Dieses Haustier ist zu niedrig stufig, um Skorpidgift Rang 5 zu behalten, daher verliert es es, sobald du dich in einen anderen Bereich begibst oder dich abmeldest." } },
          { name = "Krellack", rare = true, level = 56, zone = "Silithus", learns = { {spell="Scorpid Poison", rank=4} }, attackSpeed = 2.0, displayId = 6068 },
        }
      },
      {
        id = "BronzeScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_BRONZESCORPIDS"] or "Bronze Scorpids",
        diet = "Meat",
        species = {
          { name = "Armored Scorpid", level = {7,8}, zone = "Durotar", attackSpeed = 2.0, displayId = 2487 },
          { name = "Venomtail Scorpid", level = {9,10}, zone = "Durotar", learns = { {spell="Claw", rank=2}, {spell="Scorpid Poison", rank=1} }, attackSpeed = 2.0, displayId = 2487 },
          { name = "Venomtip Scorpid", level = {52,53}, zone = "Burning Steppes", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 2487 },
          { name = "Deathlash Scorpid", level = {54,55}, zone = "Burning Steppes", learns = { {spell="Claw", rank=7}, {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 2487 },
          { name = "Firetail Scorpid", level = {56,57}, zone = "Burning Steppes", learns = { {spell="Scorpid Poison", rank=4} }, attackSpeed = 2.0, displayId = 2487 },
        }
      },
      {
        id = "BrownScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_BROWNSCORPIDS"] or "Brown Scorpids",
        diet = "Meat",
        species = {
          { name = "Scorpid Worker", level = 3, zone = "Durotar", learns = { {spell="Claw", rank=1} }, attackSpeed = 2.0, displayId = 2486 },
          { name = "Clattering Scorpid", level = {5,6}, zone = "Durotar", attackSpeed = 2.0, displayId = 2486 },
        }
      },
      {
        id = "GreenScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_GREENSCORPIDS"] or "Green Scorpids",
        diet = "Meat",
        species = {
          { name = "Silithid Creeper", level = {20,21}, zone = "The Barrens", learns = { {spell="Scorpid Poison", rank=1} }, attackSpeed = 2.0, displayId = 2730 },
          { name = "Silithid Swarmer", level = {21,22}, zone = "The Barrens", learns = { {spell="Scorpid Poison", rank=1} }, attackSpeed = 2.0, displayId = 2730 },
        }
      },
      {
        id = "PinkScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_PINKSCORPIDS"] or "Pink Scorpids",
        diet = "Meat",
        species = {
          { name = "Scorpid Hunter", level = {40,41}, zone = "Tanaris", learns = { {spell="Claw", rank=6}, {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 2414 },
          { name = "Scorpid Tail Lasher", level = {43,44}, zone = "Tanaris", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 2414 },
          { name = "Scorpid Duneburrower", level = {46,47}, zone = "Tanaris", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 2414 },
          { name = "Scorpid Dunestalker", level = {46,47}, zone = "Tanaris", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 2414 },
        }
      },
      {
        id = "RedScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_REDSCORPIDS"] or "Red Scorpids",
        diet = "Meat",
        species = {
          { name = "Scorpid Reaver", level = {31,32}, zone = "Thousand Needles", learns = { {spell="Claw", rank=4}, {spell="Scorpid Poison", rank=2} }, attackSpeed = 2.0, displayId = 3247 },
          { name = "Cleft Scorpid", level = {35,36}, zone = "Uldaman (Dungeon)", learns = { {spell="Scorpid Poison", rank=2} }, attackSpeed = 2.0, displayId = 3247 },
          { name = "Deadly Cleft Scorpid", level = {42,43}, zone = "Uldaman (Dungeon)", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 3247 },
          { name = "Deep Stinger", level = {50,52}, zone = "Blackrock Depths (Dungeon)", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 3247 },
        }
      },
      {
        id = "WhiteScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_WHITESCORPIDS"] or "White Scorpids",
        diet = "Meat",
        species = {
          { name = "Vile Sting", rare = true, level = 35, zone = "Thousand Needles", learns = { {spell="Claw", rank=5}, {spell="Scorpid Poison", rank=2} }, attackSpeed = 2.0, displayId = 10988 },
          { name = "Clack the Reaver", rare = true, level = 53, zone = "Blasted Lands", learns = { {spell="Claw", rank=7} }, attackSpeed = 2.0, displayId = 10988 },
          { name = "Stonelash Scorpid", level = {54,55}, zone = "Silithus", learns = { {spell="Scorpid Poison", rank=3} }, attackSpeed = 2.0, displayId = 10988 },
          { name = "Stonelash Flayer", level = {58,59}, zone = "Silithus", learns = { {spell="Scorpid Poison", rank=4} }, attackSpeed = 2.0, displayId = 10988 },
        }
      },
      {
        id = "YellowScorpids",
        name = BAB.Locale and BAB.Locale["SUBGROUP_SCORPIDS_YELLOWSCORPIDS"] or "Yellow Scorpids",
        diet = "Meat",
        species = {
          { name = "Scorpashi Snapper", level = {30,31}, zone = "Desolace", learns = { {spell="Claw", rank=4}, {spell="Scorpid Poison", rank=2} }, attackSpeed = 2.0, displayId = 2729 },
          { name = "Scorpashi Lasher", level = {34,35}, zone = "Desolace", learns = { {spell="Claw", rank=5}, {spell="Scorpid Poison", rank=2} }, attackSpeed = 2.0, displayId = 2729 },
          { name = "Scorpashi Venomlash", level = {38,39}, zone = "Desolace", learns = { {spell="Scorpid Poison", rank=2} }, attackSpeed = 2.0, displayId = 2729 },
          { name = "Stonelash Pincer", level = {56,57}, zone = "Silithus", learns = { {spell="Scorpid Poison", rank=4} }, attackSpeed = 2.0, displayId = 2729 },
        }
      },
    }
  },
}
function BAB.GetPetCategories()
  BAB._RawPetData = BAB._RawPetData or {}
  return BAB._RawPetData
end

BeastAndBow.GetPetCategories = BAB.GetPetCategories

-- Utility to fetch category by id
function BAB.GetPetCategoryById(catId)
  for _, c in ipairs(BAB.GetPetCategories()) do
    if c.id == catId then return c end
  end
end
-- Skill level data (added by user)
BAB.SkillLevelData = {
  [1] = "Bite 1, Charge 1, Claw 1, Growl 1, Lightning Breath 1",
  [5] = "Cower 1",
  [8] = "Bite 2, Claw 2, Scorpid Poison 1, Screech 1",
  [10] = "Furious Howl 1, Great Stamina 1, Growl 2, Natural Armor 1",
  [12] = "Charge 2, Great Stamina 2, Lightning Breath 2, Natural Armor 2",
  [15] = "Cower 2",
  [16] = "Bite 3, Claw 3",
  [18] = "Great Stamina 3, Natural Armor 3",
  [20] = "Arcane Resistance 1, Fire Resistance 1, Frost Resistance 1, Growl 3, Nature Resistance 1, Shadow Resistance 1, Shell Shield 1",
  [24] = "Bite 4, Charge 3, Claw 4, Furious Howl 2, Great Stamina 4, Lightning Breath 3, Natural Armor 4, Scorpid Poison 2, Screech 2",
  [25] = "Cower 3",
  [30] = "Arcane Resistance 2, Dash 1, Dive 1, Fire Resistance 2, Frost Resistance 2, Great Stamina 5, Growl 4, Natural Armor 5, Nature Resistance 2, Prowl 1, Shadow Resistance 2, Thunderstomp 1",
  [32] = "Bite 5, Claw 5",
  [35] = "Cower 4",
  [36] = "Charge 4, Great Stamina 6, Lightning Breath 4, Natural Armor 6",
  [40] = "Arcane Resistance 3, Bite 6, Claw 6, Dash 2, Dive 2, Fire Resistance 3, Frost Resistance 3, Furious Howl 3, Growl 5, Nature Resistance 3, Prowl 2, Scorpid Poison 3, Shadow Resistance 3, Thunderstomp 2",
  [42] = "Great Stamina 7, Natural Armor 7",
  [45] = "Cower 5",
  [48] = "Bite 7, Charge 5, Claw 7, Great Stamina 8, Lightning Breath 5, Natural Armor 8, Screech 3",
  [50] = "Arcane Resistance 4, Dash 3, Dive 3, Fire Resistance 4, Frost Resistance 4, Growl 6, Nature Resistance 4, Prowl 3, Shadow Resistance 4, Thunderstomp 3",
  [54] = "Great Stamina 9, Natural Armor 9",
  [55] = "Cower 6",
  [56] = "Bite 8, Claw 8, Furious Howl 4, Scorpid Poison 4, Screech 4",
  [60] = "Arcane Resistance 5, Charge 6, Fire Resistance 5, Frost Resistance 5, Great Stamina 10, Growl 7, Lightning Breath 6, Natural Armor 10, Nature Resistance 5, Shadow Resistance 5",
  [64] = "Bite 9, Claw 9, Scorpid Poison 5, Screech 5",
  [65] = "Cower 7",
  [70] = "Great Stamina 11, Growl 8, Natural Armor 11",
}
-- Parse the SkillLevelData into a normalized table: skillName -> list of {rank=?, level=?}
function BAB.ParseSkillLevels()
  if BAB._parsedSkillLevels then return BAB._parsedSkillLevels end
  local parsed = {}
  for level, line in pairs(BAB.SkillLevelData) do
    for entry in string.gmatch(line, "[^,]+") do
      local s = entry:gsub("^%s+",""):gsub("%s+$","")
      -- try to capture a trailing rank number; e.g. "Bite 2" -> name="Bite", rank=2
      local name, rank = s:match("^(.-)%s+(%d+)$")
      if not name then
        name = s
        rank = 1
      else
        rank = tonumber(rank)
      end
      name = name:gsub("%s+$","")
      parsed[name] = parsed[name] or {}
      table.insert(parsed[name], { rank = rank, level = level })
    end
  end
  -- sort entries for each skill by rank ascending
  for name, list in pairs(parsed) do
    table.sort(list, function(a,b)
      if a.rank == b.rank then return a.level < b.level end
      return a.rank < b.rank
    end)
  end
  BAB._parsedSkillLevels = parsed
  return parsed
end
-- Return a list of skill names (sorted)
function BAB.GetAllSkillNames()
  local parsed = BAB.ParseSkillLevels()
  local names = {}
  for n in pairs(parsed) do table.insert(names, n) end
  table.sort(names)
  return names
end
-- Lightweight UI: show a simple skill browser and details window (placeholders for pets)
function BAB.ShowSkillBrowser()
  -- Delegate to in-frame skills UI if available to avoid creating a separate window
  if BeastAndBow and BeastAndBow.OpenSkillsView then
    local success, err = pcall(BeastAndBow.OpenSkillsView)
    if not success and BeastAndBow_Settings and BeastAndBow_Settings.debug and BeastAndBow.Debug then
      BeastAndBow.Debug.Error("OpenSkillsView failed: " .. tostring(err), "Bestarium")
    end
    return
  end
  -- Fallback: no BeastAndBow UI present, do nothing
  print("BeastAndBow: Skill browser is delegated to main UI. No action taken.")
end
function BAB.ShowSkillDetails(skillName, rankIndex)
  -- Delegate to in-frame detail display if available
  if BeastAndBow and BeastAndBow.OpenSkillsView and BeastAndBow.SelectSkill then
    local success, err = pcall(BeastAndBow.OpenSkillsView)
    if not success and BeastAndBow_Settings and BeastAndBow_Settings.debug and BeastAndBow.Debug then
      BeastAndBow.Debug.Error("OpenSkillsView failed: " .. tostring(err), "Bestarium")
    end
    success, err = pcall(BeastAndBow.SelectSkill, skillName)
    if not success and BeastAndBow_Settings and BeastAndBow_Settings.debug and BeastAndBow.Debug then
      BeastAndBow.Debug.Error("SelectSkill failed: " .. tostring(err), "Bestarium")
    end
    if BeastAndBow.SelectSkillRank then 
      success, err = pcall(BeastAndBow.SelectSkillRank, skillName, rankIndex or 1)
      if not success and BeastAndBow_Settings and BeastAndBow_Settings.debug and BeastAndBow.Debug then
        BeastAndBow.Debug.Error("SelectSkillRank failed: " .. tostring(err), "Bestarium")
      end
    end
    return
  end
  print("BeastAndBow: ShowSkillDetails delegated to main UI; no detail popup shown.")
end
-- ============================================================================
-- ABILITY DATA
-- ============================================================================
BAB.AbilitiesByLevel = BAB.AbilitiesByLevel or {
    [1] = {
        { id = "Bite", name = "Bite", rank = 1 },
        { id = "Claw", name = "Claw", rank = 1 },
        { id = "Growl", name = "Growl", rank = 1 },
        { id = "Lightning Breath", name = "Lightning Breath", rank = 1 },
    },
    [5] = {
        { id = "Cower", name = "Cower", rank = 1 },
  },
    [8] = {
        { id = "Bite", name = "Bite", rank = 2 },
        { id = "Claw", name = "Claw", rank = 2 },
        { id = "Scorpid Poison", name = "Scorpid Poison", rank = 1 },
        { id = "Screech", name = "Screech", rank = 1 },
    },
    [10] = {
        { id = "Furious Howl", name = "Furious Howl", rank = 1 },
        { id = "Great Stamina", name = "Great Stamina", rank = 1 },
        { id = "Growl", name = "Growl", rank = 2 },
        { id = "Natural Armor", name = "Natural Armor", rank = 1 },
    },
    [12] = {
        { id = "Charge", name = "Charge", rank = 2 },
        { id = "Great Stamina", name = "Great Stamina", rank = 2 },
        { id = "Lightning Breath", name = "Lightning Breath", rank = 2 },
        { id = "Natural Armor", name = "Natural Armor", rank = 2 },
    },
    [15] = {
        { id = "Cower", name = "Cower", rank = 2 },
    },
    [16] = {
        { id = "Bite", name = "Bite", rank = 3 },
        { id = "Claw", name = "Claw", rank = 3 },
    },
    [18] = {
        { id = "Great Stamina", name = "Great Stamina", rank = 3 },
        { id = "Natural Armor", name = "Natural Armor", rank = 3 },
    },
    [20] = {
        { id = "Arcane Resistance", name = "Arcane Resistance", rank = 1 },
        { id = "Fire Resistance", name = "Fire Resistance", rank = 1 },
        { id = "Frost Resistance", name = "Frost Resistance", rank = 1 },
        { id = "Growl", name = "Growl", rank = 3 },
        { id = "Nature Resistance", name = "Nature Resistance", rank = 1 },
        { id = "Shadow Resistance", name = "Shadow Resistance", rank = 1 },
        { id = "Shell Shield", name = "Shell Shield", rank = 1 },
    },
    [24] = {
        { id = "Bite", name = "Bite", rank = 4 },
        { id = "Charge", name = "Charge", rank = 3 },
        { id = "Claw", name = "Claw", rank = 4 },
        { id = "Furious Howl", name = "Furious Howl", rank = 2 },
        { id = "Great Stamina", name = "Great Stamina", rank = 4 },
        { id = "Lightning Breath", name = "Lightning Breath", rank = 3 },
        { id = "Natural Armor", name = "Natural Armor", rank = 4 },
        { id = "Scorpid Poison", name = "Scorpid Poison", rank = 2 },
        { id = "Screech", name = "Screech", rank = 2 },
    },
    [25] = {
        { id = "Cower", name = "Cower", rank = 3 },
    },
    [30] = {
        { id = "Arcane Resistance", name = "Arcane Resistance", rank = 2 },
        { id = "Dash", name = "Dash", rank = 1 },
        { id = "Dive", name = "Dive", rank = 1 },
        { id = "Fire Resistance", name = "Fire Resistance", rank = 2 },
        { id = "Frost Resistance", name = "Frost Resistance", rank = 2 },
        { id = "Great Stamina", name = "Great Stamina", rank = 5 },
        { id = "Growl", name = "Growl", rank = 4 },
        { id = "Natural Armor", name = "Natural Armor", rank = 5 },
        { id = "Nature Resistance", name = "Nature Resistance", rank = 2 },
        { id = "Prowl", name = "Prowl", rank = 1 },
        { id = "Shadow Resistance", name = "Shadow Resistance", rank = 2 },
        { id = "Thunderstomp", name = "Thunderstomp", rank = 1 },
    },
    [32] = {
        { id = "Bite", name = "Bite", rank = 5 },
        { id = "Claw", name = "Claw", rank = 5 },
    },
    [35] = {
        { id = "Cower", name = "Cower", rank = 4 },
    },
    [36] = {
        { id = "Charge", name = "Charge", rank = 4 },
        { id = "Great Stamina", name = "Great Stamina", rank = 6 },
        { id = "Lightning Breath", name = "Lightning Breath", rank = 4 },
        { id = "Natural Armor", name = "Natural Armor", rank = 6 },
    },
    [40] = {
        { id = "Arcane Resistance", name = "Arcane Resistance", rank = 3 },
        { id = "Bite", name = "Bite", rank = 6 },
        { id = "Claw", name = "Claw", rank = 6 },
        { id = "Dash", name = "Dash", rank = 2 },
        { id = "Dive", name = "Dive", rank = 2 },
        { id = "Fire Resistance", name = "Fire Resistance", rank = 3 },
        { id = "Frost Resistance", name = "Frost Resistance", rank = 3 },
        { id = "Furious Howl", name = "Furious Howl", rank = 3 },
        { id = "Growl", name = "Growl", rank = 5 },
        { id = "Nature Resistance", name = "Nature Resistance", rank = 3 },
        { id = "Prowl", name = "Prowl", rank = 2 },
        { id = "Scorpid Poison", name = "Scorpid Poison", rank = 3 },
        { id = "Shadow Resistance", name = "Shadow Resistance", rank = 3 },
        { id = "Thunderstomp", name = "Thunderstomp", rank = 2 },
    },
    [42] = {
        { id = "Great Stamina", name = "Great Stamina", rank = 7 },
        { id = "Natural Armor", name = "Natural Armor", rank = 7 },
    },
    [45] = {
        { id = "Cower", name = "Cower", rank = 5 },
    },
    [48] = {
        { id = "Bite", name = "Bite", rank = 7 },
        { id = "Charge", name = "Charge", rank = 5 },
        { id = "Claw", name = "Claw", rank = 7 },
        { id = "Great Stamina", name = "Great Stamina", rank = 8 },
        { id = "Lightning Breath", name = "Lightning Breath", rank = 5 },
        { id = "Natural Armor", name = "Natural Armor", rank = 8 },
        { id = "Screech", name = "Screech", rank = 3 },
    },
    [50] = {
        { id = "Arcane Resistance", name = "Arcane Resistance", rank = 4 },
        { id = "Dash", name = "Dash", rank = 3 },
        { id = "Dive", name = "Dive", rank = 3 },
        { id = "Fire Resistance", name = "Fire Resistance", rank = 4 },
        { id = "Frost Resistance", name = "Frost Resistance", rank = 4 },
        { id = "Growl", name = "Growl", rank = 6 },
        { id = "Nature Resistance", name = "Nature Resistance", rank = 4 },
        { id = "Prowl", name = "Prowl", rank = 3 },
        { id = "Shadow Resistance", name = "Shadow Resistance", rank = 4 },
        { id = "Thunderstomp", name = "Thunderstomp", rank = 3 },
    },
    [54] = {
        { id = "Great Stamina", name = "Great Stamina", rank = 9 },
        { id = "Natural Armor", name = "Natural Armor", rank = 9 },
    },
    [55] = {
        { id = "Cower", name = "Cower", rank = 6 },
    },
    [56] = {
        { id = "Bite", name = "Bite", rank = 8 },
        { id = "Claw", name = "Claw", rank = 8 },
        { id = "Furious Howl", name = "Furious Howl", rank = 4 },
        { id = "Scorpid Poison", name = "Scorpid Poison", rank = 4 },
        { id = "Screech", name = "Screech", rank = 4 },
    },
    [60] = {
        { id = "Arcane Resistance", name = "Arcane Resistance", rank = 5 },
        { id = "Charge", name = "Charge", rank = 6 },
        { id = "Fire Resistance", name = "Fire Resistance", rank = 5 },
        { id = "Frost Resistance", name = "Frost Resistance", rank = 5 },
        { id = "Great Stamina", name = "Great Stamina", rank = 10 },
        { id = "Growl", name = "Growl", rank = 7 },
        { id = "Lightning Breath", name = "Lightning Breath", rank = 6 },
        { id = "Natural Armor", name = "Natural Armor", rank = 10 },
        { id = "Nature Resistance", name = "Nature Resistance", rank = 5 },
        { id = "Shadow Resistance", name = "Shadow Resistance", rank = 5 },
    },
    [63] = {
    },
    [64] = {
      { id = "Bite", name = "Bite", rank = 9 },
      { id = "Claw", name = "Claw", rank = 9 },
      { id = "Scorpid Poison", name = "Scorpid Poison", rank = 5 },
      { id = "Screech", name = "Screech", rank = 5 },
    },
    [65] = {
      { id = "Cower", name = "Cower", rank = 7 },
    },
    [70] = {
      { id = "Great Stamina", name = "Great Stamina", rank = 11 },
      { id = "Growl", name = "Growl", rank = 8 },
      { id = "Natural Armor", name = "Natural Armor", rank = 11 },
    },
}

BAB.AbilityIcons = {
    -- Offensive
    { name = "Bite", path = "Interface\\Icons\\ability_racial_cannibalize" },
    { name = "Claw", path = "Interface\\Icons\\ability_druid_rake" },
    { name = "Charge", path = "Interface\\Icons\\ability_hunter_pet_bear" },
    { name = "Dash", path = "Interface\\Icons\\ability_druid_dash" },
    { name = "Dive", path = "Interface\\Icons\\spell_shadow_burningspirit" },
    { name = "Furious Howl", path = "Interface\\Icons\\ability_hunter_pet_wolf" },
    { name = "Lightning Breath", path = "Interface\\Icons\\spell_nature_lightning" },
    { name = "Prowl", path = "Interface\\Icons\\ability_druid_supriseattack" },
    { name = "Scorpid Poison", path = "Interface\\Icons\\ability_poisonsting" },
    { name = "Screech", path = "Interface\\Icons\\ability_hunter_pet_bat" },
    { name = "Thunderstomp", path = "Interface\\Icons\\ability_hunter_pet_gorilla" },
    -- Defensive
    { name = "Cower", path = "Interface\\Icons\\ability_druid_cower" },
    { name = "Growl", path = "Interface\\Icons\\ability_physical_taunt" },
    { name = "Shell Shield", path = "Interface\\Icons\\ability_hunter_pet_turtle" },
    { name = "Great Stamina", path = "Interface\\Icons\\spell_nature_unyeildingstamina" },
    { name = "Natural Armor", path = "Interface\\Icons\\spell_nature_spiritarmor" },
    -- Resistances
    { name = "Arcane Resistance", path = "Interface\\Icons\\spell_nature_starfall" },
    { name = "Fire Resistance", path = "Interface\\Icons\\spell_fire_firearmor" },
    { name = "Frost Resistance", path = "Interface\\Icons\\spell_frost_frostward" },
    { name = "Nature Resistance", path = "Interface\\Icons\\spell_nature_resistnature" },
    { name = "Shadow Resistance", path = "Interface\\Icons\\spell_shadow_antishadow" },
    
}

-- Ability display order (must be after AbilityIcons)
BAB.AbilityOrder = {
  "Bite", "Claw", "Charge", "Dash", "Dive", "Furious Howl", "Lightning Breath", "Prowl", "Scorpid Poison", "Screech", "Thunderstomp",
    "Cower", "Growl", "Shell Shield", "Great Stamina", "Natural Armor",
    "Arcane Resistance", "Fire Resistance", "Frost Resistance", "Nature Resistance", "Shadow Resistance",
}

-- ============================================================================
local function FlattenWrapperSubgroups(categoryId, wrapperIds)
  if type(BAB._RawPetData) ~= "table" then return end
  local wrapperLookup = {}
  for _, id in ipairs(wrapperIds or {}) do
    wrapperLookup[id] = true
  end

  for _, category in ipairs(BAB._RawPetData) do
    if category and category.id == categoryId and type(category.subgroups) == "table" then
      for index = #category.subgroups, 1, -1 do
        local subgroup = category.subgroups[index]
        if subgroup and wrapperLookup[subgroup.id] and type(subgroup.subgroups) == "table" and #subgroup.subgroups > 0 then
          table.remove(category.subgroups, index)
          for childIndex = #subgroup.subgroups, 1, -1 do
            table.insert(category.subgroups, index, subgroup.subgroups[childIndex])
          end
        end
      end
      break
    end
  end
end

if not (BAB.IsTBC and BAB.IsTBC()) then
  FlattenWrapperSubgroups("Raptors", { "NormalRaptors" })
  FlattenWrapperSubgroups("WindSerpents", { "NormalWindSerpents" })
  FlattenWrapperSubgroups("CarrionBirds", { "NormalCarrionBirds" })
end

local function PruneEmptySubgroups(subgroups)
  if type(subgroups) ~= "table" then return end

  for index = #subgroups, 1, -1 do
    local subgroup = subgroups[index]
    if subgroup and type(subgroup.subgroups) == "table" then
      PruneEmptySubgroups(subgroup.subgroups)
    end

    local hasSpecies = type(subgroup and subgroup.species) == "table" and #subgroup.species > 0
    local hasSubgroups = type(subgroup and subgroup.subgroups) == "table" and #subgroup.subgroups > 0
    if subgroup and not hasSpecies and not hasSubgroups then
      table.remove(subgroups, index)
    end
  end
end

local shouldPruneEmptySubgroups = not (BAB.IsTBC and BAB.IsTBC())

if shouldPruneEmptySubgroups then
  for index = #BAB._RawPetData, 1, -1 do
    local category = BAB._RawPetData[index]
    if category and type(category.subgroups) == "table" then
      PruneEmptySubgroups(category.subgroups)
      if #category.subgroups == 0 then
        table.remove(BAB._RawPetData, index)
      end
    end
  end
end

BAB._parsedSkillLevels = nil
