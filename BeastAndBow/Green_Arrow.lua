-- Green_Arrow.lua: Komplette Navigation Arrow Logik für BeastAndBow
-- Exportiert alle Arrow-Funktionen über BeastAndBow Namespace

local addonName, addonTable = ...
BeastAndBow = BeastAndBow or {}
local BAB = BeastAndBow

-- Local safe logging helpers (use DebugUtils when available)
local function LogInfo(msg, ctx)
    if BeastAndBow and BeastAndBow.Debug and BeastAndBow.Debug.Info then
        BeastAndBow.Debug.Info(msg, ctx or "Green_Arrow")
    else
        print(msg)
    end
end

local function LogWarn(msg, ctx)
    if BeastAndBow and BeastAndBow.Debug and BeastAndBow.Debug.Warn then
        BeastAndBow.Debug.Warn(msg, ctx or "Green_Arrow")
    else
        print(msg)
    end
end

local function LogDebug(msg, ctx)
    if BeastAndBow and BeastAndBow.Debug and BeastAndBow.Debug.Debug then
        BeastAndBow.Debug.Debug(msg, ctx or "Green_Arrow")
    else
        -- only print debug fallback when global debug is enabled
        if BeastAndBow and BeastAndBow_Settings and BeastAndBow_Settings.debug then
            print(msg)
        end
    end
end

-- ============================================================================
-- HEREBEDRAGONS LIBRARY SETUP
-- Green_Arrow loaded
-- ============================================================================

local HBD = nil
if LibStub then
    local ok, lib = pcall(function() return LibStub("HereBeDragons-2.0") end)
    if ok and lib then
        HBD = lib
    end
end

if not HBD then
    -- Use debug logging when available; fallback to print
    LogWarn("HereBeDragons-2.0 library not found!", "Green_Arrow")
    -- Dummy object to prevent errors
    HBD = {
        GetPlayerWorldPosition = function() return nil end,
        GetWorldVector = function() return nil end,
        GetWorldCoordinatesFromZone = function() return nil end,
        GetWorldCoordinatesFromUIMapID = function() return nil end,
    }
else
    -- HBD library found
end

-- Load the HereBeDragons-Pins library
local hbdp = nil
if LibStub then
    local ok, lib = pcall(function() return LibStub("HereBeDragons-Pins-2.0") end)
    if ok and lib then
        hbdp = lib
    end
end

if not hbdp then
    LogWarn("HereBeDragons-Pins-2.0 library not found! Map pins will not be shown.", "Green_Arrow")
    -- Dummy object to prevent errors
    hbdp = {
        AddWorldMapIconMap = function() end,
        AddMinimapIconMap = function() end,
        RemoveWorldMapIcon = function() end,
        RemoveMinimapIcon = function() end,
    }
else
    if BeastAndBow and BeastAndBow.Debug and BeastAndBow.Debug.Debug then
        BeastAndBow.Debug.Debug(tostring(hbdp), "Green_Arrow: HBD-Pins")
        if hbdp.AddWorldMapIconMap then
            BeastAndBow.Debug.Debug("AddWorldMapIconMap ist vorhanden!", "Green_Arrow: HBD-Pins")
        else
            BeastAndBow.Debug.Debug("AddWorldMapIconMap fehlt!", "Green_Arrow: HBD-Pins")
        end
    else
        -- Fallback minimal info (goes to debug-level log only)
        LogDebug("HBD-Pins detected: " .. tostring(hbdp), "Green_Arrow: HBD-Pins")
    end
end

-- Apply the WorldMap OnShow hook to ensure pins refresh when the map is opened.
-- This logic was formerly in FixMapPins.lua
C_Timer.After(2, function()
    if not (hbdp and hbdp.worldmapProvider and hbdp.worldmapProvider.RefreshAllData) then
        return
    end

    local mapFrame = _G.WorldMapFrame
    if not mapFrame then
        return
    end

    -- Hook the OnShow script
    local originalOnShow = mapFrame:GetScript("OnShow")
    mapFrame:SetScript("OnShow", function(self, ...)
        if originalOnShow then
            originalOnShow(self, ...)
        end
        hbdp.worldmapProvider:RefreshAllData()
    end)
end)


-- ============================================================================
-- FRAME UND VISUELLE ELEMENTE
-- ============================================================================

