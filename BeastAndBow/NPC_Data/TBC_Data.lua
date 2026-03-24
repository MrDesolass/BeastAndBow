-- NPC_Data/TBC_Data.lua
-- The Burning Crusade spezifische Daten (Maps, NPCs, Koordinaten)
-- Diese Datei wird nur in TBC geladen

BeastAndBow = BeastAndBow or {}
local BAB = BeastAndBow

-- ============================================================================
-- TBC MAP IDs UND NAMEN
-- ============================================================================

BeastAndBow.TBC_MapIDs = {
    -- Outland (Parent Map)
    [1945] = "Outland",

    -- Neue Startgebiete und Städte (TBC)
    [1941] = "Eversong Woods",
    [1942] = "Ghostlands",
    [1943] = "Azuremyst Isle",
    [1950] = "Bloodmyst Isle",
    [1947] = "The Exodar",
    [1954] = "Silvermoon City",
    [1955] = "Shattrath City",
    [1957] = "Isle of Quel'Danas",
    
    -- Outland Zones
    [1944] = "Hellfire Peninsula",
    [1946] = "Zangarmarsh",
    [1952] = "Terokkar Forest",
    [1951] = "Nagrand",
    [1949] = "Blade's Edge Mountains",
    [1953] = "Netherstorm",
    [1948] = "Shadowmoon Valley",
}

-- TBC Map Namen (lokalisiert wenn möglich)
do
    local L = rawget(BeastAndBow, "L")
    local M = rawget(BeastAndBow, "MapNames") or {}
    
    if L then
        M[1945] = rawget(L, "MAP_OUTLAND") or "Outland"
        M[1941] = rawget(L, "MAP_EVERSONG_WOODS") or "Eversong Woods"
        M[1942] = rawget(L, "MAP_GHOSTLANDS") or "Ghostlands"
        M[1943] = rawget(L, "MAP_AZUREMYST_ISLE") or "Azuremyst Isle"
        M[1950] = rawget(L, "MAP_BLOODMYST_ISLE") or "Bloodmyst Isle"
        M[1947] = rawget(L, "MAP_THE_EXODAR") or "The Exodar"
        M[1954] = rawget(L, "MAP_SILVERMOON_CITY") or "Silvermoon City"
        M[1955] = rawget(L, "MAP_SHATTRATH_CITY") or "Shattrath City"
        M[1957] = rawget(L, "MAP_ISLE_OF_QUEL_DANAS") or "Isle of Quel'Danas"
        M[1944] = rawget(L, "MAP_HELLFIRE_PENINSULA") or "Hellfire Peninsula"
        M[1946] = rawget(L, "MAP_ZANGARMARSH") or "Zangarmarsh"
        M[1952] = rawget(L, "MAP_TEROKKAR_FOREST") or "Terokkar Forest"
        M[1951] = rawget(L, "MAP_NAGRAND") or "Nagrand"
        M[1949] = rawget(L, "MAP_BLADES_EDGE_MOUNTAINS") or "Blade's Edge Mountains"
        M[1953] = rawget(L, "MAP_NETHERSTORM") or "Netherstorm"
        M[1948] = rawget(L, "MAP_SHADOWMOON_VALLEY") or "Shadowmoon Valley"
    else
        M[1945] = "Outland"
        M[1941] = "Eversong Woods"
        M[1942] = "Ghostlands"
        M[1943] = "Azuremyst Isle"
        M[1950] = "Bloodmyst Isle"
        M[1947] = "The Exodar"
        M[1954] = "Silvermoon City"
        M[1955] = "Shattrath City"
        M[1957] = "Isle of Quel'Danas"
        M[1944] = "Hellfire Peninsula"
        M[1946] = "Zangarmarsh"
        M[1952] = "Terokkar Forest"
        M[1951] = "Nagrand"
        M[1949] = "Blade's Edge Mountains"
        M[1953] = "Netherstorm"
        M[1948] = "Shadowmoon Valley"
    end
    
    BeastAndBow.MapNames = M
end

