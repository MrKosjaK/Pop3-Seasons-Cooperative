-- Includes
include("Common.lua");
include("Snow.lua");
include("Libs\\LbAreaInfo.lua");

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 3;
G_CONST.ComputerManaAdjustFactor = 256;

function _OnPostLevelInit(level_id)
  -- Ally ais
  -- for i = 1, #G_AI_ALIVE do
    -- for j = 1, #G_AI_ALIVE do
      -- set_players_allied(G_AI_ALIVE[i], G_AI_ALIVE[j]);
    -- end
  -- end
end

function _OnLevelInit(level_id)
  -- Green stuff
  -- AI_Initialize(TRIBE_GREEN);

  -- set_player_can_cast(M_SPELL_BLAST, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_CONVERT_WILD, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_WHIRLWIND, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_INSECT_PLAGUE, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_INVISIBILITY, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_HYPNOTISM, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_GHOST_ARMY, TRIBE_GREEN);
  -- set_player_can_cast(M_SPELL_EARTHQUAKE, TRIBE_GREEN);
  -- set_player_can_build(M_BUILDING_TEPEE, TRIBE_GREEN);
  -- set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_GREEN);
  -- set_player_can_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_GREEN);
  -- set_player_can_build(M_BUILDING_TEMPLE, TRIBE_GREEN);

  -- AI_SetAways(TRIBE_GREEN, 1, 0, 0, 0, 0);
  -- AI_SetShamanAway(TRIBE_GREEN, false);
  -- AI_SetShamanParams(TRIBE_GREEN, 54, 126, true, 16, 12);
  -- AI_SetMainDrumTower(TRIBE_GREEN, false, 62, 142);
  -- AI_SetConvertingParams(TRIBE_GREEN, false, false, 12);
  -- AI_SetTargetParams(TRIBE_GREEN, TRIBE_RED, true, true);

  -- AI_SetBuildingParams(TRIBE_GREEN, true, 60, 4);
  -- AI_SetTrainingHuts(TRIBE_GREEN, 0, 1, 0, 0);
  -- AI_SetTrainingPeople(TRIBE_GREEN, false, 0, 0, 0, 0, 0);
  -- AI_SetVehicleParams(TRIBE_GREEN, false, 0, 0, 0, 0);
  -- AI_SetFetchParams(TRIBE_GREEN, false, false, false, false);

  -- AI_SetAttackingParams(TRIBE_GREEN, true, 3, 0, 12);
  -- AI_SetDefensiveParams(TRIBE_GREEN, true, true, true, true, 3, 1, 1);
  -- AI_SetSpyParams(TRIBE_GREEN, false, 0, 100, 128, 1);
  -- AI_SetPopulatingParams(TRIBE_GREEN, true, true);

  -- AI_EnableBuckets(TRIBE_GREEN);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_BLAST, 1);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_CONVERT_WILD, 1);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_INSECT_PLAGUE, 5);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_INVISIBILITY, 4);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_LIGHTNING_BOLT, 7);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_HYPNOTISM, 8);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_EARTHQUAKE, 20);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_WHIRLWIND, 10);
  -- AI_SpellBucketCost(TRIBE_GREEN, M_SPELL_GHOST_ARMY, 3);

  --Cyan stuff
  -- AI_Initialize(TRIBE_CYAN);

  -- set_player_can_cast(M_SPELL_BLAST, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_CONVERT_WILD, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_WHIRLWIND, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_INSECT_PLAGUE, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_INVISIBILITY, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_HYPNOTISM, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_GHOST_ARMY, TRIBE_CYAN);
  -- set_player_can_cast(M_SPELL_EARTHQUAKE, TRIBE_CYAN);
  -- set_player_can_build(M_BUILDING_TEPEE, TRIBE_CYAN);
  -- set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_CYAN);
  -- set_player_can_build(M_BUILDING_SUPER_TRAIN, TRIBE_CYAN);
  -- set_player_can_build(M_BUILDING_TEMPLE, TRIBE_CYAN);

  -- AI_SetAways(TRIBE_CYAN, 1, 0, 0, 0, 0);
  -- AI_SetShamanAway(TRIBE_CYAN, false);
  -- AI_SetShamanParams(TRIBE_CYAN, 138, 128, true, 8, 12);
  -- AI_SetMainDrumTower(TRIBE_CYAN, false, 138, 128);
  -- AI_SetConvertingParams(TRIBE_CYAN, false, false, 12);
  -- AI_SetTargetParams(TRIBE_CYAN, TRIBE_BLUE, true, true);
  -- SET_SPELL_ENTRY(TRIBE_CYAN, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST) >> 2, 32, 1, 1);
  -- SET_SPELL_ENTRY(TRIBE_CYAN, 1, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST) >> 2, 32, 1, 0);

  -- AI_SetBuildingParams(TRIBE_CYAN, true, 18, 3);
  -- AI_SetTrainingHuts(TRIBE_CYAN, 0, 1, 0, 0);
  -- AI_SetTrainingPeople(TRIBE_CYAN, false, 0, 0, 0, 0, 0);
  -- AI_SetVehicleParams(TRIBE_CYAN, false, 0, 0, 0, 0);
  -- AI_SetFetchParams(TRIBE_CYAN, false, false, false, false);

  -- AI_SetAttackingParams(TRIBE_CYAN, true, 3, 0, 12);
  -- AI_SetDefensiveParams(TRIBE_CYAN, true, true, true, true, 3, 1, 1);
  -- AI_SetSpyParams(TRIBE_CYAN, false, 0, 100, 128, 1);
  -- AI_SetPopulatingParams(TRIBE_CYAN, true, true);

  -- AI_EnableBuckets(TRIBE_CYAN);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_BLAST, 1);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_CONVERT_WILD, 1);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INSECT_PLAGUE, 5);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INVISIBILITY, 4);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_LIGHTNING_BOLT, 7);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_HYPNOTISM, 8);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_EARTHQUAKE, 20);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_WHIRLWIND, 10);
  -- AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_GHOST_ARMY, 3);

  --Pink stuff
  -- AI_Initialize(TRIBE_PINK);

  -- set_player_can_cast(M_SPELL_BLAST, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_CONVERT_WILD, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_WHIRLWIND, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_INSECT_PLAGUE, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_INVISIBILITY, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_HYPNOTISM, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_GHOST_ARMY, TRIBE_PINK);
  -- set_player_can_cast(M_SPELL_EARTHQUAKE, TRIBE_PINK);
  -- set_player_can_build(M_BUILDING_TEPEE, TRIBE_PINK);
  -- set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_PINK);
  -- set_player_can_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_PINK);
  -- set_player_can_build(M_BUILDING_SUPER_TRAIN, TRIBE_PINK);

  -- AI_SetAways(TRIBE_PINK, 1, 0, 0, 0, 0);
  -- AI_SetShamanAway(TRIBE_PINK, false);
  -- AI_SetShamanParams(TRIBE_PINK, 222, 118, true, 16, 12);
  -- AI_SetMainDrumTower(TRIBE_PINK, false, 216, 158);
  -- AI_SetConvertingParams(TRIBE_PINK, false, false, 12);
  -- AI_SetTargetParams(TRIBE_PINK, TRIBE_YELLOW, true, true);

  -- AI_SetBuildingParams(TRIBE_PINK, true, 30, 2);
  -- AI_SetTrainingHuts(TRIBE_PINK, 0, 0, 1, 0);
  -- AI_SetTrainingPeople(TRIBE_PINK, true, 0, 0, 0, 0, 0);
  -- AI_SetVehicleParams(TRIBE_PINK, false, 0, 0, 0, 0);
  -- AI_SetFetchParams(TRIBE_PINK, false, false, false, false);

  -- AI_SetAttackingParams(TRIBE_PINK, true, 3, 0, 12);
  -- AI_SetDefensiveParams(TRIBE_PINK, true, true, true, true, 3, 1, 1);
  -- AI_SetSpyParams(TRIBE_PINK, false, 0, 100, 128, 1);
  -- AI_SetPopulatingParams(TRIBE_PINK, true, true);

  -- AI_EnableBuckets(TRIBE_PINK);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_BLAST, 1);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_CONVERT_WILD, 1);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_INSECT_PLAGUE, 5);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_INVISIBILITY, 4);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_LIGHTNING_BOLT, 7);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_HYPNOTISM, 8);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_EARTHQUAKE, 20);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_WHIRLWIND, 10);
  -- AI_SpellBucketCost(TRIBE_PINK, M_SPELL_GHOST_ARMY, 3);
  
  -- take away some of buildings from players, since it is yes. design choice
  -- set_player_cannot_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_BLUE);
  -- set_player_cannot_build(M_BUILDING_SUPER_TRAIN, TRIBE_RED);
  -- set_player_cannot_build(M_BUILDING_TEMPLE, TRIBE_YELLOW);
  
  set_correct_gui_menu();
end

function _OnTurn(turn)
  -- if (turn > 0) then
    -- if ((turn & (1 << 9)-1) == 0) then
      -- AIfasterSprogging(512);
    -- end
  -- end
  
  if ((turn % 4096) == 0) then
    createSnow(1000, 10, 16, 180, 12);
  end
end

function _OnCreateThing(t)
end

function _OnPlayerDeath(pn)
  if (G_PLR_PTR[pn].PlayerType == COMPUTER_PLAYER) then
    CompPlayer:deinit(pn);
  end
end

function _OnFrame(w,h,guiW)
end

function _OnKeyUp(k)
end

function _OnKeyDown(k)
end
