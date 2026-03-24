BeastAndBow = BeastAndBow or {}

-- Englische Kartennamen für das Navigationssystem (Classic Era benötigt englische Namen)
BeastAndBow.EnglishMapNames = {
    -- Eastern Kingdoms
    [1415] = "Eastern Kingdoms",
    [1416] = "Alterac Mountains",
    [1417] = "Arathi Highlands",
    [1418] = "Badlands",
    [1419] = "Blasted Lands",
    [1420] = "Tirisfal Glades",
    [1421] = "Silverpine Forest",
    [1422] = "Western Plaguelands",
    [1423] = "Eastern Plaguelands",
    [1424] = "Hillsbrad Foothills",
    [1425] = "The Hinterlands",
    [1426] = "Dun Morogh",
    [1427] = "Searing Gorge",
    [1428] = "Burning Steppes",
    [1429] = "Elwynn Forest",
    [1430] = "Deadwind Pass",
    [1431] = "Duskwood",
    [1432] = "Loch Modan",
    [1433] = "Redridge Mountains",
    [1434] = "Stranglethorn Vale",
    [1435] = "Swamp of Sorrows",
    [1436] = "Westfall",
    [1437] = "Wetlands",
    [1453] = "Stormwind City",
    [1455] = "Ironforge",
    [1458] = "Undercity",
    [1459] = "Alterac Valley",
    [1519] = "Stormwind City", -- Instanz
    [1537] = "Ironforge", -- Instanz
    [1497] = "Undercity", -- Instanz

    -- Kalimdor
    [1414] = "Kalimdor",
    [1411] = "Durotar",
    [1412] = "Mulgore",
    [1413] = "The Barrens",
    [1438] = "Teldrassil",
    [1439] = "Darkshore",
    [1440] = "Ashenvale",
    [1441] = "Thousand Needles",
    [400] = "Thousand Needles", -- Sub-zone ID, keep for compatibility
    [1442] = "Stonetalon Mountains",
    [1443] = "Desolace",
    [1444] = "Feralas",
    [357] = "Feralas", -- Instanz ID, keep for compatibility
    [1445] = "Dustwallow Marsh",
    [1446] = "Tanaris",
    [1447] = "Azshara",
    [1448] = "Felwood",
    [1449] = "Un'Goro Crater",
    [1450] = "Moonglade",
    [1451] = "Silithus",
    [1452] = "Winterspring",
    [1454] = "Orgrimmar",
    [1456] = "Thunder Bluff",
    [1457] = "Darnassus",
    [1637] = "Orgrimmar", -- Instanz
    [1638] = "Thunder Bluff", -- Instanz
    [1657] = "Darnassus", -- Instanz
}

-- Build MapNames eagerly to avoid metatable recursion issues
do
    local L = rawget(BeastAndBow, "L")
    local M = {}
    if L then
        -- Kalimdor
        M[1411] = rawget(L, "MAP_DUROTAR")
        M[1412] = rawget(L, "MAP_MULGORE")
        M[1413] = rawget(L, "MAP_THE_BARRENS")
        M[1438] = rawget(L, "MAP_TELDRASSIL")
        -- 1439 is the Auberdine/Darkshore coastal sub-map on Era; label accordingly
        M[1439] = rawget(L, "MAP_DARKSHORE")
        M[1440] = rawget(L, "MAP_ASHENVALE")
        M[1441] = rawget(L, "MAP_THOUSAND_NEEDLES")
        M[1442] = rawget(L, "MAP_STONETALON_MOUNTAINS")
        M[1443] = rawget(L, "MAP_DESOLACE")
        M[1444] = rawget(L, "MAP_FERALAS")
        M[1445] = rawget(L, "MAP_DUSTWALLOW_MARSH")
        M[1446] = rawget(L, "MAP_TANARIS")
        M[1447] = rawget(L, "MAP_AZSHARA")
        M[1448] = rawget(L, "MAP_FELWOOD")
        M[1449] = rawget(L, "MAP_UNGORO_CRATER")
        M[1450] = rawget(L, "MAP_MOONGLADE")
        M[1451] = rawget(L, "MAP_SILITHUS")
        M[1452] = rawget(L, "MAP_WINTERSPRING")
        M[1454] = rawget(L, "MAP_ORGRIMMAR")
        M[1456] = rawget(L, "MAP_THUNDER_BLUFF")
        M[1637] = rawget(L, "MAP_ORGRIMMAR_CITY")
        M[1638] = rawget(L, "MAP_THUNDER_BLUFF_CITY")
        M[400]  = rawget(L, "MAP_THOUSAND_NEEDLES")

        -- Östliche Königreiche
        M[1429] = rawget(L, "MAP_ELWYNN_FOREST")
        M[1430] = rawget(L, "MAP_DEADWIND_PASS")
        M[1431] = rawget(L, "MAP_DUSKWOOD")
        M[1432] = rawget(L, "MAP_LOCH_MODAN")
        M[1433] = rawget(L, "MAP_REDRIDGE_MOUNTAINS")
        M[1434] = rawget(L, "MAP_STRANGLETHORN_VALE")
        M[1435] = rawget(L, "MAP_SWAMP_OF_SORROWS")
        M[1436] = rawget(L, "MAP_WESTFALL")
        M[1437] = rawget(L, "MAP_WETLANDS")
        M[1417] = rawget(L, "MAP_ARATHI_HIGHLANDS")
        M[1424] = rawget(L, "MAP_HILLSBRAD_FOOTHILLS")
        M[1416] = rawget(L, "MAP_ALTERAC_MOUNTAINS")
        M[1425] = rawget(L, "MAP_THE_HINTERLANDS")
        M[1420] = rawget(L, "MAP_TIRISFAL_GLADES")
        M[1421] = rawget(L, "MAP_SILVERPINE_FOREST")
        M[1422] = rawget(L, "MAP_WESTERN_PLAGUELANDS")
        M[1423] = rawget(L, "MAP_EASTERN_PLAGUELANDS")
        M[1426] = rawget(L, "MAP_DUN_MOROGH")
        M[1427] = rawget(L, "MAP_SEARING_GORGE")
        M[1428] = rawget(L, "MAP_BURNING_STEPPES")
        M[1418] = rawget(L, "MAP_BADLANDS")
        M[1453] = rawget(L, "MAP_STORMWIND")
        M[1455] = rawget(L, "MAP_IRONFORGE")
        M[1458] = rawget(L, "MAP_UNDERCITY")
        M[1519] = rawget(L, "MAP_STORMWIND_CITY")
        M[1537] = rawget(L, "MAP_IRONFORGE_CITY")
        M[1497] = rawget(L, "MAP_UNDERCITY_CITY")
        M[1657] = rawget(L, "MAP_DARNASSUS_CITY")
        -- Some clients report Darnassus as 1457; add mapping for clarity
        M[1457] = rawget(L, "MAP_DARNASSUS")
    end
    BeastAndBow.MapNames = M
