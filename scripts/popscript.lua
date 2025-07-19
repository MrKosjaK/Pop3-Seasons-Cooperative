-- This file will contain all of PopScript helper functions
-- To help with easier writing.


function ai_shaman_available(pn)
  return (IS_SHAMAN_AVAILABLE_FOR_ATTACK(pn) ~= 0);
end

ai_attr_w = WRITE_CP_ATTRIB;
ai_attr_r = READ_CP_ATTRIB;
ai_setv = SET_USER_VARIABLE_VALUE;
ai_getv = GET_USER_VARIABLE_VALUE;
ai_convert_marker = CONVERT_AT_MARKER;
ai_set_marker_entry = SET_MARKER_ENTRY;
ai_set_spell_entry = SET_SPELL_ENTRY;
ai_enable_buckets = SET_BUCKET_USAGE;
ai_set_spell_bucket_count = SET_BUCKET_COUNT_FOR_SPELL;
ai_set_atk_var = SET_ATTACK_VARIABLE;
ai_do_marker_entries = MARKER_ENTRIES;
ai_do_attack = ATTACK;
ai_fix_wilds = FIX_WILD_IN_AREA;
ai_build_tower = BUILD_DRUM_TOWER;
ai_set_defence_rad = SET_DEFENCE_RADIUS;
ai_set_state = STATE_SET;

function ai_set_targets(pn, opponent, a, b, c)
  TARGET_PLAYER_DT_AND_S(pn, opponent);
  if (a) then TARGET_DRUM_TOWERS(pn); else DONT_TARGET_DRUM_TOWERS(pn); end
  if (b) then TARGET_S_WARRIORS(pn); else DONT_TARGET_S_WARRIORS(pn); end
  if (c) then TARGET_SHAMAN(pn); else DONT_TARGET_SHAMAN(pn); end
end

function ai_set_aways(pn, a, b, c, d, e)
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_BRAVE, a);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_WARRIOR, b);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_RELIGIOUS, c);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_SUPER_WARRIOR, d);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_SPY, e);
end

-- PARAMS
-- @bool (true/false) away shaman?
function ai_set_shaman_away(pn, a)
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_MEDICINE_MAN, a and 1 or 0);
end

-- PARAMS:
-- @bool (true/false) should ai build at all?
-- @int (number value) house percentage
-- @int (number value) max bldgs on go
function ai_set_bldg_info(pn, a, b, c)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_CONSTRUCT_BUILDING);
  WRITE_CP_ATTRIB(pn, ATTR_HOUSE_PERCENTAGE, b);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_BUILDINGS_ON_GO, c);
end

function ai_set_training_huts(pn, a, b, c, d)
  WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_TRAINS, a);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_RELIGIOUS_TRAINS, b);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_TRAINS, c);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SPY_TRAINS, d);
end

function ai_set_training_people(pn, a, b, c, d, e, f)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_TRAIN_PEOPLE);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_PEOPLE, b);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_RELIGIOUS_PEOPLE, c);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_PEOPLE, d);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SPY_PEOPLE, e);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_TRAIN_AT_ONCE, f);
end

function ai_set_attack_info(pn, a, b, c, d)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_AUTO_ATTACK);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_ATTACKS, b);
  WRITE_CP_ATTRIB(pn, ATTR_RETREAT_VALUE, c);
  WRITE_CP_ATTRIB(pn, ATTR_FIGHT_STOP_DISTANCE, d);
end

function ai_set_vehicle_info(pn, a, b, c, d, e)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_BUILD_VEHICLE);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_HUTS, b);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_DRIVERS, c);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_HUTS, d);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_DRIVERS, e);
end

function ai_set_fetch_info(pn, a, b, c, d)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_FETCH_LOST_PEOPLE);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_FETCH_LOST_VEHICLE);
  STATE_SET(pn, c and 1 or 0, CP_AT_TYPE_FETCH_FAR_VEHICLE);
  STATE_SET(pn, d and 1 or 0, CP_AT_TYPE_FETCH_WOOD);
end

function ai_set_defensive_info(pn, a, b, c, d, e, f, g)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_DEFEND);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_DEFEND_BASE);
  STATE_SET(pn, c and 1 or 0, CP_AT_TYPE_SUPER_DEFEND);
  STATE_SET(pn, d and 1 or 0, CP_AT_TYPE_PREACH);
  WRITE_CP_ATTRIB(pn, ATTR_DEFENSE_RAD_INCR, e);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_DEFENSIVE_ACTIONS, f);
  WRITE_CP_ATTRIB(pn, ATTR_USE_PREACHER_FOR_DEFENCE, g);
end

function ai_set_converting_info(pn, a, b, c)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_BRING_NEW_PEOPLE_BACK);
  WRITE_CP_ATTRIB(pn, ATTR_EXPANSION, c);
end

function ai_set_spy_info(pn, a, b, c, d, e)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_SABOTAGE);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_SPY_ATTACKS, b);
  WRITE_CP_ATTRIB(pn, ATTR_SPY_DISCOVER_CHANCE, c);
  WRITE_CP_ATTRIB(pn, ATTR_SPY_CHECK_FREQUENCY, d);
  WRITE_CP_ATTRIB(pn, ATTR_ENEMY_SPY_MAX_STAND, e);
end

function ai_set_shaman_info(pn, x, z, a, b, c)
  SHAMAN_DEFEND(pn, x, z, a and 1 or 0);
  WRITE_CP_ATTRIB(pn, ATTR_SHAMEN_BLAST, b);
  WRITE_CP_ATTRIB(pn, ATTR_SPELL_DELAY, c);
end

function ai_set_attack_flags(pn, a, b, c)
  WRITE_CP_ATTRIB(pn, ATTR_GROUP_OPTION, a);
  WRITE_CP_ATTRIB(pn, ATTR_DONT_GROUP_AT_DT, b);
  WRITE_CP_ATTRIB(pn, ATTR_DONT_USE_BOATS, c);
end

function ai_set_populating_info(pn, a, b)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_POPULATE_DRUM_TOWER);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_HOUSE_A_PERSON);
end

function ai_main_drum_tower_info(pn, a, x, z)
  if (a) then
    DELAY_MAIN_DRUM_TOWER(FALSE, pn);
    SET_DRUM_TOWER_POS(pn, x, z);
  else
    DELAY_MAIN_DRUM_TOWER(TRUE, pn);
  end
end