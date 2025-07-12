include("common.lua");
include("pop_helper.lua");
include("weather.lua");

-- level 1 specific stuff
set_level_human_count(2);
set_level_computer_count(6);

add_human_player_start_info(0, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_HYPNOTISM, M_SPELL_LIGHTNING_BOLT}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN, M_BUILDING_WARRIOR_TRAIN});
add_human_player_start_info(1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(2, 2, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_HYPNOTISM, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(3, -1, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE, M_SPELL_LIGHTNING_BOLT, M_SPELL_WHIRLWIND}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER, M_BUILDING_WARRIOR_TRAIN, M_BUILDING_SUPER_TRAIN});
add_ai_player_start_info(4, 5, {2}, {2});
add_ai_player_start_info(5, -1, {2}, {2});
add_ai_player_start_info(6, -1, {2}, {2});
add_ai_player_start_info(7, 7, {2}, {2});



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
  
  -- spawn extra small huts
  if (AI_PLR1_DIFF >= AI_MEDIUM) then
    CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(130, 52), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
    CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(176, 48), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
    CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(126, 82), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
    CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(134, 82), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
    -- spawn extra medium huts + warrior train
    if (AI_PLR1_DIFF >= AI_HARD) then
      CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(132, 44), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
      CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(124, 90), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
      CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(148, 90), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
      CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_WARRIOR_TRAIN, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(156, 90), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
      CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_TEPEE_2, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(152, 82), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
      -- spawn firewarrior train + defense + troops
      if (AI_PLR1_DIFF == AI_VERY_HARD) then
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_SUPER_TRAIN, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(136, 94), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(192, 110), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(180, 110), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(180, 102), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(154, 108), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(168, 92), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(170, 74), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(122, 66), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
        CREATE_THING_WITH_PARAMS5(T_BUILDING, M_BUILDING_DRUM_TOWER, AI_PLR1_TRIBE, MAP_XZ_2_WORLD_XYZ(128, 104), math.floor(G_RANDOM(2048) / 512), 0, S_BUILDING_STAND, -1, 0);
      end
    end
  end
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