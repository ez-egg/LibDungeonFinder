-- retrieve whether the skillpoint quest for a dungeon is finished or unfinished
-- you need to pass the dungeon's zoneid

function LibDF.IsQuestFinished(zoneId)
    local questIds = LibDF.SkillpointQuests[zoneId]
    if not questIds then return nil end
    for _, questId in ipairs(questIds) do
        if LibQuestData.completed_quests[questId] then
            return true
        end
    end
    return false
end