-- TBC English Map Names
do
    local EN = rawget(BeastAndBow, "EnglishMapNames") or {}
    
    EN[1945] = "Outland"
    EN[1941] = "Eversong Woods"
    EN[1942] = "Ghostlands"
    EN[1943] = "Azuremyst Isle"
    EN[1950] = "Bloodmyst Isle"
    EN[1947] = "The Exodar"
    EN[1954] = "Silvermoon City"
    EN[1955] = "Shattrath City"
    EN[1957] = "Isle of Quel'Danas"
    EN[1944] = "Hellfire Peninsula"
    EN[1946] = "Zangarmarsh"
    EN[1952] = "Terokkar Forest"
    EN[1951] = "Nagrand"
    EN[1949] = "Blade's Edge Mountains"
    EN[1953] = "Netherstorm"
    EN[1948] = "Shadowmoon Valley"
    
    BeastAndBow.EnglishMapNames = EN
end

-- ============================================================================
-- TBC PFEIL-HÄNDLER (Arrow Vendors)
-- ============================================================================

-- Diese werden zu den bestehenden Arrow Vendors hinzugefügt
BeastAndBow.TBC_ArrowVendors = {
    -- Hellfire Peninsula (1944)
    { npc = "Floyd Pinkus", mapIDs = {1944}, coords = { {x = 56.6, y = 37.6} }, faction = "Horde" },
    { npc = "Hagash the Blind", mapIDs = {1944}, coords = { {x = 60.8, y = 81.6} }, faction = "Horde", onlyArrow = true },
    { npc = "Lukra", mapIDs = {1944}, coords = { {x = 61.4, y = 81.8} }, faction = "Horde" },
    { npc = "Mixie Farshot", mapIDs = {1944}, coords = { {x = 61.0, y = 81.6} }, faction = "Horde", onlyBullet = true },
    { npc = "Sid Limbardi", mapIDs = {1944}, coords = { {x = 54.2, y = 63.6} }, faction = "Alliance" },
    { npc = "Supply Master Broog", mapIDs = {1944}, coords = { {x = 87.8, y = 48.2} }, faction = "Horde" },
    { npc = "Supply Officer Isabel", mapIDs = {1944}, coords = { {x = 65.8, y = 43.6} }, faction = "Horde" },
    { npc = "Supply Officer Pestle", mapIDs = {1944}, coords = { {x = 78.6, y = 34.0} }, faction = "Alliance" },
    { npc = "Supply Officer Shandria", mapIDs = {1944}, coords = { {x = 70.8, y = 63.2} }, faction = "Alliance" },

    -- Eversong Woods (1941)
    { npc = "Areyn", mapIDs = {1941}, coords = { {x = 59.4, y = 62.6} }, faction = "Horde" },
    { npc = "Halis Dawnstrider", mapIDs = {1941}, coords = { {x = 44.0, y = 70.6} }, faction = "Horde" },
    { npc = "Marniel Amberlight", mapIDs = {1941}, coords = { {x = 43.6, y = 71.2} }, faction = "Horde" },
    { npc = "Sheri", mapIDs = {1941}, coords = { {x = 48.2, y = 47.2} }, faction = "Horde" },
    { npc = "Paelarin", mapIDs = {1941}, coords = { {x = 60.0, y = 62.6} }, faction = "Horde", onlyArrow = true },
    { npc = "Shara Sunwing", mapIDs = {1941}, coords = { {x = 38.6, y = 20.6} }, faction = "Horde", onlyArrow = true },

    -- Ghostlands (1942)
    { npc = "Narina", mapIDs = {1942}, coords = { {x = 72.0, y = 32.0} }, faction = "Horde" },
    { npc = "Quartermaster Lymel", mapIDs = {1942}, coords = { {x = 47.2, y = 29.6} }, faction = "Horde" },

    -- Azuremyst Isle (1943)
    { npc = "Logan Daniel", mapIDs = {1943}, coords = { {x = 46.2, y = 71.0} }, faction = "Alliance" },
    { npc = "Otonambusi", mapIDs = {1943}, coords = { {x = 48.0, y = 52.0} }, faction = "Alliance" },
    { npc = "Parkat Steelfur", mapIDs = {1943}, coords = { {x = 46.8, y = 22.0} }, faction = "Alliance" },
    { npc = "Ryosh", mapIDs = {1943}, coords = { {x = 79.2, y = 51.0} }, faction = "Alliance", onlyArrow = true },

    -- Bloodmyst Isle (1950)
    { npc = "Beega", mapIDs = {1950}, coords = { {x = 53.4, y = 56.6} }, faction = "Alliance", onlyArrow = true },
    { npc = "Meriaad", mapIDs = {1950}, coords = { {x = 55.2, y = 58.2} }, faction = "Alliance" },

    -- The Exodar (1947)
    { npc = "Avelii", mapIDs = {1947}, coords = { {x = 48.8, y = 90.0} }, faction = "Alliance", onlyArrow = true },
    { npc = "Muhaa", mapIDs = {1947}, coords = { {x = 45.6, y = 88.6} }, faction = "Alliance", onlyBullet = true },
    { npc = "Onnis", mapIDs = {1947}, coords = { {x = 53.2, y = 46.6} }, faction = "Alliance" },

    -- Silvermoon City (1954)
    { npc = "Celana", mapIDs = {1954}, coords = { {x = 86.0, y = 35.6} }, faction = "Horde", onlyArrow = true },
    { npc = "Mathaleron", mapIDs = {1954}, coords = { {x = 86.0, y = 39.6} }, faction = "Horde", onlyBullet = true },
    { npc = "Sathren Azuredawn", mapIDs = {1954}, coords = { {x = 54.6, y = 71.0} }, faction = "Horde" },

    -- Shattrath City (1955)
    { npc = "Eral", mapIDs = {1955}, coords = { {x = 61.8, y = 70.6} }, faction = "Neutral" },
    { npc = "Nalama the Merchant", mapIDs = {1955}, coords = { {x = 52.4, y = 80.6} }, faction = "Neutral" },

    -- Isle of Quel'Danas (1957)
    { npc = "Tyrael Flamekissed", mapIDs = {1957}, coords = { {x = 49.8, y = 39.6} }, faction = "Neutral" },

    -- Zangarmarsh (1946)
    { npc = "Innkeeper Coryth Stoktron", mapIDs = {1946}, coords = { {x = 78.6, y = 63.0} }, faction = "Neutral" },
    { npc = "Loolruna", mapIDs = {1946}, coords = { {x = 68.6, y = 50.2} }, faction = "Alliance" },
    { npc = "Sarinei Whitestar", mapIDs = {1946}, coords = { {x = 79.6, y = 63.8} }, faction = "Neutral" },
    { npc = "Zurai", mapIDs = {1946}, coords = { {x = 85.2, y = 54.6} }, faction = "Horde" },

    -- Terokkar Forest (1952)
    { npc = "\"Slim\"", mapIDs = {1952}, coords = { {x = 39.2, y = 58.8} }, faction = "Neutral" },
    { npc = "Dod'ss", mapIDs = {1952}, coords = { {x = 50.0, y = 45.6} }, faction = "Horde" },
    { npc = "Fabian Lanzonelli", mapIDs = {1952}, coords = { {x = 57.6, y = 53.6} }, faction = "Alliance" },
    { npc = "Ruogo", mapIDs = {1952}, coords = { {x = 37.6, y = 51.2} }, faction = "Neutral" },

    -- Nagrand (1951)
    { npc = "Banro", mapIDs = {1951}, coords = { {x = 41.6, y = 43.8} }, faction = "Alliance" },
    { npc = "Tasaldan", mapIDs = {1951}, coords = { {x = 41.6, y = 44.0} }, faction = "Horde" },
    { npc = "Matron Qualia", mapIDs = {1951}, coords = { {x = 55.4, y = 36.0} }, faction = "Horde" },

    -- Blade's Edge Mountains (1949)
    { npc = "Bembil Knockhammer", mapIDs = {1949}, coords = { {x = 61.2, y = 68.8} }, faction = "Alliance" },
    { npc = "Cymbre Starsong", mapIDs = {1949}, coords = { {x = 61.2, y = 39.2} }, faction = "Neutral" },
    { npc = "Karnaze", mapIDs = {1949}, coords = { {x = 51.4, y = 57.6} }, faction = "Horde" },
    { npc = "Krugash", mapIDs = {1949}, coords = { {x = 74.6, y = 61.4} }, faction = "Horde" },
    { npc = "Ogri'la Merchant", mapIDs = {1949}, coords = { {x = 27.8, y = 58.4} }, faction = "Neutral" },
    { npc = "Tanaide", mapIDs = {1949}, coords = { {x = 37.6, y = 65.8} }, faction = "Alliance" },

    -- Netherstorm (1953)
    { npc = "Dealer Digriz", mapIDs = {1953}, coords = { {x = 43.4, y = 35.0} }, faction = "Neutral" },
    { npc = "Dealer Dunar", mapIDs = {1953}, coords = { {x = 46.8, y = 56.4} }, faction = "Neutral" },
    { npc = "Dealer Hazzin", mapIDs = {1953}, coords = { {x = 58.4, y = 31.4} }, faction = "Neutral" },
    { npc = "Kerpow Blastwrench", mapIDs = {1953}, coords = { {x = 66.0, y = 67.2} }, faction = "Neutral", onlyBullet = true },
    { npc = "Kizzie", mapIDs = {1953}, coords = { {x = 33.0, y = 67.2} }, faction = "Neutral" },

    -- Shadowmoon Valley (1948)
    { npc = "Alorya", mapIDs = {1948}, coords = { {x = 55.4, y = 59.2} }, faction = "Neutral" },
    { npc = "Daggle Ironshaper", mapIDs = {1948}, coords = { {x = 36.8, y = 54.4} }, faction = "Alliance" },
    { npc = "Dorni", mapIDs = {1948}, coords = { {x = 61.0, y = 28.0} }, faction = "Neutral" },
    { npc = "Horus", mapIDs = {1948}, coords = { {x = 66.2, y = 87.0} }, faction = "Neutral" },
    { npc = "Korthul", mapIDs = {1948}, coords = { {x = 30.0, y = 31.0} }, faction = "Horde" },
    { npc = "Salle Sunforge", mapIDs = {1948}, coords = { {x = 36.2, y = 55.6} }, faction = "Alliance" },
    { npc = "Trop Rendlimb", mapIDs = {1948}, coords = { {x = 29.2, y = 26.2} }, faction = "Horde" },
}

