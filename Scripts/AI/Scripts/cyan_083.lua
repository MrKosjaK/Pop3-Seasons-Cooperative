CompPlayer:init(TRIBE_CYAN);
local ai = CompPlayer(TRIBE_CYAN);

-- shaman ai options
ai:toggle_shaman_ai(true); -- enable it first u dummy

local sham = ai:get_shaman_ai(); -- get pointer to it as local, so it's fasto

sham:toggle_fall_damage_save(true, 60 + G_RANDOM(40));
sham:toggle_lightning_dodge(true, 60 + G_RANDOM(40));
sham:toggle_spell_check(true);

sham:set_spell_entry(1, M_SPELL_LIGHTNING_BOLT, {4, 5, 6, 7, 8}, 4, 4, 40000);
sham:set_spell_entry(2, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 5, 6, 7, 8}, 3, 3, 75000);
sham:set_spell_entry(3, M_SPELL_EARTHQUAKE, {1, 2, 3, 5, 6, 7, 8}, 2, 2, 120000);

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
local Area = CreateAreaInfo();
local my_enemies_table = {TRIBE_BLUE};

local function get_my_enemy()
  if (#my_enemies_table == 0) then
    return nil
  else
    return (my_enemies_table[G_RANDOM(#my_enemies_table) + 1]);
  end
end

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

local function cyan_defend_base(player)
  AI_SetVar(player, 11, 0);
  
  GetEnemyAreaInfo(player, 138, 136, 12, Area);
  
  if (Area:contains_people()) then
    -- our base is probably under attack?
	local e_priests = Area:get_person_count(M_PERSON_RELIGIOUS);
	local e_fws = Area:get_person_count(M_PERSON_SUPER_WARRIOR);
	local e_wars = Area:get_person_count(M_PERSON_WARRIOR);
	local e_braves = Area:get_person_count(M_PERSON_BRAVE);
	local e_shaman = Area:get_person_count(M_PERSON_MEDICINE_MAN);
	local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
	local my_fws = AI_GetUnitCount(player, M_PERSON_SUPER_WARRIOR);
	
	if ((e_priests + e_fws + e_wars + e_braves) >= 3) then
	  AI_SetVar(player, 11, 1);
	  -- murder, murder and murder!!!!!
	  -- marker 39
	  if ((my_priests + my_fws) >= 3) then
	    AI_SetAttackFlags(player, 3, 1, 0);
	    AI_SetAways(player, 0, 0, 50, 50, 0);
	    AI_SetShamanAway(player, false);
	    LOG("DEFENDING MYSELF T");
	    ATTACK(player, TRIBE_BLUE, (my_fws + my_priests), ATTACK_MARKER, 39, 999, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, 0); 
	    ai:set_event_ticks(4, 1024 + G_RANDOM(120));
	  end
	  
	  if (e_shaman > 0 and AI_ShamanFree(player)) then
	    LOG("DEFENDING MYSELF S1");
		AI_SetAttackFlags(player, 3, 1, 0);
		AI_SetAways(player, 0, 0, 0, 0, 0);
		AI_SetShamanAway(player, true);
		TARGET_SHAMAN(player, TRIBE_BLUE);
		SET_SPELL_ENTRY(player, 2, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 0);
		SET_SPELL_ENTRY(player, 3, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 1);
	    SET_SPELL_ENTRY(player, 4, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		SET_SPELL_ENTRY(player, 5, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 1);
		ATTACK(player, TRIBE_BLUE, 0, ATTACK_PERSON, M_PERSON_MEDICINE_MAN, 999, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, ATTACK_NORMAL, 0, -1, -1, 0);
	    ai:set_event_ticks(4, 1024 + G_RANDOM(120));
	  else
	    LOG("DEFENDING MYSELF S2");
	    AI_SetAttackFlags(player, 3, 1, 0);
		AI_SetAways(player, 0, 0, 0, 0, 0);
		AI_SetShamanAway(player, true);
		SET_SPELL_ENTRY(player, 2, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 2, 0);
		SET_SPELL_ENTRY(player, 3, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 2, 1);
	    SET_SPELL_ENTRY(player, 4, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		SET_SPELL_ENTRY(player, 5, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 1);
	    ATTACK(player, TRIBE_BLUE, 0, ATTACK_MARKER, 39, 999, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, ATTACK_NORMAL, 0, -1, -1, 0); 
	    ai:set_event_ticks(4, 1024 + G_RANDOM(120));
	  end
	end
  end
end

local function cyan_main_attack(player)
  -- this one will perform full navigation check before attacking
  if (AI_GetVar(player, 9) == 0 or AI_GetVar(player, 11) == 1) then
    return;
  end
  
  local target = get_my_enemy();
  
  if (target == nil) then
    return;
  end
  
  local shaman_busy = false;
  local result = NAV_CHECK(player, target, ATTACK_BUILDING, 0, FALSE);
  local pattern = G_RANDOM(6);
  
  if (result == 1) then
    local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
	  local my_fws = AI_GetUnitCount(player, M_PERSON_SUPER_WARRIOR);
	
    if (pattern == 0) then
	  -- invisible priests, how pathetic.
	  if (my_priests >= 3) then
	    LOG("MAIN ATTACK P1");
	    AI_SetAttackFlags(player, 1, 0, 0);
	    AI_SetAways(player, 0, 0, 100, 0, 0);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, target, math.min(8, my_priests), ATTACK_BUILDING, M_BUILDING_TEMPLE, 999, M_SPELL_INVISIBILITY, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		ai:set_event_ticks(8, 1024 + G_RANDOM(120));
		shaman_busy = true;
      end
	elseif (pattern == 1) then
	  -- invisible fws attacking shaman. pathetic.
	  if (my_fws >= 3) then
	    LOG("MAIN ATTACK P2");
	    AI_SetAttackFlags(player, 1, 0, 0);
	    AI_SetAways(player, 0, 0, 0, 100, 0);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, target, math.min(8, my_fws), ATTACK_PERSON, M_PERSON_MEDICINE_MAN, 999, M_SPELL_INVISIBILITY, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		ai:set_event_ticks(8, 1024 + G_RANDOM(120));
		shaman_busy = true;
      end
	elseif (pattern == 2 and AI_GetVar(player, 10) == 0) then
	  -- 80% priests and 20% fws, no invis
	  if (my_priests >= 4 and my_fws >= 2) then
	    LOG("MAIN ATTACK P3");
	    AI_SetAttackFlags(player, 1, 0, 0);
	    AI_SetAways(player, 0, 0, 80, 0, 20);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, target, math.min(16, (my_priests + my_fws)), ATTACK_BUILDING, M_BUILDING_SUPER_TRAIN, 999, 0, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		ai:set_event_ticks(8, 1024 + G_RANDOM(120));
      end
	elseif (pattern == 3) then
	  -- 50% priests and 50% fws, invis.
	  if (my_fws >= 3 and my_priests >= 3) then
	    LOG("MAIN ATTACK P4");
	    AI_SetAttackFlags(player, 1, 0, 0);
	    AI_SetAways(player, 0, 0, 50, 50, 0);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, target, math.min(16, (my_priests + my_fws)), ATTACK_BUILDING, M_BUILDING_TEMPLE, 999, M_SPELL_INVISIBILITY, M_SPELL_INVISIBILITY, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		ai:set_event_ticks(8, 1024 + G_RANDOM(120));
		shaman_busy = true;
      end
	elseif (pattern == 4 and AI_GetVar(player, 10) == 0) then
	  -- 20% priests, 80% fws, no invis
	  if (my_priests >= 2 and my_fws >= 4) then
	    LOG("MAIN ATTACK P5");
	    AI_SetAttackFlags(player, 1, 0, 0);
	    AI_SetAways(player, 0, 0, 20, 0, 80);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, target, math.min(12, (my_priests + my_fws)), ATTACK_BUILDING, M_BUILDING_TEMPLE, 999, 0, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		ai:set_event_ticks(8, 1024 + G_RANDOM(120));
      end
	elseif (pattern == 5 and AI_GetVar(player, 10) == 0) then
	  -- 30% braves, 20% priests, 50% fws, no invis
	  if (my_priests >= 2 and my_fws >= 2) then
	    LOG("MAIN ATTACK P6");
	    AI_SetAttackFlags(player, 1, 0, 0);
	    AI_SetAways(player, 30, 0, 20, 0, 50);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, target, math.min(18, 7 + G_RANDOM(12)), ATTACK_BUILDING, M_BUILDING_SUPER_TRAIN, 999, 0, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		ai:set_event_ticks(8, 1024 + G_RANDOM(120));
      end
	end
	
	if (not shaman_busy) then
	  if (AI_ShamanFree(player) and AI_GetVar(player, 10) == 0) then
	    -- send shaman to murder opponent. in case she is FREE!!!!!
		
		if (sham:can_cast_spell_from_entry(2) or sham:can_cast_spell_from_entry(3)) then
		  LOG("MAIN ATTACK S");
		  AI_SetAttackFlags(player, 1, 1, 0);
	      AI_SetAways(player, 0, 0, 0, 0, 0);
		  AI_SetShamanAway(player, true);
		  SET_SPELL_ENTRY(player, 2, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 2, 0);
		  SET_SPELL_ENTRY(player, 3, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 2, 1);
	      SET_SPELL_ENTRY(player, 4, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		  SET_SPELL_ENTRY(player, 5, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 1);
		  ATTACK(player, target, 0, ATTACK_BUILDING, 0, 999, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, ATTACK_NORMAL, 0, -1, -1, 0);
		  ai:set_event_ticks(8, 1024 + G_RANDOM(120));
		end
	  end
	end
  end
end

local function cyan_mid_attack(player)
  AI_SetVar(player, 10, 0);
  -- attacking momentos
  if (AI_GetVar(player, 9) == 0 and AI_GetVar(player, 11) == 1) then
    return;
  end
  
  -- get info on our midhill first
  GetEnemyAreaInfo(player, 138, 78, 6, Area);
  
  if (Area:contains_people()) then
    local e_priests = Area:get_person_count(M_PERSON_RELIGIOUS);
	local e_fws = Area:get_person_count(M_PERSON_SUPER_WARRIOR);
	local e_braves = Area:get_person_count(M_PERSON_BRAVE);
	local e_shaman = Area:get_person_count(M_PERSON_MEDICINE_MAN);
	local my_priests = AI_GetUnitCount(player, M_PERSON_RELIGIOUS);
	
	if (e_braves > 0 and e_shaman == 0 and e_fws == 0 and e_priests == 0) then
	  -- mid only has braves, send some priests.
	  if (my_priests > 0) then
	    AI_SetAttackFlags(player, 1, 1, 0);
		AI_SetAways(player, 0, 0, 90, 10, 0);
		AI_SetShamanAway(player, false);
		
		ATTACK(player, TRIBE_BLUE, math.min(6, e_braves >> 2), ATTACK_MARKER, 6, 999, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, 0);
	    LOG("ATTACKING MID 1");
	    ai:set_event_ticks(5, 720 + G_RANDOM(120));
		return;
	  end
	end
	
	if (my_priests >= e_priests and e_fws == 0 and e_shaman == 0) then
	  -- mid only hass priests, we got more priests when what mid has, try attacking.
	  -- we won't pull shaman for this attack
	  AI_SetAttackFlags(player, 2, 1, 0);
	  -- do not group at drum tower
	  AI_SetAways(player, 0, 0, 75, 25, 0);
	  AI_SetShamanAway(player, false);
	  
	  ATTACK(player, TRIBE_BLUE, math.min(e_priests, my_priests), ATTACK_MARKER, 6, 999, 0, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
	  LOG("ATTACKING MID 2");
	  ai:set_event_ticks(5, 720 + G_RANDOM(120));
	  return
	end
	
	if (e_fws > 0 and e_priests == 0) then
	  AI_SetVar(player, 10, 1);
	  -- mid has fws, we'll check if theres a shaman as well.
	  if (AI_ShamanFree(player)) then
	    if (e_shaman > 0) then
	      LOG("ATTACKING MID 4 S1");
		  AI_SetAttackFlags(player, 1, 0, 0);
	      AI_SetAways(player, 0, 0, 0, 0, 0);
	      AI_SetShamanAway(player, true);
		  TARGET_SHAMAN(player, TRIBE_BLUE); -- target the bitch
		  SET_SPELL_ENTRY(player, 2, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 0);
		  SET_SPELL_ENTRY(player, 3, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 1);
	      SET_SPELL_ENTRY(player, 4, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		  SET_SPELL_ENTRY(player, 5, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 1);
		  ATTACK(player, TRIBE_BLUE, 0, ATTACK_PERSON, M_PERSON_MEDICINE_MAN, 999, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, ATTACK_NORMAL, 0, -1, -1, 0);
	      ai:set_event_ticks(5, 720 + G_RANDOM(120));
		  return;
	    else
	      LOG("ATTACKING MID 4 S2");
	      AI_SetAttackFlags(player, 1, 0, 0);
	      AI_SetAways(player, 0, 0, 0, 0, 0);
	      AI_SetShamanAway(player, true);
		    SET_SPELL_ENTRY(player, 2, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 2, 0);
		    SET_SPELL_ENTRY(player, 3, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> 2, 32, 2, 1);
	      SET_SPELL_ENTRY(player, 4, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		    SET_SPELL_ENTRY(player, 5, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 1);
		    ATTACK(player, TRIBE_BLUE, 0, ATTACK_MARKER, 6, 999, M_SPELL_INSECT_PLAGUE, M_SPELL_HYPNOTISM, M_SPELL_INSECT_PLAGUE, ATTACK_NORMAL, 0, -1, -1, 0);
	      ai:set_event_ticks(5, 720 + G_RANDOM(120));
		  return;
		end
	  end
	end
	
	if (e_fws == 0 and e_shaman > 0) then
	  AI_SetVar(player, 10, 1);
	  -- mid has priests, and a shaman, include our own shaman and murder her.
	  -- shaman will be in its own independent attack
	  if (AI_ShamanFree(player)) then
	    if (e_priests > 0) then
	      AI_SetAttackFlags(player, 2, 1, 0);
	      AI_SetAways(player, 0, 0, 75, 25, 0);
	      AI_SetShamanAway(player, false);
	  
	      -- first troops.
		  LOG("ATTACKING MID 3 T");
	      ATTACK(player, TRIBE_BLUE, math.min(e_priests, my_priests), ATTACK_MARKER, 6, 999, 0, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		end
		
		-- now shaman.
		AI_SetAttackFlags(player, 1, 0, 0);
	    AI_SetAways(player, 0, 0, 0, 0, 0);
	    AI_SetShamanAway(player, true);
		TARGET_SHAMAN(player, TRIBE_BLUE); -- target the bitch
		SET_SPELL_ENTRY(player, 2, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 0);
		SET_SPELL_ENTRY(player, 3, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 1);
	    SET_SPELL_ENTRY(player, 4, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		SET_SPELL_ENTRY(player, 5, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 1);
		ATTACK(player, TRIBE_BLUE, 0, ATTACK_PERSON, M_PERSON_MEDICINE_MAN, 999, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, ATTACK_NORMAL, 0, -1, -1, 0);
	    LOG("ATTACKING MID 3 S");
	    ai:set_event_ticks(5, 840 + G_RANDOM(240));
		return;
	  end
	end
	
	if (e_fws > 0 and e_priests > 0 and e_shaman > 0) then
	  -- mid has all kinds of troops.
	  -- try a double attack?
	  if (AI_ShamanFree(player)) then
	    LOG("ATTACKING MID 5 S");
	    AI_SetAttackFlags(player, 1, 1, 0);
	    AI_SetAways(player, 0, 0, 0, 0, 0);
	    AI_SetShamanAway(player, true);
		TARGET_SHAMAN(player, TRIBE_BLUE); -- target the bitch
		SET_SPELL_ENTRY(player, 2, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 0);
		SET_SPELL_ENTRY(player, 3, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> 2, 32, 4, 1);
	    SET_SPELL_ENTRY(player, 4, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 0);
		SET_SPELL_ENTRY(player, 5, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2, 32, 3, 1);
		ATTACK(player, TRIBE_BLUE, 0, ATTACK_PERSON, M_PERSON_MEDICINE_MAN, 999, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, ATTACK_NORMAL, 0, -1, -1, 0);
	  
	    if (my_priests >= e_priests) then
		  -- launch a supportive attack.
		  AI_SetAttackFlags(player, 2, 1, 0);
	      AI_SetAways(player, 0, 0, 80, 20, 0);
	      AI_SetShamanAway(player, false);
	  
	      -- first troops.
		  LOG("ATTACKING MID 5 T");
	      ATTACK(player, TRIBE_BLUE, math.min(e_priests, my_priests), ATTACK_MARKER, 6, 999, 0, 0, 0, ATTACK_NORMAL, 0, 30, -1, 0);
		end
		
		ai:set_event_ticks(5, 840 + G_RANDOM(240));
		return;
	  end
	end
  end
end

local function cyan_check_towers(player)
  if (AI_GetVar(player, 9) == 0 or AI_GetVar(player, 10) == 1 or AI_GetVar(player, 11) == 1) then
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
	  
	if (turn < 1440) then
	  sham:toggle_converting(true);
	  if (turn < 720) then
	    SHAMAN_DEFEND(player, 134, 84, TRUE);
	  else
	    local spot = G_RANDOM(4);
		if (spot == 0) then
		  SHAMAN_DEFEND(player, 138, 136, TRUE);
		elseif (spot == 1) then
		  SHAMAN_DEFEND(player, 126, 144, TRUE);
		elseif (spot == 2) then
		  SHAMAN_DEFEND(player, 128, 122, TRUE);
		elseif (spot == 3) then
		  SHAMAN_DEFEND(player, 156, 140, TRUE);
		elseif (spot == 4) then
		  SHAMAN_DEFEND(player, 148, 158, TRUE);
		end
	  end
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
    if (temples == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 10);
	end
  end
  
  if (AI_GetVar(player, 3) == 1) then
	if (fw_trains == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 12);
	end
  end
  
  if (AI_GetVar(player, 4) == 1) then
    if (fw_trains > 0 and temples > 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 18);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 20);
	end
  end
end

local function cyan_try_pray_totem(player)
  if (AI_GetVar(player, 13) == 1) then
    if (GET_HEAD_TRIGGER_COUNT(130, 12) > 0) then
      AI_SetAways(player, 10, 10, 10, 10, 10);
      AI_SetShamanAway(player, false);
      PRAY_AT_HEAD(player, 3, 54);
      ai:set_event_ticks(9, 720 + G_RANDOM(360));
    else
      AI_SetVar(player, 13, 2);
    end
  end
end

local function cyan_check_my_enemies(player)
  if (AI_GetVar(player, 12) == 1) then
    -- blue died.
    for i = 1, #my_enemies_table do
      if (my_enemies_table[i] == TRIBE_BLUE) then
        my_enemies_table[i] = nil;
      end
    end
  end
  
  if (AI_GetVar(player, 13) == 2) then
    -- pray'd totem, yellow is now accessible.
    my_enemies_table[#my_enemies_table + 1] = TRIBE_YELLOW;
    AI_SetVar(player, 13, 3);
  end
  
  if (AI_GetVar(player, 14) == 1) then
    -- yellow died.
    for i = 1, #my_enemies_table do
      if (my_enemies_table[i] == TRIBE_YELLOW) then
        my_enemies_table[i] = nil;
      end
    end
  end
  
  if (AI_GetVar(player, 15) == 1) then
    -- yellow died.
    for i = 1, #my_enemies_table do
      if (my_enemies_table[i] == TRIBE_RED) then
        my_enemies_table[i] = nil;
      end
    end
  end
end

-- events
ai:create_event(1, 174, 46, cyan_build);
ai:create_event(2, 64, 12, cyan_convert);
ai:create_event(3, 132, 32, cyan_early_towers);
ai:create_event(4, 324, 64, cyan_defend_base);
ai:create_event(5, 370, 70, cyan_mid_attack);
ai:create_event(6, 480, 96, cyan_look_for_buildings);
ai:create_event(7, 422, 104, cyan_check_towers);
ai:create_event(8, 512, 128, cyan_main_attack);
ai:create_event(9, 256, 64, cyan_try_pray_totem);
ai:create_event(10, 16, 8, cyan_check_my_enemies);
