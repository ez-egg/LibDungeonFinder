LibDungeonFinder = LibDungeonFinder or {}

local lastWasSpecific = false
local openPending = false
local refreshPending = false
local inGroupDungeon = false
local DUNGEON_ACTIVITY_TYPES = { LFG_ACTIVITY_DUNGEON, LFG_ACTIVITY_MASTER_DUNGEON }

local function FireOpened()
    if openPending then return end
    openPending = true
    zo_callLater(function()
        openPending = false
        LibDungeonFinder._FireCallbacks("SpecificDungeonsOpened")
    end, 50)
end

local function OnFragmentStateChange(oldState, newState)
    if newState == SCENE_FRAGMENT_SHOWN then
        lastWasSpecific = LibDungeonFinder._IsSpecificDungeons()
        if lastWasSpecific then
            FireOpened()
        end
    elseif newState == SCENE_FRAGMENT_HIDDEN then
        lastWasSpecific = false
    end
end

local function OnRefreshView()
    if not LibDungeonFinder._IsDungeonFinderShowing() then return end
    if not LibDungeonFinder._IsSpecificDungeons() then return end
    if refreshPending then return end
    refreshPending = true
    zo_callLater(function()
        refreshPending = false
        LibDungeonFinder._FireCallbacks("SpecificDungeonsRefreshed")
    end, 50)
end

local function IterateEntries()
    for _, activityType in ipairs(DUNGEON_ACTIVITY_TYPES) do
        local locationData = ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(activityType)
        if locationData then
            for _, location in ipairs(locationData) do
                if location:IsActive() and not location:ShouldForceFullPanelKeyboard() then
                    LibDungeonFinder._FireCallbacks("SpecificDungeonIterated", location)
                end
            end
        end
    end
end

-- Event_zone_changed is lighter than event_player_activated,
-- but it still needs to be permanently registered for this function to work;
-- if we unregister, the event won't fire if the player enters another dungeon without reloading.
-- I've taken steps to try and make this as light as possible through state tracking,
-- but i'm open to feedback if you know a better way.

local function OnZoneChanged(_, _, _, _, zoneId)
    local isGroupDungeon = LibDungeonFinder.GroupDungeonZones[zoneId] ~= nil
    if isGroupDungeon and not inGroupDungeon then
        inGroupDungeon = true
        zo_callLater(function()
            if GetZoneId(GetUnitZoneIndex("player")) ~= zoneId then return end
            LibDungeonFinder._FireCallbacks("GroupDungeonEntered", zoneId)
        end, 200)
    elseif not isGroupDungeon then
        inGroupDungeon = false
    end
end

local function OnDungeonFinderActivated()
    local keyboardFragment = DUNGEON_FINDER_KEYBOARD and DUNGEON_FINDER_KEYBOARD.fragment
    local gamepadFragment  = DUNGEON_FINDER_GAMEPAD  and DUNGEON_FINDER_GAMEPAD.fragment

    if keyboardFragment then keyboardFragment:RegisterCallback("StateChange", OnFragmentStateChange) end
    if gamepadFragment  then gamepadFragment:RegisterCallback("StateChange", OnFragmentStateChange)  end

    if keyboardFragment or gamepadFragment then
        ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnSelectionsChanged", function()
            if not LibDungeonFinder._IsDungeonFinderShowing() then return end
            local isSpecific = LibDungeonFinder._IsSpecificDungeons()
            if isSpecific and not lastWasSpecific then
                FireOpened()
            end
            lastWasSpecific = isSpecific
        end)
    end

    if DUNGEON_FINDER_KEYBOARD then
        ZO_PostHook(DUNGEON_FINDER_KEYBOARD, "RefreshView", OnRefreshView)
    end
    if DUNGEON_FINDER_GAMEPAD then
        ZO_PostHook(DUNGEON_FINDER_GAMEPAD, "RefreshView", OnRefreshView)
    end

    EVENT_MANAGER:UnregisterForEvent(LibDungeonFinder.name .. "_DungeonFinderActivated", EVENT_PLAYER_ACTIVATED)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= LibDungeonFinder.name then return end
    EVENT_MANAGER:UnregisterForEvent(LibDungeonFinder.name .. "_Events_OnAddonLoaded", EVENT_ADD_ON_LOADED)

    LibDungeonFinder.RegisterCallback("SpecificDungeonsRefreshed", IterateEntries)

    EVENT_MANAGER:RegisterForEvent(LibDungeonFinder.name .. "_GroupDungeonEntered", EVENT_ZONE_CHANGED, OnZoneChanged)
    EVENT_MANAGER:RegisterForEvent(LibDungeonFinder.name .. "_DungeonFinderActivated", EVENT_PLAYER_ACTIVATED, OnDungeonFinderActivated)
end

EVENT_MANAGER:RegisterForEvent(LibDungeonFinder.name .. "_Events_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
