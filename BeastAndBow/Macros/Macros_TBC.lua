BeastAndBow = BeastAndBow or {}

local BAB = BeastAndBow
local S = BAB.MacroSpellRefs or {}

local function SpellName(spellRef)
    return BAB.GetMacroLocalizedSpellName and BAB.GetMacroLocalizedSpellName(spellRef) or (type(spellRef) == "table" and spellRef.legacy) or spellRef
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

local function EnableTBCTrapButtons()
    SetButtonsEnabled({
        BeastAndBowMacrosFramePage3Macro3Button,
        BeastAndBowMacrosFramePage3Macro3DeleteButton,
        BeastAndBowMacrosFramePage3Macro4Button,
        BeastAndBowMacrosFramePage3Macro4DeleteButton,
        BeastAndBowMacrosFramePage3Macro7Button,
        BeastAndBowMacrosFramePage3Macro7DeleteButton,
    }, true)
end

local function EnableTBCAspectButtons()
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
    }, true)
end

local sharedShowMacroPage3 = BAB.ShowMacroPage3
if sharedShowMacroPage3 then
    function BAB.ShowMacroPage3()
        sharedShowMacroPage3()
        EnableTBCTrapButtons()
    end
end

local sharedShowMacroPage4 = BAB.ShowMacroPage4
if sharedShowMacroPage4 then
    function BAB.ShowMacroPage4()
        sharedShowMacroPage4()
        EnableTBCAspectButtons()
    end
end

function BAB.CreateTrapMacroCombo3()
    local body = "/cast [mod:shift] " .. SpellName(S.SnakeTrap) .. "; " .. SpellName(S.FreezingTrap)
    BAB.ShowNameInputDialogForBody("Fallen: Eiskälte+Schlange", body, nil, nil, "Traps")
end

function BAB.CreateTrapMacroCombo4()
    local body = "/cast [mod:shift] " .. SpellName(S.SnakeTrap) .. "; " .. SpellName(S.ImmolationTrap)
    BAB.ShowNameInputDialogForBody("Fallen: Feuerbrand+Schlange", body, nil, nil, "Traps")
end

function BAB.CreateTrapMacroAllSnake()
    local body = "/cast [mod:shift] " .. SpellName(S.ImmolationTrap) .. "; [mod:ctrl] " .. SpellName(S.ExplosiveTrap) .. "; [mod:alt] " .. SpellName(S.SnakeTrap) .. "; " .. SpellName(S.FreezingTrap)
    BAB.ShowNameInputDialogForBody("Fallen: Mit Schlange", body, nil, nil, "Traps")
end

local function CreateAspectComboMacro(defaultName, primaryAspect, modifierAspect, modifier)
    local key = modifier or "shift"
    local body = "/cast [mod:" .. key .. "] " .. SpellName(modifierAspect) .. "; " .. SpellName(primaryAspect)
    BAB.ShowNameInputDialogForBody(defaultName, body, nil, nil, "Aspects")
end

function BAB.CreateAspectMacro4()
    CreateAspectComboMacro("Aspekt-Kombo: Wildnis/Viper", S.AspectWild, S.AspectViper, "shift")
end

function BAB.CreateAspectMacro5()
    CreateAspectComboMacro("Aspekt-Kombo: Falken/Viper", S.AspectHawk, S.AspectViper, "shift")
end

function BAB.CreateAspectMacro6()
    CreateAspectComboMacro("Aspekt-Kombo: Geparden/Viper", S.AspectCheetah, S.AspectViper, "ctrl")
end

function BAB.CreateAspectMacro7()
    CreateAspectComboMacro("Aspekt-Kombo: Rudels/Viper", S.AspectPack, S.AspectViper, "shift")
end

function BAB.CreateAspectMacro8()
    CreateAspectComboMacro("Aspekt-Kombo: Affen/Viper", S.AspectMonkey, S.AspectViper, "shift")
end