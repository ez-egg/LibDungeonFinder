# LibDungeonFinder ⚔️

*AI assistance is used to error-check this library before release.*

**This library has just received a major update, in which it, its files, and its global table were renamed. If you downloaded version 1.0.0, please update!**

## Dependences

- [LibMapData](https://www.esoui.com/downloads/info3353-LibMapData.html) (Required)
- [LibQuestData](https://www.esoui.com/downloads/info2625-LibQuestData.html) (Required)

## Examples

### IsGroupDungeon

Returns `true` if the zone is a group dungeon.

```lua
if LibDungeonFinder.IsGroupDungeon(GetZoneId(GetUnitZoneIndex("player"))) then
    -- your code here
end
```

### IsDungeonLocked

Returns `true` if the dungeon is inaccessible due to a missing DLC or unmet level requirement.

```lua
if LibDungeonFinder.IsDungeonLocked(zoneId) then
    -- your code here
end
```

### IsDLCOwned

Returns `true` if the player owns the required DLC, `false` if not, or `nil` if no DLC is required.

```lua
local owned = LibDungeonFinder.IsDLCOwned(zoneId)
```

### GetRequirements

Returns a table with `minLevel` and/or `minCP`, or `nil` if there are no requirements.

```lua
local reqs = LibDungeonFinder.GetRequirements(zoneId)
if reqs then
    local level = reqs.minLevel
    local cp    = reqs.minCP
end
```

### IsQuestFinished

Returns `true` if the skillpoint quest for the dungeon is complete, `false` if not.

```lua
local done = LibDungeonFinder.IsQuestFinished(zoneId)
```

### IsPledgeFinished

Returns `true` if the active pledge for the dungeon is complete, `false` if in progress, or `nil` if no pledge is in the journal.

```lua
local done = LibDungeonFinder.IsPledgeFinished(zoneId)
```

### GroupDungeonEntered

Fires on `EVENT_ZONE_CHANGED` when the player enters a group dungeon.

```lua
LibDungeonFinder.RegisterCallback("GroupDungeonEntered", function(zoneId)
    local name = GetZoneNameById(zoneId)
end)
```

### SpecificDungeonsOpened

Fires once when the Specific Dungeons list becomes visible in the dungeon finder.

```lua
LibDungeonFinder.RegisterCallback("SpecificDungeonsOpened", function()
    -- your code here
end)
```

### SpecificDungeonsRefreshed

Fires once each time the Specific Dungeons list refreshes its contents, including when it is first opened.

```lua
LibDungeonFinder.RegisterCallback("SpecificDungeonsRefreshed", function()
    -- your code here
end)
```

### SpecificDungeonIterated

Fires once per entry in the Specific Dungeons list after each refresh, passing the entry's data.

```lua
LibDungeonFinder.RegisterCallback("SpecificDungeonIterated", function(location)
    local zoneId   = location:GetZoneId()
    local isLocked = location:IsLocked()
    local name     = location:GetRawName()
end)
```

```lua
:GetId()                                            activityId
:GetActivityType()                                  LFG_ACTIVITY_DUNGEON or LFG_ACTIVITY_MASTER_DUNGEON
:GetZoneId()                                        zoneId
:GetRawName()                                       dungeon name, unformatted
:GetNameKeyboard()                                  name with veteran icon prepended for master dungeons
:GetLevelMin() / :GetLevelMax()                     level range
:GetChampionPointsMin() / :GetChampionPointsMax()   CP range
:GetMinGroupSize() / :GetMaxGroupSize()             group size range
:GetDescription()                                   description text
:GetDescriptionTextureSmallKeyboard()               small art texture path
:GetDescriptionTextureLargeKeyboard()               large art texture path
:IsLocked()                                         true if locked (DLC, level, cooldown, etc.)
:GetLockReasonText()                                lock reason string, or nil
:IsSelected()                                       true if checked for queue
```
