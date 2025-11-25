-- Localization loader: picks the correct localized table from locales/*.lua
-- Each locale file registers its translations into BeastAndBow_locales["<locale>"]

BeastAndBow = BeastAndBow or {}
BeastAndBow_locales = BeastAndBow_locales or {}

local function safeGetLocale()
    if GetLocale then
        local ok, loc = pcall(GetLocale)
        if ok and type(loc) == "string" then
            return loc
        end
    end
    return "enUS"
end

local locale = safeGetLocale()
local L = BeastAndBow_locales[locale]
if not L then
    -- fallback to enUS
    L = BeastAndBow_locales["enUS"] or {}
end

BeastAndBow.L = L

-- optional: expose the detected locale for debugging
BeastAndBow.locale = locale
