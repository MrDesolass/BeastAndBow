BeastAndBow = BeastAndBow or {}

BeastAndBow.MapNames = {
    -- Kalimdor
    [1411] = BeastAndBow.L.MAP_DUROTAR,
    [1412] = BeastAndBow.L.MAP_MULGORE,
    [1413] = BeastAndBow.L.MAP_THE_BARRENS,
    [1438] = BeastAndBow.L.MAP_TELDRASSIL,
    [1439] = BeastAndBow.L.MAP_DARNASSUS,
    [1440] = BeastAndBow.L.MAP_DARKSHORE,
    [1441] = BeastAndBow.L.MAP_ASHENVALE,
    [1442] = BeastAndBow.L.MAP_STONETALON_MOUNTAINS,
    [1443] = BeastAndBow.L.MAP_FERALAS,
    [1444] = BeastAndBow.L.MAP_DESOLACE,
    [1445] = BeastAndBow.L.MAP_DUSTWALLOW_MARSH,
    [1446] = BeastAndBow.L.MAP_TANARIS,
    [1447] = BeastAndBow.L.MAP_AZSHARA,
    [1448] = BeastAndBow.L.MAP_FELWOOD,
    [1449] = BeastAndBow.L.MAP_UNGORO_CRATER,
    [1450] = BeastAndBow.L.MAP_MOONGLADE,
    [1451] = BeastAndBow.L.MAP_SILITHUS,
    [1452] = BeastAndBow.L.MAP_WINTERSPRING,
    [1454] = BeastAndBow.L.MAP_ORGRIMMAR,
    [1456] = BeastAndBow.L.MAP_THUNDER_BLUFF,
    [1637] = BeastAndBow.L.MAP_ORGRIMMAR_CITY,
    [1638] = BeastAndBow.L.MAP_THUNDER_BLUFF_CITY,

    -- Östliche Königreiche
    [1429] = BeastAndBow.L.MAP_ELWYNN_FOREST,
    [1430] = BeastAndBow.L.MAP_WESTFALL,
    [1431] = BeastAndBow.L.MAP_DUSKWOOD,
    [1432] = BeastAndBow.L.MAP_LOCH_MODAN,
    [1433] = BeastAndBow.L.MAP_REDRIDGE_MOUNTAINS,
    [1434] = BeastAndBow.L.MAP_STRANGLETHORN_VALE,
    [1435] = BeastAndBow.L.MAP_SWAMP_OF_SORROWS,
    [1436] = BeastAndBow.L.MAP_BLASTED_LANDS,
    [1437] = BeastAndBow.L.MAP_WETLANDS,
    [1417] = BeastAndBow.L.MAP_ARATHI_HIGHLANDS,
    [1424] = BeastAndBow.L.MAP_HILLSBRAD_FOOTHILLS,
    [1416] = BeastAndBow.L.MAP_ALTERAC_MOUNTAINS,
    [1425] = BeastAndBow.L.MAP_THE_HINTERLANDS,
    [1420] = BeastAndBow.L.MAP_TIRISFAL_GLADES,
    [1421] = BeastAndBow.L.MAP_SILVERPINE_FOREST,
    [1422] = BeastAndBow.L.MAP_WESTERN_PLAGUELANDS,
    [1423] = BeastAndBow.L.MAP_EASTERN_PLAGUELANDS,
    [1426] = BeastAndBow.L.MAP_DUN_MOROGH,
    [1427] = BeastAndBow.L.MAP_SEARING_GORGE,
    [1428] = BeastAndBow.L.MAP_BURNING_STEPPES,
    [1418] = BeastAndBow.L.MAP_BADLANDS,
    [1453] = BeastAndBow.L.MAP_STORMWIND,
    [1455] = BeastAndBow.L.MAP_IRONFORGE,
    [1458] = BeastAndBow.L.MAP_UNDERCITY,
    [1519] = BeastAndBow.L.MAP_STORMWIND_CITY,
    [1537] = BeastAndBow.L.MAP_IRONFORGE_CITY,
    [1497] = BeastAndBow.L.MAP_UNDERCITY_CITY,
    [1657] = BeastAndBow.L.MAP_DARNASSUS_CITY,
    [1457] = BeastAndBow.L.MAP_SEARING_GORGE_ZONE,
    
    -- Specials
    [1459] = BeastAndBow.L.MAP_ALTERAC_VALLEY,
    [2597] = BeastAndBow.L.MAP_ALTERAC_VALLEY_BG,
}

