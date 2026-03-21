include("turnclock.lua");
local EnemyArea = create_enemy_search_area();


local PLAYER_2_IDX =
{

};
local _ADDON_INDEX = 1;
local FLOOR = math.floor;
local ROUND = function(n) return FLOOR(n + 0.5); end;
local MIN = math.min;
local MAX = math.max;
local MP_POS = MapPosXZ.new();

-- Data base for computer's starting things.
-- The way it is designed is index will be incremented by 1 every time you call
-- spawn_computer_addons() function.
local _MAP_ADDONS =
{
  -- player 1
  {
    {AI_MEDIUM, T_PERSON, 12, M_PERSON_BRAVE, 224, 102},
    {AI_HARD, T_PERSON, 6, M_PERSON_WARRIOR, 224, 102},
    {AI_HARD, T_PERSON, 6, M_PERSON_SUPER_WARRIOR, 224, 102},
    {AI_EXTREME, T_PERSON, 12, M_PERSON_BRAVE, 224, 102},
    {AI_EXTREME, T_PERSON, 6, M_PERSON_WARRIOR, 224, 102},
    {AI_EXTREME, T_PERSON, 6, M_PERSON_SUPER_WARRIOR, 224, 102},
  },
  
  -- player 2
  {
    {AI_MEDIUM, T_PERSON, 12, M_PERSON_BRAVE, 226, 202},
    {AI_HARD, T_PERSON, 3, M_PERSON_SPY, 226, 202},
    {AI_HARD, T_PERSON, 9, M_PERSON_SUPER_WARRIOR, 226, 202},
    {AI_EXTREME, T_PERSON, 12, M_PERSON_BRAVE, 226, 202},
    {AI_EXTREME, T_PERSON, 3, M_PERSON_SPY, 226, 202},
    {AI_EXTREME, T_PERSON, 9, M_PERSON_SUPER_WARRIOR, 226, 202},
  },
  
  -- player 3
  {
    {AI_MEDIUM, T_PERSON, 12, M_PERSON_BRAVE, 148, 242},
    {AI_HARD, T_PERSON, 4, M_PERSON_WARRIOR, 148, 242},
    {AI_HARD, T_PERSON, 4, M_PERSON_SUPER_WARRIOR, 148, 242},
    {AI_HARD, T_PERSON, 4, M_PERSON_RELIGIOUS, 148, 242},
    {AI_EXTREME, T_PERSON, 12, M_PERSON_BRAVE, 148, 242},
    {AI_EXTREME, T_PERSON, 4, M_PERSON_WARRIOR, 148, 242},
    {AI_EXTREME, T_PERSON, 4, M_PERSON_SUPER_WARRIOR, 148, 242},
    {AI_EXTREME, T_PERSON, 4, M_PERSON_RELIGIOUS, 148, 242},
  },
  
  -- player 4
  {
    {AI_MEDIUM, T_PERSON, 12, M_PERSON_BRAVE, 244, 250},
    {AI_HARD, T_PERSON, 6, M_PERSON_RELIGIOUS, 244, 250},
    {AI_HARD, T_PERSON, 6, M_PERSON_SUPER_WARRIOR, 244, 250},
    {AI_EXTREME, T_PERSON, 12, M_PERSON_BRAVE, 244, 250},
    {AI_EXTREME, T_PERSON, 6, M_PERSON_RELIGIOUS, 244, 250},
    {AI_EXTREME, T_PERSON, 6, M_PERSON_SUPER_WARRIOR, 244, 250},
  }
}

function spawn_computer_addons(player_num, difficulty)
  local t = _MAP_ADDONS[_ADDON_INDEX];
  local d = difficulty;
  local p = player_num;
  
  for i,item in ipairs(t) do
    if (item ~= nil) then
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
  end
  
  _ADDON_INDEX = _ADDON_INDEX + 1;
end

-- AI DEFINES
-- PLAYER ONE

-- Event vars
local USER_BALLOONS_AVAILABLE = 1;

-- Attack vars
local USER_BASIC_ATTACK = 64;
local USER_SHAMAN_ATTACK = 65;
local USER_MAJOR_ATTACK = 66;
local USER_REINFORCEMENT_ATTACK = 67;
local USER_BALLOON_FWS_ASSAULT = 68;

-- PLAYER TWO

-- PLAYER THREE

-- PLAYER FOUR

-- cache
local PLR1_BLDG_LIST = nil;
local PLR2_BLDG_LIST = nil;
PLR1_SH = nil;
PLR2_SH = nil;

-- user vars

-- AI EVENTS

