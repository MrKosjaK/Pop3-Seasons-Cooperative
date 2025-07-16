include("common.lua");
include("searcharea.lua");
include("lvl1_ai_func.lua");
--include("pop_helper.lua");
--include("weather.lua");

-- level 1 specific stuff
set_level_human_count(2);
set_level_computer_count(2);

add_human_player_start_info(0, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_HYPNOTISM, M_SPELL_LIGHTNING_BOLT}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN, M_BUILDING_WARRIOR_TRAIN});
add_human_player_start_info(1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(2, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_HYPNOTISM, M_SPELL_WHIRLWIND, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(3, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_HYPNOTISM, M_SPELL_LIGHTNING_BOLT, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});



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
    set_player_check_surround_slopes(G_PLR[ai.Owner], FALSE);
    reduce_computer_players_sprogging_time_by_percent(G_PLR[ai.Owner], 0 + ((ai.Difficulty - 1) * 15));
    spawn_computer_addons(ai.Owner, ai.Difficulty);
    register_ai_events(ai.Owner, ai.Difficulty);
  end);
  
  AI_PLR1_TRIBE = get_ai_player_info(1).Owner;
  AI_PLR1_DIFF = get_ai_player_info(1).Difficulty;
  AI_PLR2_TRIBE = get_ai_player_info(2).Owner;
  AI_PLR2_DIFF = get_ai_player_info(2).Difficulty;
  
  -- ai player 1 stuff
  ai_main_drum_tower_info(AI_PLR1_TRIBE, true, 122, 66);
  ai_set_shaman_info(AI_PLR1_TRIBE, 168, 74, true, 56 - ((AI_PLR1_DIFF - 1) * 16), 12);
  ai_set_converting_info(AI_PLR1_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR1_TRIBE, true, true, true, true, 3, 3, 1);
  ai_set_fetch_info(AI_PLR1_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR1_TRIBE, true, 1 + (AI_PLR1_DIFF), 30 - ((AI_PLR1_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR1_TRIBE, true, 15 + (AI_PLR1_DIFF * 25), 2 + ((AI_PLR1_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR1_TRIBE, 1, 0, 1, 0);
  ai_set_training_people(AI_PLR1_TRIBE, true, 10, 0, 12, 0, 0 + AI_PLR1_DIFF);
  ai_set_populating_info(AI_PLR1_TRIBE, true, true);
  
  if (AI_PLR1_DIFF == AI_EASY) then
    ai_set_marker_entry(AI_PLR1_TRIBE, 0, 44, -1, 0, 1, 2, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 1, 45, -1, 0, 2, 1, 0);
    ai_set_marker_entry(AI_PLR1_TRIBE, 2, 46, 47, 0, 1, 3, 0);
  end
  
  -- ai player 2 stuff
  ai_main_drum_tower_info(AI_PLR2_TRIBE, true, 36, 88);
  ai_set_shaman_info(AI_PLR2_TRIBE, 22, 110, true, 56 - ((AI_PLR2_DIFF - 1) * 16), 12);
  ai_set_converting_info(AI_PLR2_TRIBE, true, true, 24);
  ai_set_defensive_info(AI_PLR2_TRIBE, true, true, true, true, 3, 3, 1);
  ai_set_fetch_info(AI_PLR2_TRIBE, true, false, false, true);
  ai_set_attack_info(AI_PLR2_TRIBE, true, 1 + (AI_PLR2_DIFF), 30 - ((AI_PLR2_DIFF - 1) * 10), 12);
  ai_set_bldg_info(AI_PLR2_TRIBE, true, 20 + (AI_PLR2_DIFF * 25), 2 + ((AI_PLR2_DIFF - 1) * 2));
  ai_set_training_huts(AI_PLR2_TRIBE, 1, 0, 1, 0);
  ai_set_training_people(AI_PLR2_TRIBE, true, 10, 0, 12, 0, 0 + AI_PLR2_DIFF);
  ai_set_populating_info(AI_PLR2_TRIBE, true, true);
end

function ScrOnLevelInit(level_id)
  --calculate_population_scores();
end

function ScrOnTurn()
  process_ai_events();
end

function ScrOnCreateThing(t_thing)
  
end

function ScrOnFrame(w, h, guiW)
  --draw_population_scores();
end