-- ============================================================================
-- DebugUtils.lua: Zentrale Debug- und Log-Verwaltung für BeastAndBow
-- ============================================================================
-- Dieses Modul bietet ein einheitliches Debug-System mit Severity-Levels
-- und konsistenter Formatierung für alle Addon-Ausgaben.
-- ============================================================================

BeastAndBow = BeastAndBow or {}
BeastAndBow_Settings = BeastAndBow_Settings or {}

-- ============================================================================
-- LOG LEVEL DEFINITIONS
-- ============================================================================

local LOG_LEVELS = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    DEBUG = 4
}

-- Befriedigende Beschreibungen für Log Levels
local LEVEL_NAMES = {
    [LOG_LEVELS.ERROR] = "ERROR",
    [LOG_LEVELS.WARN] = "WARN",
    [LOG_LEVELS.INFO] = "INFO",
    [LOG_LEVELS.DEBUG] = "DEBUG"
}

-- Farben für verschiedene Log Levels (für UI-Ausgabe wenn gewünscht)
local LEVEL_COLORS = {
    [LOG_LEVELS.ERROR] = { r = 1.0, g = 0.2, b = 0.2 },  -- Rot
    [LOG_LEVELS.WARN] = { r = 1.0, g = 0.8, b = 0.2 },   -- Orange/Gelb
    [LOG_LEVELS.INFO] = { r = 0.7, g = 1.0, b = 0.7 },   -- Grün
    [LOG_LEVELS.DEBUG] = { r = 0.7, g = 0.7, b = 1.0 }   -- Blau
}

-- ============================================================================
-- SETTINGS & CONFIGURATION
-- ============================================================================

-- Standard Log Level (was zeigen wir in der Konsole?)
-- ERROR=1, WARN=2, INFO=3, DEBUG=4
local DEFAULT_LOG_LEVEL = LOG_LEVELS.WARN

-- Debug-Mode: Wenn true, wird alles angezeigt (auch DEBUG)
local function IsDebugMode()
    return BeastAndBow_Settings.debug == true
end

-- Bestimme welche Level angezeigt werden
local function GetEffectiveLogLevel()
    -- Debug Mode: Alles zeigen
    if IsDebugMode() then
        return LOG_LEVELS.DEBUG
    end
    
    -- Prüfe debugLogLevel Setting (von Dropdown)
    local levelStr = BeastAndBow_Settings.debugLogLevel
    if levelStr then
        if levelStr == "DEBUG" then
            return LOG_LEVELS.DEBUG
        elseif levelStr == "INFO" then
            return LOG_LEVELS.INFO
        elseif levelStr == "WARN" then
            return LOG_LEVELS.WARN
        elseif levelStr == "ERROR" then
            return LOG_LEVELS.ERROR
        end
    end
    
    -- Fallback auf Default
    return DEFAULT_LOG_LEVEL
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- Zentraler Log-Dispatcher
local function Log(level, context, message)
    -- Wenn Debug Mode AUS ist, nur ERROR und WARN zeigen
    if not IsDebugMode() and level > LOG_LEVELS.WARN then
        return
    end
    
    -- Wenn Debug Mode AN ist, nutze GetEffectiveLogLevel für feinere Kontrolle
    if IsDebugMode() and level > GetEffectiveLogLevel() then
        return
    end
    
    -- Formatiere die Nachricht
    local addonName = BeastAndBow.L and BeastAndBow.L.ADDON_NAME or "BeastAndBow"
    local levelName = LEVEL_NAMES[level] or "UNKNOWN"
    
    -- Basis-Format: [ADDON_NAME] [LEVEL] message
    local prefix = string.format("[%s] [%s]", addonName, levelName)
    if context then
        prefix = prefix .. " (" .. context .. ")"
    end
    
    local output = prefix .. ": " .. tostring(message)
    print(output)
end

-- Convenience-Funktionen für verschiedene Log Levels
local function Error(message, context)
    Log(LOG_LEVELS.ERROR, context, message)
end

local function Warn(message, context)
    Log(LOG_LEVELS.WARN, context, message)
end

local function Info(message, context)
    Log(LOG_LEVELS.INFO, context, message)
end

local function Debug(message, context)
    Log(LOG_LEVELS.DEBUG, context, message)
end

-- ============================================================================
-- COMPATIBILITY & LEGACY FUNCTIONS
-- ============================================================================

-- Legacy bab_print(): Provide global wrapper compatible with calls bab_print(msg, level, context)
-- Falls Level/Context nicht angegeben, mappen wir auf INFO.
function bab_print(msg, level, context)
    local dbg = BeastAndBow and BeastAndBow.Debug
    local lvl = level or (dbg and dbg.LEVELS and dbg.LEVELS.INFO or 3)

    -- Schlanke Logs: DEBUG-Meldungen nur, wenn debugVerbose aktiv ist.
    local verbose = BeastAndBow_Settings and BeastAndBow_Settings.debugVerbose
    if dbg and dbg.LEVELS and lvl >= dbg.LEVELS.DEBUG and not verbose then
        return
    end

    if dbg and type(dbg.Log) == "function" then
        dbg.Log(lvl, context, msg)
        return
    end
    -- Fallback, falls Debug-System noch nicht initialisiert ist
    if lvl < 4 or verbose then
        print(tostring(msg))
    end
end

-- Legacy print() Wrapper für ältere Code-Teile
-- VORSICHT: Das macht die echte print() zu unserer Log-Funktion
-- Nur verwenden für Code der von außen kommt!
local function BeastAndBow_print(msg)
    Info(msg, "print()")
end

-- ============================================================================
-- DIAGNOSTIC FUNCTIONS
-- ============================================================================

-- Zeige aktuelle Debug-Status
local function PrintDebugStatus()
    local addonName = BeastAndBow.L and BeastAndBow.L.ADDON_NAME or "BeastAndBow"
    print("---")
    print(string.format("%s Debug Status:", addonName))
    print(string.format("  Debug Mode: %s", tostring(IsDebugMode())))
    print(string.format("  Effective Log Level: %s", LEVEL_NAMES[GetEffectiveLogLevel()] or "UNKNOWN"))
    print("---")
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

BeastAndBow.Debug = {
    -- Log Levels (Konstanten)
    LEVELS = LOG_LEVELS,
    
    -- Haupt-API
    Log = Log,
    Error = Error,
    Warn = Warn,
    Info = Info,
    Debug = Debug,
    
    -- Legacy Support
    bab_print = bab_print,
    BeastAndBow_print = BeastAndBow_print,
    
    -- Diagnostik
    PrintDebugStatus = PrintDebugStatus,
    IsDebugMode = IsDebugMode,
    GetEffectiveLogLevel = GetEffectiveLogLevel,
    
    -- Helpers
    LEVEL_NAMES = LEVEL_NAMES,
    LEVEL_COLORS = LEVEL_COLORS
}

-- Für schnellerZugriff: auch auf globale Namespace
local Debug = BeastAndBow.Debug

-- ============================================================================
-- INITIALIZATION MESSAGE
-- ============================================================================

-- Nach dem Laden das System aktivieren
local function Initialize()
    if BeastAndBow_Settings.logLevel == nil then
        BeastAndBow_Settings.logLevel = DEFAULT_LOG_LEVEL
    end
    Debug.Info("Debug system initialized", "DebugUtils")
end

-- Initialize wird später aufgerufen wenn das Addon geladen ist
if not BeastAndBow._DebugUtilsInitialized then
    BeastAndBow._DebugUtilsInitialized = true
    -- Will be initialized from main addon file after load
end
