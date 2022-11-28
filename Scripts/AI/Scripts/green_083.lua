CompPlayer:init(TRIBE_GREEN);
local ai = CompPlayer(TRIBE_GREEN);

ai:toggle_shaman_ai(true);
local sham = ai:get_shaman_ai();
sham:toggle_fall_damage_save(true, 50);
sham:toggle_land_bridge_save(true, 25);
sham:toggle_lightning_dodge(true, 90);
sham:toggle_spell_check(true);
sham:set_spell_entry(1, M_SPELL_LIGHTNING_BOLT, {4, 5, 6, 7, 8}, 4, 4, 35000);
sham:set_spell_entry(2, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 5, 6, 7, 8}, 3, 3, 80000);
sham:set_spell_entry(3, M_SPELL_EARTHQUAKE, {1, 2, 3, 5, 6, 7, 8}, 2, 2, 100000);

-- towers
ai:create_tower(1, 54, 136, -1);
ai:create_tower(2, 40, 116, -1);
ai:create_tower(3, 66, 112, -1);
ai:create_tower(4, 46, 80, -1);
ai:create_tower(5, 68, 80, 3);
ai:create_tower(6, 56, 78, 2);

local cont = getPlayerContainer(TRIBE_GREEN);
local construction_list = cont.PlayerLists[BUILDINGMARKERLIST];
local people_list = cont.PlayerLists[PEOPLELIST];
local shapes_without_workers = {};
local cmd = Commands.new();
local cti = CmdTargetInfo.new();

local function green_look_for_buildings(player)
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
		Cmds:clear_person_commands(t);
		Cmds:construct_building(t, shape);
		
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

local function green_build(player)
  AI_SetVar(player, 2, 0);
  AI_SetVar(player, 3, 0);
  AI_SetVar(player, 4, 0);
  local huts = AI_GetHutsCount(player);
  local war_trains = AI_GetBldgCount(player, M_BUILDING_WARRIOR_TRAIN);
  local temples = AI_GetBldgCount(player, M_BUILDING_TEMPLE);
  
  if (temples > 0 or war_trains > 0) then
    WRITE_CP_ATTRIB(player, ATTR_MAX_TRAIN_AT_ONCE, 3);
    STATE_SET(player, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
  end
  
  if (huts < 7) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 45);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 4);
	AI_SetVar(player, 2, 1);
  elseif (huts < 16) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 90);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 3);
	AI_SetVar(player, 2, 1);
	AI_SetVar(player, 3, 1);
	if (AI_GetVar(player, 10) == 0) then
      AI_SetVar(player, 10, 1);
      AI_SetMainDrumTower(player, true, 54, 126);
    end
  else
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 121);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 3);
	AI_SetVar(player, 2, 1);
	AI_SetVar(player, 3, 1);
	AI_SetVar(player, 4, 1);
  end
  
  if (AI_GetVar(player, 2) == 1) then
    if (temples == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 14);
	end
  end
  
  if (AI_GetVar(player, 3) == 1) then
    if (war_trains == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 10);
	end
  end
  
  if (AI_GetVar(player, 4) == 1) then
    if (temples > 0 and war_trains > 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 16);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 20);
	end
  end
end

local function green_check_towers(player)
end

local function green_early_towers(player)
  local my_pop = AI_GetPopCount(player);
  
  if (my_pop >= 10) then
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
	  ai:construct_tower(4);
	  AI_SetVar(player, 8, 1);
	  return;
	end
	
	if (AI_GetVar(player, 9) == 0) then
	  ai:construct_tower(5);
	  AI_SetVar(player, 9, 1);
	  return;
	end
  end
end

local function green_convert(player)
  if (AI_GetVar(player, 3) == 0) then
	local turn = getTurn();
	  
	if (turn < 960) then
      sham:toggle_converting(true);
	  SHAMAN_DEFEND(player, 64, 58, TRUE);
	else
      AI_SetVar(player, 3, 1);
	  SHAMAN_DEFEND(player, 54, 126, TRUE);
      sham:toggle_converting(false);
    end
  end
end

ai:create_event(1, 114, 24, green_convert);
ai:create_event(2, 192, 84, green_build);
ai:create_event(3, 372, 90, green_check_towers);
ai:create_event(4, 140, 44, green_early_towers);
ai:create_event(5, 480, 96, green_look_for_buildings);