end

BeastAndBow.ArrowVendors = {
    -- Dämmerwald (1431)
    { npc = "Mabel Solaj", mapIDs = {1431}, coords = { {x = 74.0, y = 44.8} }, faction = "Alliance" },
    { npc = "Avette Felwood", mapIDs = {1431}, coords = { {x = 73.0, y = 44.4} }, faction = "Alliance", onlyArrow = true },
    -- Westfall (1436)
    { npc = "Quartermaster Lewis", mapIDs = {1436}, coords = { {x = 56.8, y = 47.2} }, faction = "Alliance" },
    { npc = "William MacGregor", mapIDs = {1436}, coords = { {x = 57.6, y = 53.8} }, faction = "Alliance", onlyArrow = true },
    -- Schlingendorntal (1434)
    { npc = "Corporal Bluth", mapIDs = {1434}, coords = { {x = 38.0, y = 3.0} }, faction = "Alliance" },
    { npc = "Uthok", mapIDs = {1434}, coords = { {x = 31.6, y = 28.0} }, faction = "Horde" },
    { npc = "Haren Kanmae", mapIDs = {1434}, coords = { {x = 28.3, y = 74.6} }, faction = "Alliance", onlyArrow = true },
    -- Rotkammgebirge (1433)
    { npc = "Kimberly Hiett", mapIDs = {1433}, coords = { {x = 27.0, y = 45.6} }, faction = "Alliance", onlyArrow = true },
    { npc = "Henry Chapal", mapIDs = {1433}, coords = { {x = 23.8, y = 41.4} }, faction = "Alliance", onlyBullet = true },
    { npc = "Lindsay Ashlock", mapIDs = {1433}, coords = { {x = 28.8, y = 47.6} }, faction = "Alliance" },
    -- Wald von Elwynn (1429)
    { npc = "Brog Hamfist", mapIDs = {1429}, coords = { {x = 43.8, y = 66.0} }, faction = "Alliance" },
    { npc = "Brother Danil", mapIDs = {1429}, coords = { {x = 47.6, y = 41.6} }, faction = "Alliance" },
    { npc = "Drake Lindgren", mapIDs = {1429}, coords = { {x = 83.2, y = 66.6} }, faction = "Alliance" },
    { npc = "Rallic Finn", mapIDs = {1429}, coords = { {x = 83.2, y = 66.0} }, faction = "Alliance", onlyArrow = true },
    -- Stormwind (nur Stadt-ID 1519)
    { npc = "Thurman Mullby", mapIDs = {1519, 1453}, coords = { {x = 58.2, y = 61.4} }, faction = "Alliance" },
    { npc = "Frederick Stover", mapIDs = {1519, 1453}, coords = { {x = 50.2, y = 57.6} }, faction = "Alliance", onlyArrow = true },
    { npc = "Lina Stover", mapIDs = {1519, 1453}, coords = { {x = 50.6, y = 57.6} }, faction = "Alliance" },
    { npc = "Thulman Flintcrag", mapIDs = {1519, 1453}, coords = { {x = 54.6, y = 15.4} }, faction = "Alliance", onlyBullet = true },
    -- Sumpfland (1437)
    
    { npc = "Edwina Monzor", mapIDs = {1437}, coords = { {x = 11.0, y = 58.6} }, faction = "Alliance", onlyArrow = true },
    { npc = "Naela Trance", mapIDs = {1437}, coords = { {x = 11.2, y = 58.6} }, faction = "Alliance", onlyArrow = true },
    { npc = "Gruham Rumdnul", mapIDs = {1437}, coords = { {x = 12.0, y = 57.8} }, faction = "Alliance" },
    { npc = "Murndan Derth", mapIDs = {1437}, coords = { {x = 11.4, y = 59.6} }, faction = "Alliance", onlyBullet = true },
    -- Loch Modan (1432)
    { npc = "Yanni Stoutheart", mapIDs = {1432}, coords = { {x = 34.8, y = 48.6} }, faction = "Alliance" },
    { npc = "Cliff Hadin", mapIDs = {1432}, coords = { {x = 83.0, y = 63.0} }, faction = "Alliance", onlyArrow = true },
    { npc = "Irene Sureshot", mapIDs = {1432}, coords = { {x = 83.0, y = 63.6} }, faction = "Alliance", onlyBullet = true },
    { npc = "Xandar Goodbeard", mapIDs = {1432}, coords = { {x = 82.6, y = 63.6} }, faction = "Alliance" },
    { npc = "Vrok Blunderblast", mapIDs = {1432}, coords = { {x = 35.8, y = 43.6} }, faction = "Alliance", onlyBullet = true },
    -- Winterspring (1452)
    { npc = "Natheril Raincaller", mapIDs = {1452}, coords = { {x = 51.4, y = 30.8} }, faction = "Alliance" },
    { npc = "Wixxrak", mapIDs = {1452}, coords = { {x = 61.6, y = 38.0} }, faction = "Neutral", onlyBullet = true },
    -- Silberwald (1421)
    { npc = "Edwin Harly", mapIDs = {1421}, coords = { {x = 44.0, y = 40.0} }, faction = "Horde" },
    { npc = "Nadia Vernon", mapIDs = {1421}, coords = { {x = 45.0, y = 39.4} }, faction = "Horde", onlyArrow = true },
    -- Hillsbrad (1424)
    { npc = "Kayren Soothallow", mapIDs = {1424}, coords = { {x = 62.6, y = 20.0} }, faction = "Horde" },
    { npc = "Sarah Raycroft", mapIDs = {1424}, coords = { {x = 49.0, y = 55.2} }, faction = "Alliance" },
    -- Teufelswald (1448)
    { npc = "Malygen", mapIDs = {1448}, coords = { {x = 62.2, y = 25.6} }, faction = "Alliance" },
    { npc = "Bale", mapIDs = {1448}, coords = { {x = 34.8, y = 53.2} }, faction = "Horde" },
    -- Arathihochland (1417)
    { npc = "Vikki Lonsav", mapIDs = {1417}, coords = { {x = 46.4, y = 47.6} }, faction = "Alliance" },
    { npc = "Graud", mapIDs = {1417}, coords = { {x = 74.0, y = 32.6} }, faction = "Horde" },
    { npc = "Mu'uta", mapIDs = {1417}, coords = { {x = 72.6, y = 33.6} }, faction = "Horde", onlyArrow = true },
    -- Ödland (1418)
    { npc = "Grawl", mapIDs = {1418}, coords = { {x = 3.0, y = 46.0} }, faction = "Horde" },
    -- Thunder Bluff (nur Stadt-ID 1638)
    { npc = "Kuna Thunderhorn", mapIDs = {1638, 1456}, coords = { {x = 46.8, y = 46.0} }, faction = "Horde", onlyArrow = true },
    { npc = "Kuruk", mapIDs = {1638, 1456}, coords = { {x = 39.0, y = 64.2} }, faction = "Horde" },
    { npc = "Netali Proudwind", mapIDs = {1638, 1456}, coords = { {x = 28.6, y = 18.6} }, faction = "Horde" },
    { npc = "Jyn Stonehoof", mapIDs = {1638, 1456}, coords = { {x = 41.6, y = 62.0} }, faction = "Horde", onlyBullet = true },
    { npc = "Hogor Thunderhoof", mapIDs = {1638, 1456}, coords = { {x = 55.6, y = 56.6} }, faction = "Horde", onlyBullet = true },
    -- Durotar (1411)
    { npc = "Trayexir", mapIDs = {1411}, coords = { {x = 56.4, y = 73.2} }, faction = "Horde", onlyArrow = true },
    { npc = "K'waii", mapIDs = {1411}, coords = { {x = 56.2, y = 73.6} }, faction = "Horde" },
    { npc = "Duokna", mapIDs = {1411}, coords = { {x = 42.6, y = 67.4} }, faction = "Horde" },
    { npc = "Ghrawt", mapIDs = {1411}, coords = { {x = 53.0, y = 41.0} }, faction = "Horde", onlyArrow = true },
    { npc = "Jark", mapIDs = {1411}, coords = { {x = 54.2, y = 42.2} }, faction = "Horde" },
    -- Orgrimmar (nur Stadt-ID 1637)
    { npc = "Asoran", mapIDs = {1637, 1454}, coords = { {x = 46.0, y = 40.6} }, faction = "Horde" },
    { npc = "Jin'sora", mapIDs = {1637, 1454}, coords = { {x = 77.8, y = 38.6} }, faction = "Horde", onlyArrow = true },
    { npc = "Kaja", mapIDs = {1637, 1454}, coords = { {x = 52.2, y = 62.6} }, faction = "Horde", onlyBullet = true },
    { npc = "Trak'gen", mapIDs = {1637, 1454}, coords = { {x = 48.0, y = 80.2} }, faction = "Horde" },
    -- Brachland (1413)
    { npc = "Barg", mapIDs = {1413}, coords = { {x = 51.6, y = 30.0} }, faction = "Horde" },
    { npc = "Uthrok", mapIDs = {1413}, coords = { {x = 51.0, y = 29.0} }, faction = "Horde" },
    { npc = "Jazzik", mapIDs = {1413}, coords = { {x = 61.8, y = 38.8} }, faction = "Neutral" },
    -- Teldrassil (1438)
    { npc = "Aldia", mapIDs = {1438}, coords = { {x = 55.6, y = 57.0} }, faction = "Alliance" },
    { npc = "Jeena Featherbow", mapIDs = {1438}, coords = { {x = 55.8, y = 59.2} }, faction = "Alliance", onlyArrow = true },
    { npc = "Keina", mapIDs = {1438}, coords = { {x = 59.4, y = 41.2} }, faction = "Alliance", onlyArrow = true },
    { npc = "Lyrai", mapIDs = {1438}, coords = { {x = 59.6, y = 41.0} }, faction = "Alliance" },
    -- Eschental (1440)
    { npc = "Bhaldaran Ravenshade", mapIDs = {1440}, coords = { {x = 50.2, y = 67.2} }, faction = "Alliance", onlyArrow = true },
    { npc = "Haljan Oakheart", mapIDs = {1440}, coords = { {x = 34.8, y = 50.8} }, faction = "Alliance" },
    -- Thousand Needles (1441)
    { npc = "Jawn Highmesa", mapIDs = {1441}, coords = { { x = 46.0, y = 51.6 } }, faction = "Horde" },
    -- Steinkrallengebirge (1442)
    { npc = "Grawnal", mapIDs = {1442}, coords = { {x = 45.8, y = 58.6} }, faction = "Horde" },
    { npc = "Chylina", mapIDs = {1442}, coords = { {x = 35.6, y = 6.2} }, faction = "Alliance" },
    { npc = "Borand", mapIDs = {1442}, coords = { {x = 45.2, y = 59.2} }, faction = "Horde", onlyArrow = true },
    -- Darnassus (Stadt: nur 1657, damit nicht in Auberdine/Darkshore angezeigt)
    { npc = "Landria", mapIDs = {1657, 1457}, coords = { {x = 63.2, y = 66.6} }, faction = "Alliance", onlyArrow = true },
    { npc = "Ellandrieth", mapIDs = {1657, 1457}, coords = { {x = 64.6, y = 53.0} }, faction = "Alliance" },
    { npc = "Mydrannul", mapIDs = {1657, 1457}, coords = { {x = 70.6, y = 45.6} }, faction = "Alliance" },
    -- Dunkelküste (1440 / 1439)
    { npc = "Dalmond", mapIDs = {1440, 1439}, coords = { {x = 37.4, y = 40.6} }, faction = "Alliance" },
    -- Unterstadt (nur Stadt-ID 1497)
    { npc = "Benijah Fenner", mapIDs = {1497, 1458}, coords = { {x = 58.6, y = 32.6} }, faction = "Horde", onlyArrow = true },
    { npc = "Abigail Sawyer", mapIDs = {1497, 1458}, coords = { {x = 55.0, y = 37.4} }, faction = "Horde", onlyArrow = true },
    { npc = "Nicholas Atwood", mapIDs = {1497, 1458}, coords = { {x = 62.2, y = 27.0} }, faction = "Horde", onlyBullet = true },
    { npc = "Eleanor Rusk", mapIDs = {1497, 1458}, coords = { {x = 69.2, y = 47.4} }, faction = "Horde" },
    -- Marschen von Dustwallow (1445)
    { npc = "Jensen Farran", mapIDs = {1445}, coords = { {x = 67.8, y = 49.8} }, faction = "Alliance", onlyArrow = true },
    { npc = "Torq Ironblast", mapIDs = {1445}, coords = { {x = 67.4, y = 48.0} }, faction = "Alliance", onlyBullet = true },
    { npc = "Charity Mipsy", mapIDs = {1445}, coords = { {x = 67.6, y = 51.6} }, faction = "Alliance" },
    { npc = "Zanara", mapIDs = {1445}, coords = { {x = 35.6, y = 30.2} }, faction = "Horde", onlyArrow = true },
    -- Ironforge (nur Stadt-ID 1537)
    { npc = "Bryllia Ironbrand", mapIDs = {1537, 1455}, coords = { {x = 71.6, y = 66.2} }, faction = "Alliance" },
    { npc = "Skolmin Goldfury", mapIDs = {1537, 1455}, coords = { {x = 71.6, y = 66.6} }, faction = "Alliance", onlyArrow = true },
    { npc = "Bretta Goldfury", mapIDs = {1537, 1455}, coords = { {x = 72.6, y = 65.8} }, faction = "Alliance", onlyBullet = true },
    -- Feralas (1444)
    { npc = "Faralorn", mapIDs = {1444}, coords = { {x = 30.6, y = 43.4} }, faction = "Alliance" },
    { npc = "Jangdor Swiftstrider", mapIDs = {1444}, coords = { {x = 74.5, y = 43.0} }, faction = "Horde" },
    { npc = "Cawind Trueaim", mapIDs = {1444}, coords = { {x = 74.8, y = 45.6} }, faction = "Horde" },
    -- Tanaris (1446)
    { npc = "Jabbey", mapIDs = {1446}, coords = { {x = 67.0, y = 22.0} }, faction = "Neutral" },
    { npc = "Blizrik Buckshot", mapIDs = {1446}, coords = { {x = 50.8, y = 27.6} }, faction = "Neutral", onlyBullet = true },
    -- Östliche Pestländer (1423)
    { npc = "Steward Alen", mapIDs = {1423}, coords = { {x = 79.4, y = 63.8} }, faction = "Neutral" },
    -- Moonglade (1450)
    { npc = "Daeolyn Summerleaf", mapIDs = {1450}, coords = { {x = 45.2, y = 34.6} }, faction = "Neutral" },
    { npc = "Narianna", mapIDs = {1450}, coords = { {x = 53.2, y = 42.6} }, faction = "Neutral", onlyArrow = true },
    -- Desolace (1443)
    { npc = "Tukk", mapIDs = {1443}, coords = { {x = 25.0, y = 71.8} }, faction = "Horde" },
    { npc = "Christi Galvanis", mapIDs = {1443}, coords = { {x = 66.6, y = 6.8} }, faction = "Alliance" },
    -- Un'Goro (1449)
    { npc = "Nergal", mapIDs = {1449}, coords = { {x = 43.2, y = 7.8} }, faction = "Neutral" },
    -- Azshara (1447)
    { npc = "Brinna Valanaar", mapIDs = {1447}, coords = { {x = 12.0, y = 78.2} }, faction = "Alliance", onlyArrow = true },
    -- Silithus (1451)
    { npc = "Calandrath", mapIDs = {1451}, coords = { {x = 51.8, y = 39.0} }, faction = "Neutral" },
    -- Hinterland (1425)
    { npc = "Renn'az", mapIDs = {1425}, coords = { {x = 76.8, y = 81.2} }, faction = "Horde", onlyArrow = true },
    -- Dun Morogh (1426)
    { npc = "Adlin Pridedrift", mapIDs = {1426}, coords = { {x = 30.0, y = 71.6} }, faction = "Alliance" },
    { npc = "Hegnar Rumbleshot", mapIDs = {1426}, coords = { {x = 40.6, y = 65.0} }, faction = "Alliance", onlyBullet = true },
    { npc = "Kreg Bilmn", mapIDs = {1426}, coords = { {x = 47.2, y = 52.4} }, faction = "Alliance" },
    -- Tirisfal (1420)
    { npc = "Joshua Kien", mapIDs = {1420}, coords = { {x = 32.2, y = 65.6} }, faction = "Horde" },
    { npc = "Mrs. Winters", mapIDs = {1420}, coords = { {x = 61.0, y = 52.6} }, faction = "Horde" },
    -- Mulgore (1412)
    { npc = "Kawnie Softbreeze", mapIDs = {1412, 1456}, coords = { {x = 45.2, y = 76.6} }, faction = "Horde" },
    { npc = "Kennah Hawkseye", mapIDs = {1412, 1456}, coords = { {x = 45.6, y = 58.4} }, faction = "Horde", onlyBullet = true },
    { npc = "Moorat Longstride", mapIDs = {1412, 1456}, coords = { {x = 45.8, y = 57.6} }, faction = "Horde" },
}

