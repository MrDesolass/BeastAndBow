BeastAndBow = BeastAndBow or {}
local BAB = BeastAndBow -- shorthand for data tables (PetCategories, Abilities)
local HBD = LibStub("HereBeDragons-2.0")

BeastAndBow_Settings = BeastAndBow_Settings or {}

-- Round-trip tolerance (percentage points) for verifying zone-percent conversions
if type(BeastAndBow_Settings.roundTripTolerance) ~= "number" then
    BeastAndBow_Settings.roundTripTolerance = 1.0 -- default 1% (was 2.0)
end

BeastAndBow_StableSeen = BeastAndBow_StableSeen or {}

BeastAndBow.MapIDToHBDUI = {
    -- This table converts continent-style Map IDs to the uiMapID format
    -- that HereBeDragons often expects for its calculations.
    -- Sourced from wow.tools and common addon knowledge for Classic Era.

    -- Continents
    [1415] = 1,  -- Kalimdor
    [1414] = 2,  -- Eastern Kingdoms

    -- Kalimdor Zones
    [1411] = 14,  -- Durotar
    [1412] = 215, -- Mulgore
    [1413] = 17,  -- The Barrens
    [1438] = 141, -- Teldrassil
    [1439] = 148, -- Darkshore
    [1440] = 331, -- Ashenvale
    [1441] = 400, -- Thousand Needles
    [400]  = 400, -- Thousand Needles (is already a uiMapID)
    [1442] = 406, -- Stonetalon Mountains
    [1443] = 405, -- Desolace
    [1444] = 357, -- Feralas
    [357]  = 357, -- Feralas (is already a uiMapID)
    [1445] = 15,  -- Dustwallow Marsh
    [1446] = 440, -- Tanaris
    [1447] = 16,  -- Azshara
    [1448] = 361, -- Felwood
    [1449] = 490, -- Un'Goro Crater
    [1450] = 493, -- Moonglade
    [1451] = 1377,-- Silithus
    [1452] = 618, -- Winterspring

    -- Eastern Kingdoms Zones
    [1416] = 36,  -- Alterac Mountains
    [1417] = 132, -- Arathi Highlands (Classic) -> Arathi Highlands in HBD is 4. ID 132 seems legacy. Let's provide both.
    [1418] = 3,   -- Badlands
    [1419] = 4,   -- Blasted Lands
    [1420] = 139, -- Tirisfal Glades
    [1421] = 130, -- Silverpine Forest
    [1422] = 28,  -- Western Plaguelands
    [1423] = 13,  -- Eastern Plaguelands
    [1424] = 267, -- Hillsbrad Foothills
    [1425] = 41,  -- The Hinterlands
    [1426] = 1,   -- Dun Morogh
    [1427] = 51,  -- Searing Gorge
    [1428] = 46,  -- Burning Steppes
    [1429] = 12,  -- Elwynn Forest
    [1430] = 47,  -- Deadwind Pass
    [1431] = 10,  -- Duskwood
    [1432] = 38,  -- Loch Modan
    [1433] = 33,  -- Redridge Mountains (ID for STV in old list was 33, which is Redridge)
    [1434] = 33,  -- Stranglethorn Vale (Correct uiMapID for STV is 33)
    [1435] = 44,  -- Swamp of Sorrows
    [1436] = 40,  -- Westfall
    [1437] = 11,  -- Wetlands

    -- Cities (Old ID -> uiMapID) - some of these are redundant but harmless
    [1519] = 87,  -- Stormwind City
    [1453] = 87,  -- Stormwind City
    [1537] = 88,  -- Ironforge
    [1455] = 88,  -- Ironforge
    [1657] = 90,  -- Darnassus
    [1457] = 90,  -- Darnassus
    [1637] = 85,  -- Orgrimmar
    [1454] = 85,  -- Orgrimmar
    [1497] = 86,  -- Undercity
    [1458] = 86,  -- Undercity
    [1638] = 89,  -- Thunder Bluff
    [1456] = 89,  -- Thunder Bluff

    -- TBC Outland (added dynamically if in TBC)
    -- Will be merged from TBC_Data.lua when available
}

-- Localize commonly used global functions for performance and lint clarity
local _G = _G
    -- This is used to trigger a travel warning when leaving a capital.
    -- The list is a combination of main city IDs provided by the user and
    -- sub-zone IDs discovered through logs, as capital cities can consist
    -- of multiple map zones. This list may need to be expanded in the future.
    
    local babTooltipScanner -- Our hidden frame for scanning tooltips
    local ammoSelectorFrame -- Holder for the ammo picker frame
    
    -- Module-level upvalues for UI elements (to avoid global taint)
    local frame, icon, countText
    local buttonsContainer, collapseButton, collapseIcon, arrowButton
    
BeastAndBow.cachedQuiverInfo = BeastAndBow.cachedQuiverInfo or { bagID = nil, totalSlots = 0 }

    -- forward declare
    local AutoDetectAmmo, startBlink, stopBlink, Update
    local ApplyCollapseState, ToggleCollapse
    -- Custom collapse/expand button textures
    local COLLAPSE_TEXTURE_UP   = "Interface\\AddOns\\BeastAndBow\\Textures\\arrow_up"   -- shown when expanded (indicates you can collapse)
    local COLLAPSE_TEXTURE_DOWN = "Interface\\AddOns\\BeastAndBow\\Textures\\arrow_down" -- shown when collapsed (indicates you can expand)

    local capitalCityMapIDs = {
        -- Orgrimmar
        [1637] = true, -- Orgrimmar City
        [1454] = true, -- Orgrimmar Zone

        -- Stormwind
        [1519] = true, -- Stormwind City
        [1453] = true, -- Stormwind Zone
        [55] = true,   -- Valley of Heroes
        [717] = true,  -- The Stockade (Dungeon inside SW)

        -- Thunder Bluff
        [1638] = true, -- Thunder Bluff City
        [1456] = true, -- Thunder Bluff Zone

        -- Undercity
        [1497] = true, -- Undercity City
        [1458] = true, -- Undercity Zone

        -- Ironforge
        [1537] = true, -- Ironforge City
        [1455] = true, -- Ironforge Zone

        -- Darnassus
        [1657] = true, -- Darnassus City
        [1457] = true, -- Darnassus Zone
    }

    local function IsPlayerInCapitalCity(mapID)
        -- Quiet helper: walk up the map hierarchy and check if any ancestor is in the capital list
        if not mapID or not C_Map or not C_Map.GetMapInfo then return false end
        local currentMapID = mapID
        local visited = {}
        while currentMapID and currentMapID ~= 0 and not visited[currentMapID] do
            if capitalCityMapIDs[currentMapID] then return true end
            visited[currentMapID] = true
            local ok, info = pcall(C_Map.GetMapInfo, currentMapID)
            if not ok or not info or not info.parentMapID or info.parentMapID == 0 then break end
            currentMapID = info.parentMapID
        end
        return false
    end

    -- (duplicate declarations removed) 
    
    -- Compatibility wrappers (Classic vs other runtimes)
    local Container_GetNumSlots
    if C_Container and C_Container.GetContainerNumSlots then
        Container_GetNumSlots = C_Container.GetContainerNumSlots
    elseif GetContainerNumSlots then
        Container_GetNumSlots = GetContainerNumSlots
    else
        Container_GetNumSlots = function() return 0 end
    end

    local Container_GetItemInfo
    if C_Container and C_Container.GetContainerItemInfo then
        Container_GetItemInfo = C_Container.GetContainerItemInfo
    elseif GetContainerItemInfo then
        Container_GetItemInfo = GetContainerItemInfo
    else
        Container_GetItemInfo = function() return nil end
    end

    local Container_GetItemLink
    if C_Container and C_Container.GetContainerItemLink then
        Container_GetItemLink = C_Container.GetContainerItemLink
    elseif GetContainerItemLink then
        Container_GetItemLink = GetContainerItemLink
    else
        Container_GetItemLink = function() return nil end
    end

    local Item_GetInfo
    if C_Item and C_Item.GetItemInfo then
        Item_GetInfo = C_Item.GetItemInfo
    elseif GetItemInfo then
        Item_GetInfo = GetItemInfo
    else
        Item_GetInfo = function() return end
    end

    local NUM_BAGS = NUM_BAG_SLOTS or 4
    local INV_AMMO = INVSLOT_AMMO or 0 -- For GetInventoryItemCount, 0 is the ammo slot
    local INV_RANGED = INVSLOT_RANGED or 18

    local function GetMaxAmmoCapacity(forDebug)
        -- Pre-cache custom sound
        if not lowAmmoSoundID then
            local path = "Interface\\AddOns\\BeastAndBow\\Sounds\\Soundalert.ogg"
            -- Register the file as a sound; fallback to PlaySoundFile path if ID not returned on Era
            if SOUNDKIT and type(SOUNDKIT) == "table" and SOUNDKIT.UI_BNet_Toast then
                -- noop; no registry API in Classic, use path directly
            end
            lowAmmoSoundID = path -- store path; PlaySoundFile accepts string
        end
        -- Create the scanner on demand
        if not babTooltipScanner then
            babTooltipScanner = CreateFrame("GameTooltip", "BeastAndBowTooltipScanner", UIParent, "GameTooltipTemplate")
                    babTooltipScanner:SetOwner(UIParent, "ANCHOR_NONE")
                end
        if forDebug then bab_print(BeastAndBow.L.STARTING_QUIVER_SEARCH) end

        -- Reset cache before search
        BeastAndBow.cachedQuiverInfo = { bagID = nil, totalSlots = 0 }

        -- In Classic, quivers are equipped in bag slots to provide their haste bonus.
        -- We must check inventory slots 20-23 (bag slots 1-4).
        for slotId = 20, 23 do
            local itemLink = GetInventoryItemLink("player", slotId)
            if itemLink then
                local itemName, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = Item_GetInfo(itemLink)
                if forDebug then bab_print(string.format(BeastAndBow.L.BAG_INFO, slotId - 19, itemName or "Unknown", (itemClassID or "nil"), (itemSubClassID or "nil"), "N/A")) end

                -- Check if it's actually a quiver or ammo pouch
                if itemClassID == 1 and (itemSubClassID == 2 or itemSubClassID == 3) then
                    if forDebug then bab_print(string.format("Found quiver/pouch in bag slot %d: %s", slotId - 19, itemName))
                    end
                    
                    -- Scan its tooltip for capacity
                    babTooltipScanner:ClearLines()
                    babTooltipScanner:SetHyperlink(itemLink)

                    local numSlots = 0
                    for i = 2, babTooltipScanner:NumLines() do
                        local lineText = _G["BeastAndBowTooltipScannerTextLeft"..i]:GetText()
                        if lineText then
                            local slots = tonumber(string.match(lineText, "(%d+)[-%s]*Platz") or string.match(lineText, "(%d+)[-%s]*Slot"))
                            if slots then
                                numSlots = slots
                                if forDebug then bab_print(string.format("  -> Found capacity in tooltip: %d slots", numSlots))
                                end
                                break
                            end
                        end
                    end
                    
                    if numSlots > 0 then
                        -- CACHE the found info
                        BeastAndBow.cachedQuiverInfo = { bagID = slotId - 19, totalSlots = numSlots }
                        if forDebug then bab_print(string.format("  -> Caching quiver info: bagID=%d, totalSlots=%d", slotId - 19, numSlots)) end

                        local capacity = numSlots * 200 -- Ammo stacks are 200
                        if forDebug then bab_print(string.format("Calculated capacity: %d", capacity))
                        end
                        return capacity, slotId - 19 -- Return capacity and bagID
                    else
                        if forDebug then bab_print("  -> Could not find capacity in tooltip for this item.")
                        end
                    end
                end
            end
        end

        -- (Removed temporary fallback menu buttons)

        if forDebug then bab_print(BeastAndBow.L.NO_QUIVER_FOUND) end
        return 800, nil -- Return fallback capacity and nil for bagID
    end
    
        local function GetUI(name)
            return _G and _G[name]
        end

    -- Count only the currently equipped ammo item (ammo slot + matching stacks in bags).
    local function GetTotalAmmoCountAndLink()
        local function dbg(msg)
            if BeastAndBow_Settings and BeastAndBow_Settings.debug and type(bab_print) == "function" then
                bab_print(msg, BeastAndBow.Debug.LEVELS.DEBUG)
            end
        end

        local ammoLink = GetInventoryItemLink("player", INV_AMMO)
        local ammoID = (ammoLink and tonumber(ammoLink:match("item:(%d+)") )) or GetInventoryItemID("player", INV_AMMO)

        if not ammoID then
            dbg(BeastAndBow.L.DEBUG_NO_ITEM_IN_AMMO_SLOT)
            return 0, nil
        end

        local totalCount = 0

        -- Count matching stacks in bags
        for bag = 0, NUM_BAG_SLOTS do
            local numSlots = Container_GetNumSlots(bag)
            if numSlots and numSlots > 0 then
                for slot = 1, numSlots do
                    local link = Container_GetItemLink(bag, slot)
                    local id = link and tonumber(link:match("item:(%d+)") )

                    -- If link missing, try itemID from container info
                    if not id then
                        local info = Container_GetItemInfo(bag, slot)
                        if type(info) == "table" then
                            id = info.itemID
                        end
                    end

                    if id == ammoID then
                        local count = 0
                        local itemInfo = Container_GetItemInfo(bag, slot)
                        if type(itemInfo) == "table" then
                            count = itemInfo.stackCount or 0
                        elseif itemInfo then
                            count = select(2, Container_GetItemInfo(bag, slot)) or 0
                        end
                        totalCount = totalCount + (count or 0)
                    end
                end
            end
        end

        dbg(string.format(BeastAndBow.L.DEBUG_FINISHED_AMMO_TOTAL, totalCount))

        return totalCount, ammoLink
    end

    local function TriggerTravelWarning(percentage)
        if travelWarningPlayed then return end
        if not BeastAndBow_Settings or not BeastAndBow_Settings.warningSystemEnabled then return end

        startBlink()
        
        if lowAmmoSoundID then
            PlaySoundFile(lowAmmoSoundID, "SFX")
        else
            PlaySound(1137, "SFX")
        end
        
        local warningMessage = BeastAndBow.L.MEDIUM_AMMO_WARNING
        if percentage and percentage <= 35 then
            warningMessage = BeastAndBow.L.LOW_AMMO_WARNING
        end
        RaidNotice_AddMessage(RaidWarningFrame, warningMessage, ChatTypeInfo["RAID_WARNING"])
        travelWarningPlayed = true
        lowAmmoWarningPlayed = true
        lowAmmoBannerShown = true
        lastWarningAt = GetTime and GetTime() or (lastWarningAt + WARNING_COOLDOWN)
    end

    startBlink = function()
        if lowAmmoBlinking then return end
        local button = arrowButton or GetUI("BeastAndBowFindArrowButton")
        if not button then return end
        
        if not button or not button.SetBackdropBorderColor then
            -- Try to add a border if template lacks one
            if button and not button._babBorder then
                local b = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate" or nil)
                b:SetFrameLevel(button:GetFrameLevel()+1)
                b:SetAllPoints(true)
                b:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16})
                b:SetBackdropBorderColor(1, 0.2, 0.2)
                b:Hide()
                button._babBorder = b
            end
        end
        lowAmmoBlinking = true
        local t = 0
        local maxTicks = 60 -- 60 ticks * 0.2s = 12 seconds
        if not button._babTicker then
            button._babTicker = C_Timer.NewTicker(0.2, function()
                t = t + 1
                local on = (t % 2) == 0
                local r, g, b = 1, 1, 0 -- Yellow for all warnings (better visibility)

                if button.SetBackdropBorderColor then
                    if on then
                        button:SetBackdropBorderColor(r, g, b, 1)
                    else
                        button:SetBackdropBorderColor(1, 1, 1, 1)
                    end
                elseif button._babBorder then
                     if on then
                        button._babBorder:SetBackdropBorderColor(r,g,b)
                        button._babBorder:Show()
                     else
                        button._babBorder:Hide()
                     end
                end
                
                -- Auto-stop after 12 seconds
                if t >= maxTicks then
                    if button._babTicker then
                        button._babTicker:Cancel()
                        button._babTicker = nil
                    end
                    lowAmmoBlinking = false
                    -- Reset border to normal
                    if button.SetBackdropBorderColor then
                        button:SetBackdropBorderColor(1, 1, 1, 1)
                    elseif button._babBorder then
                        button._babBorder:Hide()
                    end
                end
            end)
            -- Create reliable in-frame buttons parented to the main Bestiary frame (more robust)
            if main then
                if not _G["BABInFrameButtonsCreated"] then
                    pcall(function()
                        local btnTex = "Interface\\AddOns\\BeastAndBow\\Textures\\buttons"
                        local in1 = CreateFrame("Button", "BABInFramePetsButton", main, "UIPanelButtonTemplate")
                        in1:SetSize(160, 48)
                        in1:SetPoint("TOPLEFT", main, "TOPLEFT", 24, -84)
                        in1:SetToplevel(true)
                        in1:SetClampedToScreen(true)
                        if in1.SetFrameStrata then in1:SetFrameStrata("DIALOG") end
                        if in1.SetFrameLevel then in1:SetFrameLevel(200) end
                        in1:SetText("Tiere")
                        if in1.SetNormalTexture then in1:SetNormalTexture(btnTex); in1:SetPushedTexture(btnTex); in1:SetHighlightTexture(btnTex); local h=in1:GetHighlightTexture(); if h then h:SetAlpha(0.85) end end
                        in1:SetScript("OnClick", function() BeastAndBow.OpenPetsView() end)

                        local in2 = CreateFrame("Button", "BABInFrameAbilitiesButton", main, "UIPanelButtonTemplate")
                        in2:SetSize(160, 48)
                        in2:SetPoint("TOPRIGHT", main, "TOPRIGHT", -24, -84)
                        in2:SetToplevel(true)
                        in2:SetClampedToScreen(true)
                        if in2.SetFrameStrata then in2:SetFrameStrata("DIALOG") end
                        if in2.SetFrameLevel then in2:SetFrameLevel(200) end
                        in2:SetText("FÃ¤higkeiten")
                        if in2.SetNormalTexture then in2:SetNormalTexture(btnTex); in2:SetPushedTexture(btnTex); in2:SetHighlightTexture(btnTex); local h2=in2:GetHighlightTexture(); if h2 then h2:SetAlpha(0.85) end end
                        in2:SetScript("OnClick", function() BeastAndBow.OpenSkillsView() end)

                        _G["BABInFrameButtonsCreated"] = true
                        if in1.Show then in1:Show() end
                        if in2.Show then in2:Show() end
                    end)
                else
                    local in1 = GetUI("BABInFramePetsButton")
                    local in2 = GetUI("BABInFrameAbilitiesButton")
                    if in1 and in1.Show then pcall(in1.Show, in1) end
                    if in2 and in2.Show then pcall(in2.Show, in2) end
                end
            end
        end
    end

    stopBlink = function()
        if not lowAmmoBlinking then return end
        -- Do not stop blinking if a low ammo or travel warning is active
        if lowAmmoWarningPlayed or travelWarningPlayed then return end

        lowAmmoBlinking = false
        local button = arrowButton or GetUI("BeastAndBowFindArrowButton")
        if button then
            if button.SetBackdropBorderColor then
                button:SetBackdropBorderColor(1, 1, 1, 1)
            elseif button._babBorder then
                button._babBorder:Hide()
            end
            if button._babTicker then
                button._babTicker:Cancel()
                button._babTicker = nil
            end
        end
    end

-- Simple fade helper that uses UIFrameFade if available, otherwise falls back to instant show/hide
local function SafeFade(frame, time, fromAlpha, toAlpha, onFinished)
    if not frame then
        if onFinished then pcall(onFinished) end
        return
    end
    if UIFrameFadeOut and UIFrameFadeIn then
        if toAlpha == 0 then
            UIFrameFadeOut(frame, time or 0.15, fromAlpha or frame:GetAlpha() or 1, 0)
            C_Timer.After(time or 0.15, function() if frame.Hide then frame:Hide() end if onFinished then pcall(onFinished) end end)
        else
            frame:Show()
            UIFrameFadeIn(frame, time or 0.15, fromAlpha or 0, toAlpha or 1)
            C_Timer.After(time or 0.15, function() if onFinished then pcall(onFinished) end end)
        end
        return
    end
    -- Fallback: instant
    if toAlpha == 0 then if frame.Hide then frame:Hide() end else frame:Show() end
    if onFinished then pcall(onFinished) end
end

-- Animate collapse/expand by fading and adjusting height (slide effect)
local function AnimateCollapseContainer(container, collapse)
    if not container then return end

    -- Height when collapsed should still show icon, count and collapse button fully
    -- Separate heights: collapsed (minimal) vs header base used when expanded
    local collapsedMinHeight = 60     -- increase for more space so arrow down sits below counter
    local headerBaseHeight   = 85     -- keep enough space for icon + count when expanded
    local fullHeight = 140             -- animation content height baseline (container dynamic portion)

    if not container._babFullHeight or container._babFullHeight == 0 then
        container._babFullHeight = container:GetHeight() or 100
    end
    fullHeight = container._babFullHeight + headerBaseHeight

    if container._babAnimTicker then
        container._babAnimTicker:Cancel()
        container._babAnimTicker = nil
    end

    local duration = 0.3
    local steps = 15
    local stepTime = duration / steps

    local startContainerH = container:GetHeight()
    local targetContainerH = collapse and 0 or container._babFullHeight
    local diffContainer = targetContainerH - startContainerH
    local current = 0

    if not collapse then
        container:SetAlpha(0)
        container:SetHeight(0)
        container:Show()
    else
        container:SetAlpha(1)
        container:Show()
    end

    container._babAnimTicker = C_Timer.NewTicker(stepTime, function()
        current = current + 1
        local frac = current / steps
        local alphaValue = collapse and (1 - frac) or frac
        local heightValue = math.floor(startContainerH + diffContainer * frac + 0.5)

        container:SetHeight(heightValue)
        container:SetAlpha(alphaValue)

        if current >= steps then
            container._babAnimTicker:Cancel()
            container._babAnimTicker = nil
            if collapse then
                container:Hide()
                container:SetAlpha(0)
                container:SetHeight(container._babFullHeight)
            else
                container:SetAlpha(1)
                container:SetHeight(container._babFullHeight)
            end
        end
    end)
