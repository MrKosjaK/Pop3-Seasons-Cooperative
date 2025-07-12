-- game lobby stuff

local AI_DIFFICULTY_STR_TABLE = {"Easy", "Normal", "Hard", "Extreme"};

local ICON_DATA_BASE = {
  [0] = {1, 6883},
  {1, 6903},
  {1, 6923},
  {1, 6943},
  {2, 6883},
  {2, 6903},
  {2, 6923},
  {2, 6943}
}

local TRIBE_NAME_DATA_BASE = {
  [0] = "The Ikani",
  "The Dakini",
  "The Chumara",
  "The Matak",
  "The Tiyao",
  "The Toktai",
  "The Duscol",
  "The Tangerine"
}

-- Stores all settings of lobby
local GLS_PLAYER_SETUP_IDX = 0;
local GLS_COMPUTER_DIFFICULTY = 1;
GAME_LOBBY_SETTINGS =
{
  [GLS_PLAYER_SETUP_IDX] =
  {
    [TRIBE_BLUE] = {1},
    [TRIBE_RED] = {2},
    [TRIBE_YELLOW] = {3},
    [TRIBE_GREEN] = {4},
    [TRIBE_CYAN] = {5},
    [TRIBE_PINK] = {6},
    [TRIBE_BLACK] = {7},
    [TRIBE_ORANGE] = {8}
  },
  
  [GLS_COMPUTER_DIFFICULTY] =
  {
    [1] = {AI_EASY},
    [2] = {AI_EASY},
    [3] = {AI_EASY},
    [4] = {AI_EASY},
    [5] = {AI_EASY},
    [6] = {AI_EASY},
  }
}

GAME_STARTED = false;
HUMAN_COUNT = 0;
AI_COUNT = 0;

-- global check in
GAME_MASTER_ID = -1;
HUMAN_CHECK_IN = {[0] = false, false, false, false, false, false, false, false};
HUMAN_PLAYERS = {};
HUMAN_PLAYERS_COUNT = 0;

-- AI data cache, holds current's AI basic info
AI_PLAYERS = {};

function process_all_ai_info(func)
  for i,k in ipairs(AI_PLAYERS) do
    func(k);
  end
end

function get_ai_player_info(slot)
  return (AI_PLAYERS[slot]);
end

-- spells and bldgs info
-- since we're making players able to swap positions
-- we have to define restrictions in a weird way
-- to support such system
HUMAN_INFO = {};
AI_INFO = {};

-- local check in
local I_AM_NOT_CHECKED_IN = true;

function i_am_checked_in()
  return (I_AM_NOT_CHECKED_IN == false);
end

function check_myself_in()
  if (I_AM_NOT_CHECKED_IN) then
    Send(255, tostring(G_NSI.PlayerNum));
    I_AM_NOT_CHECKED_IN = false;
  end
end

function i_am_game_master()
  return (G_NSI.PlayerNum == GAME_MASTER_ID);
end

function set_level_human_count(n)
  HUMAN_COUNT = n;
end

function set_level_computer_count(n)
  AI_COUNT = n;
end