local function _AI_CALC_BUCKETS_GENERAL(_p, _sturn, difficulty)
  local base_mod = 20 - (4 * difficulty);
  local time_passed_mod = MIN(FLOOR(_sturn / 3600), 5);
  local population_mod = FLOOR(count_pop(_p) / 25);
  local final_mod = MAX(1, (base_mod - (time_passed_mod + population_mod)));
  
  -- tier 1 spells
  ai_set_spell_bucket_count(_p, M_SPELL_BLAST, ROUND(1.0 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_CONVERT_WILD, ROUND(1.0 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_GHOST_ARMY, ROUND(1.15 * final_mod));
  
  -- tier 2 spells
  ai_set_spell_bucket_count(_p, M_SPELL_INSECT_PLAGUE, ROUND(2.10 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_INVISIBILITY, ROUND(2.25 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_SHIELD, ROUND(2.35 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_LAND_BRIDGE, ROUND(2.45 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_LIGHTNING_BOLT, ROUND(2.75 * final_mod));
  
  -- tier 3 spells
  ai_set_spell_bucket_count(_p, M_SPELL_HYPNOTISM, ROUND(3.25 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_WHIRLWIND, ROUND(3.35 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_SWAMP, ROUND(3.55 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_FLATTEN, ROUND(3.85 * final_mod));
  
  -- tier 4 spells
  ai_set_spell_bucket_count(_p, M_SPELL_EARTHQUAKE, ROUND(4.05 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_EROSION, ROUND(4.35 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_FIRESTORM, ROUND(4.90 * final_mod));
  
  -- tier 5 spells
  ai_set_spell_bucket_count(_p, M_SPELL_ANGEL_OF_DEATH, ROUND(5.45 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_VOLCANO, ROUND(5.85 * final_mod));
  
  -- tier 6 spells
  ai_set_spell_bucket_count(_p, M_SPELL_ARMAGEDDON, ROUND(6.0 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_BLOODLUST, ROUND(6.0 * final_mod));
  ai_set_spell_bucket_count(_p, M_SPELL_TELEPORT, ROUND(6.0 * final_mod));
end

local AI_TROOP_HUT_VALUE_TBL =
{
  -- player 1
  {
    [M_PERSON_WARRIOR] = {0.45, 0.65, 0.85},
    [M_PERSON_SUPER_WARRIOR] = {0.55, 0.65, 0.75}
  },
  
  -- player 2
  {
    [M_PERSON_SPY] = {0.05, 0.13, 0.22},
    [M_PERSON_SUPER_WARRIOR] = {0.9, 1, 1.12}
  },
  
  -- player 3
  {
    [M_PERSON_WARRIOR] = {0.25, 0.35, 0.45},
    [M_PERSON_SUPER_WARRIOR] = {0.25, 0.35, 0.45},
    [M_PERSON_RELIGIOUS] = {0.3, 0.4, 0.5}
  },
  
  -- player 4
  {
    [M_PERSON_SUPER_WARRIOR] = {0.55, 0.65, 0.9},
    [M_PERSON_RELIGIOUS] = {0.7, 0.9, 1.1}
  }
}

local function calculate_troop_value(plr_num, p_type, n_small, n_medium, n_large)
    return FLOOR((AI_TROOP_HUT_VALUE_TBL[PLAYER_2_IDX[plr_num]][p_type][M_BUILDING_TEPEE] * n_small) +
    (AI_TROOP_HUT_VALUE_TBL[PLAYER_2_IDX[plr_num]][p_type][M_BUILDING_TEPEE_2] * n_medium) +
    (AI_TROOP_HUT_VALUE_TBL[PLAYER_2_IDX[plr_num]][p_type][M_BUILDING_TEPEE_3] * n_large));
end

local function _AI1_MANAGE_MY_TROOPS_AMOUNTS(_p, _sturn, difficulty)
  local num_small_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE);
  local num_medium_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_2);
  local num_large_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_3);
  
  local m_war_value = calculate_troop_value(_p, M_PERSON_WARRIOR, num_small_huts, num_medium_huts, num_large_huts);
  local m_fw_value = calculate_troop_value(_p, M_PERSON_SUPER_WARRIOR, num_small_huts, num_medium_huts, num_large_huts);
  
  ai_attr_w(_p, ATTR_PREF_WARRIOR_PEOPLE, m_war_value);
  ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, m_fw_value);
end

local function _AI1_SHOULD_I_BUILD_AIRSHIP_HUT(_p, _sturn, difficulty)
  if (difficulty >= AI_HARD) then
    -- Only build balloons on hard and extreme diffs.

    -- First we check if we have firewarrior train built with decent amount of population.
    local num_huts = count_huts(_p, true);
    local fw_bldgs = count_bldgs_of_type(_p, M_BUILDING_SUPER_TRAIN);
    if (num_huts >= 7 and fw_bldgs > 0) then
      -- Commence airship craft.
      ai_set_vehicle_info(_p, true, 0, 0, 1, 0);
      ai_set_state(_p, TRUE, CP_AT_TYPE_FETCH_LOST_VEHICLE);
      ai_set_state(_p, TRUE, CP_AT_TYPE_FETCH_FAR_VEHICLE);
      ai_attr_w(_p, ATTR_PEOPLE_PER_BALLOON, 8);
      ai_setv(_p, USER_BALLOONS_AVAILABLE, 1);
    else
      -- Halt production of flying potatoes.
      ai_set_vehicle_info(_p, false, 0, 0, 0, 0);
      ai_set_state(_p, FALSE, CP_AT_TYPE_FETCH_LOST_VEHICLE);
      ai_set_state(_p, FALSE, CP_AT_TYPE_FETCH_FAR_VEHICLE);
      ai_attr_w(_p, ATTR_PEOPLE_PER_BALLOON, 0);
      ai_setv(_p, USER_BALLOONS_AVAILABLE, 0);
    end
  end
end

local function _AI2_MANAGE_MY_TROOPS_AMOUNTS(_p, _sturn, difficulty)
  local num_small_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE);
  local num_medium_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_2);
  local num_large_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_3);
  
  local m_spy_value = calculate_troop_value(_p, M_PERSON_SPY, num_small_huts, num_medium_huts, num_large_huts);
  local m_fw_value = calculate_troop_value(_p, M_PERSON_SUPER_WARRIOR, num_small_huts, num_medium_huts, num_large_huts);
  
  ai_attr_w(_p, ATTR_PREF_SPY_PEOPLE, m_spy_value);
  ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, m_fw_value);
end

local function _AI3_MANAGE_MY_TROOPS_AMOUNTS(_p, _sturn, difficulty)
  local num_small_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE);
  local num_medium_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_2);
  local num_large_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_3);
  
  local m_priest_value = calculate_troop_value(_p, M_PERSON_RELIGIOUS, num_small_huts, num_medium_huts, num_large_huts);
  local m_war_value = calculate_troop_value(_p, M_PERSON_WARRIOR, num_small_huts, num_medium_huts, num_large_huts);
  local m_fw_value = calculate_troop_value(_p, M_PERSON_SUPER_WARRIOR, num_small_huts, num_medium_huts, num_large_huts);
  
  ai_attr_w(_p, ATTR_PREF_RELIGIOUS_PEOPLE, m_priest_value);
  ai_attr_w(_p, ATTR_PREF_WARRIOR_PEOPLE, m_war_value);
  ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, m_fw_value);
end

local function _AI4_MANAGE_MY_TROOPS_AMOUNTS(_p, _sturn, difficulty)
  local num_small_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE);
  local num_medium_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_2);
  local num_large_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_3);
  
  local m_priest_value = calculate_troop_value(_p, M_PERSON_RELIGIOUS, num_small_huts, num_medium_huts, num_large_huts);
  local m_fw_value = calculate_troop_value(_p, M_PERSON_SUPER_WARRIOR, num_small_huts, num_medium_huts, num_large_huts);
  
  ai_attr_w(_p, ATTR_PREF_RELIGIOUS_PEOPLE, m_priest_value);
  ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, m_fw_value);
