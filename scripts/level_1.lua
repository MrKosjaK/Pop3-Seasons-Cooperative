include("common.lua");
--include("pop_helper.lua");
--include("weather.lua");

-- level 1 specific stuff
set_level_human_count(2);
set_level_computer_count(2);

add_human_player_start_info(0, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_HYPNOTISM, M_SPELL_LIGHTNING_BOLT}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN, M_BUILDING_WARRIOR_TRAIN});
add_human_player_start_info(1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(2, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_HYPNOTISM, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(3, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_LIGHTNING_BOLT, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});



local AI_PLR1_TRIBE = -1;
local AI_PLR1_DIFF = AI_EASY;
local AI_PLR2_TRIBE = -1;
local AI_PLR2_DIFF = AI_EASY;

-- triggers at turn 0, at that point client's resolution is set to correct one instead of 640x480.
function OnInit()
  --start_weather(WEATHER_SNOW, 750, 75, 35, 60*10) -- type, amount, ~per_second_spawn, speed, duration_seconds
end

-- triggers after GAME MASTER starts game.
function OnGameStart()
  process_all_ai_info(function(ai)
    --log(string.format("Owner: %i, Difficulty: %i", ai.Owner, ai.Difficulty));
    set_player_check_surround_slopes(G_PLR[ai.Owner], FALSE);
    reduce_computer_players_sprogging_time_by_percent(G_PLR[ai.Owner], 0 + ((ai.Difficulty - 1) * 15));
  end);
  
  AI_PLR1_TRIBE = get_ai_player_info(1).Owner;
  AI_PLR1_DIFF = get_ai_player_info(1).Difficulty;
  AI_PLR2_TRIBE = get_ai_player_info(2).Owner;
  AI_PLR2_DIFF = get_ai_player_info(2).Difficulty;
  
  -- spawn extra small huts
  if (AI_PLR1_DIFF >= AI_MEDIUM) then
    create_building(M_BUILDING_TEPEE, AI_PLR1_TRIBE, 130, 52, G_RANDOM(4));
    create_building(M_BUILDING_TEPEE, AI_PLR1_TRIBE, 176, 48, G_RANDOM(4));
    create_building(M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, 126, 82, G_RANDOM(4));
    create_building(M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, 134, 82, G_RANDOM(4));
    create_building(M_BUILDING_WARRIOR_TRAIN, AI_PLR1_TRIBE, 156, 90, G_RANDOM(4));
    create_building(M_BUILDING_SUPER_TRAIN, AI_PLR1_TRIBE, 136, 94, G_RANDOM(4));
    -- spawn extra medium huts + warrior train
    if (AI_PLR1_DIFF >= AI_HARD) then
      create_building(M_BUILDING_TEPEE_3, AI_PLR1_TRIBE, 132, 44, G_RANDOM(4));
      create_building(M_BUILDING_TEPEE_3, AI_PLR1_TRIBE, 124, 90, G_RANDOM(4));
      create_building(M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, 148, 90, G_RANDOM(4));
      create_building(M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, 152, 82, G_RANDOM(4));
      -- spawn firewarrior train + defense + troops
      if (AI_PLR1_DIFF == AI_VERY_HARD) then
        create_building(M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, 192, 110, G_RANDOM(4));
        create_building(M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, 180, 110, G_RANDOM(4));
        create_building(M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, 180, 102, G_RANDOM(4));
        create_building(M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, 154, 108, G_RANDOM(4));
        create_building(M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, 168, 92, G_RANDOM(4));
        create_building(M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, 170, 74, G_RANDOM(4));
        create_building(M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, 128, 104, G_RANDOM(4));
      end
    end
  end
  
  if (AI_PLR2_DIFF >= AI_MEDIUM) then
    create_building(M_BUILDING_TEPEE_2, AI_PLR2_TRIBE, 44, 60, G_RANDOM(4));
    create_building(M_BUILDING_TEPEE_2, AI_PLR2_TRIBE, 36, 60, G_RANDOM(4));
    create_building(M_BUILDING_TEPEE, AI_PLR2_TRIBE, 44, 68, G_RANDOM(4));
    create_building(M_BUILDING_TEPEE, AI_PLR2_TRIBE, 36, 68, G_RANDOM(4));
    create_building(M_BUILDING_SUPER_TRAIN, AI_PLR2_TRIBE, 16, 82, G_RANDOM(4));
    create_building(M_BUILDING_WARRIOR_TRAIN, AI_PLR2_TRIBE, 16, 94, G_RANDOM(4));
    
    if (AI_PLR2_DIFF >= AI_HARD) then
      create_building(M_BUILDING_TEPEE_3, AI_PLR2_TRIBE, 34, 114, G_RANDOM(4));
      create_building(M_BUILDING_TEPEE_3, AI_PLR2_TRIBE, 26, 114, G_RANDOM(4));
      create_building(M_BUILDING_TEPEE_3, AI_PLR2_TRIBE, 26, 106, G_RANDOM(4));
      create_building(M_BUILDING_TEPEE_3, AI_PLR2_TRIBE, 34, 106, G_RANDOM(4));
      create_building(M_BUILDING_TEPEE_3, AI_PLR2_TRIBE, 42, 108, G_RANDOM(4));
    end
  end
  
  -- ai player 1 stuff
  ai_main_drum_tower_info(AI_PLR1_TRIBE, true, 122, 66);
  ai_set_shaman_info(AI_PLR1_TRIBE, 168, 74, true, 56 - ((AI_PLR1_DIFF - 1) * 16), 12);
  ai_set_converting_info(AI_PLR1_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR1_TRIBE, true, true, true, true, 3, 3, 1);
  ai_set_fetch_info(AI_PLR1_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR1_TRIBE, true, 1 + (AI_PLR1_DIFF), 30 - ((AI_PLR1_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR1_TRIBE, true, 15 + (AI_PLR1_DIFF * 15), 1 + ((AI_PLR1_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR1_TRIBE, 1, 0, 1, 0);
  ai_set_training_people(AI_PLR1_TRIBE, true, 10, 0, 12, 0, 0 + AI_PLR1_DIFF);
  ai_set_populating_info(AI_PLR1_TRIBE, true, true);
  
  -- ai player 1 spells
  ai_enable_buckets(AI_PLR1_TRIBE);
  ai_set_spell_bucket_count(AI_PLR1_TRIBE, M_SPELL_BLAST, 4);
  ai_set_spell_bucket_count(AI_PLR1_TRIBE, M_SPELL_CONVERT_WILD, 1);
  ai_set_spell_bucket_count(AI_PLR1_TRIBE, M_SPELL_INSECT_PLAGUE, 8);
  ai_set_spell_bucket_count(AI_PLR1_TRIBE, M_SPELL_LIGHTNING_BOLT, 10);
  ai_set_spell_bucket_count(AI_PLR1_TRIBE, M_SPELL_WHIRLWIND, 16);
  
  -- ai player 2 stuff
  ai_main_drum_tower_info(AI_PLR2_TRIBE, true, 36, 88);
  ai_set_shaman_info(AI_PLR2_TRIBE, 22, 110, true, 56 - ((AI_PLR2_DIFF - 1) * 16), 12);
  ai_set_converting_info(AI_PLR2_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR2_TRIBE, true, true, true, true, 3, 3, 1);
  ai_set_fetch_info(AI_PLR2_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR2_TRIBE, true, 1 + (AI_PLR2_DIFF), 30 - ((AI_PLR2_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR2_TRIBE, true, 20 + (AI_PLR2_DIFF * 15), 1 + ((AI_PLR2_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR2_TRIBE, 1, 0, 1, 0);
  ai_set_training_people(AI_PLR2_TRIBE, true, 10, 0, 12, 0, 0 + AI_PLR2_DIFF);
  ai_set_populating_info(AI_PLR2_TRIBE, true, true);
  
  -- ai player 2 spells
  ai_enable_buckets(AI_PLR2_TRIBE);
  ai_set_spell_bucket_count(AI_PLR2_TRIBE, M_SPELL_BLAST, 4);
  ai_set_spell_bucket_count(AI_PLR2_TRIBE, M_SPELL_CONVERT_WILD, 1);
  ai_set_spell_bucket_count(AI_PLR2_TRIBE, M_SPELL_INSECT_PLAGUE, 8);
  ai_set_spell_bucket_count(AI_PLR2_TRIBE, M_SPELL_LIGHTNING_BOLT, 10);
  ai_set_spell_bucket_count(AI_PLR2_TRIBE, M_SPELL_WHIRLWIND, 16);
end

function ScrOnLevelInit(level_id)
  --calculate_population_scores();
end

function ScrOnTurn(curr_turn)
  --process_weather(curr_turn);
  --calculate_population_scores();
end

function ScrOnCreateThing(t_thing)
  
end

function ScrOnFrame(w, h, guiW)
  --draw_population_scores();
end