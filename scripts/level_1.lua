include("common.lua");
include("pop_helper.lua");
include("weather.lua");

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
    log(string.format("Owner: %i, Difficulty: %i", ai.Owner, ai.Difficulty));
  end);
  
  AI_PLR1_TRIBE = get_ai_player_info(1).Owner;
  AI_PLR1_DIFF = get_ai_player_info(1).Difficulty;
  AI_PLR2_TRIBE = get_ai_player_info(2).Owner;
  AI_PLR2_DIFF = get_ai_player_info(2).Difficulty;
end

function ScrOnLevelInit(level_id)
  calculate_population_scores();
end

function ScrOnTurn(curr_turn)
  --process_weather(curr_turn);
  calculate_population_scores();
end

function ScrOnCreateThing(t_thing)
  
end

function ScrOnFrame(w, h, guiW)
  draw_population_scores();
end