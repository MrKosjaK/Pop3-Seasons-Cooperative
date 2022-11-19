-- Includes
include("Common.lua");

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 2;

function _OnTurn(turn)
	if turn == 1 then afterInit() end
	
	local stage = G_GAMESTAGE

	for k,v in ipairs(G_AI_ALIVE) do
		Sulk(v,stage+3)
		trainingHutsPriorities(v)
		--small AI boosts lategame
		if minutes() > 15 then
			fasterTrain(v,32)
			fasterHutBars(v,8)
		end
		--priorities
		if everySeconds(12) then
			updateBasePriorities(v)
			if countHuts(v,false) > 1+stage+5 then
				WRITE_CP_ATTRIB(v, ATTR_PREF_BOAT_HUTS, 1);
			end
		end
	end
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





function trainingHutsPriorities(pn)
	
end

function _OnLevelInit(level_id)

	--stuff for AI
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
	set_player_can_cast(M_SPELL_FIRESTORM, TRIBE_CYAN);
	AI_EnableBuckets(TRIBE_CYAN);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_BLAST, 1);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_CONVERT_WILD, 1);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INSECT_PLAGUE, 5);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INVISIBILITY, 4);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_LIGHTNING_BOLT, 7);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_HYPNOTISM, 8);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_EARTHQUAKE, 20);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_FIRESTORM, 30);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_WHIRLWIND, 10);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_GHOST_ARMY, 3);
	
	set_player_can_build(M_BUILDING_TEPEE, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_SUPER_TRAIN, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_TEMPLE, TRIBE_CYAN);

	AI_SetAways(TRIBE_CYAN, 1, 0, 0, 0, 0);
	AI_SetShamanAway(TRIBE_CYAN, true);
	AI_SetShamanParams(TRIBE_CYAN, 180, 160, true, 16, 12);
	AI_SetMainDrumTower(TRIBE_CYAN, true, 180, 160);
	AI_SetConvertingParams(TRIBE_CYAN, true, true, 24);
	--AI_SetTargetParams(TRIBE_CYAN, TRIBE_BLUE, true, true);

	AI_SetBuildingParams(TRIBE_CYAN, true, 50, 3);
	AI_SetTrainingHuts(TRIBE_CYAN, 1, 0, 0, 0);
	AI_SetTrainingPeople(TRIBE_CYAN, true, 10, 0, 0, 0, 0);
	AI_SetVehicleParams(TRIBE_CYAN, false, 0, 0, 0, 0);
	AI_SetFetchParams(TRIBE_CYAN, true, true, true, true);

	AI_SetAttackingParams(TRIBE_CYAN, true, 255, 10);
	AI_SetDefensiveParams(TRIBE_CYAN, true, true, true, true, 3, 1, 1);
	AI_SetSpyParams(TRIBE_CYAN, false, 0, 100, 128, 1);
	AI_SetPopulatingParams(TRIBE_CYAN, true, true);
	
	-------------------------------------------------------------------------
	
	AI_Initialize(TRIBE_BLACK)
end

function afterInit()
	--stuff for humans
	for k,v in ipairs(G_HUMANS) do
		set_player_can_cast(M_SPELL_GHOST_ARMY, v);
		set_correct_gui_menu();
	end
end