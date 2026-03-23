include("common.lua");
include("searcharea.lua");
include("ai_shaman.lua");
include("lvl3_ai_func.lua");


--include("pop_helper.lua");
--include("weather.lua");

-- level 1 specific stuff
set_level_human_count(2);
set_level_computer_count(4);

add_human_player_start_info(0, 
  {
    M_SPELL_BLAST,
    M_SPELL_CONVERT_WILD, 
    M_SPELL_INSECT_PLAGUE, 
    M_SPELL_HYPNOTISM, 
    M_SPELL_LIGHTNING_BOLT,
    M_SPELL_LAND_BRIDGE,
    M_SPELL_WHIRLWIND,
    M_SPELL_EARTHQUAKE
  }, 
  {
    M_BUILDING_TEPEE,
    M_BUILDING_DRUM_TOWER,
    M_BUILDING_SUPER_TRAIN,
    M_BUILDING_SPY_TRAIN
  });
    
add_human_player_start_info(1, 
  {
    M_SPELL_BLAST, 
    M_SPELL_CONVERT_WILD, 
    M_SPELL_INSECT_PLAGUE, 
    M_SPELL_INVISIBILITY,
    M_SPELL_SHIELD,
    M_SPELL_HYPNOTISM,
    M_SPELL_LAND_BRIDGE,
    M_SPELL_GHOST_ARMY
  }, 
  {
    M_BUILDING_TEPEE, 
    M_BUILDING_DRUM_TOWER, 
    M_BUILDING_SUPER_TRAIN,
    M_BUILDING_WARRIOR_TRAIN,
    M_BUILDING_TEMPLE,
    M_BUILDING_AIRSHIP_HUT_1
  });
    
-- ai player 1
add_ai_player_start_info(2, -1, 
  {
    M_SPELL_BLAST, 
    M_SPELL_CONVERT_WILD, 
    M_SPELL_HYPNOTISM, 
    M_SPELL_LIGHTNING_BOLT,
    M_SPELL_LAND_BRIDGE,
    M_SPELL_SHIELD, 
    M_SPELL_INSECT_PLAGUE,
    M_SPELL_SWAMP
  }, 
  {
    M_BUILDING_TEPEE, 
    M_BUILDING_DRUM_TOWER, 
    M_BUILDING_WARRIOR_TRAIN, 
    M_BUILDING_SUPER_TRAIN,
    M_BUILDING_AIRSHIP_HUT_1
  });

-- ai player 2
add_ai_player_start_info(3, TRIBE_BLACK, 
  {
    M_SPELL_BLAST, 
    M_SPELL_CONVERT_WILD, 
    M_SPELL_INSECT_PLAGUE, 
    M_SPELL_LIGHTNING_BOLT,
    M_SPELL_WHIRLWIND,
    M_SPELL_GHOST_ARMY,
    M_SPELL_EARTHQUAKE,
    M_SPELL_FIRESTORM,
    M_SPELL_INVISIBILITY
  }, 
  {
    M_BUILDING_TEPEE, 
    M_BUILDING_DRUM_TOWER,
    M_BUILDING_SPY_TRAIN,
    M_BUILDING_SUPER_TRAIN
  });
  
-- ai player 3
add_ai_player_start_info(4, -1, 
  {
    M_SPELL_BLAST, 
    M_SPELL_CONVERT_WILD, 
    M_SPELL_INSECT_PLAGUE, 
    M_SPELL_HYPNOTISM,
    M_SPELL_SWAMP,
    M_SPELL_EROSION,
    M_SPELL_EARTHQUAKE,
    M_SPELL_LAND_BRIDGE,
    M_SPELL_VOLCANO,
    M_SPELL_GHOST_ARMY
  }, 
  {
    M_BUILDING_TEPEE, 
    M_BUILDING_DRUM_TOWER, 
    M_BUILDING_WARRIOR_TRAIN, 
    M_BUILDING_SUPER_TRAIN,
    M_BUILDING_TEMPLE
  });
  