BeastAndBow.ArrowVendors = {
    -- Dämmerwald (1431)
    { npc = "Mabel Solaj", mapIDs = {1431}, coords = { {x = 74.21, y = 44.81} }, faction = "Alliance" },
    { npc = "Avette Felwood", mapIDs = {1431}, coords = { {x = 73.03, y = 44.42} }, faction = "Alliance" },
    -- Westfall (1430)
    { npc = "Rüstmeister Lewis", mapIDs = {1430}, coords = { {x = 57.0, y = 47.17} }, faction = "Alliance" },
    { npc = "William MacGregor", mapIDs = {1430}, coords = { {x = 57.71, y = 53.94} }, faction = "Alliance" },
    -- Schlingendorntal (1434)
    { npc = "Corporal Bluth", mapIDs = {1434}, coords = { {x = 37.96, y = 2.99} }, faction = "Alliance" },
    { npc = "Uthok", mapIDs = {1434}, coords = { {x = 31.55, y = 27.95} }, faction = "Horde" },
    { npc = "Haren Kanmae", mapIDs = {1434}, coords = { {x = 28.31, y = 74.56} }, faction = "Alliance" },
    -- Rotkammgebirge (1433)
    { npc = "Kimberly Hiett", mapIDs = {1433}, coords = { {x = 27.08, y = 45.55} }, faction = "Alliance" },
    { npc = "Lindsay Ashlock", mapIDs = {1433}, coords = { {x = 28.77, y = 47.33} }, faction = "Alliance" },
    -- Wald von Elwynn (1429)
    { npc = "Brog Hamfist", mapIDs = {1429}, coords = { {x = 43.96, y = 65.92} }, faction = "Alliance" },
    { npc = "Bruder Danil", mapIDs = {1429}, coords = { {x = 47.49, y = 41.56} }, faction = "Alliance" }, -- Nordhaintal
    { npc = "Drake Lindgren", mapIDs = {1429}, coords = { {x = 83.31, y = 66.69} }, faction = "Alliance" },
    -- Stormwind (1519 City / 1453 Zone)
    { npc = "Thurman Mullby", mapIDs = {1519, 1453}, coords = { {x = 58.37, y = 61.68} }, faction = "Alliance" },
    { npc = "Marda Weller", mapIDs = {1519, 1453}, coords = { {x = 57.38, y = 56.77} }, faction = "Alliance" },
    { npc = "Lina Stover", mapIDs = {1519, 1453}, coords = { {x = 50.46, y = 57.23} }, faction = "Alliance" },
    { npc = "Frederick Stover", mapIDs = {1519, 1453}, coords = { {x = 49.98, y = 57.64} }, faction = "Alliance" },
    -- Sumpfland (1437)
    { npc = "Rallic Finn", mapIDs = {1437}, coords = { {x = 10.6, y = 56.8} }, faction = "Alliance" },
    { npc = "Neal Allen", mapIDs = {1437}, coords = { {x = 10.75, y = 56.75} }, faction = "Alliance" },
    { npc = "Gruham Rumdnul", mapIDs = {1437}, coords = { {x = 12.07, y = 57.98} }, faction = "Alliance" },
    -- Loch Modan (1432)
    { npc = "Yanni Stoutheart", mapIDs = {1432}, coords = { {x = 34.76, y = 48.62} }, faction = "Alliance" },
    { npc = "Xandar Goodbeard", mapIDs = {1432}, coords = { {x = 82.47, y = 63.35} }, faction = "Alliance" },
    -- Winterspring (1452)
    { npc = "Natheril Raincaller", mapIDs = {1452}, coords = { {x = 51.45, y = 30.83} }, faction = "Alliance" },
    -- Silberwald (1421)
    { npc = "Edwin Harly", mapIDs = {1421}, coords = { {x = 43.98, y = 39.9} }, faction = "Horde" },
    { npc = "Nadia Vernon", mapIDs = {1421}, coords = { {x = 45.01, y = 39.3} }, faction = "Horde" },
    -- Hillsbrad (1424)
    { npc = "Kayren Soothallow", mapIDs = {1424}, coords = { {x = 62.56, y = 19.91} }, faction = "Horde" },
    { npc = "Sarah Raycroft", mapIDs = {1424}, coords = { {x = 49.14, y = 55.06} }, faction = "Alliance" },
    -- Teufelswald (1448)
    { npc = "Malygen", mapIDs = {1448}, coords = { {x = 62.32, y = 25.64} }, faction = "Neutral" },
    { npc = "Bale", mapIDs = {1448}, coords = { {x = 34.75, y = 53.23} }, faction = "Neutral" },
    -- Arathihochland (1417)
    { npc = "Vikki Lonsav", mapIDs = {1417}, coords = { {x = 46.45, y = 47.6} }, faction = "Alliance" },
    { npc = "Graud", mapIDs = {1417}, coords = { {x = 74.12, y = 32.37} }, faction = "Horde" },
    { npc = "Mu'uta", mapIDs = {1417}, coords = { {x = 73.91, y = 32.36} }, faction = "Horde" },
    -- Ödland (1418)
    { npc = "Grawl", mapIDs = {1418}, coords = { {x = 3.12, y = 45.93} }, faction = "Horde" },
    -- Thunder Bluff (1638 City / 1456 Zone)
    { npc = "Kuna Thunderhorn", mapIDs = {1638, 1456}, coords = { {x = 47.0, y = 45.7} }, faction = "Horde" },
    { npc = "Kuruk", mapIDs = {1638, 1456}, coords = { {x = 38.91, y = 64.7} }, faction = "Horde" },
    -- Durotar (1411)
    { npc = "Ghrawt", mapIDs = {1411}, coords = { {x = 52.98, y = 41.03} }, faction = "Horde" },
    { npc = "Trayexir", mapIDs = {1411}, coords = { {x = 53, y = 41} }, faction = "Horde" },
    { npc = "Duokna", mapIDs = {1411}, coords = { {x = 42.59, y = 67.34} }, faction = "Horde" },
    { npc = "Jark", mapIDs = {1411}, coords = { {x = 54.39, y = 42.18} }, faction = "Horde" },
    -- Orgrimmar (1637 City / 1454 Zone)
    { npc = "Trak'gen", mapIDs = {1637, 1454}, coords = { {x = 48.11, y = 80.17} }, faction = "Horde" },
    { npc = "Asoran", mapIDs = {1637, 1454}, coords = { {x = 46.07, y = 40.87} }, faction = "Horde" },
    { npc = "Zendo'jian", mapIDs = {1637, 1454}, coords = { {x = 46.4, y = 40.23} }, faction = "Horde" },
    -- Brachland (1413)
    { npc = "Barg", mapIDs = {1413}, coords = { {x = 51.67, y = 29.95} }, faction = "Horde" },
    { npc = "Uthrok", mapIDs = {1413}, coords = { {x = 51.11, y = 29.06} }, faction = "Horde" }, -- Ratchet
    { npc = "Jazzik", mapIDs = {1413}, coords = { {x = 61.92, y = 38.8} }, faction = "Horde" },
    -- Teldrassil (1438)
    { npc = "Keina", mapIDs = {1438}, coords = { {x = 59.8, y = 42.0} }, faction = "Alliance" },
    { npc = "Jeena Featherbow", mapIDs = {1438}, coords = { {x = 55.89, y = 59.21} }, faction = "Alliance" },
    { npc = "Lyrai", mapIDs = {1438}, coords = { {x = 55.8, y = 59.2} }, faction = "Alliance" },
    { npc = "Aldia", mapIDs = {1438}, coords = { {x = 55.8, y = 59.2} }, faction = "Alliance" },
    -- Alteractal (1459 / 2597)
    { npc = "Rarck", mapIDs = {1459, 2597}, coords = { {x = 46, y = 32.8} }, faction = "Horde" },
    -- Eschental (1441)
    { npc = "Bhaldaran Ravenshade", mapIDs = {1441}, coords = { {x = 34.8, y = 50.8} }, faction = "Alliance" },
    { npc = "Haljan Oakheart", mapIDs = {1441}, coords = { {x = 34.8, y = 50.8} }, faction = "Alliance" },
    -- Steinkrallengebirge (1442)
    { npc = "Grawnal", mapIDs = {1442}, coords = { {x = 45.8, y = 58.6} }, faction = "Horde" },
    { npc = "Chylina", mapIDs = {1442}, coords = { {x = 45.8, y = 58.6} }, faction = "Horde" },
    -- Darnassus (1657 City / 1439 Zone)
    { npc = "Landria", mapIDs = {1657, 1439, 1457}, coords = { {x = 64.6, y = 53} }, faction = "Alliance" },
    { npc = "Mydrannul", mapIDs = {1657, 1439, 1457}, coords = { {x = 64.4, y = 53} }, faction = "Alliance" },
    -- Dunkelküste (1440)
    { npc = "Dalmond", mapIDs = {1440}, coords = { {x = 37.4, y = 40.4} }, faction = "Alliance" },
    -- Unterstadt (1458 / 1497)
    { npc = "Eleanor Rusk", mapIDs = {1458, 1497}, coords = { {x = 58.4, y = 32.4} }, faction = "Horde" },
    { npc = "Benijah Fenner", mapIDs = {1458, 1497}, coords = { {x = 58.4, y = 32.6} }, faction = "Horde" },

    -- Marschen von Dustwallow (1445)
    { npc = "Jensen Farran", mapIDs = {1445}, coords = { {x = 35.4, y = 30.2} }, faction = "Alliance" },
    { npc = "Zanara", mapIDs = {1445}, coords = { {x = 35.6, y = 30.2} }, faction = "Alliance" },
    -- Ironforge (1537 City / 1455 Zone)
    { npc = "Bryllia Ironbrand", mapIDs = {1537, 1455}, coords = { {x = 71.6, y = 66.2} }, faction = "Alliance" },
    { npc = "Thalgus Thunderfist", mapIDs = {1537, 1455}, coords = { {x = 71.6, y = 66.2} }, faction = "Alliance" },
    -- Feralas (1443)
    { npc = "Faralorn", mapIDs = {1443}, coords = { {x = 74.8, y = 45.6} }, faction = "Alliance" },
    { npc = "Cawind Trueaim", mapIDs = {1443}, coords = { {x = 74.8, y = 45.6} }, faction = "Alliance" },
    -- Tanaris (1446)
    { npc = "Jabbey", mapIDs = {1446}, coords = { {x = 67, y = 22} }, faction = "Neutral" },
    -- Östliche Pestländer (1423)
    { npc = "Verwalter Alen", mapIDs = {1423}, coords = { {x = 79.4, y = 63.8} }, faction = "Neutral" },
    -- Moonglade (1450)
    { npc = "Daeolyn Summerleaf", mapIDs = {1450}, coords = { {x = 45.2, y = 34.4} }, faction = "Neutral" },
    -- Desolace (1444)
    { npc = "Tukk", mapIDs = {1444}, coords = { {x = 66.4, y = 6.8} }, faction = "Horde" },
    -- Un'Goro (1449)
    { npc = "Nergal", mapIDs = {1449}, coords = { {x = 43.2, y = 7.8} }, faction = "Neutral" },
    -- Azshara (1447)
    { npc = "Brinna Valanaar", mapIDs = {1447}, coords = { {x = 12, y = 78.2} }, faction = "Alliance" },
    -- Sengende Schlucht (1427)
    { npc = "Meisterschmied Burninate", mapIDs = {1427}, coords = { {x = 38.6, y = 28.4} }, faction = "Neutral" },
    -- Silithus (1451)
    { npc = "Calandrath", mapIDs = {1451}, coords = { {x = 51.8, y = 39} }, faction = "Neutral" },
    -- Hinterland (1425)
    { npc = "Renn'az", mapIDs = {1425}, coords = { {x = 76.8, y = 81.2} }, faction = "Horde" },
    -- Dun Morogh (1426)
    { npc = "Adlin Pridedrift", mapIDs = {1426}, coords = { {x = 30, y = 71.6} }, faction = "Alliance" },
    -- Tirisfal (1420)
    { npc = "Joshua Kien", mapIDs = {1420}, coords = { {x = 32.2, y = 65.4} }, faction = "Horde" },
    -- Mulgore (1412)
    { npc = "Kawnie Softbreeze", mapIDs = {1412}, coords = { {x = 45.2, y = 76.4} }, faction = "Horde" },
    { npc = "Moorat Longstride", mapIDs = {1412}, coords = { {x = 45.2, y = 76.6} }, faction = "Horde" },
}

