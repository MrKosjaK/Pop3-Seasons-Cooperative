-- game lobby stuff

HUMAN_COUNT = 0;
AI_COUNT = 0;
HUMAN_START_POSITIONS = {};
AI_START_POSITIONS = {};

HUMAN_PLAYERS = {};
HUMAN_PLAYERS_COUNT = 0;

function set_level_human_count(n)
  HUMAN_COUNT = n;
end

function set_level_computer_count(n)
  AI_COUNT = n;
end

function add_level_human_start_pos(marker_idx)
  HUMAN_START_POSITIONS[#HUMAN_START_POSITIONS + 1] = marker_to_coord3d(marker_idx);
end

function add_level_computer_start_pos(marker_idx)
  AI_START_POSITIONS[#AI_START_POSITIONS + 1] = marker_to_coord3d(marker_idx);
end

function get_info_on_players_count()
  for i = 0, 7 do
    if (G_PLR[i].PlayerType == HUMAN_PLAYER) then
      HUMAN_PLAYERS[#HUMAN_PLAYERS + 1] = i;
      HUMAN_PLAYERS_COUNT = HUMAN_PLAYERS_COUNT + 1;
    end
  end
  
  if (HUMAN_PLAYERS_COUNT > HUMAN_COUNT) then
    log(string.format("Amount of players exceed defined amount in level. Defined %i, actual %i", HUMAN_COUNT, HUMAN_PLAYERS_COUNT));
  end
end