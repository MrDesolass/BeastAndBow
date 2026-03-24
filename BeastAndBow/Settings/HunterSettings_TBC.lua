-- Logic for the Hunter Settings panel (TBC overrides)
BeastAndBow = BeastAndBow or {}

local function SanitizeButton(btn, texturePath)
    if not btn then return end
    if btn.Left then btn.Left:Hide() end
    if btn.Middle then btn.Middle:Hide() end
    if btn.Right then btn.Right:Hide() end
    if btn.GetHighlightTexture then
        local h = btn:GetHighlightTexture()
        if h then h:SetAlpha(0) end
    end
    btn:SetNormalTexture(texturePath)
    btn:SetPushedTexture(texturePath)
    btn:SetDisabledTexture(texturePath)
end

local function GetAmmoLabel(key)
    local L = BeastAndBow.L or {}
    return L[key] or key
end

local function GetAmmoDataByID(ammoList, itemID)
    if not ammoList or not itemID then return nil end
    for _, ammoData in ipairs(ammoList) do
        if ammoData.itemID == itemID then
            return ammoData
        end
    end
    return nil
end

local function ResolveAmmoLabel(ammoList, itemID, fallbackKey)
    local ammoData = GetAmmoDataByID(ammoList, itemID)
    if ammoData and ammoData.key then
        return GetAmmoLabel(ammoData.key), ammoData.itemID
    end
    return GetAmmoLabel(fallbackKey), nil
end

local availableArrows = {
    { key = "AMMO_ARROW_ROUGH", itemID = 2512 },
    { key = "AMMO_ARROW_SHARP", itemID = 2515 },
    { key = "AMMO_ARROW_RAZOR", itemID = 3030 },
    { key = "AMMO_ARROW_JAGGED", itemID = 11285 },
    { key = "AMMO_ARROW_WICKED", itemID = 28053 },
    { key = "AMMO_ARROW_BLACKFLIGHT", itemID = 28056 },
}

local availableBullets = {
    { key = "AMMO_BULLET_LIGHT", itemID = 2516 },
    { key = "AMMO_BULLET_HEAVY", itemID = 2519 },
    { key = "AMMO_BULLET_SOLID", itemID = 3033 },
    { key = "AMMO_BULLET_ACCURATE", itemID = 11284 },
    { key = "AMMO_BULLET_IMPACT", itemID = 28060 },
    { key = "AMMO_BULLET_IRONBITE", itemID = 28061 },
}

local petFoodTypes = { "Fleisch", "Fisch", "Käse", "Brot", "Frucht", "Pilz" }

local function ClearChildren(frame)
    if not frame or not frame.GetChildren then return end
    for _, child in ipairs({frame:GetChildren()}) do
        child:Hide()
    end
end

