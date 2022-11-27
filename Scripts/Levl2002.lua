-- Includes
include("Common.lua");
include("snow.lua");

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 2;

function _OnTurn(turn)

	local stage = G_GAMESTAGE
	
	------------------------------------------------------------------------------------------------------------------------
	-- AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	--early warrior/maybe preachers boat attacks
	if turn < 5001 and turn % 1000 == 0 then
		if countBoats(TRIBE_CYAN) > 1 then
			local target = TRIBE_RED
			if rnd() > 70 then target = TRIBE_BLUE end
			local warriors,preachers = 100,0 if rnd() > 80 then preachers = 50 warriors = 50 end
			WriteAiAttackers(TRIBE_CYAN,warriors,100,preachers,0,0,0)
			AI_SetAttackFlags(TRIBE_CYAN,3,1,0)
			local targetType = ATTACK_PERSON
			if countHuts(TRIBE_CYAN,true) > 0 then targetType = ATTACK_BUILDING end
			ATTACK(TRIBE_CYAN,TRIBE_BLUE,5,targetType,0,999,0,0,0,ATTACK_BY_BOAT,TRUE,-1,-1,-1)
		end
	end
	
	if stage > 0 then
		--build towers
		if everySeconds(180-stage*20) then
			local ct = countTowers(TRIBE_CYAN,true)
			if ct < 2 then
				BUILD_DRUM_TOWER(TRIBE_CYAN,rndb(136,216),rndb(138,186))
			end
			local bt = countTowers(TRIBE_BLACK,true)
			if bt < 6 then
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
	
	if everySeconds(6-stage) then
		ProcessDefensiveShaman()
	end
	if everySeconds(3) then
		ProcessAgressiveShaman()
		ProcessUnitMoveTbl()
		ProcessIslandStalagtites()
		for i = #unitAtkunitTbl,1,-1 do unstuckT(unitAtkunitTbl[i]) table.remove(unitAtkunitTbl,i) end
	end
	if everySeconds(8) then
		FillRndEmptyTower(TRIBE_CYAN,2)
		updateSpellEntries()
		updateMarkerPatrols()
	end
	if everySeconds(15) then
		updateVehiclesBuild()
		updateConvertParams()
		updateSpellBuckets(stage)
		updateAtkSpells(stage) --use this b4 ttack
	end
	if everySeconds(30-stage) then
		DefensivePreachMarkers()
		DefendStoneHead(68)
	end
	if everySeconds(180-stage*10) then
		OffensivePreachMarkers()
	end	
	------------------------------------------------------------------------------------------------------------------------
	-- NON-AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	--snowing 3 times during level
	--snowAmtTarget, CreationAmtPerSecCreation, speed, (durationSeconds, internTimer), fadeSeconds
	if turn == 1000 then
		createSnow(1700, 50, 32, 60*3, 60*3, 12)
	elseif turn == 7000 then
		createSnow(700, 100, 24, 60*1, 60*1, 3)
	elseif turn == 13000 then
		createSnow(1200, 50, 42, 60*2, 60*2, 24)
	end
	--process stalagtites
	StalagtitesFalling()
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
	if k == LB_KEY_A then
		
	elseif k == LB_KEY_B then
		
	end
end
------------------------------------------------------------------------------------------------------------------------
function updateMarkerPatrols()
	local pn = TRIBE_CYAN
	SET_MARKER_ENTRY(pn, 0, 69, 70, 0, 1, 0, 1)
	MARKER_ENTRIES(pn, 0,-1,-1,-1)
	--VEHICLE_PATROL(pn, 3, 71,72,73,74, M_VEHICLE_BOAT_1) --gl with that lol
end

function ProcessDefensiveShaman()
	local pn = TRIBE_CYAN
	if isShamanHome(pn,0,24) then --pn,mk,rad
		GetRidOfNearbyEnemies(pn,1)
		TargetNearbyShamans(pn,9+G_GAMESTAGE,30+G_GAMESTAGE*10)
	end
end

function ProcessAgressiveShaman()
	local pn = TRIBE_CYAN
	if not isShamanHome(pn,0,24) then --pn,mk,rad
		GetRidOfNearbyEnemies(pn,1)
		TargetNearbyShamans(pn,9+G_GAMESTAGE,20+G_GAMESTAGE*15)
	end	
end