end

    local function TravelCheck()
        if travelWarningPlayed then return end
        if not BeastAndBow_Settings or not BeastAndBow_Settings.expectedAmmoClassID then return end
        
        local totalAmmo, _ = GetTotalAmmoCountAndLink()
        if totalAmmo == 0 then return end

        local maxCapacity, _ = GetMaxAmmoCapacity(false)
        if maxCapacity > 0 then
            local percentage = (totalAmmo / maxCapacity) * 100
            if percentage <= 70 then
                TriggerTravelWarning(percentage)
            end
        end
    end

    -- Apply collapse/expand state to the UI with smooth animation and texture swap
    ApplyCollapseState = function(animate)
        if not frame then return end
        buttonsContainer = buttonsContainer or GetUI("BeastAndBowButtonsContainer")
        local optionsContainer = GetUI("BeastAndBowOptionsContainer")
        collapseButton = collapseButton or GetUI("BeastAndBowCollapseButton")
        local title = GetUI("BeastAndBowFrameTitle")
        local nextBtn = GetUI("BeastAndBowNextPageButton")
        local prevBtn = GetUI("BeastAndBowPrevPageButton")
        local closeBtn = GetUI("BeastAndBowCloseButton")
        local collapsed = BeastAndBow_Settings and BeastAndBow_Settings.collapsed
        
        -- Cancel any running animations on both containers to prevent stacking
        if buttonsContainer and buttonsContainer._babAnimTicker then
            buttonsContainer._babAnimTicker:Cancel()
            buttonsContainer._babAnimTicker = nil
        end
        if optionsContainer and optionsContainer._babAnimTicker then
            optionsContainer._babAnimTicker:Cancel()
            optionsContainer._babAnimTicker = nil
        end
        
        -- Dynamically adjust frame size and visibility of elements
        if frame then
            if collapsed then
                frame:SetHeight(145)
                frame:SetWidth(80) -- Compact width
                if title then title:Hide() end
                if nextBtn then nextBtn:Hide() end
                if prevBtn then prevBtn:Hide() end
                if closeBtn then closeBtn:Hide() end
            else
                frame:SetHeight(265)
                frame:SetWidth(240) -- Full width
                if title then title:Show() end
                if closeBtn then closeBtn:Show() end
                BeastAndBow.SetPage(BeastAndBow_Settings and BeastAndBow_Settings.showOptionsPage or false)
            end
        end
        
        -- Only show the active container for the current page; hide the other to prevent overlap
        local onOptions = BeastAndBow_Settings and BeastAndBow_Settings.showOptionsPage
        if collapsed then
            if buttonsContainer then buttonsContainer:Hide() end
            if optionsContainer then optionsContainer:Hide() end
        else
            if onOptions then
                if optionsContainer then 
                    optionsContainer:Show()
                    optionsContainer:SetAlpha(1)
                    if optionsContainer._babFullHeight then
                        optionsContainer:SetHeight(optionsContainer._babFullHeight)
                    end
                end
                if buttonsContainer then buttonsContainer:Hide() end
            else
                if buttonsContainer then 
                    buttonsContainer:Show()
                    buttonsContainer:SetAlpha(1)
                    if buttonsContainer._babFullHeight then
                        buttonsContainer:SetHeight(buttonsContainer._babFullHeight)
                    end
                end
                if optionsContainer then optionsContainer:Hide() end
            end
        end
        -- Swap arrow textures based on collapsed state
        if collapseButton then
            if collapsed then
                collapseButton:SetNormalTexture(COLLAPSE_TEXTURE_DOWN)
                collapseButton:SetPushedTexture(COLLAPSE_TEXTURE_DOWN)
                collapseButton:SetHighlightTexture(COLLAPSE_TEXTURE_DOWN)
            else
                collapseButton:SetNormalTexture(COLLAPSE_TEXTURE_UP)
                collapseButton:SetPushedTexture(COLLAPSE_TEXTURE_UP)
                collapseButton:SetHighlightTexture(COLLAPSE_TEXTURE_UP)
            end
            local h = collapseButton:GetHighlightTexture(); if h then h:SetAlpha(0.85) end
            local n = collapseButton:GetNormalTexture(); if n then n:SetAlpha(1) end

            -- Dynamic re-anchor to avoid overlap with main icon when collapsed
            collapseButton:ClearAllPoints()
            if collapsed then
                -- Collapsed: anchor above frame bottom (consistent positioning)
                collapseButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)
            else
                -- Expanded: also anchor to frame bottom; Lua animation adjusts frame height
                collapseButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)
            end
            -- Position ammo menu arrows relative to icon; shift when collapsed for centered position
            local ammoMenu = GetUI("BeastAndBowAmmoMenuContainer")
            local ammoAnchor = GetUI("BeastAndBowFrameIcon") or frame
            if ammoMenu and ammoAnchor then
                ammoMenu:ClearAllPoints()
                if collapsed then
                    -- When collapsed: closer to icon
                    ammoMenu:SetPoint("RIGHT", ammoAnchor, "LEFT", 2, -2)
                else
                    -- When expanded: just left of the icon
                    ammoMenu:SetPoint("RIGHT", ammoAnchor, "LEFT", -6, -2)
                end
            end

            -- Refresh tooltip text if mouse currently over button
            if collapseButton:IsMouseOver() and GameTooltip and GameTooltip:IsShown() then
                GameTooltip:ClearLines()
                if BeastAndBow_Settings and BeastAndBow_Settings.collapsed then
                    GameTooltip:SetText("Show Buttons")
                else
                    GameTooltip:SetText("Hide Buttons")
                end
                GameTooltip:Show()
            end
        end
    end

    ToggleCollapse = function()
        if not BeastAndBow_Settings then BeastAndBow_Settings = {} end
        BeastAndBow_Settings.collapsed = not BeastAndBow_Settings.collapsed
        PlaySound(856) -- UI checkbox sound
        ApplyCollapseState(true) -- animate on user toggle
        C_Timer.After(0.35, function()
            if BeastAndBow and BeastAndBow.SavePosition then
                BeastAndBow.SavePosition()
            end
        end)
    end

    -- Export for XML callbacks
    BeastAndBow.ToggleCollapse = ToggleCollapse

    -- Restore Update routine (UI icon, count, colors, blink suppression)
    local function Update()
        if not frame or not BeastAndBow_Settings then
            if frame then frame:Hide() end
            return
        end

        icon = icon or GetUI("BeastAndBowFrameIcon")
        countText = countText or GetUI("BeastAndBowFrameCount")
        if not icon or not countText then return end

        -- first update suppression
        if firstUpdateAfterLogin then
            firstUpdateAfterLogin = false
        end

        local maxCapacity = select(1, GetMaxAmmoCapacity(false)) or 0
        local totalAmmo, ammoItemLink = GetTotalAmmoCountAndLink()

        -- pick texture
        local itemTexture = "Interface\\Icons\\INV_Misc_Arrow_01"
        local slotTexture = GetInventoryItemTexture("player", INV_AMMO)
        if slotTexture then
            itemTexture = slotTexture
        elseif ammoItemLink then
            local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(ammoItemLink)
            if texture then itemTexture = texture end
        end

        if BeastAndBow_Settings.frameVisible then frame:Show() else frame:Hide() end
        lastFrameVisibleState = BeastAndBow_Settings.frameVisible
        icon:SetTexture(itemTexture)
        countText:SetText(totalAmmo or 0)

        if maxCapacity > 0 and totalAmmo and totalAmmo > 0 then
            local percentage = (totalAmmo / maxCapacity) * 100
            if percentage > 70 then
                countText:SetTextColor(0.1, 1.0, 0.1)
                lowAmmoWarningPlayed = false; lowAmmoBannerShown = false; travelWarningPlayed = false; stopBlink()
            elseif percentage > 35 then
                countText:SetTextColor(1, 1, 0)
                if not travelWarningPlayed then
                    lowAmmoWarningPlayed = false; lowAmmoBannerShown = false; stopBlink()
                end
            else
                countText:SetTextColor(1.0, 0.1, 0.1)
                if not travelWarningPlayed then
                    lowAmmoWarningPlayed = false; lowAmmoBannerShown = false; stopBlink()
                end
            end
        elseif (totalAmmo or 0) > 0 then
            countText:SetTextColor(0.1, 1.0, 0.1)
            lowAmmoWarningPlayed = false; lowAmmoBannerShown = false; travelWarningPlayed = false; stopBlink()
        end

        if (totalAmmo or 0) == 0 then icon:SetVertexColor(0.5,0.5,0.5) else icon:SetVertexColor(1,1,1) end
    end

    local function DelayedInitialUpdate()
        Update()
    end

    AutoDetectAmmo = function()
        if BeastAndBow_Settings.autoDetect then
            -- Reset first
            BeastAndBow_Settings.expectedAmmoClassID = nil
            BeastAndBow_Settings.expectedAmmoSubClassID = nil

            -- 1. Check Weapon (Priority)
            local rangedWeaponLink = GetInventoryItemLink("player", INV_RANGED) 
            if rangedWeaponLink then
                local _, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfo(rangedWeaponLink)
                if itemClassID == 2 then -- Weapon
                    if itemSubClassID == 2 or itemSubClassID == 18 then -- Bow/Crossbow
                        BeastAndBow_Settings.expectedAmmoClassID = 6 
                        BeastAndBow_Settings.expectedAmmoSubClassID = 2 -- Arrows
                    elseif itemSubClassID == 3 then -- Gun
                        BeastAndBow_Settings.expectedAmmoClassID = 6 
                        BeastAndBow_Settings.expectedAmmoSubClassID = 3 -- Bullets
                    end
                end
            end

            -- 2. Fallback: If no weapon determined the ammo type, check the Ammo Slot (Slot 0)
            if not BeastAndBow_Settings.expectedAmmoClassID then
                local ammoSlotLink = GetInventoryItemLink("player", INV_AMMO)
                if ammoSlotLink then
                    local _, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfo(ammoSlotLink)
                    if itemClassID == 6 then -- It is indeed Ammo
                         BeastAndBow_Settings.expectedAmmoClassID = itemClassID
                         BeastAndBow_Settings.expectedAmmoSubClassID = itemSubClassID
                    end
                end
            end
        end

        -- Update the button text and action (use cached/cautious lookup)
        local button = arrowButton or GetUI("BeastAndBowFindArrowButton")
        if button then
            if BeastAndBow_Settings.expectedAmmoSubClassID == 3 then -- Bullets
                button:SetText(BeastAndBow.L.BULLETS)
                button:SetScript("OnClick", BeastAndBow.FindNearestBulletVendor)
            else -- Default to Arrows
                button:SetText(BeastAndBow.L.ARROWS)
                button:SetScript("OnClick", BeastAndBow.FindNearestArrowVendor)
            end
        end
    end

    --- Scans all carried ammo types (bags + equipped) and returns one entry per ammo item ID.
-- @return Table of ammo entries with name/icon/count/equipped state.
function BeastAndBow.ScanForAmmoTypes()
    local equippedLink = GetInventoryItemLink("player", INVSLOT_AMMO)
    local equippedID = (equippedLink and tonumber(equippedLink:match("item:(%d+)"))) or GetInventoryItemID("player", INVSLOT_AMMO)

    local byID = {}
    local order = {}

    local function ensureEntry(itemID, itemLink)
        if not itemID then return nil end
        local entry = byID[itemID]
        if not entry then
            local name, _, _, _, _, _, _, _, _, icon, _, classID, subClassID = GetItemInfo(itemID)
            if not name then
                name, _, _, _, _, _, _, _, _, icon, _, classID, subClassID = GetItemInfo("item:" .. tostring(itemID))
            end
            if type(GetItemInfoInstant) == "function" then
                local n, _, _, _, _, classInstant, subClassInstant = GetItemInfoInstant(itemID)
                if not name then name = n end
                if not classID then classID = classInstant end
                if not subClassID then subClassID = subClassInstant end
            end

            if classID ~= 6 then
                return nil
            end

            entry = {
                itemID = itemID,
                itemLink = itemLink,
                name = name or "Unknown Ammo",
                icon = icon,
                count = 0,
                isEquipped = (equippedID and itemID == equippedID) or false,
                isUsable = true,
                subClassID = subClassID,
            }
            byID[itemID] = entry
            table.insert(order, itemID)
        elseif itemLink and not entry.itemLink then
            entry.itemLink = itemLink
        end
        return entry
    end

    if equippedID then
        local equippedEntry = ensureEntry(equippedID, equippedLink)
        if equippedEntry then
            local equippedCount = GetInventoryItemCount("player", INVSLOT_AMMO) or 0
            equippedEntry.count = equippedEntry.count + equippedCount
        end
    end

    for bag = 0, NUM_BAG_SLOTS do
        local numSlots = Container_GetNumSlots(bag)
        if numSlots and numSlots > 0 then
            for slot = 1, numSlots do
                local link = Container_GetItemLink(bag, slot)
                local itemID = link and tonumber(link:match("item:(%d+)"))

                local info = Container_GetItemInfo(bag, slot)
                local stackCount = 0
                if type(info) == "table" then
                    itemID = itemID or info.itemID
                    stackCount = info.stackCount or info.count or 0
                else
                    local legacyCount = select(2, Container_GetItemInfo(bag, slot))
                    if type(legacyCount) == "number" then
                        stackCount = legacyCount
                    elseif type(info) == "number" then
                        stackCount = info
                    end
                end

                local entry = ensureEntry(itemID, link)
                if entry then
                    entry.count = entry.count + stackCount
                end
            end
        end
    end

    local result = {}
    for _, itemID in ipairs(order) do
        local entry = byID[itemID]
        if entry and (entry.count or 0) > 0 then
            table.insert(result, entry)
        end
    end

    table.sort(result, function(a, b)
        if a.isEquipped ~= b.isEquipped then
            return a.isEquipped
        end
        return (a.name or "") < (b.name or "")
    end)

    return result
end

--- Equips selected ammo entry by link/id/name.
-- @param ammoData Table from ScanForAmmoTypes.
function BeastAndBow.EquipAmmo(ammoData)
    if not ammoData then return end
    local target = ammoData.itemLink or ammoData.itemID or ammoData.name
    if not target then return end
    EquipItemByName(target)
    BeastAndBow.CloseAmmoSelector()
end

-- This function clears all buttons from the selector frame.
local function ClearAmmoSelectorButtons()
    if not ammoSelectorFrame then return end
    for _, child in ipairs({ ammoSelectorFrame:GetChildren() }) do
        if child:GetName() and string.find(child:GetName(), "BeastAndBowAmmoSelectorButton") then
            child:Hide()
        end
    end
end

--- Creates or updates and shows the icon-based ammo selector frame.
function BeastAndBow.OnAmmoIconClick(self, forceMode, anchorFrame)
    local anchor = (anchorFrame and anchorFrame.GetObjectType and anchorFrame)
        or (self and self.GetObjectType and self)
        or BeastAndBowFrame

    if forceMode == "hide" then
        BeastAndBow.CloseAmmoSelector()
        return
    end

    if ammoSelectorFrame and ammoSelectorFrame:IsShown() and forceMode ~= "show" then
        ammoSelectorFrame:Hide()
        return
    end

    local availableAmmo = BeastAndBow.ScanForAmmoTypes()
    if #availableAmmo == 0 then return end

    if not ammoSelectorFrame then
        ammoSelectorFrame = CreateFrame("Frame", "BeastAndBowAmmoSelectorFrame", BeastAndBowFrame, "BackdropTemplate")
        ammoSelectorFrame:SetBackdrop({ bgFile = "Interface\\AddOns\\BeastAndBow\\Textures\\background" })
        ammoSelectorFrame:SetBackdropColor(1, 1, 1, 1)
        ammoSelectorFrame:SetFrameStrata("HIGH")
        ammoSelectorFrame:SetScript("OnHide", ClearAmmoSelectorButtons)
        ammoSelectorFrame:SetToplevel(true)
        ammoSelectorFrame:EnableMouse(true)
        ammoSelectorFrame:SetClampedToScreen(true)
    end
    
    ClearAmmoSelectorButtons()

    local buttonSize = 36
    local padding = 6
    local maxButtonsPerRow = 4
    local numRows = math.ceil(#availableAmmo / maxButtonsPerRow)
    local numCols = math.min(#availableAmmo, maxButtonsPerRow)

    local frameWidth = (numCols * buttonSize) + ((numCols + 1) * padding)
    local frameHeight = (numRows * buttonSize) + ((numRows + 1) * padding)
    ammoSelectorFrame:SetSize(frameWidth, frameHeight)
    ammoSelectorFrame:ClearAllPoints()
    ammoSelectorFrame:SetPoint("BOTTOM", anchor or BeastAndBowFrame, "TOP", 0, 5)

    for i, ammoData in ipairs(availableAmmo) do
        local row = math.ceil(i / maxButtonsPerRow)
        local col = (i - 1) % maxButtonsPerRow
        
        local btnName = "BeastAndBowAmmoSelectorButton" .. i
        local btn = _G[btnName] or CreateFrame("Button", btnName, ammoSelectorFrame)
        btn:SetSize(buttonSize, buttonSize)

        local xOffset = padding + col * (buttonSize + padding)
        local yOffset = -padding - (row - 1) * (buttonSize + padding)
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", xOffset, yOffset)
        
        btn:SetNormalTexture(ammoData.icon)
        btn:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
        
        btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

        local countText = btn.countText or btn:CreateFontString(nil, "OVERLAY")
        btn.countText = countText
        countText:SetFontObject(GameFontNormal)
        countText:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
        countText:SetJustifyH("RIGHT")
        -- countText:SetFont(select(1, countText:GetFont()), 10, "OUTLINE")
        -- countText:SetText(ammoData.count or 0)

        -- Handle visual state based on equipped/usable status
        if ammoData.isEquipped then
            btn:GetNormalTexture():SetDesaturated(true)
            btn:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0)
        elseif not ammoData.isUsable then
            btn:GetNormalTexture():SetDesaturated(false)
            btn:GetNormalTexture():SetVertexColor(1.0, 0.5, 0.5) -- Red tint for unusable
        else -- Is usable and not equipped
            btn:GetNormalTexture():SetDesaturated(false)
            btn:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0)
        end
        
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if ammoData.itemLink then
                GameTooltip:SetHyperlink(ammoData.itemLink)
            elseif ammoData.itemID and type(GameTooltip.SetItemByID) == "function" then
                GameTooltip:SetItemByID(ammoData.itemID)
            else
                GameTooltip:SetText(ammoData.name or "Ammo")
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Handle click logic based on equipped/usable status
        btn:SetScript("OnClick", function()
            -- Only equip if it's not already equipped and is usable by the player
            if not ammoData.isEquipped and ammoData.isUsable then
                BeastAndBow.EquipAmmo(ammoData)
            end
        end)
        btn:Show()
    end
    
    ammoSelectorFrame:Show()
end

function BeastAndBow.OpenAmmoSelector(anchorFrame)
    BeastAndBow.OnAmmoIconClick(anchorFrame, "show", anchorFrame)
end

function BeastAndBow.CloseAmmoSelector()
    if ammoSelectorFrame and ammoSelectorFrame:IsShown() then
        ammoSelectorFrame:Hide()
    end
end

-- End of new code for ICON ammo switching

