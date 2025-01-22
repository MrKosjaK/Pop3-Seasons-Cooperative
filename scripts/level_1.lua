include("common.lua");
include("pop_helper.lua");

local _TURN = 0;

function ScrOnLevelInit(level_id)
  log(string.format("Level has been initialized!"));
  calculate_population_scores();
end

function ScrOnTurn(curr_turn)
  _TURN = curr_turn;
  calculate_population_scores();
end

function ScrOnCreateThing(t_thing)
  log(string.format("T: %i, M: %i", t_thing.Type, t_thing.Model));
end

function ScrOnFrame(w, h, guiW)
  PopSetFont(4);
  draw_population_scores();
  LbDraw_Text(150, 150, string.format("Turn: %i", _TURN), 0);
end