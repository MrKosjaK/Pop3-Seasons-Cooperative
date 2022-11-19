-- This file will contain all of PopScript helper functions
-- To help with easier writing.

function AI_Initialize(pn)
  computer_init_player(getPlayer(pn));
end

function AI_SetVar(player, idx, value)
  SET_USER_VARIABLE_VALUE(player, idx, value);
end

function AI_GetVar(player, idx)
  return GET_USER_VARIABLE_VALUE(player, idx);
end

function AI_AreaContainsEnemy(pn, x, z, radius)
  local result = false;
  SearchMapCells(CIRCULAR, 0, 0, radius, map_xz_to_map_idx(x, z), function(me)
    if (not me.MapWhoList:isEmpty()) then
      me.MapWhoList:processList(function(t)
        if (t.Owner == TRIBE_HOSTBOT) then
          return true;
        end

        if (t.Type ~= T_PERSON and t.Type ~= T_BUILDING) then
          return true;
        end

        if (are_players_allied(pn, t.Owner) == 0) then
          result = true;
          return false;
        end
        return true;
      end);
    end
    if (result) then return false; end
    return true;
  end);

  return result;
end

function AI_CanBuildTower(pn, x, z, radius)
  local result = true;
  SearchMapCells(CIRCULAR, 0, 0, radius, map_xz_to_map_idx(x, z), function(me)
    -- first check if mapelement has a tower bldg/shape belonging to us
    if (not me.ShapeOrBldgIdx:isNull()) then
      local sob = me.ShapeOrBldgIdx:get();
      if (sob.Owner == pn) then
        if (sob.Type == T_SHAPE) then
          if (sob.u.Shape.BldgModel == M_BUILDING_DRUM_TOWER) then
            result = false;
            return false;
          end
        end

        if (sob.Type == T_BUILDING) then
          if (sob.Model == M_BUILDING_DRUM_TOWER) then
            result = false;
            return false;
          end
        end
      elseif (are_players_allied(pn, sob.Owner) == 0) then
        result = false;
        return false;
      end
    end

    return true;
  end);

  return result;
end

function AI_ConvertAt(pn, mk)
  CONVERT_AT_MARKER(pn, mk);
end

function AI_GetUnitCount(pn, unit)
  return PLAYERS_PEOPLE_OF_TYPE(pn, unit);
end

function AI_EntryAvailable(pn)
  return (FREE_ENTRIES(pn) > 0);
end

function AI_GetPopCount(pn)
  return GET_NUM_PEOPLE(pn);
end

function AI_GetBldgCount(pn, model)
  return PLAYERS_BUILDING_OF_TYPE(pn, model);
end

function AI_GetHutsCount(pn)
  local huts = PLAYERS_BUILDING_OF_TYPE(pn, M_BUILDING_TEPEE);
  huts = huts + PLAYERS_BUILDING_OF_TYPE(pn, M_BUILDING_HUT);
  huts = huts + PLAYERS_BUILDING_OF_TYPE(pn, M_BUILDING_FARM);
  return huts;
end

function AI_SetTargetParams(pn, opponent, a, b)
  TARGET_PLAYER_DT_AND_S(pn, opponent);
  if (a) then TARGET_DRUM_TOWERS(pn); else DONT_TARGET_DRUM_TOWERS(pn); end
  if (b) then TARGET_S_WARRIORS(pn); else DONT_TARGET_S_WARRIORS(pn); end
end

function AI_EnableBuckets(pn)
  SET_BUCKET_USAGE(pn, 1);
end

function AI_DisableBuckets(pn)
  SET_BUCKET_USAGE(pn, 0);
end

function AI_SpellBucketCost(pn, a, b)
  SET_BUCKET_COUNT_FOR_SPELL(pn, a, b);
end

function AI_SetAways(pn, a, b, c, d, e)
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_BRAVE, a);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_WARRIOR, b);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_RELIGIOUS, c);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_SUPER_WARRIOR, d);
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_SPY, e);
end

-- PARAMS
-- @bool (true/false) away shaman?
function AI_SetShamanAway(pn, a)
  WRITE_CP_ATTRIB(pn, ATTR_AWAY_MEDICINE_MAN, a and 1 or 0);
end

