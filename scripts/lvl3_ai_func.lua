include("turnclock.lua");
local EnemyArea = create_enemy_search_area();


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
  },
  
  -- player 2
  {
  },
  
  -- player 3
  {
  },
  
  -- player 4
  {
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

local function _AI1_CALC_BUCKET_COUNTS(_p, _sturn, difficulty)
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
    [M_PERSON_WARRIOR] = {0.95, 1.25, 1.45},
    [M_PERSON_SUPER_WARRIOR] = {1, 1.35, 1.65}
  },
  
  -- player 2
  {
    [M_PERSON_SPY] = {0.55, 0.70, 0.95},
    [M_PERSON_SUPER_WARRIOR] = {1.15, 1.55, 1.85}
  },
  
  -- player 3
  {
    [M_PERSON_WARRIOR] = {0.95, 1.25, 1.45},
    [M_PERSON_SUPER_WARRIOR] = {1, 1.35, 1.65},
    [M_PERSON_RELIGIOUS] = {1, 1.25, 1.55}
  },
  
  -- player 4
  {
    [M_PERSON_SUPER_WARRIOR] = {0.95, 1.15, 1.35},
    [M_PERSON_RELIGIOUS] = {1.25, 1.55, 1.95}
  }
}

local function _AI1_MANAGE_MY_TROOPS_AMOUNTS(_p, _sturn, difficulty)
  local num_small_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE);
  local num_medium_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_2);
  local num_large_huts = count_bldgs_of_type(_p, M_BUILDING_TEPEE_3);
  
  local function calculate_troop_value(p_type)
    return FLOOR((AI_TROOP_HUT_VALUE_TBL[_p][p_type][M_BUILDING_TEPEE] * num_small_huts) +
    (AI_TROOP_HUT_VALUE_TBL[_p][p_type][M_BUILDING_TEPEE_2] * num_medium_huts) +
    (AI_TROOP_HUT_VALUE_TBL[_p][p_type][M_BUILDING_TEPEE_3] * num_large_huts));
  end
  
  local m_war_value = calculate_troop_value(M_PERSON_WARRIOR);
  local m_fw_value = calculate_troop_value(M_PERSON_SUPER_WARRIOR);
  
  ai_attr_w(_p, ATTR_PREF_WARRIOR_PEOPLE, m_war_value);
  ai_attr_w(_p, ATTR_PREF_SUPER_WARRIOR_PEOPLE, m_fw_value);
end

local _EVENT_INDEX = 1;
local _EVENT_TABLE =
{
  -- player 1
  {
    [AI_EASY] =
    {
      {_AI1_CALC_BUCKET_COUNTS, 688, 32},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_HARD] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
    
    [AI_EXTREME] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
      {_AI1_MANAGE_MY_TROOPS_AMOUNTS, 688, 32},
    },
  },
  
  -- player 2
  {
    [AI_EASY] =
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_HARD] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_EXTREME] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
  },
  
  -- player 3
  {
    [AI_EASY] =
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_HARD] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_EXTREME] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
  },
  
  -- player 4
  {
    [AI_EASY] =
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_HARD] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
    
    [AI_EXTREME] = 
    {
      {_AI1_CALC_BUCKET_COUNTS, 720, 16},
    },
  }
}

function register_ai_events(player_num, difficulty)
  local t = _EVENT_TABLE[_EVENT_INDEX][difficulty];
  
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