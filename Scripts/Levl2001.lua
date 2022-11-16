-- Includes
include("Common.lua");

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

  AI_SetBuildingParams(TRIBE_GREEN, true, 60, 4);
  AI_SetTrainingHuts(TRIBE_GREEN, 0, 0, 0, 0);
  AI_SetTrainingPeople(TRIBE_GREEN, false, 0, 0, 0, 0, 0);
  AI_SetVehicleParams(TRIBE_GREEN, false, 0, 0, 0, 0);
  AI_SetFetchParams(TRIBE_GREEN, false, false, false, false);

  AI_SetAttackingParams(TRIBE_GREEN, false, 0, 25);
  AI_SetDefensiveParams(TRIBE_GREEN, true, true, true, true, 3, 1, 1);
  AI_SetSpyParams(TRIBE_GREEN, false, 0, 100, 128, 1);
  AI_SetPopulatingParams(TRIBE_GREEN, false, true);

  -- Cyan stuff
  AI_Initialize(TRIBE_CYAN);

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
  AI_SetShamanParams(TRIBE_CYAN, 0, 0, false, 0, 12);
  AI_SetMainDrumTower(TRIBE_CYAN, false, 0, 0);
  AI_SetConvertingParams(TRIBE_CYAN, true, true, 12);

  AI_SetBuildingParams(TRIBE_CYAN, true, 60, 4);
  AI_SetTrainingHuts(TRIBE_CYAN, 0, 0, 0, 0);
  AI_SetTrainingPeople(TRIBE_CYAN, false, 0, 0, 0, 0, 0);
  AI_SetVehicleParams(TRIBE_CYAN, false, 0, 0, 0, 0);
  AI_SetFetchParams(TRIBE_CYAN, false, false, false, false);

  AI_SetAttackingParams(TRIBE_CYAN, false, 0, 25);
  AI_SetDefensiveParams(TRIBE_CYAN, true, true, true, true, 3, 1, 1);
  AI_SetSpyParams(TRIBE_CYAN, false, 0, 100, 128, 1);
  AI_SetPopulatingParams(TRIBE_CYAN, false, true);

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

  AI_SetBuildingParams(TRIBE_PINK, true, 60, 4);
  AI_SetTrainingHuts(TRIBE_PINK, 0, 0, 0, 0);
  AI_SetTrainingPeople(TRIBE_PINK, false, 0, 0, 0, 0, 0);
  AI_SetVehicleParams(TRIBE_PINK, false, 0, 0, 0, 0);
  AI_SetFetchParams(TRIBE_PINK, false, false, false, false);

  AI_SetAttackingParams(TRIBE_PINK, false, 0, 25);
  AI_SetDefensiveParams(TRIBE_PINK, true, true, true, true, 3, 1, 1);
  AI_SetSpyParams(TRIBE_PINK, false, 0, 100, 128, 1);
  AI_SetPopulatingParams(TRIBE_PINK, false, true);
end

function _OnTurn(turn)
end

function _OnCreateThing(t)
end

function _OnPlayerDeath(pn)
end

function _OnFrame(w,h,guiW)
end

function _OnKeyUp(k)
end

function _OnKeyDown(k)
end