BeastAndBow.BreadVendors = {
    -- Thunder Bluff
    { npc = "Fyr Mistrunner", mapIDs = {1638, 1456}, coords = { {x = 41.44, y = 53.19} }, faction = "Horde" },
    -- Mulgore (1412)
    { npc = "Gastwirt Kauth", mapIDs = {1412}, coords = { {x = 44.6, y = 77.8} }, faction = "Horde" },
    -- Brachland (1413)
    { npc = "Moorane Hearthgrain", mapIDs = {1413}, coords = { {x = 52.2, y = 30.4} }, faction = "Horde" },
    -- Schlingendorntal (1434)
    { npc = "Nargatt", mapIDs = {1434}, coords = { {x = 27.0, y = 77.2} }, faction = "Horde" },
    -- Feralas (1443)
    { npc = "Gastwirtin Greul", mapIDs = {1443}, coords = { {x = 75.4, y = 43.8} }, faction = "Horde" },
    -- Brennende Steppe (1428)
    { npc = "Gruna", mapIDs = {1428}, coords = { {x = 65.4, y = 24.0} }, faction = "Horde" },
    -- Westfall (1430)
    { npc = "Bauer Saldean", mapIDs = {1430}, coords = { {x = 56.0, y = 31.2} }, faction = "Alliance" },
    -- Wald von Elwynn (1429)
    { npc = "Kira Songshine", mapIDs = {1429}, coords = { {x = 33.0, y = 51.2} }, faction = "Alliance" },
    -- Stormwind
    { npc = "Thomas Miller", mapIDs = {1519, 1453}, coords = { {x = 52.2, y = 60.4} }, faction = "Alliance" },
    -- Ironforge
    { npc = "Myra Tyrngaarde", mapIDs = {1537, 1455}, coords = { {x = 23.0, y = 61.4} }, faction = "Alliance" },
    -- Loch Modan (1432)
    { npc = "Gastwirt Hearthstove", mapIDs = {1432}, coords = { {x = 35.2, y = 49.4} }, faction = "Alliance" },
    -- Ashenvale (1441)
    { npc = "Nantar", mapIDs = {1441}, coords = { {x = 37.0, y = 49.8} }, faction = "Alliance" },
    -- Hinterland (1425)
    { npc = "Gastwirt Thulfram", mapIDs = {1425}, coords = { {x = 13.4, y = 41.8} }, faction = "Alliance" },
    -- Dustwallow (1445)
    { npc = "Dwane Wertle", mapIDs = {1445}, coords = { {x = 68.2, y = 47.4} }, faction = "Alliance" },
    -- Rotkammgebirge (1433)
    { npc = "Gretchen Vogel", mapIDs = {1433}, coords = { {x = 22.6, y = 44.2} }, faction = "Alliance" },
    -- Desolace (1444)
    { npc = "Gastwirtin Lyshaerya", mapIDs = {1444}, coords = { {x = 66.2, y = 6.6} }, faction = "Alliance" },
    -- Dunkelküste (1440)
    { npc = "Kyndri", mapIDs = {1440}, coords = { {x = 36.8, y = 44.4} }, faction = "Alliance" },
    -- Teldrassil (1438)
    { npc = "Danlyia", mapIDs = {1438}, coords = { {x = 55.4, y = 57.0} }, faction = "Alliance" },
    -- Hillsbrad (1424)
    { npc = "Gastwirt Anderson", mapIDs = {1424}, coords = { {x = 51.0, y = 59.0} }, faction = "Alliance" },
    -- Feralas (1443)
    { npc = "Mardrack Greenwell", mapIDs = {1443}, coords = { {x = 75.4, y = 43.8} }, faction = "Alliance" },
    -- Dun Morogh (1426)
    { npc = "Kazan Mogosh", mapIDs = {1426}, coords = { {x = 47.4, y = 52.4} }, faction = "Alliance" },
    -- Tirisfal (1420)
    { npc = "Joshua Kien", mapIDs = {1420}, coords = { {x = 32.2, y = 65.4} }, faction = "Horde" },
    -- Verwüstete Lande (1436)
    { npc = "Bernie Heisten", mapIDs = {1436}, coords = { {x = 63.4, y = 16.8} }, faction = "Alliance" },
    -- Westliche Pestländer (1422)
    { npc = "Bäcker Masterson", mapIDs = {1422}, coords = { {x = 69.4, y = 79.4} }, faction = "Neutral" },
    -- Östliche Pestländer (1423)
    { npc = "Jessica Chambers", mapIDs = {1423}, coords = { {x = 81.4, y = 58.2} }, faction = "Neutral" },
    -- Steinkrallengebirge (1442)
    { npc = "Gastwirtin Faralia", mapIDs = {1442}, coords = { {x = 35.6, y = 5.8} }, faction = "Neutral" },
}

