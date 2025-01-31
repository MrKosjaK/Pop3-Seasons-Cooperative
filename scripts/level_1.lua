include("common.lua");
include("pop_helper.lua");

set_level_human_count(2);
set_level_computer_count(1);

add_level_human_start_pos(0);
add_level_human_start_pos(1);
add_level_computer_start_pos(2);

function ScrOnLevelInit(level_id)
  calculate_population_scores();
end

function ScrOnTurn(curr_turn)
  calculate_population_scores();
end

function ScrOnCreateThing(t_thing)
  
end

function ScrOnFrame(w, h, guiW)
  draw_population_scores();
end