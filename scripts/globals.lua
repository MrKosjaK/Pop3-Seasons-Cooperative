-- ENUMS

-- button types
BTN_TYPE_NORMAL = 0;
BTN_TYPE_ARRAY = 1;

-- packets
PACKET_MULTI_BUTTON_LEFT = 0;
PACKET_MULTI_BUTTON_RIGHT = 1;
PACKET_ROTATE_RESTORE = 2;
PACKET_START_GAME = 3;

-- game state
GM_STATE_SETUP = 0;
GM_STATE_GAME = 1;
GM_STATE_END = 2;

-- AI difficulty
AI_EASY = 1;
AI_MEDIUM = 2;
AI_HARD = 3;
AI_EXTREME = 4;

-- Seasons

SEASON_WINTER = 1;
SEASON_SPRING = 2;
SEASON_SUMMER = 3;
SEASON_AUTUMN = 4;

-- weather
WEATHER_NONE = 0;
WEATHER_SNOW = 1;
WEATHER_ASH_PARTICLES = 2;
WEATHER_RAIN = 3;


-- module imports
import(Module_Building);
import(Module_Commands);
import(Module_Control);
import(Module_DataTypes);
import(Module_Defines);
import(Module_Draw);
import(Module_Features);
import(Module_Game);
import(Module_Globals);
import(Module_Helpers);
import(Module_ImGui);
import(Module_Level);
import(Module_Map);
import(Module_MapWho);
import(Module_Math);
import(Module_Network);
import(Module_Objects);
import(Module_Person);
import(Module_Players);
import(Module_PopScript);
import(Module_Sound);
import(Module_Shapes);
import(Module_Spells);
import(Module_String);
import(Module_System);
import(Module_Table);

-- global pointers
G_CONST = constants();
G_SPELL_CONST = spells_type_info();
G_BLDG_CONST = building_type_info();
G_ENCY = encyclopedia_info();
G_SI = gsi();
G_NSI = gnsi();
G_PLR = {
  [0] = getPlayer(0),
  getPlayer(1),
  getPlayer(2),
  getPlayer(3),
  getPlayer(4),
  getPlayer(5),
  getPlayer(6),
  getPlayer(7)
};

-- global vars

G_SCRIPT_TURN = 0
G_SCRIPT_SECOND = 0

-- global function
function set_level_unable_to_complete()
  G_NSI.GameParams.Flags2 = G_NSI.GameParams.Flags2 | GPF2_GAME_NO_WIN;
end

function set_level_able_to_complete()
  G_NSI.GameParams.Flags2 = G_NSI.GameParams.Flags2 & ~GPF2_GAME_NO_WIN;
end

function set_level_unable_to_lose()
  G_NSI.GameParams.Flags3 = G_NSI.GameParams.Flags3 | GPF3_NO_GAME_OVER_PROCESS;
end

function set_level_able_to_lose()
  G_NSI.GameParams.Flags3 = G_NSI.GameParams.Flags3 & ~GPF3_NO_GAME_OVER_PROCESS;
end

function set_player_check_surround_slopes(t_player, toggle)
  t_player.LimitsBuilding.CheckForSurroundSlopes = toggle;
end

function get_script_turn()
  return G_SCRIPT_TURN;
end

function reduce_computer_players_sprogging_time_by_percent(t_player, percent)
  local p_sprog_time = t_player.LimitsBuilding.SproggingTime
  local one_percent_1 = math.floor(p_sprog_time[M_BUILDING_TEPEE] / 100);
  local one_percent_2 = math.floor(p_sprog_time[M_BUILDING_TEPEE_2] / 100);
  local one_percent_3 = math.floor(p_sprog_time[M_BUILDING_TEPEE_3] / 100);

  p_sprog_time[M_BUILDING_TEPEE] = p_sprog_time[M_BUILDING_TEPEE] - (one_percent_1 * percent);
  p_sprog_time[M_BUILDING_TEPEE_2] = p_sprog_time[M_BUILDING_TEPEE_2] - (one_percent_2 * percent);
  p_sprog_time[M_BUILDING_TEPEE_3] = p_sprog_time[M_BUILDING_TEPEE_3] - (one_percent_3 * percent);
end

---------------------
-- SAVING/LOADING ---
---------------------

local G_NUM_SAVE_ITEMS = 0;
local SAVE_ITEMS_MAP = {};

function gsave_int(sData, key, value)
  sData:push_int(value);
  sData:push_string(key);
  sData:push_string("INTEGER");
  G_NUM_SAVE_ITEMS = G_NUM_SAVE_ITEMS + 1;
end

function gsave_string(sData, key, str)
  sData:push_string(str);
  sData:push_string(key);
  sData:push_string("STRING");
  G_NUM_SAVE_ITEMS = G_NUM_SAVE_ITEMS + 1;
end

function gsave_bool(sData, key, value)
  sData:push_bool(value);
  sData:push_string(key);
  sData:push_string("BOOLEAN");
  G_NUM_SAVE_ITEMS = G_NUM_SAVE_ITEMS + 1;
end

function gsave_float(sData, key, value)
  sData:push_float(value);
  sData:push_string(key);
  sData:push_string("FLOAT");
  G_NUM_SAVE_ITEMS = G_NUM_SAVE_ITEMS + 1;
end

function gload_all_data(sData)
  SAVE_ITEMS_MAP = {}; -- clear cache
  
  local _t = nil;
  local _k = nil;
  local _v = nil;
  
  G_NUM_SAVE_ITEMS = sData:pop_int();
  
  for i = 1, G_NUM_SAVE_ITEMS do
    _t = sData:pop_string();
    _k = sData:pop_string();
    
    if _t == "INTEGER" then
      SAVE_ITEMS_MAP[_k] = sData:pop_int();
    end
    
    if _t == "STRING" then
      SAVE_ITEMS_MAP[_k] = sData:pop_string();
    end
    
    if _t == "BOOLEAN" then
      SAVE_ITEMS_MAP[_k] = sData:pop_bool();
    end
    
    if _t == "FLOAT" then
      SAVE_ITEMS_MAP[_k] = sData:pop_float();
    end
  end
end

function gload_data(key)
  if (SAVE_ITEMS_MAP[key] ~= nil) then
    log(string.format("Loaded item key: %s, value: %s", key, tostring(SAVE_ITEMS_MAP[key])));
    return SAVE_ITEMS_MAP[key];
  end
  
  log("KEY VALUE NOT FOUND");
  return nil;
end

function gsave_globals(sData)
  gsave_int(sData, "ScriptTurn", G_SCRIPT_TURN);
  sData:push_int(G_NUM_SAVE_ITEMS); -- has to be very last saved item that doesn't account for G_NUM_SAVE_ITEMS
end

function gload_globals();
  G_SCRIPT_TURN = gload_data("ScriptTurn");
end