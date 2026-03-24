BeastAndBow = BeastAndBow or {}

-- This file handles the logic for the Macro creation helper frame.

-- Initialize a table to store created macros if it doesn't exist
if BeastAndBow_Settings and BeastAndBow_Settings.createdMacros == nil then
    BeastAndBow_Settings.createdMacros = {}
end

-- Frame to hold the dialog widgets
BeastAndBow.MacroNameDialog = nil

BeastAndBow.MacroSpellRefs = {
    SerpentSting = { id = 1978, legacy = "Schlangenbiss" },
    ArcaneShot = { id = 3044, legacy = "Arkaner Schuss" },
    ConcussiveShot = { id = 5116, legacy = "Erschütternder Schuss" },
    MultiShot = { id = 2643, legacy = "Mehrfachschuss" },
    ScorpidSting = { id = 3043, legacy = "Skorpidstich" },
    ViperSting = { id = 3034, legacy = "Vipernbiss" },
    AimedShot = { id = 19434, legacy = "Gezielter Schuss" },
    AutoShot = { id = 75, legacy = "Automatischer Schuss" },
    DismissPet = { id = 2641, legacy = "Tier freigeben" },
    RevivePet = { id = 982, legacy = "Tier wiederbeleben" },
    CallPet = { id = 883, legacy = "Tier rufen" },
    MendPet = { id = 136, legacy = "Tier heilen" },
    FrostTrap = { id = 13809, legacy = "Frostfalle" },
    FreezingTrap = { id = 1499, legacy = "Eiskältefalle" },
    ExplosiveTrap = { id = 13813, legacy = "Sprengfalle" },
    ImmolationTrap = { id = 13795, legacy = "Feuerbrandfalle" },
    SnakeTrap = { id = 34600, legacy = "Schlangenfalle" },
    AspectHawk = { id = 13165, legacy = "Aspekt des Falken" },
    AspectCheetah = { id = 5118, legacy = "Aspekt des Geparden" },
    AspectPack = { id = 13159, legacy = "Aspekt des Rudels" },
    AspectMonkey = { id = 13163, legacy = "Aspekt des Affen" },
    AspectWild = { id = 20043, legacy = "Aspekt der Wildnis" },
    AspectViper = { id = 34074, legacy = "Aspekt der Viper" },
    TrackBeasts = { id = 1494, legacy = "Wildtiere aufspüren" },
    TrackHumanoids = { id = 19883, legacy = "Humanoide aufspüren" },
    TrackDemons = { id = 19878, legacy = "Dämonen aufspüren" },
    TrackUndead = { id = 19884, legacy = "Untote aufspüren" },
    TrackElementals = { id = 19880, legacy = "Elementare aufspüren" },
    TrackGiants = { id = 19882, legacy = "Riesen aufspüren" },
    TrackHidden = { id = 19885, legacy = "Verborgenes aufspüren" },
    TrackDragonkin = { id = 19879, legacy = "Drachkin aufspüren" },
    RaptorStrike = { id = 2973, legacy = "Raptorstoß" },
    MongooseBite = { id = 1495, legacy = "Mungobiss" },
    WingClip = { id = 2974, legacy = "Zurechtstutzen" },
}

local MACRO_STORAGE_ALIASES = {
    PetAttack = {
        ["Schlangenbiss"] = "PET_ATTACK_SERPENT_STING",
        ["Serpent Sting"] = "PET_ATTACK_SERPENT_STING",
        ["Arkaner Schuss"] = "PET_ATTACK_ARCANE_SHOT",
        ["Arcane Shot"] = "PET_ATTACK_ARCANE_SHOT",
        ["Erschütternder Schuss"] = "PET_ATTACK_CONCUSSIVE_SHOT",
        ["Concussive Shot"] = "PET_ATTACK_CONCUSSIVE_SHOT",
        ["Mehrfachschuss"] = "PET_ATTACK_MULTI_SHOT",
        ["Multi-Shot"] = "PET_ATTACK_MULTI_SHOT",
        ["Skorpidstich"] = "PET_ATTACK_SCORPID_STING",
        ["Scorpid Sting"] = "PET_ATTACK_SCORPID_STING",
        ["Vipernbiss"] = "PET_ATTACK_VIPER_STING",
        ["Viper Sting"] = "PET_ATTACK_VIPER_STING",
        ["Gezielter Schuss"] = "PET_ATTACK_AIMED_SHOT",
        ["Aimed Shot"] = "PET_ATTACK_AIMED_SHOT",
        ["Automatischer Schuss"] = "PET_ATTACK_AUTO_SHOT",
        ["Auto Shot"] = "PET_ATTACK_AUTO_SHOT",
        ["PetAtk: Auto"] = "PET_ATTACK_AUTO_SHOT",
    },
}

local function ResolveSpellName(spellRef)
    if type(spellRef) == "table" then
        local spellName = spellRef.id and GetSpellInfo(spellRef.id)
        if spellName and spellName ~= "" then
            return spellName
        end
        if spellRef.name then
            spellName = GetSpellInfo(spellRef.name)
            if spellName and spellName ~= "" then
                return spellName
            end
        end
        return spellRef.legacy or spellRef.name or ""
    end

    if type(spellRef) == "number" then
        return GetSpellInfo(spellRef) or ""
    end

    return GetSpellInfo(spellRef) or spellRef or ""
end

local function NormalizeMacroStorageKey(group, key)
    local groupAliases = MACRO_STORAGE_ALIASES[group]
    if groupAliases and groupAliases[key] then
        return groupAliases[key]
    end
    return key
end

local DEFAULT_DYNAMIC_MACRO_ICON = "INV_MISC_QUESTIONMARK"

function BeastAndBow.GetMacroLocalizedSpellName(spellRef)
    return ResolveSpellName(spellRef)
end

local function SetButtonsEnabled(buttons, enabled)
    for _, button in ipairs(buttons) do
        if button then
            if enabled then
                button:Enable()
            else
                button:Disable()
            end
        end
    end
end

local function MacroUIText(germanText, englishText)
    local locale = (type(GetLocale) == "function" and GetLocale()) or ""
    local isGerman = (locale == "deDE" or locale == "deAT")
    if isGerman then
        return germanText or englishText
    end
    return englishText or germanText
end

local function HideAllMacroPages()
    if BeastAndBowMacrosFramePage1 then BeastAndBowMacrosFramePage1:Hide() end
    if BeastAndBowMacrosFramePage2 then BeastAndBowMacrosFramePage2:Hide() end
    if BeastAndBowMacrosFramePage3 then BeastAndBowMacrosFramePage3:Hide() end
    if BeastAndBowMacrosFramePage4 then BeastAndBowMacrosFramePage4:Hide() end
    if BeastAndBowMacrosFramePage5 then BeastAndBowMacrosFramePage5:Hide() end
    if BeastAndBowMacrosFramePage6 then BeastAndBowMacrosFramePage6:Hide() end
end

local function SetTextIfPresent(globalName, text)
    local widget = _G[globalName]
    if widget and widget.SetText then
        widget:SetText(text)
    end
end

