-- retrieve whether a dlc is required to unlock a dungeon
-- you need to pass the dungeon's zoneid

function LibDF.IsDLCOwned(zoneId)
    local activityId = LibDF.ZoneActivityIds[zoneId]
    if not activityId then return nil end
    local collectibleId = GetRequiredActivityCollectibleId(activityId)
    if not collectibleId or collectibleId == 0 then return nil end
    return GetCollectibleUnlockStateById(collectibleId) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED
end
