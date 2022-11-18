gs = gsi()
_gnsi = gnsi()
_gsi = gsi()
--gsi = gsi()
gns = gnsi()
sti = spells_type_info()
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--is player human
function isHuman(player)
	return getPlayer(player).PlayerType == HUMAN_PLAYER
end

--is player alive
function isAlive(player)
	return GetPop(player) > 0
end

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--pow 2 turn
function every2Pow(a)
  if (_gsi.Counts.GameTurn % 2^a == 0) then
    return true else return false
  end
end

--pow 2 turn with offset
function every2PowOffset(pow,offset)
  local curr_turn = _gsi.Counts.GameTurn
  local turn_offset = curr_turn-offset
  if (turn_offset % 2^pow == 0) then
    return true
  else
    return false
  end
end

--every x
function every(a)
  if (_gsi.Counts.GameTurn % a == 0) then
    return true else return false
  end
end

--every x seconds
function everySeconds(a)
  if (_gsi.Counts.GameTurn % (a*12) == 0) then
    return true else return false
  end
end

--get turn
function turn()
	return gs.Counts.ProcessThings
end

--get second
function seconds()
	return math.floor(gs.Counts.ProcessThings/12)
end

--get minute
function minutes()
	return math.floor(seconds()/60)
end

--update game stage
function updateGameStage(early,medium,late,verylate)
	--if everySeconds(5) then
		if minutes() < early then
			G_GAMESTAGE = 0
		elseif minutes() < medium then
			G_GAMESTAGE = 1
		elseif minutes() < late then
			G_GAMESTAGE = 2
		elseif minutes() < verylate then
			G_GAMESTAGE = 3
		else
			G_GAMESTAGE = 4
		end
	--end
end

--quick random
function rnd()
	return math.random(100)
end
--quick random between
function rndb(a,b)
	return math.random(a,b)
end

