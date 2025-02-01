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

BTN_CHECK_IN = create_button("Check in", 3, BTN_STYLE_DEFAULT, BTN_STYLE_DEFAULT_H, BTN_STYLE_DEFAULT_HP);

-- main hooks

-- triggered on level initialization
function OnLevelInit(level_id)
  if (ScrOnLevelInit ~= nil) then ScrOnLevelInit(level_id); end
  
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
    
    -- init buttons positions according to people's resolution
    
  end
end


-- triggered every game turn
function OnTurn()
  if (getTurn() == 0) then
    set_button_position(BTN_CHECK_IN, ScreenWidth() >> 1, ScreenHeight() - (ScreenHeight() >> 4));
    if (am_i_in_network_game() ~= 0) then
      set_button_function(BTN_CHECK_IN, function()
        if (not i_am_checked_in()) then
          check_myself_in();
          set_button_inactive(BTN_CHECK_IN);
        end
      end);
    end
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
  
  if (is_game_state(GM_STATE_SETUP)) then
    local str = "";
    local str_width = 0;
    local x = 0;
    local y = 0;
    
    if (am_i_in_network_game() ~= 0) then
      if (not i_am_checked_in()) then
        PopSetFont(3);
        str = "Press [Space] to check in";
        str_width = string_width(str);
        x = (w >> 1) - (str_width >> 1) + (guiW >> 1);
        y = (h - 96);
        
        LbDraw_Text(x, y, str, 0);
      else
        --LbDraw_VerticalLine((w >> 1) + (guiW >> 1), 0, h, clr);
        str = "Press [Space] to start the game";
        
        PopSetFont(3);
        
        str_width = string_width(str);
        x = (w >> 1) - (str_width >> 1) + (guiW >> 1);
        y = (h - 96);
        
        LbDraw_Text(x, y, str, 0);
        
        str = "Press [Q] to rotate backward";
        
        PopSetFont(4);
        str_width = string_width(str);
        y = y - CharHeight2();
        x = (w >> 1) - (str_width) - (str_width >> 2) + (guiW >> 1);
        --LbDraw_VerticalLine(x + (str_width >> 1), 0, h, clr);
        
        LbDraw_Text(x, y, str, 0);
        
        str = "Press [E] to rotate forward"
        str_width = string_width(str);
        x = (w >> 1) + (str_width >> 1) - (str_width >> 2) + (guiW >> 1);
        --LbDraw_VerticalLine(x + (str_width >> 1), 0, h, clr);
        
        LbDraw_Text(x, y, str, 0);
      end
    else
      --LbDraw_VerticalLine((w >> 1) + (guiW >> 1), 0, h, clr);
      str = "Press [Space] to start the game";
        
      PopSetFont(3);
        
      str_width = string_width(str);
      x = (w >> 1) - (str_width >> 1) + (guiW >> 1);
      y = (h - 96);
        
      LbDraw_Text(x, y, str, 0);
        
      str = "Press [Q] to rotate backward";
        
      PopSetFont(4);
      str_width = string_width(str);
      y = y - CharHeight2();
      x = (w >> 1) - (str_width) - (str_width >> 2) + (guiW >> 1);
      --LbDraw_VerticalLine(x + (str_width >> 1), 0, h, clr);
        
      LbDraw_Text(x, y, str, 0);
        
      str = "Press [E] to rotate forward"
      str_width = string_width(str);
      x = (w >> 1) + (str_width >> 1) - (str_width >> 2) + (guiW >> 1);
      --LbDraw_VerticalLine(x + (str_width >> 1), 0, h, clr);
        
      LbDraw_Text(x, y, str, 0);
    end
  end
  
  draw_buttons();
  draw_log_events(w, h, guiW);
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
      if (key == LB_KEY_SPACE) then
        log("space bar");
        if (not i_am_checked_in()) then
          --check_myself_in();
          log("space bar 1");
        else
          Send(PACKET_START_GAME, "0");
          log("space bar 2");
        end
      end
      -- for now rotating will be via hotkeys, later will do GUI
      
      -- FORWARD rotation
      if (key == LB_KEY_E) then
        Send(PACKET_ROTATE_FORWARD, "0");
        --elseif (_IsKeyDown(LB_KEY_LCONTROL) or _IsKeyDown(LB_KEY_RCONTROL)) then
          --Send(PACKET_ROTATE_FORWARD, tostring(key));
        --end
      end
      
      -- BACKWARD rotation
      if (key == LB_KEY_Q) then
        Send(PACKET_ROTATE_BACKWARD, "0");
      end
      
      -- RESTORE rotation
      if (key == LB_KEY_W) then
        Send(PACKET_ROTATE_RESTORE, "0");
      end
    else
      -- forward
      if (key == LB_KEY_E) then
        for i = 1, #SHAM_CURR_POS do
          local value = (i % #SHAM_CURR_POS) + 1;
          --if (value == 0) then value = 1; end
          log(string.format("%i", value));
          --set_person_standing_anim(getShaman(SHAM_ORDER[i]));
          move_thing_within_mapwho(getShaman(SHAM_ORDER[i]), SHAM_CURR_POS[value]);
          move_thing_within_mapwho(getShaman(SHAM_ORDER[i]), SHAM_CURR_POS[value]);
          ensure_thing_on_ground(getShaman(SHAM_ORDER[i]));
          --set_person_standing_anim(getShaman(SHAM_ORDER[i]));
        end
        
        for i = 1, #SHAM_CURR_POS do
          -- update positions
          SHAM_CURR_POS[i].Xpos = getShaman(SHAM_ORDER[i]).Pos.D3.Xpos;
          SHAM_CURR_POS[i].Zpos = getShaman(SHAM_ORDER[i]).Pos.D3.Zpos;
          SHAM_CURR_POS[i].Ypos = getShaman(SHAM_ORDER[i]).Pos.D3.Ypos;
        end

		zoom_thing(getShaman(G_NSI.PlayerNum), 0)
      end
      -- backward
      if (key == LB_KEY_Q) then
      
      end
      -- restore
      if (key == LB_KEY_W) then
      
      end
      
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
      
      if (packet_type == PACKET_START_GAME) then
        GAME_STARTED = true;
        log(string.format("Starting network game... Real players: %i", HUMAN_PLAYERS_COUNT));
      end
    
      if (packet_type == PACKET_GIVE_SPELL_ADD) then
        local key = tonumber(data);
        
        if (key == LB_KEY_1) then
          increment_number_of_one_shots(player_num, M_SPELL_BLAST);
        end
      end
      
      if (packet_type == PACKET_GIVE_SPELL_SUB) then
        local key = tonumber(data);
        
        if (key == LB_KEY_1) then
          reduce_number_of_one_shots(player_num, M_SPELL_BLAST);
        end
      end
    end
  end
end