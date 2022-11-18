-- Includes
include("Common.lua");
include("LbClock.lua");
include("Spells\\TiledSwamp.lua");

-- TiledSwamp parameters
SwampTileEnabled = true; -- enables tiled swamps
SwampTileSize = 4;

-- Clocks
CreateClock("C_BldgMain", 384, 96);
CreateClock("C_Convert", 212, 84);
CreateClock("C_Towers", 1024, 256);
CreateClock("C_Patrol", 740, 112);

-- Towers
-- CreateTower("Front1", TRIBE_CYAN, 124, 104, -1);
-- CreateTower("Front2", TRIBE_CYAN, 146, 106, -1);
-- CreateTower("Front3", TRIBE_CYAN, 126, 96, -1);
-- CreateTower("MidHill1", TRIBE_CYAN, 130, 76, -1);
-- CreateTower("MidHill2", TRIBE_CYAN, 148, 78, -1);
-- CreateTower("MidHill3", TRIBE_CYAN, 138, 78, -1);

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 3;
local ai_convert_markers =
{
  [TRIBE_CYAN] = { 10, 11, 12, 13, 14 },
  [TRIBE_GREEN] = { 1 },
  [TRIBE_PINK] = { 1 }
};

function _OnLevelInit(level_id)
  -- Green stuff
  AI_Initialize(TRIBE_GREEN);

  set_player_can_cast(M_SPELL_BLAST, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_CONVERT_WILD, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_WHIRLWIND, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_INSECT_PLAGUE, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_INVISIBILITY, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_HYPNOTISM, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_GHOST_ARMY, TRIBE_GREEN);
  set_player_can_cast(M_SPELL_EARTHQUAKE, TRIBE_GREEN);
  set_player_can_build(M_BUILDING_TEPEE, TRIBE_GREEN);
  set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_GREEN);
  set_player_can_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_GREEN);
  set_player_can_build(M_BUILDING_SUPER_TRAIN, TRIBE_GREEN);
  set_player_can_build(M_BUILDING_TEMPLE, TRIBE_GREEN);

  AI_SetAways(TRIBE_GREEN, 1, 0, 0, 0, 0);
  AI_SetShamanAway(TRIBE_GREEN, false);
  AI_SetShamanParams(TRIBE_GREEN, 0, 0, false, 0, 12);
  AI_SetMainDrumTower(TRIBE_GREEN, false, 0, 0);
  AI_SetConvertingParams(TRIBE_GREEN, true, true, 12);
  AI_SetTargetParams(TRIBE_GREEN, TRIBE_RED, true, true);

  AI_SetBuildingParams(TRIBE_GREEN, true, 60, 4);
  AI_SetTrainingHuts(TRIBE_GREEN, 0, 0, 0, 0);
  AI_SetTrainingPeople(TRIBE_GREEN, false, 0, 0, 0, 0, 0);
  AI_SetVehicleParams(TRIBE_GREEN, false, 0, 0, 0, 0);
  AI_SetFetchParams(TRIBE_GREEN, false, false, false, false);

  AI_SetAttackingParams(TRIBE_GREEN, false, 0, 25);
  AI_SetDefensiveParams(TRIBE_GREEN, true, true, true, true, 3, 1, 1);
  AI_SetSpyParams(TRIBE_GREEN, false, 0, 100, 128, 1);
  AI_SetPopulatingParams(TRIBE_GREEN, true, true);

  AI_EnableBuckets(TRIBE_GREEN);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_BLAST, 1);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_CONVERT_WILD, 1);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_INSECT_PLAGUE, 5);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_INVISIBILITY, 4);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_LIGHTNING_BOLT, 7);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_HYPNOTISM, 8);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_EARTHQUAKE, 20);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_WHIRLWIND, 10);
  AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_GHOST_ARMY, 3);

  -- Cyan stuff
  AI_Initialize(TRIBE_CYAN);
  Initialize_Special_AI("Cyan", TRIBE_CYAN);
  GetAI("Cyan"):RegisterEvent("Test", 12, 1, function(player) log("Player : " .. player); end);

  set_player_can_cast(M_SPELL_BLAST, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_CONVERT_WILD, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_WHIRLWIND, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_INSECT_PLAGUE, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_INVISIBILITY, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_HYPNOTISM, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_GHOST_ARMY, TRIBE_CYAN);
  set_player_can_cast(M_SPELL_EARTHQUAKE, TRIBE_CYAN);
  set_player_can_build(M_BUILDING_TEPEE, TRIBE_CYAN);
  set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_CYAN);
  set_player_can_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_CYAN);
  set_player_can_build(M_BUILDING_SUPER_TRAIN, TRIBE_CYAN);
  set_player_can_build(M_BUILDING_TEMPLE, TRIBE_CYAN);

  AI_SetAways(TRIBE_CYAN, 1, 0, 0, 0, 0);
  AI_SetShamanAway(TRIBE_CYAN, false);
  AI_SetShamanParams(TRIBE_CYAN, 138, 128, true, 16, 12);
  AI_SetMainDrumTower(TRIBE_CYAN, true, 138, 128);
  AI_SetConvertingParams(TRIBE_CYAN, false, true, 12);
  AI_SetTargetParams(TRIBE_CYAN, TRIBE_BLUE, true, true);

  AI_SetBuildingParams(TRIBE_CYAN, true, 9, 3);
  AI_SetTrainingHuts(TRIBE_CYAN, 0, 0, 0, 0);
  AI_SetTrainingPeople(TRIBE_CYAN, false, 0, 0, 0, 0, 0);
  AI_SetVehicleParams(TRIBE_CYAN, false, 0, 0, 0, 0);
  AI_SetFetchParams(TRIBE_CYAN, false, false, false, false);

  AI_SetAttackingParams(TRIBE_CYAN, false, 0, 25);
  AI_SetDefensiveParams(TRIBE_CYAN, true, true, true, true, 3, 1, 1);
  AI_SetSpyParams(TRIBE_CYAN, false, 0, 100, 128, 1);
  AI_SetPopulatingParams(TRIBE_CYAN, true, true);

  AI_EnableBuckets(TRIBE_CYAN);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_BLAST, 1);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_CONVERT_WILD, 1);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INSECT_PLAGUE, 5);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INVISIBILITY, 4);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_LIGHTNING_BOLT, 7);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_HYPNOTISM, 8);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_EARTHQUAKE, 20);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_WHIRLWIND, 10);
  AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_GHOST_ARMY, 3);

  -- Pink stuff
  AI_Initialize(TRIBE_PINK);

  set_player_can_cast(M_SPELL_BLAST, TRIBE_PINK);
  set_player_can_cast(M_SPELL_CONVERT_WILD, TRIBE_PINK);
  set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_PINK);
  set_player_can_cast(M_SPELL_WHIRLWIND, TRIBE_PINK);
  set_player_can_cast(M_SPELL_INSECT_PLAGUE, TRIBE_PINK);
  set_player_can_cast(M_SPELL_INVISIBILITY, TRIBE_PINK);
  set_player_can_cast(M_SPELL_HYPNOTISM, TRIBE_PINK);
  set_player_can_cast(M_SPELL_GHOST_ARMY, TRIBE_PINK);
  set_player_can_cast(M_SPELL_EARTHQUAKE, TRIBE_PINK);
  set_player_can_build(M_BUILDING_TEPEE, TRIBE_PINK);
  set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_PINK);
  set_player_can_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_PINK);
  set_player_can_build(M_BUILDING_SUPER_TRAIN, TRIBE_PINK);
  set_player_can_build(M_BUILDING_TEMPLE, TRIBE_PINK);

  AI_SetAways(TRIBE_PINK, 1, 0, 0, 0, 0);
  AI_SetShamanAway(TRIBE_PINK, false);
  AI_SetShamanParams(TRIBE_PINK, 0, 0, false, 0, 12);
  AI_SetMainDrumTower(TRIBE_PINK, false, 0, 0);
  AI_SetConvertingParams(TRIBE_PINK, true, true, 12);
  AI_SetTargetParams(TRIBE_PINK, TRIBE_YELLOW, true, true);

  AI_SetBuildingParams(TRIBE_PINK, true, 60, 4);
  AI_SetTrainingHuts(TRIBE_PINK, 0, 0, 0, 0);
  AI_SetTrainingPeople(TRIBE_PINK, false, 0, 0, 0, 0, 0);
  AI_SetVehicleParams(TRIBE_PINK, false, 0, 0, 0, 0);
  AI_SetFetchParams(TRIBE_PINK, false, false, false, false);

  AI_SetAttackingParams(TRIBE_PINK, false, 0, 25);
  AI_SetDefensiveParams(TRIBE_PINK, true, true, true, true, 3, 1, 1);
  AI_SetSpyParams(TRIBE_PINK, false, 0, 100, 128, 1);
  AI_SetPopulatingParams(TRIBE_PINK, true, true);

  AI_EnableBuckets(TRIBE_PINK);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_BLAST, 1);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_CONVERT_WILD, 1);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_INSECT_PLAGUE, 5);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_INVISIBILITY, 4);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_LIGHTNING_BOLT, 7);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_HYPNOTISM, 8);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_EARTHQUAKE, 20);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_WHIRLWIND, 10);
  AI_SpellBucketCost(TRIBE_PINK, M_SPELL_GHOST_ARMY, 3);