BeastAndBow.BreadVendors = {
    -- Thunder Bluff
    { npc = "Fyr Mistrunner", mapIDs = {1638, 1456}, coords = { {x = 41.6, y = 54.6} }, faction = "Horde" },
    -- Mulgore (1412)
    { npc = "Innkeeper Kauth", mapIDs = {1412}, coords = { {x = 46.6, y = 61.0} }, faction = "Horde" },
    { npc = "Jhawna Oatwind", mapIDs = {1412}, coords = { {x = 47.6, y = 61.6} }, faction = "Horde" },
    { npc = "Moodan Sungrain", mapIDs = {1412}, coords = { {x = 44.6, y = 77.8} }, faction = "Horde" },
    -- Brachland (1413)
    { npc = "Moorane Hearthgrain", mapIDs = {1413}, coords = { {x = 52.2, y = 30.6} }, faction = "Horde" },
    { npc = "Tarban Hearthgrain", mapIDs = {1413}, coords = { {x = 55.0, y = 32.0} }, faction = "Horde" },
    -- Schlingendorntal (1434)
    { npc = "Nixxrax Fillamug", mapIDs = {1434}, coords = { {x = 27.0, y = 77.2} }, faction = "Neutral" },
    { npc = "Nargatt", mapIDs = {1434}, coords = { {x = 32.2, y = 29.2} }, faction = "Horde" },
    -- Feralas (1444)
    { npc = "Innkeeper Greul", mapIDs = {1444}, coords = { {x = 74.8, y = 45.0} }, faction = "Horde" },
    { npc = "Mardrack Greenwell", mapIDs = {1444}, coords = { {x = 31.0, y = 43.2} }, faction = "Alliance" },
    { npc = "Loorana", mapIDs = {1444}, coords = { {x = 75.4, y = 43.8} }, faction = "Horde" },
    -- Brennende Steppe (1428)
    { npc = "Gruna", mapIDs = {1428}, coords = { {x = 65.6, y = 24.0} }, faction = "Horde" },
    -- Westfall (1436)
    { npc = "Mike Miller", mapIDs = {1436}, coords = { {x = 57.6, y = 53.6} }, faction = "Alliance" },
    -- Wald von Elwynn (1429)
    { npc = "Innkeeper Farley", mapIDs = {1429}, coords = { {x = 43.8, y = 65.8} }, faction = "Alliance" },
    { npc = "Kira Songshine", mapIDs = {1429}, coords = {
        {x = 33.0, y = 51.2}, {x = 36.0, y = 53.6}, {x = 38.4, y = 55.6}, {x = 40.0, y = 58.6},
        {x = 41.6, y = 63.4}, {x = 43.8, y = 68.0}, {x = 47.6, y = 69.6}
    }, faction = "Alliance" },
    -- Stormwind
    { npc = "Thomas Miller", mapIDs = {1519, 1453}, coords = {
        {x = 52.2, y = 60.4}, {x = 54.4, y = 63.4}, {x = 55.4, y = 59.4}, {x = 57.0, y = 60.2},
        {x = 57.6, y = 63.6}, {x = 58.4, y = 56.8}, {x = 59.4, y = 67.0}, {x = 60.8, y = 61.0},
        {x = 61.8, y = 61.4}
    }, faction = "Alliance" },
    { npc = "Innkeeper Allison", mapIDs = {1519, 1453}, coords = { {x = 52.8, y = 65.4} }, faction = "Alliance" },
    -- Ironforge
    { npc = "Myra Tyrngaarde", mapIDs = {1537, 1455}, coords = {
        {x = 23.0, y = 61.4}, {x = 24.4, y = 62.0}, {x = 25.6, y = 68.0}, {x = 26.4, y = 70.6},
        {x = 27.8, y = 72.2}, {x = 29.2, y = 74.8}, {x = 30.6, y = 76.4}, {x = 32.0, y = 68.4},
        {x = 33.6, y = 73.6}
    }, faction = "Alliance" },
    -- Loch Modan (1432)
    { npc = "Innkeeper Hearthstove", mapIDs = {1432}, coords = { {x = 35.4, y = 48.4} }, faction = "Alliance" },
    { npc = "Honni Goldenoat", mapIDs = {1432}, coords = { {x = 35.2, y = 49.6} }, faction = "Alliance" },
    { npc = "Greishan Ironstove", mapIDs = {1432}, coords = {
        {x = 22.8, y = 70.8}, {x = 24.4, y = 68.6}, {x = 25.2, y = 11.8}, {x = 26.6, y = 66.4},
        {x = 28.2, y = 64.6}, {x = 29.2, y = 60.8}, {x = 30.6, y = 58.0}, {x = 34.4, y = 47.2}
    }, faction = "Alliance" },
    -- Ashenvale (1440)
    { npc = "Nantar", mapIDs = {1440}, coords = { {x = 37.0, y = 49.8} }, faction = "Alliance" },
    -- Hinterland (1425)
    { npc = "Innkeeper Thulfram", mapIDs = {1425}, coords = { {x = 13.8, y = 41.6} }, faction = "Alliance" },
    -- Dustwallow (1445)
    { npc = "Dwane Wertle", mapIDs = {1445}, coords = { {x = 68.2, y = 47.6} }, faction = "Alliance" },
    { npc = "Craig Nollward", mapIDs = {1445}, coords = { {x = 66.8, y = 45.2} }, faction = "Alliance" },
    { npc = "Innkeeper Janene", mapIDs = {1445}, coords = { {x = 66.6, y = 45.2} }, faction = "Alliance" },
    -- Rotkammgebirge (1433)
    { npc = "Gretchen Vogel", mapIDs = {1433}, coords = { {x = 22.6, y = 44.2} }, faction = "Alliance" },
    { npc = "Bartender Wental", mapIDs = {1433}, coords = { {x = 26.8, y = 44.0} }, faction = "Alliance" },
    -- Desolace (1443)
    { npc = "Innkeeper Lyshaerya", mapIDs = {1443}, coords = { {x = 66.2, y = 6.6} }, faction = "Alliance" },
    -- Dunkelküste (1440 / 1439)
    { npc = "Kyndri", mapIDs = {1440, 1439}, coords = { {x = 36.8, y = 44.6} }, faction = "Alliance" },
    { npc = "Innkeeper Shaussiy", mapIDs = {1440, 1439}, coords = { {x = 37.0, y = 44.0} }, faction = "Alliance" },
    -- Teldrassil (1438)
    { npc = "Danlyia", mapIDs = {1438}, coords = { {x = 55.4, y = 57.0} }, faction = "Alliance" },
    { npc = "Innkeeper Keldamyr", mapIDs = {1438}, coords = { {x = 55.6, y = 59.8} }, faction = "Alliance" },
    -- Hillsbrad (1424)
    { npc = "Innkeeper Anderson", mapIDs = {1424}, coords = { {x = 51.0, y = 58.8} }, faction = "Alliance" },
    { npc = "Neema", mapIDs = {1424}, coords = { {x = 51.0, y = 59.0} }, faction = "Alliance" },
    -- Dun Morogh (1426)
    { npc = "Kazan Mogosh", mapIDs = {1426}, coords = { {x = 68.6, y = 54.6} }, faction = "Alliance" },
    { npc = "Innkeeper Belm", mapIDs = {1426}, coords = { {x = 47.4, y = 52.6} }, faction = "Alliance" },
    -- Tirisfal (1420)
    { npc = "Innkeeper Renee", mapIDs = {1420}, coords = { {x = 61.6, y = 52.2} }, faction = "Horde" },
    -- Verwüstete Lande (1419)
        { npc = "Bernie Heisten", mapIDs = {1419}, coords = { {x = 63.6, y = 16.8} }, faction = "Alliance" },
    -- Westliche Pestländer (1422)
    { npc = "Baker Masterson", mapIDs = {1422}, coords = { {x = 42.6, y = 83.8} }, faction = "Alliance" },
    -- Östliche Pestländer (1423)
    { npc = "Jessica Chambers", mapIDs = {1423}, coords = { {x = 81.6, y = 58.0} }, faction = "Neutral" },
    -- Steinkrallengebirge (1442)
    { npc = "Innkeeper Faralia", mapIDs = {1442}, coords = { {x = 35.6, y = 5.8} }, faction = "Alliance" },
}