local function AutoFitMacroButton(globalName, minWidth, maxWidth, padding)
    local btn = _G[globalName]
    if not btn or not btn.GetFontString or not btn.SetWidth then
        return
    end

    local fs = btn:GetFontString()
    if not fs then
        return
    end

    local textWidth = 0
    if fs.GetUnboundedStringWidth then
        textWidth = fs:GetUnboundedStringWidth() or 0
    elseif fs.GetStringWidth then
        textWidth = fs:GetStringWidth() or 0
    end

    local width = math.ceil(textWidth + (padding or 28))
    if width < (minWidth or 220) then
        width = minWidth or 220
    end
    if width > (maxWidth or 340) then
        width = maxWidth or 340
    end

    btn:SetWidth(width)
end

local function AutoFitMacroPageButtons(pagePrefix, count, minWidth, maxWidth, padding)
    for i = 1, count do
        AutoFitMacroButton(pagePrefix .. "Macro" .. i .. "Button", minWidth, maxWidth, padding)
    end
end

local function ShortMacroLabel(spellKey)
    local names = {
        AspectHawk = { "Falken", "Hawk" },
        AspectCheetah = { "Geparden", "Cheetah" },
        AspectPack = { "Rudels", "Pack" },
        AspectMonkey = { "Affen", "Monkey" },
        AspectWild = { "Wildnis", "Wild" },
        AspectViper = { "Viper", "Viper" },
        TrackBeasts = { "Wildtiere", "Beasts" },
        TrackHumanoids = { "Humanoide", "Humanoids" },
        TrackDemons = { "Dämonen", "Demons" },
        TrackUndead = { "Untote", "Undead" },
        TrackElementals = { "Elementare", "Elementals" },
        TrackGiants = { "Riesen", "Giants" },
        TrackHidden = { "Verborgenes", "Hidden" },
        TrackDragonkin = { "Drachkin", "Dragonkin" },
        FrostTrap = { "Frost", "Frost" },
        FreezingTrap = { "Eiskälte", "Freezing" },
        ExplosiveTrap = { "Spreng", "Explosive" },
        ImmolationTrap = { "Feuerbrand", "Immolation" },
        SnakeTrap = { "Schlange", "Snake" },
        RaptorStrike = { "Raptorstoß", "Raptor Strike" },
        MongooseBite = { "Mungo", "Mongoose" },
        WingClip = { "Zurechtst", "Wing Clip" },
    }
    local pair = names[spellKey]
    if pair then
        return MacroUIText(pair[1], pair[2])
    end
    return ResolveSpellName(BeastAndBow.MacroSpellRefs[spellKey])
end

