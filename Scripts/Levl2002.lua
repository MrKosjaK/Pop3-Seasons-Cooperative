-- Includes
include("Common.lua");
include("snow.lua");

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 2;

function _OnTurn(turn)
	if turn == 1 then afterInit() end
	
	local stage = G_GAMESTAGE
	
	------------------------------------------------------------------------------------------------------------------------
	-- AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	if stage > 0 then
		--build towers
		if everySeconds(180-stage*20) then
			local ct = countTowers(TRIBE_CYAN,true)
			if ct < 2 then
				BUILD_DRUM_TOWER(TRIBE_CYAN,rndb(136,216),rndb(138,186))
			end
			local bt = countTowers(TRIBE_BLACK,true)
			if ct < 6 then
				BUILD_DRUM_TOWER(TRIBE_BLACK,rndb(20,46),rndb(18,62))
			end
		end
	end
	if stage > 1 then
		--burn trees
		local cdr = 40-stage*3
		if rnd() > 50 then
			burnTrees(cdr,TRIBE_CYAN,42,124,12)
			burnTrees(cdr,TRIBE_BLACK,42,124,12)
		else
			burnTrees(cdr,TRIBE_CYAN,88,6,12)
			burnTrees(cdr,TRIBE_BLACK,88,6,12)
		end
	end

	--Process AIs on turn
	for k,v in ipairs(G_AI_ALIVE) do
		Sulk(v,stage+3)
		--small AI boosts lategame
		if minutes() > 15 then
			fasterTrain(v,8+8*stage)
			fasterHutBars(v,4+2*stage)
		end
		--priorities
		if everySeconds(12) then
			updateBasePriorities(v)
			unstuckS(v)
			trainingHutsPriorities(v)
		end
		--update lb expand tbl
		if everySeconds(1) then
			if G_AI_EXPANSION_TABLE[v][1] > 0 then G_AI_EXPANSION_TABLE[v][1] = G_AI_EXPANSION_TABLE[v][1] - 1 end
			if G_AI_EXPANSION_TABLE[v][1] == 0 and not G_AI_EXPANSION_TABLE[v][4] then
				if v == TRIBE_CYAN then
					LBexpand(v,9+stage,rndb(120,180),false) --pn,radius,cooldownSecondsIncrement,requiresLBmana
				end
			end
			tryToLB(v)
		end
	end
	
	if everySeconds(15) then
		updateVehiclesBuild()
		updateConvertParams()
		updateSpellBuckets(stage)
		updateAtkSpells(stage) --use this b4 ttack
	end
	
	------------------------------------------------------------------------------------------------------------------------
	-- NON-AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	--snowing 3 times during level
	--snowAmtTarget, CreationAmtPerSecCreation, speed, (durationSeconds, internTimer), fadeSeconds
	if turn == 1000 then
		createSnow(1700, 50, 48, 60*3, 60*3, 12)
	elseif turn == 7000 then
		createSnow(700, 100, 32, 60*1, 60*1, 3)
	elseif turn == 13000 then
		createSnow(1200, 50, 78, 60*2, 60*2, 24)
	end
	
	--debug
	--local f,a,b,c = #AI_CYAN_ATK_SPELLS,AI_CYAN_ATK_SPELLS[1],AI_CYAN_ATK_SPELLS[2],AI_CYAN_ATK_SPELLS[3]
	--LOG(string.format("atk spells num: %s     %s|%s|%s",f, a,b,c))
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

------------------------------------------------------------------------------------------------------------------------

function updateAtkSpells(s)
	AI_CYAN_ATK_SPELLS = {}
	
	--
	local spellList = {}
	local function SpellPicker(possibilitiesTbl,aiTbl)
		for i = 1,3 do
			local k = rndb(0,#possibilitiesTbl)
			table.insert(aiTbl,possibilitiesTbl[k])
			table.remove(possibilitiesTbl,k)
		end		
	end
	if s == 0 then
		spellList = {M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND}
	elseif s == 1 then
		spellList = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM}
	elseif s == 2 then
		spellList = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWINDM_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE}
	elseif s == 3 then
		spellList = {M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM}
	else
		spellList = {M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM}
	end
	SpellPicker(spellList,AI_CYAN_ATK_SPELLS)
	--feel the need to use SHIELD/INVI?
	if s > 1 then
		local chance = 20+s*10 --40-60% chance
		if rnd() < chance then
			AI_CYAN_ATK_SPELLS[1] = M_SPELL_INVISIBILITY
		end
	end
end

function updateSpellBuckets(s)
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_BLAST, 1);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_CONVERT_WILD, 2);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INSECT_PLAGUE, 6-s);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INVISIBILITY, 13-s);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_LIGHTNING_BOLT, 11-s);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_HYPNOTISM, 16-s);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_EARTHQUAKE, 32-s);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_FIRESTORM, 48-s);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_WHIRLWIND, 18-s);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_GHOST_ARMY, 8-s);
	--
	
end

function updateConvertParams()
	local pn = TRIBE_CYAN
	local cv = btn(GetPop(pn)>20+20*G_GAMESTAGE)
	STATE_SET(pn, cv, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS)
	WRITE_CP_ATTRIB(pn, ATTR_EXPANSION, 15+10*G_GAMESTAGE)
end

function updateVehiclesBuild()
	local pn = TRIBE_CYAN
	WRITE_CP_ATTRIB(pn, CP_AT_TYPE_BUILD_VEHICLE, btn(_gsi.Players[pn].NumVehiclesOfType[M_VEHICLE_BOAT_1] > 3))
