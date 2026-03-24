local addonName, addonTable = ...

-- Expose core table if not already initialized
BeastAndBow = BeastAndBow or {}
local BAB = BeastAndBow

-- ============================================================================
-- LAZY-LOADING: Pet Categories (Bestarium Data)
-- ============================================================================
-- The Bestarium.lua file is loaded but stores data in _RawPetData.
-- GetPetCategories() initializes PetCategories on first access.

function BAB.GetPetCategories()
	if not rawget(BAB, "PetCategories") then
		-- Initialize from raw data on first access
		if rawget(BAB, "_RawPetData") then
			BAB.PetCategories = BAB._RawPetData
			
			-- Localize category names and pet names if locale mapping is available
			if BAB.L then
				for _, category in ipairs(BAB.PetCategories) do
					-- Localize category name
					local catKeyId = "CATEGORY_" .. category.id
					if BAB.L[catKeyId] then
						category.name = BAB.L[catKeyId]
					end
					
					if category.subgroups then
						for _, subgroup in ipairs(category.subgroups) do
							-- Localize subgroup name
							local subKeyId = "SUBGROUP_" .. category.id .. "_" .. subgroup.id
							if BAB.L[subKeyId] then
								subgroup.name = BAB.L[subKeyId]
							end
							
							if subgroup.species then
								for _, pet in ipairs(subgroup.species) do
									if pet.name then
										pet.name = BAB.GetLocalizedPetName(pet.name)
									end
								end
							end
							
							-- Handle nested subgroups (for spiders and wolves)
							if subgroup.subgroups then
								for _, sub2 in ipairs(subgroup.subgroups) do
									-- Localize nested subgroup name
									local sub2KeyId = "SUBGROUP_" .. category.id .. "_" .. subgroup.id .. "_" .. sub2.id
									if BAB.L[sub2KeyId] then
										sub2.name = BAB.L[sub2KeyId]
									end
									
									if sub2.species then
										for _, pet in ipairs(sub2.species) do
											if pet.name then
												pet.name = BAB.GetLocalizedPetName(pet.name)
											end
										end
									end
								end
							end
						end
					end
				end
			end
			
			-- Clear raw data to save memory
			BAB._RawPetData = nil
		else
			-- Fallback: empty table if data not loaded yet
			BAB.PetCategories = {}
		end
	end
	return BAB.PetCategories
end

-- ============================================================================
-- NAVIGATION STATE (wird von Green_Arrow.lua genutzt)
-- ============================================================================

BAB.navTargets = nil  -- Liste von Zielen { {mapID=,x=,y=,label=} }
BAB.navIndex = 1

-- ============================================================================
-- ZONE NAME RESOLVER: Name -> MapID
-- ============================================================================
-- Builds a lookup table from BeastAndBow.EnglishMapNames (defined in NPC_Data/Data.lua)

do
	local nameToMap

	local function ensureLookup()
		local EN = rawget(BeastAndBow, "EnglishMapNames")
		if not EN then
			nameToMap = nameToMap or {}
			return nameToMap
		end
		-- If we haven't built it yet, or EN was loaded later, (re)build it
		if not nameToMap or not next(nameToMap) then
			local m = {}
			for mapID, name in pairs(EN) do
				if type(name) == "string" and type(mapID) == "number" then
					m[name] = mapID
				end
			end
			-- Helpful aliases
			if m["The Barrens"] and not m["Barrens"] then
				m["Barrens"] = m["The Barrens"]
			end
			if m["Stormwind City"] and not m["Stormwind"] then
				m["Stormwind"] = m["Stormwind City"]
			end
			-- Prefer Orgrimmar city map (1637) if present
			if EN[1637] == "Orgrimmar" then
				m["Orgrimmar"] = 1637
			end
			-- Darkshore has 1439 and 1440; prefer 1440 if available
			if EN[1440] == "Darkshore" or EN[1439] == "Darkshore" then
				m["Darkshore"] = EN[1440] and 1440 or 1439
			end
			nameToMap = m
		end
		return nameToMap
	end

	function BAB.GetMapIDByZoneName(zoneName)
		if not zoneName or zoneName == "" then return nil end
		local LUT = ensureLookup()
		-- Exact match
		local id = LUT[zoneName]
		if id then return id end
		-- Case-insensitive exact
		local normalized = tostring(zoneName):gsub("^%s+", ""):gsub("%s+$", "")
		for name, mapID in pairs(LUT) do
			if type(name) == "string" and name:lower() == normalized:lower() then
				return mapID
			end
		end
		-- Common shorthand
		local shorthand = {
			Barrens = "The Barrens",
			STV = "Stranglethorn Vale",
		}
		for short, full in pairs(shorthand) do
			if normalized:lower() == short:lower() and LUT[full] then
				return LUT[full]
			end
		end
		-- Composite or subzone names: try to detect the base zone by substring
		-- e.g., "Ruins of Mathystra, Darkshore" -> "Darkshore"
		local lowered = normalized:lower()
		for name, mapID in pairs(LUT) do
			if type(name) == "string" then
				local lname = name:lower()
				if lowered:find(lname, 1, true) or lname:find(lowered, 1, true) then
					return mapID
				end
			end
		end
		-- Not found
		return nil
	end
end

-- Duplicate block removed - function already defined above

-- ============================================================================
-- TBC INITIALIZATION
-- ============================================================================
-- Merge TBC-specific data if running on TBC
if BeastAndBow and BeastAndBow.MergeTBCData then
	-- This will be called by TBC_Data.lua if in TBC version
	BeastAndBow.MergeTBCData()
end
