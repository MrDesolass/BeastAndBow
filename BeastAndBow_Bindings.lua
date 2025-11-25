-- Small binding/wrapper to make XML OnLoad safe regardless of load ordering.
-- The XML calls BeastAndBow_OnLoad(self). If the main BeastAndBow table isn't
-- ready yet, we queue the frame and let the main file call OnLoad on it once
-- it's available.

_BeastAndBow_pendingOnLoad = _BeastAndBow_pendingOnLoad or {}

function BeastAndBow_OnLoad(frame)
    if BeastAndBow and type(BeastAndBow.OnLoad) == "function" then
        -- Main handler is available, call it directly
        BeastAndBow.OnLoad(frame)
    else
        -- Queue the frame for later processing
        table.insert(_BeastAndBow_pendingOnLoad, frame)
    end
end

function BeastAndBow_OnEvent(frame, event, ...)
    if BeastAndBow and type(BeastAndBow.OnEvent) == "function" then
        BeastAndBow.OnEvent(frame, event, ...)
    end
end
