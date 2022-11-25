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

local function cyan_attacking(player)
  -- depends on what we want with attacking, let's actually make it patterned for now
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
ai:create_event(4, 740, 112, function(player) end);
ai:create_event(5, 1536, 256, cyan_attacking);
ai:create_event(6, 512, 128, cyan_look_for_buildings);
