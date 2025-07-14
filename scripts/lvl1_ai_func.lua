include("turnclock.lua");
local _ADDON_INDEX = 1;


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

-- EASY EVENTS

local function _AI1_CHECK_BUCKETS_EASY(_p, _sturn)
  if (_sturn < 12000) then
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

-- MEDIUM EVENTS

-- HARD EVENTS

-- EXTREME EVENTS

local _EVENT_INDEX = 1;
local _EVENT_TABLE =
{
  {
    [AI_EASY] =
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64},
    },
    
    [AI_HARD] = 
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64}
    },
    
    [AI_EXTREME] = 
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64}
    },
  },
  {
    [AI_EASY] =
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64},
    },
    
    [AI_MEDIUM] = 
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64},
    },
    
    [AI_HARD] = 
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64},
    },
    
    [AI_EXTREME] = 
    {
      {_AI1_CHECK_BUCKETS_EASY, 256, 64},
    },
  }
}

function register_ai_events(player_num, difficulty)
  local t = _EVENT_TABLE[_EVENT_INDEX][difficulty];
  
  for i,event in ipairs(t) do
    TurnClock.new(get_script_turn(), event[1], event[2], player_num, event[3]);
  end
  
  _EVENT_INDEX = _EVENT_INDEX + 1;
end

function process_ai_events()
  TurnClock.process_clocks();
end