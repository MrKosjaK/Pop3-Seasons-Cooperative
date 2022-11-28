CompPlayer:init(TRIBE_PINK);
local ai = CompPlayer(TRIBE_PINK);

ai:toggle_shaman_ai(true);
local sham = ai:get_shaman_ai();
sham:toggle_fall_damage_save(true, 50);
sham:toggle_land_bridge_save(true, 25);
sham:toggle_lightning_dodge(true, 90);
sham:toggle_spell_check(true);
sham:set_spell_entry(1, M_SPELL_LIGHTNING_BOLT, {4, 5, 6, 7, 8}, 4, 4, 35000);
sham:set_spell_entry(2, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 5, 6, 7, 8}, 3, 3, 90000);
sham:set_spell_entry(3, M_SPELL_EARTHQUAKE, {1, 2, 3, 5, 6, 7, 8}, 2, 2, 115000);

-- towers
ai:create_tower(1, 218, 118, -1);
ai:create_tower(2, 230, 120, -1);
ai:create_tower(3, 222, 108, -1);
ai:create_tower(4, 204, 108, -1);
ai:create_tower(5, 214, 80, 3);
ai:create_tower(6, 220, 76, 2);
ai:create_tower(7, 224, 76, 2);
ai:create_tower(8, 228, 78, 1);

local cont = getPlayerContainer(TRIBE_PINK);
local construction_list = cont.PlayerLists[BUILDINGMARKERLIST];
local people_list = cont.PlayerLists[PEOPLELIST];
local shapes_without_workers = {};
local cmd = Commands.new();
local cti = CmdTargetInfo.new();

local function purple_look_for_buildings(player)
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

local function purple_troop_attack(player)

end

local function purple_shaman_attack(player)

end

local function purple_early_towers(player)
  local my_pop = AI_GetPopCount(player);
  
  if (my_pop >= 10) then
    if (AI_GetVar(player, 2) == 0) then
	  ai:construct_tower(1);
	  AI_SetVar(player, 2, 1);
	  return;
	end
	
	if (AI_GetVar(player, 3) == 0) then
	  ai:construct_tower(2);
	  AI_SetVar(player, 3, 1);
	  return;
	end
	
	if (AI_GetVar(player, 4) == 0) then
	  ai:construct_tower(3);
	  ai:construct_tower(4);
	  AI_SetVar(player, 4, 1);
	  return;
	end
	
	if (AI_GetVar(player, 5) == 0) then
	  ai:construct_tower(5);
	  ai:construct_tower(7);
	  AI_SetVar(player, 5, 1);
	  return;
	end
	
	if (AI_GetVar(player, 6) == 0) then
	  ai:construct_tower(6);
	  ai:construct_tower(8);
	  AI_SetVar(player, 6, 1);
	  return;
	end
  end
end

local function purple_build(player)
  AI_SetVar(player, 7, 0); -- fw building.
  AI_SetVar(player, 8, 0); -- war building
  AI_SetVar(player, 9, 0); -- bigger troops counts.
  local fw_trains = AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN);
  local war_trains = AI_GetBldgCount(player, M_BUILDING_WARRIOR_TRAIN);
  local huts = AI_GetHutsCount(player);
  
  if (fw_trains > 0 or war_trains > 0) then
    WRITE_CP_ATTRIB(player, ATTR_MAX_TRAIN_AT_ONCE, 3);
    STATE_SET(player, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
  end
  
  if (huts < 7) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 45);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 4);
	AI_SetVar(player, 7, 1);
  elseif (huts < 16) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 90);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 2);
	AI_SetVar(player, 7, 1);
	AI_SetVar(player, 8, 1);
	if (AI_GetVar(player, 10) == 0) then
      AI_SetVar(player, 10, 1);
      AI_SetMainDrumTower(player, true, 216, 158);
    end
  else
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 121);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 1);
	AI_SetVar(player, 7, 1);
	AI_SetVar(player, 8, 1);
	AI_SetVar(player, 9, 1);
  end
  
  if (AI_GetVar(player, 7) == 1) then
    if (fw_trains == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 10);
	end
  end
  
  if (AI_GetVar(player, 8) == 1) then
    if (war_trains == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 14);
	end
  end
  
  if (AI_GetVar(player, 9) == 1) then
    if (fw_trains > 0 and war_trains > 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 20);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 15);
	end
  end
end

local function purple_convert(player)
  if (AI_GetVar(player, 1) == 0) then
	local turn = getTurn();
	  
	if (turn < 1440) then
      sham:toggle_converting(true);
	  if (turn < 720) then
	    SHAMAN_DEFEND(player, 226, 54, TRUE);
	  else
	    SHAMAN_DEFEND(player, 208, 162, TRUE);
	  end
	else
      AI_SetVar(player, 1, 1);
	  SHAMAN_DEFEND(player, 222, 118, TRUE);
      sham:toggle_converting(false);
    end
  end
end

local function purple_check_towers(player)
  --if (AI_GetVar(player, 9) == 0 or AI_GetVar(player, 10) == 1 or AI_GetVar(player, 11) == 1) then
	--return;
  --end
  
  local my_pop = AI_GetPopCount(player);
  
  if (my_pop >= 30) then
    -- only bother with said pop or above
	for i = 1, 8 do
	  if (not ai:is_tower_constructed(i)) then
	    ai:construct_tower(i);
		break;
      end
	end
  end
end

-- events
ai:create_event(1, 92, 34, purple_convert);
ai:create_event(2, 188, 74, purple_build);
ai:create_event(3, 140, 44, purple_early_towers);
ai:create_event(4, 1440, 256, purple_shaman_attack);
ai:create_event(5, 940, 120, purple_troop_attack);
ai:create_event(6, 480, 96, purple_look_for_buildings);
ai:create_event(7, 384, 96, purple_check_towers);
