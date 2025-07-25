-- misc assets

function is_point_on_rectangle(rect, x, y)
  return (x >= rect.Left and x <= rect.Right and y >= rect.Top and y <= rect.Bottom);
end

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

function player_in_options()
	return (G_NSI.Flags3 & GNS3_INGAME_OPTIONS) > 0
end

function player_in_player_stats()
	return (G_NSI.Flags3 & 	GNS3_DISPLAY_LEVEL_STATS) > 0
end

function no_menus_open()
	return (not player_in_options() and not player_in_player_stats())
end

function is_paused()
	return G_NSI.Flags & GNS_PAUSED > 0
end

give_player_mana = GIVE_MANA_TO_PLAYER;

function unpause_if_paused()
	if isPaused() then
		process_options(OPT_SET_PAUSE, 0, FALSE)
	end
end

function pause_if_unpaused()
	if not isPaused() then
		process_options(OPT_SET_PAUSE, 0, FALSE)
	end
end

function get_turn()
	return G_SI.Counts.ProcessThings
end

-- EVERY POW FUNCS

function is_every_2_turns(_val)
  return (_val & 1 == 0);
end

function is_every_4_turns(_val)
  return (_val & 3 == 0);
end

function is_every_8_turns(_val)
  return (_val & 7 == 0);
end

function is_every_16_turns(_val)
  return (_val & 15 == 0);
end

function is_every_32_turns(_val)
  return (_val & 31 == 0);
end

function is_every_64_turns(_val)
  return (_val & 63 == 0);
end

function is_every_128_turns(_val)
  return (_val & 127 == 0);
end

function is_every_256_turns(_val)
  return (_val & 255 == 0);
end

function is_every_512_turns(_val)
  return (_val & 511 == 0);
end

function is_every_1024_turns(_val)
  return (_val & 1023 == 0);
end

function is_every_2048_turns(_val)
  return (_val & 2047 == 0);
end

function is_every_4096_turns(_val)
  return (_val & 4095 == 0);
end

function is_every_8192_turns(_val)
  return (_val & 8191 == 0);
end

function is_every_16384_turns(_val)
  return (_val & 16383 == 0);
end

function LOG(msg)
	log_msg(8, "turn: " .. G_SCRIPT_TURN .. " |   " .. tostring(msg))
end

function btn(bool)
  return bool and 1 or 0
end

function ntb(num)
	if num == 0 then return false end
	return true
end

function clamp(value, minVal, maxVal)
    return math.max(minVal, math.min(value, maxVal))
end

function mf(a, b)
	return math.floor(a / b)
end

function everySeconds(n)
  return G_SI.Counts.ProcessThings % (n*12) == 0
end

function rndb(a, b)
	return a + G_RANDOM(b - a + 1)
end

function random_float()
    return G_RANDOM(1000000) / 1000000
end

function chance(a)
	return rndb(0, 100) < a
end

