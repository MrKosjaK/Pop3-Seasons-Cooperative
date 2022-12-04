CompPlayer:init(TRIBE_GREEN);
local ai = CompPlayer(TRIBE_GREEN);

ai:toggle_shaman_ai(true);

local sham = ai:get_shaman_ai();

sham:toggle_fall_damage_save(true, 20 + G_RANDOM(50));
sham:toggle_lightning_dodge(true, 20 + G_RANDOM(50));
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
local Area = CreateAreaInfo();
local my_enemies_table = {TRIBE_RED};

local function get_my_enemy()
  if (#my_enemies_table == 0) then
    return nil
  else
    return (my_enemies_table[G_RANDOM(#my_enemies_table) + 1]);
  end
end

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
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 6);
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
  if (AI_GetVar(player, 3) == 0) then
	return;
  end
  
  local my_pop = AI_GetPopCount(player);
  
  if (my_pop >= 30) then
    -- only bother with said pop or above
	for i = 1, 6 do
	  if (not ai:is_tower_constructed(i)) then
	    ai:construct_tower(i);
		break;
      end
	end
  end
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

local function green_mid_attack(player)
  AI_SetVar(player, 10, 0);
  
  if (AI_GetVar(player, 3) == 0) then
    return;
  end
  
  -- get info on our midhill first
  GetEnemyAreaInfo(player, 58, 80, 5, Area);
  
  if (Area:contains_people()) then
    local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
	local e_wars = Area:get_person_count(M_PERSON_WARRIOR);
	local e_priests = Area:get_person_count(M_PERSON_RELIGIOUS);
	
	if (e_wars > 0 and e_priests == 0) then
	  AI_SetVar(player, 10, 1);
	  if (my_priests > 0) then
	    -- only fws/braves on hill, can try sending wars.
	    AI_SetAttackFlags(player, 3, 0, 0);
	    AI_SetAways(player, 0, 0, 100, 0, 0);
	    AI_SetShamanAway(player, false);
	  
	    ATTACK(player, TRIBE_RED, math.min(e_wars, my_priests >> 1), ATTACK_MARKER, 40, 500, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, 0);
	  end
	  return;
	end
	
	if (e_priests > 0 and e_wars > 0) then
	  AI_SetVar(player, 10, 1);
	  -- send shaman and hypno/swarm them.
	  if (AI_ShamanFree(player)) then
	    if (player_can_cast(M_SPELL_HYPNOTISM, player) ~= 3) then
	      set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
		  set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
		  set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
	    end
		
		AI_SetAttackFlags(player, 3, 1, 0);
	    AI_SetAways(player, 0, 0, 0, 0, 0);
	    AI_SetShamanAway(player, true);
	    SET_SPELL_ENTRY(player, 2, M_SPELL_GHOST_ARMY, SPELL_COST(M_SPELL_GHOST_ARMY) >> 2, 32, 1, 0);
	    SET_SPELL_ENTRY(player, 3, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
	  
		ATTACK(player, TRIBE_RED, 0, ATTACK_MARKER, 40, 400, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, ATTACK_NORMAL, 0, -1, -1, 0);
		return;
	  end
	end
  end
end

local function green_main_attack(player)
  if (AI_GetVar(player, 3) == 0 or AI_GetVar(player, 10) == 1) then
    return;
  end
  
  local target = get_my_enemy();
  
  if (target == nil) then
    return;
  end
  
  local shaman_busy = false;
  local result = NAV_CHECK(player, target, ATTACK_BUILDING, 0, FALSE);
  local idx = AI_GetVar(player, 11);
  
  if (result == 1) then
    if (idx == 0) then
	  local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
	  if (my_priests >= 4) then
	    if (MANA(player) >= SPELL_COST(M_SPELL_INVISIBILITY) << 1) then
		  AI_SetAttackFlags(player, 0, 0, 0);
		  AI_SetAways(player, 0, 0, 100, 0, 0);
		  AI_SetShamanAway(player, false);
		  
		  ATTACK(player, target, math.min(10, my_priests), ATTACK_BUILDING, M_BUILDING_TEMPLE, 400, M_SPELL_INVISIBILITY, M_SPELL_INVISIBILITY, M_SPELL_INVISIBILITY, ATTACK_NORMAL, 0, 32, -1, 0);
		end
	  end
      AI_SetVar(player, 11, 1);
	elseif (idx == 1) then
	  local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
	  local my_wars = AI_GetUnitCount(player, M_PERSON_WARRIOR);
	  
	  if (my_priests >= 3 and my_wars >= 3) then
	    AI_SetAttackFlags(player, 0, 0, 0);
		AI_SetAways(player, 5, 50, 50, 0, 0);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, target, math.min(16, (my_priests + my_wars) >> 1), ATTACK_BUILDING, M_BUILDING_WARRIOR_TRAIN, 500, 0, 0, 0, ATTACK_NORMAL, 0, 32, -1, 0);
	  end
	  AI_SetVar(player, 11, 0);
	end
	
	if (AI_ShamanFree(player)) then
	  if (sham:can_cast_spell_from_entry(3) and AI_GetVar(player, 10) == 0) then
	    AI_SetAttackFlags(player, 2, 1, 0);
		AI_SetAways(player, 0, 0, 0, 0, 0);
		AI_SetShamanAway(player, true);
		
		if (player_can_cast(M_SPELL_HYPNOTISM, player) ~= 3) then
	      set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
		  set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
		  set_player_can_cast_temp(M_SPELL_HYPNOTISM, player, 1);
	    end
		
		SET_SPELL_ENTRY(player, 2, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		SET_SPELL_ENTRY(player, 3, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 2, 0);
		ATTACK(player, target, 0, ATTACK_BUILDING, 0, 600, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, ATTACK_NORMAL, 0, 32, -1, 0);
	  end
	end
  end
end

local function green_convert(player)
  if (AI_GetVar(player, 3) == 0) then
	local turn = getTurn();
	  
	if (turn < 840) then
      sham:toggle_converting(true);
	  SHAMAN_DEFEND(player, 64, 58, TRUE);
	else
      AI_SetVar(player, 3, 1);
	  SHAMAN_DEFEND(player, 54, 126, TRUE);
      sham:toggle_converting(false);
    end
  end
end

local function green_try_pray_totem(player)
  if (AI_GetVar(player, 13) == 1) then
    if (GET_HEAD_TRIGGER_COUNT(56, 24) > 0) then
      AI_SetAways(player, 10, 10, 10, 10, 10);
      AI_SetShamanAway(player, false);
      PRAY_AT_HEAD(player, 3, 56);
      ai:set_event_ticks(9, 720 + G_RANDOM(360));
    else
      AI_SetVar(player, 13, 2);
    end
  end
end

local function green_check_my_enemies(player)
  if (AI_GetVar(player, 14) == 1) then
    -- red died.
    for i = 1, #my_enemies_table do
      if (my_enemies_table[i] == TRIBE_RED) then
        my_enemies_table[i] = nil;
      end
    end
  end
  
  if (AI_GetVar(player, 13) == 2) then
    -- pray'd totem, blue is now accessible.
    my_enemies_table[#my_enemies_table + 1] = TRIBE_BLUE;
    AI_SetVar(player, 13, 3);
  end
  
  if (AI_GetVar(player, 15) == 1) then
    -- blue died.
    for i = 1, #my_enemies_table do
      if (my_enemies_table[i] == TRIBE_BLUE) then
        my_enemies_table[i] = nil;
      end
    end
  end
  
  if (AI_GetVar(player, 16) == 1) then
    -- blue died.
    for i = 1, #my_enemies_table do
      if (my_enemies_table[i] == TRIBE_YELLOW) then
        my_enemies_table[i] = nil;
      end
    end
  end
end

ai:create_event(1, 90, 24, green_convert);
ai:create_event(2, 192, 84, green_build);
ai:create_event(3, 372, 90, green_check_towers);
ai:create_event(4, 140, 44, green_early_towers);
ai:create_event(5, 480, 96, green_look_for_buildings);
ai:create_event(6, 1736, 362, green_mid_attack);
ai:create_event(7, 2542, 786, green_main_attack);
ai:create_event(8, 199, 99, function() end);
ai:create_event(9, 256, 64, green_try_pray_totem);
ai:create_event(10, 16, 8, green_check_my_enemies);