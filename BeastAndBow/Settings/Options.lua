BeastAndBow.Options = {}

-- Local aliases to reduce global lookups and static-lint warnings
local C_Timer = C_Timer
local CreateFrame = CreateFrame
local Settings = Settings
local _G = _G

local function InitializeSettings()
    local addonName = "BeastAndBow"
    
    -- Hauptkategorie für Beast & Bow
    local category, layout = Settings.RegisterVerticalLayoutCategory(addonName)
    BeastAndBow.settingsCategory = category

    -- Warning System Setting
    local warningSystemSetting = Settings.RegisterAddOnSetting(
        category,
        "BEASTANDBOW_WARNING_SYSTEM",
        "warningSystemEnabled",
        BeastAndBow_Settings,
        Settings.VarType.Boolean,
        BeastAndBow.L.OPTIONS_ENABLE_WARNINGS,
        Settings.Default.True
    )
    Settings.CreateCheckbox(category, warningSystemSetting, BeastAndBow.L.OPTIONS_ENABLE_WARNINGS_TOOLTIP)

    -- Show Frame Setting
    local showFrameSetting = Settings.RegisterAddOnSetting(
        category,
        "BEASTANDBOW_SHOW_FRAME",
        "frameVisible",
        BeastAndBow_Settings,
        Settings.VarType.Boolean,
        BeastAndBow.L.OPTIONS_SHOW_FRAME,
        Settings.Default.True
    )
    
    Settings.CreateCheckbox(category, showFrameSetting, BeastAndBow.L.OPTIONS_SHOW_FRAME_TOOLTIP)

    -- Collapse Buttons Setting
    local collapseSetting = Settings.RegisterAddOnSetting(
        category,
        "BEASTANDBOW_COLLAPSE_BUTTONS",
        "collapsed",
        BeastAndBow_Settings,
        Settings.VarType.Boolean,
        BeastAndBow.L.OPTIONS_COLLAPSE_BUTTONS,
        Settings.Default.False
    )
    Settings.CreateCheckbox(category, collapseSetting, BeastAndBow.L.OPTIONS_COLLAPSE_BUTTONS_TOOLTIP)

    -- ========================================================================
    -- DEBUG SUBCATEGORY (mit ▼/▶ ausklappbar)
    -- ========================================================================
    
    -- Erstelle eine Unterkategorie für Debugging
    local debugCategory, debugLayout = Settings.RegisterVerticalLayoutSubcategory(
        category,
        BeastAndBow.L.OPTIONS_DEBUG_SECTION
    )
    
    -- Debug Mode Toggle: Wenn AN = alles zeigen, wenn AUS = Dropdown-Level nutzen
    local debugSetting = Settings.RegisterAddOnSetting(
        debugCategory,
        "BEASTANDBOW_DEBUG_MODE",
        "debug",
        BeastAndBow_Settings,
        Settings.VarType.Boolean,
        BeastAndBow.L.OPTIONS_DEBUG_MODE,
        Settings.Default.False
    )
    Settings.CreateCheckbox(debugCategory, debugSetting, BeastAndBow.L.OPTIONS_DEBUG_MODE_TOOLTIP)
    
    -- Debug Log Level Setting - mit Standard CreateControlTextContainer
    local debugLogLevelSetting = Settings.RegisterAddOnSetting(
        debugCategory,
        "BEASTANDBOW_DEBUG_LOG_LEVEL",
        "debugLogLevel",
        BeastAndBow_Settings,
        Settings.VarType.String,
        BeastAndBow.L.OPTIONS_DEBUG_LOG_LEVEL,
        Settings.Default.String
    )
    
    -- Dropdown mit CreateControlTextContainer für bessere Sichtbarkeit
    local function GetDebugLevelOptions()
        local L = BeastAndBow.L
        local container = Settings.CreateControlTextContainer()
        container:Add("INFO", "|cff00ff00" .. (L.DEBUG_LEVEL_INFO or "INFO - All messages") .. "|r")
        container:Add("WARN", "|cffff9900" .. (L.DEBUG_LEVEL_WARN or "WARN - Warnings and errors") .. "|r")
        container:Add("DEBUG", "|cff0099ff" .. (L.DEBUG_LEVEL_DEBUG or "DEBUG - Verbose output only") .. "|r")
        container:Add("ERROR", "|cffff0000" .. (L.DEBUG_LEVEL_ERROR or "ERROR - Errors only") .. "|r")
        return container:GetData()
    end
    
    Settings.CreateDropdown(debugCategory, debugLogLevelSetting, GetDebugLevelOptions, BeastAndBow.L.OPTIONS_DEBUG_LOG_LEVEL_TOOLTIP)

    -- Register categories
    Settings.RegisterAddOnCategory(category)
end

-- Initialize settings when addon loads
local settingsFrame = CreateFrame("Frame")
settingsFrame:RegisterEvent("ADDON_LOADED")
settingsFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "BeastAndBow" then
        InitializeSettings()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Create a frame that watches for saved variable changes
local watcherFrame = CreateFrame("Frame")
do
    local lastCollapsed = nil
    watcherFrame:SetScript("OnUpdate", function(self)
        local frame = _G["BeastAndBowFrame"]
        if frame then
            if BeastAndBow_Settings.frameVisible and not frame:IsShown() then
                frame:Show()
            elseif not BeastAndBow_Settings.frameVisible and frame:IsShown() then
                frame:Hide()
            end
            -- Only apply collapse state when it actually changes
            if BeastAndBow and BeastAndBow.ApplyCollapseState then
                local current = BeastAndBow_Settings and BeastAndBow_Settings.collapsed
                if current ~= lastCollapsed then
                    lastCollapsed = current
                    BeastAndBow.ApplyCollapseState()
                end
            end
        end
    end)
end