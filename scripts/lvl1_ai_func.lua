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
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 178, 42}
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
    {AI_EXTREME, T_BUILDING, M_BUILDING_DRUM_TOWER, 22, 110}
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
    end
  end
  
  _ADDON_INDEX = _ADDON_INDEX + 1;
end

-- AI DEFINES
local WAY_POINT_EASY_MKS = {39, 40, 41, 42};
local USER_TOWER_BUILT = 1;
local USER_BASIC_ATTACK = 64;

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

local function _AI_CHECK_CONVERT_EASY(_p, _sturn)
  if (count_pop(_p) < 20) then
    ai_set_converting_info(_p, true, true, 16);
  else
    ai_set_converting_info(_p, false, true, 16);
  end
end

local function _AI_CHECK_CONVERT_M_H(_p, _sturn)
  if (count_pop(_p) < 35) then
    ai_set_converting_info(_p, true, true, 24);
  else
    ai_set_converting_info(_p, false, true, 24);
  end
end

local function _AI_CHECK_CONVERT_EXTREME(_p, _sturn)
  if (count_pop(_p) < 40) then
    ai_set_converting_info(_p, true, true, 32);
  else
    ai_set_converting_info(_p, false, true, 32);
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
            ai_set_aways(_p, 100, 0, 0, 0, 0);
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
            ai_set_aways(_p, 100, 0, 0, 0, 0);
          elseif (ai_shaman_available(_p)) then
            -- try sending shaman with some spells
            ai_set_aways(_p, 20, 60, 0, 20, 0);
            ai_set_attack_flags(_p, 3, 0, 1);
            ai_set_shaman_away(_p, true);
            ai_set_atk_var(_p, USER_BASIC_ATTACK);
            ai_do_attack(_p, target_enemy, (any_troops >> 1), ATTACK_MARKER, 43, 150, M_SPELL_HYPNOTISM, M_SPELL_HYPNOTISM, M_SPELL_INSECT_PLAGUE, ATTACK_NORMAL, 0, -1, -1, 0);
            ai_set_aways(_p, 100, 0, 0, 0, 0);
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

local function _AI1_TOWERS_EXPANSION(_p, _sturn)
  if (_sturn > 3600) then
    local my_braves = num_braves(_p);
    
    if (my_braves >= 10) then
      if (not is_shape_or_bldg_at_xz(_p, M_BUILDING_DRUM_TOWER, 184, 108, 2)) then
        BUILD_DRUM_TOWER(_p, 184, 108);
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

local function _AI1_TOWER_SPAM_FRONT_M_H(_p, _sturn)
  local num_huts = count_huts(_p, false);
  
  if (num_huts >= 12) then
    local num_towers = MIN(FLOOR(_sturn / 1440) * 2, 10);
    local curr_towers = count_towers(_p, true);
    
    
    if (curr_towers < num_towers) then
      MP_POS.XZ.X = 162 - 18 + G_RANDOM(36);
      MP_POS.XZ.Z = 100 - 18 + G_RANDOM(36);
      
      BUILD_DRUM_TOWER(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
    end
  end
end

local function _AI1_TOWER_SPAM_BASE_M_H(_p, _sturn)
  local num_huts = count_huts(_p, false);
  
  if (num_huts >= 14) then
    local num_towers = MIN(FLOOR(_sturn / 2160) * 2, 20);
    local curr_towers = count_towers(_p, true);
    
    
    if (curr_towers < num_towers) then
      MP_POS.XZ.X = 142 - 20 + G_RANDOM(40);
      MP_POS.XZ.Z = 70 - 20 + G_RANDOM(40);
      
      BUILD_DRUM_TOWER(_p, MP_POS.XZ.X, MP_POS.XZ.Z);
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
      {_AI_CHECK_CONVERT_EASY, 128, 32},
      {_AI1_BASIC_ATTACK_EASY, 3072, 512},
      {_AI1_TOWERS_EXPANSION, 512, 256},
      {_AI1_MARKER_ENTRIES_EASY, 256, 128},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI_CHECK_CONVERT_M_H, 128, 32},
      {_AI1_TOWER_SPAM_FRONT_M_H, 384, 64},
      {_AI1_TOWER_SPAM_BASE_M_H, 512, 128},
    },
    
    [AI_HARD] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI_CHECK_CONVERT_M_H, 128, 32},
      {_AI1_TOWER_SPAM_FRONT_M_H, 384, 32},
      {_AI1_TOWER_SPAM_BASE_M_H, 512, 32},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CHECK_BUCKETS_EXTREME, 256, 64},
      {_AI_CHECK_CONVERT_EXTREME, 96, 24},
    },
  },
  {
    [AI_EASY] =
    {
      {_AI_CHECK_BUCKETS_EASY, 256, 64},
      {_AI_CHECK_CONVERT_EASY, 128, 32},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI_CHECK_CONVERT_M_H, 128, 32},
    },
    
    [AI_HARD] = 
    {
      {_AI_CHECK_BUCKETS_M_H, 256, 64},
      {_AI_CHECK_CONVERT_M_H, 128, 32},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CHECK_BUCKETS_EXTREME, 256, 64},
      {_AI_CHECK_CONVERT_EXTREME, 96, 24},
    },
  }
}

function register_ai_events(player_num, difficulty)
  local t = _EVENT_TABLE[_EVENT_INDEX][difficulty];
  
  for i,event in ipairs(t) do
    TurnClock.new(get_script_turn(), event[1], event[2], player_num, event[3]);
  end
  
  ai_setv(player_num, USER_BASIC_ATTACK, 52);
  
  _EVENT_INDEX = _EVENT_INDEX + 1;
end

function process_ai_events()
  TurnClock.process_clocks();
end