local game_state = 0;

function set_game_state(state)
  game_state = state;
end

function is_game_state(state)
  return (game_state == state);
end