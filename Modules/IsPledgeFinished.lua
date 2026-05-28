-- retrieve whether the player has an finished or unfinished pledge quest for a dungeon
-- you need to pass the dungeon's zoneid

function LibDF.IsPledgeFinished(zoneId)
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