function updateSpellEntries(marker,radius)
	local s = G_GAMESTAGE
	local pn,marker,radius = TRIBE_CYAN,0,24
	if IS_SHAMAN_IN_AREA(pn,marker,radius) then
		SET_SPELL_ENTRY(pn, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST) >> (1+s), 128, 1, 1)
		SET_SPELL_ENTRY(pn, 1, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> (1+s), 128, 5-s, 1)
		SET_SPELL_ENTRY(pn, 2, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> (1+s), 128, 5, 1)
		if s > 1 then
			SET_SPELL_ENTRY(pn, 3, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> (1+s), 128, 16-(s*2), 1)
		end
	else
		SET_SPELL_ENTRY(pn, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST) >> (1+s), 128, 1, 0)
		SET_SPELL_ENTRY(pn, 1, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_BLAST) >> (1+s), 128, 2, 0)
		SET_SPELL_ENTRY(pn, 2, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> (1+s), 128, 7, 0)
		if s > 0 then
			SET_SPELL_ENTRY(pn, 3, M_SPELL_GHOST_ARMY, 5000, 128, 6-s, 0)
		end
		if s > 1 then
			SET_SPELL_ENTRY(pn, 4, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> (1+s), 128, 12-s, 0)
		end
		if s > 2 then
			SET_SPELL_ENTRY(pn, 5, M_SPELL_FIRESTORM, 150000, 128, 24-s, 0)
		end
	end
	local pn = TRIBE_BLACK,1,16
	
end



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

function DefensivePreachMarkers()
	local tribe = TRIBE_CYAN
	local markers = {} for i = 56,60 do table.insert(markers,i) end
	if _gsi.Players[tribe].NumPeopleOfType[M_PERSON_RELIGIOUS] > 3 then
		for k,v in ipairs(markers) do
			PREACH_AT_MARKER(tribe,v)
		end
	end
end

function OffensivePreachMarkers()
	if G_GAMESTAGE > 1 then
		local tribe = TRIBE_CYAN
		local markers = {}
		if GetPop(1) > 0 then for i = 61,63 do table.insert(markers,i) end else for i = 64,67 do table.insert(markers,i) end end
		if _gsi.Players[tribe].NumPeopleOfType[M_PERSON_RELIGIOUS] > 3 then
			for k,v in ipairs(markers) do
				PREACH_AT_MARKER(tribe,v)
			end
		end
	end
end

function DefendStoneHead(mk)
	--stone heads defending by cyan
	if countBoats(TRIBE_CYAN) > 0 then
		if countPeopleInArea(TRIBE_BLUE,mk,0) > 0 or countPeopleInArea(TRIBE_RED,mk,0) > 0 then
			PREACH_AT_MARKER(TRIBE_CYAN,mk)
			if rnd() < 40 and AI_ShamanFree(TRIBE_CYAN) then
				local spellsTbl = {M_SPELL_BLAST,M_SPELL_LIGHTNING_BOLT,M_SPELL_INSECT_PLAGUE,M_SPELL_SWAMP}
				local s = randomItemFromTable(spellsTbl)
				GIVE_ONE_SHOT(s,TRIBE_CYAN)
				SPELL_ATTACK(TRIBE_CYAN,s,mk,mk)
			end
		end
	end
end

function updateSpellBuckets(s)
	local tribe = TRIBE_CYAN
	AI_SpellBucketCost(tribe, M_SPELL_BLAST, 1);
	AI_SpellBucketCost(tribe, M_SPELL_CONVERT_WILD, 2);
	AI_SpellBucketCost(tribe, M_SPELL_INSECT_PLAGUE, 6-s);
	AI_SpellBucketCost(tribe, M_SPELL_INVISIBILITY, 13-s);
	AI_SpellBucketCost(tribe, M_SPELL_LIGHTNING_BOLT, 11-s);
	AI_SpellBucketCost(tribe, M_SPELL_HYPNOTISM, 16-s);
	AI_SpellBucketCost(tribe, M_SPELL_EARTHQUAKE, 32-s);
	AI_SpellBucketCost(tribe, M_SPELL_FIRESTORM, 48-s);
	AI_SpellBucketCost(tribe, M_SPELL_WHIRLWIND, 18-s);
	AI_SpellBucketCost(tribe, M_SPELL_GHOST_ARMY, 8-s);
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
	STATE_SET(pn, btn(countBoats(pn) < 3), CP_AT_TYPE_BUILD_VEHICLE)
	STATE_SET(pn, btn(countBoats(pn) > 0), CP_AT_TYPE_FETCH_LOST_VEHICLE)
	STATE_SET(pn, btn(countBoats(pn) > 0), CP_AT_TYPE_FETCH_FAR_VEHICLE)
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

