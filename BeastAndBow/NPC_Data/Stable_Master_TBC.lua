BeastAndBow = BeastAndBow or {}

-- Zones scaffold for TBC Stable Masters
-- Uses uiMapIDs. Keep aligned with BeastAndBow.EnglishMapNames and MapNames.
BeastAndBow.TBC_StableMasterZones = {
    -- New starter regions and cities
    1941, -- Eversong Woods
    1942, -- Ghostlands
    1943, -- Azuremyst Isle
    1950, -- Bloodmyst Isle
    1947, -- The Exodar
    1954, -- Silvermoon City
    1955, -- Shattrath City
    1957, -- Isle of Quel'Danas

    -- Outland zones
    1944, -- Hellfire Peninsula
    1946, -- Zangarmarsh
    1952, -- Terokkar Forest
    1951, -- Nagrand
    1949, -- Blade's Edge Mountains
    1953, -- Netherstorm
    1948, -- Shadowmoon Valley
}

-- TBC Stable Master NPCs
BeastAndBow.TBC_StableMasters = {
    -- Hellfire Peninsula (1944)
    { npc = "Huntsman Torf Angerhoof", mapIDs = {1944}, coords = { {x = 54.4, y = 41.0} }, faction = "Horde" },
    { npc = "Master Sergeant Lorin Thalmerok", mapIDs = {1944}, coords = { {x = 54.6, y = 62.6} }, faction = "Alliance" },

    -- Eversong Woods (1941)
    { npc = "Anathos", mapIDs = {1941}, coords = { {x = 47.6, y = 47.2} }, faction = "Horde" },

    -- Ghostlands (1942)
    { npc = "Paniar", mapIDs = {1942}, coords = { {x = 48.6, y = 31.2} }, faction = "Horde" },

    -- Azuremyst Isle (1943)
    { npc = "Esbina", mapIDs = {1943}, coords = { {x = 48.8, y = 50.0} }, faction = "Alliance" },

    -- Bloodmyst Isle (1950)
    { npc = "Astur", mapIDs = {1950}, coords = { {x = 55.0, y = 59.8} }, faction = "Alliance" },

    -- The Exodar (1947)
    { npc = "Arthaid", mapIDs = {1947}, coords = { {x = 60.2, y = 25.6} }, faction = "Alliance" },

    -- Silvermoon City (1954)
    { npc = "Shalenn", mapIDs = {1954}, coords = { {x = 82.8, y = 30.8} }, faction = "Horde" },

    -- Shattrath City (1955)
    { npc = "Ilthuril", mapIDs = {1955}, coords = { {x = 55.8, y = 79.8} }, faction = "Neutral" },
    { npc = "Oruhe", mapIDs = {1955}, coords = { {x = 28.6, y = 47.6} }, faction = "Neutral" },

    -- Isle of Quel'Danas (1957)
    { npc = "Seraphina Bloodheart", mapIDs = {1957}, coords = { {x = 50.6, y = 35.4} }, faction = "Neutral" },

    -- Zangarmarsh (1946)
    { npc = "Joraal", mapIDs = {1946}, coords = { {x = 67.6, y = 49.6} }, faction = "Alliance" },
    { npc = "Kameel Longstride", mapIDs = {1946}, coords = { {x = 78.8, y = 64.2} }, faction = "Neutral" },
    { npc = "Khalan", mapIDs = {1946}, coords = { {x = 31.8, y = 49.8} }, faction = "Horde" },

    -- Terokkar Forest (1952)
    { npc = "Leassian", mapIDs = {1952}, coords = { {x = 56.8, y = 53.8} }, faction = "Alliance" },
    { npc = "Trag", mapIDs = {1952}, coords = { {x = 49.4, y = 44.6} }, faction = "Horde" },

    -- Nagrand (1951)
    { npc = "Luftasia", mapIDs = {1951}, coords = { {x = 55.8, y = 74.6} }, faction = "Alliance" },
    { npc = "Wilda Bearmane", mapIDs = {1951}, coords = { {x = 56.8, y = 40.8} }, faction = "Horde" },

    -- Blade's Edge Mountains (1949)
    { npc = "Fiskal Shadowsong", mapIDs = {1949}, coords = { {x = 36.0, y = 64.6} }, faction = "Alliance" },
    { npc = "Lor", mapIDs = {1949}, coords = { {x = 53.6, y = 53.2} }, faction = "Horde" },
    { npc = "Ogrin", mapIDs = {1949}, coords = { {x = 75.8, y = 59.4} }, faction = "Horde" },
    { npc = "Skyguard Stable Master", mapIDs = {1949}, coords = { {x = 27.6, y = 52.6} }, faction = "Neutral" },

    -- Netherstorm (1953)
    { npc = "Liza Cutlerflix", mapIDs = {1953}, coords = { {x = 32.0, y = 64.8} }, faction = "Neutral" },

    -- Shadowmoon Valley (1948)
    { npc = "Crinn Pathfinder", mapIDs = {1948}, coords = { {x = 37.6, y = 56.0} }, faction = "Alliance" },
    { npc = "Gedrah", mapIDs = {1948}, coords = { {x = 29.2, y = 29.4} }, faction = "Horde" },
}
