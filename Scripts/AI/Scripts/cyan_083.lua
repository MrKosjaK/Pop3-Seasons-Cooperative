CompPlayer:init(TRIBE_CYAN);
local ai = CompPlayer(TRIBE_CYAN);

-- shaman ai options
ai:toggle_shaman_ai(true); -- enable it first u dummy

local sham = ai:get_shaman_ai(); -- get pointer to it as local, so it's fasto
sham:toggle_spell_check(true); -- spell entries
sham:toggle_fall_damage_save(true, 50);
sham:toggle_land_bridge_save(true, 25);
sham:toggle_lightning_dodge(true, 90);
sham:toggle_spell_check(true);
sham:set_spell_entry(1, M_SPELL_WHIRLWIND, {M_BUILDING_DRUM_TOWER, 1, 2, 3}, 3, 50000);

-- towers
ai:create_tower(1, 138, 136, -1);
ai:create_tower(2, 146, 106, -1);
ai:create_tower(3, 124, 104, -1);
ai:create_tower(4, 130, 76, -1);
ai:create_tower(5, 148, 78, -1);
ai:create_tower(6, 138, 78, -1);

local cont = getPlayerContainer(TRIBE_CYAN);
local construction_list = cont.PlayerLists[BUILDINGMARKERLIST];
local people_list = cont.PlayerLists[PEOPLELIST];
local shapes_without_workers = {};
local cmd = Commands.new();
local cti = CmdTargetInfo.new();
local Area = CreateAreaInfo();

