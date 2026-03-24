BeastAndBow = BeastAndBow or {}

-- Zones scaffold for Stable Masters (no NPCs yet)
-- Uses uiMapIDs. Keep aligned with BeastAndBow.EnglishMapNames and MapNames.
BeastAndBow.StableMasterZones = {
    -- Capitals
    1519, -- Stormwind City
    1453, -- Stormwind Zone
    1537, -- Ironforge City
    1455, -- Ironforge Zone
    1657, -- Darnassus City
    1457, -- Darnassus Zone
    1637, -- Orgrimmar City
    1454, -- Orgrimmar Zone
    1638, -- Thunder Bluff City
    1456, -- Thunder Bluff Zone
    1497, -- Undercity City
    1458, -- Undercity Zone

    -- Starter regions
    1429, -- Elwynn Forest
    1411, -- Durotar
    1412, -- Mulgore
    1426, -- Dun Morogh
    1438, -- Teldrassil
    
    -- Other zones
    1413, -- The Barrens
    1425, -- The Hinterlands
    1430, -- Westfall
    1433, -- Redridge Mountains
    1434, -- Stranglethorn Vale
    1437, -- Wetlands
    1439, -- Darkshore
    1441, -- Ashenvale
    1443, -- Feralas
    1445, -- Dustwallow Marsh
    1446, -- Tanaris
    1452, -- Winterspring
}