--random item from a table
function randomItemFromTable(t)
  if (#t == 0) then
    return nil
  end

  local idx = math.random(1, #t)
  return t[idx], idx
end

--remove index from table
function removeFromTable(tbl, value)
	if tbl ~= nil then
		for k,v in ipairs(tbl) do
			if value == v then
				table.remove(tbl,k)
				break
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
--quick shaman nil
function nilS(tribe)
	if getShaman(tribe) ~= nil then return true else return false end
end
--quick nil thing
function nilT(thing)
	if thing ~= nil then return true else return false end
end

--pop of a tribe
function GetPop(pn)
  return _gsi.Players[pn].NumPeople
end

--troops of a tribe
function GetTroops(pn)
	local sh = 0 if getShaman(0) ~= nil then sh = 1 end
	return (_gsi.Players[pn].NumPeople - _gsi.Players[pn].NumPeopleOfType[M_PERSON_BRAVE]) - sh
end

--who has most pop
function GetPopLeader()
	local highestPop = 0
	local tribeWinning = -1
	for i = 0,7 do
		local pop = _gsi.Players[i].NumPeople
		if pop > highestPop then
			highestPop = pop
			tribeWinning = i
		end
	end

	return tribeWinning
end

--give up and sulk
function Sulk(tribe,pop)
	if minutes() > 5 and gs.Counts.ProcessThings % 64 == 0 then
		if _gsi.Players[tribe].NumPeople < pop then
			GIVE_UP_AND_SULK(tribe,TRUE)
		end
	end
end

--copy c3d
function CopyC3d(c3d)
	local nc3d = Coord3D.new()
	nc3d.Xpos = c3d.Xpos
	nc3d.Ypos = c3d.Ypos
	nc3d.Zpos = c3d.Zpos
	return nc3d
end

--move c3d offset
function MoveC3d(c3d,offset,heightOffset)
	c3d.Xpos = c3d.Xpos + math.random(-offset,offset) c3d.Zpos = c3d.Zpos + math.random(-offset,offset)
	if heightOffset then c3d.Ypos = c3d.Ypos + math.random(-offset,offset) end
	--if thing ~= nil then move_thing_within_mapwho(thing, c3d) end
	return c3d
end

--thing X coord
function ThingX(thing)
	if thing ~= nil then
		local pos = MapPosXZ.new()
		pos.Pos = world_coord3d_to_map_idx(thing.Pos.D3)
		return pos.XZ.X
	end
end
--thing Z coord
function ThingZ(thing)
	if thing ~= nil then
		local pos = MapPosXZ.new()
		pos.Pos = world_coord3d_to_map_idx(thing.Pos.D3)
		return pos.XZ.Z
	end
end

--coords to c3d
function coord_to_c3d(x,z)
	local c2d = Coord2D.new()
	map_xz_to_world_coord2d(x,z,c2d)
	local c3d = Coord3D.new()
	coord2D_to_coord3D(c2d,c3d)
	return c3d
end

--me ptr to c3d
function me2c3d(me)
	local _me = MAP_ELEM_PTR_2_IDX(me)
	local c3d = Coord3D.new()
	map_idx_to_world_coord3d_centre(_me,c3d)
	return c3d
end

--is thing in area
function IsThingInArea(thingType,thingModel,thingOwner,X,Z,radius)
	--thingOwner -1 for things of any tribe
	local pos = MapPosXZ.new() ; pos.XZ.X = X ; pos.XZ.Z = Z
	local exists = 0
	SearchMapCells(SQUARE ,0, 0, radius, pos.Pos, function(me)
		me.MapWhoList:processList( function (t)
			if t.Type == thingType and t.Model == thingModel and exists == 0 then
				if thingOwner == -1 then
					exists = 1
				else
					if t.Owner == thingOwner then
						exists = 1
					end
				end
			end
		return true end)
	return true end)

	return exists
end

--count things of type in area
function CountThingsOfTypeInArea(thingType,thingModel,thingOwner,X,Z,radius)
	--thingOwner -1 for things of any tribe
	local pos = MapPosXZ.new() ; pos.XZ.X = X ; pos.XZ.Z = Z
	local count = 0
	SearchMapCells(SQUARE ,0, 0, radius, pos.Pos, function(me)
		me.MapWhoList:processList( function (t)
			if t.Type == thingType and t.Model == thingModel then
				if thingOwner == -1 then
					count = count + 1
				else
					if t.Owner == thingOwner then
						count = count + 1
					end
				end
			end
		return true end)
	return true end)

	return count
end

--update base priorities
function updateBasePriorities(pn)
	updateGameStage(5,10,15,20)
	local s = G_GAMESTAGE
	--WriteAiTrainTroops(pn,s*)
end
--------------------------------------------------------------------------------------------------------------------------------------------
--read AI attacking troops (attr_away)
function ReadAIAttackers(pn)
	local b,w,r,fw,spy,sh = READ_CP_ATTRIB(pn,ATTR_AWAY_BRAVE),READ_CP_ATTRIB(pn,ATTR_AWAY_WARRIOR),READ_CP_ATTRIB(pn,ATTR_AWAY_RELIGIOUS),READ_CP_ATTRIB(pn,ATTR_AWAY_SUPER_WARRIOR),READ_CP_ATTRIB(pn,ATTR_AWAY_SPY),READ_CP_ATTRIB(pn,ATTR_AWAY_MEDICINE_MAN)
	log_msg(pn,"ATTACKERS:   br: " .. b .. ", wars: " .. w .. ", pr: " .. r .. ", fws: " .. fw .. ", spy: " .. spy .. ", shaman: " .. sh)
end

--read AI % troops to train (attr_pref)
function ReadAITroops(pn)
	local w,r,fw,spy = READ_CP_ATTRIB(pn,ATTR_PREF_WARRIOR_PEOPLE),READ_CP_ATTRIB(pn,ATTR_PREF_RELIGIOUS_PEOPLE),READ_CP_ATTRIB(pn,ATTR_PREF_SUPER_WARRIOR_PEOPLE),READ_CP_ATTRIB(pn,ATTR_PREF_SPY_PEOPLE)
	log_msg(pn,"% TROOPS:   wars: " .. w .. ", preachers: " .. r .. ", fws: " .. fw .. ", spy: " .. spy)
end

--write AI attacking troops(attr_away)
function WriteAiAttackers(pn,b,w,r,fw,spy,sh)
	WRITE_CP_ATTRIB(pn, ATTR_AWAY_BRAVE, b)
	WRITE_CP_ATTRIB(pn, ATTR_AWAY_WARRIOR, w)
	WRITE_CP_ATTRIB(pn, ATTR_AWAY_RELIGIOUS, r)
	WRITE_CP_ATTRIB(pn, ATTR_AWAY_SUPER_WARRIOR, fw)
	WRITE_CP_ATTRIB(pn, ATTR_AWAY_SPY, spy)
	WRITE_CP_ATTRIB(pn, ATTR_AWAY_MEDICINE_MAN, sh)
end

--write AI % train troops(attr_pref)
function WriteAiTrainTroops(pn,w,r,fw,spy)
	WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_PEOPLE, w)
	WRITE_CP_ATTRIB(pn, ATTR_PREF_RELIGIOUS_PEOPLE, r)
	WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_PEOPLE, fw)
	WRITE_CP_ATTRIB(pn, ATTR_PREF_SPY_PEOPLE, spy)
