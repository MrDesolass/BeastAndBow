local HBD = LibStub("HereBeDragons-2.0")
local M = BeastAndBow

-- Utility: Calculate distance in yards between two points on potentially different maps.
-- This requires getting world coordinates for both and ensuring they are on the same instance.
function M.CalculateDistanceYards(playerMapID, playerX, playerY, npcMapID, npcX, npcY)
    if not HBD or not playerMapID or not npcMapID then return nil end

    -- Normalize inputs: HBD expects 0-1 range
    local pX = (playerX > 1) and (playerX / 100) or playerX
    local pY = (playerY > 1) and (playerY / 100) or playerY
    local nX = (npcX > 1) and (npcX / 100) or npcX
    local nY = (npcY > 1) and (npcY / 100) or npcY

    -- Get world coordinates for both points
    -- pcall is used here to prevent errors from HBD (e.g., bad map ID) from halting execution.
    local ok1, wx1, wy1, instance1 = pcall(HBD.GetWorldCoordinatesFromZone, HBD, pX, pY, playerMapID)
    local ok2, wx2, wy2, instance2 = pcall(HBD.GetWorldCoordinatesFromZone, HBD, nX, nY, npcMapID)

    if not (ok1 and ok2 and wx1 and wy1 and wx2 and wy2 and instance1 and instance1 == instance2) then
      -- If we can't get valid, same-instance world coordinates, we can't calculate distance.
      return nil
    end
    
    -- Can only calculate distance if they are on the same continent/instance
    if wx1 and wy1 and wx2 and wy2 and instance1 and instance1 == instance2 then
        local _, distYards = HBD:GetWorldVector(instance1, wx1, wy1, wx2, wy2)
        return distYards
    end

    return nil
end