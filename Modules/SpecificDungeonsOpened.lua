-- this event fires when the specific dungeons category is first opened in the dungeon finder
-- it does not change or iterate on the contents for you, and should only fire once

local lastWasSpecific = false
local openPending = false

local function FireOpened()
    if openPending then return end
    openPending = true
    zo_callLater(function()
        openPending = false
        LibDF._FireCallbacks("SpecificDungeonsOpened")
    end, 50)
end

local function OnFragmentStateChange(oldState, newState)
    if newState == SCENE_FRAGMENT_SHOWN then
        lastWasSpecific = LibDF._IsSpecificDungeons()
        if lastWasSpecific then
            FireOpened()
        end
    elseif newState == SCENE_FRAGMENT_HIDDEN then
        lastWasSpecific = false
    end
end

local function OnPlayerActivated()
    local keyboardFragment = DUNGEON_FINDER_KEYBOARD and DUNGEON_FINDER_KEYBOARD.fragment
    local gamepadFragment  = DUNGEON_FINDER_GAMEPAD  and DUNGEON_FINDER_GAMEPAD.fragment
    if not keyboardFragment and not gamepadFragment then return end

    if keyboardFragment then keyboardFragment:RegisterCallback("StateChange", OnFragmentStateChange) end
    if gamepadFragment  then gamepadFragment:RegisterCallback("StateChange", OnFragmentStateChange)  end

    ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnSelectionsChanged", function()
        if not LibDF._IsDungeonFinderShowing() then return end
        local isSpecific = LibDF._IsSpecificDungeons()
        if isSpecific and not lastWasSpecific then
            FireOpened()
        end
        lastWasSpecific = isSpecific
    end)

    EVENT_MANAGER:UnregisterForEvent("LibDF_SpecificDungeonsOpened_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= "LibDF" then return end
    EVENT_MANAGER:UnregisterForEvent("LibDF_SpecificDungeonsOpened_OnAddonLoaded", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent("LibDF_SpecificDungeonsOpened_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("LibDF_SpecificDungeonsOpened_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