end

--preach at markers
function PreachAtMarkers(pn,idxS,idxE)
	for i = idxS,idxE do
		PREACH_AT_MARKER(pn,i)
	end
end

--count huts
function countHuts(pn, includeDamaged)
	if includeDamaged then 
		return _gsi.Players[pn].NumBuiltOrPartBuiltBuildingsOfType[1]+_gsi.Players[pn].NumBuiltOrPartBuiltBuildingsOfType[2]+_gsi.Players[pn].NumBuiltOrPartBuiltBuildingsOfType[3]
	end
	return _gsi.Players[pn].NumBuildingsOfType[1]+_gsi.Players[pn].NumBuildingsOfType[2]+_gsi.Players[pn].NumBuildingsOfType[3]
end

--count towers
function countTowers(pn, includeDamaged)
	if includeDamaged then 
		return _gsi.Players[pn].NumBuiltOrPartBuiltBuildingsOfType[4]
	end
	return _gsi.Players[pn].NumBuildingsOfType[4]
end

--fill towers (fills all tribe's towers prioritizing one unit type)
function FillTowers(pn,coord,unit) --1fw 2pre 3war 4spy 5brave
	local unitType = M_PERSON_SUPER_WARRIOR
	if unit == 2 then unitType = M_PERSON_RELIGIOUS elseif unit == 3 then unitType = M_PERSON_WARRIOR elseif unit == 4 then unitType = M_PERSON_SPY elseif unit == 5 then unitType = M_PERSON_BRAVE end
	ProcessGlobalSpecialList(pn, BUILDINGLIST, function(b)
		if b.Model == M_BUILDING_DRUM_TOWER then
			PUT_PERSON_IN_DT (pn, unitType,ThingX(b),ThingZ(b))
		end
	return true end)
end

--fill marker towers
function FillMkTowers(pn,idxS,idxE,unit)
	local unitType = M_PERSON_SUPER_WARRIOR
	if unit == 2 then unitType = M_PERSON_RELIGIOUS elseif unit == 3 then unitType = M_PERSON_WARRIOR elseif unit == 4 then unitType = M_PERSON_SPY elseif unit == 5 then unitType = M_PERSON_BRAVE end
	for i = idxS,idxE do
		local pos = MapPosXZ.new()
		pos.Pos = world_coord3d_to_map_idx(marker_to_coord3d(i))
		PUT_PERSON_IN_DT (pn, unitType, pos.XZ.X,pos.XZ.Z)
	end
end

--occasionally burn trees near X coordinate (usually blue's base)
function burnTrees(seconds,tribe,x,z,radius)
	local ShInArea = CountThingsOfTypeInArea(T_PERSON,M_PERSON_MEDICINE_MAN,tribe,x,z,radius)
	if getShaman(tribe) ~= nil then
		if everySeconds(seconds) then
			if ShInArea == 1 and (getShaman(tribe).Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0) then
				SearchMapCells(SQUARE, 0, 0 , 5, world_coord3d_to_map_idx(getShaman(tribe).Pos.D3), function(me)
					me.MapWhoList:processList(function (t)
						if t.Type == T_SCENERY and t.Model < 7 then
							if t.State == 1 then
								local Sstate = getShaman(tribe).State
								if Sstate == 10 or Sstate == 17 or Sstate == 18 or Sstate == 19 then
									createThing(T_SPELL,M_SPELL_BLAST,tribe,t.Pos.D3,false,false)
									GIVE_MANA_TO_PLAYER(tribe,-10000)
								end
							end
						end
					return true end)
				return true end)
			end
		end
	end
end

--occasionally shield unit(s) when in certain zone (good for when attacking)
function useShield(seconds,tribe,x,z,radius)
	local ShInArea = CountThingsOfTypeInArea(T_PERSON,M_PERSON_MEDICINE_MAN,tribe,x,z,radius)
	local r = 0
	if getShaman(tribe) ~= nil then
		if everySeconds(seconds) then
			if ShInArea == 1 and (getShaman(tribe).Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0) then
				SearchMapCells(SQUARE, 0, 0 , 5, world_coord3d_to_map_idx(getShaman(tribe).Pos.D3), function(me)
					me.MapWhoList:processList(function (t)
						if t.Type == T_PERSON and t.Owner == tribe and t.Model > 2 and t.Model < 7 then
							if isShielded(t) == 0 and isGhost(t) == 0 and r == 0 then
								createThing(T_SPELL,M_SPELL_SHIELD,tribe,t.Pos.D3,false,false)
								GIVE_MANA_TO_PLAYER(tribe,-30000)
								r = 1
							end
						end
					return true end)
				return true end)
			end
		end
	end
end

--troops train faster
function fasterTrain(tribe, amt)
	ProcessGlobalSpecialList(tribe, BUILDINGLIST, function(t)
			if (t.u.Bldg.ShapeThingIdx:isNull()) then
				if (t.u.Bldg.TrainingManaCost > 0) then
					t.u.Bldg.TrainingManaStored = t.u.Bldg.TrainingManaStored + amt
				end
			end
	return true end)
end
--buildings faster green red bar
function fasterHutBars(tribe, amt)
	ProcessGlobalSpecialList(tribe, BUILDINGLIST, function(b)
		if (b.Model <= 3) then
			if (b.u.Bldg.UpgradeCount < 1850) then
				b.u.Bldg.UpgradeCount = b.u.Bldg.UpgradeCount + amt
			end
			if (b.u.Bldg.SproggingCount < 1000) then
				b.u.Bldg.SproggingCount = b.u.Bldg.SproggingCount + amt
			end
		end
	return true end)
end
--------------------------------------------------------------------------------------------------------------------------------------------
--flags
function EnableFlag(_f1, _f2)
    if (_f1 & _f2 == 0) then
        _f1 = _f1 | _f2
    end
    return _f1
end
function DisableFlag(_f1, _f2)
    if (_f1 & _f2 == _f2) then
        _f1 = _f1 ~ _f2
    end
    return _f1
end

--check if thing has X flag
function isGhost(thing)
	if thing ~= nil then
		if thing.Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0 then return 0 else return 1 end
	end
end
function isInvisible(thing)
	if thing ~= nil then
		if thing.Flags2 & TF2_THING_IS_AN_INVISIBLE_PERSON == 0 then return 0 else return 1 end
	end
end
function isBloodlusted(thing)
	if thing ~= nil then
		if thing.Flags3 & TF3_BLOODLUST_ACTIVE == 0 then return 0 else return 1 end
	end
end
function isShielded(thing)
	if thing ~= nil then
		if thing.Flags3 & TF3_SHIELD_ACTIVE == 0 then return 0 else return 1 end
	end
end

--give a certain flag to a thing (for X seconds)
function giveShield(thing,duration)
	if thing ~= nil then
		thing.Flags3 = EnableFlag(thing.Flags3, TF3_SHIELD_ACTIVE)
		if duration ~= -1 then thing.u.Pers.u.Owned.ShieldCount = math.floor(1.6 * duration) end
	end
end
function giveBloodlust(thing,duration)
	if thing ~= nil then
		thing.Flags3 = EnableFlag(thing.Flags3, TF3_BLOODLUST_ACTIVE)
		if duration ~= -1 then thing.u.Pers.u.Owned.BloodlustCount = math.floor(1.6 * duration) end
	end
end
function giveInvisibility(thing,duration)
	if thing ~= nil then
		thing.Flags2 = EnableFlag(thing.Flags2, TF2_THING_IS_AN_INVISIBLE_PERSON)
		if duration ~= -1 then thing.u.Pers.u.Owned.InvisibleCount = math.floor(1.6 * duration) end
	end
end
function makeGhost(thing)
	if thing ~= nil then
		thing.Flags2 = EnableFlag(thing.Flags2, TF2_THING_IS_A_GHOST_PERSON)
	end
end

--remove a certain flag
function removeShield(thing)
	if thing ~= nil then
		thing.Flags3 = DisableFlag(thing.Flags3, TF3_SHIELD_ACTIVE)
	end
end
function removeBloodlust(thing)
	if thing ~= nil then
		thing.Flags3 = DisableFlag(thing.Flags3, TF3_BLOODLUST_ACTIVE)
	end
end
function removeInvisibility(thing)
	if thing ~= nil then
		thing.Flags2 = DisableFlag(thing.Flags2, TF2_THING_IS_AN_INVISIBLE_PERSON)
	end
end

--win/lose levels
function WIN()
	gns.GameParams.Flags2 = gns.GameParams.Flags2 & ~GPF2_GAME_NO_WIN
	gns.Flags = gns.Flags | GNS_LEVEL_COMPLETE
end
function LOSE()
	gns.GameParams.Flags2 = gns.GameParams.Flags2 & ~GPF2_GAME_NO_WIN
	gns.Flags = gns.Flags | GNS_LEVEL_FAILED
end

--reset spells sprites
function ResetSpellsSprites()
	for i = 2,17 do
		G_SPELL_CONST[i].AvailableSpriteIdx = 353+i
	end
	G_SPELL_CONST[19].AvailableSpriteIdx = 408
end
--------------------------------------------------------------------------------------------------------------------------------------------
PThing = {}
--set spell
PThing.SpellSet = function (player, spell, input, charge)
  if (input == 0) then
    _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable ~ (1<<spell);
	else
		if (charge == 0) then
			_gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging = _gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging | (1<<spell-1);
		else
			_gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging = _gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging ~ (1<<spell-1);
		end
		_gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable | (1<<spell);
	end
end

--set building
PThing.BldgSet = function (player, building, input)
  if (input == 0) then
		_gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable ~ (1<<building);
	else
		_gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable | (1<<building);
	end
end

--give shot
PThing.GiveShot = function (player, spell, amount)
  if (amount > sti[spell].OneOffMaximum) then
    _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailableOnce[spell] = 4
  else
    _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailableOnce[spell] = _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailableOnce[spell] + amount
  end
end

--get me a random person
function get_me_a_random_person(tribe)
	if _gsi.Players[tribe].NumPeople < 1 then return nil end
	local things = {}
	ProcessGlobalSpecialList(tribe, PEOPLELIST, function(t)
		if t.Model ~= M_PERSON_ANGEL then
			table.insert(things,t)
		end
	return true end)

	return randomItemFromTable(things)
end

--get me a random building
function get_me_a_random_building(tribe,onlyHuts,includeDamaged)
	local things = {}
	ProcessGlobalSpecialList(tribe, BUILDINGLIST, function(t)
		if onlyHuts == true then
			if t.Model <= 3 then
				if includeDamaged == true then
					table.insert(things,t)
				else
					if t.State == 2 then
						table.insert(things,t)
					end
				end
			end
		else
			if t.Model < M_BUILDING_GUARD_POST then
				if includeDamaged == true then
					table.insert(things,t)
				else
					if t.State == 2 then
						table.insert(things,t)
					end
				end
			end
		end
	return true end)

	if #things == 0 then return nil else return randomItemFromTable(things) end
end

--plant scenery
function Plant(IdxS,IdxE,drawnum) -- pick -1 for random plants, or specify
	for i = IdxS,IdxE do
		local plants = createThing(T_SCENERY,M_SCENERY_PLANT_2,8,marker_to_coord3d(i),false,false) centre_coord3d_on_block(plants.Pos.D3)
		if drawnum == -1 then plants.DrawInfo.DrawNum = math.random(1808,1817) else plants.DrawInfo.DrawNum = drawnum end --still need to add plant types to HFX
		plants.DrawInfo.Alpha = -16 plants.DrawInfo.Flags = EnableFlag(plants.DrawInfo.Flags, DF_USE_ENGINE_SHADOW)
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
--timer to h/m/s
function TurnsToClock(initialCountdown)
  local initialCountdown = tonumber(initialCountdown)
  if initialCountdown <= 0 then
    return "00:00";
  else
    hours = string.format("%02.f", math.floor(initialCountdown/3600));
    mins = string.format("%02.f", math.floor(initialCountdown/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(initialCountdown - hours*3600 - mins *60));
    return mins..":"..secs
  end
end

--mouse percent to screen value
function percentofW(Wpercent)
    if tonumber(Wpercent) then
        return math.ceil((Wpercent*ScreenWidth())/100)
    end
    return false
end
function percentofH(Hpercent)
    if tonumber(Hpercent) then
        return math.ceil((Hpercent*ScreenHeight())/100)
    end
    return false
end

--mouse screen value to percent
function mouseXp(X)
	if tonumber(X) then return math.floor((X*100)/ScreenWidth()) end return false
end
function mouseYp(Y)
	if tonumber(Y) then return math.floor((Y*100)/ScreenHeight()) end return false
end

--is mouse cursor between 4 values
function isCursorBetween(Xcurr,Ycurr,   Xmin,Xmax,Ymin,Ymax)
	if Xcurr > Xmin and Xcurr <= Xmax then
		if Ycurr > Ymin and Ycurr <= Ymax then
			return true
		end
	end
	return false
end
--------------------------------------------------------------------------------------------------------------------------------------------
--debug
function LOG(msg)
	log_msg(8,"turn: " .. turn() .. "  |   " .. tostring(msg))
end
--------------------------------------------------------------------------------------------------------------------------------------------