-- Stable Master NPCs
BeastAndBow.StableMasters = {
    -- The Barrens (1413)
    { npc = "Sikwa", mapIDs = {1413}, coords = { {x = 51.6, y = 29.6} }, faction = "Horde" },
    { npc = "Reggifuz", mapIDs = {1413}, coords = { {x = 62.2, y = 39.2} }, faction = "Neutral" },
    -- Wetlands (1437)
    { npc = "Bethaine Flinthammer", mapIDs = {1437}, coords = { {x = 10.6, y = 59.6} }, faction = "Alliance" },
    -- Stranglethorn Vale (1434)
    { npc = "Grimestack", mapIDs = {1434}, coords = { {x = 27.2, y = 77.2} }, faction = "Neutral" },
    { npc = "Durik", mapIDs = {1434}, coords = { {x = 31.8, y = 29.4} }, faction = "Horde" },
    -- Darkshore (1439)
    { npc = "Jaelysia", mapIDs = {1439}, coords = { {x = 37.4, y = 44.2} }, faction = "Alliance" },
    -- Winterspring (1452)
    { npc = "Azzleby", mapIDs = {1452}, coords = { {x = 60.4, y = 38.0} }, faction = "Neutral" },
    -- Orgrimmar (1454, 1637)
    { npc = "Xon'cha", mapIDs = {1454, 1637}, coords = { {x = 70.0, y = 15.0} }, faction = "Horde" },
    -- Westfall (1430)
    { npc = "Kirk Maxwell", mapIDs = {1436}, coords = { {x = 53.0, y = 53.0} }, faction = "Alliance" },
    -- Tanaris (1446)
    { npc = "Laziphus", mapIDs = {1446}, coords = { {x = 52.2, y = 28.0} }, faction = "Neutral" },
    -- Ashenvale (1440)
    { npc = "Qeeju", mapIDs = {1440}, coords = { {x = 73.4, y = 61.0} }, faction = "Horde" },
    -- Undercity (1458, 1497)
    { npc = "Anya Maulray", mapIDs = {1458, 1497}, coords = { {x = 67.8, y = 38.6} }, faction = "Horde" },
    -- Stormwind (1453, 1519)
    { npc = "Jenova Stoneshield", mapIDs = {1453, 1519}, coords = { {x = 61.2, y = 17.2} }, faction = "Alliance" },
    -- Feralas (1443)
    { npc = "Shyrka Wolfrunner", mapIDs = {1443}, coords = { {x = 74.6, y = 43.4} }, faction = "Horde" },
    -- Redridge Mountains (1433)
    { npc = "Penny", mapIDs = {1433}, coords = { {x = 26.8, y = 46.6} }, faction = "Alliance" },
    -- Thunder Bluff (1456, 1638)
    { npc = "Bulrug", mapIDs = {1456, 1638}, coords = { {x = 45.0, y = 59.6} }, faction = "Horde" },
    -- Ironforge (1455, 1537)
    { npc = "Ulbrek Firehand", mapIDs = {1455, 1537}, coords = { {x = 69.6, y = 83.8} }, faction = "Alliance" },
    -- The Hinterlands (1425)
    { npc = "Huntsman Markhor", mapIDs = {1425}, coords = { {x = 79.0, y = 79.4} }, faction = "Horde" },
    -- Darnassus (1457, 1657)
    { npc = "Alassin", mapIDs = {1457, 1657}, coords = { {x = 39.8, y = 11.0} }, faction = "Alliance" },
    -- Dustwallow Marsh (1445)
    { npc = "Michael", mapIDs = {1445}, coords = { {x = 66.0, y = 45.6} }, faction = "Alliance" },
    -- Desolace (1443)
    { npc = "Aboda", mapIDs = {1443}, coords = { {x = 24.8, y = 68.8} }, faction = "Horde" },
    { npc = "Shelgrayn", mapIDs = {1443}, coords = { {x = 65.6, y = 7.8} }, faction = "Alliance" },
    -- Feralas (1443)
    { npc = "Antarius", mapIDs = {1443}, coords = { {x = 31.6, y = 43.2} }, faction = "Alliance" },
     -- Thousand Needles (400)
    { npc = "Awenasa", mapIDs = {1441}, coords = { {x = 45.8, y = 51.0} }, faction = "Horde" },
    -- Elwynn Forest (1429)
    { npc = "Erma", mapIDs = {1429}, coords = { {x = 42.8, y = 65.8} }, faction = "Alliance" },
    -- Stonetalon Mountains (1442)
    { npc = "Gereck", mapIDs = {1442}, coords = { {x = 47.8, y = 61.2} }, faction = "Horde" },
    -- Badlands (1418)
    { npc = "Greth", mapIDs = {1419}, coords = { {x = 3.8, y = 47.6} }, faction = "Horde" },
    -- Swamp of Sorrows (1435)
    { npc = "Hekkru", mapIDs = {1435}, coords = { {x = 45.6, y = 54.8} }, faction = "Horde" },
    -- The Barrens (1413)
    { npc = "Kelsuwa", mapIDs = {1413}, coords = { {x = 45.2, y = 58.6} }, faction = "Horde" },
    -- The Hinterlands (1425)
    { npc = "Killium Bouldertoe", mapIDs = {1425}, coords = { {x = 14.4, y = 45.6} }, faction = "Alliance" },
    -- Loch Modan (1432)
    { npc = "Lina Hearthstove", mapIDs = {1432}, coords = { {x = 34.6, y = 48.0} }, faction = "Alliance" },
    -- Ashenvale (1440)
    { npc = "Maluressian", mapIDs = {1440}, coords = { {x = 36.6, y = 50.4} }, faction = "Alliance" },
    -- Tirisfal Glades (1420)
    { npc = "Morganus", mapIDs = {1420}, coords = { {x = 60.0, y = 52.2} }, faction = "Horde" },
    -- Silverpine Forest (1421)
    { npc = "Sarah Goode", mapIDs = {1421}, coords = { {x = 43.6, y = 41.2} }, faction = "Horde" },
    -- Mulgore (1412)
    { npc = "Seikwa", mapIDs = {1412}, coords = { {x = 46.8, y = 60.2} }, faction = "Horde" },
    -- Teldrassil (1438)
    { npc = "Seriadne", mapIDs = {1438}, coords = { {x = 56.6, y = 59.6} }, faction = "Alliance" },
    -- Dun Morogh (1426)
    { npc = "Shelby Stoneflint", mapIDs = {1426}, coords = { {x = 47.0, y = 52.6} }, faction = "Alliance" },
    -- Durotar (1411)
    { npc = "Shoja'my", mapIDs = {1411}, coords = { {x = 52.0, y = 41.8} }, faction = "Horde" },
    -- Silithus (1451)
    { npc = "Squire Leoren Mal'derath", mapIDs = {1451}, coords = { {x = 49.2, y = 36.6} }, faction = "Neutral" },
    -- Duskwood (1431)
    { npc = "Steven Black", mapIDs = {1431}, coords = { {x = 74.0, y = 46.2} }, faction = "Alliance" },
    -- Stormwind (1453, 1519)
    { npc = "Sylista", mapIDs = {1453, 1519}, coords = { {x = 30.0, y = 50.4} }, faction = "Alliance" },
    -- Arathi Highlands (1417)
    { npc = "Tharlidun", mapIDs = {1417}, coords = { {x = 73.8, y = 33.2} }, faction = "Horde" },
    -- Hillsbrad Foothills (1424)
    { npc = "Theodore Mont Claire", mapIDs = {1424}, coords = { {x = 62.2, y = 19.8} }, faction = "Horde" },
    { npc = "Wesley", mapIDs = {1424}, coords = { {x = 50.4, y = 58.6} }, faction = "Alliance" },
}
