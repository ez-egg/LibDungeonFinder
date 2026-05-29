LibDungeonFinder = LibDungeonFinder or {}

function LibDungeonFinder.IsQuestFinished(zoneId)
    local questIds = LibDungeonFinder.SkillpointQuests[zoneId]
    if not questIds then return nil end
    for _, questId in ipairs(questIds) do
        if LibQuestData.completed_quests[questId] then
            return true
        end
    end
    return false
end

function LibDungeonFinder.IsPledgeFinished(zoneId)
    local dungeonName = GetZoneNameById(zoneId)
    if not dungeonName or dungeonName == "" then return nil end

    for i = 1, GetNumJournalQuests() do
        if IsValidQuestIndex(i) then
            local questName = GetJournalQuestName(i)
            if questName == dungeonName then
                local questIds = LibQuestData:get_questids_table(questName)
                if questIds then
                    for _, questId in ipairs(questIds) do
                        if LibQuestData:get_quest_series(questId) == 2 then
                            local _, _, _, _, _, completed = GetJournalQuestInfo(i)
                            return completed
                        end
                    end
                end
            end
        end
    end

    return nil
end