-- ============================================================================
-- TBC FLEISCH-HÄNDLER (Meat Vendors)
-- ============================================================================

BeastAndBow.TBC_MeatVendors = {
    -- Hellfire Peninsula (1944)
    { npc = "Caregiver Ophera Windfury", mapIDs = {1944}, coords = { {x = 23.4, y = 36.6} }, faction = "Alliance" },
    { npc = "Cookie One-Eye", mapIDs = {1944}, coords = { {x = 54.6, y = 41.0} }, faction = "Horde" },
    { npc = "Floyd Pinkus", mapIDs = {1944}, coords = { {x = 56.6, y = 37.6} }, faction = "Horde" },
    { npc = "Innkeeper Bazil Olof'tazun", mapIDs = {1944}, coords = { {x = 26.8, y = 59.6} }, faction = "Horde" },
    { npc = "Mondul", mapIDs = {1944}, coords = { {x = 61.6, y = 81.4} }, faction = "Horde" },
    { npc = "Provisioner Anir", mapIDs = {1944}, coords = { {x = 24.0, y = 40.2} }, faction = "Alliance" },
    { npc = "Sid Limbardi", mapIDs = {1944}, coords = { {x = 54.2, y = 63.6} }, faction = "Alliance" },
    { npc = "Supply Officer Isabel", mapIDs = {1944}, coords = { {x = 65.8, y = 43.6} }, faction = "Horde" },
    { npc = "Supply Officer Pestle", mapIDs = {1944}, coords = { {x = 78.6, y = 34.0} }, faction = "Alliance" },
    { npc = "Supply Officer Shandria", mapIDs = {1944}, coords = { {x = 70.8, y = 63.2} }, faction = "Alliance" },

    -- Eversong Woods (1941)
    { npc = "Marniel Amberlight", mapIDs = {1941}, coords = { {x = 43.6, y = 71.2} }, faction = "Horde" },
    { npc = "Zalene Firstlight", mapIDs = {1941}, coords = { {x = 60.4, y = 62.6} }, faction = "Horde" },

    -- Ghostlands (1942)
    { npc = "Heron Skygaze", mapIDs = {1942}, coords = { {x = 72.2, y = 32.2} }, faction = "Horde" },
    { npc = "Kurzel", mapIDs = {1942}, coords = { {x = 69.8, y = 67.6} }, faction = "Horde" },

    -- Bloodmyst Isle (1950)
    { npc = "Caregiver Topher Loaal", mapIDs = {1950}, coords = { {x = 55.8, y = 59.8} }, faction = "Alliance" },

    -- The Exodar (1947)
    { npc = "Caregiver Breel", mapIDs = {1947}, coords = { {x = 59.6, y = 20.0} }, faction = "Alliance" },

    -- Silvermoon City (1954)
    { npc = "Innkeeper Jovia", mapIDs = {1954}, coords = { {x = 68.0, y = 74.0} }, faction = "Horde" },
    { npc = "Innkeeper Velandra", mapIDs = {1954}, coords = { {x = 79.8, y = 57.2} }, faction = "Horde" },

    -- Shattrath City (1955)
    { npc = "Brendan Turner", mapIDs = {1955}, coords = { {x = 60.6, y = 69.6} }, faction = "Neutral" },
    { npc = "Shaarubo", mapIDs = {1955}, coords = { {x = 75.2, y = 33.6} }, faction = "Neutral" },

    -- Isle of Quel'Danas (1957)
    { npc = "Caregiver Inaara", mapIDs = {1957}, coords = { {x = 51.2, y = 33.8} }, faction = "Neutral" },

    -- Zangarmarsh (1946)
    { npc = "Innkeeper Kerp", mapIDs = {1946}, coords = { {x = 41.8, y = 26.2} }, faction = "Alliance" },

    -- Terokkar Forest (1952)
    { npc = "\"Slim\"", mapIDs = {1952}, coords = { {x = 39.2, y = 58.8} }, faction = "Neutral" },
    { npc = "Innkeeper Grilka", mapIDs = {1952}, coords = { {x = 48.8, y = 45.0} }, faction = "Horde" },
    { npc = "Morula", mapIDs = {1952}, coords = { {x = 37.6, y = 51.2} }, faction = "Neutral" },
    { npc = "Supply Officer Mills", mapIDs = {1952}, coords = { {x = 55.8, y = 53.0} }, faction = "Alliance" },

    -- Nagrand (1951)
    { npc = "Caregiver Isel", mapIDs = {1951}, coords = { {x = 54.2, y = 76.0} }, faction = "Alliance" },
    { npc = "Matron Tikkit", mapIDs = {1951}, coords = { {x = 56.6, y = 34.6} }, faction = "Horde" },
    { npc = "Nancila", mapIDs = {1951}, coords = { {x = 55.2, y = 70.6} }, faction = "Alliance" },
    { npc = "Nula the Butcher", mapIDs = {1951}, coords = { {x = 58.0, y = 35.6} }, faction = "Horde" },

    -- Blade's Edge Mountains (1949)
    { npc = "Braagor", mapIDs = {1949}, coords = { {x = 76.0, y = 60.2} }, faction = "Horde" },
    { npc = "Gholah", mapIDs = {1949}, coords = { {x = 53.2, y = 55.4} }, faction = "Horde" },
    { npc = "Ogri'la Grubgiver", mapIDs = {1949}, coords = { {x = 27.8, y = 58.2} }, faction = "Neutral" },

    -- Netherstorm (1953)
    { npc = "Gant", mapIDs = {1953}, coords = { {x = 32.6, y = 64.0} }, faction = "Neutral" },

    -- Shadowmoon Valley (1948)
    { npc = "Dreg Cloudsweeper", mapIDs = {1948}, coords = { {x = 37.0, y = 58.2} }, faction = "Alliance" },
    { npc = "Horus", mapIDs = {1948}, coords = { {x = 66.2, y = 87.0} }, faction = "Neutral" },
    { npc = "Nanomah", mapIDs = {1948}, coords = { {x = 62.6, y = 28.2} }, faction = "Neutral" },
    { npc = "Targrom", mapIDs = {1948}, coords = { {x = 28.2, y = 27.0} }, faction = "Horde" },
}

