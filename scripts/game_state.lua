local game_state = 0;
local game_difficulty = AI_MEDIUM;

function set_game_state(state)
  game_state = state;
end

function is_game_state(state)
  return (game_state == state);
end

function set_difficulty(difficulty)
	game_difficulty = difficulty
end

function get_difficulty()
	return game_difficulty
end