BeastAndBow.FishVendors = {
    -- Redridge (1433)
    { npc = "Vernon Hale", mapIDs = {1433}, coords = { {x = 27.5, y = 47.8} }, faction = "Alliance" },
    { npc = "Innkeeper Brianna", mapIDs = {1433}, coords = { {x = 26.8, y = 44.8} }, faction = "Alliance" },
    -- Loch Modan (1432)
    { npc = "Khara Deepwater", mapIDs = {1432}, coords = { {x = 40.3, y = 39.3} }, faction = "Alliance" },
    -- Stranglethorn (1434)
    { npc = "Wigcik", mapIDs = {1434}, coords = { {x = 28.0, y = 76.8} }, faction = "Neutral" },
    { npc = "Innkeeper Skindle", mapIDs = {1434}, coords = { {x = 27.0, y = 77.2} }, faction = "Neutral" },
    { npc = "Innkeeper Thulbek", mapIDs = {1434}, coords = { {x = 31.4, y = 29.6} }, faction = "Horde" },
    -- Wetlands (1437)
    { npc = "Stuart Fleming", mapIDs = {1437}, coords = { {x = 8.0, y = 58.2} }, faction = "Alliance" },
    -- Barrens (1413)
    { npc = "Kilxx", mapIDs = {1413}, coords = { {x = 62.8, y = 38.2} }, faction = "Neutral" },
    { npc = "Innkeeper Wiley", mapIDs = {1413}, coords = { {x = 62.0, y = 39.4} }, faction = "Neutral" },
    -- Hillsbrad (1424)
    { npc = "Hal McAllister", mapIDs = {1424}, coords = { {x = 49.8, y = 62.2} }, faction = "Alliance" },
    -- Darkshore (1440 / 1439)
    { npc = "Laird", mapIDs = {1440, 1439}, coords = { {x = 36.8, y = 44.2} }, faction = "Alliance" },
    { npc = "Heldan Galesong", mapIDs = {1440, 1439}, coords = { {x = 37.0, y = 56.2} }, faction = "Alliance" },
    -- Darnassus (1657)
    { npc = "Talaelar", mapIDs = {1657, 1457}, coords = { {x = 47.6, y = 57.0} }, faction = "Alliance" },
    -- Verwüstete Lande (1419)
        { npc = "Kriggon Talsone", mapIDs = {1419}, coords = { {x = 36.2, y = 90.0} }, faction = "Alliance" },
    -- Westfall (1436)
    { npc = "Innkeeper Heather", mapIDs = {1436}, coords = { {x = 52.8, y = 53.6} }, faction = "Alliance" },
    -- Ashenvale (1440)
    { npc = "Innkeeper Kimlya", mapIDs = {1440}, coords = { {x = 11.8, y = 34.0}, {x = 37.0, y = 49.2} }, faction = "Alliance" },
    { npc = "Wik'Tar", mapIDs = {1440}, coords = { {x = 11.8, y = 34.0} }, faction = "Horde" },
    -- Feralas (1444)
    { npc = "Harklane", mapIDs = {1444}, coords = { {x = 31.0, y = 46.2} }, faction = "Alliance" },
    -- Tanaris (1446)
    { npc = "Gikkix", mapIDs = {1446}, coords = { {x = 66.6, y = 22.0} }, faction = "Neutral" },
    -- Winterspring (1452)
    { npc = "Himmik", mapIDs = {1452}, coords = { {x = 61.2, y = 39.0} }, faction = "Neutral" },
    -- Hinterlands (1425)
    { npc = "Lard", mapIDs = {1425}, coords = { {x = 78.2, y = 81.2} }, faction = "Horde" },
}

