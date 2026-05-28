LibDF = {}
LibDF.GroupDungeonZones = {}
LibDF.ZoneActivityIds = {}
LibDF.SkillpointQuests = {}

local callbackRegistry = {}

function LibDF.RegisterCallback(eventName, callback)
    if not callbackRegistry[eventName] then
        callbackRegistry[eventName] = {}
    end
    table.insert(callbackRegistry[eventName], callback)
end

function LibDF.UnregisterCallback(eventName, callback)
    local list = callbackRegistry[eventName]
    if not list then return end
    for i, cb in ipairs(list) do
        if cb == callback then
            table.remove(list, i)
            return
        end
    end
end

function LibDF._FireCallbacks(eventName, ...)
    local list = callbackRegistry[eventName]
    if not list then return end
    local snapshot = {}
    for i = 1, #list do snapshot[i] = list[i] end
    for _, cb in ipairs(snapshot) do
        cb(...)
    end
end

function LibDF._IsSpecificDungeons()
    if DUNGEON_FINDER_KEYBOARD and DUNGEON_FINDER_KEYBOARD.filterComboBox then
        local selectedData = DUNGEON_FINDER_KEYBOARD.filterComboBox:GetSelectedItemData()
        if selectedData then
            return not selectedData.data.singular
        end
    end
    if DUNGEON_FINDER_GAMEPAD and DUNGEON_FINDER_GAMEPAD.navigationMode then
        return DUNGEON_FINDER_GAMEPAD.navigationMode == 3
    end
    return false
end

function LibDF._IsDungeonFinderShowing()
    return (DUNGEON_FINDER_KEYBOARD and DUNGEON_FINDER_KEYBOARD.fragment and DUNGEON_FINDER_KEYBOARD.fragment:IsShowing())
        or (DUNGEON_FINDER_GAMEPAD  and DUNGEON_FINDER_GAMEPAD.fragment  and DUNGEON_FINDER_GAMEPAD.fragment:IsShowing())
end

local function BuildGroupDungeonLookup()
    LibDF.GroupDungeonZones = {}
    LibDF.ZoneActivityIds = {}
    for _, activityType in ipairs({ LFG_ACTIVITY_DUNGEON, LFG_ACTIVITY_MASTER_DUNGEON }) do
        local i = 1
        local activityId = GetActivityIdByTypeAndIndex(activityType, i)
        while activityId ~= 0 do
            local zoneId = GetActivityZoneId(activityId)
            if zoneId ~= 0 then
                LibDF.GroupDungeonZones[zoneId] = true
                if not LibDF.ZoneActivityIds[zoneId] then
                    LibDF.ZoneActivityIds[zoneId] = activityId
                end
            end
            i = i + 1
            activityId = GetActivityIdByTypeAndIndex(activityType, i)
        end
    end
end

local function BuildSkillpointQuestLookup()
    LibDF.SkillpointQuests = {}

    local skillpointSet = {}
    for _, questId in ipairs(LibQuestData.quest_has_skill_point) do
        skillpointSet[questId] = true
    end

    -- Build a reverse index: zoneId -> set of textures
    local zoneTextures = {}
    for texture, mapIds in pairs(LibMapData.textureNamesLookup) do
        for _, mapId in ipairs(mapIds) do
            local zoneId = GetZoneId(GetZoneIndexByMapId(mapId))
            if zoneId and zoneId ~= 0 and LibDF.GroupDungeonZones[zoneId] then
                if not zoneTextures[zoneId] then zoneTextures[zoneId] = {} end
                zoneTextures[zoneId][texture] = true
            end
        end
    end

    -- For each dungeon zone, collect its skillpoint quests
    -- seen[zoneId][questId] prevents duplicates when a zone has multiple textures
    local seen = {}
    for zoneId in pairs(LibDF.GroupDungeonZones) do
        local textures = zoneTextures[zoneId]
        if textures then
            for texture in pairs(textures) do
                local questLocations = LibQuestData_QuestLocationData[texture]
                if questLocations then
                    for _, questEntry in ipairs(questLocations) do
                        local questId = questEntry[5]
                        if questId and skillpointSet[questId] then
                            if not seen[zoneId] then seen[zoneId] = {} end
                            if not seen[zoneId][questId] then
                                seen[zoneId][questId] = true
                                if not LibDF.SkillpointQuests[zoneId] then
                                    LibDF.SkillpointQuests[zoneId] = {}
                                end
                                table.insert(LibDF.SkillpointQuests[zoneId], questId)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function OnPlayerActivated()
    BuildGroupDungeonLookup()
    BuildSkillpointQuestLookup()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= "LibDF" then return end
    EVENT_MANAGER:UnregisterForEvent("LibDF_OnAddonLoaded", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent("LibDF_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("LibDF_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