end



local _EVENT_INDEX = 1;
local _EVENT_TABLE =
{
  -- player 1
  {
    [AI_EASY] =
    {
      {_AI_CALC_BUCKETS_GENERAL, 128, 64},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 128, 64},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_HARD] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 128, 64},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 256, 64},
      {_AI1_SHOULD_I_BUILD_AIRSHIP_HUT, 512, 128},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 128, 64},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 256, 64},
      {_AI1_SHOULD_I_BUILD_AIRSHIP_HUT, 512, 128},
    },
  },
  
  -- player 2
  {
    [AI_EASY] =
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI2_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI2_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_HARD] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI2_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI2_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
  },
  
  -- player 3
  {
    [AI_EASY] =
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI3_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI3_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_HARD] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI3_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI3_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
  },
  
  -- player 4
  {
    [AI_EASY] =
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI4_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI4_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_HARD] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI4_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_EXTREME] = 
    {
      {_AI_CALC_BUCKETS_GENERAL, 688, 32},
      {_AI4_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
  }
}

function register_ai_events(player_num, difficulty)
  local t = _EVENT_TABLE[_EVENT_INDEX][difficulty];
  PLAYER_2_IDX[player_num] = _EVENT_INDEX;
  for i,event in ipairs(t) do
    if (event ~= nil) then
      TurnClock.new(get_script_turn(), event[1], event[2], player_num, event[3], difficulty);
    end
  end
  
  if (_EVENT_INDEX == 1) then
  
  else
  
  end
  
  _EVENT_INDEX = _EVENT_INDEX + 1;
end

function process_ai_events()
  TurnClock.process_clocks();
  
  process_shaman_ai(get_script_turn());
end