-- ai player 4
add_ai_player_start_info(5, TRIBE_ORANGE, 
  {
    M_SPELL_BLAST, 
    M_SPELL_CONVERT_WILD, 
    M_SPELL_INSECT_PLAGUE, 
    M_SPELL_HYPNOTISM, 
    M_SPELL_SHIELD,
    M_SPELL_INVISIBILITY,
    M_SPELL_SWAMP,
    M_SPELL_LAND_BRIDGE,
    M_SPELL_EROSION
  }, 
  {
    M_BUILDING_TEPEE, 
    M_BUILDING_DRUM_TOWER, 
    M_BUILDING_TEMPLE, 
    M_BUILDING_SUPER_TRAIN,
    M_BUILDING_AIRSHIP_HUT_1
  });

AI_PLR1_TRIBE = -1;
AI_PLR2_TRIBE = -1;
AI_PLR3_TRIBE = -1;
AI_PLR4_TRIBE = -1;
AI_PLR1_DIFF = AI_EASY;
AI_PLR2_DIFF = AI_EASY;
AI_PLR3_DIFF = AI_EASY;
AI_PLR4_DIFF = AI_EASY;

-- triggers at turn 0, at that point client's resolution is set to correct one instead of 640x480.
function OnInit()
  --start_weather(WEATHER_SNOW, 750, 75, 35, 60*10) -- type, amount, ~per_second_spawn, speed, duration_seconds
end

