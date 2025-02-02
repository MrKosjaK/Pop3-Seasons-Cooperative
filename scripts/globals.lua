-- ENUMS

-- button types
BTN_TYPE_NORMAL = 0;
BTN_TYPE_ARRAY = 1;

-- packets
PACKET_ROTATE_FORWARD = 0;
PACKET_ROTATE_BACKWARD = 1;
PACKET_ROTATE_RESTORE = 2;
PACKET_START_GAME = 3;

-- game state
GM_STATE_SETUP = 0;
GM_STATE_GAME = 1;
GM_STATE_END = 2;

-- AI difficulty
AI_EASY = 0;
AI_MEDIUM = 1;
AI_HARD = 2;

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
include("lb_box.lua");
include("lb_button.lua");
include("lb_menu.lua");

-- style defines
BTN_STYLE_BLUE = create_layout(879);
BTN_STYLE_BLUE_H = create_layout(888);
BTN_STYLE_BLUE_HP = create_layout(897);
BTN_STYLE_GRAY = create_layout(510); -- normal
BTN_STYLE_GRAY_H = create_layout(519); -- highlight
BTN_STYLE_GRAY_HP = create_layout(528); -- pressed
BTN_STYLE_DEFAULT = create_layout(794); -- normal
BTN_STYLE_DEFAULT_H = create_layout(803); -- highlight
BTN_STYLE_DEFAULT_HP = create_layout(812); -- pressed
BTN_STYLE_DEFAULT2 = create_layout(821); -- normal
BTN_STYLE_DEFAULT2_H = create_layout(830); -- highlight
BTN_STYLE_DEFAULT2_HP = create_layout(839); -- pressed
BTN_STYLE_DEFAULT3 = create_layout(848); -- normal
BTN_STYLE_DEFAULT3_H = create_layout(857); -- highlight
BTN_STYLE_DEFAULT3_HP = create_layout(866); -- pressed

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