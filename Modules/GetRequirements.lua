-- retrieve a dungeon's level or cp requirements
-- you need to pass the dungeon's zoneid

function LibDF.GetRequirements(zoneId)
    local activityId = LibDF.ZoneActivityIds[zoneId]
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
