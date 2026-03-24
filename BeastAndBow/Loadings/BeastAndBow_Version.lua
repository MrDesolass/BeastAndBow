-- BeastAndBow_Version.lua
-- Versions-Erkennungssystem für Classic Era und TBC

BeastAndBow = BeastAndBow or {}
local BAB = BeastAndBow

-- ============================================================================
-- WoW VERSION DETECTION
-- ============================================================================

local function GetWoWVersion()
    -- GetBuildInfo() returns: versionString, buildString, buildDate, interfaceNumber
    local versionString, buildString, _, interfaceNumber = GetBuildInfo()
    local major, minor, patch = tostring(versionString):match("^(%d+)%.(%d+)%.(%d+)")

    return {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch),
        build = tonumber(buildString),
        interface = tonumber(interfaceNumber),
        versionString = tostring(versionString or "unknown"),
    }
end

-- Cache the version info
BAB.WoWVersion = GetWoWVersion()

-- ============================================================================
-- EXPANSION DETECTION
-- ============================================================================

function BAB.IsClassicEra()
    local v = BAB.WoWVersion or {}
    -- Classic Era clients are 1.x and use 1xxxx interface numbers.
    if v.major == 1 then return true end
    if v.interface and v.interface >= 10000 and v.interface < 20000 then return true end
    return false
end

function BAB.IsTBC()
    local v = BAB.WoWVersion or {}
    -- TBC clients are 2.x and use 2xxxx interface numbers.
    if v.major == 2 then return true end
    if v.interface and v.interface >= 20000 and v.interface < 30000 then return true end
    return false
end

function BAB.IsExpansion(expansion)
    -- expansion: "ClassicEra", "TBC", etc.
    if expansion == "ClassicEra" then
        return BAB.IsClassicEra()
    elseif expansion == "TBC" then
        return BAB.IsTBC()
    end
    return false
end

function BAB.GetCurrentExpansion()
    if BAB.IsClassicEra() then
        return "ClassicEra"
    elseif BAB.IsTBC() then
        return "TBC"
    end
    return "Unknown"
end

function BAB.GetGameVersion()
    local v = BAB.WoWVersion
    if not v then return "unknown" end
    local versionLabel = v.versionString or string.format("%s.%s.%s", tostring(v.major or "?"), tostring(v.minor or "?"), tostring(v.patch or "?"))
    return string.format("%s (%s)", versionLabel, tostring(v.build or "?"))
end

-- ============================================================================
-- FEATURE AVAILABILITY
-- ============================================================================

-- In TBC werden neue Map IDs und Zonen hinzugefügt
function BAB.IsNewTBCZone(mapID)
    -- TBC-only Zones: Outland, Hellfire Peninsula, etc.
    -- Diese werden in TBC_Data.lua definiert
    if BAB.TBC_MapIDs and BAB.TBC_MapIDs[mapID] then
        return true
    end
    return false
end

-- ============================================================================
-- LOGGING
-- ============================================================================

function BAB.LogVersion()
    print("|cff9482c9Beast & Bow|r - " .. BAB.GetGameVersion() .. " (" .. BAB.GetCurrentExpansion() .. ")")
end

-- Log on load
BAB.LogVersion()
