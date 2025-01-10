include("common.lua");

local _TURN = 0;

function ScrOnLevelInit(level_id)
  log(string.format("Level has been initialized!"));
end

function ScrOnTurn(curr_turn)
  _TURN = curr_turn;
end

function ScrOnCreateThing(t_thing)
  log(string.format("T: %i, M: %i", t_thing.Type, t_thing.Model));
end

function ScrOnFrame()
  PopSetFont(4);
  LbDraw_Text(150, 150, string.format("Turn: %i", _TURN), 0);
end