-- Erstelle das Arrow-Frame
local arrowFrame = CreateFrame("Frame", "BAB_NavigationArrow", UIParent)
arrowFrame:SetSize(48, 48)
arrowFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
arrowFrame:EnableMouse(true)
arrowFrame:SetMovable(true)
arrowFrame:RegisterForDrag("LeftButton")
arrowFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
arrowFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Tooltip beim Hover über Arrow
arrowFrame:SetScript("OnEnter", function(self)
    if GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Beast & Bow Navigation", 1, 1, 1)
        GameTooltip:AddLine("Left-click and drag to move", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click to clear waypoint", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end
end)
arrowFrame:SetScript("OnLeave", function(self)
    if GameTooltip then
        GameTooltip:Hide()
    end
end)

-- Rechtsklick zum Löschen des Waypoints (Handler unten gesetzt)
arrowFrame:Hide()

-- Arrow Texture
local arrowTexture = arrowFrame:CreateTexture(nil, "ARTWORK")
arrowTexture:SetAllPoints()
arrowTexture:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\navigation.blp")
arrowTexture:SetTexCoord(0, 1, 0, 1)
arrowFrame.arrow = arrowTexture

-- Distance Display Text
local distanceText = arrowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
distanceText:SetPoint("TOP", arrowFrame, "BOTTOM", 0, -5)
distanceText:SetTextColor(1, 1, 1)

-- ============================================================================
-- PIN FRAMES (HBD-Pins erwartet Frames, keine Tables)
-- ============================================================================

-- Robust texture setter with fallback
local function SafeSetTexture(texObj, pathOrID)
    local ok = texObj:SetTexture(pathOrID)
    if ok == false then
        texObj:SetTexture(136441) -- Blizzard POI as fallback
    end
end

-- Create a plain frame pin for World Map (let HBD-Pins manage parenting/position/visibility)
local worldMapIcon = CreateFrame("Button", "BAB_WorldMapIcon", UIParent)
worldMapIcon:SetSize(28, 28) -- visible on MapCanvas (reduced size)
worldMapIcon:SetFrameStrata("HIGH")
worldMapIcon:SetFrameLevel(10000)
worldMapIcon:EnableMouse(false)
worldMapIcon:SetMovable(false)
-- Important: do not set points or :Show(); HBD-Pins will manage it.

local worldMapTexture = worldMapIcon:CreateTexture(nil, "ARTWORK")
worldMapTexture:SetAllPoints()
SafeSetTexture(worldMapTexture, "Interface\\AddOns\\BeastAndBow\\Textures\\Waypoint_pin.tga")

-- Create a plain frame pin for Minimap
local minimapIcon = CreateFrame("Button", "BAB_MinimapIcon", UIParent)
minimapIcon:SetSize(24, 24)
minimapIcon:SetFrameStrata("MEDIUM")
minimapIcon:SetFrameLevel(9)
minimapIcon:EnableMouse(false)
minimapIcon:SetMovable(false)

local minimapTexture = minimapIcon:CreateTexture(nil, "ARTWORK")
minimapTexture:SetAllPoints()
SafeSetTexture(minimapTexture, "Interface\\AddOns\\BeastAndBow\\Textures\\Waypoint_pin.tga")

-- ============================================================================
-- EINSTELLUNGEN UND KONFIGURATION
-- ============================================================================

BeastAndBow_Settings = BeastAndBow_Settings or {}

-- Debug Mode
if type(BeastAndBow_Settings.debug) ~= "boolean" then
    BeastAndBow_Settings.debug = false
end

-- Rotation-Offset (Feinjustierung der Pfeil-Grafik)
local rotationOffset = 0
if type(BeastAndBow_Settings.rotationOffsetDeg) == "number" then
    rotationOffset = BeastAndBow_Settings.rotationOffsetDeg * math.pi / 180
else
    BeastAndBow_Settings.rotationOffsetDeg = 0
    rotationOffset = 0
end
 
 -- WorldMap pin size setting (default: 28)
 if type(BeastAndBow_Settings.worldMapPinSize) ~= "number" then
     BeastAndBow_Settings.worldMapPinSize = 28
 end
 
 -- Apply configured world map pin size to the previously-created frame
 if worldMapIcon and type(BeastAndBow_Settings.worldMapPinSize) == "number" then
     worldMapIcon:SetSize(BeastAndBow_Settings.worldMapPinSize, BeastAndBow_Settings.worldMapPinSize)
 end

-- ============================================================================
-- NAVIGATION STATE & PUBLIC API
-- ============================================================================

BAB.navTargets = nil  -- List of targets { {wx=, wy=, instance=, label=} }
BAB.navIndex = 1
BAB.isPinSet = false -- Track if the pin is currently active

function BAB.ShowNavigationArrow(show)
    if show then
        arrowFrame:Show()
    else
        arrowFrame:Hide()
    end
end

-- Internal helper to clear both pins
local function ClearPins()
    if BAB.isPinSet then
        hbdp:RemoveWorldMapIcon(BAB, worldMapIcon)
        hbdp:RemoveMinimapIcon(BAB, minimapIcon)
        BAB.isPinSet = false
    end
end


-- Helper: force-show if WorldMap open on correct uiMapID (debug aid)
local function TryForceShowWorldMapPin(uiMapID)
    if not WorldMapFrame or not WorldMapFrame.GetMapID then return end
    local openID = WorldMapFrame:GetMapID()
    if openID == uiMapID then
        -- HBD-Pins manages visibility, but some UIs hide children; ensure ours isn't hidden.
        worldMapIcon:Show()
        worldMapIcon:SetAlpha(1.0)
        -- Also bring to front again
        worldMapIcon:SetFrameLevel(10000)
    end
end

-- This internal function now also handles removing the map pins
function BAB.SetNavigationTargets(worldCoordTargetList)
    if type(worldCoordTargetList) == "table" and #worldCoordTargetList > 0 then
        BAB.navTargets = worldCoordTargetList
        BAB.navIndex = 1
        BAB.ShowNavigationArrow(true)

        -- Clear existing pins before setting new ones
        ClearPins()

        -- Only first target gets a pin for now
        local target = worldCoordTargetList[1]
        if target and HBD and hbdp then
            -- processing target

            local x, y, uiMapID = target.normX, target.normY, target.uiMapID
            if x and y and uiMapID then
                -- Prefer adding the pin using WORLD coordinates (we already computed them in SetNavigationTarget).
                -- This avoids relying on HBD:GetWorldCoordinatesFromZone(uiMapID) which may return nil in some map states.
                local addedWorld = false
                if target.wx and target.wy and target.instance then
                    pcall(function()
                        if hbdp.AddWorldMapIconWorld then
                            hbdp:AddWorldMapIconWorld(BAB, worldMapIcon, target.instance, target.wx, target.wy, 3)
                            addedWorld = true
                        end
                    end)
                end

                -- Fallback: try adding by uiMapID (zone coords) if world-add failed
                if not addedWorld then
                    pcall(function()
                        if hbdp.AddWorldMapIconMap then
                            hbdp:AddWorldMapIconMap(BAB, worldMapIcon, uiMapID, x, y, 3)
                        end
                    end)
                end

                -- immediate snapshot removed (clean runtime)

                -- 2. Versuche, die Karte sofort zu aktualisieren und das Pin vom Provider
                -- verarbeiten zu lassen. Einige UIs liefern beim allerersten Klick noch
                -- keinen stabilen MapState, daher versuchen wir (a) ein sofortiges
                -- HandlePin (falls möglich) und (b) einen sicheren Refresh auf dem
                -- nächsten Frame. Beide Aufrufe verwenden pcall, um Laufzeitfehler
                -- in unterschiedlichen UI-Umgebungen abzufangen.
                -- Retry helper: mehrere Versuche in kurzen Abständen durchführen,
                -- weil das WorldMap/GetMap state manchmal noch nicht vollständig
                -- initialisiert ist. Die Versuche sind sicher (pcall) und schreiben
                -- nur im Debug-Modus Ausgaben.
                local function doAttempt(tag)
                    if not hbdp then return end
                    pcall(function()
                        if hbdp.worldmapProvider and hbdp.worldmapPins and hbdp.worldmapPins[worldMapIcon] then
                            hbdp.worldmapProvider:HandlePin(worldMapIcon, hbdp.worldmapPins[worldMapIcon])
                        end

                        -- Direct AcquirePin fallback: if the map is open, try acquiring the pin on the MapCanvas.
                        pcall(function()
                            local data = hbdp.worldmapPins and hbdp.worldmapPins[worldMapIcon]
                            if data and WorldMapFrame and WorldMapFrame.GetMap then
                                local mapObj = WorldMapFrame:GetMap()
                                if mapObj and mapObj.GetMapID then
                                    local openID = mapObj:GetMapID()
                                    if openID then
                                        local lx, ly = HBD:GetZoneCoordinatesFromWorld(data.x, data.y, openID)
                                        if lx and ly and mapObj.AcquirePin then
                                            mapObj:AcquirePin("HereBeDragonsPinsTemplate", worldMapIcon, lx, ly, data.frameLevelType)
                                        end
                                    end
                                end
                            end
                        end)
                    end)
                    pcall(function()
                        if hbdp.worldmapProvider then
                            hbdp.worldmapProvider:RefreshAllData()
                        end
                    end)
                end

                C_Timer.After(0,   function() doAttempt("t0") end)
                C_Timer.After(0.05,function() doAttempt("t50") end)
                C_Timer.After(0.2, function() doAttempt("t200") end)

                -- Minimap-MapID: versuche, die aktuelle Player-Zone von HBD zu verwenden,
                -- damit der Minimap-Pin IMMER auf der aktiven Minimap-Map liegt.
                local mmMapID = uiMapID
                if HBD.GetPlayerZone then
                    local playerZoneID = HBD:GetPlayerZone()
                    if playerZoneID then
                        mmMapID = playerZoneID
                    end
                end

                -- Minimap: showOnParent=false, floatOnEdge=true
                hbdp:AddMinimapIconMap(BAB, minimapIcon, mmMapID, x, y, false, true)
                BAB.isPinSet = true

                -- pins added
            else
                -- Invalid uiMapID/x/y: Pins not added.
            end
        end
    else
        -- Clear everything: arrow, navigation data, and map pins
        BAB.navTargets = nil
        BAB.navIndex = 1
        BAB.ShowNavigationArrow(false)
        ClearPins()
    end
end

-- Main function to set a waypoint: only compute world coords, then delegate pin creation
function BAB.SetNavigationTarget(oldMapID, uiMapID, x, y, label, preWx, preWy, preInstance)
    -- SetNavigationTarget called
    if not (hbdp and HBD and oldMapID and uiMapID and x ~= nil and y ~= nil) then
        BAB.SetNavigationTargets(nil)
        return
    end

    if type(x) ~= "number" or type(y) ~= "number" then
        BAB.SetNavigationTargets(nil)
        return
    end

    local normX = (x > 1) and (x / 100) or x
    local normY = (y > 1) and (y / 100) or y

    -- Compute or accept world coordinates for arrow navigation
    local wx, wy, instance = preWx, preWy, preInstance

    -- If precomputed world coords weren't provided, compute them now
    if not (type(wx) == "number" and type(wy) == "number" and instance) then
        -- Preferred: UIMapID-based resolution (Retail/Wrath+)
        if HBD.GetWorldCoordinatesFromUIMapID and uiMapID then
            wx, wy, instance = HBD:GetWorldCoordinatesFromUIMapID(normX, normY, uiMapID)
        end

        -- Fallback: legacy zone-based resolution (Classic-era HBD)
        if (not wx or not wy or not instance) and HBD.GetWorldCoordinatesFromZone and oldMapID then
            local fx, fy, finst = HBD:GetWorldCoordinatesFromZone(normX, normY, oldMapID)
            if fx and fy and finst then
                wx, wy, instance = fx, fy, finst
            end
        end
    end

    if wx and wy and instance then
        -- Delegate to SetNavigationTargets which will add pins (avoid double add)
        BAB.SetNavigationTargets({
            {
                wx = wx, wy = wy, instance = instance,
                label = label, uiMapID = uiMapID, normX = normX, normY = normY
            }
        })
        -- Pin set via SetNavigationTargets
    else
        BAB.SetNavigationTargets(nil)
    end
end

-- Right-click on arrow clears everything correctly
arrowFrame:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        BAB.SetNavigationTargets(nil)
    end
end)