BeastAndBow.FishVendors = {
    -- Redridge (1433)
    { npc = "Vernon Hale", mapIDs = {1433}, coords = { {x = 27.49, y = 47.83} }, faction = "Alliance" },
    -- Loch Modan (1432)
    { npc = "Khara Deepwater", mapIDs = {1432}, coords = { {x = 40.28, y = 39.28} }, faction = "Alliance" },
    -- Stranglethorn (1434)
    { npc = "Wigcik", mapIDs = {1434}, faction = "Neutral" },
    -- Wetlands (1437)
    { npc = "Stuart Fleming", mapIDs = {1437}, coords = { {x = 8, y = 58.2} }, faction = "Alliance" },
    -- Barrens (1413)
    { npc = "Kilxx", mapIDs = {1413}, coords = { {x = 62.8, y = 38.2} }, faction = "Neutral" },
    -- Hillsbrad (1424)
    { npc = "Hal McAllister", mapIDs = {1424}, coords = { {x = 49.8, y = 62.2} }, faction = "Alliance" },
    -- Darkshore (1440)
    { npc = "Laird", mapIDs = {1440}, coords = { {x = 36.8, y = 44.2} }, faction = "Alliance" },
    -- Darnassus (1439/1657)
    { npc = "Talaelar", mapIDs = {1439, 1657}, coords = { {x = 47, y = 56.2} }, faction = "Alliance" },
    -- Westfall (1430)
    { npc = "Kriggon Talsone", mapIDs = {1430}, coords = { {x = 36.2, y = 90} }, faction = "Alliance" },
    -- Ashenvale (1441)
    { npc = "Innkeeper Kimlya", mapIDs = {1441}, coords = { {x = 11.8, y = 34} }, faction = "Alliance" },
    -- Feralas (1443)
    { npc = "Harklane", mapIDs = {1443}, coords = { {x = 31, y = 46.2} }, faction = "Alliance" },
    -- Tanaris (1446)
    { npc = "Gikkix", mapIDs = {1446}, coords = { {x = 66.6, y = 22} }, faction = "Neutral" },
    -- Winterspring (1452)
    { npc = "Himmik", mapIDs = {1452}, coords = { {x = 61.2, y = 39} }, faction = "Neutral" },
    -- Hinterlands (1425)
    { npc = "Lard", mapIDs = {1425}, coords = { {x = 78.2, y = 81.2} }, faction = "Horde" },
}