-- ============================================================================
-- TBC FISCH-HÄNDLER (Fish Vendors)
-- ============================================================================

BeastAndBow.TBC_FishVendors = {
    -- Bloodmyst Isle (1950)
    { npc = "Caregiver Topher Loaal", mapIDs = {1950}, coords = { {x = 55.8, y = 59.8} }, faction = "Alliance" },

    -- The Exodar (1947)
    { npc = "Caregiver Breel", mapIDs = {1947}, coords = { {x = 59.6, y = 20.0} }, faction = "Alliance" },

    -- Silvermoon City (1954)
    { npc = "Innkeeper Velandra", mapIDs = {1954}, coords = { {x = 79.8, y = 57.2} }, faction = "Horde" },

    -- Shattrath City (1955)
    { npc = "Oloraak", mapIDs = {1955}, coords = { {x = 58.6, y = 15.6} }, faction = "Neutral" },

    -- Isle of Quel'Danas (1957)
    { npc = "Caregiver Inaara", mapIDs = {1957}, coords = { {x = 51.2, y = 33.8} }, faction = "Neutral" },

    -- Terokkar Forest (1952)
    { npc = "Innkeeper Biribi", mapIDs = {1952}, coords = { {x = 56.6, y = 53.2} }, faction = "Alliance" },

    -- Blade's Edge Mountains (1949)
    { npc = "Ogri'la Grubgiver", mapIDs = {1949}, coords = { {x = 27.8, y = 58.2} }, faction = "Neutral" },
    { npc = "Threlc", mapIDs = {1949}, coords = { {x = 52.0, y = 57.2} }, faction = "Horde" },
}

