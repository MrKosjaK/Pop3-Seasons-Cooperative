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

-- ai buttons
BTN_AI_DIFFICULTY = create_button_array({"Beginner", "Moderate", "Honour"}, 3, 3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);

-- misc buttons
BTN_CHECK_IN = create_button("Check in", 3, BTN_STYLE_DEFAULT2, BTN_STYLE_DEFAULT2_H, BTN_STYLE_DEFAULT2_HP);
BTN_START_GAME = create_button("Start Game", 3, BTN_STYLE_DEFAULT3, BTN_STYLE_DEFAULT3_H, BTN_STYLE_DEFAULT3_HP);

-- menus
MENU_CHECK_IN = create_menu("Check Phase", BTN_STYLE_GRAY);

MENU_OPTIONS = create_menu("Game Options", BTN_STYLE_GRAY);
MENU_AI = create_menu("AI Settings", BTN_STYLE_GRAY);

GAME_STARTED = false;
HUMAN_COUNT = 0;
AI_COUNT = 0;

-- global check in
GAME_MASTER_ID = -1;
HUMAN_CHECK_IN = {[0] = false, false, false, false, false, false, false, false};
HUMAN_PLAYERS = {};
HUMAN_PLAYERS_COUNT = 0;

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
    Send(256, tostring(G_NSI.PlayerNum));
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
    local b_data = get_button_ptr(BTN_PLR1_POS + p_num);
    local h_data = HUMAN_INFO[b_data.CurrData];
    
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
    
    -- TEST AI STUFF

    STATE_SET(p_num, TRUE, CP_AT_TYPE_CONSTRUCT_BUILDING);
    STATE_SET(p_num, TRUE, CP_AT_TYPE_AUTO_ATTACK);
    STATE_SET(p_num, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
    SET_ATTACK_VARIABLE(p_num, 0);
    WRITE_CP_ATTRIB(p_num, ATTR_MAX_BUILDINGS_ON_GO, 3);
    WRITE_CP_ATTRIB(p_num, ATTR_HOUSE_PERCENTAGE, 30);
    WRITE_CP_ATTRIB(p_num, ATTR_PREF_WARRIOR_TRAINS, 1);
    WRITE_CP_ATTRIB(p_num, ATTR_PREF_WARRIOR_PEOPLE, 0);
    WRITE_CP_ATTRIB(p_num, ATTR_MAX_TRAIN_AT_ONCE, 4);
    WRITE_CP_ATTRIB(p_num, ATTR_MAX_ATTACKS, 3);
    WRITE_CP_ATTRIB(p_num, ATTR_ATTACK_PERCENTAGE, 100);
    WRITE_CP_ATTRIB(p_num, ATTR_MAX_DEFENSIVE_ACTIONS, 0);
    WRITE_CP_ATTRIB(p_num, ATTR_RETREAT_VALUE, 0);
    WRITE_CP_ATTRIB(p_num, ATTR_BASE_UNDER_ATTACK_RETREAT, 0);

    WRITE_CP_ATTRIB(p_num, ATTR_EXPANSION, 28);
    WRITE_CP_ATTRIB(p_num, ATTR_SHAMEN_BLAST, 16);
    WRITE_CP_ATTRIB(p_num, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
    STATE_SET(p_num, TRUE, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
    STATE_SET(p_num, TRUE, CP_AT_TYPE_FETCH_WOOD);
    STATE_SET(p_num, TRUE, CP_AT_TYPE_BRING_NEW_PEOPLE_BACK);
    STATE_SET(p_num, TRUE, CP_AT_TYPE_POPULATE_DRUM_TOWER);

    SET_BUCKET_USAGE(p_num, TRUE);
    SET_BUCKET_COUNT_FOR_SPELL(p_num, M_SPELL_CONVERT_WILD, 1);
    SET_BUCKET_COUNT_FOR_SPELL(p_num, M_SPELL_BLAST, 1);
    SET_BUCKET_COUNT_FOR_SPELL(p_num, M_SPELL_INSECT_PLAGUE, 8);
    
    local map_xz = coord3d_to_map_xz(ai_data._start_pos);
    SET_DRUM_TOWER_POS(p_num, map_xz.XZ.X, map_xz.XZ.Z);
    SHAMAN_DEFEND(p_num, map_xz.XZ.X, map_xz.XZ.Z, TRUE);
    SET_DEFENCE_RADIUS(p_num, 5);
  end
end

function update_network_players_count(p_num)
  --log("test");
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
      
      set_all_elements_inactive();
      close_all_menus();
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
end

function process_game_lobby_packets(pn, p_type, data)
  if (packet_type == 256) then
    update_network_players_count(tonumber(data));
  end
  
  -- buttons packets
  if (p_type == PACKET_BTN_ARRAY_DEC) then
    local b = get_button_ptr(tonumber(data));
    b.CurrData = math.min(math.max(b.CurrData - 1, 1), b.MaxData);
  end
  
  if (p_type == PACKET_BTN_ARRAY_INCR) then
    local b = get_button_ptr(tonumber(data));
    b.CurrData = math.min(math.max(b.CurrData + 1, 1), b.MaxData);
  end
  
  if (p_type == PACKET_START_GAME) then
    GAME_STARTED = true;
    
    close_all_menus();
    set_all_elements_inactive();
  end
end