-- Includes
include("Common.lua");
include("AI\\Scripts\\cyan_083.lua");
include("AI\\Scripts\\green_083.lua");
include("AI\\Scripts\\purple_083.lua");

Initialize_Special_AI("Cyan", TRIBE_CYAN);
Initialize_Special_AI("Green", TRIBE_GREEN);
Initialize_Special_AI("Purple", TRIBE_PINK);

-- Events
GetAI("Cyan"):RegisterEvent("Building", 256, 64, cyan_build);
GetAI("Cyan"):RegisterEvent("Convert", 128, 24, cyan_convert);
GetAI("Cyan"):RegisterEvent("Towers", 128, 32, cyan_towers);
GetAI("Cyan"):RegisterEvent("Patrol", 740, 112, function(player) end);
GetAI("Cyan"):RegisterEvent("Attacking", 1536, 256, cyan_attacking);
GetAI("Purple"):RegisterEvent("Convert", 122, 32, purple_convert);

-- Towers
GetAI("Cyan"):RegisterTower("Front1", 124, 104, -1);
GetAI("Cyan"):RegisterTower("Front2", 146, 106, -1);
GetAI("Cyan"):RegisterTower("Front3", 124, 96, -1);
GetAI("Cyan"):RegisterTower("MidHill1", 130, 76, -1);
GetAI("Cyan"):RegisterTower("MidHill2", 148, 78, -1);
GetAI("Cyan"):RegisterTower("MidHill3", 138, 78, -1);

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 3;

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
  AI_SetMainDrumTower(TRIBE_CYAN, false, 138, 128);
  AI_SetConvertingParams(TRIBE_CYAN, false, true, 12);
  AI_SetTargetParams(TRIBE_CYAN, TRIBE_BLUE, true, true);

  AI_SetBuildingParams(TRIBE_CYAN, true, 18, 3);
  AI_SetTrainingHuts(TRIBE_CYAN, 0, 0, 0, 0);
  AI_SetTrainingPeople(TRIBE_CYAN, false, 0, 0, 0, 0, 0);
  AI_SetVehicleParams(TRIBE_CYAN, false, 0, 0, 0, 0);
  AI_SetFetchParams(TRIBE_CYAN, false, false, false, false);

  AI_SetAttackingParams(TRIBE_CYAN, true, 4, 25);
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
  AI_SetConvertingParams(TRIBE_PINK, false, true, 12);
  AI_SetTargetParams(TRIBE_PINK, TRIBE_YELLOW, true, true);

  AI_SetBuildingParams(TRIBE_PINK, false, 60, 4);
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
