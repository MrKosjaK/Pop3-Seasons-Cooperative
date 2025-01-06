import(Module_System);
import(Module_Game);
import(Module_Table);
import(Module_Map);
import(Module_Objects);
import(Module_Commands);
import(Module_Defines);
import(Module_Globals);
import(Module_DataTypes);
import(Module_String);
import(Module_Draw);
import(Module_Math);
import(Module_Players);

-- Include our Machine.
include("CActionMan.lua");

-- Instance of our engine. Best to make it global.
Engine = CActionManager:Create();

-- This is necessary if you want your level to have dialog system. Useful for cutscenes, information!
Engine:InitDialogSystem();

-- This is necessary if you want your level to have cinematic module. Useful for cutscenes!
Engine:InitCinematicSystem();

-- Defaulting parameters of dialog settings.
Engine:SetDlgParameters(ScreenWidth() >> 2, 190, ScreenWidth() >> 1, true, 244);

-- Add unique dialog styles. Requires 9 sprite idxes. ORDER IN WHICH YOU ADD STYLES DOES MATTER.
-- MAKE SURE YOU DO THESE ALWAYS ON SCRIPT LOAD (OUTSIDE OF ONTURN OR ANYTHING), COZ IT IS NOT SAVED.
Engine:AddDialogStyle(510, 511, 512, 513, 514, 516, 517, 515, 518); -- Gray ID 1
Engine:AddDialogStyle(879, 880, 881, 882, 883, 885, 886, 884, 887) -- Tribe Blue ID 2
Engine:AddDialogStyle(906, 907, 908, 909, 910, 912, 913, 911, 914) -- Tribe Red ID 3
Engine:AddDialogStyle(933, 934, 935, 936, 937, 939, 940, 938, 941) -- Tribe Yellow ID 4
Engine:AddDialogStyle(960, 961, 962, 963, 964, 966, 967, 965, 968) -- Tribe Green ID 5
Engine:AddDialogStyle(1615, 1616, 1617, 1618, 1619, 1621, 1622, 1620, 1623); -- Tribe Cyan ID 6
Engine:AddDialogStyle(1642, 1643, 1644, 1645, 1646, 1648, 1649, 1647, 1650); -- Tribe Purple ID 7
Engine:AddDialogStyle(1669, 1670, 1671, 1672, 1673, 1675, 1676, 1674, 1677); -- Tribe Black ID 8
Engine:AddDialogStyle(1696, 1697, 1698, 1699, 1700, 1702, 1703, 1701, 1704); -- Tribe Orange ID 9
Engine:AddDialogStyle(1450, 1451, 1452, 1453, 1454, 1458, 1460, 1457, 1462); -- In-Game's dialogs ID 10

-- Misc variables that control level's logic.
local init = true;
local counter = 0;

function OnSave(sd)
  -- Saving hook.

  -- Misc
  sd:push_bool(init);
  sd:push_int(counter);

  -- This is necessary if you want to preserve engine's state.
  Engine:SaveData(sd); -- Calling this is enough.
end

function OnLoad(ld)
  -- Loading hook.

  -- This is necessary if you want to preserve engine's state.
  Engine:LoadData(ld); -- Calling this is enough.

  -- Misc
  counter = ld:pop_int();
  init = ld:pop_bool();
end

function OnTurn()
  if (init) then
    -- Initialization, executed only at the start/execution of level/script.

    -- Starts engine's action manager.
    Engine:StartExecution();

    -- Create a buffer for storing thing indexes.
    Engine:CreateThingBuffers(1);

    -- Create a buffer for various variables, in case you need it. Other wise don't use.
    Engine:CreateVarBuffers(1);
    Engine:AllocateVarBuffer(1, 64);

    -- This command instantly puts black bars at top & bottom.
    Engine:CinemaShow();

    -- Queueing commands with various parameters depending on what they require. CActionMan.lua has all the parameters for commands.
    Engine:QueueCommand(AM_CMD_CREATE_THINGS, 5, 1, 10, T_PERSON, M_PERSON_BRAVE, TRIBE_BLUE, marker_to_coord3d_centre(0));
    Engine:QueueCommand(AM_CMD_CREATE_THINGS, 8, 1, 10, T_PERSON, M_PERSON_BRAVE, TRIBE_BLUE, marker_to_coord3d_centre(0));
    Engine:QueueCommand(AM_CMD_PERS_LOOK_AT, 155, 1, marker_to_coord2d_centre(3));
    Engine:QueueCommand(AM_CMD_DESTROY_THINGS, 299, 1);
    Engine:QueueCommand(AM_CMD_HIDE_PANEL, 0);
    Engine:QueueCommand(AM_CMD_SHOW_PANEL, 294);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 1, "Ikani tribe style.", "Blue", 244, 133, 0, 2, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 13, "Dakini tribe style.", "Red", 244, 133, 0, 3, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 26, "Chumara tribe style.", "Yellow", 244, 133, 0, 4, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 39, "Matak tribe style.", "Green", 244, 133, 0, 5, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 53, "Tiyao tribe style.", "Cyan", 244, 133, 0, 6, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 66, "Toktai tribe style.", "Purple", 244, 133, 0, 7, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 79, "Unkuru tribe style.", "Black", 244, 133, 0, 8, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 93, "Lokara tribe style.", "Orange", 244, 133, 0, 9, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 106, "In-game's dialog default style. <b> Height test. <b> Test.", "Dialog Default", 244, 133, 0, 10, 12);
    Engine:QueueCommand(AM_CMD_QUEUE_MSG, 119, "Epic gray style.", "Gray", 244, 133, 0, 1, 12);
    Engine:QueueCommand(AM_CMD_SET_VAR, 299, 1, 1, 69);
    Engine:QueueCommand(AM_CMD_CINEMA_FADE, 280);

    -- Making sure it is executed once.
    init = false;
  end

  -- Checking if specific variable is set to a specfici number.
  if (Engine:GetVar(1, 1) == 69) then
    --Engine:QueueCommand(AM_CMD_QUEUE_MSG, 300, "Woah..... <d:120> I'm <d:30> surprised... <d:60> Friendship da powa!!!", "Info", 36);
    Engine:SetVar(1, 1, 0);

    -- Will queue an engine stop.
    Engine:QueueCommand(AM_CMD_ENGINE_STOP, 312);
  end

  -- This must be run every turn, handles all the core logic of engine.
  Engine:ProcessExecution();
end

function OnFrame()
  -- This is necessary if you want a cinematic module to be rendered.
  Engine:RenderCinema();

  -- This is necessary if you want a dialog module to be rendered.
  Engine:RenderDialog();

  -- Debugging/testing purposes only.
  --Engine:DisplayDebugInfo();
end