-- ============================================================================
-- TBC OBST-HÄNDLER (Fruit Vendors)
-- ============================================================================

BeastAndBow.TBC_FruitVendors = {
    -- Hellfire Peninsula (1944)
    { npc = "Provisioner Anir", mapIDs = {1944}, coords = { {x = 24.0, y = 40.2} }, faction = "Alliance" },

    -- Eversong Woods (1941)
    { npc = "Zalene Firstlight", mapIDs = {1941}, coords = { {x = 60.4, y = 62.6} }, faction = "Horde" },

    -- Ghostlands (1942)
    { npc = "Heron Skygaze", mapIDs = {1942}, coords = { {x = 72.2, y = 32.2} }, faction = "Horde" },
    { npc = "Innkeeper Kalarin", mapIDs = {1942}, coords = { {x = 48.8, y = 32.4} }, faction = "Horde" },

    -- Bloodmyst Isle (1950)
    { npc = "Little Azimi", mapIDs = {1950}, coords = { {x = 63.0, y = 87.6} }, faction = "Alliance" },

    -- Silvermoon City (1954)
    { npc = "Innkeeper Jovia", mapIDs = {1954}, coords = { {x = 68.0, y = 74.0} }, faction = "Horde" },

    -- Shattrath City (1955)
    { npc = "Garul", mapIDs = {1955}, coords = { {x = 27.6, y = 49.6} }, faction = "Neutral" },
    { npc = "Granny Smith", mapIDs = {1955}, coords = { {x = 64.6, y = 68.8} }, faction = "Neutral" },
    { npc = "Innkeeper Haelthol", mapIDs = {1955}, coords = { {x = 56.2, y = 81.6} }, faction = "Neutral" },

    -- Isle of Quel'Danas (1957)
    { npc = "Caregiver Inaara", mapIDs = {1957}, coords = { {x = 51.2, y = 33.8} }, faction = "Neutral" },

    -- Terokkar Forest (1952)
    { npc = "Innkeeper Grilka", mapIDs = {1952}, coords = { {x = 48.8, y = 45.0} }, faction = "Horde" },

    -- Nagrand (1951)
    { npc = "Cendrii", mapIDs = {1951}, coords = { {x = 42.0, y = 43.0} }, faction = "Alliance" },
    { npc = "Embelar", mapIDs = {1951}, coords = { {x = 42.0, y = 43.0} }, faction = "Horde" },

    -- Blade's Edge Mountains (1949)
    { npc = "Ogri'la Grubgiver", mapIDs = {1949}, coords = { {x = 27.8, y = 58.2} }, faction = "Neutral" },
    { npc = "Old Orok", mapIDs = {1949}, coords = { {x = 53.0, y = 54.4} }, faction = "Horde" },

    -- Netherstorm (1953)
    { npc = "Gant", mapIDs = {1953}, coords = { {x = 32.6, y = 64.0} }, faction = "Neutral" },

    -- Shadowmoon Valley (1948)
    { npc = "Caretaker Aluuro", mapIDs = {1948}, coords = { {x = 61.0, y = 28.2} }, faction = "Neutral" },
    { npc = "Roldemar", mapIDs = {1948}, coords = { {x = 56.2, y = 59.8} }, faction = "Neutral" },
}