function random_item_from_table(t)
  if (#t == 0) then
    return nil
  end

  local idx = rndb(1, #t)
  return t[idx]
end

function remove_item_from_table(tbl, value, remove_all_duplicates)
	if tbl ~= nil then
		for k,v in ipairs(tbl) do
			if value == v then
				table.remove(tbl, k)
				if not remove_all_duplicates then
					break
				end
			end
		end
	end
end

function is_item_in_table(tbl,item)
	for k,v in ipairs(tbl) do
		if v == item then return true end
	end
	return false
end

function are_players_allies(a, b)
	if are_players_allied(a, b) > 0 then
		if are_players_allied(b, a) > 0 then
			return true
		end
	end
	
	return false
end

function zoom_thing(thing, angle)
	if thing ~= nil then
		local pos = MapPosXZ.new() 
		pos.Pos = world_coord3d_to_map_idx(thing.Pos.D3)	
		ZOOM_TO(pos.XZ.X,pos.XZ.Z, angle)
	end
end

function CopyC2d(c2d)
	local nc2d = Coord2D.new()
	nc2d.Xpos = c2d.Xpos
	nc2d.Zpos = c2d.Zpos
	return nc2d
end

function CopyC3d(c3d)
	local nc3d = Coord3D.new()
	nc3d.Xpos = c3d.Xpos
	nc3d.Ypos = c3d.Ypos
	nc3d.Zpos = c3d.Zpos
	return nc3d
end

function coord_to_c3d(x,z)
	local c2d = Coord2D.new()
	map_xz_to_world_coord2d(x,z,c2d)
	local c3d = Coord3D.new()
	coord2D_to_coord3D(c2d,c3d)
	return c3d
end

function me2c3d(me)
	local _me = MAP_ELEM_PTR_2_IDX(me)
	local c3d = Coord3D.new()
	map_idx_to_world_coord3d_centre(_me,c3d)
	return c3d
end

function markerIdxX(marker)
	local m = MapPosXZ.new()
	m.Pos = world_coord3d_to_map_idx(marker_to_coord3d(marker))
	
	return m.XZ.X
end

function markerIdxZ(marker)
	local m = MapPosXZ.new()
	m.Pos = world_coord3d_to_map_idx(marker_to_coord3d(marker))
	
	return m.XZ.Z
end

function isMkLand(mk)
	local is = false
	SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(marker_to_coord3d(mk)), function(me)
		if is_map_elem_all_land(me) > 0 then is = true end
	return true end)
	
	return is
end

function isMkWater(mk)
	local is = false
	SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(marker_to_coord3d(mk)), function(me)
		if is_map_elem_all_sea(me) > 0 then is = true end
	return true end)
	
	return is
end

function thing_flying(t)
	return HasFlag(t.Flags2, TF2_THING_IN_AIR) > 0
end

function thing_over_water(t)
	local water = false
	SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(t.Pos.D3), function(me)
		ProcessMapWho(me, function(t)
			water = is_map_elem_all_sea(me) > 0
		return true end)
	return true end)
	
	return water
end

function is_c3d_water(c3d)
	local water = false
	SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(c3d), function(me)
		water = is_map_elem_all_sea(me) > 0
	return false end)
	
	return water
end

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

function nilS(tribe)
	return getShaman(tribe) ~= nil
end

function nilT(thing)
	return thing ~= nil
end

function count_pop(pn)
  return G_PLR[pn].NumPeople
end

function count_troops(pn)
	local sh = 0 if getShaman(0) ~= nil then sh = 1 end
	return (G_PLR[pn].NumPeople - G_PLR[pn].NumPeopleOfType[M_PERSON_BRAVE]) - sh
end

function num_braves(pn)
  return G_PLR[pn].NumPeopleOfType[M_PERSON_BRAVE];
end

function count_boats(pn)
	return G_PLR[pn].NumVehiclesOfType[M_VEHICLE_BOAT_1]
end

function count_balloons(pn)
	return G_PLR[pn].NumVehiclesOfType[M_VEHICLE_AIRSHIP_1]
end

function count_buildings(pn)
	return G_PLR[pn].NumBuildings
end

count_bldgs_of_type = PLAYERS_BUILDING_OF_TYPE;
count_people_of_type = PLAYERS_PEOPLE_OF_TYPE;

function count_huts(pn, includeDamaged)
	if includeDamaged then 
		return G_PLR[pn].NumBuiltOrPartBuiltBuildingsOfType[1]+G_PLR[pn].NumBuiltOrPartBuiltBuildingsOfType[2]+G_PLR[pn].NumBuiltOrPartBuiltBuildingsOfType[3]
	end
	return G_PLR[pn].NumBuildingsOfType[1]+G_PLR[pn].NumBuildingsOfType[2]+G_PLR[pn].NumBuildingsOfType[3]
end

function count_towers(pn, includeDamaged)
	if includeDamaged then 
		return G_PLR[pn].NumBuiltOrPartBuiltBuildingsOfType[4]
	end
	return G_PLR[pn].NumBuildingsOfType[4]
end

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

function is_ghost(thing)
	if thing ~= nil then
		return not thing.Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0
	end
end

function is_invisible(thing)
	if thing ~= nil then
		return not thing.Flags2 & TF2_THING_IS_AN_INVISIBLE_PERSON == 0
	end
end

function is_bloodlusted(thing)
	if thing ~= nil then
		return not thing.Flags3 & TF3_BLOODLUST_ACTIVE == 0
	end
end

