-- game lobby stuff

-- MENU: PLAYERS
MENU_PLAYERS = create_menu("Player List", BTN_STYLE_GRAY);
TXT_PLR1_NAME = create_text_field("", 3);
TXT_PLR2_NAME = create_text_field("", 3);
TXT_PLR3_NAME = create_text_field("", 3);
TXT_PLR4_NAME = create_text_field("", 3);
TXT_PLR5_NAME = create_text_field("", 3);
TXT_PLR6_NAME = create_text_field("", 3);
TXT_PLR7_NAME = create_text_field("", 3);
TXT_PLR8_NAME = create_text_field("", 3);
ICON_PLR1 = create_icon(1, 6883);
ICON_PLR2 = create_icon(1, 6903);
ICON_PLR3 = create_icon(1, 6923);
ICON_PLR4 = create_icon(1, 6943);
ICON_PLR5 = create_icon(2, 6883);
ICON_PLR6 = create_icon(2, 6903);
ICON_PLR7 = create_icon(2, 6923);
ICON_PLR8 = create_icon(2, 6943);
TXT_FIELD_TRIBE = create_text_field("Tribe", 4);
TXT_FIELD_PLR_NAME = create_text_field("Name", 4);
TXT_FIELD_START_POS = create_text_field("Start Pos", 4);
BTN_PLR1_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_PLR2_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_PLR3_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_PLR4_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_PLR5_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_PLR6_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_PLR7_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_PLR8_POS = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);

-- MENU: OPTIONS
MENU_OPTIONS = create_menu("Game Options", BTN_STYLE_GRAY);
BTN_AI_DIFFICULTY = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);