-- ============================================================================
-- TBC PILZ-HÄNDLER (Mushroom Vendors)
-- ============================================================================

BeastAndBow.TBC_MushroomVendors = {
    -- Ghostlands (1942)
    { npc = "Heron Skygaze", mapIDs = {1942}, coords = { {x = 72.2, y = 32.2} }, faction = "Horde" },
    { npc = "Kurzel", mapIDs = {1942}, coords = { {x = 69.8, y = 67.6} }, faction = "Horde" },

    -- Blade's Edge Mountains (1949)
    { npc = "Ogri'la Grubgiver", mapIDs = {1949}, coords = { {x = 27.8, y = 58.2} }, faction = "Neutral" },
    { npc = "Old Orok", mapIDs = {1949}, coords = { {x = 53.0, y = 54.4} }, faction = "Horde" },
}

-- ============================================================================
-- TBC BROT-HÄNDLER (Bread Vendors)
-- ============================================================================

BeastAndBow.TBC_BreadVendors = {
    -- Eversong Woods (1941)
    { npc = "Innkeeper Delaniel", mapIDs = {1941}, coords = { {x = 48.0, y = 47.6} }, faction = "Horde" },

    -- The Exodar (1947)
    { npc = "Caregiver Breel", mapIDs = {1947}, coords = { {x = 59.6, y = 20.0} }, faction = "Alliance" },

    -- Silvermoon City (1954)
    { npc = "Innkeeper Jovia", mapIDs = {1954}, coords = { {x = 68.0, y = 74.0} }, faction = "Horde" },

    -- Zangarmarsh (1946)
    { npc = "Caregiver Abidaar", mapIDs = {1946}, coords = { {x = 67.2, y = 49.0} }, faction = "Alliance" },
    { npc = "Merajit", mapIDs = {1946}, coords = { {x = 30.6, y = 50.8} }, faction = "Horde" },

    -- Terokkar Forest (1952)
    { npc = "Morula", mapIDs = {1952}, coords = { {x = 37.6, y = 51.2} }, faction = "Neutral" },
    { npc = "Supply Officer Mills", mapIDs = {1952}, coords = { {x = 55.8, y = 53.0} }, faction = "Alliance" },

    -- Blade's Edge Mountains (1949)
    { npc = "Innkeeper Shaunessy", mapIDs = {1949}, coords = { {x = 35.8, y = 63.8} }, faction = "Alliance" },

    -- Shadowmoon Valley (1948)
    { npc = "Caretaker Aluuro", mapIDs = {1948}, coords = { {x = 61.0, y = 28.2} }, faction = "Neutral" },
    { npc = "Dreg Cloudsweeper", mapIDs = {1948}, coords = { {x = 37.0, y = 58.2} }, faction = "Alliance" },
    { npc = "Feranin", mapIDs = {1948}, coords = { {x = 55.8, y = 58.2} }, faction = "Neutral" },
    { npc = "Roldemar", mapIDs = {1948}, coords = { {x = 56.2, y = 59.8} }, faction = "Neutral" },
    { npc = "Targrom", mapIDs = {1948}, coords = { {x = 28.2, y = 27.0} }, faction = "Horde" },
}

