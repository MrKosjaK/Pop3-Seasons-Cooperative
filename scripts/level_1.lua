include("common.lua");
include("pop_helper.lua");
include("weather.lua");

set_level_human_count(2);
set_level_computer_count(2);

add_human_player_start_info(0, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_human_player_start_info(1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_HYPNOTISM}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_ai_player_start_info(2, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_WARRIOR_TRAIN});
add_ai_player_start_info(3, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_WARRIOR_TRAIN});

-- triggers at turn 0, at that point client's resolution is set to correct one instead of 640x480.
function OnInit()
  --start_weather(WEATHER_SNOW, 750, 75, 35, 60*10) -- type, amount, ~per_second_spawn, speed, duration_seconds
end

-- triggers after GAME MASTER starts game.
function OnGameStart()
  process_all_ai_info(function(ai)
    log(string.format("Owner: %i, Difficulty: %i", ai.Owner, ai.Difficulty));
  end);
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