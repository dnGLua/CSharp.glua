local define = System.defStc
local setmetatable = setmetatable

local handle = define("War3ApiCommon.handle", {
})
local agent = define("War3ApiCommon.agent", {
  base = { handle }
})
local event = define("War3ApiCommon.event", {
  base = { agent }
})
local player = define("War3ApiCommon.player", {
  base = { agent }
})
local widget = define("War3ApiCommon.widget", {
  base = { agent }
})
local unit = define("War3ApiCommon.unit", {
  base = { widget }
})
local destructable = define("War3ApiCommon.destructable", {
  base = { widget }
})
local item = define("War3ApiCommon.item", {
  base = { widget }
})
local ability = define("War3ApiCommon.ability", {
  base = { agent }
})
local buff = define("War3ApiCommon.buff", {
  base = { ability }
})
local force = define("War3ApiCommon.force", {
  base = { agent }
})
local group = define("War3ApiCommon.group", {
  base = { agent }
})
local trigger = define("War3ApiCommon.trigger", {
  base = { agent }
})
local triggercondition = define("War3ApiCommon.triggercondition", {
  base = { agent }
})
local triggeraction = define("War3ApiCommon.triggeraction", {
  base = { handle }
})
local timer = define("War3ApiCommon.timer", {
  base = { agent }
})
local location = define("War3ApiCommon.location", {
  base = { agent }
})
local region = define("War3ApiCommon.region", {
  base = { agent }
})
local rect = define("War3ApiCommon.rect", {
  base = { agent }
})
local boolexpr = define("War3ApiCommon.boolexpr", {
  base = { agent }
})
local sound = define("War3ApiCommon.sound", {
  base = { agent }
})
local conditionfunc = define("War3ApiCommon.conditionfunc", {
  base = { boolexpr }
})
local filterfunc = define("War3ApiCommon.filterfunc", {
  base = { boolexpr }
})
local unitpool = define("War3ApiCommon.unitpool", {
  base = { handle }
})
local itempool = define("War3ApiCommon.itempool", {
  base = { handle }
})
local race = define("War3ApiCommon.race", {
  base = { handle }
})
local alliancetype = define("War3ApiCommon.alliancetype", {
  base = { handle }
})
local racepreference = define("War3ApiCommon.racepreference", {
  base = { handle }
})
local gamestate = define("War3ApiCommon.gamestate", {
  base = { handle }
})
local igamestate = define("War3ApiCommon.igamestate", {
  base = { gamestate }
})
local fgamestate = define("War3ApiCommon.fgamestate", {
  base = { gamestate }
})
local playerstate = define("War3ApiCommon.playerstate", {
  base = { handle }
})
local playerscore = define("War3ApiCommon.playerscore", {
  base = { handle }
})
local playergameresult = define("War3ApiCommon.playergameresult", {
  base = { handle }
})
local unitstate = define("War3ApiCommon.unitstate", {
  base = { handle }
})
local aidifficulty = define("War3ApiCommon.aidifficulty", {
  base = { handle }
})
local eventid = define("War3ApiCommon.eventid", {
  base = { handle }
})
local gameevent = define("War3ApiCommon.gameevent", {
  base = { eventid }
})
local playerevent = define("War3ApiCommon.playerevent", {
  base = { eventid }
})
local playerunitevent = define("War3ApiCommon.playerunitevent", {
  base = { eventid }
})
local unitevent = define("War3ApiCommon.unitevent", {
  base = { eventid }
})
local limitop = define("War3ApiCommon.limitop", {
  base = { eventid }
})
local widgetevent = define("War3ApiCommon.widgetevent", {
  base = { eventid }
})
local dialogevent = define("War3ApiCommon.dialogevent", {
  base = { eventid }
})
local unittype = define("War3ApiCommon.unittype", {
  base = { handle }
})
local gamespeed = define("War3ApiCommon.gamespeed", {
  base = { handle }
})
local gamedifficulty = define("War3ApiCommon.gamedifficulty", {
  base = { handle }
})
local gametype = define("War3ApiCommon.gametype", {
  base = { handle }
})
local mapflag = define("War3ApiCommon.mapflag", {
  base = { handle }
})
local mapvisibility = define("War3ApiCommon.mapvisibility", {
  base = { handle }
})
local mapsetting = define("War3ApiCommon.mapsetting", {
  base = { handle }
})
local mapdensity = define("War3ApiCommon.mapdensity", {
  base = { handle }
})
local mapcontrol = define("War3ApiCommon.mapcontrol", {
  base = { handle }
})
local playerslotstate = define("War3ApiCommon.playerslotstate", {
  base = { handle }
})
local volumegroup = define("War3ApiCommon.volumegroup", {
  base = { handle }
})
local camerafield = define("War3ApiCommon.camerafield", {
  base = { handle }
})
local camerasetup = define("War3ApiCommon.camerasetup", {
  base = { handle }
})
local playercolor = define("War3ApiCommon.playercolor", {
  base = { handle }
})
local placement = define("War3ApiCommon.placement", {
  base = { handle }
})
local startlocprio = define("War3ApiCommon.startlocprio", {
  base = { handle }
})
local raritycontrol = define("War3ApiCommon.raritycontrol", {
  base = { handle }
})
local blendmode = define("War3ApiCommon.blendmode", {
  base = { handle }
})
local texmapflags = define("War3ApiCommon.texmapflags", {
  base = { handle }
})
local effect = define("War3ApiCommon.effect", {
  base = { agent }
})
local effecttype = define("War3ApiCommon.effecttype", {
  base = { handle }
})
local weathereffect = define("War3ApiCommon.weathereffect", {
  base = { handle }
})
local terraindeformation = define("War3ApiCommon.terraindeformation", {
  base = { handle }
})
local fogstate = define("War3ApiCommon.fogstate", {
  base = { handle }
})
local fogmodifier = define("War3ApiCommon.fogmodifier", {
  base = { agent }
})
local dialog = define("War3ApiCommon.dialog", {
  base = { agent }
})
local button = define("War3ApiCommon.button", {
  base = { agent }
})
local quest = define("War3ApiCommon.quest", {
  base = { agent }
})
local questitem = define("War3ApiCommon.questitem", {
  base = { agent }
})
local defeatcondition = define("War3ApiCommon.defeatcondition", {
  base = { agent }
})
local timerdialog = define("War3ApiCommon.timerdialog", {
  base = { agent }
})
local leaderboard = define("War3ApiCommon.leaderboard", {
  base = { agent }
})
local multiboard = define("War3ApiCommon.multiboard", {
  base = { agent }
})
local multiboarditem = define("War3ApiCommon.multiboarditem", {
  base = { agent }
})
local trackable = define("War3ApiCommon.trackable", {
  base = { agent }
})
local gamecache = define("War3ApiCommon.gamecache", {
  base = { agent }
})
local version = define("War3ApiCommon.version", {
  base = { handle }
})
local itemtype = define("War3ApiCommon.itemtype", {
  base = { handle }
})
local texttag = define("War3ApiCommon.texttag", {
  base = { handle }
})
local attacktype = define("War3ApiCommon.attacktype", {
  base = { handle }
})
local damagetype = define("War3ApiCommon.damagetype", {
  base = { handle }
})
local weapontype = define("War3ApiCommon.weapontype", {
  base = { handle }
})
local soundtype = define("War3ApiCommon.soundtype", {
  base = { handle }
})
local lightning = define("War3ApiCommon.lightning", {
  base = { handle }
})
local pathingtype = define("War3ApiCommon.pathingtype", {
  base = { handle }
})
local mousebuttontype = define("War3ApiCommon.mousebuttontype", {
  base = { handle }
})
local animtype = define("War3ApiCommon.animtype", {
  base = { handle }
})
local subanimtype = define("War3ApiCommon.subanimtype", {
  base = { handle }
})
local image = define("War3ApiCommon.image", {
  base = { handle }
})
local ubersplat = define("War3ApiCommon.ubersplat", {
  base = { handle }
})
local hashtable = define("War3ApiCommon.hashtable", {
  base = { agent }
})
local framehandle = define("War3ApiCommon.framehandle", {
  base = { handle }
})
local originframetype = define("War3ApiCommon.originframetype", {
  base = { handle }
})
local framepointtype = define("War3ApiCommon.framepointtype", {
  base = { handle }
})
local textaligntype = define("War3ApiCommon.textaligntype", {
  base = { handle }
})
local frameeventtype = define("War3ApiCommon.frameeventtype", {
  base = { handle }
})
local oskeytype = define("War3ApiCommon.oskeytype", {
  base = { handle }
})
local abilityintegerfield = define("War3ApiCommon.abilityintegerfield", {
  base = { handle }
})
local abilityrealfield = define("War3ApiCommon.abilityrealfield", {
  base = { handle }
})
local abilitybooleanfield = define("War3ApiCommon.abilitybooleanfield", {
  base = { handle }
})
local abilitystringfield = define("War3ApiCommon.abilitystringfield", {
  base = { handle }
})
local abilityintegerlevelfield = define("War3ApiCommon.abilityintegerlevelfield", {
  base = { handle }
})
local abilityreallevelfield = define("War3ApiCommon.abilityreallevelfield", {
  base = { handle }
})
local abilitybooleanlevelfield = define("War3ApiCommon.abilitybooleanlevelfield", {
  base = { handle }
})
local abilitystringlevelfield = define("War3ApiCommon.abilitystringlevelfield", {
  base = { handle }
})
local abilityintegerlevelarrayfield = define("War3ApiCommon.abilityintegerlevelarrayfield", {
  base = { handle }
})
local abilityreallevelarrayfield = define("War3ApiCommon.abilityreallevelarrayfield", {
  base = { handle }
})
local abilitybooleanlevelarrayfield = define("War3ApiCommon.abilitybooleanlevelarrayfield", {
  base = { handle }
})
local abilitystringlevelarrayfield = define("War3ApiCommon.abilitystringlevelarrayfield", {
  base = { handle }
})
local unitintegerfield = define("War3ApiCommon.unitintegerfield", {
  base = { handle }
})
local unitrealfield = define("War3ApiCommon.unitrealfield", {
  base = { handle }
})
local unitbooleanfield = define("War3ApiCommon.unitbooleanfield", {
  base = { handle }
})
local unitstringfield = define("War3ApiCommon.unitstringfield", {
  base = { handle }
})
local unitweaponintegerfield = define("War3ApiCommon.unitweaponintegerfield", {
  base = { handle }
})
local unitweaponrealfield = define("War3ApiCommon.unitweaponrealfield", {
  base = { handle }
})
local unitweaponbooleanfield = define("War3ApiCommon.unitweaponbooleanfield", {
  base = { handle }
})
local unitweaponstringfield = define("War3ApiCommon.unitweaponstringfield", {
  base = { handle }
})
local itemintegerfield = define("War3ApiCommon.itemintegerfield", {
  base = { handle }
})
local itemrealfield = define("War3ApiCommon.itemrealfield", {
  base = { handle }
})
local itembooleanfield = define("War3ApiCommon.itembooleanfield", {
  base = { handle }
})
local itemstringfield = define("War3ApiCommon.itemstringfield", {
  base = { handle }
})
local movetype = define("War3ApiCommon.movetype", {
  base = { handle }
})
local targetflag = define("War3ApiCommon.targetflag", {
  base = { handle }
})
local armortype = define("War3ApiCommon.armortype", {
  base = { handle }
})
local heroattribute = define("War3ApiCommon.heroattribute", {
  base = { handle }
})
local defensetype = define("War3ApiCommon.defensetype", {
  base = { handle }
})
local regentype = define("War3ApiCommon.regentype", {
  base = { handle }
})
local unitcategory = define("War3ApiCommon.unitcategory", {
  base = { handle }
})
local pathingflag = define("War3ApiCommon.pathingflag", {
  base = { handle }
})
