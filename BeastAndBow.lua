BeastAndBow = BeastAndBow or {}

    -- locals
    local frame, icon, countText, statusBar
    local lowAmmoWarningPlayed = false
    local lastUpdate = 0
    local updateInterval = 1 -- 1 second

    -- print helper
    local function bab_print(msg) if BeastAndBow_Settings and BeastAndBow_Settings.debug then print(BeastAndBow.L.ADDON_NAME .. ": " .. msg) end end

    local babTooltipScanner -- Our hidden frame for scanning tooltips

    -- forward declare
    local AutoDetectAmmo

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

    -- function implementations
    local function GetMaxAmmoCapacity(forDebug)
        -- Create the scanner on demand
        if not babTooltipScanner then
            babTooltipScanner = CreateFrame("GameTooltip", "BeastAndBowTooltipScanner", UIParent, "GameTooltipTemplate")
                    babTooltipScanner:SetOwner(UIParent, "ANCHOR_NONE")
                end
        if forDebug then bab_print(BeastAndBow.L.STARTING_QUIVER_SEARCH) end
        -- In Classic, quivers are equipped in bag slots to provide their haste bonus.
        -- We must check inventory slots 20-23 (bag slots 1-4).
        for slotId = 20, 23 do
            local itemLink = GetInventoryItemLink("player", slotId)
            if itemLink then
                local itemName, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = Item_GetInfo(itemLink)
                if forDebug then bab_print(string.format(BeastAndBow.L.BAG_INFO, slotId - 19, itemName or "Unknown", (itemClassID or "nil"), (itemSubClassID or "nil"), "N/A")) end

                -- Check if it's actually a quiver or ammo pouch
                if itemClassID == 1 and (itemSubClassID == 2 or itemSubClassID == 3) then
                    if forDebug then bab_print(string.format("Found quiver/pouch in bag slot %d: %s", slotId - 19, itemName)) end
                    
                    -- Scan its tooltip for capacity
                    babTooltipScanner:ClearLines()
                    babTooltipScanner:SetHyperlink(itemLink)

                    local numSlots = 0
                    for i = 2, babTooltipScanner:NumLines() do
                        local lineText = _G["BeastAndBowTooltipScannerTextLeft"..i]:GetText()
                        if lineText then
                            local slots = tonumber(string.match(lineText, "(%d+)[ -]Slot") or string.match(lineText, "(%d+)[ -]Plätze"))
                            if slots then
                                numSlots = slots
                                if forDebug then bab_print(string.format("  -> Found capacity in tooltip: %d slots", numSlots)) end
                                break
                            end
                        end
                    end
                    
                    if numSlots > 0 then
                        local capacity = numSlots * 200 -- Ammo stacks are 200
                        if forDebug then bab_print(string.format("Calculated capacity: %d", capacity)) end
                        return capacity, slotId - 19 -- Return capacity and bagID
                    else
                        if forDebug then bab_print("  -> Could not find capacity in tooltip for this item.") end
                    end
                end
            end
        end

        if forDebug then bab_print(BeastAndBow.L.NO_QUIVER_FOUND) end
        return 800, nil -- Return fallback capacity and nil for bagID
    end
    local function GetTotalAmmoCountAndLink()
        local totalCount = 0
        local firstAmmoLink = nil

    bab_print(BeastAndBow.L.DEBUG_GET_TOTAL_AMMO_RUNNING) -- DEBUG
    bab_print(string.format(BeastAndBow.L.DEBUG_EXPECTED_AMMO, tostring(BeastAndBow_Settings.expectedAmmoClassID), tostring(BeastAndBow_Settings.expectedAmmoSubClassID))) -- DEBUG

        if not BeastAndBow_Settings.expectedAmmoClassID or not BeastAndBow_Settings.expectedAmmoSubClassID then
            bab_print(BeastAndBow.L.DEBUG_ABORT_EXPECTED_AMMO_NOT_SET) -- DEBUG
            return 0, nil
        end

        -- First, check the ammo slot itself
        local ammoSlotLink = GetInventoryItemLink("player", INV_AMMO)
        if ammoSlotLink then
            bab_print(string.format(BeastAndBow.L.DEBUG_FOUND_IN_AMMO_SLOT, tostring(ammoSlotLink))) -- DEBUG
            -- Wrapped GetItemInfo
            local itemName, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = Item_GetInfo(ammoSlotLink)
            bab_print(string.format(BeastAndBow.L.DEBUG_AMMO_SLOT_CLASS, tostring(itemClassID), tostring(itemSubClassID))) -- DEBUG
            if itemClassID and itemSubClassID and itemClassID == BeastAndBow_Settings.expectedAmmoClassID and itemSubClassID == BeastAndBow_Settings.expectedAmmoSubClassID then
                local itemCount = GetInventoryItemCount("player", INV_AMMO)
                totalCount = totalCount + itemCount
                bab_print(string.format(BeastAndBow.L.DEBUG_MATCH_IN_AMMO_SLOT, itemCount, totalCount)) -- DEBUG
                if not firstAmmoLink then
                    firstAmmoLink = ammoSlotLink
                end
            end
        else
            bab_print(BeastAndBow.L.DEBUG_NO_ITEM_IN_AMMO_SLOT) -- DEBUG
        end

        -- Then, check all the bags
    bab_print(BeastAndBow.L.DEBUG_SCANNING_BAGS) -- DEBUG
        -- Aggregate items by itemID (or link when ID not available), prefer per-slot counts when available
        local perID = {}
        for bag = 0, NUM_BAGS do
            local numSlots = Container_GetNumSlots(bag)
            if numSlots and numSlots > 0 then
                bab_print(string.format(BeastAndBow.L.DEBUG_BAG_HAS_SLOTS, bag, numSlots)) -- DEBUG
                for slot = 1, numSlots do
                    local itemLink = Container_GetItemLink(bag, slot)
                    if itemLink then
                        local id = tonumber(itemLink:match("item:(%d+)") )
                        local key = id and ("id:"..id) or ("link:"..itemLink)
                        if not perID[key] then
                            local itemName, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = Item_GetInfo(itemLink)
                            perID[key] = {itemLink = itemLink, itemName = itemName, class = itemClassID, sub = itemSubClassID, perSlotSum = 0, hadPerSlot = false}
                        end

                        local cnt
                        if Container_GetItemInfo then
                            local _, c = Container_GetItemInfo(bag, slot)
                            cnt = c
                        end

                        if cnt and cnt > 0 then
                            perID[key].perSlotSum = perID[key].perSlotSum + cnt
                            perID[key].hadPerSlot = true
                        else
                            -- store the link (already stored on creation) and continue; we'll use GetItemCount later if needed
                        end
                    end
                end
            else
                bab_print(string.format(BeastAndBow.L.DEBUG_BAG_NO_SLOTS, bag)) -- DEBUG
            end
        end

        -- Now sum totals: prefer per-slot sums when present, otherwise call GetItemCount once per item
        for _, info in pairs(perID) do
            bab_print(string.format(BeastAndBow.L.DEBUG_FOUND_AGGREGATED_ITEM, tostring(info.itemName), tostring(info.class), tostring(info.sub), tostring(info.perSlotSum), tostring(info.hadPerSlot))) -- DEBUG
            if info.class and info.sub and info.class == BeastAndBow_Settings.expectedAmmoClassID and info.sub == BeastAndBow_Settings.expectedAmmoSubClassID then
                if info.hadPerSlot then
                    bab_print(string.format(BeastAndBow.L.DEBUG_MATCH_PER_SLOT, tostring(info.itemName), info.perSlotSum)) -- DEBUG
                    totalCount = totalCount + info.perSlotSum
                    if not firstAmmoLink then firstAmmoLink = info.itemLink end
                else
                    local gt = GetItemCount(info.itemLink) or 0
                    bab_print(string.format(BeastAndBow.L.DEBUG_MATCH_FALLBACK, tostring(info.itemName), gt)) -- DEBUG
                    totalCount = totalCount + gt
                    if not firstAmmoLink then firstAmmoLink = info.itemLink end
                end
            end
        end
    bab_print(string.format(BeastAndBow.L.DEBUG_FINISHED_AMMO_TOTAL, totalCount)) -- DEBUG
        return totalCount, firstAmmoLink
    end

    function BeastAndBow.FindNearestBulletVendor()
        BeastAndBow.FindNearestVendor("bullet", BeastAndBow.ArrowVendors)
    end

    local function Update()
        if not frame or not BeastAndBow_Settings then
            if frame then frame:Hide() end
            return
        end

        local maxCapacity, _ = GetMaxAmmoCapacity(false)
        
        -- 1. Zählen (Das bleibt wie es ist)
        local totalAmmo, ammoItemLink = GetTotalAmmoCountAndLink()

        -- 2. Das Bild bestimmen (NEUE LOGIK!)
        -- Standard-Bild, falls alles schiefgeht:
        local itemTexture = "Interface\\Icons\\INV_Misc_Arrow_01" 

        -- PRIORITÄT A: Was liegt optisch im Munitions-Slot? (Das ist superschnell)
        local slotTexture = GetInventoryItemTexture("player", INV_AMMO)
        if slotTexture then
            itemTexture = slotTexture
        -- PRIORITÄT B: Falls der Slot leer ist, nimm das Bild von der Munition, die wir in den Taschen gefunden haben.
        elseif ammoItemLink then
            local _, _, _, _, _, _, _, _, _, texture = Item_GetInfo(ammoItemLink)
            if texture then
                itemTexture = texture
            end
        end

        -- Ab hier ist alles wie vorher: Anzeigen und Farben
        if BeastAndBow_Settings.frameVisible then frame:Show() else frame:Hide() end
        icon:SetTexture(itemTexture)
        countText:SetText(totalAmmo)
        
        if maxCapacity > 0 and totalAmmo > 0 then
            local percentage = (totalAmmo / maxCapacity) * 100
            if percentage > 70 then
                countText:SetTextColor(0.1, 1.0, 0.1) -- green
                lowAmmoWarningPlayed = false
            elseif percentage > 35 and percentage <= 70 then
                countText:SetTextColor(1, 1, 0) -- yellow
                lowAmmoWarningPlayed = false
            else
                countText:SetTextColor(1.0, 0.1, 0.1) -- red
                if BeastAndBow_Settings.playSound and not lowAmmoWarningPlayed and totalAmmo > 0 then
                    PlaySound(1137, "SFX")
                    lowAmmoWarningPlayed = true
                end
            end
        elseif totalAmmo > 0 then
            countText:SetTextColor(0.1, 1.0, 0.1) -- green
            lowAmmoWarningPlayed = false
        end

        if totalAmmo == 0 then
            icon:SetVertexColor(0.5, 0.5, 0.5)
            if not lowAmmoWarningPlayed then
                PlaySound(815, "SFX")
                lowAmmoWarningPlayed = true
            end
        else
            icon:SetVertexColor(1, 1, 1)
        end
    end

    local function DelayedInitialUpdate()
        AutoDetectAmmo()
        Update()
    end

    AutoDetectAmmo = function()
        bab_print(BeastAndBow.L.AUTODETECT_AMMO_STARTED)
        if BeastAndBow_Settings.autoDetect then
            -- Reset first
            BeastAndBow_Settings.expectedAmmoClassID = nil
            BeastAndBow_Settings.expectedAmmoSubClassID = nil

            -- 1. Check Weapon (Priority)
            local rangedWeaponLink = GetInventoryItemLink("player", INV_RANGED) 
            if rangedWeaponLink then
                local _, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = Item_GetInfo(rangedWeaponLink)
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
                    local _, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = Item_GetInfo(ammoSlotLink)
                    if itemClassID == 6 then -- It is indeed Ammo
                         BeastAndBow_Settings.expectedAmmoClassID = itemClassID
                         BeastAndBow_Settings.expectedAmmoSubClassID = itemSubClassID
                         bab_print("No weapon found, using ammo slot item as reference.")
                    end
                end
            end

            bab_print(string.format(BeastAndBow.L.DEBUG_EXPECTED_AMMO_SET, tostring(BeastAndBow_Settings.expectedAmmoClassID), tostring(BeastAndBow_Settings.expectedAmmoSubClassID))) 
        end

        -- Update the button text and action
        local button = BeastAndBowFindArrowButton
        if not button then return end

        if BeastAndBow_Settings.expectedAmmoSubClassID == 3 then -- Bullets
            button:SetText(BeastAndBow.L.BULLETS)
            button:SetScript("OnClick", BeastAndBow.FindNearestBulletVendor)
        else -- Default to Arrows
            button:SetText(BeastAndBow.L.ARROWS)
            button:SetScript("OnClick", BeastAndBow.FindNearestArrowVendor)
        end
    end

    function BeastAndBow.OnLoad(self)
        frame = self
        icon = BeastAndBowFrameIcon
        countText = BeastAndBowFrameCount
        bab_print(BeastAndBow.L.BEASTANDBOW_ONLOAD_STARTED)

        if not BeastAndBow_Settings then BeastAndBow_Settings = {} end
        if BeastAndBow_Settings.frameVisible == nil then BeastAndBow_Settings.frameVisible = true end
        if BeastAndBow_Settings.autoDetect == nil then BeastAndBow_Settings.autoDetect = true end
        if BeastAndBow_Settings.playSound == nil then BeastAndBow_Settings.playSound = true end
        if BeastAndBow_Settings.debug == nil then BeastAndBow_Settings.debug = false end
        if BeastAndBow_Settings.curseforgeURL == nil then BeastAndBow_Settings.curseforgeURL = BeastAndBow.L.CURSE_FORGE_URL_PLACEHOLDER end

        self:RegisterEvent("PLAYER_ENTERING_WORLD")

        if BeastAndBow_Settings.position and BeastAndBow_Settings.position.point then
            frame:SetPoint(BeastAndBow_Settings.position.point, "UIParent", BeastAndBow_Settings.position.relativePoint, BeastAndBow_Settings.position.x, BeastAndBow_Settings.position.y)
        end
        if BeastAndBow_Settings.frameVisible then frame:Show() else frame:Hide() end
        frame:SetMovable(true)
    end

    function BeastAndBow.ToggleReportFrame()
        if BeastAndBowReportFrame:IsShown() then
            HideUIPanel(BeastAndBowReportFrame)
        else
            ShowUIPanel(BeastAndBowReportFrame)
        end
    end

    function BeastAndBow.GenerateReport()
        local userInput = BeastAndBowReportFrameEditBox:GetText()
        if not userInput or userInput == "" then
            userInput = "No message entered."
        end

        local report = {}
        table.insert(report, "```") -- Start of code block for easy copying
        table.insert(report, "## Beast & Bow Report")
        table.insert(report, string.format("**Addon Version:** %s", "1.0")) -- Placeholder, reading .toc is tricky

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

        BeastAndBowCopyEditBox:SetText(reportString)
        BeastAndBowCopyEditBox:HighlightText()
        
        HideUIPanel(BeastAndBowReportFrame)
        ShowUIPanel(BeastAndBowCopyFrame)
    end

    function BeastAndBow.OnEvent(self, event, ...)
        bab_print(string.format(BeastAndBow.L.EVENT_FIRED, event))
        if event == "PLAYER_ENTERING_WORLD" then
            -- Register other events now that we are in the world
            self:RegisterEvent("UNIT_INVENTORY_CHANGED")
                -- Listen for bag and equipment changes so ammo counts update in real time
            self:RegisterEvent("BAG_UPDATE")
            self:RegisterEvent("BAG_UPDATE_DELAYED")
            self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

            -- Unregister this event as it's no longer needed
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")

            -- Perform initial update
            C_Timer.After(1, DelayedInitialUpdate)

        elseif event == "UNIT_INVENTORY_CHANGED" then
            local unit, slotId = ...
            if unit == "player" then
                -- WENN sich die Waffe ändert ODER die Munition ändert -> Neu erkennen!
                if slotId == INV_RANGED or slotId == INV_AMMO then  -- <--- DAS HIER ERGÄNZEN (or slotId == INV_AMMO)
                    AutoDetectAmmo()
                end
                Update()
            end
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            -- Fires when equipment changes; refresh autodetect and display
            local unit, slot = ...
            AutoDetectAmmo()
            Update()
        elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
            -- Bags changed (items used, bought, moved) -> update counts
            Update()
        end
    end

    function BeastAndBow.FindNearestVendor(vendorType, vendorData)
        bab_print(string.format(BeastAndBow.L.FIND_NEAREST_VENDOR_CALLED, vendorType))
        local playerFaction = UnitFactionGroup("player")
        if not playerFaction then
            bab_print(BeastAndBow.L.COULD_NOT_DETERMINE_PLAYER_FACTION)
            return
        end

        -- Helper: try modern C_Map APIs first, fall back to classic map APIs when available.
        local function GetPlayerMapData()
            -- Try modern C_Map API
            if C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition then
                local ok, uiMapID = pcall(C_Map.GetBestMapForUnit, "player")
                if not ok or not uiMapID then return nil end
                local ok2, playerPos = pcall(C_Map.GetPlayerMapPosition, uiMapID, "player")
                if not ok2 or not playerPos then return nil end

                local px, py
                if type(playerPos) == "table" and type(playerPos.GetXY) == "function" then
                    px, py = playerPos:GetXY()
                elseif type(playerPos) == "table" and playerPos.x and playerPos.y then
                    px, py = playerPos.x, playerPos.y
                end
                if not px or not py then return nil end

                if px <= 1 and py <= 1 then px = px * 100; py = py * 100 end
                return uiMapID, px, py
            end

            -- Fallback: Classic / older API: GetCurrentMapAreaID + GetPlayerMapPosition
            if GetCurrentMapAreaID and GetPlayerMapPosition then
                local ok, mapID = pcall(GetCurrentMapAreaID)
                if not ok or not mapID then return nil end
                local ok2, px, py = pcall(GetPlayerMapPosition, "player")
                if not ok2 or not px or not py then return nil end
                if px <= 1 and py <= 1 then px = px * 100; py = py * 100 end
                return mapID, px, py
            end

            -- Could not determine player map/pos
            return nil
        end

        local uiMapID, playerX, playerY = GetPlayerMapData()
        if not uiMapID or not playerX or not playerY then
            bab_print(BeastAndBow.L.MAP_API_NOT_AVAILABLE)
            return
        end

        local currentMapID = uiMapID

        bab_print(string.format(BeastAndBow.L.PLAYER_POSITION, currentMapID, playerX, playerY))

        local nearestVendor = nil
        local minDistanceSq = -1

        bab_print(string.format(BeastAndBow.L.SEARCHING_FOR_NEAREST_VENDOR, vendorType))

        for _, vendor in ipairs(vendorData) do
            bab_print(string.format(BeastAndBow.L.CHECKING_VENDOR, vendor.npc))
            if vendor.mapIDs then
                for _, mapID in ipairs(vendor.mapIDs) do
                    bab_print(string.format(BeastAndBow.L.VENDOR_MAP_ID, mapID))
                end
            end

            local vendorFaction = vendor.faction
            local isAccessible = (vendorFaction == "Neutral" or vendorFaction == playerFaction or (vendorFaction == "Alliance" and playerFaction == "Alliance"))

            if isAccessible then
                -- Only compare coords for vendors that are on the same map (or a related map) as the player.
                local isOnMap = false

                if vendor.mapIDs then
                    for _, mapID in ipairs(vendor.mapIDs) do
                        -- consider vendor on map if mapIDs exactly match
                        if mapID == currentMapID then
                            isOnMap = true
                            if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                                bab_print(string.format("Vendor '%s' map %d matches current map %d", tostring(vendor.npc), mapID, currentMapID))
                            end
                            break
                        end
                    end
                else
                    -- If vendor does not specify mapIDs, assume coords (if present) are usable.
                    isOnMap = true
                end

                if isOnMap and vendor.coords then
                    for _, coord in ipairs(vendor.coords) do
                        -- Determine which player coordinates to compare against.
                        -- If vendor specifies mapIDs, try to get the player's projected position on that vendor map.
                        local comparePX, comparePY = nil, nil
                        local vendorMapToUse = vendor.mapIDs and vendor.mapIDs[1] or currentMapID
                        if vendor.mapIDs and C_Map and C_Map.GetPlayerMapPosition then
                            local okProj, ppos = pcall(C_Map.GetPlayerMapPosition, vendorMapToUse, "player")
                            if okProj and ppos then
                                if type(ppos.GetXY) == "function" then
                                    comparePX, comparePY = ppos:GetXY()
                                elseif type(ppos) == "table" and ppos.x and ppos.y then
                                    comparePX, comparePY = ppos.x, ppos.y
                                end
                                if comparePX and comparePY and comparePX <= 1 and comparePY <= 1 then
                                    comparePX = comparePX * 100; comparePY = comparePY * 100
                                end
                            end
                        end

                        -- Fallback to player's current map coordinates if projection not available
                        if not comparePX or not comparePY then
                            comparePX, comparePY = playerX, playerY
                        end

                        local dx = coord.x - comparePX
                        local dy = coord.y - comparePY
                        local distanceSq = dx*dx + dy*dy

                        if BeastAndBow_Settings and BeastAndBow_Settings.debug then
                            local distance = math.sqrt(distanceSq)
                            bab_print(string.format("Vendor '%s' candidate at %.1f,%.1f (compareAt=%.1f,%.1f dx=%.2f dy=%.2f) dist=%.2f", tostring(vendor.npc), coord.x, coord.y, comparePX or 0, comparePY or 0, dx, dy, distance))
                        end

                        if minDistanceSq == -1 or distanceSq < minDistanceSq then
                            minDistanceSq = distanceSq
                            nearestVendor = {
                                name = vendor.npc,
                                x = coord.x,
                                y = coord.y,
                                mapID = vendor.mapIDs and vendor.mapIDs[1] or 0
                            }
                        end
                    end
                end
            else
                bab_print(string.format(BeastAndBow.L.VENDOR_NOT_ACCESSIBLE, vendor.npc, playerFaction))
            end
        end

        if nearestVendor then
            local mapName = BeastAndBow.MapNames[nearestVendor.mapID] or BeastAndBow.L.UNKNOWN_ZONE
            if SlashCmdList["TOMTOM_WAY"] then
                local msg = string.format("%s %.1f %.1f %s", mapName, nearestVendor.x, nearestVendor.y, nearestVendor.name)
                SlashCmdList["TOMTOM_WAY"](msg)
                bab_print(string.format(BeastAndBow.L.WAYPOINT_CREATED, nearestVendor.name, mapName))
            else
                bab_print(BeastAndBow.L.TOMTOM_NOT_FOUND .. mapName .. " " .. nearestVendor.x .. " " .. nearestVendor.y .. " " .. nearestVendor.name)
            end
        else
            bab_print(string.format(BeastAndBow.L.NO_VENDOR_FOUND, vendorType))
        end
    end

    function BeastAndBow.FindNearestArrowVendor() BeastAndBow.FindNearestVendor("arrow", BeastAndBow.ArrowVendors) end
    function BeastAndBow.FindNearestBreadVendor() BeastAndBow.FindNearestVendor("bread", BeastAndBow.BreadVendors) end
    function BeastAndBow.FindNearestFishVendor() BeastAndBow.FindNearestVendor("fish", BeastAndBow.FishVendors) end
    function BeastAndBow.FindNearestCheeseVendor() BeastAndBow.FindNearestVendor("cheese", BeastAndBow.CheeseVendors) end
    function BeastAndBow.FindNearestFruitVendor() BeastAndBow.FindNearestVendor("fruit", BeastAndBow.FruitVendors) end
    function BeastAndBow.FindNearestMushroomVendor() BeastAndBow.FindNearestVendor("mushroom", BeastAndBow.MushroomVendors) end
    function BeastAndBow.FindNearestMeatVendor() BeastAndBow.FindNearestVendor("meat", BeastAndBow.MeatVendors) end

    -- Map debug helper: prints player/map info and vendor candidate details for Arrow vendors
    function BeastAndBow.MapDebug()
        print(BeastAndBow.L.ADDON_NAME .. ": MapDebug starting...")

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

        print(BeastAndBow.L.ADDON_NAME .. ": uiMapID=" .. tostring(uiMapID) .. " playerMapXY=" .. tostring(px) .. "," .. tostring(py) .. " UnitPosition=" .. tostring(ux) .. "," .. tostring(uy) .. "," .. tostring(uz))

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
            print(BeastAndBow.L.ADDON_NAME .. ": No ArrowVendors defined")
            return
        end

        for _, vendor in ipairs(BeastAndBow.ArrowVendors) do
            local vendorName = vendor.npc or "<unknown>"
            local mapIDs = vendor.mapIDs and table.concat(vendor.mapIDs, ",") or "<none>"
            local faction = vendor.faction or "<none>"
            print(string.format(BeastAndBow.L.ADDON_NAME .. ": Vendor '%s' maps=%s faction=%s", vendorName, mapIDs, tostring(faction)))

            if vendor.mapIDs and uiMapID then
                for _, mapID in ipairs(vendor.mapIDs) do
                    local related = AreMapsRelated(mapID, uiMapID) or AreMapsRelated(uiMapID, mapID)
                    print(string.format("  map %d relatedToCurrent=%s", mapID, tostring(related)))
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
                    print(string.format("  coord %.1f,%.1f %s dx=%.2f dy=%.2f dist=%s", vx, vy, reason, (dx or 0), (dy or 0), dist and string.format("%.2f", dist) or "nil"))
                end
            else
                print("  (no coords provided)")
            end
        end

        print(BeastAndBow.L.ADDON_NAME .. ": MapDebug finished")
    end

    function BeastAndBow.SavePosition()
        if frame then
            local point, _, relativePoint, x, y = frame:GetPoint()
            BeastAndBow_Settings.position = {
                point = point,
                relativePoint = relativePoint,
                x = x,
                y = y
            }
        end
    end

    SLASH_BEASTANDBOW1 = "/beastandbow"
    SLASH_BEASTANDBOW2 = "/bab"
    SlashCmdList["BEASTANDBOW"] = function(msg)
        msg = string.lower(msg)
        if msg == "mapdebug" then
            BeastAndBow.MapDebug()
            return
        end
        if msg == "report" then
            BeastAndBow.ToggleReportFrame()
            return
        end
        if msg == "debug" then
            BeastAndBow_Settings.debug = not BeastAndBow_Settings.debug
            print(BeastAndBow.L.ADDON_NAME .. ": " .. (BeastAndBow_Settings.debug and BeastAndBow.L.DEBUG_MODE_ENABLED or BeastAndBow.L.DEBUG_MODE_DISABLED) .. ".")
        elseif msg == "show" then
            BeastAndBow_Settings.frameVisible = true
            if frame then frame:Show() end
        elseif msg == "hide" then
            BeastAndBow_Settings.frameVisible = false
            if frame then frame:Hide() end
        else
            print(BeastAndBow.L.ADDON_NAME .. ": " .. BeastAndBow.L.AVAILABLE_COMMANDS)
        end
    end

-- Process any frames that were loaded before the addon was ready
if _BeastAndBow_pendingOnLoad then
    for _, frame in ipairs(_BeastAndBow_pendingOnLoad) do
        if frame and type(frame.IsVisible) == "function" then
            BeastAndBow.OnLoad(frame)
        end
    end
    _BeastAndBow_pendingOnLoad = nil -- Clear the queue
end
