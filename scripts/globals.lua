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

-- lib
include("popscript.lua");
--include("lb_box.lua");
--include("lb_button.lua");
--include("lb_menu.lua");
--include("lb_textbox.lua");

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

turn = 0

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

function reduce_computer_players_sprogging_time_by_percent(t_player, percent)
  local p_sprog_time = t_player.LimitsBuilding.SproggingTime
  local one_percent_1 = math.floor(p_sprog_time[M_BUILDING_TEPEE] / 100);
  local one_percent_2 = math.floor(p_sprog_time[M_BUILDING_TEPEE_2] / 100);
  local one_percent_3 = math.floor(p_sprog_time[M_BUILDING_TEPEE_3] / 100);

  p_sprog_time[M_BUILDING_TEPEE] = p_sprog_time[M_BUILDING_TEPEE] - (one_percent_1 * percent);
  p_sprog_time[M_BUILDING_TEPEE_2] = p_sprog_time[M_BUILDING_TEPEE_2] - (one_percent_2 * percent);
  p_sprog_time[M_BUILDING_TEPEE_3] = p_sprog_time[M_BUILDING_TEPEE_3] - (one_percent_3 * percent);
end