BeastAndBow.CheeseVendors = {
    -- Elwynn (1429)
    { npc = "Innkeeper Farley", mapIDs = {1429}, coords = { {x = 43.77, y = 65.80} }, faction = "Alliance" },
    -- Stormwind
    { npc = "Elaine Trias", mapIDs = {1519, 1453}, coords = { {x = 60.59, y = 63.24} }, faction = "Alliance" },
    -- Dun Morogh (1426)
    { npc = "Kazan Mogosh", mapIDs = {1426}, coords = { {x = 68.61, y = 54.64} }, faction = "Alliance" },
    -- Redridge (1433)
    { npc = "Bartender Wental", mapIDs = {1433}, coords = { {x = 26.71, y = 43.91} }, faction = "Alliance" },
    -- Duskwood (1431)
    { npc = "Innkeeper Trelayne", mapIDs = {1431}, coords = { {x = 73.87, y = 44.41} }, faction = "Alliance" },
    -- Thunder Bluff
    { npc = "Innkeeper Pala", mapIDs = {1638, 1456}, coords = { {x = 45.81, y = 64.71} }, faction = "Horde" },
    -- Desolace (1444)
    { npc = "Innkeeper Sikewa", mapIDs = {1444}, coords = { {x = 24.0, y = 68.2} }, faction = "Horde" },
    -- Hillsbrad (1424)
    { npc = "Innkeeper Anderson", mapIDs = {1424}, coords = { {x = 51.17, y = 58.93} }, faction = "Neutral" },
    -- Burning Steppes (1428)
    { npc = "Gabrielle Chase", mapIDs = {1428}, coords = { {x = 84.2, y = 67.8} }, faction = "Neutral" },
    -- Blasted Lands (1436)
    { npc = "Bernie Heisten", mapIDs = {1436}, coords = { {x = 63.5, y = 16.8} }, faction = "Neutral" },
    -- Hinterlands (1425)
    { npc = "Truk Wildbeard", mapIDs = {1425}, coords = { {x = 14.4, y = 42.5} }, faction = "Neutral" },
    -- Dustwallow (1445)
    { npc = "Dwane Wertle", mapIDs = {1445}, coords = { {x = 66.8, y = 45.2} }, faction = "Neutral" },
    -- Swamp of Sorrows (1435)
    { npc = "Innkeeper Karakul", mapIDs = {1435}, coords = { {x = 45.0, y = 56.5} }, faction = "Neutral" },
    -- Arathi (1417)
    { npc = "Innkeeper Adegwa", mapIDs = {1417}, coords = { {x = 73.8, y = 32.5} }, faction = "Neutral" },
}

