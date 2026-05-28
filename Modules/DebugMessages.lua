-- this is leftover code from testing, it's not included in the manifest by default
-- but I left it in because it could be useful for other addon authors

local chat

local function Print(msg)
    if chat then
        chat:Print(msg)
    else
        d(msg)
    end
end

local function Printf(fmt, ...)
    if chat then
        chat:Printf(fmt, ...)
    else
        d(string.format(fmt, ...))
    end
end

-- Dungeon Finder summary: count locked vs unlocked group dungeons
local function PrintDFSummary()
    local locked, unlocked = 0, 0
    for zoneId in pairs(LibDF.GroupDungeonZones) do
        if LibDF.IsDungeonLocked(zoneId) then
            locked = locked + 1
        else
            unlocked = unlocked + 1
        end
    end
    Printf("Dungeon Finder: %d unlocked, %d locked", unlocked, locked)
end

local function OnZoneChanged(_, _, _, _, zoneId, _)
    if not LibDF.IsGroupDungeon(zoneId) then return end

    local zoneName = GetZoneNameById(zoneId)
    Print("--- LibDF: Entered " .. (zoneName or tostring(zoneId)) .. " ---")

    -- Group vs solo
    Printf("  Group dungeon: %s", tostring(LibDF.IsGroupDungeon(zoneId)))

    -- Unlock requirements (level/CP)
    local reqs = LibDF.GetRequirements(zoneId)
    if reqs then
        local parts = {}
        if reqs.minLevel then table.insert(parts, "Level " .. reqs.minLevel) end
        if reqs.minCP then table.insert(parts, "CP " .. reqs.minCP) end
        Print("  Requirements: " .. table.concat(parts, ", "))
    else
        Print("  Requirements: none")
    end

    -- DLC
    local dlcOwned = LibDF.IsDLCOwned(zoneId)
    if dlcOwned == nil then
        Print("  DLC: none required")
    else
        Printf("  DLC: %s | Locked: %s", tostring(dlcOwned), tostring(LibDF.IsDungeonLocked(zoneId)))
    end

    -- Skillpoint quest
    local questDone = LibDF.IsQuestFinished(zoneId)
    if questDone == nil then
        Print("  Skillpoint quest: unknown")
    elseif questDone then
        Print("  Skillpoint quest: done")
    else
        Print("  Skillpoint quest: not done")
    end

    -- Pledge
    local pledgeDone = LibDF.IsPledgeFinished(zoneId)
    if pledgeDone == nil then
        Print("  Pledge: not in journal")
    elseif pledgeDone then
        Print("  Pledge: complete")
    else
        Print("  Pledge: in progress")
    end
end

local function OnDFSceneStateChange(scene, oldState, newState)
    if newState == SCENE_SHOWING then
        PrintDFSummary()
    end
end

local sceneHooked = false

local function OnPlayerActivated()
    if not sceneHooked then
        local dfScene = SCENE_MANAGER:GetScene("activityFinder")
        if dfScene then
            dfScene:RegisterCallback("StateChange", OnDFSceneStateChange)
            sceneHooked = true
        end
    end

    EVENT_MANAGER:RegisterForEvent("LibDF_Debug_ZoneChanged", EVENT_ZONE_CHANGED, OnZoneChanged)

    -- EVENT_ZONE_CHANGED does not fire after a loading screen; check here instead
    OnZoneChanged(nil, nil, nil, nil, GetZoneId(GetUnitZoneIndex("player")), nil)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= "LibDF" then return end
    EVENT_MANAGER:UnregisterForEvent("LibDF_Debug_OnAddonLoaded", EVENT_ADD_ON_LOADED)

    if LibChatMessage then
        chat = LibChatMessage("LibDF Debug", "LDF")
    end

    LibDF.RegisterCallback("SpecificDungeonsOpened", function()
        Print("--- LibDF: Specific Dungeons opened ---")
    end)

    LibDF.RegisterCallback("SpecificDungeonsRefreshed", function()
        Print("--- LibDF: Specific Dungeons refreshed ---")
    end)

    LibDF.RegisterCallback("SpecificDungeonIterated", function(location)
        local lockStr = location:IsLocked() and " (locked)" or ""
        Printf("  [SpecificDungeonIterated] %s%s", location:GetRawName(), lockStr)
    end)

    LibDF.RegisterCallback("GroupDungeonEntered", function(zoneId)
        local zoneName = GetZoneNameById(zoneId)
        Print("--- LibDF: GroupDungeonEntered fired for " .. (zoneName or tostring(zoneId)) .. " ---")
    end)

    EVENT_MANAGER:RegisterForEvent("LibDF_Debug_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("LibDF_Debug_OnAddonLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)

SLASH_COMMANDS["/libdf"] = function()
    PrintDFSummary()
end