function add_human_player_start_info(marker_idx, spells, bldgs)
  local data = {
    _spells = {},
    _bldgs = {},
    _start_pos = marker_to_coord3d(marker_idx)
  };
  
  for i = 1, #spells do
    data._spells[#data._spells + 1] = spells[i];
  end
  
  for i = 1, #bldgs do
    data._bldgs[#data._bldgs + 1] = bldgs[i];
  end
  
  centre_coord3d_on_block(data._start_pos);
  HUMAN_INFO[#HUMAN_INFO + 1] = data;
end

function add_ai_player_start_info(marker_idx, tribe_owner, spells, bldgs)
  local data = {
    _spells = {},
    _bldgs = {},
    _forced_owner = tribe_owner or -1,
    _start_pos = marker_to_coord3d(marker_idx)
  };
  
  for i = 1, #spells do
    data._spells[#data._spells + 1] = spells[i];
  end
  
  for i = 1, #bldgs do
    data._bldgs[#data._bldgs + 1] = bldgs[i];
  end
  
  centre_coord3d_on_block(data._start_pos);
  AI_INFO[#AI_INFO + 1] = data;
end

function spawn_players_initial_stuff();
  for i = 1, #HUMAN_PLAYERS do
    local p_num = HUMAN_PLAYERS[i];
   -- local b_data = get_button_ptr(BTN_PLR1_POS + p_num);
    local h_data = HUMAN_INFO[GAME_LOBBY_SETTINGS[GLS_PLAYER_SETUP_IDX][p_num][1]];
    
    for i,k in ipairs(h_data._spells) do
      set_player_can_cast(k, p_num);
      
      if (k ~= M_SPELL_BLAST and k ~= M_SPELL_CONVERT_WILD) then
        set_player_spell_switched_off(p_num, k);
      end
    end
    
    for i,k in ipairs(h_data._bldgs) do
      set_player_can_build(k, p_num);
    end

    createThing(T_PERSON, M_PERSON_MEDICINE_MAN, p_num, h_data._start_pos, false, false);
    
    G_PLR[p_num].PlayerType = HUMAN_PLAYER;
    G_PLR[p_num].PlayerActive = TRUE;
    G_PLR[p_num].DeadCount = 0;
    set_player_reinc_site_on(G_PLR[p_num]);
    G_PLR[p_num].ReincarnSiteCoord.Xpos = h_data._start_pos.Xpos;
    G_PLR[p_num].ReincarnSiteCoord.Zpos = h_data._start_pos.Zpos;
    mark_reincarnation_site_mes(G_PLR[p_num].ReincarnSiteCoord, p_num, MARK);
    set_players_shaman_initial_command(G_PLR[p_num]);
  end
  
  for i = 1, AI_COUNT do
    local ai_data = AI_INFO[i];
    local p_num = ai_data._forced_owner;
    --local b_data = get_button_ptr(BTN_AI_PLR1_DIFF + (i - 1));
    
    if (p_num ~= -1) then
      -- check if existing human players dont match its owner
      for i,k in ipairs(HUMAN_PLAYERS) do
        if (p_num == k) then
          -- found matching
          p_num = -1;
          break
        end
      end
    end
    
    if (p_num == -1) then
      -- if found matching or defined to be random
      p_num = 2;
      local count = 8;
      
      while (count > 0) do
        count = count - 1;
        
        if (G_PLR[p_num].PlayerType == NO_PLAYER) then
          break;
        end
        
        p_num = p_num + 1;
      end
    end
    
    AI_PLAYERS[#AI_PLAYERS + 1] =
    {
      Owner = p_num,
      Coord = ai_data._start_pos,
      Difficulty = GAME_LOBBY_SETTINGS[GLS_COMPUTER_DIFFICULTY][i][1]
    };
    
    for i,k in ipairs(ai_data._spells) do
      set_player_can_cast(k, p_num);
    end
    
    for i,k in ipairs(ai_data._bldgs) do
      set_player_can_build(k, p_num);
    end
    
    createThing(T_PERSON, M_PERSON_MEDICINE_MAN, p_num, ai_data._start_pos, false, false);
    
    computer_init_player(G_PLR[p_num]);
    G_PLR[p_num].DeadCount = 0;
    G_PLR[p_num].PlayerActive = TRUE;
    set_player_reinc_site_on(G_PLR[p_num]);
    G_PLR[p_num].ReincarnSiteCoord.Xpos = ai_data._start_pos.Xpos;
    G_PLR[p_num].ReincarnSiteCoord.Zpos = ai_data._start_pos.Zpos;
    mark_reincarnation_site_mes(G_PLR[p_num].ReincarnSiteCoord, p_num, MARK);
    set_players_shaman_initial_command(G_PLR[p_num]);
  end
end

function update_network_players_count(p_num)
  if (HUMAN_PLAYERS_COUNT == 0) then
    GAME_MASTER_ID = p_num;
    --set_player_name(p_num, "ORE_GAMMAMON", ntb(am_i_in_network_game()));
    set_elem_text_string(MY_ELEM_TXT_GAME_MASTER, string.format("Game Master: %s", get_player_name(p_num, ntb(am_i_in_network_game()))));
  end
  
  HUMAN_CHECK_IN[p_num] = true;
  HUMAN_PLAYERS[#HUMAN_PLAYERS + 1] = p_num;
  HUMAN_PLAYERS_COUNT = HUMAN_PLAYERS_COUNT + 1;
end

function get_info_on_players_count()
  if (HUMAN_PLAYERS_COUNT > HUMAN_COUNT) then
    log(string.format("Amount of players exceed defined amount in level. Defined %i, actual %i", HUMAN_COUNT, HUMAN_PLAYERS_COUNT));
  end
end

function link_stuff_to_gui()
  for i = 0, 5 do
    local ai_diff_btn = get_elem_ptr(MY_ELEM_COMP_PLR1_DIFF + i);
    
    ai_diff_btn.TextData = AI_DIFFICULTY_STR_TABLE;
    ai_diff_btn.DataPtr = GAME_LOBBY_SETTINGS[GLS_COMPUTER_DIFFICULTY][i + 1];
    ai_diff_btn.MaxValue = #AI_DIFFICULTY_STR_TABLE;
  end

  set_elem_btn_function(MY_ELEM_BTN_CHECK_IN, function()
    if (not i_am_checked_in()) then
      if (am_i_in_network_game() ~= 0) then
        check_myself_in();
      else
        update_network_players_count(G_NSI.PlayerNum);
        
        gui_close_menu(MY_MENU_CHECK_IN);
        trigger_menu_maintain(MY_MENU_HUMAN_PLAYERS);
        trigger_menu_maintain(MY_MENU_COMP_PLAYERS);
        gui_open_menu(MY_MENU_HUMAN_PLAYERS);
        gui_open_menu(MY_MENU_COMP_PLAYERS);
        gui_open_menu(MY_MENU_SETUP_GENERAL);
      end
    end
  end);
  
  set_menu_open_func(MY_MENU_COMP_PLAYERS, function(menu)
    menu.isActive = true;
    
    local num_rows = math.min(AI_COUNT, 6);
    local num_icons = math.min(AI_COUNT, 6);
    local num_diff = math.min(AI_COUNT, 6);
    
    for i,elem_entry in ipairs(menu.Elements) do
      elem_entry.isActive = false;
      if (elem_entry.ElemType == ELEM_TYPE_S_PANEL and num_rows > 0) then
        elem_entry.isActive = true;
        num_rows = num_rows - 1;
      end
      
      if (elem_entry.ElemType == ELEM_TYPE_SPRITE and num_icons > 0) then
        elem_entry.isActive = true;
        num_icons = num_icons - 1;
      end
      
      if (elem_entry.ElemType == ELEM_TYPE_MULTI_BUTTON and num_diff > 0) then
        elem_entry.isActive = true;
        num_diff = num_diff - 1;
      end
      
      if (elem_entry.ElemType ~= ELEM_TYPE_S_PANEL and elem_entry.ElemType ~= ELEM_TYPE_SPRITE and elem_entry.ElemType ~= ELEM_TYPE_MULTI_BUTTON) then
        elem_entry.isActive = true;
      end
    end
  end);
  
  set_menu_maintain_func(MY_MENU_COMP_PLAYERS, function(menu)
    local num_comp_players = math.min(AI_COUNT, 6); -- hardcode to 6 max ais.
    
    if (num_comp_players > 0) then
      local space = 0.12;
      local v_offset = (space / 2);
      local init_menu = _GUI_INIT_MENUS[menu.ID];
      
      for i = 0, num_comp_players - 1 do
        local curr_plate = get_elem_ptr(MY_ELEM_SP_COMP_PLR1 + i);
        local init_plate = _GUI_INIT_ELEMENTS[curr_plate.ElemID];
        
        curr_plate.Data.X = math.floor(init_menu.Data.X * CURR_RES_WIDTH);
        curr_plate.Data.Y = math.floor((init_menu.Data.Y + v_offset + (space * i)) * menu.Data.H)
        curr_plate.Data.W = math.floor(init_menu.Data.W * CURR_RES_WIDTH) - 2;
        curr_plate.Data.H = math.floor(space * menu.Data.H);
        
        if (init_plate.JustData.H == HJ_CENTER) then
          curr_plate.Data.X =  curr_plate.Data.X - (curr_plate.Data.W >> 1);
        elseif (init_plate.JustData.H == HJ_RIGHT) then
          curr_plate.Data.X =  curr_plate.Data.X - curr_plate.Data.W;
        end
        
        if (init_plate.JustData.V == VJ_CENTER) then
          curr_plate.Data.Y = curr_plate.Data.Y - (curr_plate.Data.H >> 1);
        elseif (init_plate.JustData.V == VJ_BOTTOM) then
          curr_plate.Data.Y = curr_plate.Data.Y - curr_plate.Data.H;
        end
        
        curr_plate.Box.Left = curr_plate.Data.X;
        curr_plate.Box.Right = curr_plate.Box.Left + curr_plate.Data.W;
        curr_plate.Box.Top = curr_plate.Data.Y;
        curr_plate.Box.Bottom = curr_plate.Box.Top + curr_plate.Data.H;
        
        local curr_icon = get_elem_ptr(MY_ELEM_SPR_COMP_PLR1 + i);
        local init_icon = _GUI_INIT_ELEMENTS[curr_icon.ElemID];
        
        local sprite_t = get_sprite(0, 1056);
        curr_icon.DrawInfo.SpriteIdx = 1056;
        curr_icon.DrawInfo.BankIdx = 0;
        curr_icon.DrawInfo.Animate = false;
        
        if (AI_INFO[i + 1]._forced_owner ~= -1) then
          sprite_t = get_sprite(ICON_DATA_BASE[AI_INFO[i + 1]._forced_owner][1], ICON_DATA_BASE[AI_INFO[i + 1]._forced_owner][2]);
          curr_icon.DrawInfo.SpriteIdx = ICON_DATA_BASE[AI_INFO[i + 1]._forced_owner][2];
          curr_icon.DrawInfo.BankIdx = ICON_DATA_BASE[AI_INFO[i + 1]._forced_owner][1];
          curr_icon.DrawInfo.Animate = true;
        end
        
        curr_icon.Data.X = math.floor((init_menu.Data.X - 0.15) * CURR_RES_WIDTH);
        curr_icon.Data.Y = math.floor((init_menu.Data.Y + v_offset + (space * i)) * menu.Data.H)
        curr_icon.Data.W = sprite_t.Width;
        curr_icon.Data.H = sprite_t.Height;
        
        if (init_icon.JustData.H == HJ_CENTER) then
          curr_icon.Data.X =  curr_icon.Data.X - (curr_icon.Data.W >> 1);
        elseif (init_icon.JustData.H == HJ_RIGHT) then
          curr_icon.Data.X =  curr_icon.Data.X - curr_icon.Data.W;
        end
        
        if (init_icon.JustData.V == VJ_CENTER) then
          curr_icon.Data.Y = curr_icon.Data.Y - (curr_icon.Data.H >> 1);
        elseif (init_icon.JustData.V == VJ_BOTTOM) then
          curr_icon.Data.Y = curr_icon.Data.Y - curr_icon.Data.H;
        end
        
        curr_icon.Box.Left = curr_icon.Data.X;
        curr_icon.Box.Right = curr_icon.Box.Left + curr_icon.Data.W;
        curr_icon.Box.Top = curr_icon.Data.Y;
        curr_icon.Box.Bottom = curr_icon.Box.Top + curr_icon.Data.H;
        
        local curr_m_button = get_elem_ptr(MY_ELEM_COMP_PLR1_DIFF + i);
        local init_m_button = _GUI_INIT_ELEMENTS[curr_m_button.ElemID];
        
        curr_m_button.Data.X = math.floor((init_menu.Data.X + 0.12) * CURR_RES_WIDTH);
        curr_m_button.Data.Y = math.floor((init_menu.Data.Y + v_offset + (space * i)) * menu.Data.H)
        curr_m_button.Data.W = math.floor(0.08 * CURR_RES_WIDTH);
        curr_m_button.Data.H = math.floor(0.05 * menu.Data.H);
        
        if (init_m_button.JustData.H == HJ_CENTER) then
          curr_m_button.Data.X =  curr_m_button.Data.X - (curr_m_button.Data.W >> 1);
        elseif (init_m_button.JustData.H == HJ_RIGHT) then
          curr_m_button.Data.X =  curr_m_button.Data.X - curr_m_button.Data.W;
        end
        
        if (init_m_button.JustData.V == VJ_CENTER) then
          curr_m_button.Data.Y = curr_m_button.Data.Y - (curr_m_button.Data.H >> 1);
        elseif (init_m_button.JustData.V == VJ_BOTTOM) then
          curr_m_button.Data.Y = curr_m_button.Data.Y - curr_m_button.Data.H;
        end
        
        curr_m_button.Box.Left = curr_m_button.Data.X;
        curr_m_button.Box.Right = curr_m_button.Box.Left + curr_m_button.Data.W;
        curr_m_button.Box.Top = curr_m_button.Data.Y;
        curr_m_button.Box.Bottom = curr_m_button.Box.Top + curr_m_button.Data.H;
        
        local curr_comp_name = get_elem_ptr(MY_ELEM_TXT_CPLR_NAME1 + i);
        local curr_comp_init = _GUI_INIT_ELEMENTS[curr_comp_name.ElemID];
        
        if (AI_INFO[i + 1]._forced_owner ~= -1) then
          curr_comp_name.Text = TRIBE_NAME_DATA_BASE[AI_INFO[i + 1]._forced_owner];
        else
          curr_comp_name.Text = "Unknown Tribe";
        end
        
        curr_comp_name.Data.X = math.floor((init_menu.Data.X - 0.06) * CURR_RES_WIDTH);
        curr_comp_name.Data.Y = math.floor((init_menu.Data.Y + v_offset + (space * i)) * menu.Data.H)
        curr_comp_name.Data.W = string_width(curr_comp_name.Text);
        curr_comp_name.Data.H = CharHeight2();
        
        if (curr_comp_init.JustData.H == HJ_CENTER) then
          curr_comp_name.Data.X =  curr_comp_name.Data.X - (curr_comp_name.Data.W >> 1);
        elseif (curr_comp_init.JustData.H == HJ_RIGHT) then
          curr_comp_name.Data.X =  curr_comp_name.Data.X - curr_comp_name.Data.W;
        end
        
        if (curr_comp_init.JustData.V == VJ_CENTER) then
          curr_comp_name.Data.Y = curr_comp_name.Data.Y - (curr_comp_name.Data.H >> 1);
        elseif (curr_comp_init.JustData.V == VJ_BOTTOM) then
          curr_comp_name.Data.Y = curr_comp_name.Data.Y - curr_comp_name.Data.H;
        end
        
        curr_comp_name.Box.Left = curr_comp_name.Data.X;
        curr_comp_name.Box.Right = curr_comp_name.Box.Left + curr_comp_name.Data.W;
        curr_comp_name.Box.Top = curr_comp_name.Data.Y;
        curr_comp_name.Box.Bottom = curr_comp_name.Box.Top + curr_comp_name.Data.H;
      end
    end
  end);
  
  set_menu_open_func(MY_MENU_HUMAN_PLAYERS, function(menu)
    menu.isActive = true;
    
    local num_rows = math.min(HUMAN_PLAYERS_COUNT, 2);
    local num_icons = math.min(HUMAN_PLAYERS_COUNT, 2);
    
    for i,elem_entry in ipairs(menu.Elements) do
      elem_entry.isActive = false;
      if (elem_entry.ElemType == ELEM_TYPE_S_PANEL and num_rows > 0) then
        elem_entry.isActive = true;
        num_rows = num_rows - 1;
      end
      
      if (elem_entry.ElemType == ELEM_TYPE_SPRITE and num_icons > 0) then
        elem_entry.isActive = true;
        num_icons = num_icons - 1;
      end
      
      if (elem_entry.ElemType ~= ELEM_TYPE_S_PANEL and elem_entry.ElemType ~= ELEM_TYPE_SPRITE) then
        elem_entry.isActive = true;
      end
    end
  end);
  
  set_menu_maintain_func(MY_MENU_HUMAN_PLAYERS, function(menu)
    -- need to check how many human players registered
    
    local num_human_players = math.min(HUMAN_PLAYERS_COUNT, 2); -- hardcode num players to 2
    
    if (num_human_players > 0) then
      -- now let's get elements arranged properly
      local init_menu = _GUI_INIT_MENUS[menu.ID];
      
      local space = 0.25;
      local v_offset = (space / 2);
      
      for i = 0, num_human_players - 1 do
        local curr_plate = get_elem_ptr(MY_ELEM_SP_HUMAN_PLR1 + i);
        local init_plate = _GUI_INIT_ELEMENTS[curr_plate.ElemID];
        
        curr_plate.Data.X = math.floor(init_menu.Data.X * CURR_RES_WIDTH);
        curr_plate.Data.Y = math.floor((init_menu.Data.Y + v_offset + (space * i)) * menu.Data.H)
        curr_plate.Data.W = math.floor(init_menu.Data.W * CURR_RES_WIDTH) - 2;
        curr_plate.Data.H = math.floor(space * menu.Data.H);
        
        if (init_plate.JustData.H == HJ_CENTER) then
          curr_plate.Data.X =  curr_plate.Data.X - (curr_plate.Data.W >> 1);
        elseif (init_plate.JustData.H == HJ_RIGHT) then
          curr_plate.Data.X =  curr_plate.Data.X - curr_plate.Data.W;
        end
        
        if (init_plate.JustData.V == VJ_CENTER) then
          curr_plate.Data.Y = curr_plate.Data.Y - (curr_plate.Data.H >> 1);
        elseif (init_plate.JustData.V == VJ_BOTTOM) then
          curr_plate.Data.Y = curr_plate.Data.Y - curr_plate.Data.H;
        end
        
        curr_plate.Box.Left = curr_plate.Data.X;
        curr_plate.Box.Right = curr_plate.Box.Left + curr_plate.Data.W;
        curr_plate.Box.Top = curr_plate.Data.Y;
        curr_plate.Box.Bottom = curr_plate.Box.Top + curr_plate.Data.H;
        
        local curr_icon = get_elem_ptr(MY_ELEM_SPR_HUMAN_PLR1 + i);
        local init_icon = _GUI_INIT_ELEMENTS[curr_icon.ElemID];
        local sprite_t = get_sprite(init_icon.SpriteData.BankIdx, init_icon.SpriteData.SpriteIdx);
        
        curr_icon.Data.X = math.floor((init_menu.Data.X - 0.15) * CURR_RES_WIDTH);
        curr_icon.Data.Y = math.floor((init_menu.Data.Y + v_offset + (space * i)) * menu.Data.H)
        curr_icon.Data.W = sprite_t.Width;
        curr_icon.Data.H = sprite_t.Height;
        
        if (init_icon.JustData.H == HJ_CENTER) then
          curr_icon.Data.X =  curr_icon.Data.X - (curr_icon.Data.W >> 1);
        elseif (init_icon.JustData.H == HJ_RIGHT) then
          curr_icon.Data.X =  curr_icon.Data.X - curr_icon.Data.W;
        end
        
        if (init_icon.JustData.V == VJ_CENTER) then
          curr_icon.Data.Y = curr_icon.Data.Y - (curr_icon.Data.H >> 1);
        elseif (init_icon.JustData.V == VJ_BOTTOM) then
          curr_icon.Data.Y = curr_icon.Data.Y - curr_icon.Data.H;
        end
        
        curr_icon.Box.Left = curr_icon.Data.X;
        curr_icon.Box.Right = curr_icon.Box.Left + curr_icon.Data.W;
        curr_icon.Box.Top = curr_icon.Data.Y;
        curr_icon.Box.Bottom = curr_icon.Box.Top + curr_icon.Data.H;
      end
    end
  end);
  
  set_elem_btn_function(MY_ELEM_BTN_START_GAME, function()
    -- first check player setup indexes to see if there are duplicates
    local found_duplicate = false;
    local setup_ptr = GAME_LOBBY_SETTINGS[GLS_PLAYER_SETUP_IDX];
    local table_check = {false, false, false, false, false, false, false, false};
    for i = 0, #setup_ptr do
      if (HUMAN_CHECK_IN[i]) then
        if (table_check[setup_ptr[i][1]] == false) then
          table_check[setup_ptr[i][1]] = true;
        else
          found_duplicate = true;
          break;
        end
      end
    end
    
    if (not found_duplicate) then
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_START_GAME, "0");
          gui_close_menu(MY_MENU_SETUP_GENERAL);
        end
      else
        GAME_STARTED = true;
        
        gui_close_menu(MY_MENU_HUMAN_PLAYERS);
        gui_close_menu(MY_MENU_COMP_PLAYERS);
        gui_close_menu(MY_MENU_SETUP_GENERAL);
      end
    end
  end);
end

function init_game_lobbys_menus_and_elements()
  local table_str = {};
  
  -- 65 = "A";
  for i = 1, #HUMAN_INFO do
    table_str[i] = string.char(65 + (i - 1));
  end
  
  -- button function defines
  set_button_function(BTN_OM_AI,
  function(button)
    close_menu(MENU_PLAYERS);
    close_menu(MENU_OPTIONS);
    open_menu(MENU_AI);
  end);
  
  set_button_function(BTN_OM_PLAYERS,
  function(button)
    close_menu(MENU_AI);
    close_menu(MENU_OPTIONS);
    open_menu(MENU_PLAYERS);
  end);
  
  set_button_function(BTN_OM_SETTINGS,
  function(button)
    close_menu(MENU_AI);
    close_menu(MENU_PLAYERS);
    open_menu(MENU_OPTIONS);
  end);
  
  
  -- players pos buttons
  for i = 1, 8 do
    set_array_button_text_table(BTN_PLR1_POS + (i - 1), table_str);
    set_array_button_data_ptr(BTN_PLR1_POS + (i - 1), GAME_LOBBY_SETTINGS[GLS_PLAYER_SETUP_IDX][i-1]);
    set_array_button_functions(BTN_PLR1_POS + (i - 1),
    function(b)
      local pos = MapPosXZ.new() 
      pos.Pos = world_coord3d_to_map_idx(HUMAN_INFO[b.CurrData[1]]._start_pos);	
      ZOOM_TO(pos.XZ.X,pos.XZ.Z, 256 * math.random(1, 8));
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_DEC, tostring(BTN_PLR1_POS + (i - 1)));
        end
      else
        b.CurrData[1] = math.min(math.max(b.CurrData[1] - 1, 1), b.MaxData);
      end
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_INCR, tostring(BTN_PLR1_POS + (i - 1)));
        end
      else
        b.CurrData[1] = math.min(math.max(b.CurrData[1] + 1, 1), b.MaxData);
      end
    end);
  end
  
  -- ai difficulty button
  set_array_button_text_table(BTN_AI_DIFFICULTY, AI_DIFFICULTY_STR_TABLE);
  --set_array_button_data_ptr(BTN_AI_DIFFICULTY, AI_MEDIUM);
  set_array_button_functions(BTN_AI_DIFFICULTY, nil,
  function(b)
    if (am_i_in_network_game() ~= 0) then
      if (i_am_game_master()) then
        Send(PACKET_BTN_ARRAY_DEC, tostring(BTN_AI_DIFFICULTY));
      end
    else
      b.CurrData[1] = math.min(math.max(b.CurrData[1] - 1, 1), b.MaxData);
    end
  end,
  function(b)
    if (am_i_in_network_game() ~= 0) then
      if (i_am_game_master()) then
        Send(PACKET_BTN_ARRAY_INCR, tostring(BTN_AI_DIFFICULTY));
      end
    else
      b.CurrData[1] = math.min(math.max(b.CurrData[1] + 1, 1), b.MaxData);
    end
  end);
  
  -- AI BUTTONS
  for i = 1, 6 do
    set_array_button_data_ptr(BTN_AI_PLR1_DIFF + (i - 1), GAME_LOBBY_SETTINGS[GLS_COMPUTER_DIFFICULTY][i]);
    set_array_button_text_table(BTN_AI_PLR1_DIFF + (i - 1), AI_DIFFICULTY_STR_TABLE);
    set_array_button_functions(BTN_AI_PLR1_DIFF + (i - 1), nil,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_DEC, tostring(BTN_AI_PLR1_DIFF + (i - 1)));
        end
      else
        b.CurrData[1] = math.min(math.max(b.CurrData[1] - 1, 1), b.MaxData);
      end
    end,
    function(b)
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_BTN_ARRAY_INCR, tostring(BTN_AI_PLR1_DIFF + (i - 1)));
        end
      else
        b.CurrData[1] = math.min(math.max(b.CurrData[1] + 1, 1), b.MaxData);
      end
    end);
  end
  
  -- check in menu
  set_menu_position_and_dimensions(MENU_CHECK_IN, (ScreenWidth() >> 1) - 48, (ScreenHeight() >> 1) - 45, 96, 90);
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
    local split_pos = (ScreenWidth() >> 1);
    set_menu_position(MENU_PLAYERS, split_pos - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
    
    set_text_field_position(TXT_FIELD_TRIBE, menu.Pos[1] + 40, menu.Pos[2] + 8);
    set_text_field_position(TXT_FIELD_PLR_NAME, menu.Pos[1] + 110, menu.Pos[2] + 8);
    set_text_field_position(TXT_FIELD_START_POS, menu.Pos[1] + 192, menu.Pos[2] + 8);
    set_text_field_active(TXT_FIELD_TRIBE);
    set_text_field_active(TXT_FIELD_PLR_NAME);
    set_text_field_active(TXT_FIELD_START_POS);
    for i = 1, 8 do
      local b_data = get_button_pos_and_dimensions(BTN_PLR1_POS + (i - 1));
      set_array_button_position(BTN_PLR1_POS + (i - 1), menu.Pos[1] + (menu.Size[1] - 68), menu.Pos[2] + 24 + ((i - 1) * 28));
      if (HUMAN_CHECK_IN[i - 1]) then
        set_button_active(BTN_PLR1_POS + (i - 1));
        set_text_field_text(TXT_PLR1_NAME + (i - 1), get_player_name(i - 1, ntb(am_i_in_network_game())));
        set_text_field_position(TXT_PLR1_NAME + (i - 1), menu.Pos[1] + 110, menu.Pos[2] + 24 + ((i - 1) * 28));
        set_text_field_active(TXT_PLR1_NAME + (i - 1));
        set_icon_position(ICON_PLR1 + (i - 1), menu.Pos[1] + 40, menu.Pos[2] + 18 + ((i - 1) * 28));
        set_icon_active(ICON_PLR1 + (i - 1));
      end
    end
    --set_array_button_position(BTN_PLR1_POS, menu.Pos[1] + (menu.Size[1] >> 1) - (b_data[3] >> 1), menu.Pos[2] + (menu.Size[2] >> 1) - (b_data[4] >> 1));
  end);
  set_menu_close_function(MENU_PLAYERS,
  function(menu)
    set_text_field_inactive(TXT_FIELD_TRIBE);
    set_text_field_inactive(TXT_FIELD_PLR_NAME);
    set_text_field_inactive(TXT_FIELD_START_POS);
    for i = 1, 8 do
      set_button_inactive(BTN_PLR1_POS + (i - 1));
      set_text_field_inactive(TXT_PLR1_NAME + (i - 1));
      set_icon_inactive(ICON_PLR1 + (i - 1));
    end
  end);
  
  -- options menu
  set_menu_dimensions(MENU_OPTIONS, 256, 256);
  set_menu_open_function(MENU_OPTIONS,
  function(menu)
    local split_pos = (ScreenWidth() >> 1);
    set_menu_position(MENU_OPTIONS, split_pos - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
  end);
  set_menu_close_function(MENU_OPTIONS,
  function(menu)
    
  end);
  
  -- ai menu
  set_menu_dimensions(MENU_AI, 256, 256);
  set_menu_open_function(MENU_AI,
  function(menu)
    local split_pos = (ScreenWidth() >> 1);
    set_menu_position(MENU_AI, split_pos - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
  
    set_text_field_position(TXT_FIELD_AI_TRIBE, menu.Pos[1] + 40, menu.Pos[2] + 8);
    set_text_field_position(TXT_FIELD_AI_DIFFICULTY, menu.Pos[1] + 160, menu.Pos[2] + 8);
    set_text_field_active(TXT_FIELD_AI_TRIBE);
    set_text_field_active(TXT_FIELD_AI_DIFFICULTY);
    for i = 1, 6 do
      local b_data = get_button_pos_and_dimensions(BTN_AI_PLR1_DIFF + (i - 1));
      set_array_button_position(BTN_AI_PLR1_DIFF + (i - 1), menu.Pos[1] + (menu.Size[1] - 140), menu.Pos[2] + 24 + ((i - 1) * 36));
      
      if (AI_INFO[i] ~= nil) then
        set_button_active(BTN_AI_PLR1_DIFF + (i - 1));
        local own = AI_INFO[i]._forced_owner;
        
        if (own >= 0) then
          set_icon_sprite_and_bank(ICON_AI_PLR1 + (i - 1), ICON_DATA_BASE[own][1], ICON_DATA_BASE[own][2]);
        end
        set_icon_position(ICON_AI_PLR1 + (i - 1), menu.Pos[1] + 40, menu.Pos[2] + 19 + ((i - 1) * 35));
        set_icon_active(ICON_AI_PLR1 + (i - 1));
      end
    end
    --local b_data = get_button_pos_and_dimensions(BTN_AI_DIFFICULTY);
    --set_array_button_position(BTN_AI_DIFFICULTY, menu.Pos[1] + (menu.Size[1] >> 1) - (b_data[3] >> 1), menu.Pos[2] + (b_data[4] >> 1));
    --set_button_active(BTN_AI_DIFFICULTY);
  end);
  set_menu_close_function(MENU_AI,
  function(menu)
    set_text_field_inactive(TXT_FIELD_AI_TRIBE);
    set_text_field_inactive(TXT_FIELD_AI_DIFFICULTY);
  
    for i = 1, 6 do
      set_button_inactive(BTN_AI_PLR1_DIFF + (i - 1));
      set_icon_inactive(ICON_AI_PLR1 + (i - 1));
    end
  end);
end

function process_game_lobby_packets(pn, p_type, data)
  if (p_type == 255) then
    update_network_players_count(tonumber(data));
    
    -- add current player to the list
    if (is_my_menu_open(MY_MENU_HUMAN_PLAYERS)) then
      gui_close_menu(MY_MENU_HUMAN_PLAYERS);
      trigger_menu_maintain(MY_MENU_HUMAN_PLAYERS);
      gui_open_menu(MY_MENU_HUMAN_PLAYERS);
      -- local m_data = get_menu_pos_and_dimensions(MENU_PLAYERS);
      -- set_array_button_position(BTN_PLR1_POS + pn, m_data[1] + (m_data[3] - 68), m_data[2] + 24 + ((pn * 28)));
      -- set_button_active(BTN_PLR1_POS + pn);
      -- set_text_field_text(TXT_PLR1_NAME + pn, get_player_name(pn, ntb(am_i_in_network_game())));
      -- set_text_field_position(TXT_PLR1_NAME + pn, m_data[1] + 110, m_data[2] + 24 + (pn * 28));
      -- set_text_field_active(TXT_PLR1_NAME + pn);
      -- set_icon_position(ICON_PLR1 + pn, m_data[1] + 40, m_data[2] + 18 + (pn * 28));
      -- set_icon_active(ICON_PLR1 + pn);
    end
    
    if (pn == G_NSI.PlayerNum) then
      gui_close_menu(MY_MENU_CHECK_IN);
      trigger_menu_maintain(MY_MENU_HUMAN_PLAYERS);
      trigger_menu_maintain(MY_MENU_COMP_PLAYERS);
      gui_open_menu(MY_MENU_HUMAN_PLAYERS);
      gui_open_menu(MY_MENU_COMP_PLAYERS);
      gui_open_menu(MY_MENU_SETUP_GENERAL);
      --close_menu(MENU_CHECK_IN);
      --set_button_inactive(BTN_CHECK_IN);
      
      
      --open_menu(MENU_PLAYERS);
      --open_menu(MENU_LOG_MSG);
      --open_menu(MENU_OPTIONS);
      --open_menu(MENU_AI);
       
      -- local b_data = get_button_pos_and_dimensions(BTN_START_GAME);
      -- set_button_position(BTN_START_GAME, (ScreenWidth() >> 1) - (b_data[3] >> 1), (ScreenHeight() - (b_data[4] << 1)));
      
      -- local m_data = get_menu_pos_and_dimensions(MENU_PLAYERS);
      -- local middle_x = m_data[1] + (m_data[3] >> 1);
      -- local pos_y = m_data[2] + m_data[4];
      -- local b_data = get_button_pos_and_dimensions(BTN_OM_PLAYERS);
      -- set_button_position(BTN_OM_PLAYERS, middle_x - (b_data[3] >> 1) - 128, pos_y + 12);
      -- local b_data = get_button_pos_and_dimensions(BTN_OM_SETTINGS);
      -- set_button_position(BTN_OM_SETTINGS, middle_x - (b_data[3] >> 1), pos_y + 12);
      -- local b_data = get_button_pos_and_dimensions(BTN_OM_AI);
      -- set_button_position(BTN_OM_AI, middle_x - (b_data[3] >> 1) + 128, pos_y + 12);
      
      -- set_button_active(BTN_START_GAME);
      -- set_button_active(BTN_OM_PLAYERS);
      -- set_button_active(BTN_OM_SETTINGS);
      -- set_button_active(BTN_OM_AI);
    end
  end
  
  -- buttons packets
  if (p_type == PACKET_BTN_ARRAY_DEC) then
    local b = get_button_ptr(tonumber(data));
    b.CurrData[1] = math.min(math.max(b.CurrData[1] - 1, 1), b.MaxData);
  end
  
  if (p_type == PACKET_BTN_ARRAY_INCR) then
    local b = get_button_ptr(tonumber(data));
    b.CurrData[1] = math.min(math.max(b.CurrData[1] + 1, 1), b.MaxData);
  end
  
  if (p_type == PACKET_START_GAME) then
    GAME_STARTED = true;
    
    gui_close_menu(MY_MENU_HUMAN_PLAYERS);
    gui_close_menu(MY_MENU_COMP_PLAYERS);
    gui_close_menu(MY_MENU_SETUP_GENERAL);
  end
end