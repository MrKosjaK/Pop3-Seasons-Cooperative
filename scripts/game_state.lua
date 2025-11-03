local game_state = 0;

function set_game_state(state)
  game_state = state;
end

function is_game_state(state)
  return (game_state == state);
end

function game_state_save(sData)
  gsave_int(sData, "GameState", game_state);
end

function game_state_load()
  game_state = gload_data("GameState");
end