-- ============================================================================
-- TBC KÄSE-HÄNDLER (Cheese Vendors)
-- ============================================================================

BeastAndBow.TBC_CheeseVendors = {
    -- Eversong Woods (1941)
    { npc = "Kyrenna", mapIDs = {1941}, coords = { {x = 47.6, y = 45.6} }, faction = "Horde" },

    -- Azuremyst Isle (1943)
    { npc = "Caregiver Chellan", mapIDs = {1943}, coords = { {x = 48.4, y = 49.2} }, faction = "Alliance" },

    -- Silvermoon City (1954)
    { npc = "Innkeeper Jovia", mapIDs = {1954}, coords = { {x = 68.0, y = 74.0} }, faction = "Horde" },

    -- Shattrath City (1955)
    { npc = "Innkeeper Haelthol", mapIDs = {1955}, coords = { {x = 56.2, y = 81.6} }, faction = "Neutral" },

    -- Terokkar Forest (1952)
    { npc = "Innkeeper Biribi", mapIDs = {1952}, coords = { {x = 56.6, y = 53.2} }, faction = "Alliance" },

    -- Blade's Edge Mountains (1949)
    { npc = "Fizit \"Doc\" Clocktock", mapIDs = {1949}, coords = { {x = 60.8, y = 68.2} }, faction = "Alliance" },
    { npc = "Ogri'la Grubgiver", mapIDs = {1949}, coords = { {x = 27.8, y = 58.2} }, faction = "Neutral" },
    { npc = "Xerintha Ravenoak", mapIDs = {1949}, coords = { {x = 62.6, y = 40.2} }, faction = "Neutral" },

    -- Shadowmoon Valley (1948)
    { npc = "Caretaker Aluuro", mapIDs = {1948}, coords = { {x = 61.0, y = 28.2} }, faction = "Neutral" },
    { npc = "Roldemar", mapIDs = {1948}, coords = { {x = 56.2, y = 59.8} }, faction = "Neutral" },
}