BeastAndBow.CheeseVendors = {
    -- Elwynn (1429)
    { npc = "Innkeeper Farley", mapIDs = {1429}, coords = { {x = 43.8, y = 65.8} }, faction = "Alliance" },
    { npc = "Barkeep Dobbins", mapIDs = {1429}, coords = { {x = 43.8, y = 65.8} }, faction = "Alliance" },
    -- Stormwind
    { npc = "Elaine Trias", mapIDs = {1519, 1453}, coords = { {x = 60.6, y = 63.4} }, faction = "Alliance" },
    { npc = "Ben Trias", mapIDs = {1519, 1453}, coords = { {x = 60.4, y = 63.6} }, faction = "Alliance" },
    -- Dun Morogh (1426)
    { npc = "Kazan Mogosh", mapIDs = {1426}, coords = { {x = 68.6, y = 54.6} }, faction = "Alliance" },
    -- Redridge (1433)
    { npc = "Bartender Wental", mapIDs = {1433}, coords = { {x = 26.8, y = 44.0} }, faction = "Alliance" },
    -- Duskwood (1431)
    { npc = "Innkeeper Trelayne", mapIDs = {1431}, coords = { {x = 73.9, y = 44.4} }, faction = "Alliance" },
    -- Thunder Bluff
    { npc = "Innkeeper Pala", mapIDs = {1638, 1456}, coords = { {x = 45.8, y = 64.6} }, faction = "Horde" },
    -- Desolace (1443)
    { npc = "Innkeeper Sikewa", mapIDs = {1443}, coords = { {x = 24.0, y = 68.2} }, faction = "Horde" },
    -- Hillsbrad (1424)
    { npc = "Innkeeper Anderson", mapIDs = {1424}, coords = { {x = 51.0, y = 58.8} }, faction = "Alliance" },
    { npc = "Neema", mapIDs = {1424}, coords = { {x = 51.0, y = 59.0} }, faction = "Alliance" },
    -- Burning Steppes (1428)
    { npc = "Gabrielle Chase", mapIDs = {1428}, coords = { {x = 84.2, y = 67.8} }, faction = "Alliance" },
    -- Verwüstete Lande (1419)
    { npc = "Bernie Heisten", mapIDs = {1419}, coords = { {x = 63.6, y = 16.8} }, faction = "Alliance" },
    -- Hinterlands (1425)
    { npc = "Truk Wildbeard", mapIDs = {1425}, coords = { {x = 14.4, y = 42.5} }, faction = "Alliance" },
    -- Dustwallow (1445)
    { npc = "Dwane Wertle", mapIDs = {1445}, coords = { {x = 68.2, y = 47.6} }, faction = "Alliance" },
    { npc = "Craig Nollward", mapIDs = {1445}, coords = { {x = 66.8, y = 45.2} }, faction = "Alliance" },
    -- Swamp of Sorrows (1435)
    { npc = "Innkeeper Karakul", mapIDs = {1435}, coords = { {x = 45.0, y = 56.6} }, faction = "Horde" },
    -- Arathi (1417)
    { npc = "Innkeeper Adegwa", mapIDs = {1417}, coords = { {x = 73.8, y = 32.6} }, faction = "Horde" },
    -- Thousand Needles (400)
    { npc = "Innkeeper Abeqwa", mapIDs = {1441}, coords = { {x = 46.0, y = 51.6} }, faction = "Horde" },
}

