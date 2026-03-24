-- Auto-generated pet name locale mapping (dynamic)
-- Builds an English->Localized mapping from BeastAndBow_locales tables
BeastAndBow = BeastAndBow or {}
BeastAndBow.PetNameLocale = {}

local function BuildPetNameLocale()
    local L = BeastAndBow and BeastAndBow.L or nil
    local en = _G.BeastAndBow_locales and _G.BeastAndBow_locales["enUS"] or nil
    if not L or not en then return end
    if (_G.GetLocale and _G.GetLocale() == "enUS") then return end
    local map = {}
    for key, enName in pairs(en) do
        if type(key) == "string" and key:find("^PET_") and type(enName) == "string" then
            local locName = L[key]
            if type(locName) == "string" and locName ~= enName then
                map[enName] = locName
            end
        end
    end
    BeastAndBow.PetNameLocale = map
end

BuildPetNameLocale()

-- Returns localized pet name for an English input, preserving suffixes
function BeastAndBow.GetLocalizedPetName(englishName)
    if type(englishName) ~= "string" then return englishName end
    local map = BeastAndBow.PetNameLocale or {}
    -- Preserve common suffixes like "(Elite)" or "(Rare)"
    local base, suffix = englishName:match("^(.+)%s+(%b())$")
    if base and map[base] then
        return map[base] .. " " .. suffix
    end
    return map[englishName] or englishName
end