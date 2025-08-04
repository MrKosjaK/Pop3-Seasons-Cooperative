include("turnclock.lua");
local EnemyArea = create_enemy_search_area();


local _ADDON_INDEX = 1;
local FLOOR = math.floor;
local MIN = math.min;
local MP_POS = MapPosXZ.new();

-- Data base for computer's starting things.
-- The way it is designed is index will be incremented by 1 every time you call
-- spawn_computer_addons() function.
local _MAP_ADDONS =
{
  {
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE, 130, 52},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE, 130, 44},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE_2, 122, 48},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE_2, 176, 48},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_WARRIOR_TRAIN, 168, 49},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_SUPER_TRAIN, 134, 84},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_2, 124, 86},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_2, 124, 94},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_3, 132, 94},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_3, 140, 94},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 168, 74},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 162, 112},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 170, 96},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 184, 108},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 126, 102},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 178, 42},
    {AI_MEDIUM, T_PERSON, 12, M_PERSON_BRAVE, 142, 70},
    {AI_HARD, T_PERSON, 6, M_PERSON_WARRIOR, 142, 70},
    {AI_HARD, T_PERSON, 6, M_PERSON_SUPER_WARRIOR, 142, 70},
    {AI_EXTREME, T_PERSON, 12, M_PERSON_BRAVE, 142, 70},
    {AI_EXTREME, T_PERSON, 6, M_PERSON_WARRIOR, 142, 70},
    {AI_EXTREME, T_PERSON, 6, M_PERSON_SUPER_WARRIOR, 142, 70},
  },
  
  {
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE, 36, 68},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE, 44, 68},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE_2, 38, 60},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_TEPEE_2, 46, 60},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_SUPER_TRAIN, 20, 82},
    {AI_MEDIUM, T_BUILDING, M_BUILDING_WARRIOR_TRAIN, 52, 112},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_3, 10, 76},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_3, 10, 84},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_3, 46, 76},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_3, 38, 76},
    {AI_HARD, T_BUILDING, M_BUILDING_TEPEE_3, 30, 76},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 246, 84},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 240, 100},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 252, 106},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 30, 132},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 20, 128},
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 22, 110},
    {AI_MEDIUM, T_PERSON, 10, M_PERSON_BRAVE, 64, 90},
    {AI_HARD, T_PERSON, 7, M_PERSON_WARRIOR, 64, 90},
    {AI_HARD, T_PERSON, 5, M_PERSON_SUPER_WARRIOR, 64, 90},
    {AI_EXTREME, T_PERSON, 16, M_PERSON_BRAVE, 64, 90},
    {AI_EXTREME, T_PERSON, 8, M_PERSON_WARRIOR, 64, 90},
    {AI_EXTREME, T_PERSON, 4, M_PERSON_SUPER_WARRIOR, 64, 90},
  }
}

function spawn_computer_addons(player_num, difficulty)
  local t = _MAP_ADDONS[_ADDON_INDEX];
  local d = difficulty;
  local p = player_num;
  
  for i,item in ipairs(t) do
    if (d >= item[1]) then
      -- Spawn building.
      if (item[2] == T_BUILDING) then
        create_building(item[3], p, item[4], item[5], G_RANDOM(4)); 
      end
      -- Spawn people
      if (item[2] == T_PERSON) then
        local amount = item[3];
        
        for k = 1,amount do
          create_person(item[4], p, item[5], item[6]);
        end
      end
    end
  end
  
  _ADDON_INDEX = _ADDON_INDEX + 1;
end

-- AI DEFINES
-- PLAYER ONE
local WAY_POINT_EASY_MKS = {39, 40, 41, 42};
local PLR1_NUM_DEFENCE_TOWERS = 5; -- default, will change depending on difficulty.
local PLR1_CONVERT_POINTS = {48, 49, 50};
local PLR1_ANNOYANCE_GROUPS = {70, 71, 72, 73, 74};

-- PLAYER TWO
local PLR2_WAY_POINT_EASY_MKS = {62, 63, 64, 65};
local PLR2_NUM_DEFENCE_TOWERS = 8;
local PLR2_CONVERT_POINTS = {51, 52, 53};
local PLR2_ANNOYANCE_GROUPS = {70, 71, 72, 73, 74};

-- cache
local PLR1_BLDG_LIST = nil;
local PLR2_BLDG_LIST = nil;
PLR1_SH = nil;
PLR2_SH = nil;

-- user vars
local USER_TOWER_BUILT = 1;
local USER_FAR_FRONT_STATUS = 2;
local USER_OUR_FRONT_STATUS = 3;
local USER_BASE_STATUS = 4;
local USER_DEF3_ENEMY_COUNT = 5;
local USER_DEF3_HAS_SHAMAN = 6;
local USER_DEF3_FIRST_OWNER = 7;
local USER_DEF2_ENEMY_COUNT = 8;
local USER_DEF2_HAS_SHAMAN = 9;
local USER_DEF2_FIRST_OWNER = 10;
local USER_DEF1_ENEMY_COUNT = 11;
local USER_DEF1_HAS_SHAMAN = 12;
local USER_DEF1_FIRST_OWNER = 13;
local USER_BASIC_ATTACK = 64;
local USER_EXTRA_ATTACK = 65;
local USER_SHAMAN_DEFEND = 66;
local USER_TROOPS_DEFEND = 67;
local USER_MAJOR_TROOP_ATTACK = 68;
local USER_SHAMAN_ATTACK = 69;

-- AI EVENTS

local function _AI_CHECK_BUCKETS_EASY(_p, _sturn)
  if (_sturn < 10800 or count_pop(_p) < 100) then
    ai_enable_buckets(_p, TRUE);
    ai_set_spell_bucket_count(_p, M_SPELL_BLAST, 16);
    ai_set_spell_bucket_count(_p, M_SPELL_CONVERT_WILD, 16);
    ai_set_spell_bucket_count(_p, M_SPELL_INSECT_PLAGUE, 32);
    ai_set_spell_bucket_count(_p, M_SPELL_LIGHTNING_BOLT, 48);
    ai_set_spell_bucket_count(_p, M_SPELL_WHIRLWIND, 64);
  else
    ai_enable_buckets(_p, TRUE);
    ai_set_spell_bucket_count(_p, M_SPELL_BLAST, 8);
    ai_set_spell_bucket_count(_p, M_SPELL_CONVERT_WILD, 8);
    ai_set_spell_bucket_count(_p, M_SPELL_INSECT_PLAGUE, 16);
    ai_set_spell_bucket_count(_p, M_SPELL_LIGHTNING_BOLT, 24);
    ai_set_spell_bucket_count(_p, M_SPELL_WHIRLWIND, 32);
  end
end

