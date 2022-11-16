-- Imports
import(Module_Building);
import(Module_Commands);
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
import(Module_Objects);
import(Module_Person);
import(Module_Players);
import(Module_PopScript);
import(Module_Sound);
import(Module_Spells);
import(Module_String);
import(Module_System);
import(Module_Table);


-- Includes
include("assets.lua"); -- Misc useful tools
include("PSHelpers.lua"); -- PopScript helpers

-- Global variables
G_GAMESTAGE = 0; --game always starts in early-game stage

-- DOESN'T NEED SAVING
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

-- CONSTANT POINTERS
G_SPELL_CONST = spells_type_info();
G_BLDG_CONST = building_type_info();
G_ENCY = encyclopedia_info();