-- TBC Stable Masters, Hunter Trainers and Pet Trainers live in:
-- NPC_Data/Stable_Master_TBC.lua
-- NPC_Data/Hunter_Trainer_TBC.lua
-- NPC_Data/Pet_Trainer_TBC.lua

-- ============================================================================
-- INTEGRATION FUNCTION
-- ============================================================================
-- Diese Funktion fügt TBC-Daten zu den bestehenden Classic-Daten hinzu

function BeastAndBow.MergeTBCData()
    if BAB.IsTBC() then
        -- Merge Arrow Vendors
        if BeastAndBow.TBC_ArrowVendors then
            BeastAndBow.ArrowVendors = BeastAndBow.ArrowVendors or {}
            for _, vendor in ipairs(BeastAndBow.TBC_ArrowVendors) do
                table.insert(BeastAndBow.ArrowVendors, vendor)
            end
        end
        
        -- Merge Meat Vendors
        if BeastAndBow.TBC_MeatVendors then
            BeastAndBow.MeatVendors = BeastAndBow.MeatVendors or {}
            for _, vendor in ipairs(BeastAndBow.TBC_MeatVendors) do
                table.insert(BeastAndBow.MeatVendors, vendor)
            end
        end

        -- Merge Fish Vendors
        if BeastAndBow.TBC_FishVendors then
            BeastAndBow.FishVendors = BeastAndBow.FishVendors or {}
            for _, vendor in ipairs(BeastAndBow.TBC_FishVendors) do
                table.insert(BeastAndBow.FishVendors, vendor)
            end
        end

        -- Merge Fruit Vendors
        if BeastAndBow.TBC_FruitVendors then
            BeastAndBow.FruitVendors = BeastAndBow.FruitVendors or {}
            for _, vendor in ipairs(BeastAndBow.TBC_FruitVendors) do
                table.insert(BeastAndBow.FruitVendors, vendor)
            end
        end

        -- Merge Bread Vendors
        if BeastAndBow.TBC_BreadVendors then
            BeastAndBow.BreadVendors = BeastAndBow.BreadVendors or {}
            for _, vendor in ipairs(BeastAndBow.TBC_BreadVendors) do
                table.insert(BeastAndBow.BreadVendors, vendor)
            end
        end

        -- Merge Cheese Vendors
        if BeastAndBow.TBC_CheeseVendors then
            BeastAndBow.CheeseVendors = BeastAndBow.CheeseVendors or {}
            for _, vendor in ipairs(BeastAndBow.TBC_CheeseVendors) do
                table.insert(BeastAndBow.CheeseVendors, vendor)
            end
        end

        -- Merge Mushroom Vendors
        if BeastAndBow.TBC_MushroomVendors then
            BeastAndBow.MushroomVendors = BeastAndBow.MushroomVendors or {}
            for _, vendor in ipairs(BeastAndBow.TBC_MushroomVendors) do
                table.insert(BeastAndBow.MushroomVendors, vendor)
            end
        end

        -- Merge Stable Master Zones
        if BeastAndBow.TBC_StableMasterZones then
            BeastAndBow.StableMasterZones = BeastAndBow.StableMasterZones or {}
            for _, mapId in ipairs(BeastAndBow.TBC_StableMasterZones) do
                table.insert(BeastAndBow.StableMasterZones, mapId)
            end
        end
        
        -- Merge Stable Masters
        if BeastAndBow.TBC_StableMasters then
            BeastAndBow.StableMasters = BeastAndBow.StableMasters or {}
            for _, master in ipairs(BeastAndBow.TBC_StableMasters) do
                table.insert(BeastAndBow.StableMasters, master)
            end
        end
        
        -- Merge Hunter Trainers
        if BeastAndBow.TBC_TrainerVendors then
            BeastAndBow.TrainerVendors = BeastAndBow.TrainerVendors or {}
            for _, trainer in ipairs(BeastAndBow.TBC_TrainerVendors) do
                table.insert(BeastAndBow.TrainerVendors, trainer)
            end
        end

        -- Merge Pet Trainers
        if BeastAndBow.TBC_PetTrainers then
            BeastAndBow.PetTrainers = BeastAndBow.PetTrainers or {}
            for _, trainer in ipairs(BeastAndBow.TBC_PetTrainers) do
                table.insert(BeastAndBow.PetTrainers, trainer)
            end
        end
    end
end

-- Automatisch aufrufen wenn in TBC
if BeastAndBow.IsTBC and BeastAndBow.IsTBC() then
    BeastAndBow.MergeTBCData()
end