-- ============================================================================
-- ARROW UPDATE LOOP
-- ============================================================================

arrowFrame:SetScript("OnUpdate", function(self, elapsed)
    -- No throttle - update every frame for maximum smoothness
    if not BAB.navTargets or not BAB.navTargets[BAB.navIndex] then
        arrowTexture:SetRotation(0)
        distanceText:SetText("")
        return
    end

    local target = BAB.navTargets[BAB.navIndex]

    -- Hole die Weltposition des Spielers direkt.
    local p_wx, p_wy, p_instance = HBD:GetPlayerWorldPosition()

    if not p_wx then
        distanceText:SetText("Player position not found")
        distanceText:SetTextColor(1,0,0)
        return
    end

    -- Zielkoordinaten sind bereits Weltkoordinaten
    local t_wx, t_wy, t_instance = target.wx, target.wy, target.instance

    local distYards, angle = nil, nil

    -- Stelle sicher, dass Spieler und Ziel auf derselben Instanz (Kontinent) sind
    if p_instance == t_instance then
        angle, distYards = HBD:GetWorldVector(p_instance, p_wx, p_wy, t_wx, t_wy)
    end

    if not distYards or not angle then
        distanceText:SetText("--- yd (different continent?)")
        distanceText:SetTextColor(1,0,0)
        arrowTexture:SetRotation(0)
        return
    end

    -- Anzeige
    local yardsInt = math.floor(distYards + 0.5)
    if target.label and target.label ~= "" then
        distanceText:SetText(string.format("%s — %d yd", tostring(target.label), yardsInt))
    else
        distanceText:SetText(string.format("%d yd", yardsInt))
    end

    if distYards < 50 then
        distanceText:SetTextColor(0, 1, 0) -- Grün
    elseif distYards < 200 then
        distanceText:SetTextColor(1, 1, 0) -- Gelb
    else
        distanceText:SetTextColor(1, 1, 1) -- Weiß
    end

    -- Ziel erreicht?
    if distYards < 5 then
        if BAB.navTargets[BAB.navIndex+1] then
            BAB.navIndex = BAB.navIndex + 1
            if PlaySound then PlaySound(SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_3 or 567) end
        else
            BAB.SetNavigationTargets(nil)
            if PlaySound then PlaySound(SOUNDKIT.MAP_PING or 856) end
            return
        end
    end

    -- Pfeilrotation
    local playerFacing = GetPlayerFacing()
    if not playerFacing then return end

    local orientation = angle - playerFacing + rotationOffset
    local twopi = math.pi * 2
    orientation = orientation % twopi

    arrowTexture:SetRotation(orientation)
end)