BeastAndBow.FruitVendors = {
    -- Ironforge
    { npc = "Bimble Longberry", mapIDs = {1537, 1455}, coords = { {x = 26.84, y = 27.74} }, faction = "Alliance" },
    -- Stranglethorn (1434)
    { npc = "Corporal Bluth", mapIDs = {1434}, coords = { {x = 37.96, y = 2.99} }, faction = "Alliance" },
    -- Elwynn (1429)
    { npc = "Homer Stonefield", mapIDs = {1429}, coords = { {x = 33.69, y = 82.90} }, faction = "Alliance" },
    -- Redridge (1433)
    { npc = "Lamar Veisilli", mapIDs = {1433}, coords = { {x = 21.07, y = 46.25} }, faction = "Alliance" },
    -- Darnassus (1439/1657)
    { npc = "Innkeeper Saelienne", mapIDs = {1439, 1657}, coords = { {x = 67.42, y = 15.65} }, faction = "Alliance" },
    -- Ashenvale (1441)
    { npc = "Maliynn", mapIDs = {1441}, coords = { {x = 36.62, y = 49.98} }, faction = "Alliance" },
    -- Darkshore (1440)
    { npc = "Allyndia", mapIDs = {1440}, coords = { {x = 37.12, y = 43.62} }, faction = "Alliance" },
    -- Feralas (1443)
    { npc = "Innkeeper Shyria", mapIDs = {1443}, coords = { {x = 30.97, y = 43.49} }, faction = "Alliance" },
    -- Thunder Bluff
    { npc = "Nan Mistrunner", mapIDs = {1638, 1456}, coords = { {x = 47.34, y = 42.49} }, faction = "Horde" },
    -- Orgrimmar
    { npc = "Shan'ti", mapIDs = {1637, 1454}, coords = { {x = 37.4, y = 52.4} }, faction = "Horde" },
    -- Barrens (1413)
    { npc = "Innkeeper Byula", mapIDs = {1413}, coords = { {x = 45.58, y = 59.04} }, faction = "Horde" },
    -- Arathi (1417)
    { npc = "Targot Jinglepocket", mapIDs = {1417}, coords = { {x = 46.4, y = 45.4}, {x = 46.4, y = 45.6} }, faction = "Neutral" },
    -- Eastern Plaguelands (1423)
    { npc = "Malorie", mapIDs = {1423}, coords = { {x = 95.2, y = 78.8} }, faction = "Neutral" },
}

