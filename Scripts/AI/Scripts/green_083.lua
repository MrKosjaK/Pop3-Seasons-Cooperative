local convert_markers =
{
  31, 32, 33, 34, 35, 36, 37
};

CompPlayer:init(TRIBE_GREEN);
local ai = CompPlayer(TRIBE_GREEN);

local function green_build(player)
end

local function green_towers(player)
end

local function green_convert(player)
-- check if we have a low pop count
  if (AI_GetPopCount(player) < 31 and AI_ShamanFree(player)) then
    -- enable converting and convert at random markers
    STATE_SET(player, 1, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
    WRITE_CP_ATTRIB(player, ATTR_EXPANSION, 36);

    local mk = convert_markers[G_RANDOM(#convert_markers) + 1];
    AI_ConvertAt(player, mk);
  else
    -- disable converting
    STATE_SET(player, 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
  end
end

ai:create_event(1, 128, 32, green_convert);
ai:create_event(2, 256, 96, green_build);
ai:create_event(3, 340, 150, green_towers);