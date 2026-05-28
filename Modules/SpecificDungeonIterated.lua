-- fires once per entry in the specific dungeons list, after SpecificDungeonsRefreshed
-- here's what's exposed:

--   :GetId()                                           activityId
--   :GetActivityType()                                 LFG_ACTIVITY_DUNGEON or LFG_ACTIVITY_MASTER_DUNGEON
--   :GetZoneId()                                       zoneId
--   :GetRawName()                                      dungeon name without formatting
--   :GetNameKeyboard()                                 name with veteran icon prepended for master dungeons
--   :GetLevelMin() / :GetLevelMax()                    level range
--   :GetChampionPointsMin() / :GetChampionPointsMax()  CP range
--   :GetMinGroupSize() / :GetMaxGroupSize()            group size range
--   :GetDescription()                                  description text
--   :GetDescriptionTextureSmallKeyboard()              small art texture path
--   :GetDescriptionTextureLargeKeyboard()              large art texture path
--   :IsLocked()                                        true if locked (DLC, level, cooldown, etc.)
--   :GetLockReasonText()                               lock reason string, or nil
--   :IsSelected()                                      true if checked for queue

local DUNGEON_ACTIVITY_TYPES = { LFG_ACTIVITY_DUNGEON, LFG_ACTIVITY_MASTER_DUNGEON }

local function IterateEntries()
    for _, activityType in ipairs(DUNGEON_ACTIVITY_TYPES) do
        local locationData = ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(activityType)
        if locationData then
            for _, location in ipairs(locationData) do
                if location:IsActive() and not location:ShouldForceFullPanelKeyboard() then
                    LibDF._FireCallbacks("SpecificDungeonIterated", location)
                end
            end
        end
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= "LibDF" then return end
    EVENT_MANAGER:UnregisterForEvent("LibDF_SpecificDungeonIterated_OnAddonLoaded", EVENT_ADD_ON_LOADED)
    LibDF.RegisterCallback("SpecificDungeonsRefreshed", IterateEntries)
end

EVENT_MANAGER:RegisterForEvent("LibDF_SpecificDungeonIterated_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
