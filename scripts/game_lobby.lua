-- game lobby stuff

local AI_DIFFICULTY_STR_TABLE = {"Easy", "Medium", "Hard", "Extreme"};

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
  local occupied_p_nums = {};
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
    
    occupied_p_nums[#occupied_p_nums + 1] = p_num;
  end
  
  for i,ai_data in ipairs(AI_INFO) do
    occupied_p_nums[#occupied_p_nums + 1] = ai_data._forced_owner;
  end
  
  local free_pn_slots = {}
  
  for i = 0, 7 do
    for j,p_num in ipairs(occupied_p_nums) do
      if (i == p_num) then
        goto continue;
      end
    end
    
    free_pn_slots[#free_pn_slots + 1] = i;
    ::continue::
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
      p_num = free_pn_slots[G_RANDOM(#free_pn_slots) + 1];
      
      for i,pn in ipairs(free_pn_slots) do
        if (pn == p_num) then
          table.remove(free_pn_slots, i);
          break;
        end
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
    set_elem_text_string(MY_ELEM_TXT_GAME_MASTER, string.format("Game Master: %s", get_player_name(p_num, ntb(am_i_in_network_game()))));
  end
  
  HUMAN_CHECK_IN[p_num] = true;
  HUMAN_PLAYERS[#HUMAN_PLAYERS + 1] = p_num;
  HUMAN_PLAYERS_COUNT = HUMAN_PLAYERS_COUNT + 1;
end

function link_stuff_to_gui()
  for i = 0, 5 do
    local ai_diff_btn = get_elem_ptr(MY_ELEM_COMP_PLR1_DIFF + i);
    
    ai_diff_btn.TextData = AI_DIFFICULTY_STR_TABLE;
    ai_diff_btn.DataPtr = GAME_LOBBY_SETTINGS[GLS_COMPUTER_DIFFICULTY][i + 1];
    ai_diff_btn.MaxValue = #AI_DIFFICULTY_STR_TABLE;
  end
  
  for i = 0, 1 do
    local plr_pos_btn = get_elem_ptr(MY_ELEM_HUMAN_PLR1_INFO + i);
    
    plr_pos_btn.TextData = {"First", "Second"};
    plr_pos_btn.DataPtr = GAME_LOBBY_SETTINGS[GLS_PLAYER_SETUP_IDX][i];
    plr_pos_btn.MaxValue = 2;
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
          curr_comp_name.Text = "Randomized";
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
    local num_pos = math.min(HUMAN_PLAYERS_COUNT, 2);
    
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
      
      if (elem_entry.ElemType == ELEM_TYPE_MULTI_BUTTON and num_pos > 0) then
        elem_entry.isActive = true;
        num_pos = num_pos - 1;
      end
      
      if (elem_entry.ElemType ~= ELEM_TYPE_S_PANEL and elem_entry.ElemType ~= ELEM_TYPE_SPRITE and elem_entry.ElemType ~= ELEM_TYPE_MULTI_BUTTON) then
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
        local sprite_t = get_sprite(ICON_DATA_BASE[HUMAN_PLAYERS[i + 1]][1], ICON_DATA_BASE[HUMAN_PLAYERS[i + 1]][2]);
        
        curr_icon.DrawInfo.BankIdx = ICON_DATA_BASE[HUMAN_PLAYERS[i + 1]][1];
        curr_icon.DrawInfo.SpriteIdx = ICON_DATA_BASE[HUMAN_PLAYERS[i + 1]][2];
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
        
        local curr_comp_name = get_elem_ptr(MY_ELEM_TXT_HPLR_NAME1 + i);
        local curr_comp_init = _GUI_INIT_ELEMENTS[curr_comp_name.ElemID];
        
        curr_comp_name.Text = get_player_name(HUMAN_PLAYERS[i + 1], ntb(am_i_in_network_game()));
        
        curr_comp_name.Data.X = math.floor((init_menu.Data.X - 0.0625) * CURR_RES_WIDTH);
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
        
        local curr_m_button = get_elem_ptr(MY_ELEM_HUMAN_PLR1_INFO + i);
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
          if (HUMAN_PLAYERS_COUNT > 1) then -- for now in network game you're forced to have an ally.
            Send(PACKET_START_GAME, "0");
            gui_close_menu(MY_MENU_SETUP_GENERAL);
          end
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

function process_game_lobby_packets(pn, p_type, data)
  if (p_type == 255) then
    update_network_players_count(tonumber(data));
    
    -- add current player to the list
    if (is_my_menu_open(MY_MENU_HUMAN_PLAYERS)) then
      gui_close_menu(MY_MENU_HUMAN_PLAYERS);
      trigger_menu_maintain(MY_MENU_HUMAN_PLAYERS);
      gui_open_menu(MY_MENU_HUMAN_PLAYERS);
    end
    
    if (pn == G_NSI.PlayerNum) then
      gui_close_menu(MY_MENU_CHECK_IN);
      trigger_menu_maintain(MY_MENU_HUMAN_PLAYERS);
      trigger_menu_maintain(MY_MENU_COMP_PLAYERS);
      gui_open_menu(MY_MENU_HUMAN_PLAYERS);
      gui_open_menu(MY_MENU_COMP_PLAYERS);
      gui_open_menu(MY_MENU_SETUP_GENERAL);
    end
  end
  
  -- buttons packets
  if (p_type == PACKET_MULTI_BUTTON_RIGHT) then
    local b = get_elem_ptr(tonumber(data));
    b.DataPtr[1] = math.min(math.max(b.DataPtr[1] - 1, 1), b.MaxValue);
  end
  
  if (p_type == PACKET_MULTI_BUTTON_LEFT) then
    local b = get_elem_ptr(tonumber(data));
    b.DataPtr[1] = math.min(math.max(b.DataPtr[1] + 1, 1), b.MaxValue);
  end
  
  if (p_type == PACKET_START_GAME) then
    GAME_STARTED = true;
    
    gui_close_menu(MY_MENU_HUMAN_PLAYERS);
    gui_close_menu(MY_MENU_COMP_PLAYERS);
    gui_close_menu(MY_MENU_SETUP_GENERAL);
  end
end