end

function _OnTurn(turn)
  ProcessTiledSwamps();
  if (TickClock("C_Towers")) then
    -- for building towers we want to have at least 1 fw and some population
    if (AI_GetPopCount(TRIBE_CYAN) > 30) then
      if (AI_GetUnitCount(TRIBE_CYAN, M_PERSON_SUPER_WARRIOR) > 0) then
        if (AI_EntryAvailable(TRIBE_CYAN)) then
          -- currently only testing
          CheckTower("Front1");
          CheckTower("Front2");
          CheckTower("Front3");
          CheckTower("MidHill1");
          CheckTower("MidHill2");
          CheckTower("MidHill3");
        end
      end
    end
  end

  if (TickClock("C_Convert")) then
    -- check if we have a low pop count
    if (AI_GetPopCount(TRIBE_CYAN) < 35) then
      -- enable converting and convert at random markers
      STATE_SET(TRIBE_CYAN, 1, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_EXPANSION, 36);

      local mk = ai_convert_markers[TRIBE_CYAN][G_RANDOM(#ai_convert_markers[TRIBE_CYAN]) + 1];
      AI_ConvertAt(TRIBE_CYAN, mk);
    else
      -- disable converting
      STATE_SET(TRIBE_CYAN, 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
    end
  end

  if (TickClock("C_BldgMain")) then
    -- let's see what we got here, we probably want to get FW hut after some huts.
    if (AI_GetHutsCount(TRIBE_CYAN) >= 2 and AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_SUPER_TRAIN) == 0) then
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
    end

    -- we want to keep building huts now
    if (AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_SUPER_TRAIN) > 0) then
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_HOUSE_PERCENTAGE, 30);
    end

    -- check if we got any training building, if so, enable training
    if (AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_SUPER_TRAIN) > 0 or
        AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_TEMPLE) > 0 or
        AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_WARRIOR_TRAIN) > 0) then
          WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_MAX_TRAIN_AT_ONCE, 3);
          STATE_SET(TRIBE_CYAN, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
    end

    -- once we get more huts, we can afford to train some fws
    if (AI_GetHutsCount(TRIBE_CYAN) > 5 and AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_SUPER_TRAIN) > 0) then
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 10);
    end

    -- we got more huts, let's get priests up !
    if (AI_GetHutsCount(TRIBE_CYAN) > 8 and AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_TEMPLE) == 0) then
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_RELIGIOUS_TRAINS, 1);
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_RELIGIOUS_PEOPLE, 10);
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 15);
    end

    -- let's keep expanding on our tribe once temple is up
    if (AI_GetBldgCount(TRIBE_CYAN, M_BUILDING_TEMPLE) > 0) then
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_HOUSE_PERCENTAGE, 60);
    end

    -- once we got big enough tribe, increase training %
    if (AI_GetHutsCount(TRIBE_CYAN) > 11) then
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_HOUSE_PERCENTAGE, 90);
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_RELIGIOUS_PEOPLE, 15);
      WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 21);
    end
  end
end

function _OnCreateThing(t)
  ProcessSwampCreate(t);
end

function _OnPlayerDeath(pn)
end

function _OnFrame(w,h,guiW)
end

function _OnKeyUp(k)
end

function _OnKeyDown(k)
end
