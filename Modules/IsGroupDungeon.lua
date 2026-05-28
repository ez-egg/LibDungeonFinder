-- retrieve whether a dungeon is a group dungeon
-- returns false if it's not a group dungeon (so, an overland, solo, or quest instance)

function LibDF.IsGroupDungeon(zoneId)
    return LibDF.GroupDungeonZones[zoneId] == true
end
