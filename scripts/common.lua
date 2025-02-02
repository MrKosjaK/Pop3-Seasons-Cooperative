-- includes
include("globals.lua");
include("assets.lua");
include("game_lobby.lua");
include("game_state.lua");
include("event_logger.lua");

local GAME_STARTED = false;
local SHAM_ORIG_POS = {};
local SHAM_CURR_POS = {};
local SHAM_ORDER = {};

-- buttons
BTN_PLR1_POS = create_button_array({"Position A", "Position B"}, 3, 2, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_AI_DIFFICULTY = create_button_array({"Beginner", "Moderate", "Honour"}, 3, 3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_CHECK_IN = create_button("Check in", 3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_START_GAME = create_button("Start Game", 3, BTN_STYLE_DEFAULT3, BTN_STYLE_DEFAULT3_H, BTN_STYLE_DEFAULT3_HP);

-- menus
MENU_CHECK_IN = create_menu("Check Phase", BTN_STYLE_GRAY);
MENU_PLAYERS = create_menu("Player List", BTN_STYLE_GRAY);
MENU_OPTIONS = create_menu("Game Options", BTN_STYLE_GRAY);
MENU_AI = create_menu("AI Settings", BTN_STYLE_GRAY);

-- main hooks

-- triggered on level initialization
function OnLevelInit(level_id)
  if (ScrOnLevelInit ~= nil) then ScrOnLevelInit(level_id); end
  
  local pos = MapPosXZ.new() 
      pos.Pos = world_coord3d_to_map_idx(HUMAN_INFO[1]._start_pos);	
      ZOOM_TO(pos.XZ.X,pos.XZ.Z, 256 * math.random(1, 8));
  
  if (is_game_state(GM_STATE_SETUP)) then
    -- let's prepare level for lobby
    set_level_unable_to_complete();
    set_level_unable_to_lose();
    --create_log_event(EVENT_TYPE_INFO, "Welcome to the Seasons Lobby!", 64);
    
    -- freeze all units and make them unselectable
    ProcessGlobalTypeList(T_PERSON, function(t_thing)
      remove_all_persons_commands(t_thing);
      --if (t_thing.Model ~= M_PERSON_MEDICINE_MAN) then
        set_person_new_state(t_thing, S_PERSON_NONE);
      --end
      t_thing.Flags2 = t_thing.Flags2 | TF2_PERSON_NOT_SELECTABLE;
      return true;
    end);
    
    for i = 0, 7 do
      if (G_PLR[i].DeadCount > 0) then
        G_PLR[i].PlayerType = NO_PLAYER;
      end
      if (getPlayer(i).NumPeople > 0 and getShaman(i)) then
        set_player_reinc_site_off(getPlayer(i));
        mark_reincarnation_site_mes(getPlayer(i).ReincarnSiteCoord, OWNER_NONE, UNMARK);
        SHAM_ORDER[#SHAM_ORDER + 1] = i;
        SHAM_ORIG_POS[#SHAM_ORIG_POS + 1] = Coord3D.new();
        SHAM_CURR_POS[#SHAM_CURR_POS + 1] = Coord3D.new();
        SHAM_ORIG_POS[#SHAM_ORIG_POS].Xpos = getShaman(i).Pos.D3.Xpos;
        SHAM_ORIG_POS[#SHAM_ORIG_POS].Zpos = getShaman(i).Pos.D3.Zpos;
        SHAM_ORIG_POS[#SHAM_ORIG_POS].Ypos = getShaman(i).Pos.D3.Ypos;
        SHAM_CURR_POS[#SHAM_CURR_POS].Xpos = getShaman(i).Pos.D3.Xpos;
        SHAM_CURR_POS[#SHAM_CURR_POS].Zpos = getShaman(i).Pos.D3.Zpos;
        SHAM_CURR_POS[#SHAM_CURR_POS].Ypos = getShaman(i).Pos.D3.Ypos;
      end
    end
    
  end
end


-- triggered every game turn
function OnTurn()
  -- reason im doing it here is because OnLevelInit resolution is 640x480....
  if (getTurn() == 0) then
    disable_inputs(DIF_FLYBY);
    process_options(OPT_TOGGLE_PANEL, 0, 0);
    
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
        Send(PACKET_START_GAME, "0");
      else
        GAME_STARTED = true;
      end
      
      close_menu(MENU_PLAYERS);
      close_menu(MENU_OPTIONS);
      close_menu(MENU_AI);
      set_button_inactive(BTN_START_GAME);
    end);
    
    -- player 1 position button
    set_array_button_functions(BTN_PLR1_POS,
    function(b)
      local pos = MapPosXZ.new() 
      pos.Pos = world_coord3d_to_map_idx(HUMAN_INFO[b.CurrData]._start_pos);	
      ZOOM_TO(pos.XZ.X,pos.XZ.Z, 256 * math.random(1, 8));
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        Send(PACKET_BTN_ARRAY_DEC, tostring(BTN_PLR1_POS));
      else
        b.CurrData = math.min(math.max(b.CurrData - 1, 1), b.MaxData);
      end
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        Send(PACKET_BTN_ARRAY_INCR, tostring(BTN_PLR1_POS));
      else
        b.CurrData = math.min(math.max(b.CurrData + 1, 1), b.MaxData);
      end
    end);
    
    -- ai difficulty button
    set_array_button_curr_value(BTN_AI_DIFFICULTY, 2);
    set_array_button_functions(BTN_PLR1_POS, nil,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        Send(PACKET_BTN_ARRAY_DEC, tostring(BTN_AI_DIFFICULTY));
      else
        b.CurrData = math.min(math.max(b.CurrData - 1, 1), b.MaxData);
      end
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        Send(PACKET_BTN_ARRAY_INCR, tostring(BTN_AI_DIFFICULTY));
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
    set_menu_dimensions(MENU_PLAYERS, math.floor(ScreenWidth() / 5), 256);
    set_menu_open_function(MENU_PLAYERS,
    function(menu)
      local split_pos = (ScreenWidth() >> 2);
      set_menu_position(MENU_PLAYERS, split_pos - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
      local b_data = get_button_pos_and_dimensions(BTN_PLR1_POS);
      set_array_button_position(BTN_PLR1_POS, menu.Pos[1] + (menu.Size[1] >> 1) - (b_data[3] >> 1), menu.Pos[2] + (menu.Size[2] >> 1) - (b_data[4] >> 1));
      set_button_active(BTN_PLR1_POS);
    end);
    set_menu_close_function(MENU_PLAYERS,
    function(menu)
      set_button_inactive(BTN_PLR1_POS);
    end);
    
    -- options menu
    set_menu_dimensions(MENU_OPTIONS, math.floor(ScreenWidth() / 5), 256);
    set_menu_open_function(MENU_OPTIONS,
    function(menu)
      local split_pos = (ScreenWidth() >> 2);
      set_menu_position(MENU_OPTIONS, (split_pos * 2) - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
    end);
    set_menu_close_function(MENU_OPTIONS,
    function(menu)
    
    end);
    
    -- ai menu
    set_menu_dimensions(MENU_AI, math.floor(ScreenWidth() / 5), 256);
    set_menu_open_function(MENU_AI,
    function(menu)
      local split_pos = (ScreenWidth() >> 2);
      set_menu_position(MENU_AI, (split_pos * 3) - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
    
      local b_data = get_button_pos_and_dimensions(BTN_AI_DIFFICULTY);
      set_array_button_position(BTN_AI_DIFFICULTY, menu.Pos[1] + (menu.Size[1] >> 1) - (b_data[3] >> 1), menu.Pos[2] + (menu.Size[2] >> 1) - (b_data[4] >> 1));
      set_button_active(BTN_AI_DIFFICULTY);
    end);
    set_menu_close_function(MENU_AI,
    function(menu)
      set_button_inactive(BTN_AI_DIFFICULTY);
    end);
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
      
      for i = 1, #SHAM_CURR_POS do
        local n = SHAM_ORDER[i];
        if (getPlayer(n).NumPeople > 0) then
          set_player_reinc_site_on(getPlayer(n));
          getPlayer(n).ReincarnSiteCoord.Xpos = SHAM_CURR_POS[i].Xpos;
          getPlayer(n).ReincarnSiteCoord.Zpos = SHAM_CURR_POS[i].Zpos;
          mark_reincarnation_site_mes(getPlayer(n).ReincarnSiteCoord, n, MARK);
          set_players_shaman_initial_command(getPlayer(n));
        end
      end
      
      spawn_players_initial_stuff();
      
      set_level_able_to_complete();
      set_level_able_to_lose();
      --GAME_STARTED = false;
      --create_log_event(EVENT_TYPE_INFO, "Game has been started!", 64);
      zoom_thing(getShaman(G_NSI.PlayerNum), math.random(0, 2048));
      
      process_options(OPT_TOGGLE_PANEL, 1, 0);
      enable_inputs(DIF_FLYBY);
      set_game_state(GM_STATE_GAME);
    end
  elseif (is_game_state(GM_STATE_GAME)) then
    -- main entry
    if (ScrOnTurn ~= nil) then ScrOnTurn(getTurn()); end
  end
end

--mouse_c2d = get_mouse_pointed_at_coord2d();

-- triggered on thing spawning
function OnCreateThing(t_thing)
  -- check if t_thing isn't local
  if (t_thing.Flags3 & TF3_LOCAL ~= 0) then
    return;
  end
  
  if (ScrOnCreateThing ~= nil) then ScrOnCreateThing(t_thing); end
end


local clr = TbColour.new();
-- triggered on every frame
function OnFrame()
  local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth();
  
  if (ScrOnFrame ~= nil) then ScrOnFrame(w, h, guiW); end
  
  if (am_i_not_in_igm()) then
    if (is_game_state(GM_STATE_SETUP)) then
      local str = "";
      local str_width = 0;
      local x = 0;
      local y = 0;
      
      if (am_i_in_network_game() ~= 0) then
        
      else
        
      end
    end
    
    draw_menus();
    draw_buttons();
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
    --log(string.format("%i %s %i %i", key, is_down, x, y));
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
  --log(string.format("%i %i %s", player_num, packet_type, data));
  if (am_i_in_network_game() ~= 0) then
    if (ScrOnPacket ~= nil) then ScrOnPacket(player_num, packet_type, data); end
    --log(string.format("%i %i %s", player_num, packet_type, data));
    if (is_game_state(GM_STATE_SETUP)) then
      --log(string.format("%i %i %s", player_num, packet_type, data));
      if (packet_type == 256) then
        --log("" .. data);
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
        --log(string.format("Starting network game... Real players: %i", HUMAN_PLAYERS_COUNT));
      end
    end
  end
end