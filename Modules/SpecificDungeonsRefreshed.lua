-- this event fires when the specific dungeons window is refreshed
-- it should only fire once per refresh

local refreshPending = false

local function OnRefreshView()
    if not LibDF._IsDungeonFinderShowing() then return end
    if not LibDF._IsSpecificDungeons() then return end
    if refreshPending then return end
    refreshPending = true
    zo_callLater(function()
        refreshPending = false
        LibDF._FireCallbacks("SpecificDungeonsRefreshed")
    end, 50)
end

local function OnPlayerActivated()
    if DUNGEON_FINDER_KEYBOARD then
        ZO_PostHook(DUNGEON_FINDER_KEYBOARD, "RefreshView", OnRefreshView)
    end
    if DUNGEON_FINDER_GAMEPAD then
        ZO_PostHook(DUNGEON_FINDER_GAMEPAD, "RefreshView", OnRefreshView)
    end

    EVENT_MANAGER:UnregisterForEvent("LibDF_SpecificDungeonsRefreshed_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= "LibDF" then return end
    EVENT_MANAGER:UnregisterForEvent("LibDF_SpecificDungeonsRefreshed_OnAddonLoaded", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent("LibDF_SpecificDungeonsRefreshed_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("LibDF_SpecificDungeonsRefreshed_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
