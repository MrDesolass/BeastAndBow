-- ======================== SEARCH FUNCTIONS ========================

-- Local trim to avoid relying on any global string:trim extensions
local function trim(s)
    if type(s) ~= "string" then return "" end
    local a = s:match("^%s*(.-)%s*$")
    return a or s
end

local function clearDynamicTextRegions(parent)
    if not parent or not parent.GetRegions then return end
    local regions = { parent:GetRegions() }
    for _, region in ipairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            if region.SetText then region:SetText("") end
            if region.Hide then region:Hide() end
        end
    end
end

function BeastAndBow.OnGlobalSearchTextChanged(searchText)
    local searchText = trim(string.lower(tostring(searchText or "")))
    
    -- Hide model and info when searching
    local modelContainer = _G["BeastAndBowPetsModelContainer"]
    local infoPanel = _G["BeastAndBowPetsInfo"]
    
    if searchText == "" then
        -- Clear search - restore normal views
        local petsFrame = _G["BeastAndBowPetsFrame"]
        local skillsFrame = _G["BeastAndBowSkillsFrame"]
        
        -- If in Pet view, restore pet categories
        if petsFrame and petsFrame:IsVisible() then
            BeastAndBow.ClearChildren(_G["BeastAndBowPetsSpecies"])
            local catsScroll = _G["BeastAndBowPetsCategoriesScroll"]
            if catsScroll then catsScroll:Show() end
            local speciesScroll = _G["BeastAndBowPetsSpeciesScroll"]
            if speciesScroll then speciesScroll:Hide() end
            BeastAndBow.PopulatePetCategories()
        end
        
        -- If in Skills view, restore skills
        if skillsFrame and skillsFrame:IsVisible() then
            local abilitiesScroll = _G["BeastAndBowSkills_AbilitiesScroll"]
            if abilitiesScroll then abilitiesScroll:Show() end
            local ranksScroll = _G["BeastAndBowSkills_RanksScroll"]
            if ranksScroll then ranksScroll:Hide() end
            local petsScroll = _G["BeastAndBowSkills_PetsScroll"]
            if petsScroll then petsScroll:Hide() end
            BeastAndBow.PopulateSkillsFrame()
        end
        return
    end
    
    -- Hide model container and info when searching
    if modelContainer then modelContainer:Hide() end
    if infoPanel then infoPanel:Hide() end
    
    -- Determine which view is active and perform appropriate search
    local petsFrame = _G["BeastAndBowPetsFrame"]
    local skillsFrame = _G["BeastAndBowSkillsFrame"]
    local isPetsViewActive = petsFrame and petsFrame:IsVisible()
    local isSkillsViewActive = skillsFrame and skillsFrame:IsVisible()
    
    if isPetsViewActive then
        -- In Pet view: show cross-search results (pets + skills)
        BeastAndBow.DisplayCrossPetSearchResults(searchText)
    elseif isSkillsViewActive then
        -- In Skills view: show cross-search results (skills + pets)
        BeastAndBow.DisplayCrossSkillSearchResults(searchText)
    end
end

function BeastAndBow.OnPetSearchTextChanged(searchText)
    local searchText = trim(string.lower(tostring(searchText or "")))
    
    if searchText == "" then
        -- Clear search - restore normal view
        BeastAndBow.PopulatePetCategories()
        local catsScroll = _G["BeastAndBowPetsCategoriesScroll"]
        if catsScroll then catsScroll:Show() end
        return
    end
    
    -- Get current active frame
    local petsFrame = _G["BeastAndBowPetsFrame"]
    local isPetsViewActive = petsFrame and petsFrame:IsVisible()
    
    -- Always perform the search, but only display if in Pet view
    if isPetsViewActive then
        -- In Pets view: show pets results and also skill results if found
        BeastAndBow.DisplayCrossPetSearchResults(searchText)
    end
end