function BeastAndBow.OnLoad(self)
        frame = self
        icon = BeastAndBowFrameIcon
        countText = BeastAndBowFrameCount

    if BeastAndBow_Settings then
        BeastAndBow_Settings.autoBuyPetFood = false
        BeastAndBow_Settings.autoBuyPetFoodType = nil
    end

        -- Initialize all settings with proper defaults
        if BeastAndBow_Settings.frameVisible == nil then BeastAndBow_Settings.frameVisible = true end
        if BeastAndBow_Settings.autoDetect == nil then BeastAndBow_Settings.autoDetect = true end
        if BeastAndBow_Settings.warningSystemEnabled == nil or BeastAndBow_Settings.warningSystemEnabled == false then 
            BeastAndBow_Settings.warningSystemEnabled = true 
        end
        if BeastAndBow_Settings.debugVerbose == nil then BeastAndBow_Settings.debugVerbose = false end
            icon = GetUI("BeastAndBowFrameIcon")
            countText = GetUI("BeastAndBowFrameCount")
        if BeastAndBow_Settings.collapsed == nil then BeastAndBow_Settings.collapsed = false end

        -- AutoDetectAmmo() was here, now called later in PLAYER_ENTERING_WORLD


        self:RegisterEvent("PLAYER_ENTERING_WORLD")

        if BeastAndBow_Settings.position and BeastAndBow_Settings.position.point then
            frame:SetPoint(BeastAndBow_Settings.position.point, "UIParent", BeastAndBow_Settings.position.relativePoint, BeastAndBow_Settings.position.x, BeastAndBow_Settings.position.y)
        end
        if BeastAndBow_Settings.frameVisible then frame:Show() else frame:Hide() end
        frame:SetMovable(true)

        -- Apply backdrop background via BackdropTemplate
        local bgPath = "Interface\\AddOns\\BeastAndBow\\Textures\\background"
        if frame.SetBackdrop then
            frame:SetBackdrop({
                bgFile = bgPath,
                edgeFile = nil,
                tile = false, tileSize = 0, edgeSize = 0,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            if frame.SetBackdropColor then
                frame:SetBackdropColor(1, 1, 1, 1)
            end
            if frame.SetBackdropBorderColor then
                frame:SetBackdropBorderColor(0, 0, 0, 0)
            end
        end

        -- Cache UI elements that may be created from XML and apply collapsed state
        C_Timer.After(0.05, function()
                buttonsContainer = GetUI("BeastAndBowButtonsContainer")
                collapseButton = GetUI("BeastAndBowCollapseButton")
                collapseIcon = GetUI("BeastAndBowCollapseButtonIcon") -- legacy icon (will be hidden)
                arrowButton = GetUI("BeastAndBowFindArrowButton")
                -- Ensure main icon/counter fallback
                icon = icon or GetUI("BeastAndBowFrameIcon")
                countText = countText or GetUI("BeastAndBowFrameCount")

            -- Disable Pets button and mark it "Coming Soon" - REMOVED, now a real button
            -- BeastAndBow.OpenPetsOptions() is still defined.

            -- Ensure the "Coming Soon" button is usable and opens the Pets/Bestiarium
            local comingSoonButton = GetUI("BeastAndBowComingSoonButton")
            if comingSoonButton then
                if comingSoonButton.Enable then comingSoonButton:Enable() end
                comingSoonButton:SetText(BeastAndBow.L.COMING_SOON)
                -- Let the button use the default font color from the button template (WoW standard color)
                if not comingSoonButton:GetScript("OnClick") then
                    comingSoonButton:SetScript("OnClick", function()
                        if BeastAndBow and BeastAndBow.OpenPetsOptions then
                            BeastAndBow.OpenPetsOptions()
                        else
                            local f = GetUI("BeastAndBowPetsFrame")
                            if f then ShowUIPanel(f) end
                        end
                    end)
                end
            end
            -- The BeastAndBowPetsButton is now a real button, ensure it uses the correct localized string
            local petsButton = GetUI("BeastAndBowPetsButton")
            if petsButton and petsButton.SetText then
                 petsButton:SetText(BeastAndBow.L.PETS)
            end

            -- Sanitize vendor buttons to remove red Blizzard segments
            if collapseButton and not collapseButton:GetScript("OnClick") then
                collapseButton:SetScript("OnClick", function() if BeastAndBow and BeastAndBow.ToggleCollapse then BeastAndBow.ToggleCollapse() end end)
            end

            -- Add dynamic tooltip for collapse button (hide/show buttons)
            if collapseButton then
                collapseButton:SetScript("OnEnter", function(self)
                    if GameTooltip then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        if BeastAndBow_Settings and BeastAndBow_Settings.collapsed then
                            GameTooltip:SetText("Show Buttons")
                        else
                            GameTooltip:SetText("Hide Buttons")
                        end
                        GameTooltip:Show()
                    end
                    self:SetAlpha(1.0)
                end)
                collapseButton:SetScript("OnLeave", function(self)
                    if GameTooltip then GameTooltip:Hide() end
                    self:SetAlpha(0.95)
                end)
            end

            -- Strip Blizzard default textures and apply custom arrow_up initially
            local function SanitizeButton(btn, normalTex)
                if not btn then return end
                if btn.Left then btn.Left:Hide() end
                if btn.Middle then btn.Middle:Hide() end
                if btn.Right then btn.Right:Hide() end
                if btn.GetHighlightTexture then
                    local h = btn:GetHighlightTexture(); if h then h:SetAlpha(0) end
                end
                btn:SetNormalTexture(normalTex or COLLAPSE_TEXTURE_UP)
                btn:SetPushedTexture(normalTex or COLLAPSE_TEXTURE_UP)
                btn:SetDisabledTexture(normalTex or COLLAPSE_TEXTURE_UP)
                if not btn:GetScript("OnClick") then
                    btn:SetScript("OnClick", function() if BeastAndBow and BeastAndBow.ToggleCollapse then BeastAndBow.ToggleCollapse() end end)
                end
                if btn.EnableMouse then btn:EnableMouse(true) end
            end

            -- Collapse button cleanup & initialization (transparent background, arrow only)
            if collapseButton then
                if collapseButton.SetBackdrop then collapseButton:SetBackdrop(nil) end
                if collapseButton.Left then collapseButton.Left:Hide() end
                if collapseButton.Middle then collapseButton.Middle:Hide() end
                if collapseButton.Right then collapseButton.Right:Hide() end
                collapseButton:SetNormalTexture(COLLAPSE_TEXTURE_UP)
                collapseButton:SetPushedTexture(COLLAPSE_TEXTURE_UP)
                collapseButton:SetHighlightTexture(COLLAPSE_TEXTURE_UP)
                local h = collapseButton:GetHighlightTexture(); if h then h:SetAlpha(0.85) end
                local n = collapseButton:GetNormalTexture(); if n then n:SetAlpha(1) end
                if not collapseButton:GetScript("OnClick") then
                    collapseButton:SetScript("OnClick", function() if BeastAndBow and BeastAndBow.ToggleCollapse then BeastAndBow.ToggleCollapse() end end)
                end
                collapseButton:EnableMouse(true)
                -- Safe frame level assignment (avoid negative levels)
                if collapseButton.SetFrameLevel and frame then
                    local baseLevel = frame:GetFrameLevel() or 0
                    -- We keep the button at the same level; adjust (+1) if we ever need it above.
                    local desiredLevel = baseLevel -- or baseLevel + 1 for above
                    if desiredLevel < 0 then desiredLevel = 0 end
                    collapseButton:SetFrameLevel(desiredLevel)
                end
            end

            -- Sanitize vendor buttons to remove red Blizzard segments
            if buttonsContainer and buttonsContainer.GetChildren then
                for _, child in ipairs({
                    GetUI("BeastAndBowFindArrowButton"),
                    GetUI("BeastAndBowFindBreadButton"),
                    GetUI("BeastAndBowFindFishButton"),
                    GetUI("BeastAndBowFindCheeseButton"),
                    GetUI("BeastAndBowFindFruitButton"),
                    GetUI("BeastAndBowFindMushroomButton"),
                    GetUI("BeastAndBowFindMeatButton")
                }) do
                    SanitizeButton(child, "Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                end
            end
            -- Hide old collapse icon if it exists (we use full button textures now)
            if collapseIcon and collapseIcon.Hide then collapseIcon:Hide() end

            -- Restore saved page state on load (first or second page)
            local showOptions = BeastAndBow_Settings.showOptionsPage or false
            BeastAndBow.SetPage(showOptions)

            -- Apply initial collapsed/expanded state to UI (no animation on load)
            ApplyCollapseState(false)
        end)
    end

    -- Save the main frame position into saved variables so it persists between sessions
    function BeastAndBow.SavePosition()
        local f = GetUI("BeastAndBowFrame")
        if not f or not f.GetPoint then return end
        local point, relativeTo, relativePoint, x, y = f:GetPoint()
        -- Normalize values and store
        BeastAndBow_Settings.position = BeastAndBow_Settings.position or {}
        BeastAndBow_Settings.position.point = point or "CENTER"
        BeastAndBow_Settings.position.relativePoint = relativePoint or "CENTER"
        BeastAndBow_Settings.position.x = tonumber(x) or 0
        BeastAndBow_Settings.position.y = tonumber(y) or 0
    end

    function BeastAndBow.ToggleReportFrame()
        local f = GetUI("BeastAndBowReportFrame")
        if f and f.IsShown then
            if f:IsShown() then
                if HideUIPanel then HideUIPanel(f) end
            else
                if ShowUIPanel then ShowUIPanel(f) end
            end
        end
    end

    -- Page toggle: switch between main vendor buttons and options page
    function BeastAndBow.SetPage(showOptions)
        local main = GetUI("BeastAndBowButtonsContainer")
        local opts = GetUI("BeastAndBowOptionsContainer")
        local nextBtn = GetUI("BeastAndBowNextPageButton")
        local prevBtn = GetUI("BeastAndBowPrevPageButton")
        local root = frame or GetUI("BeastAndBowFrame")
        if not main or not opts then return end
        if showOptions then
            main:Hide(); opts:Show()
            if nextBtn then nextBtn:Hide() end
            if prevBtn then prevBtn:Show() end
        else
            opts:Hide(); main:Show()
            if prevBtn then prevBtn:Hide() end
            if nextBtn then nextBtn:Show() end
        end
        -- Keep frame dimensions stable across pages; collapse logic manages height separately
        if root and root.SetWidth then root:SetWidth(240) end
        BeastAndBow_Settings.showOptionsPage = showOptions and true or false

        -- Respect collapsed state immediately after switching pages to prevent both containers showing
        if BeastAndBow_Settings and BeastAndBow_Settings.collapsed then
            if main then main:Hide() end
            if opts then opts:Hide() end
        end
    end
    function BeastAndBow.TogglePage()
        local show = not (BeastAndBow_Settings and BeastAndBow_Settings.showOptionsPage)
        BeastAndBow.SetPage(show)
    end
    function BeastAndBow.OpenTrainerOptions()
        BeastAndBow.FindNearestTrainer()
    end
    function BeastAndBow.OpenPetsOptions()
        BeastAndBow.TogglePets(true)
    end

    -- Pets Encyclopedia Logic
    BeastAndBow.SelectedCategory = nil
    BeastAndBow.SelectedSpeciesIndex = nil
    -- DEBUG: Force using the replacement menu (set true to bypass XML buttons)
    BeastAndBow.ForceReplacement = false

-- Ensure a persistent in-frame menu (two buttons) exists inside the pets frame.
function BeastAndBow.EnsureInFrameMenu(parentFrame)
    if not parentFrame then parentFrame = GetUI("BeastAndBowPetsFrame") or GetUI("BestiaryMainFrame") end
    if not parentFrame then return end
    local function createBtn(name, point, x, text, onClick)
        local b = GetUI(name)
        if not b then
            b = CreateFrame("Button", name, parentFrame, "UIPanelButtonTemplate")
            b:SetSize(160, 48)
            b:SetPoint(point, parentFrame, point, x, -36)
            if b.SetNormalTexture then
                b:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                b:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                b:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
            end
            if b.GetFontString and b:GetFontString() then b:GetFontString():SetText(text) end
            b:SetScript("OnClick", function()
                -- hide any menu overlays that might still be visible
                local xmlMenu = GetUI("BeastAndBowPetsMenu") if xmlMenu and xmlMenu.Hide then xmlMenu:Hide() end
                local repl = GetUI("BeastAndBow_MenuReplacement") if repl and repl.Hide then repl:Hide() end
                local success, err = pcall(onClick)
                if not success and BeastAndBow_Settings and BeastAndBow_Settings.debug then
                    BeastAndBow.Debug.Warn("Button onClick failed: " .. tostring(err), "UI")
                end
            end)
        else
            -- ensure parented and positioned
            if b.SetParent then pcall(b.SetParent, b, parentFrame) end
            if b.SetPoint then b:ClearAllPoints(); pcall(b.SetPoint, b, point, parentFrame, point, x, -36) end
            if b.Show then b:Show() end
        end
        if b.Show then b:Show() end
        return b
    end

    -- left button (Pets) and right button (Abilities) centered at top
    createBtn("BABInFramePetsButton", "LEFT", 20, (BeastAndBow.L and BeastAndBow.L.MENU_PETS) or "Tiere", function() 
        local success, err = pcall(BeastAndBow.OpenPetsView)
        if not success and BeastAndBow_Settings and BeastAndBow_Settings.debug and BeastAndBow.Debug then
            BeastAndBow.Debug.Error("OpenPetsView failed: " .. tostring(err), "UI")
        end
    end)
    createBtn("BABInFrameAbilitiesButton", "RIGHT", -20, (BeastAndBow.L and BeastAndBow.L.MENU_ABILITIES) or "FÃ¤higkeiten", function() 
        local success, err = pcall(BeastAndBow.OpenSkillsView)
        if not success and BeastAndBow_Settings and BeastAndBow_Settings.debug and BeastAndBow.Debug then
            BeastAndBow.Debug.Error("OpenSkillsView failed: " .. tostring(err), "UI")
        end
    end)
end

-- Slash command to toggle the replacement menu without editing files
SLASH_BEASTANDBOWMENU1 = "/babmenu"
SlashCmdList["BEASTANDBOWMENU"] = function(msg)
    local arg = (msg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "on" then
        BeastAndBow.ForceReplacement = true
        print("BAB: ForceReplacement = true (replacement menu will be used)")
    elseif arg == "off" then
        BeastAndBow.ForceReplacement = false
        print("BAB: ForceReplacement = false (XML menu will be used if available)")
    elseif arg == "close" then
        local repl = GetUI("BeastAndBow_MenuReplacement")
        if repl and repl.Hide then repl:Hide() end
        local main = GetUI("BestiaryMainFrame") if main and HideUIPanel then HideUIPanel(main) end
        print("BAB: replacement menu closed")
    else
        print("BAB: /babmenu on|off - current:", tostring(BeastAndBow.ForceReplacement))
    end
end

    function BeastAndBow.TogglePets(show)
        local main = GetUI("BestiaryMainFrame")
        if not main then return end
        if show then
            -- Show the main Bestiary container
            ShowUIPanel(main)
            -- Don't auto-show pet menu - wait for user to click "Tiere" button
            -- Hide pet frame and skills frame
            local petsFrame = GetUI("BeastAndBowPetsFrame")
            if petsFrame then petsFrame:Hide() end
            local skillsFrame = GetUI("BeastAndBowSkillsFrame")
            if skillsFrame then skillsFrame:Hide() end
            
            -- reset detail fields
            local nameFS = GetUI("BeastAndBowPetsDetailName")
            if nameFS and nameFS.SetText then nameFS:SetText("Select a Pet") end
            local lvlFS = GetUI("BeastAndBowPetsDetailLevel"); if lvlFS and lvlFS.SetText then lvlFS:SetText("Level: -") end
            local spdFS = GetUI("BeastAndBowPetsDetailSpeed"); if spdFS and spdFS.SetText then spdFS:SetText("Attack Speed: -") end
            local abFS = GetUI("BeastAndBowPetsDetailAbilities"); if abFS and abFS.SetText then abFS:SetText("Learns: -") end
        else
            HideUIPanel(main)
        end
    end

    function BeastAndBow.ClearChildren(parent)
        if not parent or not parent.GetChildren then return end
        local children = { parent:GetChildren() }
        for _, c in ipairs(children) do c:Hide(); c:SetParent(nil) end
    end

    -- Show the central Pets menu (Tiere / FÃ¤higkeiten)
    function BeastAndBow.ShowPetsMenu()
    local main = GetUI("BestiaryMainFrame")
    if not main then
        bab_print("ShowPetsMenu: BestiaryMainFrame missing", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS and BeastAndBow.Debug.LEVELS.WARN or 2, "UI")
        return
    end
    bab_print("ShowPetsMenu: opening BestiaryMainFrame", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS and BeastAndBow.Debug.LEVELS.INFO or 1, "UI")
    ShowUIPanel(main)

    -- Show the main content frame, relying on XML for parenting and anchors
    local f = GetUI("BeastAndBowPetsFrame")
    if f and f.Show then
        f:Show()
        bab_print("ShowPetsMenu: BeastAndBowPetsFrame shown", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS and BeastAndBow.Debug.LEVELS.INFO or 1, "UI")
    else
        bab_print("ShowPetsMenu: BeastAndBowPetsFrame not found", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS and BeastAndBow.Debug.LEVELS.WARN or 2, "UI")
    end

    -- Show the central menu, relying on XML for parenting and anchors
    local menu = GetUI("BeastAndBowPetsMenu")
    if menu and menu.Show then
        menu:Show()
        bab_print("ShowPetsMenu: BeastAndBowPetsMenu shown", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS and BeastAndBow.Debug.LEVELS.INFO or 1, "UI")
    else
        bab_print("ShowPetsMenu: BeastAndBowPetsMenu not found", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS and BeastAndBow.Debug.LEVELS.WARN or 2, "UI")
    end

    -- Hide all other views to ensure a clean state
    local backBtn = GetUI("BeastAndBowPetsToSkillsButton") if backBtn and backBtn.Hide then backBtn:Hide() end
    local skillsBackBtn = GetUI("BeastAndBowSkillsBackButton") if skillsBackBtn and skillsBackBtn.Hide then skillsBackBtn:Hide() end
    local skills = GetUI("BeastAndBowSkillsFrame") if skills and skills.Hide then skills:Hide() end
    local cats = GetUI("BeastAndBowPetsCategoriesScroll") if cats and cats.Hide then cats:Hide() end
    local species = GetUI("BeastAndBowPetsSpeciesScroll") if species and species.Hide then species:Hide() end
    local modelContainer = GetUI("BeastAndBowPetsModelContainer") if modelContainer and modelContainer.Hide then modelContainer:Hide() end
    local info = GetUI("BeastAndBowPetsInfo") if info and info.Hide then info:Hide() end
    
    -- Hide any replacement/fallback buttons
    local in1 = GetUI("BABInFramePetsButton") if in1 and in1.Hide then in1:Hide() end
    local in2 = GetUI("BABInFrameAbilitiesButton") if in2 and in2.Hide then in2:Hide() end
    local overlay = GetUI("BeastAndBow_MenuOverlay") if overlay and overlay.Hide then overlay:Hide() end
    local fallback = GetUI("BeastAndBow_MenuFallback") if fallback and fallback.Hide then fallback:Hide() end
end

    function BeastAndBow.OpenPetsView()
    bab_print("OpenPetsView called", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS.INFO or 1, "UI")
    local main = GetUI("BestiaryMainFrame")
    if not main then return end
    ShowUIPanel(main)

    -- Main layout: show pets frame, hide skills frame
    local petsFrame = GetUI("BeastAndBowPetsFrame"); if petsFrame and petsFrame.Show then petsFrame:Show() end
    local skillsFrame = GetUI("BeastAndBowSkillsFrame"); if skillsFrame and skillsFrame.Hide then skillsFrame:Hide() end

    -- Hide the initial menu overlay
    local menu = GetUI("BeastAndBowPetsMenu"); if menu and menu.Hide then menu:Hide() end

    -- Button visibility: Show "To Skills" button, hide "Back to Pets" button
    local toSkillsBtn = GetUI("BeastAndBowPetsToSkillsButton"); if toSkillsBtn and toSkillsBtn.Show then toSkillsBtn:Show() end
    local toPetsBtn = GetUI("BeastAndBowSkillsBackButton"); if toPetsBtn and toPetsBtn.Hide then toPetsBtn:Hide() end

    -- Clear and reset global search box
    local globalSearch = GetUI("BestiariumGlobalSearchBoxHeader")
    if globalSearch then globalSearch:SetText("") globalSearch:Show() end
    
    -- Ensure all scroll frames and content is visible initially
    local cats = GetUI("BeastAndBowPetsCategoriesScroll"); if cats and cats.Show then cats:Show() end
    local species = GetUI("BeastAndBowPetsSpeciesScroll"); if species and species.Show then species:Show() end
    
    -- Hide model container and info panel initially - they show only when viewing pet details
    local modelContainer = GetUI("BeastAndBowPetsModelContainer"); if modelContainer then modelContainer:Hide() end
    local info = GetUI("BeastAndBowPetsInfo"); if info then info:Hide() end
    
    -- Populate the pet categories to ensure content is visible
    BeastAndBow.PopulatePetCategories()
end

function BeastAndBow.StyleScrollFrame(scrollFrame)
    if not scrollFrame then return end
    -- The scrollbar is conventionally named after the scrollFrame + "ScrollBar"
    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    if not scrollBar then return end

    -- Hide Blizzard's default textures for the track if they exist
    if scrollBar.Top and scrollBar.Top.SetAlpha then scrollBar.Top:SetAlpha(0) end
    if scrollBar.Bottom and scrollBar.Bottom.SetAlpha then scrollBar.Bottom:SetAlpha(0) end
    if scrollBar.Middle and scrollBar.Middle.SetAlpha then scrollBar.Middle:SetAlpha(0) end
    
    -- Set custom textures for Up/Down buttons
    if scrollBar.ScrollUpButton then
        scrollBar.ScrollUpButton:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\arrow_up")
        scrollBar.ScrollUpButton:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\arrow_up")
        scrollBar.ScrollUpButton:SetDisabledTexture("Interface\\AddOns\\BeastAndBow\\Textures\\arrow_up")
        scrollBar.ScrollUpButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    end
    
    if scrollBar.ScrollDownButton then
        scrollBar.ScrollDownButton:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\arrow_down")
        scrollBar.ScrollDownButton:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\arrow_down")
        scrollBar.ScrollDownButton:SetDisabledTexture("Interface\\AddOns\\BeastAndBow\\Textures\\arrow_down")
        scrollBar.ScrollDownButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    end

    -- Set custom texture for the thumb
    if scrollBar.ThumbTexture then
        scrollBar.ThumbTexture:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\scroll_thumb")
        scrollBar.ThumbTexture:SetSize(scrollBar.ThumbTexture:GetWidth(), 22) -- Make thumb a bit taller for visibility
    end
end

function BeastAndBow.OpenSkillsView()
    bab_print("OpenSkillsView called", BeastAndBow.Debug and BeastAndBow.Debug.LEVELS.INFO or 1, "UI")
    local main = GetUI("BestiaryMainFrame")
    if not main then return end
    ShowUIPanel(main)

    -- Main layout: show skills frame, hide pets frame
    local petsFrame = GetUI("BeastAndBowPetsFrame"); if petsFrame and petsFrame.Hide then petsFrame:Hide() end
    local skillsFrame = GetUI("BeastAndBowSkillsFrame"); if skillsFrame and skillsFrame.Show then skillsFrame:Show() end

    -- Hide the initial menu overlay
    local menu = GetUI("BeastAndBowPetsMenu"); if menu and menu.Hide then menu:Hide() end

    -- Button visibility
    local toSkillsBtn = GetUI("BeastAndBowPetsToSkillsButton"); if toSkillsBtn and toSkillsBtn.Hide then toSkillsBtn:Hide() end
    local toPetsBtn = GetUI("BeastAndBowSkillsBackButton"); if toPetsBtn and toPetsBtn.Show then toPetsBtn:Show() end

    -- Hide details view from other screens
    local modelContainer = GetUI("BeastAndBowPetsModelContainer"); if modelContainer then modelContainer:Hide() end
    local info = GetUI("BeastAndBowPetsInfo"); if info then info:Hide() end
    
    -- Clear and show global search box
    local globalSearch = GetUI("BestiariumGlobalSearchBoxHeader")
    if globalSearch then globalSearch:SetText("") globalSearch:Show() end
    
    -- Show the first column and hide the others
    local abilitiesScroll = GetUI("BeastAndBowSkills_AbilitiesScroll"); if abilitiesScroll then abilitiesScroll:Show() end
    local ranksScroll = GetUI("BeastAndBowSkills_RanksScroll"); if ranksScroll then ranksScroll:Hide() end
    local petsScroll = GetUI("BeastAndBowSkills_PetsScroll"); if petsScroll then petsScroll:Hide() end

    if BeastAndBow.BuildAbilityDB then
        BeastAndBow.BuildAbilityDB()
    end

    -- Populate the first column with abilities
    BeastAndBow.PopulateSkillsFrame()

    C_Timer.After(0.05, function()
        if not (skillsFrame and skillsFrame.IsShown and skillsFrame:IsShown()) then
            return
        end
        if BeastAndBow.BuildAbilityDB then
            BeastAndBow.BuildAbilityDB()
        end
        BeastAndBow.PopulateSkillsFrame()
    end)

    -- Create a persistent, named FontString for info text inside the scroll frame (but not the scroll child)
    -- This prevents it from being destroyed by ClearChildren.
    local scrollFrame = GetUI("BeastAndBowSkills_PetsScroll")
    if scrollFrame and not GetUI("BeastAndBowSkillInfoText") then
        local fs = scrollFrame:CreateFontString("BeastAndBowSkillInfoText", "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", 10, -10)
        fs:SetPoint("RIGHT", scrollFrame, "RIGHT", -25, 0) -- Anchor to scrollframe, account for scrollbar width
        fs:SetJustifyH("LEFT")
        fs:Hide()
    end
end

    -- Functions tied to the top tabs inside BestiaryMainFrame
    function BeastAndBow.ShowPetsInMain()
        BeastAndBow.OpenPetsView()
    end

    function BeastAndBow.ShowSkillsInMain()
        BeastAndBow.OpenSkillsView()
    end

function BeastAndBow.PopulatePetCategories()
    BeastAndBow.PetNavStack = {}

        local parent = GetUI("BeastAndBowPetsCategories")
        if not parent then return end
        
        BeastAndBow.ClearChildren(parent)
        GetUI("BeastAndBowPetsSpeciesScroll"):Hide()

        local y = -4
        local cats = BeastAndBow and BeastAndBow.GetPetCategories() or {}
        if not BeastAndBow.GetCategoryIcon then
            local function normalizeKey(s)
                s = tostring(s or ""):lower():gsub("%s+", ""):gsub("[-_]", "")
                return s
            end
            function BeastAndBow.GetCategoryIcon(name)
                 local key = normalizeKey(name)
                local map = {
                    cats = "Interface\\Icons\\Ability_Hunter_Pet_Cat",
                    katzen = "Interface\\Icons\\Ability_Hunter_Pet_Cat",
                    bears = "Interface\\Icons\\Ability_Hunter_Pet_Bear",
                    baren = "Interface\\Icons\\Ability_Hunter_Pet_Bear",
                    bats = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
                    fledermause = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
                    sporebats = "Interface\\Icons\\ability_hunter_pet_sporebat",
                    boars = "Interface\\Icons\\Ability_Hunter_Pet_Boar",
                    eber = "Interface\\Icons\\Ability_Hunter_Pet_Boar",
                    birdsofprey = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
                    spiders = "Interface\\Icons\\Ability_Hunter_Pet_Spider",
                    spinnen = "Interface\\Icons\\Ability_Hunter_Pet_Spider",
                    wolves = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
                    wolfe = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
                    raptors = "Interface\\Icons\\Ability_Mount_Raptor",
                    raptoren = "Interface\\Icons\\Ability_Mount_Raptor",
                    turtles = "Interface\\Icons\\Ability_Hunter_Pet_Turtle",
                    schildkroten = "Interface\\Icons\\Ability_Hunter_Pet_Turtle",
                    windserpents = "Interface\\Icons\\Ability_Hunter_Pet_WindSerpent",
                    windnattern = "Interface\\Icons\\Ability_Hunter_Pet_WindSerpent",
                    carrionbirds = "Interface\\Icons\\Ability_Hunter_Pet_Vulture",
                    aasvogel = "Interface\\Icons\\Ability_Hunter_Pet_Vulture",
                    crocolisks = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
                    krokodile = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
                    krokolisken = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
                    gorillas = "Interface\\Icons\\Ability_Hunter_Pet_Gorilla",
                    hyenas = "Interface\\Icons\\Ability_Hunter_Pet_Hyena",
                    hyanen = "Interface\\Icons\\Ability_Hunter_Pet_Hyena",
                    tallstriders = "Interface\\Icons\\Ability_Hunter_Pet_Tallstrider",
                    hochlaufer = "Interface\\Icons\\Ability_Hunter_Pet_Tallstrider",
                    weitschreiter = "Interface\\Icons\\Ability_Hunter_Pet_Tallstrider",
                    crabs = "Interface\\Icons\\Ability_Hunter_Pet_Crab",
                    krebse = "Interface\\Icons\\Ability_Hunter_Pet_Crab",
                    krabben = "Interface\\Icons\\Ability_Hunter_Pet_Crab",
                    owls = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
                    eule = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
                    eulen = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
                    scorpids = "Interface\\Icons\\Ability_Hunter_Pet_Scorpid",
                    skorpide = "Interface\\Icons\\Ability_Hunter_Pet_Scorpid",
                }
                return map[key] or "Interface\\Icons\\INV_Misc_QuestionMark"
            end
        end
        local created = 0
        for i, cat in ipairs(BeastAndBow.GetPetCategories() or {}) do
            local btn = CreateFrame("Button", "BeastAndBowPetCatButton"..i, parent, "UIPanelButtonTemplate")
            btn:SetSize(140, 22)
            btn:SetPoint("TOPLEFT", 8, y)
            btn:SetText(cat.name)
            local icon = btn:CreateTexture(nil, "OVERLAY")
            icon:SetSize(18, 18)
            icon:SetPoint("LEFT", btn, "LEFT", 6, 0)
            -- Use cat.icon if it's a string path, otherwise fallback to GetCategoryIcon
            local tex
            if cat.icon and type(cat.icon) == "string" then
                tex = cat.icon
            else
                tex = BeastAndBow.GetCategoryIcon(cat.name)
            end
            icon:SetTexture(tex)
            
            if btn.SetNormalTexture then
                btn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
            end
            btn:SetScript("OnClick", function()
                BeastAndBow.SelectedCategory = cat
                BeastAndBow.PetNavStack = {}
                table.insert(BeastAndBow.PetNavStack, { view = "categories" })
                BeastAndBow.PopulatePetSubgroups(cat)
            end)
            y = y - 26
            created = created + 1
        end
        
        parent:SetHeight(math.max(created * 26 + 10, 300))
        GetUI("BeastAndBowPetsCategoriesScroll"):SetVerticalScroll(0)
    end

    function BeastAndBow.PetMenuBack()
        local stack = BeastAndBow.PetNavStack or {}
        local previous = table.remove(stack)
        BeastAndBow.PetNavStack = stack

        if not previous then
            BeastAndBow.PopulatePetCategories()
            return
        end

        if previous.view == "categories" then
            BeastAndBow.PopulatePetCategories()
        elseif previous.view == "subgroups" and previous.node then
            BeastAndBow.PopulatePetSubgroups(previous.node)
        else
            BeastAndBow.PopulatePetCategories()
        end
    end

    function BeastAndBow.PopulatePetSubgroups(cat)
        local parent = GetUI("BeastAndBowPetsSpecies")
        if not parent then return end
        BeastAndBow.ClearChildren(parent)
        
        GetUI("BeastAndBowPetsSpeciesScroll"):Show()
        GetUI("BeastAndBowPetsModelContainer"):Hide()
        GetUI("BeastAndBowPetsInfo"):Hide()

        local y = -4
        local created = 0

        if BeastAndBow.PetNavStack and #BeastAndBow.PetNavStack > 0 then
            local backBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
            backBtn:SetSize(160, 22)
            backBtn:SetPoint("TOPLEFT", 8, y)
            backBtn:SetText((BeastAndBow.L and BeastAndBow.L.BACK) or "Back")
            BeastAndBow.EnableButtonMarquee(backBtn)
            if backBtn.SetNormalTexture then
                backBtn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                backBtn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                backBtn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
            end
            backBtn:SetScript("OnClick", function()
                BeastAndBow.PetMenuBack()
            end)
            y = y - 26
            created = created + 1
        end

        local function processSubgroup(subgroup)
             local btn = CreateFrame("Button", "BeastAndBowPetSubgroupButton"..created, parent, "UIPanelButtonTemplate")
            btn:SetSize(160, 22)
            btn:SetPoint("TOPLEFT", 8, y)
            btn:SetText(subgroup.name)
            -- Enable marquee scrolling for long subgroup names (color variants, etc.)
            BeastAndBow.EnableButtonMarquee(btn)
            if btn.SetNormalTexture then
                btn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
            end
            btn:SetScript("OnClick", function()
                BeastAndBow.SelectedSubgroup = subgroup
                BeastAndBow.PetNavStack = BeastAndBow.PetNavStack or {}
                table.insert(BeastAndBow.PetNavStack, { view = "subgroups", node = cat })
                if subgroup.subgroups and #subgroup.subgroups > 0 then
                    BeastAndBow.PopulatePetSubgroups(subgroup)
                else
                    BeastAndBow.PopulatePetSpeciesMiddle(subgroup)
                end
            end)
            y = y - 26
            created = created + 1
        end

        for _, subgroup in ipairs(cat.subgroups or {}) do
            processSubgroup(subgroup)
        end
        parent:SetHeight(math.max(created * 26 + 10, 300))
        GetUI("BeastAndBowPetsSpeciesScroll"):SetVerticalScroll(0)
    end

-- SKILLS UI 
-- Skills learned from a pet trainer and not from taming wild pets
local trainerSkills = {
    ["Growl"] = true,
    ["Great Stamina"] = true,
    ["Natural Armor"] = true,
    ["Avoidance"] = true,
    ["Arcane Resistance"] = true,
    ["Fire Resistance"] = true,
    ["Frost Resistance"] = true,
    ["Nature Resistance"] = true,
    ["Shadow Resistance"] = true,
}

local trainerSkillPriority = {
    ["Avoidance"] = 1,
    ["Growl"] = 2,
}

function BeastAndBow.PopulateSkillsFrame()
    local parent = GetUI("BeastAndBowSkills_Abilities")
    if not parent then return end
    BeastAndBow.ClearChildren(parent)

    if (not BAB.AbilityDB or not next(BAB.AbilityDB)) and BeastAndBow.BuildAbilityDB then
        BeastAndBow.BuildAbilityDB()
    end

    local skillNames = {}
    if BAB.AbilityDB then
        for name in pairs(BAB.AbilityDB) do
            table.insert(skillNames, name)
        end
    end
    table.sort(skillNames, function(a, b)
        local a_is_trainer = trainerSkills[a]
        local b_is_trainer = trainerSkills[b]
        if a_is_trainer and not b_is_trainer then
            return false
        elseif not a_is_trainer and b_is_trainer then
            return true
        elseif a_is_trainer and b_is_trainer then
            local a_prio = trainerSkillPriority[a]
            local b_prio = trainerSkillPriority[b]
            if a_prio and b_prio and a_prio ~= b_prio then
                return a_prio < b_prio
            elseif a_prio and not b_prio then
                return true
            elseif not a_prio and b_prio then
                return false
            end
            return a < b
        else
            -- Use custom ability order if available, otherwise alphabetical
            if BAB.AbilityOrder then
                local a_idx, b_idx
                for i, name in ipairs(BAB.AbilityOrder) do
                    if name == a then a_idx = i end
                    if name == b then b_idx = i end
                end
                if a_idx and b_idx then
                    return a_idx < b_idx
                elseif a_idx then
                    return true
                elseif b_idx then
                    return false
                end
            end
            return a < b
        end
    end)

    local y = -4
    local created = 0
    for _, name in ipairs(skillNames) do
        local skillInfo = BAB.AbilityDB[name]
        if skillInfo then
            local btn = CreateFrame("Button", "BeastAndBowSkillNameBtn"..created, parent, "UIPanelButtonTemplate")
            btn:SetSize(170, 22)
            btn:SetPoint("TOPLEFT", 8, y)
            local spellKey = "SPELL_" .. name:upper():gsub("%s+", "_")
            local localizedName = (BAB.L and BAB.L[spellKey]) or name
            btn:SetText(localizedName)
            
            -- Adjust text position to avoid overlapping with icon
            local fontString = btn:GetFontString()
            if fontString then
                fontString:ClearAllPoints()
                fontString:SetPoint("LEFT", btn, "LEFT", 28, 0)
                fontString:SetPoint("RIGHT", btn, "RIGHT", -5, 0)
                fontString:SetJustifyH("LEFT")
            end
            
            local icon = btn:CreateTexture(nil, "OVERLAY")
            icon:SetSize(18, 18)
            icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
            icon:SetTexture(skillInfo.icon)

            if btn.SetNormalTexture then
                btn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
            end
            btn:SetScript("OnClick", function()
                BeastAndBow.SelectSkill(name)
            end)
            y = y - 26
            created = created + 1
        end
    end
    parent:SetHeight(math.max(created * 26 + 10, 300))
    GetUI("BeastAndBowSkills_AbilitiesScroll"):SetVerticalScroll(0)
end

-- Helper: enable horizontal marquee on a UIPanelButton's text if too long
function BeastAndBow.EnableButtonMarquee(btn)
    if not btn or not btn.GetFontString then return end
    local fs = btn:GetFontString()
    if not fs then return end
    local padding = 8
    local available = math.max(0, math.floor((btn.GetWidth and btn:GetWidth() or 160) - padding * 2))
    local textWidth = math.floor(fs:GetStringWidth() or 0)
    local overshoot = textWidth - available
    local threshold = 20 -- require meaningful overflow before scrolling
    if overshoot > threshold then
        -- Clip children so the text never draws outside the button
        if btn.SetClipsChildren then btn:SetClipsChildren(true) end
        if fs.SetJustifyH then fs:SetJustifyH("LEFT") end
        fs:ClearAllPoints()
        fs:SetPoint("LEFT", btn, "LEFT", padding, 0)
        btn._marquee = btn._marquee or { t = 0, range = overshoot, period = 5 }
        btn._marquee.range = overshoot
        btn._marquee.period = btn._marquee.period or 5 -- seconds per full cycle
        btn:SetScript("OnUpdate", function(self, elapsed)
            local m = self._marquee
            if not m then return end
            -- re-evaluate width in case font/text changed
            local curTextWidth = math.floor(fs:GetStringWidth() or 0)
            local curOvershoot = curTextWidth - available
            if curOvershoot <= threshold then
                -- disable marquee if no longer needed
                fs:ClearAllPoints(); fs:SetPoint("CENTER", self, "CENTER", 0, 0)
                if fs.SetJustifyH then fs:SetJustifyH("CENTER") end
                self:SetScript("OnUpdate", nil); self._marquee = nil
                if self.SetClipsChildren then self:SetClipsChildren(false) end
                return
            else
                m.range = curOvershoot
            end
            -- sinusoidal ping-pong movement between 0 and range
            m.t = (m.t or 0) + (elapsed or 0)
            local phase = (m.t / (m.period or 5)) * 2 * math.pi
            local offset = (math.sin(phase) * 0.5 + 0.5) * m.range
            fs:SetPoint("LEFT", self, "LEFT", padding - offset, 0)
        end)
    else
        -- Reset if not needed
        fs:ClearAllPoints()
        fs:SetPoint("CENTER", btn, "CENTER", 0, 0)
        if fs.SetJustifyH then fs:SetJustifyH("CENTER") end
        btn:SetScript("OnUpdate", nil)
        btn._marquee = nil
        if btn.SetClipsChildren then btn:SetClipsChildren(false) end
    end
end

function BeastAndBow.SelectSkill(name)
    local skillData = BAB.AbilityDB and BAB.AbilityDB[name]
    local parent = GetUI("BeastAndBowSkills_Ranks")
    if not parent or not skillData then return end
    BeastAndBow.ClearChildren(parent)
    
    -- NEW: Clear the pet/info column to prevent old text from persisting
    local petsParent = GetUI("BeastAndBowSkills_Pets")
    if petsParent then
        BeastAndBow.ClearChildren(petsParent)
    end

    GetUI("BeastAndBowSkills_RanksScroll"):Show()
    GetUI("BeastAndBowSkills_PetsScroll"):Hide()

    local y = -4
    local created = 0
    for i, rankInfo in ipairs(skillData.ranks) do
        local btn = CreateFrame("Button", "BeastAndBowSkillRankBtn"..created, parent, "UIPanelButtonTemplate")
        btn:SetSize(160, 22)
        btn:SetPoint("TOPLEFT", 8, y)
        btn:SetText(string.format("Rank %d (Lvl %d)", rankInfo.rank, rankInfo.level))

        if btn.SetNormalTexture then
            btn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
            btn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
            btn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
        end
        btn:SetScript("OnClick", function()
            BeastAndBow.SelectSkillRank(name, i)
        end)
        y = y - 26
        created = created + 1
    end
    parent:SetHeight(math.max(created * 26 + 10, 300))
    GetUI("BeastAndBowSkills_RanksScroll"):SetVerticalScroll(0)
end

function BeastAndBow.SelectSkillRank(skillName, rankIndex)
    local rankData = BAB.AbilityDB and BAB.AbilityDB[skillName] and BAB.AbilityDB[skillName].ranks[rankIndex]
    local parent = GetUI("BeastAndBowSkills_Pets") -- This is the scroll child
    if not parent or not rankData then return end
    
    -- 1. Clear previous pet buttons from the scrollable area
    BeastAndBow.ClearChildren(parent)

    -- 2. Get a handle to our persistent info text and hide it by default
    local infoText = GetUI("BeastAndBowSkillInfoText")
    if infoText then infoText:Hide() end

    -- 3. Show the scroll frame that contains both the scroll child and our info text
    GetUI("BeastAndBowSkills_PetsScroll"):Show()

    local y = -4
    local created = 0
    
    -- 4. Decide what to display: a list of pets, or an info message
    if rankData.pets and #rankData.pets > 0 then
        -- Populate with pet buttons. The infoText remains hidden.
        for i, petData in ipairs(rankData.pets) do
            local btn = CreateFrame("Button", "BeastAndBowSkillPetBtn"..created, parent, "UIPanelButtonTemplate")
            btn:SetSize(160, 22)
            btn:SetPoint("TOPLEFT", 8, y)
            btn:SetText(petData.petInfo.name)

            if btn.SetNormalTexture then
                btn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
            end
            btn:SetScript("OnClick", function()
                BeastAndBow.ShowPetDetailFromSkills(petData)
            end)
            y = y - 26
            created = created + 1
        end
    elseif trainerSkills[skillName] then
        -- Show trainer info using our persistent text frame
        if infoText then
            infoText:SetText(BAB.L and BAB.L.SKILL_TRAINER_INFO or "This ability is taught by a Pet Trainer. Use the 'Pet Trainer' button to locate the nearest one.")
            infoText:Show()
        end
        created = 4 -- Give it some vertical space
    else
        -- Show "no pets found" info
        if infoText then
            infoText:SetText(BAB.L and BAB.L.SKILL_NO_PETS_FOUND or "No tameable pets found that teach this skill.")
            infoText:Show()
        end
        created = 1
    end
    
    -- Adjust height of the scrollable area
    parent:SetHeight(math.max(created * 26 + 10, 300))
    GetUI("BeastAndBowSkills_PetsScroll"):SetVerticalScroll(0)
end

function BeastAndBow.ShowPetDetailFromSkills(petData)
    -- Hide the 3-column browser
    GetUI("BeastAndBowSkills_AbilitiesScroll"):Hide()
    GetUI("BeastAndBowSkills_RanksScroll"):Hide()
    GetUI("BeastAndBowSkills_PetsScroll"):Hide()

    -- Show and populate the detail view
    BeastAndBow.ShowPetDetail(petData.petInfo, petData.subgroupInfo)

    -- Manage back buttons
    GetUI("BeastAndBowPetsBackButton"):Hide()
    GetUI("BeastAndBowSkills_DetailBackButton"):Show()
end

function BeastAndBow.SkillsBackToBrowser()
    -- Hide the detail view
    GetUI("BeastAndBowPetsModelContainer"):Hide()
    GetUI("BeastAndBowPetsInfo"):Hide()
    
    -- Show the 3-column browser
    GetUI("BeastAndBowSkills_AbilitiesScroll"):Show()
    GetUI("BeastAndBowSkills_RanksScroll"):Show()
    GetUI("BeastAndBowSkills_PetsScroll"):Show()
end

function BeastAndBow.PopulatePetSpeciesMiddle(subgroup)
        local parent = GetUI("BeastAndBowPetsSpecies")
        if not parent then return end
        BeastAndBow.ClearChildren(parent)
        GetUI("BeastAndBowPetsSpeciesScroll"):Show()
        GetUI("BeastAndBowPetsModelContainer"):Hide()
        GetUI("BeastAndBowPetsInfo"):Hide()

        local y = -4
        local created = 0

        if BeastAndBow.PetNavStack and #BeastAndBow.PetNavStack > 0 then
            local backBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
            backBtn:SetSize(160, 22)
            backBtn:SetPoint("TOPLEFT", 8, y)
            backBtn:SetText((BeastAndBow.L and BeastAndBow.L.BACK) or "Back")
            BeastAndBow.EnableButtonMarquee(backBtn)
            if backBtn.SetNormalTexture then
                backBtn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                backBtn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                backBtn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
            end
            backBtn:SetScript("OnClick", function()
                BeastAndBow.PetMenuBack()
            end)
            y = y - 26
            created = created + 1
        end

        for idx, sp in ipairs(subgroup.species or {}) do
            local btn = CreateFrame("Button", "BeastAndBowPetSpeciesButton"..idx, parent, "UIPanelButtonTemplate")
            btn:SetSize(160, 22)
            btn:SetPoint("TOPLEFT", 8, y)
            btn:SetText(sp.name)
            -- Enable marquee scrolling for long names
            BeastAndBow.EnableButtonMarquee(btn)
    
            if btn.SetNormalTexture then
                btn:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
                btn:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons", "ADD")
            end
            btn:SetScript("OnClick", function()
                BeastAndBow.SelectedCategory = subgroup 
                BeastAndBow.SelectedSpeciesIndex = idx
                BeastAndBow.ShowPetDetail(sp, subgroup)
            end)
            y = y - 26
            created = created + 1
        end
        parent:SetHeight(math.max(created * 26 + 10, 300))
        GetUI("BeastAndBowPetsSpeciesScroll"):SetVerticalScroll(0)
    end

local function trimText(value)
    if type(value) ~= "string" then return "" end
    return value:match("^%s*(.-)%s*$") or ""
end

function BeastAndBow.NormalizeMojibakeText(value)
    if type(value) ~= "string" or value == "" then
        return value
    end

    local replacements = {
        { "Ã„", "Ä" }, { "Ã–", "Ö" }, { "Ãœ", "Ü" },
        { "Ã¤", "ä" }, { "Ã¶", "ö" }, { "Ã¼", "ü" },
        { "ÃŸ", "ß" }, { "Ã©", "é" }, { "Ã¨", "è" },
        { "Ã´", "ô" }, { "Ãª", "ê" },
        { "â€“", "–" }, { "â€”", "—" },
        { "â€ž", "„" }, { "â€œ", "“" }, { "â€", "”" },
        { "â€™", "’" }, { "â€²", "′" },
        { "Â", "" },
    }

    local fixed = value
    for _, rep in ipairs(replacements) do
        fixed = fixed:gsub(rep[1], rep[2])
    end
    return fixed
end

function BeastAndBow.LocalizeZoneText(zoneText)
    if type(zoneText) ~= "string" or zoneText == "" or zoneText == "-" then
        return zoneText or "-"
    end

    local function makeZoneKey(prefix, value)
        local normalized = trimText(value):upper():gsub("%s+", "_"):gsub("[^A-Z0-9_]", "")
        if normalized == "" then return nil end
        return prefix .. normalized
    end

    local function localizeChunk(chunk)
        local part = trimText(chunk)
        if part == "" then return part end

        local suffix = part:match("(%s*%([^)]*%))%s*$")
        local base = part
        if suffix then
            base = trimText(part:gsub("%s*%([^)]*%)%s*$", ""))
        end

        local localizedBase = base
        if BAB.L then
            local zoneKey = makeZoneKey("ZONE_", base)
            local mapKey = makeZoneKey("MAP_", base)
            localizedBase = (zoneKey and BAB.L[zoneKey]) or (mapKey and BAB.L[mapKey]) or base
        end

        if suffix and suffix ~= "" then
            local normalizedSuffix = trimText(suffix):lower()
            local normalizedLocalizedBase = trimText(localizedBase):lower()
            if normalizedLocalizedBase:sub(-#normalizedSuffix) == normalizedSuffix then
                return localizedBase
            end
        end

        return localizedBase .. (suffix or "")
    end

    local localizedSegments = {}
    for segment in string.gmatch(zoneText, "[^;]+") do
        local localizedParts = {}
        for piece in string.gmatch(segment, "[^,]+") do
            table.insert(localizedParts, localizeChunk(piece))
        end
        table.insert(localizedSegments, table.concat(localizedParts, ", "))
    end

    return table.concat(localizedSegments, "; ")
end

    function BeastAndBow.ShowPetDetail(sp, subgroup)
    local modelContainer = GetUI("BeastAndBowPetsModelContainer")
    local infoPanel = GetUI("BeastAndBowPetsInfo")
    
    -- Hide the lists
    GetUI("BeastAndBowPetsCategoriesScroll"):Hide()
    GetUI("BeastAndBowPetsSpeciesScroll"):Hide()

    -- Show the main containers for the detail view
    modelContainer:Show()
    infoPanel:Show()
    
    -- Manage back buttons
    GetUI("BeastAndBowPetsBackButton"):Show()
    GetUI("BeastAndBowSkills_DetailBackButton"):Hide()

    -- Gather all the detail font strings
    local nameFS = GetUI("BeastAndBowPetsDetailName")
    local lvlFS = GetUI("BeastAndBowPetsDetailLevel")
    local spdFS = GetUI("BeastAndBowPetsDetailSpeed")
    local dietFS = GetUI("BeastAndBowPetsDetailDiet")
    local zoneFS = GetUI("BeastAndBowPetsDetailZone")
    local abFS = GetUI("BeastAndBowPetsDetailAbilities")

    -- Ensure consistent left alignment and wrapping width
    local function setupFS(fs)
        if not fs then return end
        if fs.SetJustifyH then fs:SetJustifyH("LEFT") end
        if fs.SetWidth then fs:SetWidth(300) end
    end
    setupFS(nameFS)
    setupFS(lvlFS)
    setupFS(spdFS)
    setupFS(dietFS)
    setupFS(zoneFS)
    setupFS(abFS)

    -- Populate the fields with data
    nameFS:SetText(sp.name or "Unknown")
    if sp.level and type(sp.level) == "table" then
        lvlFS:SetText(string.format("%s: %d-%d", (BAB.L and BAB.L["PET_DETAIL_LEVEL"]) or "Level", sp.level[1] or 0, sp.level[2] or (sp.level[1] or 0)))
    elseif sp.level then
        lvlFS:SetText(string.format("%s: %s", (BAB.L and BAB.L["PET_DETAIL_LEVEL"]) or "Level", tostring(sp.level)))
    else
        lvlFS:SetText((BAB.L and BAB.L["PET_DETAIL_LEVEL"]) or "Level" .. ": -")
    end
    if sp.attackSpeed then 
        spdFS:SetText(string.format("%s: %.1f", (BAB.L and BAB.L["PET_DETAIL_ATTACK_SPEED"]) or "Attack Speed", sp.attackSpeed)) 
    else 
        spdFS:SetText((BAB.L and BAB.L["PET_DETAIL_ATTACK_SPEED"]) or "Attack Speed" .. ": -") 
    end
    local txt = string.format("%s: -", (BAB.L and BAB.L["PET_DETAIL_LEARNS"]) or "Learns")
    if sp.learns and type(sp.learns) == "table" and #sp.learns > 0 then
        local parts = {}
        for _, a in ipairs(sp.learns) do
            local spellKey = "SPELL_" .. (a.spell or ""):upper():gsub("%s+", "_")
            local localizedSpell = (BAB.L and BAB.L[spellKey]) or a.spell or "?"
            local label = localizedSpell
            if a.rank then label = string.format("%s (Rank %s)", label, a.rank) end
            table.insert(parts, label)
        end
        -- Add line break for 2+ abilities
        local separator = (#sp.learns >= 2) and ",\n" or ", "
        txt = string.format("%s:\n%s", (BAB.L and BAB.L["PET_DETAIL_LEARNS"]) or "Learns", table.concat(parts, separator))
    end
    abFS:SetText(txt)
    
    -- Localize diet
    local diet = (subgroup and subgroup.diet) or sp.diet or "-"
    if diet and diet ~= "-" then
        local dietParts = {}
        for part in diet:gmatch("[^,]+") do
            part = part:match("^%s*(.-)%s*$") -- trim whitespace
            local dietKey = "DIET_" .. part:upper():gsub("%s+", "_")
            local localizedDiet = (BAB.L and BAB.L[dietKey]) or part
            table.insert(dietParts, localizedDiet)
        end
        -- Add line break for 5+ diet items
        local separator = (#dietParts >= 5) and ",\n" or ", "
        diet = table.concat(dietParts, separator)
    end
    dietFS:SetText(string.format("%s: %s", (BAB.L and BAB.L["PET_DETAIL_DIET"]) or "Diet", diet))
    
    local zone = BeastAndBow.LocalizeZoneText(sp.zone or "-")
    zoneFS:SetText(string.format("%s: %s", (BAB.L and BAB.L["PET_DETAIL_ZONE"]) or "Zone", zone))
    
    -- Display notes
    local notesFS = GetUI("BeastAndBowPetsDetailNotes")
    if notesFS then
        -- Align and set width for proper wrapping
        setupFS(notesFS)
        if sp.notes then
            local noteText = sp.notes
            -- Check if notes is a table with language variants
            if type(noteText) == "table" then
                local currentLang = BeastAndBow.locale or "enUS"
                -- Only show German notes if in German locale, don't show English fallback
                if currentLang:find("deDE") then
                    noteText = noteText.de or ""
                else
                    noteText = noteText.en or ""
                end
            end
            -- Convert to string and trim
            noteText = tostring(noteText):match("^%s*(.-)%s*$") or ""
            noteText = BeastAndBow.NormalizeMojibakeText(noteText)
            
            -- Add line breaks every ~35 characters on word boundaries
            local function wrapText(text, lineLength)
                local result = ""
                local currentLine = ""
                for word in text:gmatch("%S+") do
                    if #currentLine + #word + 1 > lineLength then
                        if currentLine ~= "" then
                            result = result .. currentLine .. "\n"
                            currentLine = word
                        else
                            result = result .. word .. "\n"
                            currentLine = ""
                        end
                    else
                        if currentLine == "" then
                            currentLine = word
                        else
                            currentLine = currentLine .. " " .. word
                        end
                    end
                end
                if currentLine ~= "" then
                    result = result .. currentLine
                end
                return result
            end
            
            if noteText ~= "" then
                noteText = wrapText(noteText, 35)
                notesFS:SetText(string.format("%s:\n%s", (BAB.L and BAB.L["PET_DETAIL_NOTES"]) or "Notes", noteText))
            else
                notesFS:SetText("")
            end
        else
            notesFS:SetText("")
        end
    end
    local scene = GetUI("BeastAndBowPetsModel")
    if scene then
        scene:ClearModel()
        if sp and sp.displayId then
            scene:SetDisplayInfo(sp.displayId)
            scene:SetCamDistanceScale(1.0)
            scene:SetPortraitZoom(0)
            if scene.SetFacing then
                scene:SetFacing(0)
            end
            if scene.SetPosition then
                BeastAndBow.PetsModelTransform = { x = 0, y = 0, z = 0 }
                scene:SetPosition(0, 0, 0)
            end
        end
        BeastAndBow.EnablePetsModelMouseControls(scene)
    end
end

    function BeastAndBow.PetsBackToSpecies()
        GetUI("BeastAndBowPetsModelContainer"):Hide()
        GetUI("BeastAndBowPetsInfo"):Hide()
        
        GetUI("BeastAndBowPetsCategoriesScroll"):Show()
        GetUI("BeastAndBowPetsSpeciesScroll"):Show()
    end

    function BeastAndBow.RotatePetsModel(delta)
        local scene = GetUI("BeastAndBowPetsModel")
        if scene and scene.SetFacing then
            local currentFacing = scene:GetFacing() or 0
            scene:SetFacing(currentFacing + delta)
        end
    end

    function BeastAndBow.EnablePetsModelMouseControls(scene)
        scene = scene or GetUI("BeastAndBowPetsModel")
        if not scene or scene._babMouseControlsReady then return end

        scene:EnableMouse(true)
        scene:EnableMouseWheel(true)

        scene:SetScript("OnMouseDown", function(self, button)
            if button ~= "LeftButton" and button ~= "RightButton" then return end
            local scale = (UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()) or 1
            local x, y = GetCursorPosition()
            self._babDragMode = button
            self._babLastCursorX = x / scale
            self._babLastCursorY = y / scale
        end)

        scene:SetScript("OnMouseUp", function(self, button)
            if self._babDragMode == button then
                self._babDragMode = nil
            end
        end)

        scene:SetScript("OnHide", function(self)
            self._babDragMode = nil
        end)

        scene:SetScript("OnUpdate", function(self)
            local mode = self._babDragMode
            if not mode then return end

            local scale = (UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()) or 1
            local x, y = GetCursorPosition()
            x = x / scale
            y = y / scale

            local lastX = self._babLastCursorX or x
            local lastY = self._babLastCursorY or y
            local dx = x - lastX
            local dy = y - lastY

            self._babLastCursorX = x
            self._babLastCursorY = y

            if mode == "RightButton" and self.SetFacing then
                local currentFacing = self:GetFacing() or 0
                self:SetFacing(currentFacing + (dx * 0.01))
            elseif mode == "LeftButton" and self.SetPosition then
                local state = BeastAndBow.PetsModelTransform or { x = 0, y = 0, z = 0 }
                -- x-axis behaves like depth on many models, so map horizontal drag to y.
                state.y = (state.y or 0) + (dx * 0.01)
                state.z = (state.z or 0) + (dy * 0.01)
                BeastAndBow.PetsModelTransform = state
                self:SetPosition(state.x or 0, state.y, state.z)
            end
        end)

        scene:SetScript("OnMouseWheel", function(self, delta)
            if not self.SetPosition then return end
            local state = BeastAndBow.PetsModelTransform or { x = 0, y = 0, z = 0 }
            -- Wheel controls depth (forward/backward movement).
            state.x = (state.x or 0) + (delta * 0.08)
            BeastAndBow.PetsModelTransform = state
            self:SetPosition(state.x, state.y or 0, state.z or 0)
        end)

        scene._babMouseControlsReady = true
    end

    function BeastAndBow.FindSelectedPet()
        local cat = BeastAndBow.SelectedCategory
        local idx = BeastAndBow.SelectedSpeciesIndex
        if not cat or not idx or not cat.species or not cat.species[idx] then
            bab_print("No pet selected.", BeastAndBow.Debug.LEVELS.WARN, "Pet")
            return
        end
        local sp = cat.species[idx]
        -- Require being in the correct zone before creating a waypoint
        if sp and sp.zone and sp.zone ~= "" then
            local englishZoneName
            local localizedZoneName
            local uiMapID

            if C_Map and C_Map.GetBestMapForUnit then
                uiMapID = C_Map.GetBestMapForUnit("player")
            end

            if uiMapID then
                -- Get English name from our database for comparison
                if BeastAndBow.EnglishMapNames and BeastAndBow.EnglishMapNames[uiMapID] then
                    englishZoneName = BeastAndBow.EnglishMapNames[uiMapID]
                end
                -- Get localized name for display in messages
                if C_Map and C_Map.GetMapInfo then
                     local info = C_Map.GetMapInfo(uiMapID)
                     if info and info.name then localizedZoneName = info.name end
                end
            end

            -- Fallback to GetRealZoneText if C_Map APIs failed
            if not localizedZoneName then
                local _GetRealZoneText = rawget(_G, "GetRealZoneText")
                if type(_GetRealZoneText) == "function" then
                    localizedZoneName = _GetRealZoneText()
                end
            end
            
            -- If we couldn't get an English name, fallback to the localized one for the check.
            -- This maintains old behavior for zones not in our English map DB.
            if not englishZoneName then
                englishZoneName = localizedZoneName
            end

            if englishZoneName and type(englishZoneName) == "string" then
                local function normalize(s)
                    if not s then return "" end
                    return s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""):lower()
                end

                local petZone = normalize(sp.zone)
                local playerZone = normalize(englishZoneName)

                -- Check if the player's zone is contained within the pet's zone string.
                -- This handles cases like "Darkshore" vs "Ruins of Mathystra, Darkshore".
                if not petZone:find(playerZone, 1, true) then
                    bab_print(string.format("You are in '%s'. This pet is found in '%s'.", localizedZoneName or englishZoneName, sp.zone), BeastAndBow.Debug.LEVELS.INFO, "Pet")
                    return
                end
            end
        end
        if sp.zone and sp.coords and sp.coords[1] then
            local mapID = BeastAndBow.GetMapIDByZoneName and BeastAndBow.GetMapIDByZoneName(sp.zone)
            
            -- WICHTIG: Konvertiere alte MapID zu HBD uiMapID
            -- HBD:GetZoneDistance() und andere HBD-Funktionen erwarten uiMapID format (56, 37, etc)
            if mapID and BeastAndBow.MapIDToHBDUI and BeastAndBow.MapIDToHBDUI[mapID] then
                mapID = BeastAndBow.MapIDToHBDUI[mapID]
            end
            
            if mapID then
                -- UnterstÃ¼tzt mehrere Koordinaten
                local targets = {}
                for _, coord in ipairs(sp.coords) do
                    if coord[1] and coord[2] then
                        -- Daten sind in Prozent (0-100), konvertiere zu normalized (0-1)
                        local normX = coord[1] / 100
                        local normY = coord[2] / 100
                        table.insert(targets, {mapID=mapID, x=normX, y=normY, label=sp.name})
                    end
                end
                if #targets > 0 then
                    -- Convert the zone-based targets to world-coordinate targets for the new arrow logic
                    local worldTargets = {}
                    if HBD and HBD.GetWorldCoordinatesFromZone then
                        for _, target in ipairs(targets) do
                            local wx, wy, instance = HBD:GetWorldCoordinatesFromZone(target.x, target.y, target.mapID)
                            if wx then
                                table.insert(worldTargets, {
                                    wx=wx, wy=wy, instance=instance, label=target.label,
                                    uiMapID=target.mapID, normX=target.x, normY=target.y
                                })
                            end
                        end
                    end
                    BeastAndBow.SetNavigationTargets(worldTargets)
                else
                    bab_print("No valid coordinates for this pet.", BeastAndBow.Debug.LEVELS.WARN, "Pet")
                end
            else
                bab_print("Unknown map for zone '" .. tostring(sp.zone) .. "'.", BeastAndBow.Debug.LEVELS.ERROR, "Pet")
            end
        else
            bab_print("No location data for this pet yet.", BeastAndBow.Debug.LEVELS.INFO, "Pet")
        end
    end
    
    -- Stable memory: store and show last seen stable pets
    function BeastAndBow.RecordStablePets(petList)
        if type(petList) ~= "table" then return end
        BeastAndBow_StableSeen = BeastAndBow_StableSeen or {}
        for _, name in ipairs(petList) do
            if type(name) == "string" and name ~= "" then
                BeastAndBow_StableSeen[name] = true
            end
        end
    end

    function BeastAndBow.OpenStableOptions()
        local f = GetUI("BeastAndBowStableFrame")
        if not f then return end
        f:Show()
        local listBox = GetUI("BeastAndBowStableList")
        if listBox and listBox.SetText then
            local names = {}
            for k,_ in pairs(BeastAndBow_StableSeen or {}) do table.insert(names, k) end
            table.sort(names)
            local text = (#names > 0) and table.concat(names, "\n") or "No stable pets recorded yet."
            listBox:SetText(text)
        end
    end

    -- Simple slash to add current pet name to stable memory (helper)
    SLASH_BABSTABLE1 = "/babstable"
    SlashCmdList["BABSTABLE"] = function(msg)
        local name = tostring(msg or "")
        if name ~= "" then
            BeastAndBow.RecordStablePets({name})
            bab_print("Recorded stable pet '" .. name .. "'.", BeastAndBow.Debug.LEVELS.INFO, "Stable")
        else
            bab_print("Usage: /babstable <PetName>", BeastAndBow.Debug.LEVELS.INFO, "Stable")
        end
    end

    function BeastAndBow.GenerateReport()
        local reportBox = GetUI("BeastAndBowReportFrameEditBox")
        local userInput = reportBox and reportBox.GetText and reportBox:GetText() or ""
        if not userInput or userInput == "" then
            userInput = "No message entered."
        end

        local report = {}
        table.insert(report, "```") -- Start of code block for easy copying
        table.insert(report, "## Beast & Bow Report")
        local version = "unknown"
        if GetAddOnMetadata then
            local ok, v = pcall(GetAddOnMetadata, "BeastAndBow", "Version")
            if ok and v then version = v end
        end
        table.insert(report, string.format("**Addon Version:** %s", version))

        -- Game Info
        local build, _, _, _ = GetBuildInfo()
        local localizedClass, _ = UnitClass("player")
        local localizedRace, _ = UnitRace("player")
        local localizedFaction, _ = UnitFactionGroup("player")
        table.insert(report, string.format("**WoW Version:** %s", build))
        table.insert(report, string.format("**Class:** %s", localizedClass))
        table.insert(report, string.format("**Race:** %s", localizedRace))
        table.insert(report, string.format("**Faction:** %s", localizedFaction))
        table.insert(report, string.format("**Level:** %d", UnitLevel("player")))

        table.insert(report, "\n**User's Message:**")
        table.insert(report, userInput)

        -- Addon List
        table.insert(report, "\n**Enabled Addons:**")
        local addons = {}
        for i = 1, GetNumAddOns() do
            local name, _, _, enabled = GetAddOnInfo(i)
            if enabled then
                table.insert(addons, name)
            end
        end
        table.sort(addons)
        table.insert(report, table.concat(addons, ", "))
        table.insert(report, "```") -- End of code block

        local reportString = table.concat(report, "\n")

        local copyBox = GetUI("BeastAndBowCopyEditBox")
        if copyBox and copyBox.SetText then copyBox:SetText(reportString) end
        if copyBox and copyBox.HighlightText then copyBox:HighlightText() end

        local reportF = GetUI("BeastAndBowReportFrame")
        local copyF = GetUI("BeastAndBowCopyFrame")
        if reportF and reportF.IsShown and reportF:IsShown() then
            if HideUIPanel then HideUIPanel(reportF) end
        end
        if copyF then
            if ShowUIPanel then ShowUIPanel(copyF) end
        end
    end

    -- Track if events have been registered to prevent duplicate registration
    local eventsRegistered = false

    local hunterAttackSpells = {
        -- English
        ["Auto Shot"] = true,
        ["Aimed Shot"] = true,
        ["Arcane Shot"] = true,
        ["Multi-Shot"] = true,
        ["Raptor Strike"] = true,
        ["Mongoose Bite"] = true,
        ["Serpent Sting"] = true,
        ["Viper Sting"] = true,
        ["Scorpid Sting"] = true,
        ["Wing Clip"] = true,
        ["Hunter's Mark"] = true,
        -- German
        ["Automatischer Schuss"] = true,
        ["Gezielter Schuss"] = true,
        ["Arkaner Schuss"] = true,
        ["Mehrfachschuss"] = true,
        ["RaptorstoÃŸ"] = true,
        ["Mungobiss"] = true,
        ["Schlangenbiss"] = true,
        ["Vipernbiss"] = true,
        ["Skorpidstich"] = true,
        ["Zurechtstutzen"] = true,
        ["Mal des JÃ¤gers"] = true,
    }

        function BeastAndBow.IsPetDismissed()
    for i = 1, 5 do -- There are 5 pet slots in Classic
        if not GetPetActionInfo(i) then break end -- Stop if no more pet actions
        local _, _, state = GetPetActionInfo(i)
        if state == "dismissed" then
            return true
        end
    end
    return false
end

function BeastAndBow.CallPet()
    for i = 1, 5 do
        if not GetPetActionInfo(i) then break end -- Stop if no more pet actions
        local name, _, state = GetPetActionInfo(i)
        if state == "dismissed" and name then
            CallCompanion("PET", i)
            return -- Call only one
        end
    end
end

function BeastAndBow.OnEvent(self, event, ...)

    if event == "PLAYER_ENTERING_WORLD" then
    
            -- Reset warning flags on entering world to ensure a clean state
    
            firstUpdateAfterLogin = true
    
            lowAmmoWarningPlayed = false
    
            lowAmmoBannerShown = false
    
            travelWarningPlayed = false
    
            
    
            -- Register other events now that we are in the world (only once)
    
            if not eventsRegistered then
    
                self:RegisterEvent("UNIT_INVENTORY_CHANGED")
    
                self:RegisterEvent("BAG_UPDATE")
    
                self:RegisterEvent("BAG_UPDATE_DELAYED")
    
                self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    
                self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    
                self:RegisterEvent("TAXIMAP_OPENED")
    
                self:RegisterEvent("TAXIMAP_CLOSED")
    
                self:RegisterEvent("MERCHANT_SHOW") -- Register auto-buy event

                self:RegisterEvent("PLAYER_REGEN_DISABLED") -- For pet auto-attack on combat start
                
                self:RegisterEvent("PLAYER_REGEN_ENABLED") -- For pet auto-call after combat
    
                self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- For pet auto-attack
    
                -- Stable events to auto-record pets when opening the stable UI
    
                if type(self.RegisterEvent) == "function" then
    
                    self:RegisterEvent("PET_STABLE_SHOW")
    
                    self:RegisterEvent("PET_STABLE_UPDATE")
    
                end
    
                eventsRegistered = true
    
            end
    
    
    
            -- Unregister this event as it's no longer needed
    
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    
    
    
            -- Delay AutoDetectAmmo and Update to ensure inventory is fully loaded
    
            C_Timer.After(5.0, function()
    
                AutoDetectAmmo()
    
                if BeastAndBow.BuildAbilityDB then
    
                    BeastAndBow.BuildAbilityDB()
    
                end
    
                DelayedInitialUpdate()
    
            end)
    
    
    
            -- Grace period: suppress low-ammo warnings for 5 seconds after login
    
            loginGraceLowAmmo = true
    
            C_Timer.After(5, function()
    
                loginGraceLowAmmo = false
    
            end)
    
    
    
    
    
        elseif event == "ZONE_CHANGED_NEW_AREA" then
    
            local _, englishClass = UnitClass("player")
    
            if englishClass ~= "HUNTER" then
    
                if C_Map and C_Map.GetBestMapForUnit then
    
                    lastUIMapID = C_Map.GetBestMapForUnit("player")
    
                end
    
                return
    
            end
    
    
    
            local newUIMapID
    
            if C_Map and C_Map.GetBestMapForUnit then
    
                newUIMapID = C_Map.GetBestMapForUnit("player")
    
            end
    
    
    
            local _, instanceType = GetInstanceInfo()
    
            local wasInCapital = IsPlayerInCapitalCity(lastUIMapID)
    
            local isInCapital = IsPlayerInCapitalCity(newUIMapID)
    
    
    
            -- Trigger 1: Entering a dungeon or raid
    
            if instanceType == "party" or instanceType == "raid" then
    
                AutoDetectAmmo()
    
                TravelCheck()
    
            -- Trigger 2: Leaving a capital city zone (and not entering another capital or an instance)
    
            elseif wasInCapital and not isInCapital and instanceType == "none" then
    
                 AutoDetectAmmo()
    
                 TravelCheck()
    
            end
    
            
    
            -- Update last known map ID
    
            lastUIMapID = newUIMapID
    
    
    
        elseif event == "TAXIMAP_OPENED" then
    
            local _, englishClass = UnitClass("player")
    
            if englishClass ~= "HUNTER" then return end
    
    
    
            local onTaxi = (type(IsOnTaxi) == "function" and IsOnTaxi())
    
            if onTaxi then return end
    
    
    
            local currentMapID
    
            if C_Map and C_Map.GetBestMapForUnit then
    
                currentMapID = C_Map.GetBestMapForUnit("player")
    
            end
    
            
    
            local isInCapital = IsPlayerInCapitalCity(currentMapID)
    
    
    
            if isInCapital then
    
                AutoDetectAmmo()
    
                TravelCheck()
    
            end
    
    
    
        elseif event == "TAXIMAP_CLOSED" then
    
            -- No action needed
    
    
    
        elseif event == "PET_STABLE_SHOW" or event == "PET_STABLE_UPDATE" then
    
            -- When the stable UI is shown or updated, record current stable pet names
    
            local _, englishClass = UnitClass("player")
    
            if englishClass ~= "HUNTER" then return end
    
            local names = {}
    
            local _GetStablePetInfo = rawget(_G, "GetStablePetInfo")
    
            if type(_GetStablePetInfo) == "function" then
    
                for i = 0, 12 do
    
                    local icon, name, level = _GetStablePetInfo(i)
    
                    if name and name ~= "" then table.insert(names, name) end
    
                end
    
            end
    
            if #names > 0 then BeastAndBow.RecordStablePets(names) end
    
    
    
        elseif event == "UNIT_INVENTORY_CHANGED" then
    
            local unit, slotId = ...
    
            if unit == "player" then
    
                -- WENN sich die Waffe Ã¤ndert ODER die Munition Ã¤ndert -> Neu erkennen!
    
                if slotId == INV_RANGED or slotId == INV_AMMO then  -- <--- DAS HIER ERGÃ„NZEN (or slotId == INV_AMMO)
    
                    -- Enter brief grace to avoid mixed-type blink when swapping
    
                    swappingGrace = true
    
                    C_Timer.After(2.5, function() swappingGrace = false end)
    
                    AutoDetectAmmo()
    
                end
    
                Update()
    
            end
    
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    
            -- Fires when equipment changes; only re-autodetect if ranged or ammo slot changed
    
            local slotId = ...
    
            if slotId == INV_RANGED or slotId == INV_AMMO then
    
                swappingGrace = true
    
                C_Timer.After(2.5, function() swappingGrace = false end)
    
                AutoDetectAmmo()
    
            end
    
            Update()
    
        elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
    
            -- Bags changed (items used, bought, moved) -> update counts
    
            Update()
    
        elseif event == "PLAYER_REGEN_DISABLED" then
    
            -- The PetAttack() call was removed from here. The pet auto-attack logic
            -- is now handled exclusively by BeastAndBow.HandlePetAutoAttack, which is
            -- triggered by COMBAT_LOG_EVENT_UNFILTERED to avoid protected action errors.

        elseif event == "PLAYER_REGEN_ENABLED" then

            if BeastAndBow_Settings.autoCallPet == true and BeastAndBow.IsPetDismissed() then
                BeastAndBow.CallPet()
            end

        elseif event == "MERCHANT_SHOW" then
    
            if BeastAndBow.AutoBuyArrows_EventHandler then
    
                BeastAndBow.AutoBuyArrows_EventHandler()
    
            end
    
            if BeastAndBow.AutoBuyPetFood_EventHandler then
    
                BeastAndBow.AutoBuyPetFood_EventHandler()
    
            end

            if BeastAndBow.AutoBuyBullets_EventHandler then

                BeastAndBow.AutoBuyBullets_EventHandler()

            end
    
        end
    
    end

function BeastAndBow.AutoBuyArrows_EventHandler()
    if not BeastAndBow_Settings or not BeastAndBow_Settings.autoBuyArrows or not BeastAndBow_Settings.autoBuyArrowID then
        return -- Feature is disabled or not configured
    end

    local debugEnabled = BeastAndBow_Settings and BeastAndBow_Settings.debug
    local arrowIDToBuy = BeastAndBow_Settings.autoBuyArrowID
    
    -- Check if merchant items are loaded
    if GetMerchantNumItems() == 0 then
        if debugEnabled then
            bab_print("Auto-buy: Waiting for merchant data to load, scheduling retry.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end
        -- Schedule a retry after a short delay to allow merchant data to load
        if not BeastAndBow.autoBuyRetries then
            BeastAndBow.autoBuyRetries = 0
        end
        BeastAndBow.autoBuyRetries = BeastAndBow.autoBuyRetries + 1
        
        -- Give up after 5 retries (approximately 2.5 seconds)
        if BeastAndBow.autoBuyRetries > 5 then
            if debugEnabled then
                bab_print("Auto-buy: Merchant data still not loaded after retries, giving up.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end
            BeastAndBow.autoBuyRetries = 0
            return
        end
        
        C_Timer.After(0.5, function()
            BeastAndBow.AutoBuyArrows_EventHandler()
        end)
        return
    end
    
    -- Reset retry counter when we have merchant data
    BeastAndBow.autoBuyRetries = 0
    local quiverBagID = nil
    local quiverTotalSlots = 0

    -- Define Quiver and Ammo Pouch IDs
    local quiverItemIDs = {
        [238925] = true, -- Scharlachroter KÃ¶cher (30)
        [236864] = true, -- SeelenfrostkÃ¶cher (26)
        [18714] = true,  -- Uraltes in Sehnen eingewickeltes Laminablatt (18)
        [216514] = true, -- BlutkÃ¶cher (16)
        [19319] = true,  -- KÃ¶cher aus Harpienhaut (16)
        [8217] = true,   -- SchnellziehkÃ¶cher (16)
        [2662] = true,   -- Ribblys KÃ¶cher (16)
        [7371] = true,   -- Schwerer KÃ¶cher (14)
        [3605] = true,   -- KÃ¶cher der Nachtwache (12)
        [11362] = true,  -- Mittlerer KÃ¶cher (10)
        [3573] = true,   -- JagdkÃ¶cher (10)
        [5439] = true,   -- Kleiner KÃ¶cher (8)
        [7278] = true,   -- Leichter LederkÃ¶cher (8)
        [2101] = true,   -- Leichter KÃ¶cher (6)
    }

    -- 1. Find equipped quiver by Item ID
    if debugEnabled then
        bab_print("Auto-buy: Attempting detection by item ID.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end

    -- Helper: collect bag family and itemID for any bagID, including reagent bag if present.
    local function GetBagMeta(bagID)
        local invSlot
        if ContainerIDToInventoryID then
            invSlot = ContainerIDToInventoryID(bagID)
        else
            -- Classic bagID 0..4 map to inventory slots 19+bagID; reagent bag (5) -> slot 24
            invSlot = (bagID == 5) and 24 or (19 + bagID)
        end

        local itemLink = invSlot and GetInventoryItemLink("player", invSlot)
        local itemID = invSlot and GetInventoryItemID("player", invSlot) or (itemLink and tonumber(itemLink:match("item:(%d+)")))

        local bagFamily
        if C_Container and C_Container.GetContainerNumFreeSlots then
            local _, family = C_Container.GetContainerNumFreeSlots(bagID)
            bagFamily = family
        elseif GetContainerNumFreeSlots then
            local _, family = GetContainerNumFreeSlots(bagID)
            bagFamily = family
        end
        bagFamily = bagFamily or (itemID and GetItemFamily(itemID)) or 0

        local itemName = (itemLink and GetItemInfo(itemLink)) or (itemID and GetItemInfo(itemID))
        local _, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfo(itemID or 0)

        return invSlot, itemID, itemName, bagFamily, itemClassID, itemSubClassID
    end

    local maxBagID = NUM_BAG_SLOTS or 4
    if REAGENTBAG_CONTAINER then maxBagID = math.max(maxBagID, REAGENTBAG_CONTAINER) end
    if Enum and Enum.BagIndex and Enum.BagIndex.Reagentbag then
        maxBagID = math.max(maxBagID, Enum.BagIndex.Reagentbag)
    end
    if maxBagID < 5 then maxBagID = 5 end -- be generous for SoD/DF reagent bag slot

    for bagID = 0, maxBagID do
        if debugEnabled then bab_print(string.format("Auto-buy: Checking bag slot %d.", bagID), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy") end

        local invSlot, itemID, itemName, bagFamily, itemClassID, itemSubClassID = GetBagMeta(bagID)

        if not itemID and debugEnabled then
            bab_print(string.format("Auto-buy: Bag slot %d has no link/ID yet (inventorySlot=%s, family=0x%X).", bagID, tostring(invSlot), bagFamily), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end

        -- Detect quiver by family bit even if ID is missing.
        local isQuiverByFamily = bit and bit.band(bagFamily, 0x0001) ~= 0
        local isQuiverByID = itemID and quiverItemIDs[itemID] == true
        local isQuiverByClass = (itemClassID == 1 and itemSubClassID == 2)

        if isQuiverByFamily or isQuiverByID or isQuiverByClass then
            quiverBagID = bagID
            if C_Container and C_Container.GetContainerNumSlots then
                quiverTotalSlots = C_Container.GetContainerNumSlots(quiverBagID)
            elseif GetContainerNumSlots then
                quiverTotalSlots = GetContainerNumSlots(quiverBagID)
            end
            if debugEnabled then
                bab_print(string.format("Auto-buy: Found quiver '%s' (ID: %s, family=0x%X, class=%s/%s) in bag %d (invSlot=%s).", itemName or "Unknown", tostring(itemID), bagFamily, tostring(itemClassID), tostring(itemSubClassID), bagID, tostring(invSlot)), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end
            break
        elseif debugEnabled then
            bab_print(string.format("Auto-buy: Ignored bag '%s' (ID: %s, family=0x%X, class=%s/%s, invSlot=%s) in bag slot %d. Not a known quiver.", itemName or "Unknown", tostring(itemID), bagFamily, tostring(itemClassID), tostring(itemSubClassID), tostring(invSlot), bagID), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end
    end

    if not quiverBagID or quiverTotalSlots == 0 then
        if BeastAndBow_Settings.debug then bab_print("Auto-buy: No quiver/pouch equipped or capacity not found.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy") end
        return -- No quiver found, nothing to do
    end

    -- 2. Figure out current ammo count and available slots
    local currentCount = 0
    local occupiedByOtherItems = 0

    for slot = 1, quiverTotalSlots do
        local itemLink
        if C_Container and C_Container.GetContainerItemLink then
            itemLink = C_Container.GetContainerItemLink(quiverBagID, slot)
        elseif GetContainerItemLink then
            itemLink = GetContainerItemLink(quiverBagID, slot)
        end

        if itemLink then
            local itemIDInSlot = tonumber(itemLink:match("item:(%d+)"))
            if itemIDInSlot == arrowIDToBuy then
                local count
                if C_Container and C_Container.GetContainerItemInfo then
                    -- Modern API returns a table
                    local info = C_Container.GetContainerItemInfo(quiverBagID, slot)
                    count = info and info.stackCount
                elseif GetContainerItemInfo then
                    -- Legacy API returns multiple values
                    _, count = GetContainerItemInfo(quiverBagID, slot)
                end
                currentCount = currentCount + (count or 0)
            else
                occupiedByOtherItems = occupiedByOtherItems + 1
            end
        end
    end

    if debugEnabled then
        bab_print(string.format("Auto-buy: quiver scan -> current of correct type=%d, slots occupied by others=%d", currentCount, occupiedByOtherItems), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end

    -- 3. Check if the merchant sells the desired arrows
    if debugEnabled then
        bab_print(string.format("Auto-buy: Looking for arrow ItemID %d", arrowIDToBuy), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end
    
    local merchantItemIndex = nil
    for i = 1, GetMerchantNumItems() do
        local itemLink = GetMerchantItemLink(i)
        if itemLink then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            if debugEnabled then
                local itemName = GetItemInfo(itemLink)
                bab_print(string.format("Auto-buy: Merchant item %d: %s (ID %s)", i, itemName or "unknown", tostring(itemID)), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end
            if itemID == arrowIDToBuy then
                merchantItemIndex = i
                if debugEnabled then
                    bab_print(string.format("Auto-buy: Found matching arrows at merchant index %d", i), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                end
                break
            end
        end
    end

    if not merchantItemIndex then
        if BeastAndBow.L and BeastAndBow.L.VENDOR_DOES_NOT_SELL then
            local arrowName = BeastAndBow_Settings.autoBuyArrowName or ("ItemID " .. tostring(arrowIDToBuy))
            bab_print(string.format(BeastAndBow.L.VENDOR_DOES_NOT_SELL, arrowName), BeastAndBow.Debug.LEVELS.INFO)
        end
        return -- Vendor doesn't sell the arrows
    end

    -- 4. Buy exactly enough stacks to reach quiver capacity
    local itemName, _, price, stackSize = GetMerchantItemInfo(merchantItemIndex)
    local maxStack = GetMerchantItemMaxStack(merchantItemIndex)
    
    if debugEnabled then
        bab_print(string.format("Auto-buy: Merchant info - itemName='%s', price=%s, stackSize=%s, maxStack=%s", 
            tostring(itemName), tostring(price), tostring(stackSize), tostring(maxStack)), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end
    
    if not stackSize or stackSize == 0 then
        stackSize = 1 -- Fallback
    end

    local availableSlots = quiverTotalSlots - occupiedByOtherItems
    local totalCapacity = availableSlots * stackSize
    local missingItems = math.max(0, totalCapacity - currentCount)

    if debugEnabled then
        bab_print(string.format("Auto-buy: quiverSlots=%d availableSlots=%d stackSize=%d current=%d totalCapacity=%d missing=%d", quiverTotalSlots, availableSlots, stackSize, currentCount, totalCapacity, missingItems), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end

    if missingItems > 0 then
        -- Count total free slots across all bags to ensure purchase doesn't fail
        local freeSlots = 0
        for i = 0, NUM_BAGS do
            if C_Container and C_Container.GetContainerNumFreeSlots then
                freeSlots = freeSlots + (C_Container.GetContainerNumFreeSlots(i) or 0)
            elseif GetContainerNumFreeSlots then
                freeSlots = freeSlots + (GetContainerNumFreeSlots(i) or 0)
            end
        end
        
        if debugEnabled then
            bab_print(string.format("Auto-buy: Total free slots: %d", freeSlots), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end
        
        local stacksToBuy = math.ceil(missingItems / stackSize)
        
        if debugEnabled then
            bab_print(string.format("Auto-buy: Stacks needed: %d (missing=%d, stackSize=%d)", stacksToBuy, missingItems, stackSize), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end
        
        if freeSlots < stacksToBuy then
             if debugEnabled then
                bab_print(string.format("Auto-buy: Not enough free slots (%d) to buy all %d missing items (%d stacks needed). Reducing amount.", freeSlots, missingItems, stacksToBuy), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end
            stacksToBuy = freeSlots
        end

        if price and price > 0 then
            local money = GetMoney()
            local totalCost = stacksToBuy * price

            if debugEnabled then
                bab_print(string.format("Auto-buy: Price check - Have: %d copper, Need: %d copper for %d stacks (price=%d per stack)", money, totalCost, stacksToBuy, price), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end

            if money < totalCost then
                local stacksCanAfford = math.floor(money / price)
                if debugEnabled then
                    bab_print(string.format("Auto-buy: Not enough money for %d stacks. Can afford %d stacks.", stacksToBuy, stacksCanAfford), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                end
                bab_print("Nicht genug Gold, um den KÃ¶cher aufzufÃ¼llen. Es wird eine geringere Menge gekauft.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                stacksToBuy = stacksCanAfford
            end
        end

        if stacksToBuy > 0 then
            -- Correctly calculate items to buy, capped by original missing amount
            -- and what's possible with money/slots.
            local itemsToBuy = math.min(missingItems, stacksToBuy * stackSize)

            if itemsToBuy > 0 then
                if debugEnabled then
                    bab_print(string.format("Auto-buy: Attempting to buy a total of %d items (%s, ItemID %d), capped by available slots/money.", itemsToBuy, itemName or "arrows", arrowIDToBuy), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                end

                -- Buy in chunks of stackSize to avoid "Internal Bag Error"
                local purchasedCount = 0
                while purchasedCount < itemsToBuy do
                    local amountInThisGo = math.min(stackSize, itemsToBuy - purchasedCount)
                    if amountInThisGo > 0 then
                        if debugEnabled then
                            bab_print(string.format("Auto-buy: Buying chunk of %d items.", amountInThisGo), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                        end
                        BuyMerchantItem(merchantItemIndex, amountInThisGo)
                        purchasedCount = purchasedCount + amountInThisGo
                    else
                        -- Should not be reached, but as a safeguard.
                        break
                    end
                end
            end
        end
    elseif BeastAndBow_Settings.debug then
        bab_print("Auto-buy: Quiver is already full with the correct arrows or occupied by other items.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end
end

function BeastAndBow.AutoBuyBullets_EventHandler()
    if not BeastAndBow_Settings or not BeastAndBow_Settings.autoBuyBullets or not BeastAndBow_Settings.autoBuyBulletID then
        return -- Feature is disabled or not configured
    end

    local debugEnabled = BeastAndBow_Settings and BeastAndBow_Settings.debug
    local bulletIDToBuy = BeastAndBow_Settings.autoBuyBulletID

    -- Shared helper (duplicated from arrows) to inspect bag meta by bagID.
    local function GetBagMeta(bagID)
        local invSlot
        if ContainerIDToInventoryID then
            invSlot = ContainerIDToInventoryID(bagID)
        else
            invSlot = (bagID == 5) and 24 or (19 + bagID)
        end

        local itemLink = invSlot and GetInventoryItemLink("player", invSlot)
        local itemID = invSlot and GetInventoryItemID("player", invSlot) or (itemLink and tonumber(itemLink:match("item:(%d+)")))

        local bagFamily
        if C_Container and C_Container.GetContainerNumFreeSlots then
            local _, family = C_Container.GetContainerNumFreeSlots(bagID)
            bagFamily = family
        elseif GetContainerNumFreeSlots then
            local _, family = GetContainerNumFreeSlots(bagID)
            bagFamily = family
        end
        bagFamily = bagFamily or (itemID and GetItemFamily(itemID)) or 0

        local itemName = (itemLink and GetItemInfo(itemLink)) or (itemID and GetItemInfo(itemID))
        local _, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfo(itemID or 0)

        return invSlot, itemID, itemName, bagFamily, itemClassID, itemSubClassID
    end

    -- Determine max bag index (include reagent bag slot if present).
    local maxBagID = NUM_BAG_SLOTS or 4
    if REAGENTBAG_CONTAINER then maxBagID = math.max(maxBagID, REAGENTBAG_CONTAINER) end
    if Enum and Enum.BagIndex and Enum.BagIndex.Reagentbag then
        maxBagID = math.max(maxBagID, Enum.BagIndex.Reagentbag)
    end
    if maxBagID < 5 then maxBagID = 5 end

    -- Define Ammo Pouch IDs
    local ammoPouchItemIDs = {
        [238926] = true, -- Scharlachroter Munitionsbeutel (30)
        [236869] = true, -- Seelenfrostmunitionsbeutel (26)
        [216515] = true, -- Blutmunitionsbeutel (16)
        [19320] = true,  -- SchultergÃ¼rtel aus Gnollhaut (16)
        [8218] = true,   -- Dicker Ledermunitionsbeutel (16)
        [2663] = true,   -- Ribblys SchultergÃ¼rtel (16)
        [7372] = true,   -- Schwerer Ledermunitionsbeutel (14)
        [3604] = true,   -- SchultergÃ¼rtel der Nachtwache (12)
        [11363] = true,  -- Mittlerer Geschossbeutel (10)
        [3574] = true,   -- Jagdmunitionssack (10)
        [5441] = true,   -- Kleiner Geschossbeutel (8)
        [7279] = true,   -- Kleiner Ledermunitionsbeutel (8)
        [2102] = true,   -- Kleiner Munitionsbeutel (6)
    }

    -- 1. Find equipped ammo pouch by Item ID
    local pouchBagID = nil
    local pouchTotalSlots = 0

    if debugEnabled then
        bab_print("Auto-buy: Attempting detection of ammo pouch by item ID.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end

    if debugEnabled then bab_print("Auto-buy: Starting bag scan for ammo pouches.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy") end

    for bagID = 0, maxBagID do
        if debugEnabled then bab_print(string.format("Auto-buy: Checking bag slot %d.", bagID), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy") end

        local invSlot, itemID, itemName, bagFamily, itemClassID, itemSubClassID = GetBagMeta(bagID)

        if not itemID and debugEnabled then
            bab_print(string.format("Auto-buy: Bag slot %d has no link/ID yet (inventorySlot=%s, family=0x%X).", bagID, tostring(invSlot), bagFamily), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end

        local isPouchByFamily = bit and bit.band(bagFamily, 0x0002) ~= 0
        local isPouchByID = itemID and ammoPouchItemIDs[itemID] == true
        local isPouchByClass = (itemClassID == 1 and itemSubClassID == 3)

        if isPouchByFamily or isPouchByID or isPouchByClass then
            pouchBagID = bagID
            if C_Container and C_Container.GetContainerNumSlots then
                pouchTotalSlots = C_Container.GetContainerNumSlots(pouchBagID)
            elseif GetContainerNumSlots then
                pouchTotalSlots = GetContainerNumSlots(pouchBagID)
            end
            if debugEnabled then
                bab_print(string.format("Auto-buy: Found ammo pouch '%s' (ID: %s, family=0x%X, class=%s/%s) in bag %d (invSlot=%s).", itemName or "Unknown", tostring(itemID), bagFamily, tostring(itemClassID), tostring(itemSubClassID), bagID, tostring(invSlot)), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end
            break -- Found it
        elseif debugEnabled then
            bab_print(string.format("Auto-buy: Ignored bag '%s' (ID: %s, family=0x%X, class=%s/%s, invSlot=%s) in bag slot %d. Not a known ammo pouch.", itemName or "Unknown", tostring(itemID), bagFamily, tostring(itemClassID), tostring(itemSubClassID), tostring(invSlot), bagID), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end
    end

    if not pouchBagID or pouchTotalSlots == 0 then
        if BeastAndBow_Settings.debug then bab_print("Auto-buy: No ammo pouch equipped or capacity not found.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy") end
        return -- No pouch found, nothing to do
    end

    -- 2. Figure out current ammo count and available slots
    local currentCount = 0
    local occupiedByOtherItems = 0

    for slot = 1, pouchTotalSlots do
        local itemLink
        if C_Container and C_Container.GetContainerItemLink then
            itemLink = C_Container.GetContainerItemLink(pouchBagID, slot)
        elseif GetContainerItemLink then
            itemLink = GetContainerItemLink(pouchBagID, slot)
        end

        if itemLink then
            local itemIDInSlot = tonumber(itemLink:match("item:(%d+)"))
            if itemIDInSlot == bulletIDToBuy then
                local count
                if C_Container and C_Container.GetContainerItemInfo then
                    local info = C_Container.GetContainerItemInfo(pouchBagID, slot)
                    count = info and info.stackCount
                elseif GetContainerItemInfo then
                    _, count = GetContainerItemInfo(pouchBagID, slot)
                end
                currentCount = currentCount + (count or 0)
            else
                occupiedByOtherItems = occupiedByOtherItems + 1
            end
        end
    end

    if debugEnabled then
        bab_print(string.format("Auto-buy: pouch scan -> current of correct type=%d, slots occupied by others=%d", currentCount, occupiedByOtherItems), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end

    -- 3. Check if the merchant sells the desired bullets
    local merchantItemIndex = nil
    for i = 1, GetMerchantNumItems() do
        local itemLink = GetMerchantItemLink(i)
        if itemLink then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            if itemID == bulletIDToBuy then
                merchantItemIndex = i
                break
            end
        end
    end

    if not merchantItemIndex then
        if BeastAndBow.L and BeastAndBow.L.VENDOR_DOES_NOT_SELL then
            local bulletName = BeastAndBow_Settings.autoBuyBulletName or ("ItemID " .. tostring(bulletIDToBuy))
            bab_print(string.format(BeastAndBow.L.VENDOR_DOES_NOT_SELL, bulletName), BeastAndBow.Debug.LEVELS.INFO)
        end
        return -- Vendor doesn't sell the bullets
    end

    -- 4. Buy exactly enough stacks to reach pouch capacity
    local itemName, _, price, stackSize = GetMerchantItemInfo(merchantItemIndex)
    if not stackSize or stackSize == 0 then
        stackSize = 1 -- Fallback
    end
    
    local availableSlots = pouchTotalSlots - occupiedByOtherItems
    local totalCapacity = availableSlots * stackSize
    local missingItems = math.max(0, totalCapacity - currentCount)

    if debugEnabled then
        bab_print(string.format("Auto-buy: pouchSlots=%d availableSlots=%d stackSize=%d current=%d totalCapacity=%d missing=%d", pouchTotalSlots, availableSlots, stackSize, currentCount, totalCapacity, missingItems), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end

    if missingItems > 0 then
        -- Count total free slots across all bags to ensure purchase doesn't fail
        local freeSlots = 0
        for i = 0, NUM_BAGS do
            if C_Container and C_Container.GetContainerNumFreeSlots then
                freeSlots = freeSlots + (select(1, C_Container.GetContainerNumFreeSlots(i)) or 0)
            elseif GetContainerNumFreeSlots then
                freeSlots = freeSlots + (GetContainerNumFreeSlots(i) or 0)
            end
        end
        
        local stacksToBuy = math.ceil(missingItems / stackSize)
        
        if debugEnabled then
            bab_print(string.format("Auto-buy: Free slots: %d, Stacks needed: %d", freeSlots, stacksToBuy), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
        end
        
        if freeSlots < stacksToBuy then
             if debugEnabled then
                bab_print(string.format("Auto-buy: Not enough free slots (%d) to buy all %d missing items (%d stacks needed). Reducing amount.", freeSlots, missingItems, stacksToBuy), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end
            stacksToBuy = freeSlots
        end

        if price and price > 0 then
            local money = GetMoney()
            local totalCost = stacksToBuy * price
            
            if debugEnabled then
                bab_print(string.format("Auto-buy: Price check - Have: %d copper, Need: %d copper for %d stacks (price=%d per stack)", money, totalCost, stacksToBuy, price), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
            end
            
            if money < totalCost then
                local stacksCanAfford = math.floor(money / price)
                if debugEnabled then
                    bab_print(string.format("Auto-buy: Not enough money for %d stacks. Can afford %d stacks.", stacksToBuy, stacksCanAfford), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                end
                bab_print("Nicht genug Gold, um den Munitionsbeutel aufzufÃ¼llen. Es wird eine geringere Menge gekauft.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                stacksToBuy = stacksCanAfford
            end
        end

        if stacksToBuy > 0 then
            -- Buy in chunks of stackSize so we purchase full stacks, not single bullets.
            local itemsToBuy = math.min(missingItems, stacksToBuy * stackSize)

            if itemsToBuy > 0 then
                if debugEnabled then
                    bab_print(string.format("Auto-buy: Attempting to buy a total of %d items (%s, ItemID %d), capped by available slots/money.", itemsToBuy, itemName or "bullets", bulletIDToBuy), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                end

                local purchasedCount = 0
                while purchasedCount < itemsToBuy do
                    local amountInThisGo = math.min(stackSize, itemsToBuy - purchasedCount)
                    if amountInThisGo > 0 then
                        if debugEnabled then
                            bab_print(string.format("Auto-buy: Buying chunk of %d items.", amountInThisGo), BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
                        end
                        BuyMerchantItem(merchantItemIndex, amountInThisGo)
                        purchasedCount = purchasedCount + amountInThisGo
                    else
                        break
                    end
                end
            end
        end
    elseif BeastAndBow_Settings.debug then
        bab_print("Auto-buy: Ammo pouch is already full with the correct bullets or occupied by other items.", BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end
end

function BeastAndBow.AutoBuyPetFood_EventHandler()
    if not (BeastAndBow.IsTBC and BeastAndBow.IsTBC()) then
        return
    end

    if not BeastAndBow_Settings or not BeastAndBow_Settings.autoBuyPetFood or not BeastAndBow_Settings.autoBuyPetFoodType then
        return -- Feature is disabled or not configured
    end


    local foodType = BeastAndBow_Settings.autoBuyPetFoodType

    if BeastAndBow_Settings.debug then
        bab_print("MERCHANT_SHOW event fired. Auto-buy for pet food type: " .. foodType, BeastAndBow.Debug.LEVELS.INFO, "AutoBuy")
    end

    -- TODO: When item IDs are provided, implement the following:
    -- 1. Create a map of food types ("Fleisch", "Fisch", etc.) to lists of item IDs.
    -- 2. Get the list of IDs for the selected 'foodType'.
    -- 3. Scan player's bags to see how much of that food type they already have.
    -- 4. If below a certain threshold (e.g., less than 2 stacks), scan the merchant.
    -- 5. Scan merchant items to see if any of the item IDs for the selected food type are available.
    -- 6. Buy one or two stacks if available.
end

function BeastAndBow.FindNearestVendor(vendorType, vendorData)
    bab_print(string.format(BeastAndBow.L.FIND_NEAREST_VENDOR_CALLED, vendorType), BeastAndBow.Debug.LEVELS.DEBUG, "Vendor")
    
    local fTag, fLocalized = UnitFactionGroup("player")
    local playerFaction = fTag or fLocalized or "Neutral"
    if not playerFaction then
        bab_print(BeastAndBow.L.COULD_NOT_DETERMINE_PLAYER_FACTION)
        return
    end

    local p_zone_x, p_zone_y, p_mapID_raw = HBD:GetPlayerZonePosition()
    if not p_mapID_raw then
        bab_print("BeastAndBow: Could not get player zone position from HereBeDragons.", BeastAndBow.Debug.LEVELS.ERROR, "Vendor")
        return
    end
    
    -- For comparing zones, we need a guaranteed uiMapID.
    local p_uiMapID_for_comparison = BeastAndBow.MapIDToHBDUI[p_mapID_raw] or p_mapID_raw

    -- For getting world coordinates, we MUST use the raw map ID that HBD returned.
    local p_wx, p_wy, p_instance = HBD:GetWorldCoordinatesFromZone(p_zone_x, p_zone_y, p_mapID_raw)
    if not p_wx then
        local fallbackMapID = (p_uiMapID_for_comparison == 1412) and 1456 or nil -- Fallback for Mulgore -> TB
        if fallbackMapID then 
            p_wx, p_wy, p_instance = HBD:GetWorldCoordinatesFromZone(p_zone_x, p_zone_y, fallbackMapID) 
        end
    end
    if not p_wx then
        bab_print("BeastAndBow: Could not determine player world coordinates. HBD may not support the current zone's map ID for this function: " .. tostring(p_mapID_raw), BeastAndBow.Debug.LEVELS.ERROR, "Vendor")
        return
    end
    -- Normalize nil instance to 0 (continent/global) to avoid mismatches where some HBD builds return nil
    p_instance = p_instance or 0

    if BeastAndBow_Settings and BeastAndBow_Settings.debug then
        bab_print(string.format("[VendorDiag] player: rawMapID=%s, uiMapID_for_comp=%s, zoneX=%.4f, zoneY=%.4f, worldX=%s, worldY=%s, instance=%s", tostring(p_mapID_raw), tostring(p_uiMapID_for_comparison), tostring(p_zone_x), tostring(p_zone_y), tostring(p_wx or "nil"), tostring(p_wy or "nil"), tostring(p_instance)), BeastAndBow.Debug.LEVELS.DEBUG, "VendorDiag")
        bab_print(string.format("[VendorDiag] HBD functions: GetWorldCoordinatesFromUIMapID=%s, GetWorldCoordinatesFromZone=%s, GetWorldVector=%s, GetPlayerZonePosition=%s", tostring(type(HBD.GetWorldCoordinatesFromUIMapID) == "function"), tostring(type(HBD.GetWorldCoordinatesFromZone) == "function"), tostring(type(HBD.GetWorldVector) == "function"), tostring(type(HBD.GetPlayerZonePosition) == "function")), BeastAndBow.Debug.LEVELS.DEBUG, "VendorDiag")
    end

    local nearestVendor = nil
    local minDistanceSq = -1

    local function VendorMatchesType(v, allowFallback)
        if not v then return false, 0 end
        local isArrowOnly = v.onlyArrow == true
        local isBulletOnly = v.onlyBullet == true
        local isGeneral = (not isArrowOnly) and (not isBulletOnly)
        if vendorType == "arrow" then
            if isArrowOnly or isGeneral then return true, (isGeneral and 2 or 1)
            elseif allowFallback and isBulletOnly then return true, 0
            else return false, 0 end
        elseif vendorType == "bullet" then
            if isBulletOnly or isGeneral then return true, (isGeneral and 2 or 1)
            elseif allowFallback and isArrowOnly then return true, 0
            else return false, 0 end
        end
        return true, 1
    end

    local function GetLocalVendorMapID(vendor)
        if not vendor or not vendor.mapIDs then return nil end
        for _, vMapID in ipairs(vendor.mapIDs) do
            local v_uiMapID = BeastAndBow.MapIDToHBDUI[vMapID] or vMapID
            if v_uiMapID == p_uiMapID_for_comparison then
                return vMapID
            end
        end
        return nil
    end

    local function find(allowFallback)
        -- Local Zone Search ONLY
        bab_print("Suche HÃ¤ndler nur in der aktuellen Zone...", BeastAndBow.Debug.LEVELS.DEBUG, "Vendor")
        for _, vendor in ipairs(vendorData) do
            local typeOk, capScore = VendorMatchesType(vendor, allowFallback)
            if typeOk and (vendor.faction == "Neutral" or vendor.faction == playerFaction) and vendor.coords and vendor.mapIDs then
                local vendor_map_id_for_coords = GetLocalVendorMapID(vendor)
                local is_local = vendor_map_id_for_coords ~= nil

                if is_local then
                    for _, coord in ipairs(vendor.coords) do
                        local foundValid = false
                        local triedCandidates = {}
                        -- Build candidate list: prefer the vendor_map_id_for_coords (the mapID that matched player's uiMapID)
                        local candidateList = {}
                        if vendor_map_id_for_coords then
                            table.insert(candidateList, vendor_map_id_for_coords)
                            for _, cm in ipairs(vendor.mapIDs) do
                                if cm ~= vendor_map_id_for_coords then table.insert(candidateList, cm) end
                            end
                        else
                            candidateList = vendor.mapIDs
                        end
                        -- Try each candidate mapID from the vendor's candidateList until one yields valid world coords
                        for _, candidateMapID in ipairs(candidateList) do
                            local v_wx, v_wy, v_inst = nil, nil, nil
                            local candidate_uiMapID = BeastAndBow.MapIDToHBDUI[candidateMapID] or candidateMapID
                            table.insert(triedCandidates, candidateMapID)

                            -- Prefer UIMapID-based conversion if available
                            if HBD.GetWorldCoordinatesFromUIMapID then
                                pcall(function()
                                    v_wx, v_wy, v_inst = HBD:GetWorldCoordinatesFromUIMapID(coord.x / 100, coord.y / 100, candidate_uiMapID)
                                end)
                            end

                            -- Fallback to zone-based conversion if needed
                            if (not v_wx or v_wx == -1) and HBD.GetWorldCoordinatesFromZone then
                                pcall(function()
                                    v_wx, v_wy, v_inst = HBD:GetWorldCoordinatesFromZone(coord.x / 100, coord.y / 100, candidateMapID)
                                end)
                            end

                            v_inst = v_inst or 0
                            if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                                bab_print(string.format("[BeastAndBow Debug] Vendor %s try map %s -> uiMapID %s: v_wx=%s, v_wy=%s, v_inst=%s (player inst=%s)", vendor.npc, tostring(candidateMapID), tostring(candidate_uiMapID), tostring(v_wx or -1), tostring(v_wy or -1), tostring(v_inst or "nil"), tostring(p_instance or "nil")), BeastAndBow.Debug.LEVELS.DEBUG, "Vendor")
                            end

                            -- Accept only numeric coords, not sentinel (-1,-1), and matching instance
                            if type(v_wx) == "number" and type(v_wy) == "number" and not (v_wx == -1 and v_wy == -1) and v_inst == p_instance then
                                -- Optional round-trip verification: convert the computed world coords back
                                -- to zone percents for this candidate_uiMapID and ensure they closely
                                -- match the original vendor coord. This prevents using a coord that
                                -- actually belongs to a different map (e.g., Darkshore coords interpreted
                                -- as Ashenvale). Only enforce if HBD provides GetZoneCoordinatesFromWorld.
                                local acceptCandidate = true
                                if HBD and HBD.GetZoneCoordinatesFromWorld then
                                    local ok_rt, rz_x, rz_y = pcall(function() return HBD:GetZoneCoordinatesFromWorld(v_wx, v_wy, candidate_uiMapID) end)
                                    if ok_rt and rz_x and rz_y then
                                        local rx, ry = rz_x * 100, rz_y * 100
                                        local nx, ny = coord.x, coord.y
                                        -- tolerance in percentage points (2% -> 2.0)
                                        local tol = (BeastAndBow_Settings and type(BeastAndBow_Settings.roundTripTolerance) == "number") and BeastAndBow_Settings.roundTripTolerance or 2.0
                                        if math.abs(rx - nx) > tol or math.abs(ry - ny) > tol then
                                            acceptCandidate = false
                                            if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                                                bab_print(string.format("[VendorDiag] Candidate map %s round-trip mismatch: vendor(%.1f,%.1f) -> roundtrip(%.1f,%.1f)", tostring(candidateMapID), nx, ny, rx, ry), BeastAndBow.Debug.LEVELS.DEBUG, "Vendor")
                                            end
                                        end
                                    end
                                end

                                if acceptCandidate then
                                    local _, dist = HBD:GetWorldVector(p_instance, p_wx, p_wy, v_wx, v_wy)
                                    if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                                        bab_print(string.format("[BeastAndBow Debug] Vendor %s (map %s): dist=%s", vendor.npc, tostring(candidateMapID), dist or "nil"), BeastAndBow.Debug.LEVELS.DEBUG, "Vendor")
                                    end
                                    if dist and (minDistanceSq == -1 or dist < minDistanceSq) then
                                        minDistanceSq = dist
                                        nearest = nil
                                        nearestVendor = { name = vendor.npc, x = coord.x, y = coord.y, uiMapID = candidate_uiMapID, oldMapID = candidateMapID, capabilityScore = capScore, worldX = v_wx, worldY = v_wy, worldInstance = v_inst }
                                    end
                                    foundValid = true
                                    break
                                end
                            end
                        end
                        if BeastAndBow_Settings and BeastAndBow_Settings.debug and not foundValid then
                            bab_print(string.format("[BeastAndBow Debug] Vendor %s: tried candidate mapIDs=%s but no valid world coords found.", vendor.npc, table.concat(triedCandidates, ",")), BeastAndBow.Debug.LEVELS.DEBUG, "Vendor")
                        end
                    end
                end
            end
        end
    end

    -- Run search
    find(false)
    if not nearestVendor and (vendorType == "arrow" or vendorType == "bullet") then
        minDistanceSq = -1
        find(true)
    end

    -- Last-resort fallback: if no vendor found by world coordinates (HBD failed to convert),
    -- try a map-coordinate based search using the uiMapID and normalized coords.
    if not nearestVendor then
        if BeastAndBow_Settings and BeastAndBow_Settings.debug then
            bab_print("No vendor found with world-coords; falling back to map-coordinate search.", BeastAndBow.Debug.LEVELS.WARN, "Vendor")
        end
        local px, py = nil, nil
        -- Try to get player position on the uiMapID used for comparison (C_Map may return a position object or table)
        if C_Map and C_Map.GetPlayerMapPosition and p_uiMapID_for_comparison then
            local ok, pos = pcall(C_Map.GetPlayerMapPosition, p_uiMapID_for_comparison, "player")
            if ok and pos then
                if type(pos.GetXY) == "function" then
                    local ok2, x, y = pcall(function() return pos:GetXY() end)
                    if ok2 and x and y then px, py = x * 100, y * 100 end
                elseif pos.x and pos.y then
                    px, py = pos.x * 100, pos.y * 100
                end
            end
        end
        -- Fallback to legacy API
        if (not px or not py) and GetPlayerMapPosition then
            local ok, ux, uy = pcall(GetPlayerMapPosition, "player")
            if ok and ux and uy then px, py = ux * 100, uy * 100 end
        end
        -- Final fallback: convert player's world coords to zone percents for the comparison uiMapID using HBD
        if (not px or not py) and p_wx and p_wy and HBD and HBD.GetZoneCoordinatesFromWorld and p_uiMapID_for_comparison then
            local ok, zx, zy = pcall(function() return HBD:GetZoneCoordinatesFromWorld(p_wx, p_wy, p_uiMapID_for_comparison) end)
            if ok and zx and zy then px, py = zx * 100, zy * 100 end
        end

        -- Enhanced fallback: compute player's zone-percent position per candidate uiMapID
        -- and compare vendor percent coords across all vendor candidate mapIDs. This helps
        -- when HBD cannot compute world coords but zone-percent conversion is available
        -- for some candidate uiMapIDs.
        local playerPercentCache = {}
        local function getPlayerPercentForUi(uiMapID)
            if not uiMapID then return nil end
            if playerPercentCache[uiMapID] then return playerPercentCache[uiMapID].x, playerPercentCache[uiMapID].y end

            -- Try C_Map.GetPlayerMapPosition first (modern API)
            if C_Map and C_Map.GetPlayerMapPosition then
                local ok, pos = pcall(C_Map.GetPlayerMapPosition, uiMapID, "player")
                if ok and pos then
                    if type(pos.GetXY) == "function" then
                        local ok2, x, y = pcall(function() return pos:GetXY() end)
                        if ok2 and x and y then
                            playerPercentCache[uiMapID] = { x = x * 100, y = y * 100 }
                            return playerPercentCache[uiMapID].x, playerPercentCache[uiMapID].y
                        end
                    elseif pos.x and pos.y then
                        playerPercentCache[uiMapID] = { x = pos.x * 100, y = pos.y * 100 }
                        return playerPercentCache[uiMapID].x, playerPercentCache[uiMapID].y
                    end
                end
            end

            -- Next try HBD:GetZoneCoordinatesFromWorld using the player's world coords
            if p_wx and p_wy and HBD and HBD.GetZoneCoordinatesFromWorld then
                local ok, zx, zy = pcall(function() return HBD:GetZoneCoordinatesFromWorld(p_wx, p_wy, uiMapID) end)
                if ok and zx and zy then
                    playerPercentCache[uiMapID] = { x = zx * 100, y = zy * 100 }
                    return playerPercentCache[uiMapID].x, playerPercentCache[uiMapID].y
                end
            end

            return nil
        end

        local foundAnyPlayerPercent = false
        if px and py then
            playerPercentCache[p_uiMapID_for_comparison] = { x = px, y = py }
            foundAnyPlayerPercent = true
        end

        local bestDist, bestVendor, bestVendorMapID, bestVendorUi = nil, nil, nil, nil
        for _, vendor in ipairs(vendorData) do
            local typeOk, capScore = VendorMatchesType(vendor, true)
            if typeOk and (vendor.faction == "Neutral" or vendor.faction == playerFaction) and vendor.coords and vendor.mapIDs then
                local localMapID = GetLocalVendorMapID(vendor)
                if localMapID then
                    local candidateUi = BeastAndBow.MapIDToHBDUI[localMapID] or localMapID
                    local ppx, ppy = getPlayerPercentForUi(candidateUi)
                    if ppx and ppy then
                        foundAnyPlayerPercent = true
                        local cx = vendor.coords[1] and vendor.coords[1].x
                        local cy = vendor.coords[1] and vendor.coords[1].y
                        if cx and cy then
                            local dx, dy = (cx - ppx), (cy - ppy)
                            local d = math.sqrt(dx*dx + dy*dy)
                            if not bestDist or d < bestDist then
                                bestDist = d
                                bestVendor = vendor
                                bestVendorMapID = localMapID
                                bestVendorUi = candidateUi
                            end
                        end
                    end
                end
            end
        end

        if bestVendor then
            nearestVendor = { name = bestVendor.npc, x = bestVendor.coords[1].x, y = bestVendor.coords[1].y, uiMapID = bestVendorUi, oldMapID = bestVendorMapID, capabilityScore = 1 }
            if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                bab_print(string.format("[VendorDiag] Fallback selected vendor %s at %.1f,%.1f (map %s)", tostring(nearestVendor.name), nearestVendor.x or 0, nearestVendor.y or 0, tostring(nearestVendor.oldMapID)), BeastAndBow.Debug.LEVELS.INFO, "VendorDiag")
            end
        else
            if not foundAnyPlayerPercent then
                if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                    bab_print("Fallback map-coordinate search skipped: could not determine player map percent position for any candidate uiMapID.", BeastAndBow.Debug.LEVELS.WARN, "VendorDiag")
                end
            else
                if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                    bab_print("Fallback map-coordinate search ran but found no matching vendors across candidate uiMapIDs.", BeastAndBow.Debug.LEVELS.WARN, "VendorDiag")
                end
            end
        end
    end

    -- Process result
    if nearestVendor then
        -- When creating the waypoint, we must pass BOTH the old map ID (for HBD coord conversion)
        -- and the uiMapID (for HBD-Pins).
        local mapName = BeastAndBow.EnglishMapNames[nearestVendor.oldMapID] or "Unknown Zone"
        local normX = (nearestVendor.x > 1) and (nearestVendor.x / 100) or nearestVendor.x
        local normY = (nearestVendor.y > 1) and (nearestVendor.y / 100) or nearestVendor.y
        BeastAndBow.SetNavigationTarget(nearestVendor.oldMapID, nearestVendor.uiMapID, normX, normY, nearestVendor.name)
        print(string.format("[Beast & Bow] " .. (BeastAndBow.L.WAYPOINT_CREATED or "Waypoint created for %s in %s."), nearestVendor.name, mapName))
        return true
    else
        -- If no vendor is found, this will now correctly return false,
        -- which will trigger the "not found" message in the calling functions.
        return false
    end
end


    function BeastAndBow.FindNearestArrowVendor()
        if not BeastAndBow.FindNearestVendor("arrow", BeastAndBow.ArrowVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.ARROWS))
        end
    end
    function BeastAndBow.FindNearestBulletVendor()
        if not BeastAndBow.FindNearestVendor("bullet", BeastAndBow.ArrowVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.BULLETS))
        end
    end
    function BeastAndBow.FindNearestBreadVendor()
        if not BeastAndBow.FindNearestVendor("bread", BeastAndBow.BreadVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.BREAD))
        end
    end
    function BeastAndBow.FindNearestFishVendor()
        if not BeastAndBow.FindNearestVendor("fish", BeastAndBow.FishVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.FISH))
        end
    end
    function BeastAndBow.FindNearestCheeseVendor()
        if not BeastAndBow.FindNearestVendor("cheese", BeastAndBow.CheeseVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.CHEESE))
        end
    end
    function BeastAndBow.FindNearestFruitVendor()
        if not BeastAndBow.FindNearestVendor("fruit", BeastAndBow.FruitVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.FRUITS))
        end
    end
    function BeastAndBow.FindNearestMushroomVendor()
        if not BeastAndBow.FindNearestVendor("mushroom", BeastAndBow.MushroomVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.MUSHROOMS))
        end
    end
    function BeastAndBow.FindNearestMeatVendor()
        if not BeastAndBow.FindNearestVendor("meat", BeastAndBow.MeatVendors) then
            print("[Beast & Bow] " .. string.format(BeastAndBow.L.NO_VENDOR_FOUND, BeastAndBow.L.MEAT))
        end
    end
    function BeastAndBow.FindNearestStableMaster()
        if not BeastAndBow.FindNearestVendor("stablemaster", BeastAndBow.StableMasters) then
            print("[Beast & Bow] " .. (BeastAndBow.L.NO_STABLE_MASTER_FOUND or "No Stable Master found."))
        end
    end

    -- Placeholder for Trainer data
    BeastAndBow.TrainerVendors = BeastAndBow.TrainerVendors or {}

    function BeastAndBow.FindNearestTrainer()
        if not BeastAndBow.FindNearestVendor("trainer", BeastAndBow.TrainerVendors) then
            print("[Beast & Bow] " .. (BeastAndBow.L.NO_TRAINER_FOUND or "No Hunter Trainer found."))
        end
    end

    function BeastAndBow.FindNearestPetTrainer()
        if not BeastAndBow.FindNearestVendor("petTrainer", BeastAndBow.PetTrainers) then
            print("[Beast & Bow] " .. (BeastAndBow.L.NO_PET_TRAINER_FOUND or "No Pet Trainer found."))
        end
    end

    function BeastAndBow.OpenPetTrainerOptions()
        BeastAndBow.FindNearestPetTrainer()
    end

    -- Map debug helper: prints player/map info and vendor candidate details for Arrow vendors
    function BeastAndBow.MapDebug()
        bab_print("MapDebug starting...", BeastAndBow.Debug.LEVELS.INFO, "MapDebug")

        -- get ui map and player map position via C_Map
        local ok, uiMapID = pcall(function() return C_Map.GetBestMapForUnit("player") end)
        local px, py
        if ok and uiMapID then
            local ok2, pos = pcall(function() return C_Map.GetPlayerMapPosition(uiMapID, "player") end)
            if ok2 and pos then
                if type(pos.GetXY) == "function" then
                    px, py = pos:GetXY()
                else
                    px, py = pos.x, pos.y
                end
                if px and py and px <= 1 and py <= 1 then px = px * 100; py = py * 100 end
            end
        end

        -- unit/world position as extra info
        local ux, uy, uz = UnitPosition("player")

        bab_print(string.format("uiMapID=%s playerMapXY=%s,%s UnitPosition=%s,%s,%s", tostring(uiMapID), tostring(px), tostring(py), tostring(ux), tostring(uy), tostring(uz)), BeastAndBow.Debug.LEVELS.DEBUG, "MapDebug")

        -- simple AreMapsRelated helper (uses C_Map.GetMapInfo if available)
        local function AreMapsRelated(mapA, mapB)
            if not C_Map or not C_Map.GetMapInfo then return false end
            if mapA == mapB then return true end
            local seen = {}
            local function addAncestors(mapID)
                while mapID and mapID ~= 0 and not seen[mapID] do
                    seen[mapID] = true
                    local ok, info = pcall(C_Map.GetMapInfo, mapID)
                    if not ok or not info then break end
                    mapID = info.parentMapID
                end
            end
            addAncestors(mapA)
            local mapID = mapB
            while mapID and mapID ~= 0 do
                if seen[mapID] then return true end
                local ok, info = pcall(C_Map.GetMapInfo, mapID)
                if not ok or not info then break end
                mapID = info.parentMapID
            end
            return false
        end

        -- Dump Arrow vendors (the one you're likely testing)
        if not BeastAndBow.ArrowVendors then
            bab_print("No ArrowVendors defined.", BeastAndBow.Debug.LEVELS.ERROR, "MapDebug")
            return
        end

        for _, vendor in ipairs(BeastAndBow.ArrowVendors) do
            local vendorName = vendor.npc or "<unknown>"
            local mapIDs = vendor.mapIDs and table.concat(vendor.mapIDs, ",") or "<none>"
            local faction = vendor.faction or "<none>"
            bab_print(string.format("Vendor '%s' maps=%s faction=%s", vendorName, mapIDs, tostring(faction)), BeastAndBow.Debug.LEVELS.DEBUG, "MapDebug")

            if vendor.mapIDs and uiMapID then
                for _, mapID in ipairs(vendor.mapIDs) do
                    local related = AreMapsRelated(mapID, uiMapID) or AreMapsRelated(uiMapID, mapID)
                    bab_print(string.format("  map %d relatedToCurrent=%s", mapID, tostring(related)), BeastAndBow.Debug.LEVELS.DEBUG, "MapDebug")
                end
            end

            if vendor.coords then
                for _, coord in ipairs(vendor.coords) do
                    local vx, vy = coord.x, coord.y
                    local reason = ""
                    if not uiMapID then reason = "(no uiMapID)" end
                    local dx, dy, dist
                    if px and py and vx and vy then
                        dx = vx - px
                        dy = vy - py
                        dist = math.sqrt(dx*dx + dy*dy)
                    end
                    bab_print(string.format("  coord %.1f,%.1f %s dx=%.2f dy=%.2f dist=%s", vx, vy, reason, (dx or 0), (dy or 0), dist and string.format("%.2f", dist) or "nil"), BeastAndBow.Debug.LEVELS.DEBUG, "MapDebug")
                end
            else
                bab_print("  (no coords provided)", BeastAndBow.Debug.LEVELS.DEBUG, "MapDebug")
            end
        end

        bab_print("MapDebug finished.", BeastAndBow.Debug.LEVELS.INFO, "MapDebug")
    end

    function BeastAndBow.SavePosition()
        if not frame then return end
        local point, relTo, relativePoint, x, y = frame:GetPoint()
        if not point then return end
        local relName = nil
        if relTo and type(relTo) == "table" and relTo.GetName then
            relName = relTo:GetName()
        elseif type(relTo) == "string" then
            relName = relTo
        end
        BeastAndBow_Settings.position = {
            point = point,
            relativeTo = relName,
            relativePoint = relativePoint,
            x = x,
            y = y
        }
    end

    SLASH_BEASTANDBOW1 = "/beastandbow"
    SLASH_BEASTANDBOW2 = "/bab"
    SlashCmdList["BEASTANDBOW"] = function(msg)
        msg = string.lower(msg or "")
        if msg == "mapdebug" or msg == "mapid" then
            BeastAndBow.MapDebug()
            return
        end
        if msg == "vendors" then
            local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or nil
            if not uiMapID and GetCurrentMapAreaID then uiMapID = GetCurrentMapAreaID() end
            local name = BeastAndBow.MapNames and BeastAndBow.MapNames[uiMapID] or "?"
            local function isSame(a,b)
                if a == b then return true end
                local eq = {
                    [1519] = 1453, [1453] = 1519,
                    [1637] = 1454, [1454] = 1637,
                    [1537] = 1455, [1455] = 1537,
                    [1497] = 1458, [1458] = 1497,
                    [1638] = 1456, [1456] = 1638,
                    [1657] = 1438, [1438] = 1657,
                }
                return eq[a] == b
            end
            local lists = {
                BeastAndBow.ArrowVendors, BeastAndBow.BreadVendors, BeastAndBow.FishVendors,
                BeastAndBow.CheeseVendors, BeastAndBow.FruitVendors, BeastAndBow.MeatVendors,
                BeastAndBow.MushroomVendors
            }
            local count = 0
            for _, list in ipairs(lists) do
                if type(list) == "table" then
                    for _, v in ipairs(list) do
                        for _, mid in ipairs(v.mapIDs or {}) do
                            if isSame(mid, uiMapID) then
                                count = count + 1
                                bab_print(string.format("Vendor: %s [%s] @ %.1f,%.1f", v.npc or "?", (v.faction or ""), (v.coords and v.coords[1] and v.coords[1].x) or 0, (v.coords and v.coords[1] and v.coords[1].y) or 0), BeastAndBow.Debug.LEVELS.INFO, "Vendors")
                                break
                            end
                        end
                    end
                end
            end
            bab_print(string.format("%d vendors on uiMapID=%s (%s)", count, tostring(uiMapID), tostring(name)), BeastAndBow.Debug.LEVELS.INFO, "Vendors")
            return
        end
        if msg == "nearest" then
            local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or nil
            if not uiMapID and GetCurrentMapAreaID then uiMapID = GetCurrentMapAreaID() end
            local name = BeastAndBow.MapNames and BeastAndBow.MapNames[uiMapID] or "?"
            local px, py = nil, nil
            if C_Map and C_Map.GetPlayerMapPosition and uiMapID then
                local pos = C_Map.GetPlayerMapPosition(uiMapID, "player")
                if pos and pos.x and pos.y then px, py = pos.x*100, pos.y*100 end
            end
            if (not px or not py) and GetPlayerMapPosition then
                local _, x, y = GetPlayerMapPosition("player")
                if x and y then px, py = x*100, y*100 end
            end
            if not px or not py then px, py = 50.0, 50.0 end
            local function isSame(a,b)
                if a == b then return true end
                local eq = {
                    [1519] = 1453, [1453] = 1519,
                    [1637] = 1454, [1454] = 1637,
                    [1537] = 1455, [1455] = 1537,
                    [1497] = 1458, [1458] = 1497,
                    [1638] = 1456, [1456] = 1638,
                    [1657] = 1438, [1438] = 1657,
                }
                return eq[a] == b
            end
            local function dist(ax, ay, bx, by)
                local dx, dy = (ax-bx), (ay-by)
                return math.sqrt(dx*dx + dy*dy)
            end
            local lists = {
                BeastAndBow.ArrowVendors, BeastAndBow.BreadVendors, BeastAndBow.FishVendors,
                BeastAndBow.CheeseVendors, BeastAndBow.FruitVendors, BeastAndBow.MeatVendors,
                BeastAndBow.MushroomVendors
            }
            local nearest, ndist
            local considered, filtered = 0, 0
            for _, list in ipairs(lists) do
                for _, v in ipairs(list or {}) do
                    local onMap = false
                    for _, mid in ipairs(v.mapIDs or {}) do
                        if isSame(mid, uiMapID) then onMap = true; break end
                    end
                    if onMap then
                        considered = considered + 1
                        local cx = v.coords and v.coords[1] and v.coords[1].x
                        local cy = v.coords and v.coords[1] and v.coords[1].y
                        if not cx or not cy then
                            filtered = filtered + 1
                        else
                            local d = dist(px, py, cx, cy)
                            if not ndist or d < ndist then
                                ndist, nearest = d, v
                            end
                        end
                    end
                end
            end
            if nearest then
                bab_print(string.format("Nearest vendor on %s: %s [%s] at %.1f,%.1f (dist=%.2f)", tostring(name), tostring(nearest.npc), tostring(nearest.faction or ""), nearest.coords[1].x, nearest.coords[1].y, ndist or 0), BeastAndBow.Debug.LEVELS.INFO, "Nearest")
            else
                bab_print(string.format("No results on %s. considered=%d filtered(no coords)=%d", tostring(name), considered, filtered), BeastAndBow.Debug.LEVELS.WARN, "Nearest")
            end
            return
        end
        if msg == "diag" then
            BeastAndBow.MapDebug()
            return
        end
        if msg == "report" then
            BeastAndBow.ToggleReportFrame()
            return
        end
        if msg == "settings" then
            if BeastAndBow.settingsCategory and BeastAndBow.settingsCategory.GetID then
                Settings.OpenToCategory(BeastAndBow.settingsCategory:GetID())
            end
            return
        end
        if msg == "logging" then
            BeastAndBow_Settings.loggingEnabled = not BeastAndBow_Settings.loggingEnabled
            print(BeastAndBow.L.ADDON_NAME .. ": " .. (BeastAndBow_Settings.loggingEnabled and BeastAndBow.L.LOGGING_ENABLED or BeastAndBow.L.LOGGING_DISABLED) .. ".")
            return
        end
        if msg == "debug" then
            BeastAndBow_Settings.debug = not BeastAndBow_Settings.debug
            print("BeastAndBow: debug " .. (BeastAndBow_Settings.debug and "ENABLED" or "DISABLED"))
            return
        end
        if msg == "warning" then
            BeastAndBow_Settings.warningSystemEnabled = not BeastAndBow_Settings.warningSystemEnabled
            print(BeastAndBow.L.ADDON_NAME .. ": Warning system " .. (BeastAndBow_Settings.warningSystemEnabled and "ENABLED" or "DISABLED") .. ".")
            return
        end
        if msg == "status" then
            print(BeastAndBow.L.ADDON_NAME .. ": Settings: warningSystemEnabled=" .. tostring(BeastAndBow_Settings.warningSystemEnabled) .. ", loggingEnabled=" .. tostring(BeastAndBow_Settings.loggingEnabled))
            return
        end
        if msg == "show" then
            BeastAndBow_Settings.frameVisible = true
            if frame then frame:Show() end
            return
        end
        if msg == "hide" then
            BeastAndBow_Settings.frameVisible = false
            if frame then frame:Hide() end
            return
        end
        print("BeastAndBow: commands -> /bab mapid, vendors, nearest, diag, report, settings, logging, debug, warning, status, show, hide")
    end

-- Process any frames that were loaded before the addon was ready
if _BeastAndBow_pendingOnLoad then
    for _, frame in ipairs(_BeastAndBow_pendingOnLoad) do
        if frame and type(frame.IsVisible) == "function" then
            BeastAndBow.OnLoad(frame)
        end
    end

    -- Quick command to open the Beast & Bow Macros helper
    SLASH_BABMACROS1 = "/babmacros"
    SLASH_BABMACROS2 = "/babm"
    SlashCmdList["BABMACROS"] = function(msg)
        if BeastAndBow and BeastAndBow.OpenMacros then
            BeastAndBow.OpenMacros()
        else
            print("Beast & Bow: Makrofenster nicht verfÃ¼gbar.")
        end
    end
    _BeastAndBow_pendingOnLoad = nil -- Clear the queue
end

-- Global wrapper function for XML callbacks
function BeastAndBow_OnLoad(frame)
    BeastAndBow.OnLoad(frame)
end

-- ============================================================================
-- ABILITY UI FUNCTIONS
-- ============================================================================

-- Helper to build a fast lookup map from the ability icons
local function BuildAbilityIconMap()
    local map = {}
    if BAB and BAB.AbilityIcons then
        for _, data in ipairs(BAB.AbilityIcons) do
            map[data.name] = data.path
            print("BAB: Icon Map Entry - " .. tostring(data.name) .. " = " .. tostring(data.path))
        end
    else
        print("BAB: WARNING - BAB.AbilityIcons is nil or empty!")
    end
    return map
end

-- Note: GetUIElement is now aliased to GetUI at the top of the file

local function ClearChildrenElements(parent)
    if not parent or not parent.GetChildren then return end
    local children = { parent:GetChildren() }
    for _, c in ipairs(children) do c:Hide(); c:SetParent(nil) end
end

-- Build abilities index from BAB.AbilitiesByLevel if present
local function BuildAbilitiesIndex()
    local map = {}
    -- Prefer explicit AbilitiesByLevel data if available
    if BAB.AbilitiesByLevel and next(BAB.AbilitiesByLevel) then
        for lvl, list in pairs(BAB.AbilitiesByLevel) do
            for _, ab in ipairs(list or {}) do
                local id = ab.id or ab.name
                if not map[id] then
                    map[id] = { id = id, name = ab.name or id, ranks = {} }
                end
                local rank = ab.rank or 1
                map[id].ranks[rank] = lvl
            end
        end
        print("BAB: BuildAbilitiesIndex - used BAB.AbilitiesByLevel, abilities indexed:", tostring(#(map) or 0))
        return map
    end

    -- Fallback: derive abilities by scanning PetCategories -> species -> learns
    for _, cat in ipairs(BAB.GetPetCategories() or {}) do
        local function scanSpeciesList(list)
            for _, sp in ipairs(list or {}) do
                local lvl = sp.level
                if type(lvl) == "table" then lvl = lvl[1] end
                lvl = tonumber(lvl) or 0
                for _, l in ipairs(sp.learns or {}) do
                    local id = l.spell or l.name
                    if id then
                        map[id] = map[id] or { id = id, name = id, ranks = {} }
                        local rank = l.rank or 1
                        -- Prefer lower (earlier) level if multiple sources
                        if not map[id].ranks[rank] or (lvl > 0 and lvl < map[id].ranks[rank]) then
                            map[id].ranks[rank] = lvl
                        end
                    end
                end
            end
        end
        scanSpeciesList(cat.species)
        for _, sg in ipairs(cat.subgroups or {}) do
            scanSpeciesList(sg.species)
        end
    end
    local count = 0
    for _ in pairs(map) do count = count + 1 end
    print("BAB: BuildAbilitiesIndex - derived abilities from PetCategories:", count)
    return map
end

function BeastAndBow.OpenSkills(show)
    local f = GetUIElement("BeastAndBowSkillsFrame")
    if not f then
        print("BAB: OpenSkills - missing frame 'BeastAndBowSkillsFrame'")
        return
    end
    print("BAB: OpenSkills - frame found", tostring(f))
    if show == nil then show = true end
    if show then
        if BeastAndBow.PopulateAbilitiesList then pcall(BeastAndBow.PopulateAbilitiesList) end
        local ranks = GetUIElement("BeastAndBowSkillsListScroll") if ranks and ranks.Hide then ranks:Hide() end
        local detail = GetUIElement("BeastAndBowSkillsDetail") if detail and detail.Hide then detail:Hide() end
    else
        if f.Hide then f:Hide() end
    end
end

function BeastAndBow.PopulateAbilitiesList()
    local parent = GetUIElement("BeastAndBowSkillsLevels")
    if not parent then
        print("BAB: PopulateAbilitiesList - missing parent 'BeastAndBowSkillsLevels'")
        return
    end
    print("BAB: PopulateAbilitiesList - parent found", tostring(parent))
    
    -- Ensure ability icon map is built
    if not BAB.AbilityIconMap then
        BAB.AbilityIconMap = BuildAbilityIconMap()
    end
    
    ClearChildrenElements(parent)
    local map = BuildAbilitiesIndex()
    local list = {}
    for id, info in pairs(map) do table.insert(list, info) end
    
    -- Generate the preferred sort order with custom ability order
    local preferred = {
        -- Offensive Abilities
        "Bite",
        "Charge",
        "Claw",
        "Cower",
        "Dash",
        "Dive",
        "Furious Howl",
        "Lightning Breath",
        "Prowl",
        "Scorpid Poison",
        "Screech",
        "Shell Shield",
        "Thunderstomp",
        -- Resistances
        "Arcane Resistance",
        "Fire Resistance",
        "Frost Resistance",
        "Great Stamina",
        "Growl",
        "Natural Armor",
        "Nature Resistance",
        "Shadow Resistance",
    }
    
    local prefMap = {}
    for i, v in ipairs(preferred) do prefMap[string.lower(v)] = i end

    table.sort(list, function(a, b)
        local an = string.lower(tostring(a.name or a.id or ""))
        local bn = string.lower(tostring(b.name or b.id or ""))
        local ai = prefMap[an] or 0
        local bi = prefMap[bn] or 0
        if ai > 0 or bi > 0 then
            if ai == 0 then return false end
            if bi == 0 then return true end
            return ai < bi
        end
        return (a.name or a.id) < (b.name or b.id)
    end)
    local y = -4
    local created = 0
    local samples = {}
    for i, ab in ipairs(list) do
        local btn = CreateFrame("Button", "BeastAndBowAbilityButton_"..i, parent, "UIPanelButtonTemplate")
        btn:SetSize(140, 24)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        btn:SetText(ab.name)
        
        -- Create icon texture with proper layering and visibility
        local icon = btn:CreateTexture(nil, "OVERLAY")
        icon:SetSize(18, 18)
        icon:SetPoint("LEFT", btn, "LEFT", 6, 0)
        
        -- Use the pre-built map for fast icon lookup
        local iconPath = BAB.AbilityIconMap and BAB.AbilityIconMap[ab.name]
        if iconPath then
            icon:SetTexture(iconPath)
            print("BAB: Set icon for " .. tostring(ab.name) .. " to " .. tostring(iconPath))
        else
            -- Fallback: use a generic ability icon if no specific one found
            print("BAB: No icon found for " .. tostring(ab.name) .. " in AbilityIconMap")
            icon:SetTexture("Interface\\Icons\\Ability_Creature_Poison_02")
        end
        -- Ensure icon is fully opaque and visible
        icon:SetVertexColor(1, 1, 1, 1)

        local tex = "Interface\\AddOns\\BeastAndBow\\Textures\\buttons"
        if btn.SetNormalTexture then pcall(btn.SetNormalTexture, btn, tex) end
        if btn.SetPushedTexture then pcall(btn.SetPushedTexture, btn, tex) end
        if btn.SetHighlightTexture then pcall(btn.SetHighlightTexture, btn, tex, "ADD") end
        btn:SetScript("OnClick", function()
            BeastAndBow.PopulateRanksForAbility(ab.id)
        end)
        created = created + 1
        if #samples < 6 then table.insert(samples, tostring(ab.name)) end
        y = y - 28
    end
    print("BAB: PopulateAbilitiesList - created", created, "ability buttons; samples:", table.concat(samples, ", "))
    local leftScroll = GetUIElement("BeastAndBowSkillsLevelsScroll") if leftScroll and leftScroll.Show then leftScroll:Show() end
    local listScroll = GetUIElement("BeastAndBowSkillsListScroll") if listScroll and listScroll.Hide then listScroll:Hide() end
    local detail = GetUIElement("BeastAndBowSkillsDetail") if detail and detail.Hide then detail:Hide() end
end

function BeastAndBow.PopulateRanksForAbility(abilityId)
    local parent = GetUIElement("BeastAndBowSkillsList")
    if not parent then return end
    ClearChildrenElements(parent)
    local map = BuildAbilitiesIndex()
    local info = map[abilityId]
    if not info or not info.ranks or not next(info.ranks) then
        local msg = CreateFrame("Frame", nil, parent)
        msg:SetSize(180, 24)
        msg:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -4)
        local fs = msg:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fs:SetPoint("TOPLEFT", msg, "TOPLEFT", 0, 0)
        fs:SetText("No ranks available")
        local listScroll = GetUIElement("BeastAndBowSkillsListScroll") if listScroll and listScroll.Show then listScroll:Show() end
        return
    end
    local ranks = {}
    for r, lvl in pairs(info.ranks or {}) do table.insert(ranks, { rank = r, level = lvl }) end
    table.sort(ranks, function(a,b) return a.rank < b.rank end)
    local y = -4
    for i, rinfo in ipairs(ranks) do
        local btn = CreateFrame("Button", "BeastAndBowAbilityRankButton_"..abilityId.."_"..i, parent, "UIPanelButtonTemplate")
        btn:SetSize(180, 24)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        btn:SetText("Rank "..tostring(rinfo.rank) .. " (Lvl "..tostring(rinfo.level)..")")
        local tex = "Interface\\AddOns\\BeastAndBow\\Textures\\buttons"
        if btn.SetNormalTexture then pcall(btn.SetNormalTexture, btn, tex) end
        if btn.SetPushedTexture then pcall(btn.SetPushedTexture, btn, tex) end
        if btn.SetHighlightTexture then pcall(btn.SetHighlightTexture, btn, tex, "ADD") end
        btn:SetScript("OnClick", function()
            BeastAndBow.PopulatePetsForAbilityRank(abilityId, rinfo.rank)
        end)
        y = y - 28
    end
    print("BAB: PopulateRanksForAbility - created", #ranks, "rank buttons for ability", tostring(abilityId))
    local listScroll = GetUIElement("BeastAndBowSkillsListScroll") if listScroll and listScroll.Show then listScroll:Show() end
    
    -- Clear and hide the info panel when switching abilities
    local infoPanel = GetUIElement("BeastAndBowPetsInfo")
    if infoPanel then
        if infoPanel.Hide then infoPanel:Hide() end
        -- Clear all the detail FontStrings
        local nameFS = GetUIElement("BeastAndBowPetsDetailName")
        if nameFS and nameFS.SetText then nameFS:SetText("") end
        local lvlFS = GetUIElement("BeastAndBowPetsDetailLevel")
        if lvlFS and lvlFS.SetText then lvlFS:SetText("") end
        local spdFS = GetUIElement("BeastAndBowPetsDetailSpeed")
        if spdFS and spdFS.SetText then spdFS:SetText("") end
        local dietFS = GetUIElement("BeastAndBowPetsDetailDiet")
        if dietFS and dietFS.SetText then dietFS:SetText("") end
        local zoneFS = GetUIElement("BeastAndBowPetsDetailZone")
        if zoneFS and zoneFS.SetText then zoneFS:SetText("") end
        local abFS = GetUIElement("BeastAndBowPetsDetailAbilities")
        if abFS and abFS.SetText then abFS:SetText("") end
        local notesFS = GetUIElement("BeastAndBowPetsDetailNotes")
        if notesFS and notesFS.SetText then notesFS:SetText("") end
    end
    
    local petsScroll = GetUIElement("BeastAndBowSkills_PetsScroll")
    if petsScroll and petsScroll.Hide then petsScroll:Hide() end
end

function BeastAndBow.PopulatePetsForAbilityRank(abilityId, rank)
    local parent = GetUIElement("BeastAndBowSkills_Pets")
    if not parent then return end
    
    -- Clear all FontStrings in the PetsInfo container (shared with both views)
    local infoPanel = GetUIElement("BeastAndBowPetsInfo")
    if infoPanel then
        local nameFS = GetUIElement("BeastAndBowPetsDetailName")
        if nameFS and nameFS.SetText then nameFS:SetText("") end
        
        local lvlFS = GetUIElement("BeastAndBowPetsDetailLevel")
        if lvlFS and lvlFS.SetText then lvlFS:SetText("") end
        
        local spdFS = GetUIElement("BeastAndBowPetsDetailSpeed")
        if spdFS and spdFS.SetText then spdFS:SetText("") end
        
        local dietFS = GetUIElement("BeastAndBowPetsDetailDiet")
        if dietFS and dietFS.SetText then dietFS:SetText("") end
        
        local zoneFS = GetUIElement("BeastAndBowPetsDetailZone")
        if zoneFS and zoneFS.SetText then zoneFS:SetText("") end
        
        local abFS = GetUIElement("BeastAndBowPetsDetailAbilities")
        if abFS and abFS.SetText then abFS:SetText("") end
        
        local notesFS = GetUIElement("BeastAndBowPetsDetailNotes")
        if notesFS and notesFS.SetText then notesFS:SetText("") end
    end

    local matches = {}
    for _, cat in ipairs(BeastAndBow.GetPetCategories() or {}) do
        local subs = cat.subgroups or {}
        for _, sg in ipairs(subs) do
            local species = sg.species or {}
            for _, sp in ipairs(species) do
                local learns = sp.learns or {}
                for _, l in ipairs(learns) do
                    if l.spell == abilityId and l.rank == rank then
                        table.insert(matches, { name = sp.name, level = sp.level, zone = sp.zone })
                    end
                end
            end
        end
        for _, sp in ipairs(cat.species or {}) do
            local learns = sp.learns or {}
            for _, l in ipairs(learns) do
                if l.spell == abilityId and l.rank == rank then
                    table.insert(matches, { name = sp.name, level = sp.level, zone = sp.zone })
                end
            end
        end
    end

    ClearChildrenElements(parent)
    
    -- Clear all FontStrings from the parent (not just child frames)
    for i = parent:GetNumRegions(), 1, -1 do
        local region = select(i, parent:GetRegions())
        if region and region:GetObjectType() == "FontString" then
            region:Hide()
        end
    end
    
    local y = -8
    if #matches == 0 then
        local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        fs:SetText("No pets listed for this rank (placeholder)")
    else
        for i, m in ipairs(matches) do
            local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
            local localizedZone = BeastAndBow.LocalizeZoneText(m.zone)
            fs:SetText((m.name or "?") .. (m.level and (" - L"..(type(m.level)=="table" and tostring(m.level[1]) or tostring(m.level))) or "") .. (localizedZone and localizedZone ~= "" and (" @ "..localizedZone) or ""))
            y = y - 18
        end
    end
    
    print("BAB: PopulatePetsForAbilityRank - matched", #matches, "pets for ability", tostring(abilityId), "rank", tostring(rank))
    -- Show the info panel
    local infoPanel = GetUIElement("BeastAndBowPetsInfo")
    if infoPanel and infoPanel.Show then infoPanel:Show() end
end
