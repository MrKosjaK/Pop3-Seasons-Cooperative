-- Imports
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

-- Includes
include("assets.lua"); -- Misc useful tools
include("PSHelpers.lua"); -- PopScript helpers
include("SearchUtils.lua"); -- Search stuff
include("AI\\AIPlayer.lua"); -- AIPlayer class
include("Libs\\LbCommands.lua"); -- Commands class

-- Global variables
G_GAMESTAGE = 0; --game always starts in early-game stage
G_GAME_RESYNC = false;
G_PLR_PTR =
{
  [0] = getPlayer(TRIBE_BLUE),
  getPlayer(TRIBE_RED),
  getPlayer(TRIBE_YELLOW),
  getPlayer(TRIBE_GREEN),
  getPlayer(TRIBE_CYAN),
  getPlayer(TRIBE_PINK),
  getPlayer(TRIBE_BLACK),
  getPlayer(TRIBE_ORANGE),
};
G_HUMANS = {};
G_HUMANS_ALIVE = {};
G_AI_ALIVE = {};
G_NUM_OF_HUMANS_FOR_THIS_LEVEL = -1; -- edit at start of each level's script
G_EVERYONE_IN_GAME = {};
G_AI_EXPANSION_TABLE = {
										--last time since expansion(secs)(set to -1 to not expand ever), -1 or c2d (shaman pos to lb from), -1 or c3d (shaman lb target ptr), isAboutToLB, reset if dies/cancelled trying
								[0] = 	{64,-1,-1,false,0},
										{64,-1,-1,false,0},
										{rndb(32,64),-1,-1,false,0},
										{rndb(32,64),-1,-1,false,0},
										{rndb(32,64),-1,-1,false,0},
										{rndb(32,64),-1,-1,false,0},
										{rndb(32,64),-1,-1,false,0},
										{rndb(32,64),-1,-1,false,0}
}

-- CONSTANT POINTERS
G_CONST = constants();
G_SPELL_CONST = spells_type_info();
G_BLDG_CONST = building_type_info();
G_ENCY = encyclopedia_info();
