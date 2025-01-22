include("common.lua");
include("pop_helper.lua");

local _TURN = 0;

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