function BeastAndBow.DisplayCrossPetSearchResults(searchText)
    local petResults = {}
    local skillResults = {}
    local seenPets = {} -- Use a set to track added pets and avoid duplicates

    -- Helper to add a pet to results if not already present
    local function addPetResult(pet)
        if not pet or not pet.data or not pet.data.name then return end
        if not seenPets[pet.data.name] then
            table.insert(petResults, pet)
            seenPets[pet.data.name] = true
        end
    end

    -- 1. Search through all pets by name and zone
    local allPets = {}
    local categories = BeastAndBow.GetPetCategories() or {}
    
    for _, cat in ipairs(categories) do
        local function collectPets(speciesList, location)
            if not speciesList then return end
            for _, pet in ipairs(speciesList) do
                table.insert(allPets, {
                    name = pet.name or "Unknown",
                    zone = pet.zone or location or "Unknown",
                    level = pet.level,
                    data = pet,
                    type = "pet"
                })
            end
        end
        
        if cat.subgroups then
            for _, sub1 in ipairs(cat.subgroups) do
                local loc = sub1.name or cat.name
                if sub1.species then collectPets(sub1.species, loc) end
                if sub1.subgroups then
                    for _, sub2 in ipairs(sub1.subgroups) do
                        if sub2.species then collectPets(sub2.species, loc) end
                        if sub2.subgroups then
                            for _, sub3 in ipairs(sub2.subgroups) do
                                if sub3.species then collectPets(sub3.species, loc) end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Filter pets based on search text (name or zone)
    for _, pet in ipairs(allPets) do
        local name = pet.name:lower()
        local zone = pet.zone:lower()
        if name:find(searchText, 1, true) or zone:find(searchText, 1, true) then
            addPetResult(pet)
        end
    end
    
    -- 2. Search for skills that match, and then add pets that have those skills
    local abilityDB = BeastAndBow.BuildAbilityDB() or {}
    for skillId, skill in pairs(abilityDB) do
        local rawSkillName = tostring(skill and skill.name or "")
        local canonicalSkillName = tostring(skillId or rawSkillName or "")
        local skillName = (canonicalSkillName ~= "" and canonicalSkillName or "unknown"):lower()
        local skillNameLocalizedSource = (rawSkillName ~= "" and rawSkillName or canonicalSkillName)
        local skillNameLocalizedDirect = skillNameLocalizedSource:lower()
        local skillNameLocalized = ""
        
        if canonicalSkillName ~= "" and BeastAndBow and BeastAndBow.L then
            local spellKey = "SPELL_" .. canonicalSkillName:upper():gsub(" ", "_"):gsub("-", "_")
            if BeastAndBow.L[spellKey] then
                skillNameLocalized = BeastAndBow.L[spellKey]:lower()
            end
        end
        
        if skillName:find(searchText, 1, true)
            or (skillNameLocalized ~= "" and skillNameLocalized:find(searchText, 1, true))
            or (skillNameLocalizedDirect ~= "" and skillNameLocalizedDirect:find(searchText, 1, true)) then
            table.insert(skillResults, {
                name = skill.name or canonicalSkillName or "Unknown",
                id = skill.id or canonicalSkillName,
                type = "skill",
                data = skill
            })
            -- Skill name matches, now find all pets that teach this skill
            if skill.ranks then
                for _, rankData in ipairs(skill.ranks) do
                    if rankData.pets then
                        for _, petDetail in ipairs(rankData.pets) do
                            if petDetail.petInfo then
                                local petToAdd = {
                                    name = petDetail.petInfo.name or "Unknown",
                                    zone = (petDetail.subgroupInfo and petDetail.subgroupInfo.name) or "Unknown",
                                    level = petDetail.petInfo.level,
                                    data = petDetail.petInfo,
                                    type = "pet"
                                }
                                addPetResult(petToAdd)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Display combined pet search results (skills first, then pets)
    BeastAndBow.DisplayPetSearchResults(petResults, searchText, skillResults)
end