BeastAndBow.FruitVendors = {
    -- Ironforge
    { npc = "Bimble Longberry", mapIDs = {1537, 1455}, coords = {
        {x = 20.2, y = 23.6}, {x = 24.2, y = 27.2}, {x = 25.6, y = 27.8}, {x = 26.6, y = 28.4},
        {x = 27.4, y = 25.4}, {x = 28.4, y = 24.0}, {x = 29.6, y = 16.0}, {x = 30.8, y = 22.6},
        {x = 31.6, y = 23.6}, {x = 32.8, y = 20.6}, {x = 33.8, y = 21.4}, {x = 34.8, y = 18.6},
        {x = 35.6, y = 16.6}, {x = 36.6, y = 15.6}, {x = 38.6, y = 14.6}, {x = 39.0, y = 12.4}
    }, faction = "Alliance" },
    -- Stranglethorn (1434)
    { npc = "Corporal Bluth", mapIDs = {1434}, coords = { {x = 38.0, y = 3.0} }, faction = "Alliance" },
    { npc = "Innkeeper Thulbek", mapIDs = {1434}, coords = { {x = 31.4, y = 29.6} }, faction = "Horde" },
    -- Elwynn (1429)
    { npc = "Homer Stonefield", mapIDs = {1429}, coords = { {x = 33.6, y = 83.0} }, faction = "Alliance" },
    -- Redridge (1433)
    { npc = "Lamar Veisilli", mapIDs = {1433}, coords = { {x = 21.0, y = 46.6} }, faction = "Alliance" },
    -- Darnassus (1657, 1457)
    { npc = "Innkeeper Saelienne", mapIDs = {1657, 1457}, coords = { {x = 67.4, y = 15.6}, {x = 67.2, y = 15.8} }, faction = "Alliance" },
    -- Ashenvale (1440)
    { npc = "Maliynn", mapIDs = {1440}, coords = { {x = 36.6, y = 50.0}, {x = 36.6, y = 49.8} }, faction = "Alliance" },
    -- Darkshore (1440 / 1439)
    { npc = "Allyndia", mapIDs = {1440, 1439}, coords = { {x = 37.0, y = 43.6} }, faction = "Alliance" },
    -- Feralas (1444)
    { npc = "Innkeeper Shyria", mapIDs = {1444}, coords = { {x = 31.0, y = 43.4} }, faction = "Alliance" },
    -- Thunder Bluff
    { npc = "Nan Mistrunner", mapIDs = {1638, 1456}, coords = { {x = 47.2, y = 42.6} }, faction = "Horde" },
    -- Orgrimmar
    { npc = "Shan'ti", mapIDs = {1637, 1454}, coords = { {x = 38.0, y = 52.6} }, faction = "Horde" },
    -- Barrens (1413)
    { npc = "Innkeeper Byula", mapIDs = {1413}, coords = { {x = 45.6, y = 59.0} }, faction = "Horde" },
    { npc = "Innkeeper Boorand Plainswind", mapIDs = {1413}, coords = { {x = 52.0, y = 29.8} }, faction = "Horde" },
    -- Arathi (1417)
    { npc = "Targot Jinglepocket", mapIDs = {1417}, coords = { {x = 46.4, y = 45.4} }, faction = "Alliance" },
    -- Eastern Plaguelands (1423)
    { npc = "Malorie", mapIDs = {1423}, coords = { {x = 95.2, y = 78.8} }, faction = "Neutral" },
    -- Dustwallow Marsh (1445)
    { npc = "Dwane Wertle", mapIDs = {1445}, coords = { {x = 68.2, y = 47.6} }, faction = "Alliance" },
}

