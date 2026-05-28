-- retrieve whether a dungeon is currently locked in dungeon finder
-- you need to pass the dungeon's zoneid

function LibDF.IsDungeonLocked(zoneId)
    local activityId = LibDF.ZoneActivityIds[zoneId]
    if not activityId then return false end
    local collectibleId = GetRequiredActivityCollectibleId(activityId)
    if collectibleId ~= 0 and not IsCollectibleUnlocked(collectibleId) then
        return true
    end
    return not DoesPlayerMeetActivityLevelRequirements(activityId)
end