function BeastAndBow.DisplayPetSearchResults(results, searchText, skillResults)
    local parent = _G["BeastAndBowPetsSpecies"]
    if not parent then return end
    
    BeastAndBow.ClearChildren(parent)
    clearDynamicTextRegions(parent)
    local speciesScroll = _G["BeastAndBowPetsSpeciesScroll"]
    if speciesScroll then speciesScroll:Show() end
    
    -- Do NOT show model and info containers during search - they should only appear when clicking a result
    -- Model and info are hidden by OnGlobalSearchTextChanged
    
    -- Hide categories
    local catsScroll = _G["BeastAndBowPetsCategoriesScroll"]
    if catsScroll then catsScroll:Hide() end
    
    local y = -4
    local hasSkills = skillResults and #skillResults > 0
    local hasPets = results and #results > 0
    
    if not hasSkills and not hasPets then
        local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        fs:SetText("Keine Ergebnisse")
        return
    end

    if hasSkills then
        for i, skill in ipairs(skillResults) do
            local btn = CreateFrame("Button", "BeastAndBowPetSearchSkillResult" .. i, parent, "UIPanelButtonTemplate")
            btn:SetSize(150, 22)
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
            local displayName = BeastAndBow.GetLocalizedSpellName(skill.name or "Unknown")
            btn:SetText(displayName)

            local tex = btn:CreateTexture(nil, "ARTWORK")
            tex:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
            tex:SetAllPoints(btn)
            btn:SetNormalTexture(tex)

            btn:SetScript("OnClick", function()
                if BeastAndBow and BeastAndBow.OpenSkillsView then
                    BeastAndBow.OpenSkillsView()
                end
                local selectedSkill = skill.data or skill
                if selectedSkill and selectedSkill.ranks then
                    BeastAndBow.SelectSkill(skill.id or selectedSkill.id or selectedSkill.name)
                end
            end)

            y = y - 26
        end
    end

    if hasSkills and hasPets then
        local separator = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        separator:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        separator:SetText("--- Pets ---")
        separator:SetTextColor(0.8, 0.8, 0.8)
        y = y - 22
    end
    
    for i, petData in ipairs(results or {}) do
        local btn = CreateFrame("Button", "BeastAndBowPetSearchResult" .. i, parent, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        btn:SetText(petData.name)
        
        -- Add button texture
        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        tex:SetAllPoints(btn)
        btn:SetNormalTexture(tex)
        
        btn:SetScript("OnClick", function()
            if petData.data then
                -- Display pet details using the existing function
                BeastAndBow.ShowPetDetail(petData.data, nil)
            end
        end)
        
        y = y - 26
    end
end

function BeastAndBow.OnSkillSearchTextChanged(searchText)
    local searchText = trim(string.lower(tostring(searchText or "")))
    
    if searchText == "" then
        -- Clear search - restore normal view
        BeastAndBow.PopulateSkillsFrame()
        local abilitiesScroll = _G["BeastAndBowSkills_AbilitiesScroll"]
        if abilitiesScroll then abilitiesScroll:Show() end
        return
    end
    
    -- Get current active frame
    local skillsFrame = _G["BeastAndBowSkillsFrame"]
    local isSkillsViewActive = skillsFrame and skillsFrame:IsVisible()
    
    if isSkillsViewActive then
        -- In Skills view: show skill results and also pet results if found
        BeastAndBow.DisplayCrossSkillSearchResults(searchText)
    end
end

function BeastAndBow.DisplayCrossSkillSearchResults(searchText)
    -- Search through all skills/abilities
    local abilityDB = BeastAndBow.BuildAbilityDB() or {}
    local skillResults = {}

    for skillId, skill in pairs(abilityDB) do
        local rawSkillName = tostring(skill and skill.name or "")
        local canonicalSkillName = tostring(skillId or rawSkillName or "")
        local skillName = (canonicalSkillName ~= "" and canonicalSkillName or "unknown"):lower()
        local skillNameLocalizedSource = (rawSkillName ~= "" and rawSkillName or canonicalSkillName)
        local skillNameLocalizedDirect = skillNameLocalizedSource:lower()
        local skillNameLocalized = ""

        -- Try to get localized name from L table using SPELL_ prefix
        if canonicalSkillName ~= "" and BeastAndBow and BeastAndBow.L then
            local spellKey = "SPELL_" .. canonicalSkillName:upper():gsub(" ", "_"):gsub("-", "_")
            if BeastAndBow.L[spellKey] then
                skillNameLocalized = BeastAndBow.L[spellKey]:lower()
            end
        end

        -- Search in both English and localized names
        if skillName:find(searchText, 1, true)
            or (skillNameLocalized ~= "" and skillNameLocalized:find(searchText, 1, true))
            or (skillNameLocalizedDirect ~= "" and skillNameLocalizedDirect:find(searchText, 1, true)) then
            table.insert(skillResults, {
                name = skill.name or canonicalSkillName or "Unknown",
                id = skill.id or canonicalSkillName,
                type = "skill",
                data = skill
            })
        end
    end

    -- Also search for pets that match
    local petResults = {}
    local categories = BeastAndBow.GetPetCategories() or {}

    for _, cat in ipairs(categories) do
        local function collectPets(speciesList, location)
            if not speciesList then return end
            for _, pet in ipairs(speciesList) do
                table.insert(petResults, {
                    name = pet.name or "Unknown",
                    zone = pet.zone or location or "Unknown",
                    level = pet.level,
                    data = pet,
                    type = "pet"
                })
            end
        end

        if cat.subgroups then
            for _, sub1 in ipairs(cat.subgroups) do
                local loc = sub1.name or cat.name
                if sub1.species then collectPets(sub1.species, loc) end
                if sub1.subgroups then
                    for _, sub2 in ipairs(sub1.subgroups) do
                        if sub2.species then collectPets(sub2.species, loc) end
                        if sub2.subgroups then
                            for _, sub3 in ipairs(sub2.subgroups) do
                                if sub3.species then collectPets(sub3.species, loc) end
                            end
                        end
                    end
                end
            end
        end
    end

    local filteredPets = {}
    for _, pet in ipairs(petResults) do
        local name = pet.name:lower()
        local zone = pet.zone:lower()
        if name:find(searchText, 1, true) or zone:find(searchText, 1, true) then
            table.insert(filteredPets, pet)
        end
    end

    -- Display skill search results
    BeastAndBow.DisplaySkillSearchResults(skillResults, searchText)

    -- If pets were also found, append them to the results
    if #filteredPets > 0 then
        BeastAndBow.AppendPetsToSearchResults(filteredPets, searchText)
    end
end

function BeastAndBow.GetLocalizedSpellName(englishName)
    if not englishName then return englishName end
    
    if BeastAndBow and BeastAndBow.L then
        local spellKey = "SPELL_" .. englishName:upper():gsub(" ", "_"):gsub("-", "_")
        if BeastAndBow.L[spellKey] then
            return BeastAndBow.L[spellKey]
        end
    end
    
    return englishName
end

function BeastAndBow.DisplaySkillSearchResults(results, searchText)
    local parent = _G["BeastAndBowSkills_Ranks"]
    if not parent then return end
    
    BeastAndBow.ClearChildren(parent)
    clearDynamicTextRegions(parent)
    local ranksScroll = _G["BeastAndBowSkills_RanksScroll"]
    if ranksScroll then ranksScroll:Show() end
    
    local petsScroll = _G["BeastAndBowSkills_PetsScroll"]
    if petsScroll then petsScroll:Hide() end
    
    local y = -4
    
    if #results == 0 then
        local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        fs:SetText("Keine Fähigkeiten")
        return
    end
    
    for i, skill in ipairs(results) do
        local btn = CreateFrame("Button", "BeastAndBowSkillSearchResult" .. i, parent, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        local displayName = BeastAndBow.GetLocalizedSpellName(skill.name or "Unknown")
        btn:SetText(displayName)
        
        -- Add button texture
        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        tex:SetAllPoints(btn)
        btn:SetNormalTexture(tex)
        
        btn:SetScript("OnClick", function()
            local selectedSkill = skill.data or skill
            if selectedSkill and selectedSkill.ranks then
                BeastAndBow.SelectSkill(skill.id or selectedSkill.id or selectedSkill.name)
            end
        end)
        
        y = y - 26
    end
end



function BeastAndBow.AppendPetsToSearchResults(petResults, searchText)
    local parent = _G["BeastAndBowSkills_Ranks"]
    if not parent then return end
    
    local y = -4
    local existingButtons = 0
    
    -- Count existing buttons to position new ones
    for i = 1, 1000 do
        if not _G["BeastAndBowSkillSearchResult" .. i] then
            existingButtons = i - 1
            break
        end
    end
    
    if existingButtons > 0 then
        y = -4 - (existingButtons * 26)
    end
    
    -- Add a separator
    local separator = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    separator:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
    separator:SetText("--- Pets ---")
    separator:SetTextColor(0.8, 0.8, 0.8)
    y = y - 22
    
    -- Add pet results
    for i, petData in ipairs(petResults) do
        local btn = CreateFrame("Button", "BeastAndBowSkillSearchPet" .. i, parent, "UIPanelButtonTemplate")
        btn:SetSize(150, 22)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
        btn:SetText(petData.name)
        
        -- Add button texture
        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetTexture("Interface\\AddOns\\BeastAndBow\\Textures\\buttons")
        tex:SetAllPoints(btn)
        btn:SetNormalTexture(tex)
        
        btn:SetScript("OnClick", function()
            BeastAndBow.ShowPetDetail(petData.data, petData)
        end)
        
        y = y - 26
    end
end

