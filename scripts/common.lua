-- includes
include("globals.lua");
include("assets.lua");
include("game_lobby.lua");
include("game_state.lua");
include("event_logger.lua");

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
  local turn = getTurn()
  
  -- reason im doing it here is because OnLevelInit resolution is still 640x480....
  if (turn == 0) then
    disable_inputs(DIF_FLYBY);
    process_options(OPT_TOGGLE_PANEL, 0, 0);
    
    init_game_lobbys_menus_and_elements();
    
    if (OnInit ~= nil) then OnInit(); end
  end
  if (is_game_state(GM_STATE_SETUP)) then
    if (GAME_STARTED) then
      --get_info_on_players_count();
    
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
      set_game_state(GM_STATE_GAME);
    end
  elseif (is_game_state(GM_STATE_GAME)) then
    -- main entry
    if (ScrOnTurn ~= nil) then ScrOnTurn(turn); end
  end
end

-- triggered on thing spawning
function OnCreateThing(t_thing)
  -- check if t_thing isn't local
  if (t_thing.Flags3 & TF3_LOCAL ~= 0) then
    return;
  end
  
  if (ScrOnCreateThing ~= nil) then ScrOnCreateThing(t_thing); end
end


-- triggered on every frame
function OnFrame()
  local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth();
  
  if (ScrOnFrame ~= nil) then ScrOnFrame(w, h, guiW); end
  
  if (am_i_not_in_igm()) then
    if (is_game_state(GM_STATE_SETUP)) then
      if (am_i_in_network_game() ~= 0) then
        
      else
        
      end
    end
    
    draw_menus();
    draw_buttons();
    draw_text_fields();
    draw_icons();
    draw_log_events(w, h, guiW);
  end
end


-- triggered on tribe's death
function OnPlayerDeath(player_num)
  if (ScrOnPlayerDeath ~= nil) then ScrOnPlayerDeath(player_num); end
end


-- triggered on mouse input
function OnMouseButton(key, is_down, x, y)
  if (key == LB_KEY_MOUSE0) then
    process_buttons_input(is_down, x, y);
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
      if (key == LB_KEY_SPACE) then
        GAME_STARTED = true;
        set_all_elements_inactive();
        close_all_menus();
      end
    end
  end
end


-- triggered on receiving a network packet
function OnPacket(player_num, packet_type, data)
  if (am_i_in_network_game() ~= 0) then
    if (ScrOnPacket ~= nil) then ScrOnPacket(player_num, packet_type, data); end
    
    if (is_game_state(GM_STATE_SETUP)) then
      if (packet_type == 256) then
        update_network_players_count(tonumber(data));
      end
      
      -- buttons packets
      if (packet_type == PACKET_BTN_ARRAY_DEC) then
        local b = get_button_ptr(tonumber(data));
        b.CurrData = math.min(math.max(b.CurrData - 1, 1), b.MaxData);
      end
      
      if (packet_type == PACKET_BTN_ARRAY_INCR) then
        local b = get_button_ptr(tonumber(data));
        b.CurrData = math.min(math.max(b.CurrData + 1, 1), b.MaxData);
      end
      
      if (packet_type == PACKET_START_GAME) then
        GAME_STARTED = true;
        
        close_all_menus();
        set_all_elements_inactive();
      end
    end
  end
end