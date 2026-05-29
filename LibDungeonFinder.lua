-- This library is licensed under CC-BY-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

LibDungeonFinder = {}
LibDungeonFinder.name = "LibDungeonFinder"
LibDungeonFinder.GroupDungeonZones = {}
LibDungeonFinder.ZoneActivityIds = {}
LibDungeonFinder.SkillpointQuests = {}

local callbackRegistry = {}

function LibDungeonFinder.RegisterCallback(eventName, callback)
    if not callbackRegistry[eventName] then
        callbackRegistry[eventName] = {}
    end
    table.insert(callbackRegistry[eventName], callback)
end

function LibDungeonFinder.UnregisterCallback(eventName, callback)
    local list = callbackRegistry[eventName]
    if not list then return end
    for i, cb in ipairs(list) do
        if cb == callback then
            table.remove(list, i)
            return
        end
    end
end

function LibDungeonFinder._FireCallbacks(eventName, ...)
    local list = callbackRegistry[eventName]
    if not list then return end
    local snapshot = {}
    for i = 1, #list do snapshot[i] = list[i] end
    for _, cb in ipairs(snapshot) do
        cb(...)
    end
end

function LibDungeonFinder._IsSpecificDungeons()
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

function LibDungeonFinder._IsDungeonFinderShowing()
    return (DUNGEON_FINDER_KEYBOARD and DUNGEON_FINDER_KEYBOARD.fragment and DUNGEON_FINDER_KEYBOARD.fragment:IsShowing())
        or (DUNGEON_FINDER_GAMEPAD  and DUNGEON_FINDER_GAMEPAD.fragment  and DUNGEON_FINDER_GAMEPAD.fragment:IsShowing())
end

local function BuildGroupDungeonLookup()
    LibDungeonFinder.GroupDungeonZones = {}
    LibDungeonFinder.ZoneActivityIds = {}
    for _, activityType in ipairs({ LFG_ACTIVITY_DUNGEON, LFG_ACTIVITY_MASTER_DUNGEON }) do
        local i = 1
        local activityId = GetActivityIdByTypeAndIndex(activityType, i)
        while activityId ~= 0 do
            local zoneId = GetActivityZoneId(activityId)
            if zoneId ~= 0 then
                LibDungeonFinder.GroupDungeonZones[zoneId] = true
                if not LibDungeonFinder.ZoneActivityIds[zoneId] then
                    LibDungeonFinder.ZoneActivityIds[zoneId] = activityId
                end
            end
            i = i + 1
            activityId = GetActivityIdByTypeAndIndex(activityType, i)
        end
    end
end

local function BuildSkillpointQuestLookup()
    LibDungeonFinder.SkillpointQuests = {}

    local skillpointSet = {}
    for _, questId in ipairs(LibQuestData.quest_has_skill_point) do
        skillpointSet[questId] = true
    end

    local zoneTextures = {}
    for texture, mapIds in pairs(LibMapData.textureNamesLookup) do
        for _, mapId in ipairs(mapIds) do
            local zoneId = GetZoneId(GetZoneIndexByMapId(mapId))
            if zoneId and zoneId ~= 0 and LibDungeonFinder.GroupDungeonZones[zoneId] then
                if not zoneTextures[zoneId] then zoneTextures[zoneId] = {} end
                zoneTextures[zoneId][texture] = true
            end
        end
    end

    local seen = {}
    for zoneId in pairs(LibDungeonFinder.GroupDungeonZones) do
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
                                if not LibDungeonFinder.SkillpointQuests[zoneId] then
                                    LibDungeonFinder.SkillpointQuests[zoneId] = {}
                                end
                                table.insert(LibDungeonFinder.SkillpointQuests[zoneId], questId)
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
    EVENT_MANAGER:UnregisterForEvent(LibDungeonFinder.name .. "_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= LibDungeonFinder.name then return end
    EVENT_MANAGER:UnregisterForEvent(LibDungeonFinder.name .. "_OnAddonLoaded", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(LibDungeonFinder.name .. "_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(LibDungeonFinder.name .. "_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
