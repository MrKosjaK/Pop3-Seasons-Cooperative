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

local _EVENT_INDEX = 1;
local _EVENT_TABLE =
{
  -- player 1
  {
    [AI_EASY] =
    {
    },
    
    [AI_MEDIUM] = 
    {
    },
    
    [AI_HARD] = 
    {
    },
    
    [AI_EXTREME] = 
    {
    },
  },
  
  -- player 2
  {
    [AI_EASY] =
    {
    },
    
    [AI_MEDIUM] = 
    {
    },
    
    [AI_HARD] = 
    {
    },
    
    [AI_EXTREME] = 
    {
    },
  },
  
  -- player 3
  {
    [AI_EASY] =
    {
    },
    
    [AI_MEDIUM] = 
    {
    },
    
    [AI_HARD] = 
    {
    },
    
    [AI_EXTREME] = 
    {
    },
  },
  
  -- player 4
  {
    [AI_EASY] =
    {
    },
    
    [AI_MEDIUM] = 
    {
    },
    
    [AI_HARD] = 
    {
    },
    
    [AI_EXTREME] = 
    {
    },
  }
}

function register_ai_events(player_num, difficulty)
  local t = _EVENT_TABLE[_EVENT_INDEX][difficulty];
  
  for i,event in ipairs(t) do
    if (event ~= nil) then
      TurnClock.new(get_script_turn(), event[1], event[2], player_num, event[3]);
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