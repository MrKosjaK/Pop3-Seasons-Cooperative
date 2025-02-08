-- includes
include("globals.lua");
include("assets.lua");
include("game_lobby.lua");
include("game_state.lua");
include("event_logger.lua");

local GAME_STARTED = false;

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
    
    local table_str = {};
    
    -- 65 = "A";
    for i = 1, #HUMAN_INFO do
      table_str[i] = string.char(65 + (i - 1));
    end
    
    -- button function defines
    set_button_function(BTN_CHECK_IN, 
    function(button)
      if (not i_am_checked_in()) then
        if (am_i_in_network_game() ~= 0) then
          check_myself_in();
        else
          update_network_players_count(G_NSI.PlayerNum);
        end
        
        close_menu(MENU_CHECK_IN);
        set_button_inactive(BTN_CHECK_IN);
        open_menu(MENU_PLAYERS);
        open_menu(MENU_OPTIONS);
        open_menu(MENU_AI);
        
        local b_data = get_button_pos_and_dimensions(BTN_START_GAME);
        set_button_position(BTN_START_GAME, (ScreenWidth() >> 1) - (b_data[3] >> 1), (ScreenHeight() - 96));
        set_button_active(BTN_START_GAME);
      end
    end);
    
    -- start game button
    set_button_function(BTN_START_GAME,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_START_GAME, "0");
          set_button_inactive(BTN_START_GAME);
        end
      else
        GAME_STARTED = true;
        
        set_button_inactive(BTN_START_GAME);
        close_menu(MENU_PLAYERS);
        close_menu(MENU_OPTIONS);
        close_menu(MENU_AI);
      end
    end);
    
    -- players pos buttons
    for i = 1, 8 do
      set_array_button_text_table(BTN_PLR1_POS + (i - 1), table_str);
    end
    set_array_button_functions(BTN_PLR1_POS,
    function(b)
      local pos = MapPosXZ.new() 
      pos.Pos = world_coord3d_to_map_idx(HUMAN_INFO[b.CurrData]._start_pos);	
      ZOOM_TO(pos.XZ.X,pos.XZ.Z, 256 * math.random(1, 8));
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_DEC, tostring(BTN_PLR1_POS));
        end
      else
        b.CurrData = math.min(math.max(b.CurrData - 1, 1), b.MaxData);
      end
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_INCR, tostring(BTN_PLR1_POS));
        end
      else
        b.CurrData = math.min(math.max(b.CurrData + 1, 1), b.MaxData);
      end
    end);
    
    -- ai difficulty button
    set_array_button_curr_value(BTN_AI_DIFFICULTY, 2);
    set_array_button_functions(BTN_AI_DIFFICULTY, nil,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_DEC, tostring(BTN_AI_DIFFICULTY));
        end
      else
        b.CurrData = math.min(math.max(b.CurrData - 1, 1), b.MaxData);
      end
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_INCR, tostring(BTN_AI_DIFFICULTY));
        end
      else
        b.CurrData = math.min(math.max(b.CurrData + 1, 1), b.MaxData);
      end
    end);
    
    -- check in menu
    set_menu_position_and_dimensions(MENU_CHECK_IN, (ScreenWidth() >> 1) - 98, (ScreenHeight() >> 1) - 15, 196, 30);
    set_menu_open_function(MENU_CHECK_IN,
    function(menu)
      local b_data = get_button_pos_and_dimensions(BTN_CHECK_IN);
      set_button_position(BTN_CHECK_IN, menu.Pos[1] + (menu.Size[1] >> 1) - (b_data[3] >> 1), menu.Pos[2] + (menu.Size[2] >> 1) - (b_data[4] >> 1));
      set_button_active(BTN_CHECK_IN);
    end);
    set_menu_close_function(MENU_CHECK_IN,
    function(menu)
      set_button_inactive(BTN_CHECK_IN);
    end);
    open_menu(MENU_CHECK_IN);
    
    -- players menu
    set_menu_dimensions(MENU_PLAYERS, 256, 256);
    set_menu_open_function(MENU_PLAYERS,
    function(menu)
      local split_pos = (ScreenWidth() >> 2);
      set_menu_position(MENU_PLAYERS, split_pos - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
      
      set_text_field_position(TXT_FIELD_TRIBE, menu.Pos[1] + 40, menu.Pos[2]);
      set_text_field_position(TXT_FIELD_PLR_NAME, menu.Pos[1] + 110, menu.Pos[2]);
      set_text_field_position(TXT_FIELD_START_POS, menu.Pos[1] + 192, menu.Pos[2]);
      set_text_field_active(TXT_FIELD_TRIBE);
      set_text_field_active(TXT_FIELD_PLR_NAME);
      set_text_field_active(TXT_FIELD_START_POS);
      for i = 1, 8 do
        local b_data = get_button_pos_and_dimensions(BTN_PLR1_POS);
        set_array_button_position(BTN_PLR1_POS + (i - 1), menu.Pos[1] + (menu.Size[1] - 68), menu.Pos[2] + 24 + ((i - 1) * 28));
        if (true) then
          set_button_active(BTN_PLR1_POS + (i - 1));
          set_text_field_text(TXT_PLR1_NAME + (i - 1), get_player_name(i - 1, ntb(am_i_in_network_game())));
          set_text_field_position(TXT_PLR1_NAME + (i - 1), menu.Pos[1] + 110, menu.Pos[2] + 24 + ((i - 1) * 28));
          set_text_field_active(TXT_PLR1_NAME + (i - 1));
          set_icon_position(ICON_PLR1 + (i - 1), menu.Pos[1] + 40, menu.Pos[2] + 24 + ((i - 1) * 28));
          set_icon_active(ICON_PLR1 + (i - 1));
        end
      end
      --set_array_button_position(BTN_PLR1_POS, menu.Pos[1] + (menu.Size[1] >> 1) - (b_data[3] >> 1), menu.Pos[2] + (menu.Size[2] >> 1) - (b_data[4] >> 1));
    end);
    set_menu_close_function(MENU_PLAYERS,
    function(menu)
      set_button_inactive(BTN_PLR1_POS);
    end);
    
    -- options menu
    set_menu_dimensions(MENU_OPTIONS, 256, 256);
    set_menu_open_function(MENU_OPTIONS,
    function(menu)
      local split_pos = (ScreenWidth() >> 2);
      set_menu_position(MENU_OPTIONS, (split_pos * 2) - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
    end);
    set_menu_close_function(MENU_OPTIONS,
    function(menu)
    
    end);
    
    -- ai menu
    set_menu_dimensions(MENU_AI, 256, 256);
    set_menu_open_function(MENU_AI,
    function(menu)
      local split_pos = (ScreenWidth() >> 2);
      set_menu_position(MENU_AI, (split_pos * 3) - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
    
      local b_data = get_button_pos_and_dimensions(BTN_AI_DIFFICULTY);
      --set_array_button_position(BTN_AI_DIFFICULTY, menu.Pos[1] + (menu.Size[1] >> 1) - (b_data[3] >> 1), menu.Pos[2] + (menu.Size[2] >> 1) - (b_data[4] >> 1));
      --set_button_active(BTN_AI_DIFFICULTY);
    end);
    set_menu_close_function(MENU_AI,
    function(menu)
      set_button_inactive(BTN_AI_DIFFICULTY);
    end);
    
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
        
        close_menu(MENU_PLAYERS);
        close_menu(MENU_OPTIONS);
        close_menu(MENU_AI);
        
        set_button_inactive(BTN_START_GAME);
      end
    end
  end
end