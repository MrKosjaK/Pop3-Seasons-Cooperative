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
  if (_gsi.Counts.ProcessThings % 2^a == 0) then
    return true else return false
  end
end

--pow 2 turn with offset
function every2PowOffset(pow,offset)
  local curr_turn = _gsi.Counts.ProcessThings
  local turn_offset = curr_turn-offset
  if (turn_offset % 2^pow == 0) then
    return true
  else
    return false
  end
end

--every x
function every(a)
  if (_gsi.Counts.ProcessThings % a == 0) then
    return true else return false
  end
end

--every x seconds
function everySeconds(a)
  if (_gsi.Counts.ProcessThings % (a*12) == 0) then
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
	return G_RANDOM(100)
end
--quick random between
function rndb(a,b)
	if a == b then return a end
	return a + G_RANDOM(b-a) + 1
end

--random item from a table
function randomItemFromTable(t)
  if (#t == 0) then
    return nil
  end

  local idx = rndb(1, #t)
  return t[idx]
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

--is item in table
function isItemInTable(tbl,item)
	for k,v in ipairs(tbl) do
		if v == item then return true end
	end
	return false
end

--pick an item of 2 items, with chances
function iipp(item1,item2,percentage1,percentage2)
	if rnd() < percentage1 then return item1 end
	return item2
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
function countTroops(pn)
	local sh = 0 if getShaman(0) ~= nil then sh = 1 end
	return (_gsi.Players[pn].NumPeople - _gsi.Players[pn].NumPeopleOfType[M_PERSON_BRAVE]) - sh
end

--boats of a tribe
function countBoats(pn)
	return _gsi.Players[pn].NumVehiclesOfType[M_VEHICLE_BOAT_1]
end
--balloons of a tribe
function countBalloons(pn)
	return _gsi.Players[pn].NumVehiclesOfType[M_VEHICLE_AIRSHIP_1]
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
	c3d.Xpos = c3d.Xpos + rndb(-offset,offset) c3d.Zpos = c3d.Zpos + rndb(-offset,offset)
	if heightOffset then c3d.Ypos = c3d.Ypos + rndb(-offset,offset) end
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

--marker to XZ.X
function markerIdxX(marker)
	local m = MapPosXZ.new()
	m.Pos = world_coord3d_to_map_idx(marker_to_coord3d(marker))
	
	return m.XZ.X
end
--marker to XZ.Z
function markerIdxZ(marker)
	local m = MapPosXZ.new()
	m.Pos = world_coord3d_to_map_idx(marker_to_coord3d(marker))
	
	return m.XZ.Z
end

--is marker land
function isMkLand(mk)
	local is = false
	SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(marker_to_coord3d(mk)), function(me)
		if is_map_elem_all_land(me) > 0 then is = true end
	return true end)
	
	return is
end
--is marker water
function isMkWater(mk)
	local is = false
	SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(marker_to_coord3d(mk)), function(me)
		if is_map_elem_all_sea(me) > 0 then is = true end
	return true end)
	
	return is
end

--shaman stuck
function stuckS(pn)
	if nilS(pn) then return getShaman(pn).State == S_PERSON_NAVIGATION_FAILED end
end
--thing stuck
function stuckT(thing)
	if nilT(thing) then return thing.State == S_PERSON_NAVIGATION_FAILED end
end

--unstuck shaman
function unstuckS(pn)
	if stuckS(pn) then 
		getShaman(pn).State = S_PERSON_SCATTER
		remove_all_persons_commands(getShaman(pn))
	end
end
--unstuck thing
function unstuckT(thing)
	if stuckT(thing) then  
		thing.State = S_PERSON_SCATTER  
		remove_all_persons_commands(thing)
	end
end

--is shaman is their base area
function isShamanHome(pn,marker,radius)
	return IS_SHAMAN_IN_AREA(pn,marker,radius) == 1
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

