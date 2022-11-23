local convert_markers =
{
  15, 16, 17, 18
};

CompPlayer:init(TRIBE_PINK);
local ai = CompPlayer(TRIBE_PINK);

-- towers
ai:create_tower(1, 218, 118, -1);
ai:create_tower(2, 230, 120, -1);
ai:create_tower(3, 222, 108, -1);
ai:create_tower(4, 204, 108, -1);
ai:create_tower(5, 214, 80, 3);
ai:create_tower(6, 220, 76, 2);
ai:create_tower(7, 224, 76, 2);
ai:create_tower(8, 228, 78, 1);

local function purple_towers(player)
  -- first row of defense.
  if (AI_GetPopCount(player) > 20) then
    -- don't need to have fws for those.
    if (not ai:is_tower_constructed(1)) then
      ai:construct_tower(1);
    end

    if (not ai:is_tower_constructed(2)) then
      ai:construct_tower(2);
      return;
    end

    if (not ai:is_tower_constructed(3)) then
      ai:construct_tower(3);
    end

    if (not ai:is_tower_constructed(4)) then
      ai:construct_tower(4);
      return;
    end

    -- and now we check if we have fws and actually mid is enemy free!!
    if (AI_GetVar(player, 3) > 0) then
      -- check middle
      AI_SetVar(player, 5, 0);
      if (AI_AreaContainsEnemy(player, 222, 82, 6)) then
        AI_SetVar(player, 5, 1);
        return;
      end

      if (not ai:is_tower_constructed(5)) then
        ai:construct_tower(5);
      end

      if (not ai:is_tower_constructed(6)) then
        ai:construct_tower(6);
        return;
      end

      if (not ai:is_tower_constructed(7)) then
        ai:construct_tower(7);
      end

      if (not ai:is_tower_constructed(8)) then
        ai:construct_tower(8);
      end
    end
  end
end

local function purple_build(player)
  AI_SetVar(player, 2, 0);
  AI_SetVar(player, 3, 0);
  AI_SetVar(player, 4, 0);

  -- check if we got any training building, if so, enable training
  if (AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) > 0 or
      AI_GetBldgCount(player, M_BUILDING_TEMPLE) > 0 or
      AI_GetBldgCount(player, M_BUILDING_WARRIOR_TRAIN) > 0) then
        WRITE_CP_ATTRIB(player, ATTR_MAX_TRAIN_AT_ONCE, 3);
        STATE_SET(player, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
  end

  -- for purple we want to build lots of huts first.
  if (AI_GetHutsCount(player) < 5) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 60);
    WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 5);
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 0);
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 0);
    WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_TRAINS, 0);
    WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 0);
    AI_SetVar(player, 2, 1); -- indicate that we're lacking huts.
  else
    -- now we have some huts, build fire warrior training hut now.
    if (AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) == 0) then
      WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 2);
      WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
    end

    -- increase house percentage once fire awrrior bldg is done.
    if (AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) > 0) then
      WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 12);
      WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 80);
      WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_TRAINS, 1);
      AI_SetVar(player, 3, 1); -- indicate that we have access to firewarriors.
    end

    -- further bldging.
    if (AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) > 0 and AI_GetBldgCount(player, M_BUILDING_WARRIOR_TRAIN) > 0) then
      WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 15);
      WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 100);
      WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 1);
      AI_SetVar(player, 4, 1); -- indicate that we have access to warriors.
    end
  end
end

local function purple_convert(player)
  -- check if we have a low pop count
  if (AI_GetPopCount(player) < 32 and AI_ShamanFree(player)) then
    -- enable converting and convert at random markers
    STATE_SET(player, 1, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
    WRITE_CP_ATTRIB(player, ATTR_EXPANSION, 36);

    -- ordered converting
    local idx = AI_GetVar(player, 1);

    if (idx > #convert_markers or idx == 0) then
      idx = 1;
    end

    local mk = convert_markers[idx];
    AI_ConvertAt(player, mk);
    AI_SetVar(player, 1, idx + 1);
  else
    -- disable converting
    STATE_SET(player, 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
  end
end

-- events
ai:create_event(1, 122, 32, purple_convert);
ai:create_event(2, 256, 96, purple_build);
ai:create_event(3, 140, 44, purple_towers);