BeastAndBow.MushroomVendors = {
    -- Duskwood (1431)
    { npc = "Scott Carevin", mapIDs = {1431}, coords = { {x = 75.6, y = 48.6} }, faction = "Alliance" },
    -- Orgrimmar
    { npc = "Kor'jus", mapIDs = {1637, 1454}, coords = { {x = 49.4, y = 53.4} }, faction = "Horde" },
    -- Hillsbrad (1424)
    { npc = "Jason Lemieux", mapIDs = {1424}, coords = {
        {x = 59.0, y = 20.2}, {x = 60.2, y = 21.0}, {x = 60.8, y = 20.6}, {x = 61.4, y = 23.2},
        {x = 62.0, y = 21.6}, {x = 62.2, y = 20.6}
    }, faction = "Horde" },
    -- Tirisfal (1420)
    { npc = "Hamlin Atkins", mapIDs = {1420}, coords = {
        {x = 56.4, y = 52.2}, {x = 58.2, y = 50.6}, {x = 59.0, y = 51.4}, {x = 61.4, y = 53.6}, {x = 61.8, y = 54.6}
    }, faction = "Horde" },
    { npc = "Innkeeper Renee", mapIDs = {1420}, coords = { {x = 61.6, y = 52.0} }, faction = "Horde" },
    -- Undercity (1497, 1458)
    { npc = "Tawny Grisette", mapIDs = {1497, 1458}, coords = {
        {x=62.2,y=42.4}, {x=63.4,y=39.4}, {x=64.2,y=39.0}, {x=64.4,y=49.6},
        {x=65.2,y=38.4}, {x=65.8,y=49.4}, {x=66.6,y=49.6}, {x=67.4,y=38.6},
        {x=67.8,y=50.6}, {x=68.6,y=39.4}, {x=68.8,y=47.6}, {x=69.4,y=41.6},
        {x=69.4,y=46.6}, {x=69.8,y=44.6}
    }, faction = "Horde" },
    { npc = "Morley Bates", mapIDs = {1497, 1458}, coords = {
        {x=71.4,y=28.0}, {x=72.6,y=25.4}, {x=73.6,y=31.4}, {x=74.8,y=32.0},
        {x=75.8,y=33.4}, {x=76.2,y=35.8}, {x=77.4,y=17.4}, {x=78.0,y=16.4},
        {x=78.6,y=24.2}, {x=79.6,y=25.4}, {x=80.2,y=26.6}, {x=81.2,y=29.0},
        {x=82.2,y=28.8}, {x=83.4,y=26.2}, {x=83.8,y=24.6}, {x=84.8,y=24.8}
    }, faction = "Horde" },
    { npc = "Innkeeper Norman", mapIDs = {1497, 1458}, coords = { {x = 67.8, y = 38.6} }, faction = "Horde" },
    -- Silverpine (1421)
    { npc = "Gwyn Farrow", mapIDs = {1421}, coords = { {x = 44.0, y = 39.8} }, faction = "Horde" },
    { npc = "Innkeeper Bates", mapIDs = {1421}, coords = { {x = 43.2, y = 41.2} }, faction = "Horde" },
    -- Desolace (1443)
    { npc = "Janet Hommers", mapIDs = {1443}, coords = { {x = 66.2, y = 6.6} }, faction = "Alliance" },
    { npc = "Harnor", mapIDs = {1443}, coords = { {x = 51.2, y = 53.2} }, faction = "Horde" },
    -- Eastern Plaguelands (1423)
    { npc = "Caretaker Alen", mapIDs = {1423}, coords = { {x = 79.4, y = 63.8} }, faction = "Neutral" },
}