local function cyan_look_for_buildings(player)
  if (construction_list:isEmpty()) then
    return;
  end

  shapes_without_workers = {};

  -- store shapes in need of building
  construction_list:processList(function(t)
	if (t.u.Shape.NumWorkers == 0) then
	  shapes_without_workers[#shapes_without_workers + 1] = t;
	  return true;
	end
	  
	return true;
  end);
  
  local shape;
  local peeps_per_shape = 2;
  
  people_list:processList(function(t)
    if (#shapes_without_workers == 0) then
	 return false;
	end
	
    if (t.Model == M_PERSON_BRAVE) then
	  if (t.State == S_PERSON_WAIT_AT_POINT) then
	    local shape = shapes_without_workers[#shapes_without_workers];
		
		-- command brave here i guessorino
		cti.TMIdxs.TargetIdx:set(shape.ThingNum);
		cti.TMIdxs.MapIdx = world_coord2d_to_map_idx(shape.Pos.D2);
		update_cmd_list_entry(cmd, CMD_BUILD_BUILDING, cti, 0);
		
		t.Flags = t.Flags | TF_RESET_STATE;
		add_persons_command(t, cmd, 0);
		
		peeps_per_shape = peeps_per_shape - 1;
		if (peeps_per_shape == 0) then
		  peeps_per_shape = 2;
		  shapes_without_workers[#shapes_without_workers] = nil;
		end
		return true;
	  end
	end
	return true;
  end);
end

local function cyan_anti_rush(player)
  AI_SetVar(player, 11, 0);
  
  if (AI_GetVar(player, 12) == 0) then
    local turn = getTurn();
	
	if (turn < 3600) then
	  GetEnemyAreaInfo(player, 138, 136, 12, Area);
	  
	  -- check if we're being attacked by priests.
	  if (Area:contains_people()) then
	    local e_priests = Area:get_person_count(M_PERSON_RELIGIOUS);
		local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
		
		if (e_priests > 0 and AI_ShamanFree(player)) then
		  AI_SetVar(player, 11, 1);
		  -- murder.
		  AI_SetAttackFlags(player, 3, 1, 0);
		  AI_SetAways(player, 0, 0, 100, 0, 0);
		  AI_SetShamanAway(player, true);
		  
		  set_player_can_cast_temp(M_SPELL_BLAST, player);
		  set_player_can_cast_temp(M_SPELL_BLAST, player);
		  set_player_can_cast_temp(M_SPELL_BLAST, player);
		  
		  SET_SPELL_ENTRY(player, 2, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 1, 1);
		  SET_SPELL_ENTRY(player, 3, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 1, 1);
		
		  ATTACK(player, TRIBE_BLUE, math.max(0, my_priests), ATTACK_MARKER, 39, 998, M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, -1, -1, 0);
		end
	  end
	else
	  AI_SetVar(player, 11, 0);
	  AI_SetVar(player, 12, 1);
	end
  end
end

local function cyan_attacking(player)
  AI_SetVar(player, 10, 0);
  -- attacking momentos
  if (AI_GetVar(player, 9) == 0 or AI_GetVar(player, 11) == 1) then
    return;
  end
  
  -- get info on our midhill first
  GetEnemyAreaInfo(player, 138, 78, 5, Area);
  
  if (Area:contains_people()) then
	-- it has em people. see if there are any fws.
	local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
	local e_priests = Area:get_person_count(M_PERSON_RELIGIOUS);
	local e_fws = Area:get_person_count(M_PERSON_SUPER_WARRIOR);
	if (e_fws > 0 and e_priests == 0) then
	  AI_SetVar(player, 10, 1); -- indicate that mid has enemies.
	  -- so there are fws, then we should send our shaman, don't want to waste any priests or fws.
	  if (AI_ShamanFree(player)) then
	    if (player_can_cast(M_SPELL_LIGHTNING_BOLT, player) ~= 3) then
	      set_player_can_cast_temp(M_SPELL_INSECT_PLAGUE, player, 1);
		  set_player_can_cast_temp(M_SPELL_INSECT_PLAGUE, player, 1);
		  set_player_can_cast_temp(M_SPELL_INSECT_PLAGUE, player, 1);
	    end
	    AI_SetAttackFlags(player, 3, 1, 0);
	    AI_SetAways(player, 0, 0, 0, 0, 0);
	    AI_SetShamanAway(player, true);
	    SET_SPELL_ENTRY(player, 2, M_SPELL_GHOST_ARMY, SPELL_COST(M_SPELL_GHOST_ARMY) >> 2, 32, 1, 0);
	    SET_SPELL_ENTRY(player, 3, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 0);
	  
	    ATTACK(player, TRIBE_BLUE, 0, ATTACK_MARKER, 6, 300, M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, ATTACK_NORMAL, 0, -1, -1, 0);
	    return;
	  end
	end
	
	if (e_priests > 0 and e_fws == 0) then
	  AI_SetVar(player, 10, 1);
	  -- has priests, can we afford to kill them?
	  if (my_priests >= e_priests) then
	    -- we have more or enough priests to beat em up.
		AI_SetAttackFlags(player, 0, 0, 0);
		AI_SetAways(player, 0, 0, 100, 0, 0);
		AI_SetShamanAway(player, false);
		ATTACK(player, TRIBE_BLUE, math.min(e_priests, my_priests), ATTACK_MARKER, 6, 800, 0, 0, 0, ATTACK_NORMAL, 0, 31, -1, 0);
	    return;
	  elseif (AI_ShamanFree(player)) then
	    -- cannot afford priests, try with shaman then!
		if (player_can_cast(M_SPELL_HYPNOTISM, player) ~= 3) then
		  set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
		  set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
		  set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
		end
		AI_SetAttackFlags(player, 3, 1, 0);
		AI_SetAways(player, 0, 0, 0, 0, 0);
		AI_SetShamanAway(player, true);
		SET_SPELL_ENTRY(player, 2, M_SPELL_GHOST_ARMY, SPELL_COST(M_SPELL_GHOST_ARMY) >> 2, 32, 1, 0);
	    SET_SPELL_ENTRY(player, 3, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 2, 0);
	  
	    ATTACK(player, TRIBE_BLUE, 0, ATTACK_MARKER, 6, 300, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, ATTACK_NORMAL, 0, -1, -1, 0);
	    return;
	  end
	end
  end
end

local function cyan_early_towers(player)
  -- quick expansion towards middle
  local my_pop = AI_GetPopCount(player);
  
  if (my_pop >= 15) then
    if (AI_GetVar(player, 5) == 0) then
	  ai:construct_tower(1);
	  AI_SetVar(player, 5, 1);
	  return;
	end
	
	if (AI_GetVar(player, 6) == 0) then
	  ai:construct_tower(2);
	  AI_SetVar(player, 6, 1);
	  return;
	end
	
	if (AI_GetVar(player, 7) == 0) then
	  ai:construct_tower(3);
	  AI_SetVar(player, 7, 1);
	  return;
	end
	
	if (AI_GetVar(player, 8) == 0) then
	  ai:construct_tower(6);
	  AI_SetVar(player, 8, 1);
	  return;
	end
  end
end

local function cyan_convert(player)
  -- we'll be converting till 1 minute passes
  if (AI_GetVar(player, 9) == 0) then
	local turn = getTurn();
	  
	if (turn < 720) then
      sham:toggle_converting(true);
	  SHAMAN_DEFEND(player, 138, 78, TRUE);
	else
      AI_SetVar(player, 9, 1);
	  SHAMAN_DEFEND(player, 138, 128, TRUE);
      sham:toggle_converting(false);
    end
  end
end

local function cyan_build(player)
  -- we want fw hut built as soon as possible.
  AI_SetVar(player, 2, 0); -- fw building.
  AI_SetVar(player, 3, 0); -- temple building
  AI_SetVar(player, 4, 0); -- bigger troops counts.
  local fw_trains = AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN);
  local temples = AI_GetBldgCount(player, M_BUILDING_TEMPLE);
  local huts = AI_GetHutsCount(player);
  
  if (fw_trains > 0 or temples > 0) then
    WRITE_CP_ATTRIB(player, ATTR_MAX_TRAIN_AT_ONCE, 3);
    STATE_SET(player, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
  end
  
  if (huts < 7) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 45);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 6);
	AI_SetVar(player, 2, 1);
  elseif (huts < 16) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 90);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 3);
	AI_SetVar(player, 2, 1);
	AI_SetVar(player, 3, 1);
	if (AI_GetVar(player, 1) == 0) then
      AI_SetVar(player, 1, 1);
      AI_SetMainDrumTower(player, true, 138, 128);
    end
  else
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 121);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 1);
	AI_SetVar(player, 2, 1);
	AI_SetVar(player, 3, 1);
	AI_SetVar(player, 4, 1);
  end
  
  if (AI_GetVar(player, 2) == 1) then
    if (fw_trains == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 12);
	end
  end
  
  if (AI_GetVar(player, 3) == 1) then
    if (temples == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 12);
	end
  end
  
  if (AI_GetVar(player, 4) == 1) then
    if (fw_trains > 0 and temples > 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 18);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 20);
	end
  end
end

-- events
ai:create_event(1, 256, 64, cyan_build);
ai:create_event(2, 128, 24, cyan_convert);
ai:create_event(3, 128, 32, cyan_early_towers);
ai:create_event(4, 340, 44, cyan_anti_rush);
ai:create_event(5, 1536, 256, cyan_attacking);
ai:create_event(6, 512, 128, cyan_look_for_buildings);
