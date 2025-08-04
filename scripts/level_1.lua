include("common.lua");
include("searcharea.lua");
include("ai_shaman.lua");
include("lvl1_ai_func.lua");


--include("pop_helper.lua");
--include("weather.lua");

-- level 1 specific stuff
set_level_human_count(2);
set_level_computer_count(2);

add_human_player_start_info(0, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_HYPNOTISM, M_SPELL_LIGHTNING_BOLT}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN, M_BUILDING_WARRIOR_TRAIN});
add_human_player_start_info(1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(2, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_HYPNOTISM, M_SPELL_LIGHTNING_BOLT, M_SPELL_WHIRLWIND, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(3, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_HYPNOTISM, M_SPELL_LIGHTNING_BOLT, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});


AI_PLR1_TRIBE = -1;
AI_PLR1_DIFF = AI_EASY;
AI_PLR2_TRIBE = -1;
AI_PLR2_DIFF = AI_EASY;

-- triggers at turn 0, at that point client's resolution is set to correct one instead of 640x480.
function OnInit()
  --start_weather(WEATHER_SNOW, 750, 75, 35, 60*10) -- type, amount, ~per_second_spawn, speed, duration_seconds
end

-- triggers after GAME MASTER starts game.
function OnGameStart()
  process_all_ai_info(function(ai)
    set_player_check_surround_slopes(G_PLR[ai.Owner], FALSE);
    reduce_computer_players_sprogging_time_by_percent(G_PLR[ai.Owner], 0 + ((ai.Difficulty - 1) * 15));
    spawn_computer_addons(ai.Owner, ai.Difficulty);
    register_ai_events(ai.Owner, ai.Difficulty);
  end);
  
  AI_PLR1_TRIBE = get_ai_player_info(1).Owner;
  AI_PLR1_DIFF = get_ai_player_info(1).Difficulty;
  AI_PLR2_TRIBE = get_ai_player_info(2).Owner;
  AI_PLR2_DIFF = get_ai_player_info(2).Difficulty;
  
  set_players_allied(AI_PLR1_TRIBE, AI_PLR2_TRIBE);
  set_players_allied(AI_PLR2_TRIBE, AI_PLR1_TRIBE);
  
  -- ai player 1 stuff
  ai_main_drum_tower_info(AI_PLR1_TRIBE, true, 122, 66);
  ai_set_shaman_info(AI_PLR1_TRIBE, 168, 74, true, 56 - ((AI_PLR1_DIFF - 1) * 16), 16);
  ai_set_converting_info(AI_PLR1_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR1_TRIBE, true, true, true, true, 1, 3, 1);
  ai_set_fetch_info(AI_PLR1_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR1_TRIBE, true, 1, 30 - ((AI_PLR1_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR1_TRIBE, true, 15 + (AI_PLR1_DIFF * 25), 2 + ((AI_PLR1_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR1_TRIBE, 1, 0, 1, 0);
  ai_set_training_people(AI_PLR1_TRIBE, true, 10, 0, 12, 0, 0 + AI_PLR1_DIFF);
  ai_set_populating_info(AI_PLR1_TRIBE, true, true);
  ai_set_defence_rad(AI_PLR1_TRIBE, 7);
  
  PLR1_SH = register_shaman_ai(AI_PLR1_TRIBE);
  PLR2_SH = register_shaman_ai(AI_PLR2_TRIBE);
  
  if (AI_PLR1_DIFF == AI_EASY) then
    ai_set_marker_entry(AI_PLR1_TRIBE, 0, 44, -1, 0, 1, 2, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 1, 45, -1, 0, 2, 1, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 2, 46, 47, 0, 1, 3, 0);
    
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 32);
    
    PLR1_SH:set_casting_delay(256);
  end
  
  if (AI_PLR1_DIFF == AI_MEDIUM) then
    ai_set_marker_entry(AI_PLR1_TRIBE, 0, 54, 55, 0, 4, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 1, 39, -1, 0, 2, 2, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 2, 56, 57, 0, 3, 3, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 3, 46, 47, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 4, 58, 59, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 5, 60, 61, 0, 0, 4, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 1);
    ai_set_spell_entry(AI_PLR1_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 5, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 5, 1);
    
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 16);
    ai_attr_w(AI_PLR1_TRIBE, ATTR_MAX_ATTACKS, 5);
    ai_set_targets(AI_PLR1_TRIBE, 0, true, false, true); -- this will by dynamically changed in actual attacks
    
    PLR1_SH:set_casting_delay(64);
    PLR1_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 7, 8}, 3, SPELL_COST(M_SPELL_WHIRLWIND));
  end
  
  if (AI_PLR1_DIFF == AI_HARD) then
    ai_set_marker_entry(AI_PLR1_TRIBE, 0, 54, 55, 0, 4, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 1, 39, -1, 0, 2, 2, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 2, 56, 57, 0, 3, 3, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 3, 46, 47, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 4, 58, 59, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 5, 60, 61, 0, 0, 4, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 1);
    ai_set_spell_entry(AI_PLR1_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 1);
    ai_set_state(AI_PLR1_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR1_TRIBE, ATTR_MAX_ATTACKS, 8);
    ai_set_targets(AI_PLR1_TRIBE, 0, true, true, true); -- this will by dynamically changed in actual attacks
    PLR1_SH:set_casting_delay(32);
    PLR1_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 7, 8}, 3, SPELL_COST(M_SPELL_WHIRLWIND) >> 1);
  end
  
  if (AI_PLR1_DIFF == AI_EXTREME) then
    ai_set_marker_entry(AI_PLR1_TRIBE, 0, 54, 55, 0, 4, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 1, 39, -1, 0, 2, 2, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 2, 56, 57, 0, 3, 3, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 3, 46, 47, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 4, 58, 59, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 5, 60, 61, 0, 0, 4, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 1);
    ai_set_spell_entry(AI_PLR1_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 1);
    ai_set_state(AI_PLR1_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR1_TRIBE, ATTR_MAX_ATTACKS, 10);
    ai_set_targets(AI_PLR1_TRIBE, 0, true, true, true); -- this will by dynamically changed in actual attacks
    
    PLR1_SH:set_casting_delay(16);
    PLR1_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 7, 8}, 3, SPELL_COST(M_SPELL_WHIRLWIND) >> 2);
  end
  
  -- ai player 2 stuff
  ai_main_drum_tower_info(AI_PLR2_TRIBE, true, 36, 88);
  ai_set_shaman_info(AI_PLR2_TRIBE, 22, 110, true, 56 - ((AI_PLR2_DIFF - 1) * 16), 16);
  ai_set_converting_info(AI_PLR2_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR2_TRIBE, true, true, true, true, 1, 3, 1);
  ai_set_fetch_info(AI_PLR2_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR2_TRIBE, true, 1, 30 - ((AI_PLR2_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR2_TRIBE, true, 20 + (AI_PLR2_DIFF * 25), 2 + ((AI_PLR2_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR2_TRIBE, 1, 0, 1, 0);
  ai_set_training_people(AI_PLR2_TRIBE, true, 10, 0, 12, 0, 0 + AI_PLR2_DIFF);
  ai_set_populating_info(AI_PLR2_TRIBE, true, true);
  ai_set_defence_rad(AI_PLR2_TRIBE, 7);
  
  if (AI_PLR2_DIFF == AI_EASY) then
  
  end
  
  if (AI_PLR2_DIFF == AI_MEDIUM) then
    ai_set_marker_entry(AI_PLR2_TRIBE, 0, 68, 69, 0, 1, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 1, 70, 71, 0, 1, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 2, 72, 73, 0, 2, 1, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 3, 74, 75, 0, 2, 3, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 1, 1);
    ai_set_spell_entry(AI_PLR2_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 4, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 4, 1);
    
    ai_attr_w(AI_PLR2_TRIBE, ATTR_SHAMEN_BLAST, 16);
    ai_attr_w(AI_PLR2_TRIBE, ATTR_MAX_ATTACKS, 5);
    ai_set_targets(AI_PLR2_TRIBE, 0, true, false, true); -- this will by dynamically changed in actual attacks
    
    PLR2_SH:set_casting_delay(64);
    PLR2_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 7, 8}, 3, SPELL_COST(M_SPELL_WHIRLWIND));
  end
  
  if (AI_PLR2_DIFF == AI_HARD) then
    ai_set_marker_entry(AI_PLR2_TRIBE, 0, 68, 69, 0, 1, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 1, 70, 71, 0, 1, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 2, 72, 73, 0, 2, 1, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 3, 74, 75, 0, 2, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 4, 76, 77, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 5, 78, 79, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 6, 80, 81, 0, 3, 2, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 7, 82, 83, 0, 3, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 1);
    ai_set_spell_entry(AI_PLR2_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 1);
    ai_set_state(AI_PLR2_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR2_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR2_TRIBE, ATTR_MAX_ATTACKS, 8);
    ai_set_targets(AI_PLR2_TRIBE, 0, true, true, true); -- this will by dynamically changed in actual attacks
    
    PLR2_SH:set_casting_delay(32);
    PLR2_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 7, 8}, 3, SPELL_COST(M_SPELL_WHIRLWIND) >> 1);
  end
  
  if (AI_PLR2_DIFF == AI_EXTREME) then
    ai_set_marker_entry(AI_PLR2_TRIBE, 0, 68, 69, 0, 1, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 1, 70, 71, 0, 1, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 2, 72, 73, 0, 2, 1, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 3, 74, 75, 0, 2, 3, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 4, 76, 77, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 5, 78, 79, 0, 0, 4, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 6, 80, 81, 0, 3, 2, 0);
    ai_set_marker_entry(AI_PLR2_TRIBE, 7, 82, 83, 0, 3, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 1);
    ai_set_spell_entry(AI_PLR2_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 1);
    ai_set_state(AI_PLR2_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR2_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR2_TRIBE, ATTR_MAX_ATTACKS, 10);
    ai_set_targets(AI_PLR2_TRIBE, 0, true, true, true); -- this will by dynamically changed in actual attacks
    
    PLR2_SH:set_casting_delay(16);
    PLR2_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 7, 8}, 3, SPELL_COST(M_SPELL_WHIRLWIND) >> 2);
  end
end

function ScrOnLevelInit(level_id)
  --calculate_population_scores();
end

function ScrOnTurn()
  process_ai_events();
  
  local sTurn = get_script_turn();
  
  if (sTurn == 72) then
    PLR1_SH:toggle_converting_wilds(true);
    PLR2_SH:toggle_converting_wilds(true);
    footer_add_msg("As such the other tribes did everything they could to undermine the Ikani, they attacked the bases already established, they even attacked at the Ikani's home system.");
  end
end

function ScrOnCreateThing(t_thing)
  
end

function ScrOnFrame(w, h, guiW)
  --draw_population_scores();
end