-- MENU: AI SETTINGS
MENU_AI = create_menu("AI Settings", BTN_STYLE_GRAY);
BTN_AI_PLR1_DIFF = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_AI_PLR2_DIFF = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_AI_PLR3_DIFF = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_AI_PLR4_DIFF = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_AI_PLR5_DIFF = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_AI_PLR6_DIFF = create_button_array(3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
TXT_FIELD_AI_TRIBE = create_text_field("Tribe", 4);
TXT_FIELD_AI_DIFFICULTY = create_text_field("Difficulty", 4);
ICON_AI_PLR1 = create_icon(0, 1056);
ICON_AI_PLR2 = create_icon(0, 1056);
ICON_AI_PLR3 = create_icon(0, 1056);
ICON_AI_PLR4 = create_icon(0, 1056);
ICON_AI_PLR5 = create_icon(0, 1056);
ICON_AI_PLR6 = create_icon(0, 1056);


-- misc buttons
BTN_CHECK_IN = create_button("Check in", 3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_START_GAME = create_button("Start Game", 3, BTN_STYLE_DEFAULT3, BTN_STYLE_DEFAULT3_H, BTN_STYLE_DEFAULT3_HP);
BTN_OM_PLAYERS = create_button("Players", 3, BTN_STYLE_DEFAULT3, BTN_STYLE_DEFAULT3_H, BTN_STYLE_DEFAULT3_HP);
BTN_OM_SETTINGS = create_button("Settings", 3, BTN_STYLE_DEFAULT3, BTN_STYLE_DEFAULT3_H, BTN_STYLE_DEFAULT3_HP);
BTN_OM_AI = create_button("Computer", 3, BTN_STYLE_DEFAULT3, BTN_STYLE_DEFAULT3_H, BTN_STYLE_DEFAULT3_HP);

-- menus
MENU_CHECK_IN = create_menu("Check Phase", BTN_STYLE_GRAY);

local AI_DIFFICULTY_STR_TABLE = {"Easy", "Normal", "Hard", "Honour"};

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
      p_num = 0;
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
      Difficulty = GAME_LOBBY_SETTINGS[GLS_COMPUTER_DIFFICULTY][p_num][1]
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
  
  set_button_function(BTN_CHECK_IN, 
  function(button)
    if (not i_am_checked_in()) then
      if (am_i_in_network_game() ~= 0) then
        check_myself_in();
      else
        update_network_players_count(G_NSI.PlayerNum);
        
        close_menu(MENU_CHECK_IN);
        set_button_inactive(BTN_CHECK_IN);
        
        
        open_menu(MENU_PLAYERS);
        --open_menu(MENU_OPTIONS);
        --open_menu(MENU_AI);
         
        local b_data = get_button_pos_and_dimensions(BTN_START_GAME);
        set_button_position(BTN_START_GAME, (ScreenWidth() >> 1) - (b_data[3] >> 1), (ScreenHeight() - 96));
        
        local middle_x = (ScreenWidth() >> 1);
        local b_data = get_button_pos_and_dimensions(BTN_OM_PLAYERS);
        set_button_position(BTN_OM_PLAYERS, middle_x - (b_data[3] >> 1) - 128, (ScreenHeight() - 200));
        local b_data = get_button_pos_and_dimensions(BTN_OM_SETTINGS);
        set_button_position(BTN_OM_SETTINGS, middle_x - (b_data[3] >> 1), (ScreenHeight() - 200));
        local b_data = get_button_pos_and_dimensions(BTN_OM_AI);
        set_button_position(BTN_OM_AI, middle_x - (b_data[3] >> 1) + 128, (ScreenHeight() - 200));
        
        set_button_active(BTN_START_GAME);
        set_button_active(BTN_OM_PLAYERS);
        set_button_active(BTN_OM_SETTINGS);
        set_button_active(BTN_OM_AI);
      end
    end
  end);
  
  -- start game button
  set_button_function(BTN_START_GAME,
  function(b)
    -- first check player setup indexes to see if there are duplicates
    local found_duplicate = false;
    local setup_ptr = GAME_LOBBY_SETTINGS[GLS_PLAYER_SETUP_IDX];
    local compare_t = {false, false, false, false, false, false, false, false};
    for i = 0, #setup_ptr do
      if (compare_t[setup_ptr[i][1]] == false) then
        compare_t[setup_ptr[i][1]] = true;
      else
        found_duplicate = true;
        break;
      end
    end
    
    if (not found_duplicate) then
      if (am_i_in_network_game() ~= 0) then
        if (i_am_game_master()) then
          Send(PACKET_START_GAME, "0");
          set_button_inactive(BTN_START_GAME);
        end
      else
        GAME_STARTED = true;
        
        set_all_elements_inactive();
        close_all_menus();
      end
    end
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
    local split_pos = (ScreenWidth() >> 1);
    set_menu_position(MENU_PLAYERS, split_pos - (menu.Size[1] >> 1), (ScreenHeight() >> 1) - (menu.Size[2] >> 1));
    
    set_text_field_position(TXT_FIELD_TRIBE, menu.Pos[1] + 40, menu.Pos[2]);
    set_text_field_position(TXT_FIELD_PLR_NAME, menu.Pos[1] + 110, menu.Pos[2]);
    set_text_field_position(TXT_FIELD_START_POS, menu.Pos[1] + 192, menu.Pos[2]);
    set_text_field_active(TXT_FIELD_TRIBE);
    set_text_field_active(TXT_FIELD_PLR_NAME);
    set_text_field_active(TXT_FIELD_START_POS);
    for i = 1, 8 do
      local b_data = get_button_pos_and_dimensions(BTN_PLR1_POS + (i - 1));
      set_array_button_position(BTN_PLR1_POS + (i - 1), menu.Pos[1] + (menu.Size[1] - 68), menu.Pos[2] + 24 + ((i - 1) * 28));
      if (HUMAN_CHECK_IN[i - 1] or i < 3) then
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
  
    set_text_field_position(TXT_FIELD_AI_TRIBE, menu.Pos[1] + 40, menu.Pos[2]);
    set_text_field_position(TXT_FIELD_AI_DIFFICULTY, menu.Pos[1] + 160, menu.Pos[2]);
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
    if (is_menu_open(MENU_PLAYERS)) then
      local m_data = get_menu_pos_and_dimensions(MENU_PLAYERS);
      set_array_button_position(BTN_PLR1_POS + pn, m_data[1] + (m_data[3] - 68), m_data[2] + 24 + ((pn * 28)));
      set_button_active(BTN_PLR1_POS + pn);
      set_text_field_text(TXT_PLR1_NAME + pn, get_player_name(pn, ntb(am_i_in_network_game())));
      set_text_field_position(TXT_PLR1_NAME + pn, m_data[1] + 110, m_data[2] + 24 + (pn * 28));
      set_text_field_active(TXT_PLR1_NAME + pn);
      set_icon_position(ICON_PLR1 + pn, m_data[1] + 40, m_data[2] + 18 + (pn * 28));
      set_icon_active(ICON_PLR1 + pn);
    end
    
    if (pn == G_NSI.PlayerNum) then
      close_menu(MENU_CHECK_IN);
      set_button_inactive(BTN_CHECK_IN);
      
      
      open_menu(MENU_PLAYERS);
      --open_menu(MENU_OPTIONS);
      --open_menu(MENU_AI);
       
      local b_data = get_button_pos_and_dimensions(BTN_START_GAME);
      set_button_position(BTN_START_GAME, (ScreenWidth() >> 1) - (b_data[3] >> 1), (ScreenHeight() - 96));
      
      local middle_x = (ScreenWidth() >> 1);
      local b_data = get_button_pos_and_dimensions(BTN_OM_PLAYERS);
      set_button_position(BTN_OM_PLAYERS, middle_x - (b_data[3] >> 1) - 128, (ScreenHeight() - 200));
      local b_data = get_button_pos_and_dimensions(BTN_OM_SETTINGS);
      set_button_position(BTN_OM_SETTINGS, middle_x - (b_data[3] >> 1), (ScreenHeight() - 200));
      local b_data = get_button_pos_and_dimensions(BTN_OM_AI);
      set_button_position(BTN_OM_AI, middle_x - (b_data[3] >> 1) + 128, (ScreenHeight() - 200));
      
      set_button_active(BTN_START_GAME);
      set_button_active(BTN_OM_PLAYERS);
      set_button_active(BTN_OM_SETTINGS);
      set_button_active(BTN_OM_AI);
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
    
    close_all_menus();
    set_all_elements_inactive();
  end
end