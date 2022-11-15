-- Imports
import(Module_Commands);
import(Module_DataTypes);
import(Module_Defines);
import(Module_Draw);
import(Module_Game);
import(Module_Globals);
import(Module_Helpers);
import(Module_Building);
import(Module_Map);
import(Module_Features);
import(Module_Math);
import(Module_Objects);
import(Module_Players);
import(Module_PopScript);
import(Module_String);
import(Module_System);
import(Module_Spells);
import(Module_Table);


-- Includes
include("assets.lua") -- Misc useful tools
include("CActionMan.lua"); -- Cutscene engine
include("CFaith.lua"); -- Faith
include("PSHelpers.lua") -- PopScript helpers
include("Riddles.lua"); -- Riddles system
include("EnhancedSpells.lua") --enhanced spells system

-- Global instances
Engine = CActionManager:Create(); -- Cutscene engine

-- Cutscene engine
Engine:InitDialogSystem();
Engine:InitCinematicSystem();
Engine:SetDlgParameters(ScreenWidth() >> 2, 190, ScreenWidth() >> 1, true, 244);

-- Instantly register default dialog styles upon including.
Engine:AddDialogStyle(510, 511, 512, 513, 514, 516, 517, 515, 518);
Engine:AddDialogStyle(879, 880, 881, 882, 883, 885, 886, 884, 887);
Engine:AddDialogStyle(906, 907, 908, 909, 910, 912, 913, 911, 914);
Engine:AddDialogStyle(933, 934, 935, 936, 937, 939, 940, 938, 941);
Engine:AddDialogStyle(960, 961, 962, 963, 964, 966, 967, 965, 968);
Engine:AddDialogStyle(1615, 1616, 1617, 1618, 1619, 1621, 1622, 1620, 1623);
Engine:AddDialogStyle(1642, 1643, 1644, 1645, 1646, 1648, 1649, 1647, 1650);
Engine:AddDialogStyle(1669, 1670, 1671, 1672, 1673, 1675, 1676, 1674, 1677);
Engine:AddDialogStyle(1696, 1697, 1698, 1699, 1700, 1702, 1703, 1701, 1704);
Engine:AddDialogStyle(1450, 1451, 1452, 1453, 1454, 1458, 1460, 1457, 1462);

Faith = CFaith:Create(); -- Faith system

-- Global variables

-- NEED SAVING
G_GAMESTAGE = 0; --game always starts in early-game stage
G_GAME_DIFFICULTY = get_game_difficulty(); -- current save difficulty.
G_INIT = true;

-- DOESN'T NEED SAVING
G_GAME_LOADED = false;
G_LEVEL = gns.StartLevelNumber;
G_PLAYER = 0
G_PLR_PTR = {
  [0] = getPlayer(TRIBE_BLUE),
  getPlayer(TRIBE_RED),
  getPlayer(TRIBE_YELLOW),
  getPlayer(TRIBE_GREEN),
  getPlayer(TRIBE_CYAN),
  getPlayer(TRIBE_PINK),
  getPlayer(TRIBE_BLACK),
  getPlayer(TRIBE_ORANGE),
}
G_SPELL_CONST = spells_type_info();
G_BLDG_CONST = building_type_info();
G_ENCY = encyclopedia_info();


-- Difficulties
G_DIFF_BEGINNER = 0;
G_DIFF_EXPERIENCED = 1;
G_DIFF_VETERAN = 2;
G_DIFF_HONOUR = 3;


function SaveGlobals(sd)
  sd:push_int(G_GAMESTAGE);
  sd:push_int(get_game_difficulty());
  sd:push_bool(G_INIT);
end

function LoadGlobals(ld)
  G_INIT = ld:pop_bool();
  G_GAME_DIFFICULTY = ld:pop_int();
  G_GAMESTAGE = ld:pop_int();
end