BeastAndBow.MushroomVendors = {
    -- Duskwood (1431)
    { npc = "Scott Carevin", mapIDs = {1431}, coords = { {x = 75.83, y = 48.70} }, faction = "Alliance" },
    -- Orgrimmar
    { npc = "Kor'jus", mapIDs = {1637, 1454}, coords = { {x = 49, y = 54}, {x = 49.4, y = 53.4} }, faction = "Horde" },
    -- Hillsbrad (1424)
    { npc = "Jason Lemieux", mapIDs = {1424}, coords = { {x = 60.51, y = 19.53} }, faction = "Neutral" },
    -- Tirisfal (1420)
    { npc = "Hamlin Atkins", mapIDs = {1420}, coords = { {x = 58.34, y = 50.70} }, faction = "Horde" },
    -- Undercity (1458 / 1497)
    { npc = "Tawny Grisette", mapIDs = {1458, 1497}, coords = { {x = 65.19, y = 49.84} }, faction = "Horde" },
    { npc = "Morley Bates", mapIDs = {1458, 1497}, coords = { {x = 72.93, y = 26.73} }, faction = "Neutral" },
    -- Silverpine (1421)
    { npc = "Gwyn Farrow", mapIDs = {1421}, coords = { {x = 44.04, y = 39.77} }, faction = "Horde" },
    -- Desolace (1444)
    { npc = "Janet Hommers", mapIDs = {1444}, coords = { {x = 51.2, y = 53.2} }, faction = "Alliance" },
    -- Eastern Plaguelands (1423)
    { npc = "Caretaker Alen", mapIDs = {1423}, coords = { {x = 79.4, y = 63.8} }, faction = "Neutral" },
}