-- PARAMS:
-- @bool (true/false) should ai build at all?
-- @int (number value) house percentage
-- @int (number value) max bldgs on go
function AI_SetBuildingParams(pn, a, b, c)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_CONSTRUCT_BUILDING);
  WRITE_CP_ATTRIB(pn, ATTR_HOUSE_PERCENTAGE, b);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_BUILDINGS_ON_GO, c);
end

function AI_SetTrainingHuts(pn, a, b, c, d)
  WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_TRAINS, a);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_RELIGIOUS_TRAINS, b);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_TRAINS, c);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SPY_TRAINS, d);
end

function AI_SetTrainingPeople(pn, a, b, c, d, e, f)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_TRAIN_PEOPLE);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_PEOPLE, b);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_RELIGIOUS_PEOPLE, c);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_PEOPLE, d);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_SPY_PEOPLE, e);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_TRAIN_AT_ONCE, f);
end

function AI_SetAttackingParams(pn, a, b, c)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_AUTO_ATTACK);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_ATTACKS, b);
  WRITE_CP_ATTRIB(pn, ATTR_RETREAT_VALUE, c);
end

function AI_SetVehicleParams(pn, a, b, c, d, e)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_BUILD_VEHICLE);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_HUTS, b);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_DRIVERS, c);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_HUTS, d);
  WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_DRIVERS, e);
end

function AI_SetFetchParams(pn, a, b, c, d)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_FETCH_LOST_PEOPLE);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_FETCH_LOST_VEHICLE);
  STATE_SET(pn, c and 1 or 0, CP_AT_TYPE_FETCH_FAR_VEHICLE);
  STATE_SET(pn, d and 1 or 0, CP_AT_TYPE_FETCH_WOOD);
end

function AI_SetDefensiveParams(pn, a, b, c, d, e, f, g)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_DEFEND);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_DEFEND_BASE);
  STATE_SET(pn, c and 1 or 0, CP_AT_TYPE_SUPER_DEFEND);
  STATE_SET(pn, d and 1 or 0, CP_AT_TYPE_PREACH);
  WRITE_CP_ATTRIB(pn, ATTR_DEFENSE_RAD_INCR, e);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_DEFENSIVE_ACTIONS, f);
  WRITE_CP_ATTRIB(pn, ATTR_USE_PREACHER_FOR_DEFENCE, g);
end

function AI_SetConvertingParams(pn, a, b, c)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_BRING_NEW_PEOPLE_BACK);
  WRITE_CP_ATTRIB(pn, ATTR_EXPANSION, c);
end

function AI_SetSpyParams(pn, a, b, c, d, e)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_SABOTAGE);
  WRITE_CP_ATTRIB(pn, ATTR_MAX_SPY_ATTACKS, b);
  WRITE_CP_ATTRIB(pn, ATTR_SPY_DISCOVER_CHANCE, c);
  WRITE_CP_ATTRIB(pn, ATTR_SPY_CHECK_FREQUENCY, d);
  WRITE_CP_ATTRIB(pn, ATTR_ENEMY_SPY_MAX_STAND, e);
end

function AI_SetShamanParams(pn, x, z, a, b, c)
  SHAMAN_DEFEND(pn, x, z, a and 1 or 0);
  WRITE_CP_ATTRIB(pn, ATTR_SHAMEN_BLAST, b);
  WRITE_CP_ATTRIB(pn, ATTR_SPELL_DELAY, c);
end

function AI_SetAttackFlags(pn, a, b, c)
  WRITE_CP_ATTRIB(pn, ATTR_GROUP_OPTION, a);
  WRITE_CP_ATTRIB(pn, ATTR_DONT_GROUP_AT_DT, b);
  WRITE_CP_ATTRIB(pn, ATTR_DONT_USE_BOATS, c);
end

function AI_SetPopulatingParams(pn, a, b)
  STATE_SET(pn, a and 1 or 0, CP_AT_TYPE_POPULATE_DRUM_TOWER);
  STATE_SET(pn, b and 1 or 0, CP_AT_TYPE_HOUSE_A_PERSON);
end

function AI_SetMainDrumTower(pn, a, x, z)
  if (a) then
    DELAY_MAIN_DRUM_TOWER(0, pn);
    SET_DRUM_TOWER_POS(pn, x, z);
  else
    DELAY_MAIN_DRUM_TOWER(1, pn);
  end
end