local function _AI_CHECK_BUCKETS_M_H(_p, _sturn)
  if (_sturn < 7200 or count_pop(_p) < 80) then
    ai_enable_buckets(_p, TRUE);
    ai_set_spell_bucket_count(_p, M_SPELL_BLAST, 12);
    ai_set_spell_bucket_count(_p, M_SPELL_CONVERT_WILD, 12);
    ai_set_spell_bucket_count(_p, M_SPELL_INSECT_PLAGUE, 24);
    ai_set_spell_bucket_count(_p, M_SPELL_LIGHTNING_BOLT, 36);
    ai_set_spell_bucket_count(_p, M_SPELL_HYPNOTISM, 40);
    ai_set_spell_bucket_count(_p, M_SPELL_WHIRLWIND, 48);
  else
    ai_enable_buckets(_p, TRUE);
    ai_set_spell_bucket_count(_p, M_SPELL_BLAST, 6);
    ai_set_spell_bucket_count(_p, M_SPELL_CONVERT_WILD, 6);
    ai_set_spell_bucket_count(_p, M_SPELL_INSECT_PLAGUE, 12);
    ai_set_spell_bucket_count(_p, M_SPELL_LIGHTNING_BOLT, 18);
    ai_set_spell_bucket_count(_p, M_SPELL_HYPNOTISM, 20);
    ai_set_spell_bucket_count(_p, M_SPELL_WHIRLWIND, 24);
  end
end

local function _AI_CHECK_BUCKETS_EXTREME(_p, _sturn)
  if (_sturn < 3600 or count_pop(_p) < 60) then
    ai_enable_buckets(_p, TRUE);
    ai_set_spell_bucket_count(_p, M_SPELL_BLAST, 4);
    ai_set_spell_bucket_count(_p, M_SPELL_CONVERT_WILD, 4);
    ai_set_spell_bucket_count(_p, M_SPELL_INSECT_PLAGUE, 8);
    ai_set_spell_bucket_count(_p, M_SPELL_LIGHTNING_BOLT, 10);
    ai_set_spell_bucket_count(_p, M_SPELL_HYPNOTISM, 12);
    ai_set_spell_bucket_count(_p, M_SPELL_WHIRLWIND, 16);
  else
    ai_enable_buckets(_p, TRUE);
    ai_set_spell_bucket_count(_p, M_SPELL_BLAST, 2);
    ai_set_spell_bucket_count(_p, M_SPELL_CONVERT_WILD, 2);
    ai_set_spell_bucket_count(_p, M_SPELL_INSECT_PLAGUE, 4);
    ai_set_spell_bucket_count(_p, M_SPELL_LIGHTNING_BOLT, 5);
    ai_set_spell_bucket_count(_p, M_SPELL_HYPNOTISM, 6);
    ai_set_spell_bucket_count(_p, M_SPELL_WHIRLWIND, 8);
  end
end

-- CONVERTING STATE

local function _AI1_CHECK_CONVERT_EASY(_p, _sturn)
  if (count_pop(_p) < 20) then
    ai_set_converting_info(_p, true, true, 16);
    PLR1_SH:toggle_converting_wilds(true);
  else
    ai_set_converting_info(_p, false, true, 16);
    PLR1_SH:toggle_converting_wilds(false);
  end
end