function is_shielded(thing)
	if thing ~= nil then
		return not thing.Flags3 & TF3_SHIELD_ACTIVE == 0
	end
end

function give_shield(thing, duration)
	if thing ~= nil then
		thing.Flags3 = EnableFlag(thing.Flags3, TF3_SHIELD_ACTIVE)
		if duration ~= -1 then thing.u.Pers.u.Owned.ShieldCount = math.floor(1.6 * duration) end
	end
end

function give_bloodlust(thing, duration)
	if thing ~= nil then
		thing.Flags3 = EnableFlag(thing.Flags3, TF3_BLOODLUST_ACTIVE)
		if duration ~= -1 then thing.u.Pers.u.Owned.BloodlustCount = math.floor(1.6 * duration) end
	end
end

function give_invisibility(thing, duration)
	if thing ~= nil then
		thing.Flags2 = EnableFlag(thing.Flags2, TF2_THING_IS_AN_INVISIBLE_PERSON)
		if duration ~= -1 then thing.u.Pers.u.Owned.InvisibleCount = math.floor(1.6 * duration) end
	end
end

function make_ghost(thing)
	if thing ~= nil then
		thing.Flags2 = EnableFlag(thing.Flags2, TF2_THING_IS_A_GHOST_PERSON)
	end
end

function remove_shield(thing)
	if thing ~= nil then
		thing.Flags3 = DisableFlag(thing.Flags3, TF3_SHIELD_ACTIVE)
	end
end

function remove_bloodlust(thing)
	if thing ~= nil then
		thing.Flags3 = DisableFlag(thing.Flags3, TF3_BLOODLUST_ACTIVE)
	end
end

function remove_invisibility(thing)
	if thing ~= nil then
		thing.Flags2 = DisableFlag(thing.Flags2, TF2_THING_IS_AN_INVISIBLE_PERSON)
	end
end

function thing_has_state(thing, state)
	return thing.State == state
end

function thing_has_flag(thing, flag)
	return thing.Flags2 & TF2_THING_IN_AIR ~= 0
end

-- utils for creating things
-- ACCEPTABLE ORIENTS ARE: 0, 1, 2, 3
function create_building(model, owner, x, z, orient)
  CREATE_THING_WITH_PARAMS5(T_BUILDING, model, owner, MAP_XZ_2_WORLD_XYZ(x, z), orient, 0, S_BUILDING_STAND, -1, 0);
end

function create_person(model, owner, x, z);
  createThing(T_PERSON, model, owner, MAP_XZ_2_WORLD_XYZ(x, z), false, false);
end

function create_people(model, owner, x, z, amount)
  local num = math.max(1, amount);
  local _c3d_pos = MAP_XZ_2_WORLD_XYZ(x, z);
  
  for i = 1, num do
    createThing(T_PERSON, model, owner, _c3d_pos, false, false);
  end
end


local plants_per_season = {
	[SEASON_WINTER] = function() return rndb(1775, 1784) end,
	[SEASON_SPRING] = function() return 1 end,
	[SEASON_SUMMER] = function() return 1 end,
	[SEASON_AUTUMN] = function() return 1 end
}

function create_random_plant_at_marker(marker, season)
	local spr = plants_per_season[season]()
	local p = createThing(T_SCENERY, M_SCENERY_PLANT_1, TRIBE_NEUTRAL, marker_to_coord3d(marker), false, false)
	centre_coord3d_on_block(p.Pos.D3)
	p.DrawInfo.DrawNum = spr
	p.DrawInfo.Alpha = -16
	-- add plant shadow i forgot flag name
end

function plants_at_markers(start, ending, season)
	for marker = start, ending do
		create_random_plant_at_marker(marker, season)
	end
end

function get_random_alive_human_player()
  -- for this specific pack human players are 0 and 1, so we'll only check those.
  local num_alive_human_players = 0;
  local table_pn = {};
  
  for i = 0, 1 do
    if (G_PLR[i].NumPeople > 0) then
      num_alive_human_players = num_alive_human_players + 1;
      table_pn[#table_pn + 1] = i;
    end
  end
  
  if (num_alive_human_players > 0) then
    return table_pn[G_RANDOM(num_alive_human_players) + 1];
  end
  
  return -1;
end