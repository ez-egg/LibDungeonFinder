LibDungeonFinder = LibDungeonFinder or {}

function LibDungeonFinder.IsGroupDungeon(zoneId)
    return LibDungeonFinder.GroupDungeonZones[zoneId] == true
end

function LibDungeonFinder.IsDungeonLocked(zoneId)
    local activityId = LibDungeonFinder.ZoneActivityIds[zoneId]
    if not activityId then return false end
    local collectibleId = GetRequiredActivityCollectibleId(activityId)
    if collectibleId ~= 0 and not IsCollectibleUnlocked(collectibleId) then
        return true
    end
    return not DoesPlayerMeetActivityLevelRequirements(activityId)
end

function LibDungeonFinder.IsDLCOwned(zoneId)
    local activityId = LibDungeonFinder.ZoneActivityIds[zoneId]
    if not activityId then return nil end
    local collectibleId = GetRequiredActivityCollectibleId(activityId)
    if not collectibleId or collectibleId == 0 then return nil end
    return GetCollectibleUnlockStateById(collectibleId) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED
end

function LibDungeonFinder.GetRequirements(zoneId)
    local activityId = LibDungeonFinder.ZoneActivityIds[zoneId]
    if not activityId then return nil end

    local _, minLevel, _, minCP = GetActivityInfo(activityId)

    if (not minLevel or minLevel == 0) and (not minCP or minCP == 0) then
        return nil
    end

    return {
        minLevel = (minLevel and minLevel > 0) and minLevel or nil,
        minCP    = (minCP and minCP > 0) and minCP or nil,
    }
end