--count things of type in area (without ghosts)
function CountThingsOfTypeInArea(thingType,thingModel,thingOwner,X,Z,radius)
	--thingOwner -1 for things of any tribe
	local pos = MapPosXZ.new() ; pos.XZ.X = X ; pos.XZ.Z = Z
	local count = 0
	SearchMapCells(SQUARE ,0, 0, radius, pos.Pos, function(me)
		me.MapWhoList:processList( function (t)
			if t.Type == thingType and t.Model == thingModel and not isGhost(thing) then
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

--count people in area (without ghosts)
function countPeopleInArea(tribe,marker,radius)
	local count = 0
	SearchMapCells(SQUARE, 0, 0 , radius, world_coord3d_to_map_idx(marker_to_coord3d(marker)), function(me)
		me.MapWhoList:processList(function (t)
			if t.Type == T_PERSON then
				if t.Model >= 2 and t.Model <= 7 then
					if not isGhost(t) then
						if tribe == -1 then
							count = count + 1
						else
							if t.Owner == tribe then
								count = count + 1
							end
						end
					end
				end
			end
		return true end)
	return true end)
	
	return count
end

--is bldg near
function isBuildingNear(model,pn,c3d,radius)
	local result = 0
	SearchMapCells(SQUARE, 0, 0 , radius, world_coord3d_to_map_idx(c3d), function(me)
		me.MapWhoList:processList(function (t)
			if t.Type == T_BUILDING then
				if model == -1 then
					if pn == -1 then
						result = 1 return false
					else
						if t.Owner == pn then result = 1 return false end
					end
				else
					if t.Model == model then
						if pn == -1 then
							result = 1 return false
						else
							if t.Owner == pn then result = 1 return false end
						end
					end
				end
			end
		return true end)
	return true end)
	
	return ntb(result) --!includes damaged buildings!
end

--blast, swarm, or hypno enemies near a shaman
function GetRidOfNearbyEnemies(pn,radius,successChance)
	if rnd() < successChance then
		local casted = false
		if G_GAMESTAGE >= 3 then radius = radius + 1 end
		local spell = M_SPELL_BLAST if G_GAMESTAGE >= 2 then if rnd() < 20 then spell = M_SPELL_INSECT_PLAGUE end if G_GAMESTAGE >= 3 then if rnd() < 15 then spell = M_SPELL_HYPNOTISM end end end
		if nilS(pn) then
			SearchMapCells(SQUARE, 0, 0 , radius, world_coord3d_to_map_idx(getShaman(pn).Pos.D3), function(me)
				me.MapWhoList:processList(function (t)
					if t.Type == T_PERSON and t.Model ~= M_PERSON_ANGEL and t.State ~= S_PERSON_WAIT_IN_BLDG then
						if isItemInTable(G_HUMANS_ALIVE,t.Owner) and not casted then
							GIVE_ONE_SHOT(spell,pn)
							local s = createThing(T_SPELL,spell,pn,t.Pos.D3,false,false)
							s.u.Spell.TargetThingIdx:set(1)
							casted = true
						end
					end
				return true end)
			return true end)
		end
	end
end

--light enemies near shaman
function TargetNearbyShamans(pn,radius,successChance)
	local spell = M_SPELL_LIGHTNING_BOLT
	
	if rnd() < successChance then
		if nilS(pn) then
			if getShaman(pn).State ~= S_PERSON_SPELL_TRANCE and (getShaman(pn).Flags2 & TF2_THING_IN_AIR == 0) then
				gns.ThisLevelHeader.Markers[254] = world_coord3d_to_map_idx(getShaman(pn).Pos.D3)
				for k,v in ipairs(G_HUMANS_ALIVE) do
					if IS_SHAMAN_IN_AREA(v,254,radius) == 1 then --baited by ghost shamans gg
						local caster,targ = getShaman(pn),getShaman(v)
						local dist = get_world_dist_xz(getShaman(pn).Pos.D2,targ.Pos.D2)
						if dist < 512*14 then
							GIVE_ONE_SHOT(spell,pn)
							if dist < 512*6 then
								local s = createThing(T_SPELL,spell,pn,targ.Pos.D3,false,false)
								s.u.Spell.TargetThingIdx:set(1)
							else
								if getShaman(pn).State ~= S_PERSON_NAVIGATION_FAILED then
									local cmd = get_thing_curr_cmd_list_ptr(targ)
									if (cmd ~= nil) then
										local function mathsAndCast(targetsTargetD2)
											local z = (targetsTargetD2.Zpos - targ.Pos.D2.Zpos)
											local x = (targetsTargetD2.Xpos - targ.Pos.D2.Xpos)
											local ax = math.abs(x)
											local az = math.abs(z)
											local angle = math.atan(z, x) * 180 / math.pi
											angle = math.ceil(angle)
											if (angle<0) then
												angle=angle+360
											end
											local rotation = (angle * math.pi) / 180
											local distOffset = 512+8*math.floor(dist/256)
											local spawnC3d = Coord3D.new()
											spawnC3d.Xpos = math.ceil(targ.Pos.D3.Xpos + (math.cos(rotation) * distOffset))
											spawnC3d.Zpos = math.ceil(targ.Pos.D3.Zpos + (math.sin(rotation) * distOffset))
											spawnC3d.Ypos = targ.Pos.D3.Ypos
											local s = createThing(T_SPELL,spell,pn,spawnC3d,false,false)
										end
										if cmd.CommandType == CMD_ATTACK_TARGET --[[or cmd.CommandType == CMD_ATTACK_AREA_2]] then
											if nilT(cmd.u.TargetIdx:get()) then
												local t = cmd.u.TargetIdx:get()
												local c2d = t.Pos.D2
												mathsAndCast(c2d) break
											end
										elseif cmd.CommandType == CMD_GOTO_POINT then
											if cmd.u.TargetCoord ~= nil then
												mathsAndCast(cmd.u.TargetCoord) break
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

--try to dodge enemy lights
function dodgeLightnings(caster,successChance,lightThing)
	if rnd() < successChance then
		if nilT(lightThing) then
			for k,v in ipairs(G_AI_ALIVE) do
				if nilS(v) and caster ~= v then
					if (getShaman(v).Flags2 & TF2_THING_IN_AIR == 0) then
						local function ShDodge(distance,inTowerBool)
							if distance < 256 then
								if not inTowerBool then
									if rnd() < 50 then
										getShaman(v).State = S_PERSON_SCATTER
									end
								else
									local success = false
									local c2d = Coord2D.new()
									SearchMapCells(SQUARE, 0, 0 , 1, world_coord3d_to_map_idx(getShaman(v).Pos.D3), function(me)
										if rnd() < 30 and not success then
											coord3D_to_coord2D(me2c3d(me),c2d)
											success = true
										end
									return true end)
									if success then command_person_go_to_coord2d(getShaman(v),c2d) end
								end
							elseif distance < 512*3 and not getShaman(v).State == S_PERSON_WAIT_IN_BLDG then
								getShaman(v).State = S_PERSON_SCATTER
							end
						end
						local dist = get_world_dist_xz(lightThing.Pos.D2,getShaman(v).Pos.D2)
						ShDodge(dist,getShaman(v).State == S_PERSON_WAIT_IN_BLDG)
					end
				end
			end
		end
	end
end

--try to dodge enemy aimed blasts
function dodgeAimedBlasts(caster,successChance,blast)
	if rnd() < successChance then
		if nilT(blast) then
			for k,v in ipairs(G_AI_ALIVE) do
				if nilS(v) and caster ~= v then
					if (getShaman(v).Flags2 & TF2_THING_IN_AIR == 0) then
						local function ShDodge(distance,inTowerBool)
							if not inTowerBool then
								if distance > 256 and distance < 512*3 then
									getShaman(v).State = S_PERSON_SCATTER
								end
							end
						end
						local dist = get_world_dist_xz(blast.Pos.D2,getShaman(v).Pos.D2)
						ShDodge(dist,getShaman(v).State == S_PERSON_WAIT_IN_BLDG)
					end
				end
			end
		end
	end	
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

--trained troops
function ReadAITrainedTroops(pn)
	local w,r,fw,spy = AI_GetUnitCount(pn,3),AI_GetUnitCount(pn,4),AI_GetUnitCount(pn,6),AI_GetUnitCount(pn,5)
	log_msg(pn,"owned troops:   wars: " .. w .. ", preachers: " .. r .. ", fws: " .. fw .. ", spies: " .. spy)
end

--read some globals
function readSomeGlobals()
	local add1, add2 = -1,-1
	log_msg(8,"turn: " .. turn() .. " | stage: " .. G_GAMESTAGE .. ", add1: " .. add1 .. ", add2: " .. add2)
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

--count buildings
function countBuildings(pn)
	return _gsi.Players[pn].NumBuildings
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

--is all pop on vehicles
function allPopOnVehicles(pn)
	local vehicled = 0
	ProcessGlobalSpecialList(pn, PEOPLELIST, function(t)
		if t.Model ~= M_PERSON_ANGEL then
			if is_person_in_any_vehicle(t) == 1 then
				vehicled = vehicled + 1
			end
		end
	return true end)
	
	return vehicled == GetPop(pn)
end

--fill tower (fills one random empty tower with one unit)
function FillRndEmptyTower(pn,unitType)
	ProcessGlobalSpecialList(pn, BUILDINGLIST, function(b)
		if b.Model == M_BUILDING_DRUM_TOWER then
			if (b.u.Bldg.NumDwellers == 0) then
				PUT_PERSON_IN_DT (pn, unitType,ThingX(b),ThingZ(b))
			end
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
	if everySeconds(seconds) then
		if getShaman(tribe) ~= nil then
		local ShInArea = CountThingsOfTypeInArea(T_PERSON,M_PERSON_MEDICINE_MAN,tribe,x,z,radius)
			if ShInArea == 1 and (getShaman(tribe).Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0) then
				SearchMapCells(SQUARE, 0, 0 , 5, world_coord3d_to_map_idx(getShaman(tribe).Pos.D3), function(me)
					me.MapWhoList:processList(function (t)
						if t.Type == T_SCENERY and t.Model < 7 then
							if t.State == 1 then
								local Sstate = getShaman(tribe).State
								if Sstate == 10 or Sstate == 17 or Sstate == 18 or Sstate == 19 then
									CREATE_THING_WITH_PARAMS4(T_SPELL, M_SPELL_BLAST, tribe, t.Pos.D3, 10000, 0, 0, 0)
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
							if not isShielded(t) and not isGhost(t) == 0 and r == 0 then
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
function fasterHutBars(tribe, amt, onlySproggingBool)
	ProcessGlobalTypeList(T_BUILDING ,function(b)
		if b.Owner == tribe then
			if (b.Model <= 3) then
				if (b.u.Bldg.SproggingCount > 0 and b.u.Bldg.SproggingCount < 1000) then
					b.u.Bldg.SproggingCount = b.u.Bldg.SproggingCount + amt
				end
				if onlySproggingBool and (b.Model <= 2) then
					if (b.u.Bldg.UpgradeCount < 1850) then
						b.u.Bldg.UpgradeCount = b.u.Bldg.UpgradeCount + amt
					end
				end
			end
		end
	return true end)
end
--all AI's faster green bar
function AIfasterSprogging(amt)
	ProcessGlobalTypeList(T_BUILDING ,function(b)
		if not isHuman(b.Owner) then
			if (b.Model <= 3) then 
				if (b.u.Bldg.SproggingCount > 0 and b.u.Bldg.SproggingCount < 1000) then
					b.u.Bldg.SproggingCount = b.u.Bldg.SproggingCount + amt
				end
			end
		end
	return true end)
end
--all AI's faster red bar
function AIfasterUpgradeCount(amt)
	ProcessGlobalTypeList(T_BUILDING ,function(b)
		if not isHuman(b.Owner) then
			if (b.Model <= 2) then
				if (b.u.Bldg.UpgradeCount < 1850) then
					b.u.Bldg.UpgradeCount = b.u.Bldg.UpgradeCount + amt
				end
			end
		end
	return true end)
end

--ai flatten around base
function TribeFlattenBase(pn,radius,minAlt,requiresLBmana)
	local success = false

	if (requiresLBmana and MANA(pn) >= 125000) or (not requiresLBmana) then
		if FREE_ENTRIES(pn) > 0 then
			if nilS(pn) then
				if AI_ShamanFree(pn) then
					local c3d = getPlayer(pn).ReincarnSiteCoord
					local c2d = Coord2D.new() ; coord3D_to_coord2D(c3d,c2d)
					if get_world_dist_xz(getShaman(pn).Pos.D2,c2d) < 512*16 then
						local meTbl = {}
						local currIsuccess = false
						for i = 1,radius do
							SearchMapCells(CIRCULAR, 0, i, i-1, world_coord2d_to_map_idx(getShaman(pn).Pos.D2), function(me)
								if is_map_cell_near_coast(MAP_ELEM_PTR_2_IDX(me),2) > 0 and is_map_elem_all_land(me) > 0 and me.Alt > minAlt then
									local meptr = MAP_ELEM_PTR_2_IDX(me)
									local c3d = Coord3D.new() map_idx_to_world_coord3d(meptr,c3d)
									table.insert(meTbl,c3d)
									success = true currIsuccess = true
								end
							return true end)
							if currIsuccess then break end
						end
						if success then
							local f = createThing(T_SPELL,M_SPELL_FLATTEN,pn,randomItemFromTable(meTbl),false,false)
						end
					end
				end
			end
		end
	end
end

--ai shaman go expand
function LBexpand(pn,radius,cooldownSecondsIncrement,requiresLBmana)
	local success = false
	
	if (requiresLBmana and MANA(pn) >= 70000) or (not requiresLBmana) then
		if FREE_ENTRIES(pn) > 0 then
			if nilS(pn) then
				if AI_ShamanFree(pn) then
					local c3d = getPlayer(pn).ReincarnSiteCoord
					local c2d = Coord2D.new() ; coord3D_to_coord2D(c3d,c2d)
					if get_world_dist_xz(getShaman(pn).Pos.D2,c2d) < 512*16 then
						SearchMapCells(SQUARE, 0, 0, radius, world_coord2d_to_map_idx(getShaman(pn).Pos.D2), function(me)
							if is_map_elem_coast(me) > 0 and me.Alt < 128 and rnd() < 33 and not success then
								local meptr = MAP_ELEM_PTR_2_IDX(me)
								local c2d = Coord2D.new() map_idx_to_world_coord2d(meptr,c2d)
								G_AI_EXPANSION_TABLE[pn][2] = c2d
								SearchMapCells(SQUARE, 0, 0, 6, world_coord2d_to_map_idx(G_AI_EXPANSION_TABLE[pn][2]), function(_me)
									if is_map_elem_coast(_me) > 0 and not success then
										local meptr = MAP_ELEM_PTR_2_IDX(_me)
										local c2d = Coord2D.new() map_idx_to_world_coord2d(meptr,c2d)
										SearchMapCells(SQUARE, 0, 0, 1, world_coord2d_to_map_idx(c2d), function(__me)
											if is_map_elem_all_sea(__me) > 0 then
												local meptr = MAP_ELEM_PTR_2_IDX(__me)
												local c3d = Coord3D.new() map_idx_to_world_coord3d(meptr,c3d)
												local c2d = Coord2D.new() ; coord3D_to_coord2D(c3d,c2d)
												if get_world_dist_xz(G_AI_EXPANSION_TABLE[pn][2],c2d) > 512*3 then
													local c3d2 = Coord3D.new() ; coord2D_to_coord3D(G_AI_EXPANSION_TABLE[pn][2],c3d2)
													if not isBuildingNear(M_BUILDING_BOAT_HUT_1,-1,c3d2,4) and not isBuildingNear(M_BUILDING_BOAT_HUT_1,-1,c3d,4) then
														G_AI_EXPANSION_TABLE[pn][3] = c3d
														G_AI_EXPANSION_TABLE[pn][5] = 20
														success = true
														return false
													end
												end
											end
										return true end)
									end
								return true end)
							end
						return true end)
					end
				end
			end
		end
	end
	
	--if not success try again in 30s; if success expand again after X
	if not success then G_AI_EXPANSION_TABLE[pn][1] = 30 G_AI_EXPANSION_TABLE[pn][2] = -1 G_AI_EXPANSION_TABLE[pn][3] = -1 G_AI_EXPANSION_TABLE[pn][4] = false else G_AI_EXPANSION_TABLE[pn][1] = cooldownSecondsIncrement command_person_go_to_coord2d(getShaman(pn),G_AI_EXPANSION_TABLE[pn][2]) G_AI_EXPANSION_TABLE[pn][4] = true end
end
function tryToLB(pn)
	if G_AI_EXPANSION_TABLE[pn][4] then
		if G_AI_EXPANSION_TABLE[pn][5] > 0 then G_AI_EXPANSION_TABLE[pn][5] = G_AI_EXPANSION_TABLE[pn][5] - 1 else G_AI_EXPANSION_TABLE[pn][1] = 30 G_AI_EXPANSION_TABLE[pn][2] = -1 G_AI_EXPANSION_TABLE[pn][3] = -1 G_AI_EXPANSION_TABLE[pn][4] = false return end
		if nilS(pn) then
			SearchMapCells(SQUARE, 0, 0, 1, world_coord2d_to_map_idx(G_AI_EXPANSION_TABLE[pn][2]), function(me)
				me.MapWhoList:processList( function (t)
					if t.Type == T_PERSON and t.Model == M_PERSON_MEDICINE_MAN and t.Owner == pn then
						createThing(T_SPELL,M_SPELL_LAND_BRIDGE,pn,G_AI_EXPANSION_TABLE[pn][3],false,false)
						G_AI_EXPANSION_TABLE[pn][2] = -1 G_AI_EXPANSION_TABLE[pn][3] = -1 G_AI_EXPANSION_TABLE[pn][4] = false
						G_AI_EXPANSION_TABLE[pn][5] = 0
					end
				return true end)
			return true end)
		end
	end
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
		if thing.Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0 then return false else return true end
	end
end
function isInvisible(thing)
	if thing ~= nil then
		if thing.Flags2 & TF2_THING_IS_AN_INVISIBLE_PERSON == 0 then return false else return true end
	end
end
function isBloodlusted(thing)
	if thing ~= nil then
		if thing.Flags3 & TF3_BLOODLUST_ACTIVE == 0 then return false else return true end
	end
end
function isShielded(thing)
	if thing ~= nil then
		if thing.Flags3 & TF3_SHIELD_ACTIVE == 0 then return false else return true end
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

function killTribe(tribe)
	ProcessGlobalSpecialList(tribe, BUILDINGLIST, function(t)
		if nilT(t) then
			if (t.Model <= 3) then
				t.u.Bldg.SproggingCount = 1
			end
		end
	return true end)
	ProcessGlobalSpecialList(tribe, PEOPLELIST, function(t)
		if nilT(t) then
			t.u.Pers.Life = 0
		end
	return true end)
end

--is sp or mp
function isOnline()
	return gns.Flags & GNS_NETWORK
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

--get me a random unit of type of tribe, bool idle
function randomUnit(pn,model,idleBool)
	if _gsi.Players[pn].NumPeople < 1 then return nil end
	local things = {}
	ProcessGlobalSpecialList(pn, PEOPLELIST, function(t)
		if t.Model == model then
			if idleBool then
				if t.State == S_PERSON_WAIT_AT_POINT or t.State == S_PERSON_GOTO_BASE_AND_WAIT then
					table.insert(things,t)
				end
			else
				table.insert(things,t)
			end
		end
	return true end)

	return randomItemFromTable(things)
end

--give atk command to unit (follow person)
unitAtkunitTbl = {} --to process hands up people and unstuck them
function unitAtkunit(tribe,enemy,model,enemyModel,attackerMustBeIdleBool)
	local atkerModel,enemyModel = model,enemyModel
	local rndAtker,rndTarg = randomUnit(tribe,atkerModel,attackerMustBeIdleBool),randomUnit(enemy,enemyModel,false)
	if nilT(rndAtker) and nilT(rndTarg) then
		Cmds:get_person_idx(rndAtker)
		Cmds:attack_person(rndAtker, rndTarg.ThingNum)
		table.insert(unitAtkunitTbl,rndAtker)
	end
end

--unit nav check and go there(doesnt work instantly, gotta have a table and process after) (send units to c3d, if can nav, else it removes hands up)
unitNavTbl = {}
function unitNavAndMoveC3d(thing,dest)
	if nilT(thing) then
		local c2d = Coord2D.new() ; coord3D_to_coord2D(dest,c2d)
		command_person_go_to_coord2d(thing,c2d)
		table.insert(unitNavTbl,{thing,c2d})
		
		return success
	end
end
function ProcessUnitMoveTbl()
	for k,v in ipairs(unitNavTbl) do
		if nilT(v[1]) then
			local success = (v[1].State ~= S_PERSON_NAVIGATION_FAILED)
			if not success then v[1].State = S_PERSON_SCATTER remove_all_persons_commands(v[1]) end
		end
	end
	unitNavTbl = {}
end

function NavCheck(tribe,enemy,c3d)
	gns.ThisLevelHeader.Markers[254] = world_coord3d_to_map_idx(c3d)
	
	return ntb(NAV_CHECK(tribe, enemy, ATTACK_MARKER, 254, FALSE))
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
		if drawnum == -1 then plants.DrawInfo.DrawNum = rndb(1775,1784) else plants.DrawInfo.DrawNum = drawnum end --still need to add plant types to HFX
		plants.DrawInfo.Alpha = -16 plants.DrawInfo.Flags = EnableFlag(plants.DrawInfo.Flags, DF_USE_ENGINE_SHADOW)
	end
end

--mimic land
function LandMimic(pointc3d,targetc3d,radius,copySceneryBool)
	local mimicTbl = {}
	SearchMapCells(SQUARE ,0, 0, radius, world_coord3d_to_map_idx(pointc3d), function(me)
		if copySceneryBool then
			local tree = -1
			me.MapWhoList:processList( function (t)
				if t.Type == T_SCENERY and t.Model < 7 then
					tree = {t.Model,t.u.Scenery.ResourceRemaining,t.u.ObjectInfo.Scale}
				end
			return true end)
			table.insert(mimicTbl,{me.Alt,tree})
		else
			table.insert(mimicTbl,me.Alt)
		end
	return true end)
	--copy it to destination
	SearchMapCells(SQUARE ,0, 0, radius, world_coord3d_to_map_idx(targetc3d), function(me)
		if copySceneryBool then
			me.Alt = mimicTbl[1][1]
			if mimicTbl[1][2] ~= -1 then
				local tree = createThing(T_SCENERY,mimicTbl[1][2][1],radius+1,me2c3d(me),false,false)
				tree.u.Scenery.ResourceRemaining = mimicTbl[1][2][2] tree.u.ObjectInfo.Scale = mimicTbl[1][2][3]
			end
			table.remove(mimicTbl,1)
		else
			me.Alt = mimicTbl[1] table.remove(mimicTbl,1)
		end
	return true end)
	
	set_square_map_params(world_coord3d_to_map_idx(targetc3d),radius+1,TRUE)
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

--bool to number
function btn(bool)
  return bool and 1 or 0
end
--number to bool
function ntb(num)
	if num == 0 then return false end
	return true
end
--------------------------------------------------------------------------------------------------------------------------------------------
--debug
function LOG(msg)
	log_msg(8,"turn: " .. turn() .. "  |   " .. tostring(msg))
end
--------------------------------------------------------------------------------------------------------------------------------------------
