-- includes
include("globals.lua");
include("assets.lua");
include("popscript.lua");
include("gui.lua");
include("game_lobby.lua");
include("game_state.lua");

-- main hooks

-- triggered on level initialization
function OnLevelInit(level_id)
  if (ScrOnLevelInit ~= nil) then ScrOnLevelInit(level_id); end
  
  if (is_game_state(GM_STATE_SETUP)) then
    -- let's prepare level for lobby
    set_level_unable_to_complete();
    set_level_unable_to_lose();
    
    -- freeze all units and make them unselectable
    ProcessGlobalTypeList(T_PERSON, function(t_thing)
      remove_all_persons_commands(t_thing);
      set_person_new_state(t_thing, S_PERSON_NONE);
      t_thing.Flags2 = t_thing.Flags2 | TF2_PERSON_NOT_SELECTABLE;
      return true;
    end);
    
    -- mark all players as NO_PLAYER.
    for i = 0, 7 do
      if (G_PLR[i].DeadCount > 0) then
        G_PLR[i].PlayerType = NO_PLAYER;
      end
    end
  end
end


-- triggered every game turn
function OnTurn()
  -- reason im doing it here is because OnLevelInit resolution is still 640x480....
  if (getTurn() == 0) then
    --disable_inputs(DIF_FLYBY);
    process_options(OPT_TOGGLE_PANEL, 0, 0);
    
    gui_init_all_menus();
    link_stuff_to_gui();
    gui_open_menu(MY_MENU_CHECK_IN);
    
    if (OnInit ~= nil) then OnInit(); end
  end
  if (is_game_state(GM_STATE_SETUP)) then
    if (GAME_STARTED) then
      ProcessGlobalTypeList(T_PERSON, function(t_thing)
        remove_all_persons_commands(t_thing);
        set_person_top_state(t_thing);
        t_thing.Flags2 = t_thing.Flags2 & ~TF2_PERSON_NOT_SELECTABLE;
        
        if (t_thing.Model == M_PERSON_WILD) then
          set_person_new_state(t_thing, S_PERSON_STAND_FOR_TIME);
        end
        return true;
      end);
      
      spawn_players_initial_stuff();
      
      set_level_able_to_complete();
      set_level_able_to_lose();
      
      zoom_thing(getShaman(G_NSI.PlayerNum), math.random(0, 2048));
      
      process_options(OPT_TOGGLE_PANEL, 1, 0);
      enable_inputs(DIF_FLYBY);
      
      if (OnGameStart ~= nil) then OnGameStart(); end
      
      set_game_state(GM_STATE_GAME);
    end
  else
    if (is_game_state(GM_STATE_GAME)) then
      -- main entry
      if (ScrOnTurn ~= nil) then ScrOnTurn(); end
	
      G_SCRIPT_TURN = G_SCRIPT_TURN + 1
    end
  end
end

-- triggered on thing spawning
function OnCreateThing(t_thing)
  -- check if t_thing isn't local
  if (t_thing.Flags3 & TF3_LOCAL ~= 0) then
    goto on_create_end;
  end
  
  if (ScrOnCreateThing ~= nil) then ScrOnCreateThing(t_thing); end
  ::on_create_end::
end


-- triggered on every frame
function OnFrame()
  local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth();
  
  if (ScrOnFrame ~= nil) then ScrOnFrame(w, h, guiW); end
  
  if (am_i_not_in_igm()) then
    if (CURR_RES_HEIGHT ~= ScreenHeight() or CURR_RES_WIDTH ~= ScreenWidth()) then
    -- reapply resolution
      CURR_RES_HEIGHT = ScreenHeight();
      CURR_RES_WIDTH = ScreenWidth();
      
      if (CURR_RES_WIDTH >= 1920 and CURR_RES_HEIGHT >= 1080) then
        GUI_TEXT_FONT = 9;
      elseif (CURR_RES_WIDTH >= 1280 and CURR_RES_HEIGHT >= 720) then
        GUI_TEXT_FONT = 3;
      else
        GUI_TEXT_FONT = 4;
      end
      
      -- go through all created menus and trigger their OnRes function
      for i,menu in ipairs(_GUI_MENUS) do
        if (menu.OnRes ~= nil) then
          menu.OnRes(menu);
        end
        
        if (menu.FuncMaintain ~= nil) then
          menu.FuncMaintain(menu);
        end
      end
    end
    
    gui_draw_menus();
    
    if (is_game_state(GM_STATE_SETUP)) then
      PopSetFont(GUI_TEXT_FONT);
      LbDraw_Text(guiW, ScreenHeight() - CharHeight2(), string.format("GUI ID: %i", GUI_HOVERING_ID), 0);
    end
    
    if (is_game_state(GM_STATE_GAME)) then
      PopSetFont(4);
      LbDraw_Text(guiW, ScreenHeight() - CharHeight2(), string.format("Process Turn: %i", get_turn()), 0);
      LbDraw_Text(guiW, ScreenHeight() - (CharHeight2() << 1), string.format("Script Turn: %i", get_script_turn()), 0);
    end
    
    GUI_HOVERING_ID = -1;
  end
end


-- triggered on tribe's death
function OnPlayerDeath(player_num)
  if (ScrOnPlayerDeath ~= nil) then ScrOnPlayerDeath(player_num); end
end


-- triggered on mouse input
function OnMouseButton(key, is_down, x, y)
  if (key == LB_KEY_MOUSE0 or key == LB_KEY_MOUSE1) then
    process_gui_mouse_inputs(key, is_down, x, y);
    --process_buttons_input(is_down, x, y);
  end
end


-- triggered on pressing down a key
function OnKeyDown(key)
  if (ScrOnKeyDown ~= nil) then ScrOnKeyDown(key); end
end

-- triggered on releasing pressed key
function OnKeyUp(key)
  if (ScrOnKeyUp ~= nil) then ScrOnKeyUp(key); end
  
  -- network based/online
  if (is_game_state(GM_STATE_SETUP)) then
    if (am_i_in_network_game() ~= 0) then
      
    else
    
    end
  end
end


-- triggered on receiving a network packet
function OnPacket(player_num, packet_type, data)
  if (am_i_in_network_game() ~= 0) then
    if (ScrOnPacket ~= nil) then ScrOnPacket(player_num, packet_type, data); end
    
    if (is_game_state(GM_STATE_SETUP)) then
      process_game_lobby_packets(player_num, packet_type, data);
    end
  end
end