function BeastAndBow.UpdateMacroUIStrings()
    local dismissPet = ResolveSpellName(BeastAndBow.MacroSpellRefs.DismissPet)

    SetTextIfPresent("BeastAndBowMacrosFrameWelcomeText", MacroUIText(
        "Willkommen bei den Jäger-Makros. Hier findest du praktische Makros, die dir vieles erleichtern.",
        "Welcome to the hunter macros. Here you will find practical macros that make many things easier."
    ))
    SetTextIfPresent("BeastAndBowMacrosFrameShowMacrosButton", MacroUIText("Zeige mir die Makros", "Show Me the Macros"))
    SetTextIfPresent("BeastAndBowMacrosFrameDoNotShowAgainText", MacroUIText("Diese Seite nicht mehr anzeigen", "Do not show this page again"))
    SetTextIfPresent("BeastAndBowMacrosFramePage1MacrosIntroText", MacroUIText(
        "Hier findest du Makros für Pet-Angriff. Klicke auf einen Button, um das Makro zu erstellen.",
        "Here you will find macros for pet attack. Click a button to create the macro."
    ))

    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro1Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.SerpentSting))
    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro2Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ArcaneShot))
    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro3Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ConcussiveShot))
    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro4Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MultiShot))
    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro5Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ScorpidSting))
    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro6Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ViperSting))
    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro7Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.AimedShot))
    SetTextIfPresent("BeastAndBowMacrosFramePage1Macro8Button", "Pet Attack: " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.AutoShot))
    SetTextIfPresent("BeastAndBowMacrosFramePage1DeleteAllButton", MacroUIText("Lösche PetAttack-Makros", "Delete Pet Attack Macros"))
    SetTextIfPresent("BeastAndBowMacrosFramePage1NextPageButton", MacroUIText("Weiter", "Next"))

    SetTextIfPresent("BeastAndBowMacrosFramePage2Page2Title", MacroUIText(
        "Tier-Management: Wähle die passende Makro-Variante für deine Bedürfnisse.",
        "Pet management: Choose the macro variant that fits your needs."
    ))
    SetTextIfPresent("BeastAndBowMacrosFramePage2Page2Subtitle", MacroUIText(
        "Nur Heilen/Wiederbeleben (ruft das Tier NICHT):",
        "Heal/Revive only (does NOT call the pet):"
    ))
    SetTextIfPresent("BeastAndBowMacrosFramePage2Page2Subtitle2", MacroUIText(
        "Heilen/Wiederbeleben/Rufen (ruft das Tier, wenn es weg ist):",
        "Heal/Revive/Call (calls the pet if it is missing):"
    ))
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro11Button", MacroUIText("Heilen/Wiederbeleben", "Heal/Revive"))
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro12Button", MacroUIText("+ Shift: ", "+ Shift: ") .. dismissPet)
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro13Button", MacroUIText("+ Strg: ", "+ Ctrl: ") .. dismissPet)
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro14Button", MacroUIText("+ Alt: ", "+ Alt: ") .. dismissPet)
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro15Button", MacroUIText("Heilen/Wiederb./Rufen", "Heal/Revive/Call"))
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro8Button", MacroUIText("+ Shift: ", "+ Shift: ") .. dismissPet)
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro9Button", MacroUIText("+ Strg: ", "+ Ctrl: ") .. dismissPet)
    SetTextIfPresent("BeastAndBowMacrosFramePage2Macro10Button", MacroUIText("+ Alt: ", "+ Alt: ") .. dismissPet)
    SetTextIfPresent("BeastAndBowMacrosFramePage2DeleteAllAIOButton", MacroUIText("Lösche Tier-Management-Makros", "Delete Pet Management Macros"))
    SetTextIfPresent("BeastAndBowMacrosFramePage2BackButton", MacroUIText("Zurück", "Back"))
    SetTextIfPresent("BeastAndBowMacrosFramePage2NextPage2Button", MacroUIText("Weiter", "Next"))

    SetTextIfPresent("BeastAndBowMacrosFramePage3Page3Title", MacroUIText(
        "Fallen-Makros: Verschiedene Kombinationen mit Modifiern.",
        "Trap macros: Different combinations with modifiers."
    ))
    SetTextIfPresent("BeastAndBowMacrosFramePage3Macro1Button", ShortMacroLabel("FreezingTrap") .. " + " .. ShortMacroLabel("FrostTrap") .. " (Shift)")
    SetTextIfPresent("BeastAndBowMacrosFramePage3Macro2Button", ShortMacroLabel("ImmolationTrap") .. " + " .. ShortMacroLabel("ExplosiveTrap") .. " (Shift)")
    SetTextIfPresent("BeastAndBowMacrosFramePage3Macro3Button", ShortMacroLabel("FreezingTrap") .. " + " .. ShortMacroLabel("SnakeTrap") .. " (Shift)")
    SetTextIfPresent("BeastAndBowMacrosFramePage3Macro4Button", ShortMacroLabel("ImmolationTrap") .. " + " .. ShortMacroLabel("SnakeTrap") .. " (Shift)")
    SetTextIfPresent("BeastAndBowMacrosFramePage3Macro5Button", ShortMacroLabel("FreezingTrap") .. " + " .. ShortMacroLabel("ImmolationTrap") .. " (Shift)")
    SetTextIfPresent("BeastAndBowMacrosFramePage3Macro6Button", MacroUIText("Alle 4 Standard", "All 4 Standard"))
    SetTextIfPresent("BeastAndBowMacrosFramePage3Macro7Button", MacroUIText("Mit Schlange-Variante", "With Snake Variant"))
    SetTextIfPresent("BeastAndBowMacrosFramePage3DeleteAllTrapsButton", MacroUIText("Lösche Fallen-Makros", "Delete Trap Macros"))
    SetTextIfPresent("BeastAndBowMacrosFramePage3Page3BackButton", MacroUIText("Zurück", "Back"))
    SetTextIfPresent("BeastAndBowMacrosFramePage3Page3NextButton", MacroUIText("Weiter", "Next"))

    SetTextIfPresent("BeastAndBowMacrosFramePage4Page4Title", MacroUIText(
        "Aspekt-Kombos: Unterschiedliche Varianten für alle Situationen.",
        "Aspect combos: Different variants for every situation."
    ))
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro1Button", ShortMacroLabel("AspectHawk") .. " (Shift: " .. ShortMacroLabel("AspectCheetah") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro2Button", ShortMacroLabel("AspectPack") .. " (Shift: " .. ShortMacroLabel("AspectCheetah") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro3Button", ShortMacroLabel("AspectHawk") .. " (Shift: " .. ShortMacroLabel("AspectMonkey") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro4Button", ShortMacroLabel("AspectWild") .. " (Shift: " .. ShortMacroLabel("AspectViper") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro5Button", ShortMacroLabel("AspectHawk") .. " (Shift: " .. ShortMacroLabel("AspectViper") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro6Button", ShortMacroLabel("AspectCheetah") .. " (" .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("AspectViper") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro7Button", ShortMacroLabel("AspectPack") .. " (Shift: " .. ShortMacroLabel("AspectViper") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro8Button", ShortMacroLabel("AspectMonkey") .. " (Shift: " .. ShortMacroLabel("AspectViper") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro9Button", ShortMacroLabel("AspectWild") .. " (Shift: " .. ShortMacroLabel("AspectCheetah") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4Macro10Button", ShortMacroLabel("AspectWild") .. " (Shift: " .. ShortMacroLabel("AspectMonkey") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage4DeleteAllAspectsButton", MacroUIText("Lösche Aspekt-Makros", "Delete Aspect Macros"))
    SetTextIfPresent("BeastAndBowMacrosFramePage4Page4BackButton", MacroUIText("Zurück", "Back"))
    SetTextIfPresent("BeastAndBowMacrosFramePage4Page4NextButton", MacroUIText("Weiter", "Next"))

    SetTextIfPresent("BeastAndBowMacrosFramePage5Page5Title", MacroUIText(
        "Tracking-Kombos: Verschiedene Spurenfähigkeits-Kombinationen.",
        "Tracking combos: Different tracking ability combinations."
    ))
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro1Button", ShortMacroLabel("TrackBeasts") .. " (Shift: " .. ShortMacroLabel("TrackHumanoids") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro2Button", ShortMacroLabel("TrackBeasts") .. " (Shift: " .. ShortMacroLabel("TrackDemons") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro3Button", ShortMacroLabel("TrackHumanoids") .. " (Shift: " .. ShortMacroLabel("TrackUndead") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro4Button", ShortMacroLabel("TrackElementals") .. " (Shift: " .. ShortMacroLabel("TrackGiants") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro5Button", ShortMacroLabel("TrackHidden") .. " (Shift: " .. ShortMacroLabel("TrackDragonkin") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro6Button", ShortMacroLabel("TrackDemons") .. " (Shift: " .. ShortMacroLabel("TrackUndead") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro7Button", ShortMacroLabel("TrackHumanoids") .. " (" .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("TrackDemons") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5Macro8Button", ShortMacroLabel("TrackElementals") .. " (Shift: " .. ShortMacroLabel("TrackDragonkin") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage5DeleteAllTrackingButton", MacroUIText("Lösche Tracking-Makros", "Delete Tracking Macros"))
    SetTextIfPresent("BeastAndBowMacrosFramePage5Page5BackButton", MacroUIText("Zurück", "Back"))
    SetTextIfPresent("BeastAndBowMacrosFramePage5Page5NextButton", MacroUIText("Weiter", "Next"))

    SetTextIfPresent("BeastAndBowMacrosFramePage6Page6Title", MacroUIText(
        "Melee-Kombos: Raptorstoß, Mungobiss und Zurechtstutzen Kombinationen.",
        "Melee combos: Raptor Strike, Mongoose Bite and Wing Clip combinations."
    ))
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro1Button", ShortMacroLabel("RaptorStrike") .. " (Shift: " .. ShortMacroLabel("MongooseBite") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("WingClip") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro2Button", ShortMacroLabel("RaptorStrike") .. " (Shift: " .. ShortMacroLabel("WingClip") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("MongooseBite") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro3Button", ShortMacroLabel("MongooseBite") .. " (Shift: " .. ShortMacroLabel("RaptorStrike") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("WingClip") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro4Button", ShortMacroLabel("MongooseBite") .. " (Shift: " .. ShortMacroLabel("WingClip") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("RaptorStrike") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro5Button", ShortMacroLabel("WingClip") .. " (Shift: " .. ShortMacroLabel("RaptorStrike") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("MongooseBite") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro6Button", ShortMacroLabel("WingClip") .. " (Shift: " .. ShortMacroLabel("MongooseBite") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("RaptorStrike") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro7Button", ShortMacroLabel("RaptorStrike") .. " (Shift: " .. ShortMacroLabel("MongooseBite") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("MongooseBite") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6Macro8Button", ShortMacroLabel("MongooseBite") .. " (Shift: " .. ShortMacroLabel("RaptorStrike") .. " / " .. MacroUIText("Strg", "Ctrl") .. ": " .. ShortMacroLabel("RaptorStrike") .. ")")
    SetTextIfPresent("BeastAndBowMacrosFramePage6DeleteAllMeleeButton", MacroUIText("Lösche Melee-Makros", "Delete Melee Macros"))
    SetTextIfPresent("BeastAndBowMacrosFramePage6Page6BackButton", MacroUIText("Zurück", "Back"))

    -- Prevent text overlap with delete buttons on combo pages
    AutoFitMacroPageButtons("BeastAndBowMacrosFramePage1", 8, 220, 320, 28)
    AutoFitMacroPageButtons("BeastAndBowMacrosFramePage2", 15, 200, 320, 28)
    AutoFitMacroPageButtons("BeastAndBowMacrosFramePage3", 7, 220, 320, 28)
    AutoFitMacroPageButtons("BeastAndBowMacrosFramePage4", 10, 240, 340, 32)
    AutoFitMacroPageButtons("BeastAndBowMacrosFramePage5", 8, 240, 340, 32)
    AutoFitMacroPageButtons("BeastAndBowMacrosFramePage6", 8, 250, 350, 36)
end

local function SetTBCTrapButtonsEnabled(enabled)
    SetButtonsEnabled({
        BeastAndBowMacrosFramePage3Macro3Button,
        BeastAndBowMacrosFramePage3Macro3DeleteButton,
        BeastAndBowMacrosFramePage3Macro4Button,
        BeastAndBowMacrosFramePage3Macro4DeleteButton,
        BeastAndBowMacrosFramePage3Macro7Button,
        BeastAndBowMacrosFramePage3Macro7DeleteButton,
    }, enabled)
end

local function SetTBCAspectButtonsEnabled(enabled)
    SetButtonsEnabled({
        BeastAndBowMacrosFramePage4Macro4Button,
        BeastAndBowMacrosFramePage4Macro4DeleteButton,
        BeastAndBowMacrosFramePage4Macro5Button,
        BeastAndBowMacrosFramePage4Macro5DeleteButton,
        BeastAndBowMacrosFramePage4Macro6Button,
        BeastAndBowMacrosFramePage4Macro6DeleteButton,
        BeastAndBowMacrosFramePage4Macro7Button,
        BeastAndBowMacrosFramePage4Macro7DeleteButton,
        BeastAndBowMacrosFramePage4Macro8Button,
        BeastAndBowMacrosFramePage4Macro8DeleteButton,
    }, enabled)
end

function BeastAndBow.ToggleShowMacroWelcome(checked)
    if BeastAndBow_Settings then
        BeastAndBow_Settings.showMacroWelcome = not checked
    end
end

function BeastAndBow.OnMacroFrameShow()
    BeastAndBow.UpdateMacroUIStrings()
    if BeastAndBow_Settings and BeastAndBow_Settings.showMacroWelcome == nil then
        BeastAndBow_Settings.showMacroWelcome = true
    end
    if BeastAndBow_Settings and BeastAndBow_Settings.showMacroWelcome == false then
        BeastAndBow.ShowMacrosList()
    else
        BeastAndBow.ShowWelcomeView()
    end
end

function BeastAndBow.ShowWelcomeView()
    BeastAndBowMacrosFrameWelcomeText:Show()
    BeastAndBowMacrosFrameShowMacrosButton:Show()
    BeastAndBowMacrosFrameDoNotShowAgain:Show()
    HideAllMacroPages()
    if BeastAndBow_Settings then
        BeastAndBowMacrosFrameDoNotShowAgain:SetChecked(not BeastAndBow_Settings.showMacroWelcome)
    end
end

function BeastAndBow.OpenMacros() 
    if BeastAndBowMacrosFrame:IsShown() then
        HideUIPanel(BeastAndBowMacrosFrame)
    else
        ShowUIPanel(BeastAndBowMacrosFrame)
    end
end

function BeastAndBow.ShowMacrosList() 
    BeastAndBowMacrosFrameWelcomeText:Hide()
    BeastAndBowMacrosFrameShowMacrosButton:Hide()
    BeastAndBowMacrosFrameDoNotShowAgain:Hide()
    HideAllMacroPages()
    BeastAndBowMacrosFramePage1:Show()
    local macro7Button = _G["BeastAndBowMacrosFramePage1Macro7Button"]
    local macro7DeleteButton = _G["BeastAndBowMacrosFramePage1Macro7DeleteButton"]
    if macro7Button and macro7DeleteButton then
        if GetSpellInfo(BeastAndBow.MacroSpellRefs.AimedShot.id) then
            macro7Button:Enable()
            macro7DeleteButton:Enable()
        else
            macro7Button:Disable()
            macro7DeleteButton:Disable()
        end
    end
end

function BeastAndBow.ShowMacroPage2()
    HideAllMacroPages()
    BeastAndBowMacrosFramePage2:Show()
end

function BeastAndBow.ShowMacroPage3()
    HideAllMacroPages()
    if BeastAndBowMacrosFramePage3 then 
        BeastAndBowMacrosFramePage3:Show()

        -- Enable/Disable Frost trap combo based on spell availability
        if BeastAndBowMacrosFramePage3Macro1Button and BeastAndBowMacrosFramePage3Macro1DeleteButton then
            if GetSpellInfo(BeastAndBow.MacroSpellRefs.FrostTrap.id) then
                BeastAndBowMacrosFramePage3Macro1Button:Enable()
                BeastAndBowMacrosFramePage3Macro1DeleteButton:Enable()
            else
                BeastAndBowMacrosFramePage3Macro1Button:Disable()
                BeastAndBowMacrosFramePage3Macro1DeleteButton:Disable()
            end
        end
        SetTBCTrapButtonsEnabled(false)
    end
end

function BeastAndBow.ShowMacroPage4()
    HideAllMacroPages()
    if BeastAndBowMacrosFramePage4 then BeastAndBowMacrosFramePage4:Show() end
    SetTBCAspectButtonsEnabled(false)
end

function BeastAndBow.ShowMacroPage5()
    HideAllMacroPages()
    if BeastAndBowMacrosFramePage5 then BeastAndBowMacrosFramePage5:Show() end
end

function BeastAndBow.ShowMacroPage6()
    HideAllMacroPages()
    if BeastAndBowMacrosFramePage6 then BeastAndBowMacrosFramePage6:Show() end
end

-- Refactored macro creation function
local function CreateHunterMacro(macroName, spellRef, icon, perCharacter)
    local spellName = ResolveSpellName(spellRef)
    local body = "#showtooltip " .. spellName .. "\n/petattack\n/cast " .. spellName
    local macroIcon = icon or DEFAULT_DYNAMIC_MACRO_ICON
    local _, _, spellIconTexture = GetSpellInfo(spellName)
    if spellIconTexture then
        macroIcon = spellIconTexture
    end
    local isPerCharacter = (perCharacter == nil) and true or perCharacter
    local success, err = pcall(CreateMacro, macroName, macroIcon, body, isPerCharacter)
    if success then
        print(string.format(MacroUIText("Makro '%s' wurde erstellt.", "Macro '%s' was created."), macroName))
    else
        print(string.format(MacroUIText("FEHLER beim Erstellen von Makro '%s': %s", "ERROR creating macro '%s': %s"), macroName, err))
    end
    return success
end

-- Helper to style a dialog button
local function SanitizeDialogButton(button)
    if not button then return end
    local left = button:GetRegions()
    if left and left.Hide then left:Hide() end
    local right = select(2, button:GetRegions())
    if right and right.Hide then right:Hide() end
    local middle = select(3, button:GetRegions())
    if middle and middle.Hide then middle:Hide() end
    button:SetNormalTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
    button:SetPushedTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
    button:SetHighlightTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
    local hTex = button:GetHighlightTexture()
    if hTex then
        hTex:SetBlendMode("ADD")
    end
end

-- Helper to generate a unique macro name by appending a number if needed
local function GetUniqueMacroName(baseName)
    local index, _ = GetMacroIndexByName(baseName)
    if not index or index == 0 then
        return baseName  -- Name doesn't exist, use as-is
    end
    -- Name exists, try appending numbers
    local counter = 2
    while counter <= 255 do
        local newName = baseName .. " " .. counter
        index, _ = GetMacroIndexByName(newName)
        if not index or index == 0 then
            return newName  -- Found a unique name
        end
        counter = counter + 1
    end
    return baseName  -- Fallback (shouldn't happen)
end

-- Function to show the name input dialog
function BeastAndBow.ShowNameInputDialog(defaultName, spellRef, icon, group, storageKey)
    if not BeastAndBow.MacroNameDialog then
        local dialog = CreateFrame("Frame", "BBMacroNameDialog", UIParent)
        dialog:SetSize(320, 145)
        dialog:SetPoint("CENTER")
        local bg = dialog:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\background.tga")
        bg:SetAllPoints(dialog)
        dialog.background = bg
        dialog:SetFrameStrata("DIALOG")
        dialog:EnableMouse(true)
        dialog:SetMovable(true)
        dialog:RegisterForDrag("LeftButton")
        dialog:SetScript("OnDragStart", function(self) self:StartMoving() end)
        dialog:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        local title = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        title:SetPoint("TOP", 0, -12)
        title:SetText(MacroUIText("Makronamen eingeben", "Enter macro name"))
        local helpText = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        helpText:SetPoint("TOP", title, "BOTTOM", 0, -4)
        helpText:SetText(MacroUIText("Dieses Makro wird unter 'Charakterspezifische Makros' gespeichert.", "This macro will be saved under 'Character-Specific Macros'."))
        helpText:SetTextColor(0.9, 0.9, 0.1) -- Yellow
        local editBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
        editBox:SetSize(220, 32)
        editBox:SetPoint("TOP", helpText, "BOTTOM", 0, -8)
        editBox:SetAutoFocus(true)
        dialog.editBox = editBox
        local okButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
        okButton:SetSize(120, 24)
        okButton:SetPoint("BOTTOMLEFT", 20, 16)
        okButton:SetText(MacroUIText("Erstellen", "Create"))
        SanitizeDialogButton(okButton)
        dialog.okButton = okButton
        local cancelButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
        cancelButton:SetSize(120, 24)
        cancelButton:SetPoint("BOTTOMRIGHT", -20, 16)
        cancelButton:SetText(MacroUIText("Abbrechen", "Cancel"))
        SanitizeDialogButton(cancelButton)
        dialog.cancelButton = cancelButton
        BeastAndBow.MacroNameDialog = dialog
    end
    local dialog = BeastAndBow.MacroNameDialog
    dialog.editBox:SetText(defaultName or "")
    dialog.editBox:HighlightText()

    dialog.okButton:SetScript("OnClick", function()
        local macroName = dialog.editBox:GetText()
        if macroName and macroName ~= "" then
            -- Generate unique name if needed
            macroName = GetUniqueMacroName(macroName)
            if CreateHunterMacro(macroName, spellRef, icon, true) then
                if group then
                    BeastAndBow_Settings = BeastAndBow_Settings or {}
                    BeastAndBow_Settings.createdMacros = BeastAndBow_Settings.createdMacros or {}
                    BeastAndBow_Settings.createdMacros[group] = BeastAndBow_Settings.createdMacros[group] or {}

                    -- Check for old format (numeric index) vs new format (string index)
                    local isOldFormat = false
                    if BeastAndBow_Settings.createdMacros[group] then
                        for k, _ in pairs(BeastAndBow_Settings.createdMacros[group]) do
                            if type(k) == "number" then
                                isOldFormat = true
                                break
                            end
                        end
                    end

                    if isOldFormat then
                        print(MacroUIText("Beast & Bow: Veraltetes Makro-Speicherformat erkannt. Bitte benutze 'Lösche PetAttack-Makros', um alle Makros dieser Gruppe zu entfernen. Danach kannst du sie neu erstellen und das Einzellöschen wird korrekt funktionieren.", "Beast & Bow: Legacy macro storage format detected. Please use 'Delete Pet Attack Macros' to remove all macros in this group, then recreate them so single-delete works correctly."))
                        table.insert(BeastAndBow_Settings.createdMacros[group], macroName)
                    else
                        local key = NormalizeMacroStorageKey(group, storageKey or ResolveSpellName(spellRef))
                        BeastAndBow_Settings.createdMacros[group][key] = macroName
                    end
                end
                dialog:Hide()
            end
        else
            print(MacroUIText("Bitte gib einen gültigen Makronamen ein.", "Please enter a valid macro name."))
        end
    end)

    dialog.cancelButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    dialog:Show()
end

-- Updated functions to call the dialog with a group identifier
function BeastAndBow.CreateMacro1() 
    BeastAndBow.ShowNameInputDialog("PetAtk: SSL", BeastAndBow.MacroSpellRefs.SerpentSting, nil, "PetAttack", "PET_ATTACK_SERPENT_STING")
end

function BeastAndBow.CreateMacro2() 
    BeastAndBow.ShowNameInputDialog("PetAtk: AS", BeastAndBow.MacroSpellRefs.ArcaneShot, nil, "PetAttack", "PET_ATTACK_ARCANE_SHOT")
end

function BeastAndBow.CreateMacro3() 
    BeastAndBow.ShowNameInputDialog("PetAtk: ESS", BeastAndBow.MacroSpellRefs.ConcussiveShot, nil, "PetAttack", "PET_ATTACK_CONCUSSIVE_SHOT")
end

function BeastAndBow.CreateMacro4() 
    BeastAndBow.ShowNameInputDialog("PetAtk: MS", BeastAndBow.MacroSpellRefs.MultiShot, nil, "PetAttack", "PET_ATTACK_MULTI_SHOT")
end

function BeastAndBow.CreateMacro5() 
    BeastAndBow.ShowNameInputDialog("PetAtk: Skorpid", BeastAndBow.MacroSpellRefs.ScorpidSting, nil, "PetAttack", "PET_ATTACK_SCORPID_STING")
end

function BeastAndBow.CreateMacro6() 
    BeastAndBow.ShowNameInputDialog("PetAtk: Viper", BeastAndBow.MacroSpellRefs.ViperSting, nil, "PetAttack", "PET_ATTACK_VIPER_STING")
end

function BeastAndBow.CreateMacro7() 
    BeastAndBow.ShowNameInputDialog("PetAtk: Aimed", BeastAndBow.MacroSpellRefs.AimedShot, nil, "PetAttack", "PET_ATTACK_AIMED_SHOT")
end

function BeastAndBow.CreateMacro16()
    local autoShot = ResolveSpellName(BeastAndBow.MacroSpellRefs.AutoShot)
    local body = "/petattack\n/cast !" .. autoShot
    BeastAndBow.ShowNameInputDialogForBody("PetAtk: Auto", body, BeastAndBow.MacroSpellRefs.AutoShot, nil, "PetAttack", "PET_ATTACK_AUTO_SHOT")
end

function BeastAndBow.ShowNameInputDialogForBody(defaultName, macroBody, tooltipSpell, icon, group, storageKey, preferDynamicTooltip)
    if not BeastAndBow.MacroNameDialog then
        local dialog = CreateFrame("Frame", "BBMacroNameDialog", UIParent)
        dialog:SetSize(320, 145)
        dialog:SetPoint("CENTER")
        local bg = dialog:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\background.tga")
        bg:SetAllPoints(dialog)
        dialog.background = bg
        dialog:SetFrameStrata("DIALOG")
        dialog:EnableMouse(true)
        dialog:SetMovable(true)
        dialog:RegisterForDrag("LeftButton")
        dialog:SetScript("OnDragStart", function(self) self:StartMoving() end)
        dialog:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        local title = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        title:SetPoint("TOP", 0, -12)
        title:SetText(MacroUIText("Makronamen eingeben", "Enter macro name"))
        local helpText = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        helpText:SetPoint("TOP", title, "BOTTOM", 0, -4)
        helpText:SetText(MacroUIText("Dieses Makro wird unter 'Charakterspezifische Makros' gespeichert.", "This macro will be saved under 'Character-Specific Macros'."))
        helpText:SetTextColor(0.9, 0.9, 0.1) -- Yellow
        local editBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
        editBox:SetSize(220, 32)
        editBox:SetPoint("TOP", helpText, "BOTTOM", 0, -8)
        editBox:SetAutoFocus(true)
        dialog.editBox = editBox
        local okButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
        okButton:SetSize(120, 24)
        okButton:SetPoint("BOTTOMLEFT", 20, 16)
        okButton:SetText(MacroUIText("Erstellen", "Create"))
        SanitizeDialogButton(okButton)
        dialog.okButton = okButton
        local cancelButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
        cancelButton:SetSize(120, 24)
        cancelButton:SetPoint("BOTTOMRIGHT", -20, 16)
        cancelButton:SetText(MacroUIText("Abbrechen", "Cancel"))
        SanitizeDialogButton(cancelButton)
        dialog.cancelButton = cancelButton
        BeastAndBow.MacroNameDialog = dialog
    end

    local dialog = BeastAndBow.MacroNameDialog
    dialog.editBox:SetText(defaultName or "")
    dialog.editBox:HighlightText()

    dialog.okButton:SetScript("OnClick", function()
        local macroName = dialog.editBox:GetText()
        if macroName and macroName ~= "" then
            -- Generate unique name if needed
            macroName = GetUniqueMacroName(macroName)
            local useDynamicTooltip = preferDynamicTooltip == true
            local macroIcon = icon or DEFAULT_DYNAMIC_MACRO_ICON
            local tooltipSpellName = tooltipSpell and ResolveSpellName(tooltipSpell) or nil
            if useDynamicTooltip then
                macroIcon = DEFAULT_DYNAMIC_MACRO_ICON
            elseif tooltipSpellName then
                local _, _, spellIconTexture = GetSpellInfo(tooltipSpellName)
                if spellIconTexture then
                    macroIcon = spellIconTexture
                end
            end
            local showTooltipLine
            if useDynamicTooltip then
                showTooltipLine = "#showtooltip"
            else
                showTooltipLine = "#showtooltip " .. (tooltipSpellName or "")
            end
            local fullBody = showTooltipLine .. "\n" .. macroBody
            local success, err = pcall(CreateMacro, macroName, macroIcon, fullBody, true)

            if success then
                print(string.format(MacroUIText("Makro '%s' wurde erstellt.", "Macro '%s' was created."), macroName))
                if group then
                    BeastAndBow_Settings = BeastAndBow_Settings or {}
                    BeastAndBow_Settings.createdMacros = BeastAndBow_Settings.createdMacros or {}
                    BeastAndBow_Settings.createdMacros[group] = BeastAndBow_Settings.createdMacros[group] or {}
                    local key = NormalizeMacroStorageKey(group, storageKey or defaultName)
                    BeastAndBow_Settings.createdMacros[group][key] = macroName
                end
                dialog:Hide()
            else
                print(string.format(MacroUIText("FEHLER beim Erstellen von Makro '%s': %s", "ERROR creating macro '%s': %s"), macroName, err))
            end
        else
            print(MacroUIText("Bitte gib einen gültigen Makronamen ein.", "Please enter a valid macro name."))
        end
    end)

    dialog.cancelButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    dialog:Show()
end

function BeastAndBow.CreateMacro8() 
    local body = "/cast [mod:shift] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.DismissPet) .. "; [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; [nopet] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.CallPet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody("B&B AIO (Shift)", body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

function BeastAndBow.CreateMacro9() 
    local body = "/cast [mod:ctrl] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.DismissPet) .. "; [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; [nopet] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.CallPet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody("B&B AIO (Ctrl)", body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

function BeastAndBow.CreateMacro10() 
    local body = "/cast [mod:alt] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.DismissPet) .. "; [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; [nopet] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.CallPet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody("B&B AIO (Alt)", body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

-- New: Heal/Revive only (no Call Pet, no Dismiss)
function BeastAndBow.CreateMacro11() 
    local body = "/cast [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Heilen/Wiederbeleben", "Heal/Revive"), body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

-- New: Heal/Revive with Shift->Dismiss
function BeastAndBow.CreateMacro12() 
    local body = "/cast [mod:shift] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.DismissPet) .. "; [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Heilen/Wiederb. (Shift->Freigeben)", "Heal/Revive (Shift->Dismiss)"), body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

-- New: Heal/Revive with Ctrl->Dismiss
function BeastAndBow.CreateMacro13() 
    local body = "/cast [mod:ctrl] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.DismissPet) .. "; [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Heilen/Wiederb. (Strg->Freigeben)", "Heal/Revive (Ctrl->Dismiss)"), body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

-- New: Heal/Revive with Alt->Dismiss
function BeastAndBow.CreateMacro14() 
    local body = "/cast [mod:alt] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.DismissPet) .. "; [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Heilen/Wiederb. (Alt->Freigeben)", "Heal/Revive (Alt->Dismiss)"), body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

-- New: Heal/Revive/Call (no Dismiss)
function BeastAndBow.CreateMacro15() 
    local body = "/cast [target=pet, dead] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.RevivePet) .. "; [nopet] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.CallPet) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.MendPet)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Heilen/Wiederb./Rufen", "Heal/Revive/Call"), body, BeastAndBow.MacroSpellRefs.MendPet, nil, "AllInOne")
end

-- Trap macros (Page 3)
function BeastAndBow.CreateTrapMacroCombo1()
    local body = "/cast [mod:shift] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.FrostTrap) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.FreezingTrap)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Fallen: Eiskälte+Frost", "Traps: Freezing+Frost"), body, BeastAndBow.MacroSpellRefs.FreezingTrap, nil, "Traps", nil, true)
end

function BeastAndBow.CreateTrapMacroCombo2()
    local body = "/cast [mod:shift] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ExplosiveTrap) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ImmolationTrap)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Fallen: Feuerbrand+Spreng", "Traps: Immolation+Explosive"), body, BeastAndBow.MacroSpellRefs.ImmolationTrap, nil, "Traps", nil, true)
end

function BeastAndBow.CreateTrapMacroCombo5()
    local body = "/cast [mod:shift] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ImmolationTrap) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.FreezingTrap)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Fallen: Eiskälte+Feuerbrand", "Traps: Freezing+Immolation"), body, BeastAndBow.MacroSpellRefs.FreezingTrap, nil, "Traps", nil, true)
end

function BeastAndBow.CreateTrapMacroAll4()
    local body = "/cast [mod:shift] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.FrostTrap) .. "; [mod:ctrl] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ImmolationTrap) .. "; [mod:alt] " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.ExplosiveTrap) .. "; " .. ResolveSpellName(BeastAndBow.MacroSpellRefs.FreezingTrap)
    BeastAndBow.ShowNameInputDialogForBody(MacroUIText("Fallen: Alle 4 Standard", "Traps: All 4 Standard"), body, BeastAndBow.MacroSpellRefs.FreezingTrap, nil, "Traps", nil, true)
end

-- Aspect macros (Page 4)
local function CreateAspectComboMacro(defaultName, primaryAspect, modifierAspect, modifier)
    local key = modifier or "shift"
    local body = "/cast [mod:" .. key .. "] " .. ResolveSpellName(modifierAspect) .. "; " .. ResolveSpellName(primaryAspect)
    BeastAndBow.ShowNameInputDialogForBody(defaultName, body, primaryAspect, nil, "Aspects", nil, true)
end

function BeastAndBow.CreateAspectMacro1()
    CreateAspectComboMacro(MacroUIText("Aspekt-Kombo: Falken/Geparden", "Aspect Combo: Hawk/Cheetah"), BeastAndBow.MacroSpellRefs.AspectHawk, BeastAndBow.MacroSpellRefs.AspectCheetah, "shift")
end

function BeastAndBow.CreateAspectMacro2()
    CreateAspectComboMacro(MacroUIText("Aspekt-Kombo: Rudels/Geparden", "Aspect Combo: Pack/Cheetah"), BeastAndBow.MacroSpellRefs.AspectPack, BeastAndBow.MacroSpellRefs.AspectCheetah, "shift")
end

function BeastAndBow.CreateAspectMacro3()
    CreateAspectComboMacro(MacroUIText("Aspekt-Kombo: Falken/Affen", "Aspect Combo: Hawk/Monkey"), BeastAndBow.MacroSpellRefs.AspectHawk, BeastAndBow.MacroSpellRefs.AspectMonkey, "shift")
end

function BeastAndBow.CreateAspectMacro9()
    CreateAspectComboMacro(MacroUIText("Aspekt-Kombo: Wildnis/Geparden", "Aspect Combo: Wild/Cheetah"), BeastAndBow.MacroSpellRefs.AspectWild, BeastAndBow.MacroSpellRefs.AspectCheetah, "shift")
end

function BeastAndBow.CreateAspectMacro10()
    CreateAspectComboMacro(MacroUIText("Aspekt-Kombo: Wildnis/Affen", "Aspect Combo: Wild/Monkey"), BeastAndBow.MacroSpellRefs.AspectWild, BeastAndBow.MacroSpellRefs.AspectMonkey, "shift")
end

-- Tracking macros (Page 5)
local function CreateTrackingComboMacro(defaultName, primaryTrack, modifierTrack, modifier)
    local key = modifier or "shift"
    local body = "/cast [mod:" .. key .. "] " .. ResolveSpellName(modifierTrack) .. "; " .. ResolveSpellName(primaryTrack)
    BeastAndBow.ShowNameInputDialogForBody(defaultName, body, primaryTrack, nil, "Tracking", nil, true)
end

function BeastAndBow.CreateTrackingMacro1()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Wildtiere/Humanoide", "Tracking Combo: Beasts/Humanoids"), BeastAndBow.MacroSpellRefs.TrackBeasts, BeastAndBow.MacroSpellRefs.TrackHumanoids, "shift")
end

function BeastAndBow.CreateTrackingMacro2()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Wildtiere/Dämonen", "Tracking Combo: Beasts/Demons"), BeastAndBow.MacroSpellRefs.TrackBeasts, BeastAndBow.MacroSpellRefs.TrackDemons, "shift")
end

function BeastAndBow.CreateTrackingMacro3()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Humanoide/Untote", "Tracking Combo: Humanoids/Undead"), BeastAndBow.MacroSpellRefs.TrackHumanoids, BeastAndBow.MacroSpellRefs.TrackUndead, "shift")
end

function BeastAndBow.CreateTrackingMacro4()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Elementare/Riesen", "Tracking Combo: Elementals/Giants"), BeastAndBow.MacroSpellRefs.TrackElementals, BeastAndBow.MacroSpellRefs.TrackGiants, "shift")
end

function BeastAndBow.CreateTrackingMacro5()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Verborgenes/Drachkin", "Tracking Combo: Hidden/Dragonkin"), BeastAndBow.MacroSpellRefs.TrackHidden, BeastAndBow.MacroSpellRefs.TrackDragonkin, "shift")
end

function BeastAndBow.CreateTrackingMacro6()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Dämonen/Untote", "Tracking Combo: Demons/Undead"), BeastAndBow.MacroSpellRefs.TrackDemons, BeastAndBow.MacroSpellRefs.TrackUndead, "shift")
end

function BeastAndBow.CreateTrackingMacro7()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Humanoide/Dämonen", "Tracking Combo: Humanoids/Demons"), BeastAndBow.MacroSpellRefs.TrackHumanoids, BeastAndBow.MacroSpellRefs.TrackDemons, "ctrl")
end

function BeastAndBow.CreateTrackingMacro8()
    CreateTrackingComboMacro(MacroUIText("Tracking-Kombo: Elementare/Drachkin", "Tracking Combo: Elementals/Dragonkin"), BeastAndBow.MacroSpellRefs.TrackElementals, BeastAndBow.MacroSpellRefs.TrackDragonkin, "shift")
end

-- Helper for melee combat macro combos
local function CreateMeleeComboMacro(defaultName, ability1, ability2, ability3, modifierAbility2, modifierAbility3)
    local modifier2 = modifierAbility2 or "shift"
    local modifier3 = modifierAbility3 or "ctrl"
    local body = "/cast [mod:" .. modifier2 .. "] " .. ResolveSpellName(ability2) .. "; [mod:" .. modifier3 .. "] " .. ResolveSpellName(ability3) .. "; " .. ResolveSpellName(ability1)
    BeastAndBow.ShowNameInputDialogForBody(defaultName, body, ability1, nil, "Melee", nil, true)
end

function BeastAndBow.CreateMeleeMacro1()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Raptorstoß/Mungobiss/Zurechtstutzen", "Melee Combo: Raptor Strike/Mongoose Bite/Wing Clip"), BeastAndBow.MacroSpellRefs.RaptorStrike, BeastAndBow.MacroSpellRefs.MongooseBite, BeastAndBow.MacroSpellRefs.WingClip, "shift", "ctrl")
end

function BeastAndBow.CreateMeleeMacro2()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Raptorstoß/Zurechtstutzen/Mungobiss", "Melee Combo: Raptor Strike/Wing Clip/Mongoose Bite"), BeastAndBow.MacroSpellRefs.RaptorStrike, BeastAndBow.MacroSpellRefs.WingClip, BeastAndBow.MacroSpellRefs.MongooseBite, "shift", "ctrl")
end

function BeastAndBow.CreateMeleeMacro3()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Mungobiss/Raptorstoß/Zurechtstutzen", "Melee Combo: Mongoose Bite/Raptor Strike/Wing Clip"), BeastAndBow.MacroSpellRefs.MongooseBite, BeastAndBow.MacroSpellRefs.RaptorStrike, BeastAndBow.MacroSpellRefs.WingClip, "shift", "ctrl")
end

function BeastAndBow.CreateMeleeMacro4()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Mungobiss/Zurechtstutzen/Raptorstoß", "Melee Combo: Mongoose Bite/Wing Clip/Raptor Strike"), BeastAndBow.MacroSpellRefs.MongooseBite, BeastAndBow.MacroSpellRefs.WingClip, BeastAndBow.MacroSpellRefs.RaptorStrike, "shift", "ctrl")
end

function BeastAndBow.CreateMeleeMacro5()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Zurechtstutzen/Raptorstoß/Mungobiss", "Melee Combo: Wing Clip/Raptor Strike/Mongoose Bite"), BeastAndBow.MacroSpellRefs.WingClip, BeastAndBow.MacroSpellRefs.RaptorStrike, BeastAndBow.MacroSpellRefs.MongooseBite, "shift", "ctrl")
end

function BeastAndBow.CreateMeleeMacro6()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Zurechtstutzen/Mungobiss/Raptorstoß", "Melee Combo: Wing Clip/Mongoose Bite/Raptor Strike"), BeastAndBow.MacroSpellRefs.WingClip, BeastAndBow.MacroSpellRefs.MongooseBite, BeastAndBow.MacroSpellRefs.RaptorStrike, "shift", "ctrl")
end

function BeastAndBow.CreateMeleeMacro7()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Raptorstoß/Mungobiss (Strg)", "Melee Combo: Raptor Strike/Mongoose Bite (Ctrl)"), BeastAndBow.MacroSpellRefs.RaptorStrike, BeastAndBow.MacroSpellRefs.MongooseBite, BeastAndBow.MacroSpellRefs.RaptorStrike, "shift", "ctrl")
end

function BeastAndBow.CreateMeleeMacro8()
    CreateMeleeComboMacro(MacroUIText("Melee-Kombo: Mungobiss/Raptorstoß (Strg)", "Melee Combo: Mongoose Bite/Raptor Strike (Ctrl)"), BeastAndBow.MacroSpellRefs.MongooseBite, BeastAndBow.MacroSpellRefs.RaptorStrike, BeastAndBow.MacroSpellRefs.MongooseBite, "shift", "ctrl")
end

-- Deletes a single macro by name and removes it from the addon's tracking list.
function BeastAndBow.DeleteSingleMacro(spellName, group)
    if not group or not spellName or not BeastAndBow_Settings.createdMacros or not BeastAndBow_Settings.createdMacros[group] then
        -- This can happen if no macros were ever created for this group.
        print(string.format("Keine Makros für die Gruppe '%s' gefunden.", group or "unbekannt"))
        return
    end

    -- Handle old format (where we can't do single-delete)
    local isOldFormat = false
    for k,v in pairs(BeastAndBow_Settings.createdMacros[group]) do
        if type(k) == "number" then
            isOldFormat = true
            break
        end
    end

    if isOldFormat then
         print("Beast & Bow: Einzellöschen für Makros im alten Format nicht möglich. Bitte benutze 'Lösche PetAttack-Makros', um alle Makros dieser Gruppe zu entfernen und neu zu erstellen.")
         return
    end

    local normalizedKey = NormalizeMacroStorageKey(group, spellName)
    local macroNameToDelete = BeastAndBow_Settings.createdMacros[group][normalizedKey] or BeastAndBow_Settings.createdMacros[group][spellName]

    if not macroNameToDelete then
        print(string.format("Kein benutzerdefiniertes Makro für '%s' gefunden.", spellName))
        return
    end

    local index, tab = GetMacroIndexByName(macroNameToDelete)
    if index and index > 0 then
        DeleteMacro(index, tab == "character")
        print(string.format("Makro '%s' (für Zauber '%s') wurde gelöscht.", macroNameToDelete, spellName))
    else
        print(string.format("Makro '%s' im Spiel nicht gefunden, wird trotzdem aus der Liste entfernt.", macroNameToDelete))
    end

    -- Remove from our tracking list
    BeastAndBow_Settings.createdMacros[group][normalizedKey] = nil
    BeastAndBow_Settings.createdMacros[group][spellName] = nil
end

-- Deletes all macros created by this addon for a specific group.
function BeastAndBow.DeleteMacrosByGroup(group)
    if not group or not BeastAndBow_Settings.createdMacros or not BeastAndBow_Settings.createdMacros[group] then
        print(string.format("Keine Makros für die Gruppe '%s' gefunden.", group))
        return
    end

    local macroGroup = BeastAndBow_Settings.createdMacros[group]
    local macrosToDelete = {}

    -- Check format and collect names
    local isOldFormat = false
    for k,v in pairs(macroGroup) do
        if type(k) == "number" then
            isOldFormat = true
            break
        end
    end

    if isOldFormat then -- Old array format
        for _, name in ipairs(macroGroup) do
            if type(name) == "string" then table.insert(macrosToDelete, name) end
        end
    else -- New dictionary format
        for spell, name in pairs(macroGroup) do
            if type(name) == "string" then table.insert(macrosToDelete, name) end
        end
    end
    
    if #macrosToDelete == 0 then
        print(string.format("Keine Makros für die Gruppe '%s' zum Löschen vorhanden.", group))
        -- Still clear the table in case it had non-string entries or was in a weird state
        BeastAndBow_Settings.createdMacros[group] = {}
        return
    end

    local deletedCount = 0
    print(string.format("Lösche %d Makros für die Gruppe '%s'...", #macrosToDelete, group))

    for _, name in ipairs(macrosToDelete) do
        local index, tab = GetMacroIndexByName(name)
        if index and index > 0 then
            DeleteMacro(index, tab == "character")
            deletedCount = deletedCount + 1
        end
    end
    
    print(string.format("%d Makros der Gruppe '%s' wurden gelöscht.", deletedCount, group))

    -- This clears the list and prepares it for the new dictionary format.
        BeastAndBow_Settings.createdMacros[group] = {}
    end