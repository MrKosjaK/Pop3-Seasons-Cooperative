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
ICON_PLR1 = create_icon(0, 887);
ICON_PLR2 = create_icon(0, 914);
ICON_PLR3 = create_icon(0, 941);
ICON_PLR4 = create_icon(0, 968);
ICON_PLR5 = create_icon(0, 1623);
ICON_PLR6 = create_icon(0, 1650);
ICON_PLR7 = create_icon(0, 1677);
ICON_PLR8 = create_icon(0, 1704);
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



HUMAN_COUNT = 0;
AI_COUNT = 0;

-- global check in
GAME_MASTER_ID = -1;
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

function spawn_players_initial_stuff());
  for i = 1, #HUMAN_PLAYERS do
    local p_num = HUMAN_PLAYERS[i];
    local h_data = HUMAN_INFO[i];
    
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
  
  HUMAN_PLAYERS[#HUMAN_PLAYERS + 1] = p_num;
  HUMAN_PLAYERS_COUNT = HUMAN_PLAYERS_COUNT + 1;
end

function get_info_on_players_count()
  if (HUMAN_PLAYERS_COUNT > HUMAN_COUNT) then
    log(string.format("Amount of players exceed defined amount in level. Defined %i, actual %i", HUMAN_COUNT, HUMAN_PLAYERS_COUNT));
  end
end