BeastAndBow.MeatVendors = {
    -- Swamp of Sorrows (1435)
    { npc = "Thultash", mapIDs = {1435}, coords = { {x = 46.53, y = 54.29} }, faction = "Horde" },
    -- Wetlands (1437)
    { npc = "Innkeeper Helbrek", mapIDs = {1437}, coords = { {x = 10.70, y = 60.95} }, faction = "Alliance" },
    -- Hillsbrad (1424)
    { npc = "Bront Coldcleave", mapIDs = {1424}, coords = { {x = 48.75, y = 57.20} }, faction = "Alliance" },
    { npc = "Innkeeper Shay", mapIDs = {1424}, coords = { {x = 62.78, y = 19.03} }, faction = "Horde" },
    -- Arathi (1417)
    { npc = "Narj Deepslice", mapIDs = {1417}, coords = { {x = 45.54, y = 47.61} }, faction = "Alliance" },
    { npc = "Uttnar", mapIDs = {1417}, coords = { {x = 74.18, y = 33.96} }, faction = "Horde" },
    -- Thunder Bluff
    { npc = "Kaga Mistrunner", mapIDs = {1638, 1456}, coords = { {x = 52.30, y = 47.79} }, faction = "Horde" },
    -- Redridge (1433)
    { npc = "Sherman Femmel", mapIDs = {1433}, coords = { {x = 26.73, y = 43.24} }, faction = "Alliance" },
    -- Orgrimmar
    { npc = "Olvia", mapIDs = {1637, 1454}, coords = { {x = 54.4, y = 68.0} }, faction = "Horde" },
    -- Stonetalon (1442)
    { npc = "Denni'ka", mapIDs = {1442}, coords = { {x = 47.4, y = 62.0} }, faction = "Horde" },
    -- Barrens (1413)
    { npc = "Zargh", mapIDs = {1413}, coords = { {x = 52.4, y = 29.8} }, faction = "Horde" },
    -- Azshara (1447)
    { npc = "Kurll", mapIDs = {1447}, coords = { {x = 21.8, y = 52.0} }, faction = "Neutral" },
    -- Durotar (1411)
    { npc = "Grimtak", mapIDs = {1411}, coords = { {x = 51.2, y = 42.4} }, faction = "Horde" },
    -- Elwynn (1429)
    { npc = "Toddrick", mapIDs = {1429}, coords = { {x = 44.2, y = 66.0} }, faction = "Alliance" },
    -- Ashenvale (1441)
    { npc = "Ulthaan", mapIDs = {1441}, coords = { {x = 50.0, y = 66.6} }, faction = "Alliance" },
    -- Darnassus (1439/1657)
    { npc = "Jaeana", mapIDs = {1439, 1657}, coords = { {x = 59.8, y = 66.6} }, faction = "Alliance" },
    -- Hinterlands (1425)
    { npc = "Truk Wildbeard", mapIDs = {1425}, coords = { {x = 14.4, y = 42.4} }, faction = "Alliance" },
    -- Dustwallow (1445)
    { npc = "Ogg'marr", mapIDs = {1445}, coords = { {x = 66.8, y = 45.2} }, faction = "Horde" },
    -- Ironforge
    { npc = "Innkeeper Firebrew", mapIDs = {1537, 1455}, coords = { {x = 55.4, y = 81.4} }, faction = "Alliance" },
    -- Stranglethorn (1434)
    { npc = "Nargatt", mapIDs = {1434}, coords = { {x = 32.2, y = 29.2} }, faction = "Horde" },
    -- Tanaris (1446)
    { npc = "Innkeeper Fizzgrimble", mapIDs = {1446}, coords = { {x = 52.6, y = 28.0} }, faction = "Neutral" },
    -- Badlands (1418)
    { npc = "Innkeeper Shul'kar", mapIDs = {1418}, coords = { {x = 2.8, y = 45.8} }, faction = "Horde" },
    -- Winterspring (1452)
    { npc = "Innkeeper Vizzie", mapIDs = {1452}, coords = { {x = 61.2, y = 38.8} }, faction = "Neutral" },
    -- Un'Goro (1449)
    { npc = "Nergal", mapIDs = {1449}, coords = { {x = 43.2, y = 7.8} }, faction = "Neutral" },
    -- Searing Gorge (1427)
    { npc = "Master Smith Burninate", mapIDs = {1427}, coords = { {x = 38.6, y = 28.4} }, faction = "Neutral" },
    -- Silithus (1451)
    { npc = "Calandrath", mapIDs = {1451}, coords = { {x = 51.8, y = 39.0} }, faction = "Neutral" },
    -- Eastern Plaguelands (1423)
    { npc = "Malorie", mapIDs = {1423}, coords = { {x = 95.2, y = 78.8} }, faction = "Neutral" }
}