--update base priorities
function updateBasePriorities(pn)
	updateGameStage(5,10,15,20)
	local s,h,b = G_GAMESTAGE, countHuts(pn,true), AI_GetUnitCount(pn, M_PERSON_BRAVE)
	--local t,p = countTroops(pn), GetPop(pn)
	AI_SetBuildingParams(pn,true,60+s*15,3)
	if b > 20+(s*5) and h > 6+s then
		if AI_GetBldgCount(pn, M_BUILDING_BOAT_HUT_1) > 0 then
			WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_DRIVERS, 1+s+2);
			WRITE_CP_ATTRIB(pn, ATTR_PEOPLE_PER_BOAT, 1+s+2);
		else
			WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_DRIVERS, 0);
			WRITE_CP_ATTRIB(pn, ATTR_PEOPLE_PER_BOAT, 0);
		end
		if AI_GetBldgCount(pn, M_BUILDING_AIRSHIP_HUT_1) > 0 then
			WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_DRIVERS, 1+s+2);
			WRITE_CP_ATTRIB(pn, ATTR_PEOPLE_PER_BALLOON, 1+s+2);
		else
			WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_DRIVERS, 0);
			WRITE_CP_ATTRIB(pn, ATTR_PEOPLE_PER_BALLOON, 0);
		end
	end
end
------------------------------------------------------------------------------------------------------------------------

AI_CYAN_SPELLS = {
M_SPELL_BLAST,
M_SPELL_CONVERT_WILD,
M_SPELL_GHOST_ARMY,
M_SPELL_LAND_BRIDGE,
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
	AI_SetFetchParams(TRIBE_CYAN, true, true, true, true);

	AI_SetAttackingParams(TRIBE_CYAN, true, 255, 10);
	AI_SetDefensiveParams(TRIBE_CYAN, true, true, true, true, 3, 2, 1);
	AI_SetSpyParams(TRIBE_CYAN, false, 0, 100, 128, 1);
	AI_SetPopulatingParams(TRIBE_CYAN, true, true);
	
	-------------------------------------------------------------------------
	
	AI_Initialize(TRIBE_BLACK)
end

function _OnPostLevelInit(level_id)
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
	SET_DEFENCE_RADIUS(TRIBE_CYAN,9)
	SET_DEFENCE_RADIUS(TRIBE_BLACK,7)
end

------------------------------------------------------------------------------------------------------------------------
stalagtites = {0,true,{},false} --cdr in seconds,active,things,falling
function ProcessIslandStalagtites()
	if stalagtites[1] > 0 then
		stalagtites[1] = stalagtites[1] - 3
	else
		if not stalagtites[2] then
			stalagtites[2] = true
			createStalagtites(68,3)
		else
			if countPeopleInArea(0,68,0) > 2 or countPeopleInArea(1,68,0) > 2 then
				stalagtites[1] = 80 --seconds
				stalagtites[2] = false
				stalagtites[4] = true
			end
		end
	end
end
function createStalagtites(marker,radius)
	stalagtites = {0,true,{},false}
	SearchMapCells(SQUARE, 0, 0 , radius, world_coord3d_to_map_idx(marker_to_coord3d(marker)), function(me)
		if rnd() < 30 then
			local stalag = createThing(T_EFFECT,60,8,me2c3d(me),false,false) stalag.u.Effect.Duration = -1 stalag.Pos.D3.Ypos = rndb(800,1300)
			stalag.DrawInfo.Alpha = -16 set_thing_draw_info(stalag,TDI_SPRITE_F1_D1, rndb(1785,1787)) stalag.DrawInfo.Flags = EnableFlag(stalag.DrawInfo.Flags, DF_USE_ENGINE_SHADOW)
			table.insert(stalagtites[3],{stalag,rnd(2,16)})
		end
	return true end)
end
function StalagtitesFalling()
	if stalagtites[4] then
		for k,v in ipairs(stalagtites[3]) do
			if v[2] > 0 then v[2] = v[2] - 1
				move_thing_within_mapwho(v[1], MoveC3d(v[1].Pos.D3,16,false))
			else
				if v[1].Pos.D3.Ypos > 2 then
					v[1].Pos.D3.Ypos = v[1].Pos.D3.Ypos - rndb(86,96)
				else
					local boom = createThing(T_EFFECT,M_EFFECT_SPHERE_EXPLODE_1 ,8,v[1].Pos.D3,false,false)
					queue_sound_event(boom,SND_EVENT_BEAMDOWN, 0)
					SearchMapCells(SQUARE, 0, 0 , 1, world_coord3d_to_map_idx(boom.Pos.D3), function(me)
						me.MapWhoList:processList( function (t)
							if t.Type == T_PERSON then
								t.u.Pers.Life = rndb(1,200) if rnd() < 60 then t.u.Pers.Life = 0 end
							end
						return true end)
					return true end)
					table.remove(stalagtites[3],k)
					delete_thing_type(v[1])
				end
			end
		end
	end
end
createStalagtites(68,3)


--to do:
--attacks
--patrols
--black tribe