local function _AI1_CHECK_CONVERT_M_H(_p, _sturn)
  if (_sturn < 720) then
    ai_set_converting_info(_p, true, true, 24);
    PLR1_SH:toggle_converting_wilds(true);
    
    if (G_RANDOM(4) > 0) then
      ai_convert_marker(_p, PLR1_CONVERT_POINTS[G_RANDOM(#PLR1_CONVERT_POINTS) + 1]);
    end
  else
    ai_set_converting_info(_p, false, true, 24);
    PLR1_SH:toggle_converting_wilds(false);
  end
end

local function _AI1_CHECK_CONVERT_EXTREME(_p, _sturn)
  if (_sturn < 720) then
    ai_set_converting_info(_p, true, true, 32);
    PLR1_SH:toggle_converting_wilds(true);
    
    if (G_RANDOM(4) > 0) then
      ai_convert_marker(_p, PLR1_CONVERT_POINTS[G_RANDOM(#PLR1_CONVERT_POINTS) + 1]);
    end
  else
    ai_set_converting_info(_p, false, true, 32);
    PLR1_SH:toggle_converting_wilds(false);
  end
end

local function _AI2_CHECK_CONVERT_EASY(_p, _sturn)
  if (count_pop(_p) < 20) then
    ai_set_converting_info(_p, true, true, 16);
    PLR2_SH:toggle_converting_wilds(true);
  else
    ai_set_converting_info(_p, false, true, 16);
    PLR2_SH:toggle_converting_wilds(false);
  end
end

local function _AI2_CHECK_CONVERT_M_H(_p, _sturn)
  if (_sturn < 720) then
    ai_set_converting_info(_p, true, true, 24);
    PLR2_SH:toggle_converting_wilds(true);
    
    if (G_RANDOM(4) > 0) then
      ai_convert_marker(_p, PLR2_CONVERT_POINTS[G_RANDOM(#PLR2_CONVERT_POINTS) + 1]);
    end
  else
    ai_set_converting_info(_p, false, true, 24);
    PLR2_SH:toggle_converting_wilds(false);
  end
end

local function _AI2_CHECK_CONVERT_EXTREME(_p, _sturn)
  if (_sturn < 720) then
    ai_set_converting_info(_p, true, true, 32);
    PLR2_SH:toggle_converting_wilds(true);
    
    if (G_RANDOM(4) > 0) then
      ai_convert_marker(_p, PLR2_CONVERT_POINTS[G_RANDOM(#PLR2_CONVERT_POINTS) + 1]);
    end
  else
    ai_set_converting_info(_p, false, true, 32);
    PLR2_SH:toggle_converting_wilds(false);
  end
end

-- BASIC ATTACKS


local function _AI1_BASIC_ATTACK_EASY(_p, _sturn)
  if (_sturn > 4320) then
    -- check if we're performing basic attack already
    local var_value = ai_getv(_p, USER_BASIC_ATTACK);
    
    if (var_value > 50) then
      -- can do another attack.
      -- first scan area around waypoint markers
      EnemyArea:clear();
      EnemyArea:scan(_p, 210, 110, 5);
      
      if (not EnemyArea:has_enemy()) then
        local any_troops = count_troops(_p);
          
        if (any_troops >= 2) then
          local target_enemy = get_random_alive_human_player();
          if (target_enemy ~= -1) then
            local attack_spell = M_SPELL_NONE;
            
            if (G_RANDOM(2) == 1) then
              ai_set_shaman_away(_p, true);
              attack_spell = M_SPELL_WHIRLWIND;
            end
            
            ai_set_aways(_p, 0, 75, 0, 25, 0);
            ai_set_attack_flags(_p, 2, 0, 1);
            ai_set_atk_var(_p, USER_BASIC_ATTACK);
            ai_do_attack(_p, target_enemy, 2 + G_RANDOM(any_troops >> 1), ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 90, attack_spell, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, WAY_POINT_EASY_MKS[G_RANDOM(#WAY_POINT_EASY_MKS) + 1], -1, 0); 
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_shaman_away(_p, false);
          end
        end
      else
        -- something is at waypoint marker, try attacking it?
        local target_enemy = get_random_alive_human_player();
        
        if (target_enemy ~= -1) then
          local num_enemies = EnemyArea:get_people_count();
          local any_troops = count_troops(_p);
          
          if (any_troops > num_enemies) then
            -- have more troops than there are enemies, try attacking
            ai_set_aways(_p, 0, 80, 0, 20, 0);
            ai_set_attack_flags(_p, 3, 0, 1);
            ai_set_shaman_away(_p, false);
            ai_set_atk_var(_p, USER_BASIC_ATTACK);
            ai_do_attack(_p, target_enemy, (any_troops >> 1), ATTACK_MARKER, 43, 150, M_SPELL_NONE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, -1, -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
          elseif (ai_shaman_available(_p)) then
            -- try sending shaman with some spells
            ai_set_aways(_p, 20, 60, 0, 20, 0);
            ai_set_attack_flags(_p, 3, 0, 1);
            ai_set_shaman_away(_p, true);
            ai_set_atk_var(_p, USER_BASIC_ATTACK);
            ai_do_attack(_p, target_enemy, (any_troops >> 1), ATTACK_MARKER, 43, 150, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_INSECT_PLAGUE, ATTACK_NORMAL, 0, -1, -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_shaman_away(_p, false);
          end
        end
      end
    else
      -- check whats going on
      if (var_value >= 1 and var_value < 7) then
        -- reset variable to check it again
        ai_setv(_p, USER_BASIC_ATTACK, 52);
      end
      
      if (var_value == 7) then
        -- navigation failed... try vehicles?
        ai_setv(_p, USER_BASIC_ATTACK, 52);
      end
    end
  end
end

-- SOME DEFENSE BUILD UP

local function _AI1_CHECK_FAR_FRONT(_p, _sturn)
  EnemyArea:clear();
  ai_setv(_p, USER_FAR_FRONT_STATUS, 0);
  ai_setv(_p, USER_DEF3_ENEMY_COUNT, 0);
  ai_setv(_p, USER_DEF3_HAS_SHAMAN, 0);
  ai_setv(_p, USER_DEF3_FIRST_OWNER, 0);
  
  EnemyArea:scan(_p, 210, 110, 5);
  
  if (EnemyArea:has_enemy()) then
    ai_setv(_p, USER_FAR_FRONT_STATUS, 1);
    ai_setv(_p, USER_DEF3_ENEMY_COUNT, EnemyArea:get_people_count());
    ai_setv(_p, USER_DEF3_HAS_SHAMAN, EnemyArea:has_shaman());
    ai_setv(_p, USER_DEF3_FIRST_OWNER, EnemyArea:get_first_enemy_owner());
  end
end

local function _AI1_CHECK_OUR_FRONT(_p, _sturn)
  EnemyArea:clear();
  ai_setv(_p, USER_OUR_FRONT_STATUS, 0);
  ai_setv(_p, USER_DEF2_ENEMY_COUNT, 0);
  ai_setv(_p, USER_DEF2_HAS_SHAMAN, 0);
  ai_setv(_p, USER_DEF2_FIRST_OWNER, 0);
  
  EnemyArea:scan(_p, 162, 100, 7);
  
  if (EnemyArea:has_enemy()) then
    ai_setv(_p, USER_OUR_FRONT_STATUS, 1);
    ai_setv(_p, USER_DEF2_ENEMY_COUNT, EnemyArea:get_people_count());
    ai_setv(_p, USER_DEF2_HAS_SHAMAN, EnemyArea:has_shaman());
    ai_setv(_p, USER_DEF2_FIRST_OWNER, EnemyArea:get_first_enemy_owner());
  end
end

local function _AI1_CHECK_OUR_BASE(_p, _sturn)
  EnemyArea:clear();
  ai_setv(_p, USER_BASE_STATUS, 0);
  ai_setv(_p, USER_DEF1_ENEMY_COUNT, 0);
  ai_setv(_p, USER_DEF1_HAS_SHAMAN, 0);
  ai_setv(_p, USER_DEF1_FIRST_OWNER, 0);
  
  EnemyArea:scan(_p, 142, 70, 10);
  
  if (EnemyArea:has_enemy()) then
    ai_setv(_p, USER_BASE_STATUS, 1);
    ai_setv(_p, USER_DEF1_ENEMY_COUNT, EnemyArea:get_people_count());
    ai_setv(_p, USER_DEF1_HAS_SHAMAN, EnemyArea:has_shaman());
    ai_setv(_p, USER_DEF1_FIRST_OWNER, EnemyArea:get_first_enemy_owner());
  end
end

local function _AI1_TRY_DEFEND_BASE_OR_FRONT(_p, _sturn)
  local front_status = ai_getv(_p, USER_OUR_FRONT_STATUS);
  local base_status = ai_getv(_p, USER_BASE_STATUS);
  
  -- check if base has some enemies 
  
  if (base_status == 1) then
    local target_enemy = ai_getv(_p, USER_DEF1_FIRST_OWNER);
    
    if (target_enemy ~= -1) then
      -- base under attack presumebly, try sending shaman with spells and troops
      local any_troops = count_troops(_p);
      local troop_atk = ai_getv(_p, USER_TROOPS_DEFEND);
      local sham_atk = ai_getv(_p, USER_SHAMAN_DEFEND);
      local enemy_shaman = ai_getv(_p, USER_DEF1_HAS_SHAMAN);
      
      if (troop_atk > 50) then
        if (any_troops > 0) then
          ai_set_shaman_away(_p, false);
          ai_set_aways(_p, 0, 50, 0, 50, 0);
          ai_set_attack_flags(_p, 3, 1, 1);
          ai_set_atk_var(_p, USER_TROOPS_DEFEND);
          ai_do_attack(_p, target_enemy, any_troops, ATTACK_MARKER, 2, 999999, M_SPELL_NONE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, -1, -1, 0);
          ai_set_aways(_p, 0, 0, 0, 0, 0);
        end
      else
        -- check whats going on
        if (troop_atk >= 1 and troop_atk < 7) then
          -- reset variable to check it again
          ai_setv(_p, USER_TROOPS_DEFEND, 52);
        end
        
        if (troop_atk == 7) then
          -- navigation failed... try vehicles?
          ai_setv(_p, USER_TROOPS_DEFEND, 52);
        end
      end
      
      if (sham_atk > 50) then
        if (enemy_shaman > 0) then
          if (ai_shaman_available(_p)) then
            computer_reset_limits_for_spell(G_PLR[_p], M_SPELL_LIGHTNING_BOLT);
            give_player_mana(_p, SPELL_COST(M_SPELL_LIGHTNING_BOLT) * 4);
            ai_set_shaman_away(_p, true);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_attack_flags(_p, 3, 1, 1);
            ai_set_atk_var(_p, USER_SHAMAN_DEFEND);
            ai_do_attack(_p, target_enemy, 0, ATTACK_PERSON, M_PERSON_MEDICINE_MAN, 999999, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, M_SPELL_LIGHTNING_BOLT, ATTACK_NORMAL, 0, -1, -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_shaman_away(_p, false);
          end
        end
      else
        -- check whats going on
        if (sham_atk >= 1 and sham_atk < 7) then
          -- reset variable to check it again
          ai_setv(_p, USER_SHAMAN_DEFEND, 52);
        end
        
        if (sham_atk == 7) then
          -- navigation failed... try vehicles?
          ai_setv(_p, USER_SHAMAN_DEFEND, 52);
        end
      end
    end
  end
end

local function _AI1_TOWERS_EXPANSION(_p, _sturn)
  if (_sturn > 3600) then
    local my_braves = num_braves(_p);
    
    if (my_braves >= 10) then
      if (not is_shape_or_bldg_at_xz(_p, M_BUILDING_DRUM_TOWER, 184, 108, 2)) then
        ai_build_tower(_p, 184, 108);
        ai_setv(_p, USER_TOWER_BUILT, 0);
      else
        ai_setv(_p, USER_TOWER_BUILT, 1);
      end
    end
  end
end

local function _AI1_MARKER_ENTRIES_EASY(_p, _sturn)
  if (_sturn > 7200) then
    local any_troops = count_troops(_p);
    
    if (any_troops > 3) then
      if (ai_getv(_p, USER_TOWER_BUILT)) then
        ai_do_marker_entries(_p, 0, 1, 2, -1);
      else
        ai_do_marker_entries(_p, 2, -1, -1, -1);
      end
    end
  end
end

local function _AI1_MARKER_ENTRIES_M_H(_p, _sturn)
  if (_sturn > 3600) then
    if (ai_getv(_p, USER_BASE_STATUS) == 0) then
      ai_do_marker_entries(_p, 3, 4, 5, -1);
    end
    
    if (ai_getv(_p, USER_OUR_FRONT_STATUS) == 0) then
      ai_do_marker_entries(_p, 0, 2, -1, -1);
    end
    
    if (ai_getv(_p, USER_FAR_FRONT_STATUS) == 0) then
      ai_do_marker_entries(_p, 1, -1, -1, -1);
    end
  end
end

local function _AI1_MANAGE_AMOUNT_OF_TROOPS_M_H(_p, _sturn)
  local num_small_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE);
  local num_medium_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_2);
  local num_large_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_3);
  
  if (num_small_huts > (num_medium_huts + num_large_huts)) then
    -- too many small huts, do not train too much
    ai_attr_w(_p, ATTR_MAX_TRAIN_AT_ONCE, 3);
    ai_attr_w(_p, ATTR_PREF_WARRIOR_PEOPLE, (num_small_huts >> 1) + ((num_large_huts + num_medium_huts)));
    ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, (num_small_huts >> 1) + (num_large_huts + num_medium_huts));
  else
    -- have more upgraded huts than small ones
    ai_attr_w(_p, ATTR_MAX_TRAIN_AT_ONCE, 4);
    ai_attr_w(_p, ATTR_PREF_WARRIOR_PEOPLE, MIN((num_large_huts << 1) + (num_medium_huts + num_small_huts), 30));
    ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, MIN((num_large_huts << 1) + (num_medium_huts + num_small_huts), 35));
  end
  
  if (_sturn > 3600) then
    if ((num_large_huts + num_medium_huts) > num_small_huts) then
      -- see if can build more war trainings
      ai_attr_w(_p, ATTR_PREF_WARRIOR_TRAINS, 2);
    else
      ai_attr_w(_p, ATTR_PREF_WARRIOR_TRAINS, 1);
    end
  end
end

local function _AI1_TOWER_SPAM_FRONT_M_H(_p, _sturn)
  if (ai_getv(_p, USER_OUR_FRONT_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 12) then
      local num_towers = MIN(FLOOR(_sturn / 1440) * 2, (PLR1_NUM_DEFENCE_TOWERS >> 1));
      local curr_towers = count_towers(_p, true);
      
      
      if (curr_towers < num_towers) then
        MP_POS.XZ.X = 162 - 18 + G_RANDOM(36);
        MP_POS.XZ.Z = 100 - 18 + G_RANDOM(36);
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI1_TOWER_SPAM_BASE_M_H(_p, _sturn)
  if (ai_getv(_p, USER_BASE_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 14) then
      local num_towers = MIN(FLOOR(_sturn / 2160) * 2, PLR1_NUM_DEFENCE_TOWERS);
      local curr_towers = count_towers(_p, true);
      
      
      if (curr_towers < num_towers) then
        MP_POS.XZ.X = 142 - 20 + G_RANDOM(40);
        MP_POS.XZ.Z = 70 - 20 + G_RANDOM(40);
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI1_TOWER_SPAM_FRONT_EXTREME(_p, _sturn)
  if (ai_getv(_p, USER_OUR_FRONT_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 12) then
      local num_towers = MIN(FLOOR(_sturn / 360) * 2, (PLR1_NUM_DEFENCE_TOWERS >> 1));
      local curr_towers = count_towers(_p, true);
      
      
      if (curr_towers < num_towers) then
        MP_POS.XZ.X = 162 - 18 + G_RANDOM(36);
        MP_POS.XZ.Z = 100 - 18 + G_RANDOM(36);
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI1_TOWER_SPAM_BASE_EXTREME(_p, _sturn)
  if (ai_getv(_p, USER_BASE_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 10) then
      local num_towers = MIN(FLOOR(_sturn / 720) * 2, PLR1_NUM_DEFENCE_TOWERS);
      local curr_towers = count_towers(_p, true);
      
      
      if (curr_towers < num_towers) then
        MP_POS.XZ.X = 142 - 20 + G_RANDOM(40);
        MP_POS.XZ.Z = 70 - 20 + G_RANDOM(40);
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI1_FAR_FRONT_TOWER_EXPANSION(_p, _sturn)
  if (ai_getv(_p, USER_FAR_FRONT_STATUS) == 0) then
    local tower_built = is_shape_or_bldg_at_xz(_p, M_BUILDING_DRUM_TOWER, 210, 110, 6);
    
    if (tower_built) then
      ai_setv(_p, USER_TOWER_BUILT, 1);
      
      if (_sturn > 7200) then
        local num_towers = count_towers(_p, true);
        
        if (num_towers < 69) then
          MP_POS.XZ.X = 210 - 24 + G_RANDOM(48);
          MP_POS.XZ.Z = 110 - 24 + G_RANDOM(48);
          
          ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
        end
      end
    else
      ai_build_tower(_p, 210, 110);
      ai_setv(_p, USER_TOWER_BUILT, 0);
    end
  end
end

local function _AI1_SPAM_HUTS_EVERYWHERE(_p, _sturn)
  local num_huts = count_huts(_p);
  
  if (num_huts > 14 and num_huts < 69) then
    local num_bldgs = PLR1_BLDG_LIST:count();
    local index = G_RANDOM(num_bldgs);
    local my_bldg = PLR1_BLDG_LIST:getNth(index);
    
    if (my_bldg ~= nil) then
      MP_POS.Pos = world_coord3d_to_map_idx(my_bldg.Pos.D3);
      computer_build_at_xz(G_PLR[_p], MP_POS.XZ.X, MP_POS.XZ.Z, M_BUILDING_TEPEE);
    end
  end
end

local function _AI1_ANNOYING_ATTACKS(_p, _sturn)
  if (_sturn > 720) then
    local my_wars = MIN(count_troops(_p), #PLR1_ANNOYANCE_GROUPS * 3);
    for i,var_index in ipairs(PLR1_ANNOYANCE_GROUPS) do
      local attack_status = ai_getv(_p, var_index);
      
      if (attack_status > 50) then
        local target_enemy = get_random_alive_human_player();
        
        if (target_enemy ~= nil) then
          if (my_wars > 2) then
            ai_set_shaman_away(_p, false);
            ai_set_aways(_p, 0, 80, 0, 50, 0);
            ai_set_attack_flags(_p, 0, 1, 1);
            ai_set_atk_var(_p, var_index);
            ai_do_attack(_p, target_enemy, 1 + G_RANDOM(3), ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 999, M_SPELL_NONE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, WAY_POINT_EASY_MKS[G_RANDOM(#WAY_POINT_EASY_MKS) + 1], -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            break;
          end
        end
      else
        -- check whats going on
        my_wars = my_wars - 3;
        if (attack_status >= 1 and attack_status < 7) then
          -- reset variable to check it again
          ai_setv(_p, var_index, 52);
        end
        
        if (attack_status == 7) then
          -- navigation failed... try vehicles?
          ai_setv(_p, var_index, 52);
        end
      end
    end
  end
end

local function _AI1_SHAMAN_ATTACK_EXTREME(_p, _sturn)
  if (_sturn > 360) then
    local target_enemy = get_random_alive_human_player();
    
    if (target_enemy ~= -1) then
      local shaman_result = ai_getv(_p, USER_SHAMAN_ATTACK);
      
      if (shaman_result > 50) then
        if (ai_shaman_available(_p)) then
          local can_cast_tornado = PLR1_SH:can_cast_offensive_spell(1);
          
          if (can_cast_tornado) then
            ai_set_shaman_away(_p, true);
            ai_set_aways(_p, 0, 100, 0, 100, 0);
            ai_set_attack_flags(_p, 0, 1, 1);
            ai_set_atk_var(_p, USER_SHAMAN_ATTACK);
            ai_do_attack(_p, target_enemy, 0, ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 9999, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, ATTACK_NORMAL, 0, WAY_POINT_EASY_MKS[G_RANDOM(#WAY_POINT_EASY_MKS) + 1], -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_shaman_away(_p, false);
            PLR1_SH:set_offensive_mode();
          end
        end
      else
        if (shaman_result >= 1 and shaman_result < 7) then
          -- reset variable to check it again
          ai_setv(_p, USER_SHAMAN_ATTACK, 52);
          PLR1_SH:set_no_casting();
        end
        
        if (shaman_result == 7) then
          -- navigation failed... try vehicles?
          ai_setv(_p, USER_SHAMAN_ATTACK, 52);
          PLR1_SH:set_no_casting();
        end
      end
    end
  end
end

local function _AI1_MAJOR_TROOPS_ATTACK(_p, _sturn)
  if (_sturn > 1440) then
    local target_enemy = get_random_alive_human_player();
    
    if (target_enemy ~= -1) then
      local my_wars = count_people_of_type(_p, M_PERSON_WARRIOR);
      local my_fws = count_people_of_type(_p, M_PERSON_SUPER_WARRIOR);
      local have_enough = (my_wars + my_fws > 10);
      
      local enemy_troops = count_troops(target_enemy);
      
      local troop_result = ai_getv(_p, USER_MAJOR_TROOP_ATTACK);
      local shaman_result = ai_getv(_p, USER_SHAMAN_ATTACK);
      
      if (have_enough) then
        if (troop_result > 50) then
          -- can attack
          ai_set_shaman_away(_p, false);
          ai_set_aways(_p, 0, 100, 0, 100, 0);
          ai_set_attack_flags(_p, 0, 0, 1);
          ai_set_atk_var(_p, USER_MAJOR_TROOP_ATTACK);
          ai_do_attack(_p, target_enemy, MIN((my_wars + my_fws), 50), ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 9999, M_SPELL_NONE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, WAY_POINT_EASY_MKS[G_RANDOM(#WAY_POINT_EASY_MKS) + 1], -1, 0);
          ai_set_aways(_p, 0, 0, 0, 0, 0);
        else
          if (troop_result >= 1 and troop_result < 7) then
            -- reset variable to check it again
            ai_setv(_p, USER_MAJOR_TROOP_ATTACK, 52);
          end
          
          if (troop_result == 7) then
            -- navigation failed... try vehicles?
            ai_setv(_p, USER_MAJOR_TROOP_ATTACK, 52);
          end
        end
      end
      
      if ((my_wars + my_fws) < enemy_troops or (not have_enough)) then
        -- send in shaman if shes available.
        if (shaman_result > 50) then
          if (ai_shaman_available(_p)) then
            ai_set_shaman_away(_p, true);
            ai_set_aways(_p, 0, 100, 0, 100, 0);
            ai_set_attack_flags(_p, 0, 1, 1);
            ai_set_atk_var(_p, USER_SHAMAN_ATTACK);
            ai_do_attack(_p, target_enemy, 0, ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 9999, M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, ATTACK_NORMAL, 0, WAY_POINT_EASY_MKS[G_RANDOM(#WAY_POINT_EASY_MKS) + 1], -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_shaman_away(_p, false);
            PLR1_SH:set_offensive_mode();
          end
        else
          if (shaman_result >= 1 and shaman_result < 7) then
            -- reset variable to check it again
            ai_setv(_p, USER_SHAMAN_ATTACK, 52);
            PLR1_SH:set_no_casting();
          end
          
          if (shaman_result == 7) then
            -- navigation failed... try vehicles?
            ai_setv(_p, USER_SHAMAN_ATTACK, 52);
            PLR1_SH:set_no_casting();
          end
        end
      end
    end
  end
end

local function _AI2_ANNOYING_ATTACKS(_p, _sturn)
  if (_sturn > 1120) then
    local my_troops = MIN(count_troops(_p), #PLR2_ANNOYANCE_GROUPS * 3);
    for i,var_index in ipairs(PLR2_ANNOYANCE_GROUPS) do
      local attack_status = ai_getv(_p, var_index);
      
      if (attack_status > 50) then
        local target_enemy = get_random_alive_human_player();
        
        if (target_enemy ~= nil) then
          if (my_troops > 1) then
            ai_set_shaman_away(_p, false);
            ai_set_aways(_p, 0, 20, 0, 100, 0);
            ai_set_attack_flags(_p, 0, 1, 1);
            ai_set_atk_var(_p, var_index);
            ai_do_attack(_p, target_enemy, 1 + G_RANDOM(3), ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 999, M_SPELL_NONE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, PLR2_WAY_POINT_EASY_MKS[G_RANDOM(#PLR2_WAY_POINT_EASY_MKS) + 1], -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            break;
          end
        end
      else
        -- check whats going on
        my_troops = my_troops - 3;
        if (attack_status >= 1 and attack_status < 7) then
          -- reset variable to check it again
          ai_setv(_p, var_index, 52);
        end
        
        if (attack_status == 7) then
          -- navigation failed... try vehicles?
          ai_setv(_p, var_index, 52);
        end
      end
    end
  end
end

local function _AI2_SHAMAN_ATTACK_EXTREME(_p, _sturn)
  if (_sturn > 1440) then
    local target_enemy = get_random_alive_human_player();
    
    if (target_enemy ~= -1) then
      local shaman_result = ai_getv(_p, USER_SHAMAN_ATTACK);
      
      if (shaman_result > 50) then
        if (ai_shaman_available(_p)) then
          local can_cast_tornado = PLR1_SH:can_cast_offensive_spell(1);
          
          if (can_cast_tornado) then
            ai_set_shaman_away(_p, true);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_attack_flags(_p, 0, 1, 1);
            ai_set_atk_var(_p, USER_SHAMAN_ATTACK);
            ai_do_attack(_p, target_enemy, 0, ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 9999, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, ATTACK_NORMAL, 0, PLR2_WAY_POINT_EASY_MKS[G_RANDOM(#PLR2_WAY_POINT_EASY_MKS) + 1], -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_shaman_away(_p, false);
            PLR2_SH:set_offensive_mode();
          end
        end
      else
        if (shaman_result >= 1 and shaman_result < 7) then
          -- reset variable to check it again
          ai_setv(_p, USER_SHAMAN_ATTACK, 52);
          PLR2_SH:set_no_casting();
        end
        
        if (shaman_result == 7) then
          -- navigation failed... try vehicles?
          ai_setv(_p, USER_SHAMAN_ATTACK, 52);
          PLR2_SH:set_no_casting();
        end
      end
    end
  end
end

local function _AI2_MAJOR_TROOPS_ATTACK(_p, _sturn)
  if (_sturn > 1120) then
    local target_enemy = get_random_alive_human_player();
    
    if (target_enemy ~= -1) then
      local my_wars = count_people_of_type(_p, M_PERSON_WARRIOR);
      local my_fws = count_people_of_type(_p, M_PERSON_SUPER_WARRIOR);
      local have_enough = (my_wars + my_fws > 10);
      
      local enemy_troops = count_troops(target_enemy);
      
      local troop_result = ai_getv(_p, USER_MAJOR_TROOP_ATTACK);
      local shaman_result = ai_getv(_p, USER_SHAMAN_ATTACK);
      
      if (have_enough) then
        if (troop_result > 50) then
          -- can attack
          ai_set_shaman_away(_p, false);
          ai_set_aways(_p, 10, 100, 0, 30, 0);
          ai_set_attack_flags(_p, 0, 0, 1);
          ai_set_atk_var(_p, USER_MAJOR_TROOP_ATTACK);
          ai_do_attack(_p, target_enemy, MIN((my_wars + my_fws), 40), ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 9999, M_SPELL_NONE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, PLR2_WAY_POINT_EASY_MKS[G_RANDOM(#PLR2_WAY_POINT_EASY_MKS) + 1], -1, 0);
          ai_set_aways(_p, 0, 0, 0, 0, 0);
        else
          if (troop_result >= 1 and troop_result < 7) then
            -- reset variable to check it again
            ai_setv(_p, USER_MAJOR_TROOP_ATTACK, 52);
          end
          
          if (troop_result == 7) then
            -- navigation failed... try vehicles?
            ai_setv(_p, USER_MAJOR_TROOP_ATTACK, 52);
          end
        end
      end
      
      if ((my_wars + my_fws) < enemy_troops or (not have_enough)) then
        -- send in shaman if shes available.
        if (shaman_result > 50) then
          if (ai_shaman_available(_p)) then
            ai_set_shaman_away(_p, true);
            ai_set_aways(_p, 0, 100, 0, 100, 0);
            ai_set_attack_flags(_p, 0, 1, 1);
            ai_set_atk_var(_p, USER_SHAMAN_ATTACK);
            ai_do_attack(_p, target_enemy, 0, ATTACK_BUILDING, INT_NO_SPECIFIC_BUILDING, 9999, M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, ATTACK_NORMAL, 0, PLR2_WAY_POINT_EASY_MKS[G_RANDOM(#PLR2_WAY_POINT_EASY_MKS) + 1], -1, 0);
            ai_set_aways(_p, 0, 0, 0, 0, 0);
            ai_set_shaman_away(_p, false);
            PLR2_SH:set_offensive_mode();
          end
        else
          if (shaman_result >= 1 and shaman_result < 7) then
            -- reset variable to check it again
            ai_setv(_p, USER_SHAMAN_ATTACK, 52);
            PLR2_SH:set_no_casting();
          end
          
          if (shaman_result == 7) then
            -- navigation failed... try vehicles?
            ai_setv(_p, USER_SHAMAN_ATTACK, 52);
            PLR2_SH:set_no_casting();
          end
        end
      end
    end
  end
end

local function _AI2_CHECK_OUR_SECOND_FRONT(_p, _sturn)
  EnemyArea:clear();
  ai_setv(_p, USER_FAR_FRONT_STATUS, 0);
  ai_setv(_p, USER_DEF3_ENEMY_COUNT, 0);
  ai_setv(_p, USER_DEF3_HAS_SHAMAN, 0);
  ai_setv(_p, USER_DEF3_FIRST_OWNER, 0);
  
  EnemyArea:scan(_p, 14, 138, 7);
  
  if (EnemyArea:has_enemy()) then
    ai_setv(_p, USER_FAR_FRONT_STATUS, 1);
    ai_setv(_p, USER_DEF3_ENEMY_COUNT, EnemyArea:get_people_count());
    ai_setv(_p, USER_DEF3_HAS_SHAMAN, EnemyArea:has_shaman());
    ai_setv(_p, USER_DEF3_FIRST_OWNER, EnemyArea:get_first_enemy_owner());
  end
end

local function _AI2_CHECK_OUR_FIRST_FRONT(_p, _sturn)
  EnemyArea:clear();
  ai_setv(_p, USER_OUR_FRONT_STATUS, 0);
  ai_setv(_p, USER_DEF2_ENEMY_COUNT, 0);
  ai_setv(_p, USER_DEF2_HAS_SHAMAN, 0);
  ai_setv(_p, USER_DEF2_FIRST_OWNER, 0);
  
  EnemyArea:scan(_p, 242, 104, 7);
  
  if (EnemyArea:has_enemy()) then
    ai_setv(_p, USER_OUR_FRONT_STATUS, 1);
    ai_setv(_p, USER_DEF2_ENEMY_COUNT, EnemyArea:get_people_count());
    ai_setv(_p, USER_DEF2_HAS_SHAMAN, EnemyArea:has_shaman());
    ai_setv(_p, USER_DEF2_FIRST_OWNER, EnemyArea:get_first_enemy_owner());
  end
end

local function _AI2_CHECK_OUR_BASE(_p, _sturn)
  EnemyArea:clear();
  ai_setv(_p, USER_BASE_STATUS, 0);
  ai_setv(_p, USER_DEF1_ENEMY_COUNT, 0);
  ai_setv(_p, USER_DEF1_HAS_SHAMAN, 0);
  ai_setv(_p, USER_DEF1_FIRST_OWNER, 0);
  
  EnemyArea:scan(_p, 36, 88, 10);
  
  if (EnemyArea:has_enemy()) then
    ai_setv(_p, USER_BASE_STATUS, 1);
    ai_setv(_p, USER_DEF1_ENEMY_COUNT, EnemyArea:get_people_count());
    ai_setv(_p, USER_DEF1_HAS_SHAMAN, EnemyArea:has_shaman());
    ai_setv(_p, USER_DEF1_FIRST_OWNER, EnemyArea:get_first_enemy_owner());
  end
end

local function _AI2_TOWER_SPAM_RANDOM_FRONT_M_H(_p, _sturn)
  if (ai_getv(_p, USER_OUR_FRONT_STATUS) == 0 and ai_getv(_p, USER_FAR_FRONT_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 12) then
      local num_towers = MIN(FLOOR(_sturn / 1440) * 2, (PLR2_NUM_DEFENCE_TOWERS >> 1));
      local curr_towers = count_towers(_p, true);
      
      if (curr_towers < num_towers) then
        if (G_RANDOM(2) == 1) then
          MP_POS.XZ.X = 242 - 18 + G_RANDOM(36);
          MP_POS.XZ.Z = 104 - 18 + G_RANDOM(36);
        else
          MP_POS.XZ.X = 14 - 18 + G_RANDOM(36);
          MP_POS.XZ.Z = 138 - 18 + G_RANDOM(36);
        end
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI2_TOWER_SPAM_BASE_M_H(_p, _sturn)
  if (ai_getv(_p, USER_BASE_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 14) then
      local num_towers = MIN(FLOOR(_sturn / 2160) * 2, PLR2_NUM_DEFENCE_TOWERS);
      local curr_towers = count_towers(_p, true);
      
      
      if (curr_towers < num_towers) then
        MP_POS.XZ.X = 36 - 24 + G_RANDOM(48);
        MP_POS.XZ.Z = 88 - 24 + G_RANDOM(48);
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI2_TOWER_SPAM_RANDOM_FRONT_EXTREME(_p, _sturn)
  if (ai_getv(_p, USER_OUR_FRONT_STATUS) == 0 and ai_getv(_p, USER_FAR_FRONT_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 12) then
      local num_towers = MIN(FLOOR(_sturn / 360) * 2, (PLR2_NUM_DEFENCE_TOWERS >> 1));
      local curr_towers = count_towers(_p, true);
      
      if (curr_towers < num_towers) then
        if (G_RANDOM(2) == 1) then
          MP_POS.XZ.X = 242 - 18 + G_RANDOM(36);
          MP_POS.XZ.Z = 104 - 18 + G_RANDOM(36);
        else
          MP_POS.XZ.X = 14 - 18 + G_RANDOM(36);
          MP_POS.XZ.Z = 138 - 18 + G_RANDOM(36);
        end
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI2_TOWER_SPAM_BASE_EXTREME(_p, _sturn)
  if (ai_getv(_p, USER_BASE_STATUS) == 0) then
    local num_huts = count_huts(_p, false);
    
    if (num_huts >= 14) then
      local num_towers = MIN(FLOOR(_sturn / 720) * 2, PLR2_NUM_DEFENCE_TOWERS);
      local curr_towers = count_towers(_p, true);
      
      
      if (curr_towers < num_towers) then
        MP_POS.XZ.X = 36 - 24 + G_RANDOM(48);
        MP_POS.XZ.Z = 88 - 24 + G_RANDOM(48);
        
        ai_build_tower(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
      end
    end
  end
end

local function _AI2_MANAGE_AMOUNT_OF_TROOPS_M_H(_p, _sturn)
  local num_small_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE);
  local num_medium_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_2);
  local num_large_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_3);
  
  if (num_small_huts > (num_medium_huts + num_large_huts)) then
    -- too many small huts, do not train too much
    ai_attr_w(_p, ATTR_MAX_TRAIN_AT_ONCE, 3);
    ai_attr_w(_p, ATTR_PREF_WARRIOR_PEOPLE, (num_small_huts >> 1) + ((num_large_huts + num_medium_huts)));
    ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, (num_small_huts >> 1) + (num_large_huts + num_medium_huts));
  else
    -- have more upgraded huts than small ones
    ai_attr_w(_p, ATTR_MAX_TRAIN_AT_ONCE, 4);
    ai_attr_w(_p, ATTR_PREF_WARRIOR_PEOPLE, MIN((num_large_huts << 1) + (num_medium_huts + num_small_huts), 40));
    ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, MIN((num_large_huts << 1) + (num_medium_huts + num_small_huts), 30));
  end
  
  if (_sturn > 3600) then
    if ((num_large_huts + num_medium_huts) > num_small_huts) then
      -- see if can build more war trainings
      ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_TRAINS, 2);
    else
      ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
    end
  end
end

local function _AI2_MARKER_ENTRIES_MEDIUM(_p, _sturn)
  if (_sturn > 3600) then
    if (ai_getv(_p, USER_OUR_FRONT_STATUS) == 0) then
      ai_do_marker_entries(_p, 0, 1, -1, -1);
    end
    
    if (ai_getv(_p, USER_FAR_FRONT_STATUS) == 0) then
      ai_do_marker_entries(_p, 2, 3, -1, -1);
    end
  end
end

local function _AI2_MARKER_ENTRIES_H_EX(_p, _sturn)
  if (_sturn > 1800) then
    if (ai_getv(_p, USER_OUR_FRONT_STATUS) == 0) then
      ai_do_marker_entries(_p, 0, 1, 6, -1);
      ai_do_marker_entries(_p, 7, -1, -1, -1);
    end
    
    if (ai_getv(_p, USER_FAR_FRONT_STATUS) == 0) then
      ai_do_marker_entries(_p, 2, 3, 4, -1);
      ai_do_marker_entries(_p, 5, -1, -1, -1);
    end
  end
end

local _EVENT_INDEX = 1;
local _EVENT_TABLE =
{
  {
    [AI_EASY] =
    {
      {_AI_CHECK_BUCKETS_EASY, 256, 64},
      {_AI1_CHECK_CONVERT_EASY, 128, 32},
      {_AI1_BASIC_ATTACK_EASY, 3072, 512},
      {_AI1_TOWERS_EXPANSION, 512, 256},
      {_AI1_MARKER_ENTRIES_EASY, 256, 128},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI1_CHECK_CONVERT_M_H, 128, 32},
      {_AI1_TOWER_SPAM_FRONT_M_H, 384, 64},
      {_AI1_TOWER_SPAM_BASE_M_H, 512, 128},
      {_AI1_CHECK_FAR_FRONT, 256, 128},
      {_AI1_CHECK_OUR_FRONT, 256, 96},
      {_AI1_CHECK_OUR_BASE, 256, 64},
      {_AI1_TRY_DEFEND_BASE_OR_FRONT, 196, 128},
      {_AI1_MARKER_ENTRIES_M_H, 384, 64},
      {_AI1_MANAGE_AMOUNT_OF_TROOPS_M_H, 512, 128},
      {_AI1_MAJOR_TROOPS_ATTACK, 1024, 768},
    },
    
    [AI_HARD] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI1_CHECK_CONVERT_M_H, 128, 32},
      {_AI1_TOWER_SPAM_FRONT_M_H, 384, 32},
      {_AI1_TOWER_SPAM_BASE_M_H, 512, 32},
      {_AI1_CHECK_FAR_FRONT, 256, 128},
      {_AI1_CHECK_OUR_FRONT, 256, 96},
      {_AI1_CHECK_OUR_BASE, 256, 64},
      {_AI1_TRY_DEFEND_BASE_OR_FRONT, 196, 64},
      {_AI1_MARKER_ENTRIES_M_H, 288, 64},
      {_AI1_MANAGE_AMOUNT_OF_TROOPS_M_H, 384, 128},
      {_AI1_MAJOR_TROOPS_ATTACK, 1024, 512},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CHECK_BUCKETS_EXTREME, 256, 64},
      {_AI1_CHECK_CONVERT_EXTREME, 96, 24},
      {_AI1_CHECK_FAR_FRONT, 192, 128},
      {_AI1_CHECK_OUR_FRONT, 192, 96},
      {_AI1_CHECK_OUR_BASE, 192, 64},
      {_AI1_TRY_DEFEND_BASE_OR_FRONT, 128, 32},
      {_AI1_TOWER_SPAM_FRONT_EXTREME, 256, 32},
      {_AI1_TOWER_SPAM_BASE_EXTREME, 384, 64},
      {_AI1_SPAM_HUTS_EVERYWHERE, 64, 32},
      {_AI1_MANAGE_AMOUNT_OF_TROOPS_M_H, 384, 64},
      {_AI1_ANNOYING_ATTACKS, 192, 96},
      {_AI1_FAR_FRONT_TOWER_EXPANSION, 412, 64},
      {_AI1_MAJOR_TROOPS_ATTACK, 1536, 768},
      {_AI1_SHAMAN_ATTACK_EXTREME, 2048, 1024},
      {_AI1_MARKER_ENTRIES_M_H, 288, 32},
    },
  },
  {
    [AI_EASY] =
    {
      {_AI_CHECK_BUCKETS_EASY, 256, 64},
      {_AI2_CHECK_CONVERT_EASY, 128, 32},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI2_CHECK_CONVERT_M_H, 128, 32},
      {_AI2_CHECK_OUR_SECOND_FRONT, 256, 64},
      {_AI2_CHECK_OUR_FIRST_FRONT, 256, 64},
      {_AI2_CHECK_OUR_BASE, 256, 64},
      {_AI2_TOWER_SPAM_RANDOM_FRONT_M_H, 384, 64},
      {_AI2_TOWER_SPAM_BASE_M_H, 512, 128},
      {_AI2_MANAGE_AMOUNT_OF_TROOPS_M_H, 512, 128},
      {_AI2_MARKER_ENTRIES_MEDIUM, 384, 64},
    },
    
    [AI_HARD] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI2_CHECK_CONVERT_M_H, 128, 32},
      {_AI2_CHECK_OUR_SECOND_FRONT, 192, 64},
      {_AI2_CHECK_OUR_FIRST_FRONT, 192, 64},
      {_AI2_CHECK_OUR_BASE, 192, 64},
      {_AI2_TOWER_SPAM_RANDOM_FRONT_M_H, 384, 32},
      {_AI2_TOWER_SPAM_BASE_M_H, 512, 32},
      {_AI2_MANAGE_AMOUNT_OF_TROOPS_M_H, 384, 128},
      {_AI2_MARKER_ENTRIES_H_EX, 288, 64},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CHECK_BUCKETS_EXTREME, 256, 64},
      {_AI2_CHECK_CONVERT_EXTREME, 96, 24},
      {_AI2_CHECK_OUR_SECOND_FRONT, 192, 64},
      {_AI2_CHECK_OUR_FIRST_FRONT, 192, 64},
      {_AI2_CHECK_OUR_BASE, 192, 64},
      {_AI2_MAJOR_TROOPS_ATTACK, 1536, 768},
      {_AI2_SHAMAN_ATTACK_EXTREME, 2048, 1024},
      {_AI2_ANNOYING_ATTACKS, 192, 96},
      {_AI2_TOWER_SPAM_RANDOM_FRONT_EXTREME, 256, 32},
      {_AI2_TOWER_SPAM_BASE_EXTREME, 384, 32},
      {_AI2_MANAGE_AMOUNT_OF_TROOPS_M_H, 384, 64},
      {_AI2_MARKER_ENTRIES_H_EX, 288, 32},
    },
  }
}

function register_ai_events(player_num, difficulty)
  local t = _EVENT_TABLE[_EVENT_INDEX][difficulty];
  
  for i,event in ipairs(t) do
    TurnClock.new(get_script_turn(), event[1], event[2], player_num, event[3]);
  end
  
  ai_setv(player_num, USER_BASIC_ATTACK, 52);
  ai_setv(player_num, USER_EXTRA_ATTACK, 52);
  ai_setv(player_num, USER_SHAMAN_DEFEND, 52);
  ai_setv(player_num, USER_TROOPS_DEFEND, 52);
  ai_setv(player_num, USER_MAJOR_TROOP_ATTACK, 52);
  ai_setv(player_num, USER_SHAMAN_ATTACK, 52);
  
  if (_EVENT_INDEX == 1) then
    for i,var_index in ipairs(PLR1_ANNOYANCE_GROUPS) do
      ai_setv(player_num, var_index, 52);
    end
    
    --PLR1_SH:set_defensive_spell_entry(1, M_SPELL_SHIELD, 4, 25000);
    --PLR1_SH:set_defensive_spell_entry(2, M_SPELL_BLOODLUST, 4, 15000);
    --PLR1_SH:set_defensive_mode();
    PLR1_NUM_DEFENCE_TOWERS = 12 + (difficulty * 4);
    PLR1_BLDG_LIST = getPlayerContainer(player_num).PlayerLists[BUILDINGLIST];
    
    if (difficulty == AI_EXTREME) then
    end
  else
    for i,var_index in ipairs(PLR2_ANNOYANCE_GROUPS) do
      ai_setv(player_num, var_index, 52);
    end
    
    PLR2_BLDG_LIST = getPlayerContainer(player_num).PlayerLists[BUILDINGLIST];
    PLR2_NUM_DEFENCE_TOWERS = 15 + (difficulty * 5);
  end
  
  _EVENT_INDEX = _EVENT_INDEX + 1;
end

function process_ai_events()
  TurnClock.process_clocks();
  
  process_shaman_ai(get_script_turn());
end