BeastAndBow.MeatVendors = {
    -- Badlands (1418)
    { npc = "Innkeeper Shul'kar", mapIDs = {1418}, coords = { {x = 2.8, y = 45.8} }, faction = "Horde" },
    {
        npc = "Sognar Cliffbeard",
        mapIDs = {1537, 1455},
        coords = {
            {x=55.4,y=81.4}, {x=56.4,y=77.8}, {x=57.4,y=80.0}, {x=58.6,y=79.2},
            {x=59.2,y=74.0}, {x=60.2,y=74.6}, {x=61.2,y=80.4}, {x=62.0,y=84.0},
            {x=63.4,y=78.4}, {x=64.4,y=76.2}, {x=65.4,y=75.2}, {x=66.4,y=74.0},
            {x=67.2,y=73.2}, {x=68.0,y=71.2}, {x=69.0,y=75.0}, {x=70.0,y=73.6}
        },
        faction = "Alliance",
    },
    -- Swamp of Sorrows (1435)
    { npc = "Thultash", mapIDs = {1435}, coords = { {x = 46.6, y = 54.0} }, faction = "Horde" },
    -- Wetlands (1437)
    { npc = "Innkeeper Helbrek", mapIDs = {1437}, coords = { {x = 10.6, y = 60.8} }, faction = "Alliance" },
    -- Hillsbrad (1424)
    { npc = "Bront Coldcleave", mapIDs = {1424}, coords = { {x = 48.8, y = 57.2} }, faction = "Alliance" },
    { npc = "Innkeeper Shay", mapIDs = {1424}, coords = { {x = 62.6, y = 19.0} }, faction = "Horde" },
    -- Arathi (1417)
    { npc = "Narj Deepslice", mapIDs = {1417}, coords = { {x = 45.6, y = 47.6} }, faction = "Alliance" },
    { npc = "Uttnar", mapIDs = {1417}, coords = { {x = 74.2, y = 33.8} }, faction = "Horde" },
    -- Thunder Bluff
    { npc = "Kaga Mistrunner", mapIDs = {1638, 1456}, coords = { {x = 52.8, y = 48.8} }, faction = "Horde" },
    -- Redridge (1433)
    { npc = "Sherman Femmel", mapIDs = {1433}, coords = { {x = 26.8, y = 43.4} }, faction = "Alliance" },
    { npc = "Bartender Wental", mapIDs = {1433}, coords = { {x = 26.8, y = 44.0} }, faction = "Alliance" },
    -- Orgrimmar
    { npc = "Olvia", mapIDs = {1637, 1454}, coords = { {x = 44.8, y = 69.8} }, faction = "Horde" },
    { npc = "Innkeeper Gryshka", mapIDs = {1637, 1454}, coords = { {x = 54.2, y = 68.4} }, faction = "Horde" },
    { npc = "Borstan", mapIDs = {1637, 1454}, coords = { {x = 57.6, y = 53.4} }, faction = "Horde" },
    -- Stonetalon (1442)
    { npc = "Denni'ka", mapIDs = {1442}, coords = { {x = 47.4, y = 62.0}, {x = 73.6, y = 95.4} }, faction = "Horde" },
    { npc = "Innkeeper Jayka", mapIDs = {1442}, coords = { {x = 47.6, y = 62.0} }, faction = "Horde" },
    { npc = "Krond", mapIDs = {1442}, coords = { {x = 46.2, y = 58.6} }, faction = "Horde" },
    { npc = "Chylina", mapIDs = {1442}, coords = { {x = 35.6, y = 6.2} }, faction = "Alliance" },
    -- Barrens (1413)
    { npc = "Zargh", mapIDs = {1413}, coords = { {x = 52.6, y = 29.8} }, faction = "Horde" },
    { npc = "Gahroot", mapIDs = {1413}, coords = { {x = 44.8, y = 59.4} }, faction = "Horde" },
    -- Azshara (1447)
    { npc = "Kurll", mapIDs = {1447}, coords = { {x = 21.8, y = 52.0} }, faction = "Horde" },
    -- Durotar (1411)
    { npc = "Grimtak", mapIDs = {1411}, coords = { {x = 51.2, y = 42.6} }, faction = "Horde" },
    { npc = "Hai'zan", mapIDs = {1411}, coords = { {x = 55.6, y = 73.6} }, faction = "Horde" },
    { npc = "Innkeeper Grosk", mapIDs = {1411}, coords = { {x = 51.6, y = 41.6} }, faction = "Horde" },
    { npc = "Zlagk", mapIDs = {1411}, coords = { {x = 42.6, y = 67.2} }, faction = "Horde" },
    -- Elwynn (1429)
    { npc = "Toddrick", mapIDs = {1429}, coords = { {x = 44.2, y = 66.0} }, faction = "Alliance" },
    -- Ashenvale (1440)
    { npc = "Ulthaan", mapIDs = {1440}, coords = { {x = 50.0, y = 66.6} }, faction = "Alliance" },
    { npc = "Innkeeper Kaylisk", mapIDs = {1440}, coords = { {x = 74.0, y = 60.6} }, faction = "Horde" },
    -- Darnassus (1657)
    { npc = "Jaeana", mapIDs = {1657, 1457}, coords = {
        {x = 59.8, y = 66.6}, {x = 61.4, y = 55.2}, {x = 61.4, y = 63.6}, {x = 61.8, y = 68.4},
        {x = 62.2, y = 58.8}, {x = 62.6, y = 71.6}, {x = 63.2, y = 57.6}, {x = 64.2, y = 70.6},
        {x = 64.8, y = 68.4}, {x = 65.8, y = 66.6}, {x = 66.4, y = 65.0}, {x = 67.2, y = 66.0},
        {x = 67.8, y = 58.4}, {x = 68.6, y = 57.8}
    }, faction = "Alliance" },
    -- Hinterlands (1425)
    { npc = "Truk Wildbeard", mapIDs = {1425}, coords = { {x = 14.4, y = 42.4} }, faction = "Alliance" },
    -- Dustwallow (1445)
    { npc = "Ogg'marr", mapIDs = {1445}, coords = { {x = 36.6, y = 31.0} }, faction = "Horde" },
    { npc = "Craig Nollward", mapIDs = {1445}, coords = { {x = 66.8, y = 45.2} }, faction = "Alliance" },
    { npc = "Dwane Wertle", mapIDs = {1445}, coords = { {x = 68.2, y = 47.6} }, faction = "Alliance" },
    -- Ironforge
    { npc = "Innkeeper Firebrew", mapIDs = {1537, 1455}, coords = { {x = 18.6, y = 51.6} }, faction = "Alliance" },
    -- Stranglethorn (1434)
    { npc = "Nargatt", mapIDs = {1434}, coords = { {x = 32.2, y = 29.2} }, faction = "Horde" },
    -- Tanaris (1446)
    { npc = "Innkeeper Fizzgrimble", mapIDs = {1446}, coords = { {x = 52.4, y = 27.8} }, faction = "Neutral" },
    { npc = "Dirge Quikcleave", mapIDs = {1446}, coords = { {x = 52.6, y = 28.0} }, faction = "Neutral" },
    -- Winterspring (1452)
    { npc = "Innkeeper Vizzie", mapIDs = {1452}, coords = { {x = 61.2, y = 38.8} }, faction = "Neutral" },
    { npc = "Himmik", mapIDs = {1452}, coords = { {x = 61.2, y = 39.0} }, faction = "Neutral" },
    -- Un'Goro (1449)
    { npc = "Nergal", mapIDs = {1449}, coords = { {x = 43.2, y = 7.8} }, faction = "Neutral" },
    -- Silithus (1451)
    { npc = "Calandrath", mapIDs = {1451}, coords = { {x = 51.8, y = 39.0} }, faction = "Neutral" },
    -- Eastern Plaguelands (1423)
    { npc = "Malorie", mapIDs = {1423}, coords = { {x = 95.2, y = 78.8} }, faction = "Neutral" },
}