end

function trainingHutsPriorities(pn)
	local pop,huts,s = GetPop(pn),countHuts(pn,false),G_GAMESTAGE
	
	WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_TRAINS, btn(huts > 2))
	--WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_TRAINS, btn(huts > 4))
	WRITE_CP_ATTRIB(pn, ATTR_PREF_RELIGIOUS_TRAINS, btn(huts > 6))
	--WRITE_CP_ATTRIB(pn, ATTR_PREF_SPY_TRAINS, btn(huts > 4))
	WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_HUTS, btn(countHuts(pn,false) > 1+s+4))
	--WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_HUTS, btn(countHuts(pn,false) > 1+stage+7))
	
	--local w,t,fw,s = AI_GetBldgCount(pn, M_BUILDING_WARRIOR_TRAIN),AI_GetBldgCount(pn, M_BUILDING_TEMPLE), AI_GetBldgCount(pn, M_BUILDING_SUPER_TRAIN),AI_GetBldgCount(pn, M_BUILDING_SPY_TRAIN)
	
	if pn == TRIBE_CYAN then
		WriteAiTrainTroops(pn, 1+(s*2)+15 ,1+(s*2)+15, 0, 0) --w,pr,fw,s
	else -- black
		WriteAiTrainTroops(pn, 1+(s*2)+15 , 0, 1+(s*2)+15, 0) --w,pr,fw,s
	end
end

------------------------------------------------------------------------------------------------------------------------

AI_CYAN_SPELLS = {
M_SPELL_BLAST,M_SPELL_CONVERT_WILD,
M_SPELL_GHOST_ARMY,
M_SPELL_LIGHTNING_BOLT,
M_SPELL_WHIRLWIND,
M_SPELL_INSECT_PLAGUE,
M_SPELL_INVISIBILITY,
M_SPELL_HYPNOTISM,
M_SPELL_EARTHQUAKE,
M_SPELL_FIRESTORM
}

AI_CYAN_ATK_SPELLS = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND}






function _OnLevelInit(level_id)
	--scenery
	for i = 5,55 do Plant(i,i,-1) end

	--stuff for AI
	AI_Initialize(TRIBE_CYAN);

	for k,v in ipairs(AI_CYAN_SPELLS) do
		set_player_can_cast(v, TRIBE_CYAN);
	end
	AI_EnableBuckets(TRIBE_CYAN);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_BLAST, 1);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_CONVERT_WILD, 2);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INSECT_PLAGUE, 6);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_INVISIBILITY, 13);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_LIGHTNING_BOLT, 11);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_HYPNOTISM, 16);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_EARTHQUAKE, 32);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_FIRESTORM, 48);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_WHIRLWIND, 18);
	AI_SpellBucketCost(TRIBE_CYAN, M_SPELL_GHOST_ARMY, 8);
	
	set_player_can_build(M_BUILDING_TEPEE, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_WARRIOR_TRAIN, TRIBE_CYAN);
	--set_player_can_build(M_BUILDING_SUPER_TRAIN, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_TEMPLE, TRIBE_CYAN);
	set_player_can_build(M_BUILDING_BOAT_HUT_1, TRIBE_CYAN);
	--set_player_can_build(M_BUILDING_AIRSHIP_HUT_1, TRIBE_CYAN);

	AI_SetAways(TRIBE_CYAN, 1, 0, 0, 0, 0);
	AI_SetShamanAway(TRIBE_CYAN, true);
	AI_SetShamanParams(TRIBE_CYAN, 180, 160, true, 16, 12);
	AI_SetMainDrumTower(TRIBE_CYAN, true, 180, 160);
	AI_SetConvertingParams(TRIBE_CYAN, false, false, 24);
	AI_SetTargetParams(TRIBE_CYAN, TRIBE_BLUE, true, true);

	AI_SetBuildingParams(TRIBE_CYAN, true, 50, 3);
	AI_SetTrainingHuts(TRIBE_CYAN, 0, 0, 0, 0);
	AI_SetTrainingPeople(TRIBE_CYAN, true, 10, 0, 0, 0, 0);
	AI_SetVehicleParams(TRIBE_CYAN, false, 0, 0, 0, 0);
	--AI_SetFetchParams(TRIBE_CYAN, true, true, true, true);

	AI_SetAttackingParams(TRIBE_CYAN, true, 255, 10);
	AI_SetDefensiveParams(TRIBE_CYAN, true, true, true, true, 3, 1, 1);
	AI_SetSpyParams(TRIBE_CYAN, false, 0, 100, 128, 1);
	AI_SetPopulatingParams(TRIBE_CYAN, true, true);
	
	-------------------------------------------------------------------------
	
	AI_Initialize(TRIBE_BLACK)
end

function afterInit()
	--stuff for humans
	set_player_can_cast(M_SPELL_LAND_BRIDGE, TRIBE_BLUE);
	set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_INVISIBILITY, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_FIRESTORM, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_HYPNOTISM, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_EARTHQUAKE, TRIBE_RED);
	for k,v in ipairs(G_HUMANS) do
		set_player_can_cast(M_SPELL_GHOST_ARMY, v);
		set_correct_gui_menu();
	end
	--stuff for AI
	G_AI_EXPANSION_TABLE[TRIBE_CYAN][1] = G_AI_EXPANSION_TABLE[TRIBE_CYAN][1] + rndb(60,120)
end


--to do:
--attacks
--patrols
--black tribe