-- game lobby stuff

HUMAN_COUNT = 0;
AI_COUNT = 0;
HUMAN_START_POSITIONS = {};
AI_START_POSITIONS = {};

-- global check in
HUMAN_PLAYERS = {};
HUMAN_PLAYERS_COUNT = 0;

-- local check in
local I_AM_NOT_CHECKED_IN = true;

function i_am_checked_in()
  return (I_AM_NOT_CHECKED_IN == false);
end

function check_myself_in()
  if (I_AM_NOT_CHECKED_IN) then
    log("checking in");
    Send(256, tostring(G_NSI.PlayerNum));
    I_AM_NOT_CHECKED_IN = false;
  end
end

function set_level_human_count(n)
  HUMAN_COUNT = n;
end

function set_level_computer_count(n)
  AI_COUNT = n;
end

function add_level_human_start_pos(marker_idx)
  HUMAN_START_POSITIONS[#HUMAN_START_POSITIONS + 1] = marker_to_coord3d(marker_idx);
  centre_coord3d_on_block(HUMAN_START_POSITIONS[#HUMAN_START_POSITIONS]);
end

function add_level_computer_start_pos(marker_idx)
  AI_START_POSITIONS[#AI_START_POSITIONS + 1] = marker_to_coord3d(marker_idx);
end

function spawn_players_initial_stuff()
  --log("spawn 2");
  for i = 1, #HUMAN_PLAYERS do
    --log("spawn 1");
    local p_num = HUMAN_PLAYERS[i];
    --log("Player num: " .. p_num);
    createThing(T_PERSON, M_PERSON_MEDICINE_MAN, p_num, HUMAN_START_POSITIONS[i], false, false);
    
    G_PLR[p_num].PlayerType = HUMAN_PLAYER;
    G_PLR[p_num].DeadCount = 0;
    set_player_reinc_site_on(G_PLR[p_num]);
    G_PLR[p_num].ReincarnSiteCoord.Xpos = HUMAN_START_POSITIONS[i].Xpos;
    G_PLR[p_num].ReincarnSiteCoord.Zpos = HUMAN_START_POSITIONS[i].Zpos;
    mark_reincarnation_site_mes(G_PLR[p_num].ReincarnSiteCoord, p_num, MARK);
    set_players_shaman_initial_command(G_PLR[p_num]);
  end
  
  for i = 1, AI_COUNT do
    local p_num = 0;
    local count = 8;
    
    while (count > 0) do
      count = count - 1;
      --log("Player num: " .. p_num);
      if (G_PLR[p_num].PlayerType == NO_PLAYER) then
        --log("wasnt human controlled");
        break;
      end
      p_num = p_num + 1;
    end
    
    createThing(T_PERSON, M_PERSON_MEDICINE_MAN, p_num, AI_START_POSITIONS[i], false, false);
    
    computer_init_player(G_PLR[p_num]);
    G_PLR[p_num].DeadCount = 0;
    set_player_reinc_site_on(G_PLR[p_num]);
    G_PLR[p_num].ReincarnSiteCoord.Xpos = AI_START_POSITIONS[i].Xpos;
    G_PLR[p_num].ReincarnSiteCoord.Zpos = AI_START_POSITIONS[i].Zpos;
    mark_reincarnation_site_mes(G_PLR[p_num].ReincarnSiteCoord, p_num, MARK);
    set_players_shaman_initial_command(G_PLR[p_num]);
    
    -- TEST AI STUFF
    set_player_can_build(M_BUILDING_TEPEE, p_num);
    set_player_can_build(M_BUILDING_DRUM_TOWER, p_num);
    set_player_can_build(M_BUILDING_WARRIOR_TRAIN, p_num)
    set_player_can_build(M_BUILDING_SUPER_TRAIN, p_num);

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
    set_player_can_cast(M_SPELL_INSECT_PLAGUE, p_num);
    set_player_can_cast(M_SPELL_CONVERT_WILD, p_num);

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
    
    local map_xz = coord3d_to_map_xz(AI_START_POSITIONS[i]);
    SET_DRUM_TOWER_POS(p_num, map_xz.XZ.X, map_xz.XZ.Z);
    SHAMAN_DEFEND(p_num, map_xz.XZ.X, map_xz.XZ.Z, TRUE);
    SET_DEFENCE_RADIUS(p_num, 5);
  end
end

function update_network_players_count(p_num)
  log("test");
  HUMAN_PLAYERS[#HUMAN_PLAYERS + 1] = p_num;
  HUMAN_PLAYERS_COUNT = HUMAN_PLAYERS_COUNT + 1;
  log(string.format("Registered player num: %i", p_num));
end

function get_info_on_players_count()
  -- for i = 0, 7 do
    -- log(string.format("%i", G_PLR[i].PlayerActive));
    -- if (G_PLR[i].PlayerType == HUMAN_PLAYER) then
      -- HUMAN_PLAYERS[#HUMAN_PLAYERS + 1] = i;
      -- HUMAN_PLAYERS_COUNT = HUMAN_PLAYERS_COUNT + 1;
    -- end
  -- end
  
  if (HUMAN_PLAYERS_COUNT > HUMAN_COUNT) then
    log(string.format("Amount of players exceed defined amount in level. Defined %i, actual %i", HUMAN_COUNT, HUMAN_PLAYERS_COUNT));
  end
end