local function ToggleAmmoMenu_TBC(parentButton, ammoList, ammoType)
    local container = _G["BeastAndBowSelectorContainer"]
    if not container then return end

    if container:IsShown() and container.owner == parentButton then
        container:Hide()
        container.owner = nil
        return
    end

    ClearChildren(container)
    container:ClearAllPoints()
    container:SetPoint("TOPLEFT", parentButton, "BOTTOMLEFT")
    container.owner = parentButton

    local yOffset = -5
    for _, ammoData in ipairs(ammoList) do
        local ammoText = GetAmmoLabel(ammoData.key)
        local btn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        SanitizeButton(btn, "Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        btn:SetSize(140, 22)
        btn:SetPoint("TOPLEFT", container, "TOPLEFT", 5, yOffset)
        btn:SetText(ammoText)
        if BeastAndBow.EnableButtonMarquee then
            BeastAndBow.EnableButtonMarquee(btn)
        end
        btn:SetScript("OnClick", function()
            if ammoType == "arrow" then
                BeastAndBow_Settings.autoBuyArrowID = ammoData.itemID
                BeastAndBow_Settings.autoBuyArrowKey = ammoData.key
                BeastAndBow_Settings.autoBuyArrowName = ammoText
            elseif ammoType == "bullet" then
                BeastAndBow_Settings.autoBuyBulletID = ammoData.itemID
                BeastAndBow_Settings.autoBuyBulletKey = ammoData.key
                BeastAndBow_Settings.autoBuyBulletName = ammoText
            end
            parentButton:SetText(ammoText)
            if BeastAndBow.EnableButtonMarquee then
                BeastAndBow.EnableButtonMarquee(parentButton)
            end
            container:Hide()
            container.owner = nil
        end)
        yOffset = yOffset - 25
    end

    container:SetHeight(#ammoList * 25 + 10)
    container:Show()
end

local function TogglePetFoodMenu_TBC(parentButton)
    local container = _G["BeastAndBowSelectorContainer"]
    if not container then return end

    if container:IsShown() and container.owner == parentButton then
        container:Hide()
        container.owner = nil
        return
    end

    ClearChildren(container)
    container:ClearAllPoints()
    container:SetPoint("TOPLEFT", parentButton, "BOTTOMLEFT")
    container.owner = parentButton

    local yOffset = -5
    for _, foodType in ipairs(petFoodTypes) do
        local btn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        SanitizeButton(btn, "Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        btn:SetSize(140, 22)
        btn:SetPoint("TOPLEFT", container, "TOPLEFT", 5, yOffset)
        btn:SetText(foodType)
        if BeastAndBow.EnableButtonMarquee then
            BeastAndBow.EnableButtonMarquee(btn)
        end
        btn:SetScript("OnClick", function()
            BeastAndBow_Settings.autoBuyPetFoodType = foodType
            parentButton:SetText(foodType)
            if BeastAndBow.EnableButtonMarquee then
                BeastAndBow.EnableButtonMarquee(parentButton)
            end
            container:Hide()
            container.owner = nil
        end)
        yOffset = yOffset - 25
    end

    container:SetHeight(#petFoodTypes * 25 + 10)
    container:Show()
end

local function ToggleArrowMenu_TBC(parentButton)
    ToggleAmmoMenu_TBC(parentButton, availableArrows, "arrow")
end

local function ToggleBulletMenu_TBC(parentButton)
    ToggleAmmoMenu_TBC(parentButton, availableBullets, "bullet")
end

local function HunterSettings_OnLoad_TBC(frame)
    frame:SetBackdrop({ bgFile = "Interface\\AddOns\\BeastAndBow\\Textures\\background" })
    frame:SetBackdropColor(1, 1, 1, 1)

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    local arrowCheckbox = _G["BeastAndBowAutoBuyArrowsCheckbox"]
    if arrowCheckbox then
        arrowCheckbox:SetChecked(BeastAndBow_Settings.autoBuyArrows or false)
    end

    local arrowButton = _G["BeastAndBowArrowSelectorButton"]
    if arrowButton then
        local arrowLabel, resolvedArrowID = ResolveAmmoLabel(availableArrows, BeastAndBow_Settings.autoBuyArrowID, "AMMO_ARROW_ROUGH")
        BeastAndBow_Settings.autoBuyArrowID = resolvedArrowID or BeastAndBow_Settings.autoBuyArrowID or 2512
        local resolvedArrow = GetAmmoDataByID(availableArrows, BeastAndBow_Settings.autoBuyArrowID)
        if resolvedArrow and resolvedArrow.key then
            BeastAndBow_Settings.autoBuyArrowKey = resolvedArrow.key
        end
        BeastAndBow_Settings.autoBuyArrowName = arrowLabel
        arrowButton:SetText(arrowLabel)
        SanitizeButton(arrowButton, "Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        if BeastAndBow.EnableButtonMarquee then
            BeastAndBow.EnableButtonMarquee(arrowButton)
        end
    end

    local bulletCheckbox = _G["BeastAndBowAutoBuyBulletsCheckbox"]
    if bulletCheckbox then
        bulletCheckbox:SetChecked(BeastAndBow_Settings.autoBuyBullets or false)
    end

    local bulletButton = _G["BeastAndBowBulletSelectorButton"]
    if bulletButton then
        local bulletLabel, resolvedBulletID = ResolveAmmoLabel(availableBullets, BeastAndBow_Settings.autoBuyBulletID, "AMMO_BULLET_LIGHT")
        BeastAndBow_Settings.autoBuyBulletID = resolvedBulletID or BeastAndBow_Settings.autoBuyBulletID or 2516
        local resolvedBullet = GetAmmoDataByID(availableBullets, BeastAndBow_Settings.autoBuyBulletID)
        if resolvedBullet and resolvedBullet.key then
            BeastAndBow_Settings.autoBuyBulletKey = resolvedBullet.key
        end
        BeastAndBow_Settings.autoBuyBulletName = bulletLabel
        bulletButton:SetText(bulletLabel)
        SanitizeButton(bulletButton, "Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        if BeastAndBow.EnableButtonMarquee then
            BeastAndBow.EnableButtonMarquee(bulletButton)
        end
    end

    local petFoodCheckbox = _G["BeastAndBowAutoBuyPetFoodCheckbox"]
    if petFoodCheckbox then
        petFoodCheckbox:SetChecked(false)
        BeastAndBow_Settings.autoBuyPetFood = false
        if petFoodCheckbox.Disable then petFoodCheckbox:Disable() end
        if petFoodCheckbox.SetAlpha then petFoodCheckbox:SetAlpha(0.5) end
        local petFoodCheckboxText = _G[petFoodCheckbox:GetName() .. "Text"]
        if petFoodCheckboxText and petFoodCheckboxText.SetText then
            petFoodCheckboxText:SetText("Soon")
        end
    end

    local petFoodButton = _G["BeastAndBowPetFoodSelectorButton"]
    if petFoodButton then
        BeastAndBow_Settings.autoBuyPetFoodType = nil
        petFoodButton:SetText("Soon")
        if petFoodButton.Disable then petFoodButton:Disable() end
        if petFoodButton.SetAlpha then petFoodButton:SetAlpha(0.5) end
        SanitizeButton(petFoodButton, "Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        if BeastAndBow.EnableButtonMarquee then
            BeastAndBow.EnableButtonMarquee(petFoodButton)
        end
    end
end

local function OpenHunterSettings_TBC()
    local frame = _G["BeastAndBowHunterSettingsFrame"]
    if frame then
        if frame:IsShown() then
            frame:Hide()
        else
            HunterSettings_OnLoad_TBC(frame)
            frame:Show()
        end
    end
end

if BeastAndBow.IsTBC and BeastAndBow.IsTBC() then
    BeastAndBow.ToggleAmmoMenu = ToggleAmmoMenu_TBC
    BeastAndBow.TogglePetFoodMenu = TogglePetFoodMenu_TBC
    BeastAndBow.ToggleArrowMenu = ToggleArrowMenu_TBC
    BeastAndBow.ToggleBulletMenu = ToggleBulletMenu_TBC
    BeastAndBow.HunterSettings_OnLoad = HunterSettings_OnLoad_TBC
    BeastAndBow.OpenHunterSettings = OpenHunterSettings_TBC
end