-- ============================================================================
-- SLASH COMMANDS (for testing)
-- ============================================================================

SLASH_BABARROW1 = "/babarrow"
SlashCmdList["BABARROW"] = function(msg)
    local args = {strsplit(" ", msg)}
    if args[1] and args[2] and args[3] then
        -- /babarrow oldMapID x y
        local oldMapID, x, y = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if oldMapID and x and y then
            -- Look up the uiMapID from the oldMapID
            local uiMapID = (BeastAndBow and BeastAndBow.MapIDToHBDUI and BeastAndBow.MapIDToHBDUI[oldMapID]) or oldMapID

            LogInfo(string.format("Setting test waypoint on oldMapID %d (uiMapID %d) at %.2f, %.2f", oldMapID, uiMapID, x, y), "BABARROW")
            BAB.SetNavigationTarget(oldMapID, uiMapID, x, y, "Test Waypoint")
        else
            LogWarn("Invalid arguments. Usage: /babarrow <oldMapID> <x> <y>", "BABARROW")
        end
    else
        -- Convenience: set pin on currently open world map (for testing visibility)
        local openID = WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
        if openID then
            local tx = 0.5
            local ty = 0.5
            LogInfo(string.format("Quick test waypoint on currently open uiMapID %d at %.2f, %.2f", openID, tx, ty), "BABARROW")
            BAB.SetNavigationTarget(openID, openID, tx, ty, "Test Waypoint (Center)")
        else
            if arrowFrame:IsShown() then
                BAB.ShowNavigationArrow(false)
            else
                BAB.ShowNavigationArrow(true)
            end
        end
    end
end

SLASH_BABOFFSET1 = "/baboffset"
SlashCmdList["BABOFFSET"] = function(msg)
    local deg = tonumber(msg)
    if not deg then
        LogWarn("Usage: /baboffset <degrees>", "BABOFFSET")
        return
    end
    rotationOffset = deg * math.pi / 180
    BeastAndBow_Settings.rotationOffsetDeg = deg
    LogInfo(string.format("Rotation offset set to %s", string.format("%.1f°", deg)), "BABOFFSET")
end

SLASH_BABDEBUG1 = "/babdebug"
SlashCmdList["BABDEBUG"] = function(msg)
    BeastAndBow_Settings.debug = not BeastAndBow_Settings.debug
    LogInfo("Debug mode is now " .. (BeastAndBow_Settings.debug and "ON" or "OFF"), "BABDEBUG")
end