-- triggers after GAME MASTER starts game.
function OnGameStart()
  footer_add_msg("Disclaimer: This is unfinished project and it's purpose is to demonstrate fraction of it's features planned for future release.");

  process_all_ai_info(function(ai)
    set_player_check_surround_slopes(G_PLR[ai.Owner], FALSE);
    reduce_computer_players_sprogging_time_by_percent(G_PLR[ai.Owner], 0 + ((ai.Difficulty - 1) * 15));
    spawn_computer_addons(ai.Owner, ai.Difficulty);
    register_ai_events(ai.Owner, ai.Difficulty);
  end);
  
  AI_PLR1_TRIBE = get_ai_player_info(1).Owner;
  AI_PLR2_TRIBE = get_ai_player_info(2).Owner;
  AI_PLR3_TRIBE = get_ai_player_info(3).Owner;
  AI_PLR4_TRIBE = get_ai_player_info(4).Owner;
  AI_PLR1_DIFF = get_ai_player_info(1).Difficulty;
  AI_PLR2_DIFF = get_ai_player_info(2).Difficulty;
  AI_PLR3_DIFF = get_ai_player_info(3).Difficulty;
  AI_PLR4_DIFF = get_ai_player_info(4).Difficulty;
  
  set_players_allied_silent(AI_PLR4_TRIBE, AI_PLR2_TRIBE);
  set_players_allied_silent(AI_PLR2_TRIBE, AI_PLR4_TRIBE);

  PLR1_SH = register_shaman_ai(AI_PLR1_TRIBE);
  PLR2_SH = register_shaman_ai(AI_PLR2_TRIBE);
  PLR3_SH = register_shaman_ai(AI_PLR3_TRIBE);
  PLR4_SH = register_shaman_ai(AI_PLR4_TRIBE);
  
  -- ai player 1 stuff
  ai_main_drum_tower_info(AI_PLR1_TRIBE, true, 238, 90);
  ai_set_shaman_info(AI_PLR1_TRIBE, 238, 90, true, 56 - ((AI_PLR1_DIFF - 1) * 16), 16);
  ai_set_converting_info(AI_PLR1_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR1_TRIBE, true, true, true, true, 1, 3, 1);
  ai_set_fetch_info(AI_PLR1_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR1_TRIBE, true, 1, 30 - ((AI_PLR1_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR1_TRIBE, true, 15 + (AI_PLR1_DIFF * 25), 2 + ((AI_PLR1_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR1_TRIBE, 1, 0, 1, 0);
  ai_set_training_people(AI_PLR1_TRIBE, true, 10, 0, 12, 0, 0 + AI_PLR1_DIFF);
  ai_set_populating_info(AI_PLR1_TRIBE, true, true);
  ai_set_defence_rad(AI_PLR1_TRIBE, 7);
  ai_set_spy_info(AI_PLR1_TRIBE, false, 0, 10, 128, 128);
  
  PLR1_SH = register_shaman_ai(AI_PLR1_TRIBE);
  PLR2_SH = register_shaman_ai(AI_PLR2_TRIBE);
  PLR3_SH = register_shaman_ai(AI_PLR3_TRIBE);
  PLR4_SH = register_shaman_ai(AI_PLR4_TRIBE);
  
  if (AI_PLR1_DIFF == AI_EASY) then
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 32);
    
    PLR1_SH:set_casting_delay(512);
  end
  
  if (AI_PLR1_DIFF == AI_MEDIUM) then
    ai_set_spell_entry(AI_PLR1_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 1);
    ai_set_spell_entry(AI_PLR1_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 5, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 5, 1);
    
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 16);
    ai_attr_w(AI_PLR1_TRIBE, ATTR_MAX_ATTACKS, 5);
    ai_set_targets(AI_PLR1_TRIBE, 0, true, false, true); -- this will by dynamically changed in actual attacks
    
    PLR1_SH:set_casting_delay(64);
    PLR1_SH:set_offensive_spell_entry(1, M_SPELL_SWAMP, {1, 2, 3, 5, 6, 7, 8, 15}, 2, SPELL_COST(M_SPELL_SWAMP));
  end
  
  if (AI_PLR1_DIFF == AI_HARD) then
    ai_set_spell_entry(AI_PLR1_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 1);
    ai_set_spell_entry(AI_PLR1_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 1);
    ai_set_state(AI_PLR1_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR1_TRIBE, ATTR_MAX_ATTACKS, 8);
    ai_set_targets(AI_PLR1_TRIBE, 0, true, true, true); -- this will by dynamically changed in actual attacks
    PLR1_SH:set_casting_delay(32);
    PLR1_SH:set_offensive_spell_entry(1, M_SPELL_SWAMP, {1, 2, 3, 5, 6, 7, 8, 15}, 3, SPELL_COST(M_SPELL_SWAMP) >> 1);
  end
  
  if (AI_PLR1_DIFF == AI_EXTREME) then
    ai_set_spell_entry(AI_PLR1_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 1);
    ai_set_spell_entry(AI_PLR1_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 0);
    ai_set_spell_entry(AI_PLR1_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 1);
    ai_set_state(AI_PLR1_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR1_TRIBE, ATTR_MAX_ATTACKS, 10);
    ai_set_targets(AI_PLR1_TRIBE, 0, true, true, true); -- this will by dynamically changed in actual attacks
    
    PLR1_SH:set_casting_delay(16);
    PLR1_SH:set_offensive_spell_entry(1, M_SPELL_SWAMP, {1, 2, 3, 5, 6, 7, 8, 15}, 3, SPELL_COST(M_SPELL_SWAMP) >> 2);
  end
  
  -- ai player 2 stuff
  ai_main_drum_tower_info(AI_PLR2_TRIBE, true, 226, 216);
  ai_set_shaman_info(AI_PLR2_TRIBE, 226, 216, true, 56 - ((AI_PLR2_DIFF - 1) * 16), 16);
  ai_set_converting_info(AI_PLR2_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR2_TRIBE, true, true, true, true, 1, 3, 1);
  ai_set_fetch_info(AI_PLR2_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR2_TRIBE, true, 1, 30 - ((AI_PLR2_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR2_TRIBE, true, 20 + (AI_PLR2_DIFF * 25), 2 + ((AI_PLR2_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR2_TRIBE, 0, 0, 1, 1);
  ai_set_training_people(AI_PLR2_TRIBE, true, 0, 0, 12, 2, 0 + AI_PLR2_DIFF);
  ai_set_populating_info(AI_PLR2_TRIBE, true, true);
  ai_set_defence_rad(AI_PLR2_TRIBE, 7);
  ai_set_spy_info(AI_PLR2_TRIBE, false, 5, 10, 128, 128);
  
  if (AI_PLR2_DIFF == AI_EASY) then
    ai_attr_w(AI_PLR1_TRIBE, ATTR_SHAMEN_BLAST, 32);

    PLR2_SH:set_casting_delay(512);
  end
  
  if (AI_PLR2_DIFF == AI_MEDIUM) then
    ai_set_spell_entry(AI_PLR2_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 1, 1);
    ai_set_spell_entry(AI_PLR2_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 4, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM)), 64, 4, 1);
    
    ai_attr_w(AI_PLR2_TRIBE, ATTR_SHAMEN_BLAST, 16);
    ai_attr_w(AI_PLR2_TRIBE, ATTR_MAX_ATTACKS, 5);
    ai_set_targets(AI_PLR2_TRIBE, 0, true, false, true); -- this will by dynamically changed in actual attacks
    
    PLR2_SH:set_casting_delay(64);
    PLR2_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 5, 6, 7, 8, 15}, 2, SPELL_COST(M_SPELL_WHIRLWIND));
    PLR2_SH:set_offensive_spell_entry(2, M_SPELL_FIRESTORM, {2, 3, 5, 6, 7, 8}, 1, SPELL_COST(M_SPELL_FIRESTORM));
  end
  
  if (AI_PLR2_DIFF == AI_HARD) then
    ai_set_spell_entry(AI_PLR2_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 1);
    ai_set_spell_entry(AI_PLR2_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 1), 64, 4, 1);
    ai_set_state(AI_PLR2_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR2_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR2_TRIBE, ATTR_MAX_ATTACKS, 8);
    ai_set_targets(AI_PLR2_TRIBE, 0, true, true, true); -- this will by dynamically changed in actual attacks
    
    PLR2_SH:set_casting_delay(32);
    PLR2_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 4, 5, 6, 7, 8, 15}, 3, SPELL_COST(M_SPELL_WHIRLWIND) >> 1);
    PLR2_SH:set_offensive_spell_entry(2, M_SPELL_FIRESTORM, {2, 3, 5, 6, 7, 8}, 1, SPELL_COST(M_SPELL_FIRESTORM) >> 1);
  end
  
  if (AI_PLR2_DIFF == AI_EXTREME) then
    ai_set_spell_entry(AI_PLR2_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 1);
    ai_set_spell_entry(AI_PLR2_TRIBE, 2, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 0);
    ai_set_spell_entry(AI_PLR2_TRIBE, 3, M_SPELL_HYPNOTISM, (SPELL_COST(M_SPELL_HYPNOTISM) >> 2), 64, 4, 1);
    ai_set_state(AI_PLR2_TRIBE, TRUE, CP_AT_TYPE_REPAIR_BLDGS);
    
    ai_attr_w(AI_PLR2_TRIBE, ATTR_SHAMEN_BLAST, 8);
    ai_attr_w(AI_PLR2_TRIBE, ATTR_MAX_ATTACKS, 10);
    ai_set_targets(AI_PLR2_TRIBE, 0, true, true, true); -- this will be dynamically changed in actual attacks
    
    PLR2_SH:set_casting_delay(16);
    PLR2_SH:set_offensive_spell_entry(1, M_SPELL_WHIRLWIND, {1, 2, 3, 5, 6, 7, 8, 15}, 3, SPELL_COST(M_SPELL_WHIRLWIND) >> 2);
    PLR2_SH:set_offensive_spell_entry(2, M_SPELL_FIRESTORM, {1, 2, 3, 5, 6, 7, 8}, 2, SPELL_COST(M_SPELL_FIRESTORM) >> 2);
  end
  
  -- ai player 3 stuff
  ai_main_drum_tower_info(AI_PLR3_TRIBE, true, 158, 242);
  ai_set_shaman_info(AI_PLR3_TRIBE, 158, 242, true, 56 - ((AI_PLR3_DIFF - 1) * 16), 16);
  ai_set_converting_info(AI_PLR3_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR3_TRIBE, true, true, true, true, 1, 3, 1);
  ai_set_fetch_info(AI_PLR3_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR3_TRIBE, true, 1, 30 - ((AI_PLR3_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR3_TRIBE, true, 15 + (AI_PLR3_DIFF * 25), 2 + ((AI_PLR3_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR3_TRIBE, 1, 1, 1, 0);
  ai_set_training_people(AI_PLR3_TRIBE, true, 10, 9, 12, 0, 0 + AI_PLR3_DIFF);
  ai_set_populating_info(AI_PLR3_TRIBE, true, true);
  ai_set_defence_rad(AI_PLR3_TRIBE, 7);
  ai_set_spy_info(AI_PLR2_TRIBE, false, 0, 10, 128, 128);

  if (AI_PLR3_DIFF == AI_EASY) then
    PLR3_SH:set_casting_delay(512);
  end

  if (AI_PLR3_DIFF == AI_MEDIUM) then
    ai_set_spell_entry(AI_PLR3_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 0);
    ai_set_spell_entry(AI_PLR3_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 1);

    PLR3_SH:set_casting_delay(64);
    PLR3_SH:set_offensive_spell_entry(1, M_SPELL_EARTHQUAKE, {1, 2, 3, 5, 6, 7, 8, 15}, 1, SPELL_COST(M_SPELL_EARTHQUAKE));
  end

  if (AI_PLR3_DIFF == AI_HARD) then
    ai_set_spell_entry(AI_PLR3_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 0);
    ai_set_spell_entry(AI_PLR3_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 1);

    PLR3_SH:set_casting_delay(32);
    PLR3_SH:set_offensive_spell_entry(1, M_SPELL_EARTHQUAKE, {1, 2, 3, 5, 6, 7, 8, 15}, 1, SPELL_COST(M_SPELL_EARTHQUAKE) >> 1);
  end

  if (AI_PLR3_DIFF == AI_EXTREME) then
    ai_set_spell_entry(AI_PLR3_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 0);
    ai_set_spell_entry(AI_PLR3_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 1);

    PLR3_SH:set_casting_delay(16);
    PLR3_SH:set_offensive_spell_entry(1, M_SPELL_EARTHQUAKE, {1, 2, 3, 5, 6, 7, 8, 15}, 2, SPELL_COST(M_SPELL_EARTHQUAKE) >> 2);
  end

  -- ai player 4 stuff
  ai_main_drum_tower_info(AI_PLR4_TRIBE, true, 230, 10);
  ai_set_shaman_info(AI_PLR4_TRIBE, 230, 10, true, 56 - ((AI_PLR4_DIFF - 1) * 16), 16);
  ai_set_converting_info(AI_PLR4_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR4_TRIBE, true, true, true, true, 1, 3, 1);
  ai_set_fetch_info(AI_PLR4_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR4_TRIBE, true, 1, 30 - ((AI_PLR4_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR4_TRIBE, true, 15 + (AI_PLR4_DIFF * 25), 2 + ((AI_PLR4_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR4_TRIBE, 0, 1, 1, 0);
  ai_set_training_people(AI_PLR4_TRIBE, true, 0, 12, 12, 0, 0 + AI_PLR4_DIFF);
  ai_set_populating_info(AI_PLR4_TRIBE, true, true);
  ai_set_defence_rad(AI_PLR4_TRIBE, 7);
  ai_set_spy_info(AI_PLR2_TRIBE, false, 0, 10, 128, 128);

  if (AI_PLR4_TRIBE == AI_EASY) then
    PLR4_SH:set_casting_delay(512);
  end

  if (AI_PLR4_DIFF == AI_MEDIUM) then
    ai_set_spell_entry(AI_PLR4_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 0);
    ai_set_spell_entry(AI_PLR4_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE)), 64, 3, 1);

    PLR4_SH:set_casting_delay(64);
    PLR4_SH:set_offensive_spell_entry(1, M_SPELL_EROSION, {1, 2, 3, 4, 5, 6, 7, 8, 15}, 1, SPELL_COST(M_SPELL_EROSION));
  end

  if (AI_PLR4_DIFF == AI_HARD) then
    ai_set_spell_entry(AI_PLR4_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 0);
    ai_set_spell_entry(AI_PLR4_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 1), 64, 1, 1);

    PLR4_SH:set_casting_delay(32);
    PLR4_SH:set_offensive_spell_entry(1, M_SPELL_EROSION, {1, 2, 3, 4, 5, 6, 7, 8, 15}, 1, SPELL_COST(M_SPELL_EROSION) >> 1);
  end

  if (AI_PLR4_DIFF == AI_EXTREME) then
    ai_set_spell_entry(AI_PLR4_TRIBE, 0, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 0);
    ai_set_spell_entry(AI_PLR4_TRIBE, 1, M_SPELL_INSECT_PLAGUE, (SPELL_COST(M_SPELL_INSECT_PLAGUE) >> 2), 64, 1, 1);

    PLR4_SH:set_casting_delay(16);
    PLR4_SH:set_offensive_spell_entry(1, M_SPELL_EROSION, {1, 2, 3, 4, 5, 6, 7, 8, 15}, 2, SPELL_COST(M_SPELL_EROSION) >> 2);
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
    PLR3_SH:toggle_converting_wilds(true);
    PLR4_SH:toggle_converting_wilds(true);
  end
end

function ScrOnCreateThing(t_thing)
  
end

function ScrOnFrame(w, h, guiW)
  --draw_population_scores();
end