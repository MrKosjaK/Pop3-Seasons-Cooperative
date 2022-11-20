local ai_convert_markers =
{
  [TRIBE_CYAN] = { 10, 11, 12, 13, 14 },
  [TRIBE_GREEN] = { 1 },
  [TRIBE_PINK] = { 15, 16, 17, 18 }
};

function purple_convert(player)
  -- check if we have a low pop count
  if (AI_GetPopCount(player) < 32) then
    -- enable converting and convert at random markers
    STATE_SET(player, 1, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
    WRITE_CP_ATTRIB(player, ATTR_EXPANSION, 36);

    -- ordered converting
    local idx = AI_GetVar(player, 1);

    if (idx > #ai_convert_markers[player] or idx == 0) then
      idx = 1;
    end

    local mk = ai_convert_markers[player][idx];
    AI_ConvertAt(player, mk);
    AI_SetVar(player, 1, idx + 1);
  else
    -- disable converting
    STATE_SET(player, 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
  end
end
