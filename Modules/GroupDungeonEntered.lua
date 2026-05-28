-- this event fires when the player enters a group dungeon
-- it does not do anything on it's own

local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if not LibDF.IsGroupDungeon(zoneId) then return end
    zo_callLater(function()
        if GetZoneId(GetUnitZoneIndex("player")) ~= zoneId then return end
        LibDF._FireCallbacks("GroupDungeonEntered", zoneId)
    end, 200)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= "LibDF" then return end
    EVENT_MANAGER:UnregisterForEvent("LibDF_GroupDungeonEntered_OnAddonLoaded", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent("LibDF_GroupDungeonEntered_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("LibDF_GroupDungeonEntered_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
