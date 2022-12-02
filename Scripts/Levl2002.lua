-- Includes
include("Common.lua");
include("snow.lua");
include("Spells\\TiledSwamp.lua");
SwampTileEnabled = true
SwampTileAffectAllies = true
SwampTileDuration = 12*15
SwampTileRandomness = 12*5

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 2;
local tribe1 = TRIBE_CYAN
local tribe2 = TRIBE_BLACK
local TRIBE1atk = 2500 + (rndb(0,500))
local TRIBE2atk = 2000 + (rndb(0,500))

function _OnTurn(turn)

	local stage = G_GAMESTAGE
	
	------------------------------------------------------------------------------------------------------------------------
	-- AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	--early warrior/maybe preachers boat attacks
	if turn < 5001 and turn % 1000 == 0 then
		if countBoats(tribe1) > 1 then
			local target = TRIBE_RED
			if rnd() > 70 then target = TRIBE_BLUE end
			local warriors,preachers = 100,0 if rnd() > 80 then preachers = 50 warriors = 50 end
			WriteAiAttackers(tribe1,warriors,100,preachers,0,0,0)
			AI_SetAttackFlags(tribe1,3,1,0)
			local targetType = ATTACK_PERSON
			if countHuts(tribe1,true) > 0 then targetType = ATTACK_BUILDING end
			ATTACK(tribe1,TRIBE_BLUE,5,targetType,0,999,0,0,0,ATTACK_BY_BOAT,TRUE,-1,-1,-1)
		end
	end
	
	if stage > 0 then
		--build towers
		if everySeconds(180-stage*20) then
			local ct = countTowers(tribe1,true)
			if ct < 2 then
				BUILD_DRUM_TOWER(tribe1,rndb(136,216),rndb(138,186))
			end
			local bt = countTowers(tribe2,true)
			if bt < 6 then
				BUILD_DRUM_TOWER(tribe2,rndb(20,46),rndb(18,62))
			end
		end
	end
	if stage > 1 then
		--burn trees
		local cdr = 40-stage*3
		if rnd() > 50 then
			burnTrees(cdr,tribe1,42,124,12)
			burnTrees(cdr,tribe2,42,124,12)
		else
			burnTrees(cdr,tribe1,88,6,12)
			burnTrees(cdr,tribe2,88,6,12)
		end
	end

	--Process AIs on turn
	for k,v in ipairs(G_AI_ALIVE) do
		Sulk(v,stage+3)
		--small AI boosts lategame
		if minutes() > 5 then
			fasterTrain(v,8+8*stage)
			fasterHutBars(v,4+2*stage,false)
		end
		--priorities
		if everySeconds(12) then
			updateGameStage(6,12,18,24)
			updateBasePriorities(v)
			unstuckS(v)
			trainingHutsPriorities(v)
		end
		--update lb expand tbl
		if v == tribe1 then
			if everySeconds(1) then
				if G_AI_EXPANSION_TABLE[v][1] > 0 then G_AI_EXPANSION_TABLE[v][1] = G_AI_EXPANSION_TABLE[v][1] - 1 end
				if G_AI_EXPANSION_TABLE[v][1] == 0 and not G_AI_EXPANSION_TABLE[v][4] then
					LBexpand(v,9+stage,rndb(120,180),false) --pn,radius,cooldownSecondsIncrement,requiresLBmana
				end
				tryToLB(v)
			end
		end
	end
	--attacks cdr
	if TRIBE1atk < turn then TRIBE1atk = TRIBE1atk - 1 elseif TRIBE1atk == turn then attack(tribe1) end
	if TRIBE2atk < turn then TRIBE2atk = TRIBE2atk - 1 elseif TRIBE2atk == turn then attack(tribe2) end
	
	if everySeconds(3) then
		ProcessAgressiveShaman()
		ProcessUnitMoveTbl()
		ProcessIslandStalagtites()
		for i = #unitAtkunitTbl,1,-1 do unstuckT(unitAtkunitTbl[i]) table.remove(unitAtkunitTbl,i) end
	end
	if everySeconds(7-stage) then
		ProcessDefensiveShaman()
	end
	if everySeconds(8) then
		FillRndEmptyTower(tribe1,M_PERSON_RELIGIOUS)
		FillRndEmptyTower(tribe2,M_PERSON_SUPER_WARRIOR)
		updateSpellEntries()
	end
	if everySeconds(15) then
		giveSpellsOccasionally()
		updateVehiclesBuild()
		updateConvertParams()
		updateSpellBuckets(stage)
		MARKER_ENTRIES(tribe2, 5,6,-1,-1) --base wars patrol
	end
	if everySeconds(30-stage) then
		DefensivePreachMarkers()
		DefendStoneHead(68)
		DefendStoneHead(94)
		updateTroopsAndAtkParams()
		--tribe1
		MARKER_ENTRIES(tribe1, 0,-1,-1,-1) --base big patrol
		--tribe2
		MARKER_ENTRIES(tribe2, 0,1,2,3) --base fws patrol
		if stage > 1 and AI_GetUnitCount(tribe2,M_PERSON_SUPER_WARRIOR) > 4 then
			MARKER_ENTRIES(tribe2, 4,-1,-1,-1) --extra patrol base
		end
	end
	if everySeconds(120-stage*20) then
		ReconnectToEnemies()
	end
	if everySeconds(120-stage*10) then
		local targ = randomItemFromTable(G_HUMANS_ALIVE)
		if nilT(targ) then
			local mk = 2 if targ == TRIBE_RED then mk = 39 end
			if countTroops(tribe2) > 10 then
				if NavCheck(tribe2,targ,marker_to_coord3d(mk)) then
					local mk1,mk2,mk3,mk4,mk5 = 86,85,84,83,87
					if targ == TRIBE_BLUE then mk1,mk2,mk3,mk4,mk5 = 88,90,rndb(91,92),93,89 end
					SET_MARKER_ENTRY(tribe2, 7, mk1, mk5, 1, math.max(2,stage), 1, 0)
					SET_MARKER_ENTRY(tribe2, 8, mk2, -1, 1, math.max(2,stage), 1, 0)
					SET_MARKER_ENTRY(tribe2, 9, mk3, mk3, 0, 2, 0, 0)
					SET_MARKER_ENTRY(tribe2, 10, mk4, mk4, 0, 2, 0, 0)
					MARKER_ENTRIES(tribe2,7,8,9,10)
				end
			end
		end
	end
	if everySeconds(180-stage*10) then
		OffensivePreachMarkers()
	end	
	if (everySeconds(240-stage*rndb(5,35)) and rnd() > 50) or (GetPop(TRIBE_RED) < 6 and everySeconds(30)) then
		BlackConnectBlue()
	end
	------------------------------------------------------------------------------------------------------------------------
	-- NON-AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	--snowing 3 times during level
	--snowAmtTarget, AmtPerSecCreation, speed, (durationSeconds, internTimer), fadeSeconds
	if turn == 1000 then
		createSnow(1700, 50, 32, 60*3, 12)
	elseif turn == 7000 then
		createSnow(700, 100, 20, 60*1, 3)
	elseif turn == 13000 then
		createSnow(1200, 50, 42, 60*2, 24)
	elseif turn == 21000 then
		createSnow(900, 30, 24, 60*3, 16)
	elseif turn == 29000 then
		createSnow(1000, 100, 28, 60*2, 32)
	end
	--process stalagtites
	StalagtitesFalling()
	ProcessTiledSwamps()
end

function _OnCreateThing(t)
	if t.Type == T_SPELL and t.Model == M_SPELL_LIGHTNING_BOLT then
		if isItemInTable(G_HUMANS_ALIVE,t.Owner) then
			dodgeLightnings(t.Owner,60+G_GAMESTAGE*10,t) --AI chance to dodge lights
		end
	end
	ProcessSwampCreate(t)
end

function _OnKeyDown(k)
	if k == LB_KEY_A then
		
	elseif k == LB_KEY_Q then
		
	end
end

------------------------------------------------------------------------------------------------------------------------
-- LEVEL FUNCTIONS
------------------------------------------------------------------------------------------------------------------------

function attack(attacker)
	local success = 0
	if #G_HUMANS_ALIVE > 0 then --wont bother to continue level(attack) if only AIs exist
		if AI_EntryAvailable(attacker) then
			local stage = G_GAMESTAGE
			local target = -1
			if attacker == tribe1 then target = iipp(TRIBE_BLUE,TRIBE_RED,20,80) else target = iipp(TRIBE_BLUE,TRIBE_RED,40,60) end --**
			if #G_HUMANS_ALIVE == 1 then target = randomItemFromTable(G_HUMANS_ALIVE) end
			local troops = countTroops(attacker)
			if troops > 4 + stage*2 then
				local numTroops = 4 + stage*2 --**
				if IS_SHAMAN_AVAILABLE_FOR_ATTACK(attacker) == 0 then WRITE_CP_ATTRIB(attacker, ATTR_AWAY_MEDICINE_MAN, 0) else WRITE_CP_ATTRIB(attacker, ATTR_AWAY_MEDICINE_MAN, btn(rnd() < 80+10*stage)) end
				local atkType = ATTACK_NORMAL
				local boats,balloons = countBoats(attacker),countBalloons(attacker)
				if (boats > 0 or balloons > 0) and READ_CP_ATTRIB(attacker,ATTR_DONT_USE_BOATS) == 0 then
					atkType = iipp(ATTACK_NORMAL,-1,60,40) --**
					if atkType == -1 then
						if (boats > 0 and balloons > 0) then
							atkType = iipp(ATTACK_BY_BOAT,ATTACK_BY_BALLOON,50,50) --**
						else
							if boats > 0 then atkType = ATTACK_BY_BOAT else atkType = ATTACK_BY_BALLOON end
						end
					end
				end
				if attacker == tribe1 then atkType = ATTACK_BY_BOAT end --X
				if atkType == ATTACK_NORMAL or ((atkType == ATTACK_BY_BOAT and countBoats(attacker) > 0) and (atkType == ATTACK_BY_BALLOON and countBalloons(attacker) > 0)) then
					if stage < 2 then
						WRITE_CP_ATTRIB(attacker, ATTR_BASE_UNDER_ATTACK_RETREAT, 1) WRITE_CP_ATTRIB(attacker, ATTR_RETREAT_VALUE, rndb(0,12))
					else
						WRITE_CP_ATTRIB(attacker, ATTR_BASE_UNDER_ATTACK_RETREAT, 0) WRITE_CP_ATTRIB(attacker, ATTR_RETREAT_VALUE, 0)
					end
					if attacker == tribe1 then WRITE_CP_ATTRIB(attacker, ATTR_FIGHT_STOP_DISTANCE, 24+G_RANDOM(8)) else WRITE_CP_ATTRIB(attacker, ATTR_FIGHT_STOP_DISTANCE, 16+G_RANDOM(4)) end --**
					local mksTbl = {}
					if attacker == tribe1 then for i = 60,70 do table.insert(mksTbl,i) end else for i = 60,70 do table.insert(mksTbl,i) end end --**
					local mk1,mk2 = randomItemFromTable(mksTbl),-1
					updateAtkSpells(stage)
					local spell1,spell2,spell3 = 0,0,0
					if attacker == tribe1 then spell1,spell2,spell3 = TRIBE1_ATK_SPELLS[1],TRIBE1_ATK_SPELLS[2],TRIBE1_ATK_SPELLS[3] else spell1,spell2,spell3 = TRIBE2_ATK_SPELLS[1],TRIBE2_ATK_SPELLS[2],TRIBE2_ATK_SPELLS[3] end --**
					if spell1 == M_SPELL_INVISIBILITY or spell1 == M_SPELL_SHIELD then mk2 = mk1 end
					--[[
					0 - Stop at waypoint (if exists) and before attack
					1 - Stop before attack only
					2 - Stop at waypoint (if exists) only
					3 - Don't stop anywhere
					]]
					if atkType ~= ATTACK_NORMAL then WRITE_CP_ATTRIB(attacker, ATTR_DONT_GROUP_AT_DT, 0) WRITE_CP_ATTRIB(attacker, ATTR_GROUP_OPTION, iipp(0,1,20,80)) else
						if (spell1 ~= M_SPELL_INVISIBILITY and spell1 ~= M_SPELL_SHIELD) then
							WRITE_CP_ATTRIB(attacker, ATTR_DONT_GROUP_AT_DT, iipp(0,1,70,30))
							WRITE_CP_ATTRIB(attacker, ATTR_GROUP_OPTION, iipp(0,1,50,50)) if rnd() < 50 then WRITE_CP_ATTRIB(attacker, ATTR_GROUP_OPTION, iipp(2,3,50,50)) end
						else
							WRITE_CP_ATTRIB(attacker, ATTR_DONT_GROUP_AT_DT, 0)
							WRITE_CP_ATTRIB(attacker, ATTR_GROUP_OPTION, iipp(0,2,60,40))
						end
					end
					if rnd() > 90 and (spell1 ~= M_SPELL_INVISIBILITY and spell1 ~= M_SPELL_SHIELD) then mk1,mk2 = -1,-1 end
					local targType = false
					if countBuildings(target) > 0 then
						if (NAV_CHECK(attacker,target,ATTACK_BUILDING,0,0) > 0) then targType = ATTACK_BUILDING else targType = ATTACK_PERSON end
					else
						if (NAV_CHECK(attacker,target,ATTACK_PERSON,0,0) > 0) then targType = ATTACK_PERSON end
					end
					if targType ~= false then
						if targType == ATTACK_PERSON and allPopOnVehicles(target) then spell1,spell2,spell3 = M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_INSECT_PLAGUE end
						GIVE_ONE_SHOT(spell1,attacker) GIVE_ONE_SHOT(spell2,attacker) GIVE_ONE_SHOT(spell3,attacker)
						local bbv = iipp(0,1,30,70) --**
						if atkType == ATTACK_NORMAL then bbv = 0 end
						ATTACK(attacker, target, numTroops, targType, 0, 969+(stage*10), spell1, spell2, spell3, atkType, bbv, mk1, mk2, 0)
						IncrementAtkVar(attacker,(rndb(1800,2500)) - (G_GAMESTAGE*rndb(150,250))) --**
						success = true
						AI_SetTargetParams(attacker,target,true,true)
						log_msg(attacker,"target: " .. target .. ", numTroops: " .. numTroops .. ", targType: " .. targType .. ", spell1: " .. spell1 .. ", spell2: " .. spell2 .. ", spell3: " .. spell3 .. ", atkType: " .. atkType .. ", mk1: " .. mk1 .. ", mk2: " .. mk2)
					end
				end
			end
		end
	end
	if not success then IncrementAtkVar(attacker,400-G_GAMESTAGE*50) end
end

function IncrementAtkVar(pn,amt)
	if pn == tribe1 then
		TRIBE1atk = TRIBE1atk + amt
	else
		TRIBE2atk = TRIBE2atk + amt
	end
end

function BlackConnectBlue()
	local pn,targ = tribe2,TRIBE_BLUE
	if GetPop(targ) > 0 then
		if (NAV_CHECK(pn,targ,ATTACK_PERSON,0,0) <= 0) then
			if AI_EntryAvailable(pn) and nilS(pn) and IS_SHAMAN_AVAILABLE_FOR_ATTACK(pn) and TRIBE2atk-getTurn() > 256 then
				local mk1,mk2 = -1,-1
				if rnd() > 50 and (isMkLand(102) and isMkLand(103)) then
					mk1,mk2 = 102,103
					WRITE_CP_ATTRIB(pn, ATTR_GROUP_OPTION, 2) WriteAiAttackers(pn,0,0,0,0,0,100)
					GIVE_ONE_SHOT(M_SPELL_LAND_BRIDGE,pn)
					ATTACK(pn, targ, 1, ATTACK_MARKER, mk2, 1, M_SPELL_LAND_BRIDGE, 0, 0, ATTACK_NORMAL, 0, mk1, mk2, 0)
				elseif (isMkLand(104) and isMkLand(105)) then
					mk1,mk2 = 104,105
					WRITE_CP_ATTRIB(pn, ATTR_GROUP_OPTION, 2) WriteAiAttackers(pn,0,0,0,0,0,100)
					GIVE_ONE_SHOT(M_SPELL_LAND_BRIDGE,pn)
					ATTACK(pn, targ, 1, ATTACK_MARKER, mk2, 1, M_SPELL_LAND_BRIDGE, 0, 0, ATTACK_NORMAL, 0, mk1, mk2, 0)
				end
			end
		end
	end
end

function ReconnectToEnemies()
	local pn,targ = tribe2,TRIBE_RED
	if GetPop(targ) > 0 then
		if (NAV_CHECK(pn,targ,ATTACK_PERSON,0,0) <= 0) then
			if AI_EntryAvailable(pn) and nilS(pn) and IS_SHAMAN_AVAILABLE_FOR_ATTACK(pn) and TRIBE2atk-getTurn() > 512 then
				local lbMarkersChain = {96,97,98,99,100,101}
				local mk1,mk2 = -1,-1
				for k,v in ipairs(lbMarkersChain) do
					if not NavCheck(pn,targ,marker_to_coord3d(v)) then
						mk1,mk2 = v-1,v
						WRITE_CP_ATTRIB(pn, ATTR_GROUP_OPTION, 2) WriteAiAttackers(pn,0,0,0,0,0,100)
						GIVE_ONE_SHOT(M_SPELL_LAND_BRIDGE,pn)
						ATTACK(pn, targ, 1, ATTACK_MARKER, mk2, 1, M_SPELL_LAND_BRIDGE, 0, 0, ATTACK_NORMAL, 0, mk1, mk2, 0)
						break
					end
					mk1,mk2 = mk1+1,mk2+1
				end
			end
		end
	end
end

function giveSpellsOccasionally()
	local s = G_GAMESTAGE
	local tbl = {{M_SPELL_BLAST,70,0},{M_SPELL_INSECT_PLAGUE,40,0},{M_SPELL_HYPNOTISM,25,2},{M_SPELL_EARTHQUAKE,10,3},{M_SPELL_WHIRLWIND,30,1},{M_SPELL_GHOST_ARMY,50,0}}
	for k,v in ipairs(G_AI_ALIVE) do
		for kk,vv in ipairs(tbl) do
			if vv[3] >= s and rnd() < vv[2] then
				GIVE_ONE_SHOT(vv[1],v)
			end
		end
	end
end

function ProcessDefensiveShaman()
	local pn = tribe1
	if isShamanHome(pn,0,24) then --pn,mk,rad
		GetRidOfNearbyEnemies(pn,1,30+G_GAMESTAGE*10)
		if rnd() < 50 then TargetNearbyShamans(pn,9+G_GAMESTAGE,10+G_GAMESTAGE*8) end
	end
	--
	local pn = tribe2
	if isShamanHome(pn,1,14) then --pn,mk,rad
		GetRidOfNearbyEnemies(pn,1,25+G_GAMESTAGE*8)
		if rnd() < 55 then TargetNearbyShamans(pn,9+G_GAMESTAGE,8+G_GAMESTAGE*6) end
	end
end

function ProcessAgressiveShaman()
	local pn = tribe1
	if not isShamanHome(pn,0,24) then --pn,mk,rad
		GetRidOfNearbyEnemies(pn,1,30+G_GAMESTAGE*10)
		if rnd() < 50 then TargetNearbyShamans(pn,9+G_GAMESTAGE,10+G_GAMESTAGE*10) end
		GIVE_ONE_SHOT(M_SPELL_LIGHTNING_BOLT,pn)
	end	
	--
	local pn = tribe2
	if not isShamanHome(pn,1,14) then --pn,mk,rad
		GetRidOfNearbyEnemies(pn,1,25+G_GAMESTAGE*12)
		if rnd() < 55 then TargetNearbyShamans(pn,9+G_GAMESTAGE,12+G_GAMESTAGE*10) end
	end	
end

function updateTroopsAndAtkParams()
	local stage = G_GAMESTAGE
	local pn = tribe1
	--update attack percentage
	local atkp = 100 + stage*5
	if atkp > 140 then atkp = 140 end
	WRITE_CP_ATTRIB(pn, ATTR_ATTACK_PERCENTAGE, atkp)
	--auto train units occasionally
	if rnd() < 50 then --50% chance for main code executte
		local braves = _gsi.Players[pn].NumPeopleOfType[M_PERSON_BRAVE]
		local troopAmmount = countTroops(pn)
		if troopAmmount < math.floor(braves/3) then
			local troopsType = {{M_PERSON_WARRIOR,8+stage*2},{M_PERSON_RELIGIOUS,8+stage*2}--[[,{M_PERSON_SUPER_WARRIOR,4+stage*2},{M_PERSON_SPY,4+stage*2}]]}
			for k,v in ipairs(troopsType) do
				if AI_EntryAvailable(pn) then
					if AI_GetUnitCount(pn,v[1]) < v[2] then TRAIN_PEOPLE_NOW(pn,1,v[1]) end
				end
			end
		end
	end
	--
	local pn = tribe2
	--update attack percentage
	local atkp = 100 + stage*5
	if atkp > 140 then atkp = 140 end
	WRITE_CP_ATTRIB(pn, ATTR_ATTACK_PERCENTAGE, atkp)
	--auto train units occasionally
	if rnd() < 50 then --50% chance for main code executte
		local braves = _gsi.Players[pn].NumPeopleOfType[M_PERSON_BRAVE]
		local troopAmmount = countTroops(pn)
		if troopAmmount < math.floor(braves/3) then
			local troopsType = {{M_PERSON_WARRIOR,10+stage*2},--[[{M_PERSON_RELIGIOUS,8+stage*2},]]{M_PERSON_SUPER_WARRIOR,10+stage*2}--[[,{M_PERSON_SPY,4+stage*2}]]}
			for k,v in ipairs(troopsType) do
				if AI_EntryAvailable(pn) then
					if AI_GetUnitCount(pn,v[1]) < v[2] then TRAIN_PEOPLE_NOW(pn,1,v[1]) end
				end
			end
		end
	end
end

function updateSpellEntries(marker,radius)
	local s = G_GAMESTAGE
	local pn,marker,radius = tribe1,0,24
	if IS_SHAMAN_IN_AREA(pn,marker,radius) then
		SET_SPELL_ENTRY(pn, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST) >> (1+s), 128, 1, 1)
		SET_SPELL_ENTRY(pn, 1, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> (1+s), 128, 6-s, 1)
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
	--
	local pn = tribe2,1,14
	if IS_SHAMAN_IN_AREA(pn,marker,radius) then
		SET_SPELL_ENTRY(pn, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST) >> (1+s), 128, 1, 1)
		SET_SPELL_ENTRY(pn, 1, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> (1+s), 128, 7-s, 1)
		SET_SPELL_ENTRY(pn, 2, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_LIGHTNING_BOLT) >> (1+s), 128, 6, 1)
		if s > 0 then
			SET_SPELL_ENTRY(pn, 3, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_HYPNOTISM) >> (1+s), 128, 15-(s*2), 1)
		end
	else
		SET_SPELL_ENTRY(pn, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST) >> (1+s), 128, 1, 0)
		SET_SPELL_ENTRY(pn, 1, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_BLAST) >> (1+s), 128, 2, 0)
		SET_SPELL_ENTRY(pn, 2, M_SPELL_LIGHTNING_BOLT, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> (1+s), 128, 6, 0)
		if s > 0 then
			SET_SPELL_ENTRY(pn, 3, M_SPELL_GHOST_ARMY, 4000, 128, 6-s, 0)
		end
		if s > 1 then
			SET_SPELL_ENTRY(pn, 4, M_SPELL_HYPNOTISM, SPELL_COST(M_SPELL_INSECT_PLAGUE) >> (1+s), 128, 10-s, 0)
		end
		if s > 2 then
			SET_SPELL_ENTRY(pn, 5, M_SPELL_FIRESTORM, 160000, 128, 22-s, 0)
			SET_SPELL_ENTRY(pn, 6, M_SPELL_EARTHQUAKE, 14000, 128, 17, 0)
		end
		if s >= 4 then
			SET_SPELL_ENTRY(pn, 7, M_SPELL_ANGEL_OF_DEATH, 200000, 128, 28, 0)
		end
	end	
end

function updateAtkSpells(s)
	TRIBE1_ATK_SPELLS = {}
	TRIBE2_ATK_SPELLS = {}
	--
	local spellList1,spellList2 = {},{}
	local function SpellPicker(possibilitiesTbl,aiTbl)
		for i = 1,3 do
			local k = rndb(0,#possibilitiesTbl)
			table.insert(aiTbl,possibilitiesTbl[k])
			table.remove(possibilitiesTbl,k)
		end		
	end
	if s == 0 then
		spellList1 = {M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND}
		spellList2 = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND}
	elseif s == 1 then
		spellList1 = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM}
		spellList2 = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE}
	elseif s == 2 then
		spellList1 = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE}
		spellList2 = {M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM}
	elseif s == 3 then
		spellList1 = {M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM}
		spellList2 = {M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM,M_SPELL_FIRESTORM}
	else
		spellList1 = {M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM}
		spellList2 = {M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM,M_SPELL_ANGEL_OF_DEATH}
	end
	SpellPicker(spellList1,TRIBE1_ATK_SPELLS)
	SpellPicker(spellList2,TRIBE2_ATK_SPELLS)
	--feel the need to use SHIELD/INVI?
	if s > 1 then
		local chance = 20+s*10 --40-60% chance
		if rnd() < chance then
			TRIBE1_ATK_SPELLS[1] = M_SPELL_INVISIBILITY
			TRIBE2_ATK_SPELLS[1] = M_SPELL_INVISIBILITY
		end
	end
end

function DefensivePreachMarkers()
	local tribe = tribe1
	local markers = {} for i = 56,60 do table.insert(markers,i) end
	if _gsi.Players[tribe].NumPeopleOfType[M_PERSON_RELIGIOUS] > 3 then
		for k,v in ipairs(markers) do
			PREACH_AT_MARKER(tribe,v)
		end
	end
end

function OffensivePreachMarkers()
	if G_GAMESTAGE > 1 then
		local tribe = tribe1
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
	--stone heads defending by tribe1(cyan)
	if countBoats(tribe1) > 0 and mk == 68 then
		if countPeopleInArea(TRIBE_BLUE,mk,0) > 0 or countPeopleInArea(TRIBE_RED,mk,0) > 0 then
			PREACH_AT_MARKER(tribe1,mk)
			if rnd() < 40 and AI_ShamanFree(tribe1) then
				local spellsTbl = {M_SPELL_BLAST,M_SPELL_LIGHTNING_BOLT,M_SPELL_INSECT_PLAGUE,M_SPELL_SWAMP}
				local s = randomItemFromTable(spellsTbl)
				GIVE_ONE_SHOT(s,tribe1)
				SPELL_ATTACK(tribe1,s,mk,mk)
			end
		end
	end
	--totem pole defending by tribe2(black)
	if mk == 94 then
		if countPeopleInArea(TRIBE_BLUE,mk,0) > 0 or countPeopleInArea(TRIBE_RED,mk,0) > 0 then
			if rnd() < 60 and AI_ShamanFree(tribe1) then
				local spellsTbl = {M_SPELL_BLAST,M_SPELL_LIGHTNING_BOLT,M_SPELL_INSECT_PLAGUE,M_SPELL_SWAMP}
				local s = randomItemFromTable(spellsTbl)
				GIVE_ONE_SHOT(s,tribe1)
				SPELL_ATTACK(tribe1,s,mk,mk)
			end
		end
	end
end

function updateSpellBuckets(s)
	local tribe = tribe1
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
	local tribe = tribe2
	AI_SpellBucketCost(tribe, M_SPELL_BLAST, 1);
	AI_SpellBucketCost(tribe, M_SPELL_CONVERT_WILD, 2);
	AI_SpellBucketCost(tribe, M_SPELL_INSECT_PLAGUE, 7-s);
	AI_SpellBucketCost(tribe, M_SPELL_INVISIBILITY, 14-s);
	AI_SpellBucketCost(tribe, M_SPELL_LIGHTNING_BOLT, 10-s);
	AI_SpellBucketCost(tribe, M_SPELL_HYPNOTISM, 15-s);
	AI_SpellBucketCost(tribe, M_SPELL_EARTHQUAKE, 33-s);
	AI_SpellBucketCost(tribe, M_SPELL_FIRESTORM, 48-s*2);
	AI_SpellBucketCost(tribe, M_SPELL_WHIRLWIND, 22-s*2);
	AI_SpellBucketCost(tribe, M_SPELL_GHOST_ARMY, 9-s);
	AI_SpellBucketCost(tribe, M_SPELL_ANGEL_OF_DEATH, 80-s*2);	
end

function updateConvertParams()
	local pn = tribe1
	local cv = btn(GetPop(pn)<45+20*G_GAMESTAGE)
	STATE_SET(pn, cv, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS)
	WRITE_CP_ATTRIB(pn, ATTR_EXPANSION, 25+10*G_GAMESTAGE)
	--
	local pn = tribe2
	local cv = btn(GetPop(pn)<40+16*G_GAMESTAGE)
	STATE_SET(pn, cv, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS)
	WRITE_CP_ATTRIB(pn, ATTR_EXPANSION, 25+8*G_GAMESTAGE)
end

function updateVehiclesBuild()
	local pn = tribe1
	STATE_SET(pn, btn(countBoats(pn) < 3), CP_AT_TYPE_BUILD_VEHICLE)
	STATE_SET(pn, btn(countBoats(pn) > 0), CP_AT_TYPE_FETCH_LOST_VEHICLE)
	STATE_SET(pn, btn(countBoats(pn) > 0), CP_AT_TYPE_FETCH_FAR_VEHICLE)
end

function trainingHutsPriorities(pn)
	local pop,huts,s = GetPop(pn),countHuts(pn,false),G_GAMESTAGE
	
	if pn == tribe1 then
		WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_TRAINS, btn(huts > 2))
		--WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_TRAINS, btn(huts > 4))
		WRITE_CP_ATTRIB(pn, ATTR_PREF_RELIGIOUS_TRAINS, btn(huts > 6))
		--WRITE_CP_ATTRIB(pn, ATTR_PREF_SPY_TRAINS, btn(huts > 4))
		WRITE_CP_ATTRIB(pn, ATTR_PREF_BOAT_HUTS, btn(countHuts(pn,false) > 1+s+4))
		--WRITE_CP_ATTRIB(pn, ATTR_PREF_BALLOON_HUTS, btn(countHuts(pn,false) > 1+stage+7))
	else
		WRITE_CP_ATTRIB(pn, ATTR_PREF_WARRIOR_TRAINS, btn(huts > 4))
		WRITE_CP_ATTRIB(pn, ATTR_PREF_SUPER_WARRIOR_TRAINS, btn(huts > 1))
	end
	
	if pn == tribe1 then
		WriteAiTrainTroops(pn, 1+(s*2)+15 ,1+(s*2)+15, 0, 0) --w,pr,fw,s
	else -- tribe2(black)
		WriteAiTrainTroops(pn, 1+(s*2)+15 , 0, 1+(s*2)+15, 0) --w,pr,fw,s
	end
end

--update base priorities
function updateBasePriorities(pn)
	local s,h,b = G_GAMESTAGE, countHuts(pn,true), AI_GetUnitCount(pn, M_PERSON_BRAVE)
	if pn == tribe1 then
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
	else
		AI_SetBuildingParams(pn,true,70+s*5,rndb(1,3))
	end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

TRIBE1_SPELLS = {
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

TRIBE1_ATK_SPELLS = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND}

TRIBE2_SPELLS = {
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
M_SPELL_FIRESTORM,
M_SPELL_ANGEL_OF_DEATH
}

TRIBE2_ATK_SPELLS = {M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND}

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function _OnLevelInit(level_id)
	--scenery
	for i = 5,55 do Plant(i,i,-1) end

	--stuff for AI
	local pn = tribe1
	AI_Initialize(pn);

	for k,v in ipairs(TRIBE1_SPELLS) do
		set_player_can_cast(v, pn);
	end
	AI_EnableBuckets(pn);
	AI_SpellBucketCost(pn, M_SPELL_BLAST, 1);
	AI_SpellBucketCost(pn, M_SPELL_CONVERT_WILD, 2);
	AI_SpellBucketCost(pn, M_SPELL_INSECT_PLAGUE, 6);
	AI_SpellBucketCost(pn, M_SPELL_INVISIBILITY, 13);
	AI_SpellBucketCost(pn, M_SPELL_LIGHTNING_BOLT, 11);
	AI_SpellBucketCost(pn, M_SPELL_HYPNOTISM, 16);
	AI_SpellBucketCost(pn, M_SPELL_EARTHQUAKE, 32);
	AI_SpellBucketCost(pn, M_SPELL_FIRESTORM, 48);
	AI_SpellBucketCost(pn, M_SPELL_WHIRLWIND, 18);
	AI_SpellBucketCost(pn, M_SPELL_GHOST_ARMY, 8);
	
	set_player_can_build(M_BUILDING_TEPEE, pn);
	set_player_can_build(M_BUILDING_DRUM_TOWER, pn);
	set_player_can_build(M_BUILDING_WARRIOR_TRAIN, pn);
	--set_player_can_build(M_BUILDING_SUPER_TRAIN, pn);
	set_player_can_build(M_BUILDING_TEMPLE, pn);
	set_player_can_build(M_BUILDING_BOAT_HUT_1, pn);
	--set_player_can_build(M_BUILDING_AIRSHIP_HUT_1, pn);

	AI_SetAways(pn, 1, 0, 0, 0, 0);
	AI_SetShamanAway(pn, true);
	AI_SetShamanParams(pn, 180, 160, true, 16, 12);
	AI_SetMainDrumTower(pn, true, 180, 160);
	AI_SetConvertingParams(pn, false, false, 24);

	AI_SetBuildingParams(pn, true, 50, 3);
	AI_SetTrainingHuts(pn, 0, 0, 0, 0);
	AI_SetTrainingPeople(pn, true, 10, 0, 0, 0, 0);
	AI_SetVehicleParams(pn, false, 0, 0, 0, 0);
	AI_SetFetchParams(pn, true, true, true, true);

	AI_SetAttackingParams(pn, true, 255, 10, 20);
	AI_SetDefensiveParams(pn, true, true, true, true, 3, 2, 1);
	AI_SetSpyParams(pn, false, 0, 100, 128, 1);
	AI_SetPopulatingParams(pn, true, true);
	
	-------------------------------------------------------------------------
	
	local pn = tribe2
	AI_Initialize(pn);
	
	for k,v in ipairs(TRIBE2_SPELLS) do
		set_player_can_cast(v, pn);
	end
	AI_EnableBuckets(pn);
	AI_SpellBucketCost(pn, M_SPELL_BLAST, 1);
	AI_SpellBucketCost(pn, M_SPELL_CONVERT_WILD, 2);
	AI_SpellBucketCost(pn, M_SPELL_INSECT_PLAGUE, 6);
	AI_SpellBucketCost(pn, M_SPELL_INVISIBILITY, 13);
	AI_SpellBucketCost(pn, M_SPELL_LIGHTNING_BOLT, 11);
	AI_SpellBucketCost(pn, M_SPELL_HYPNOTISM, 16);
	AI_SpellBucketCost(pn, M_SPELL_EARTHQUAKE, 32);
	AI_SpellBucketCost(pn, M_SPELL_FIRESTORM, 48);
	AI_SpellBucketCost(pn, M_SPELL_WHIRLWIND, 18);
	AI_SpellBucketCost(pn, M_SPELL_GHOST_ARMY, 8);
	AI_SpellBucketCost(pn, M_SPELL_ANGEL_OF_DEATH, 70);
	
	set_player_can_build(M_BUILDING_TEPEE, pn);
	set_player_can_build(M_BUILDING_DRUM_TOWER, pn);
	set_player_can_build(M_BUILDING_WARRIOR_TRAIN, pn);
	set_player_can_build(M_BUILDING_SUPER_TRAIN, pn);
	--set_player_can_build(M_BUILDING_TEMPLE, pn);
	--set_player_can_build(M_BUILDING_BOAT_HUT_1, pn);
	--set_player_can_build(M_BUILDING_AIRSHIP_HUT_1, pn);

	AI_SetAways(pn, 1, 0, 0, 0, 0);
	AI_SetShamanAway(pn, true);
	AI_SetShamanParams(pn, 22, 32, true, 32, 12);
	AI_SetMainDrumTower(pn, true, 22, 32);
	AI_SetConvertingParams(pn, false, false, 24);

	AI_SetBuildingParams(pn, true, 50, 2);
	AI_SetTrainingHuts(pn, 0, 0, 0, 0);
	AI_SetTrainingPeople(pn, true, 10, 0, 0, 0, 0);
	AI_SetVehicleParams(pn, false, 0, 0, 0, 0);
	AI_SetFetchParams(pn, true, false, false, true);

	AI_SetAttackingParams(pn, true, 255, 10, 20);
	AI_SetDefensiveParams(pn, true, true, true, true, 3, 2, 1);
	AI_SetSpyParams(pn, false, 0, 100, 128, 1);
	AI_SetPopulatingParams(pn, true, true);
end

function _OnPostLevelInit(level_id)
	--stuff for humans
	set_player_can_cast(M_SPELL_LAND_BRIDGE, TRIBE_BLUE);
	set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_INVISIBILITY, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_SWAMP, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_HYPNOTISM, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_EARTHQUAKE, TRIBE_RED);
	for k,v in ipairs(G_HUMANS) do
		set_player_can_cast(M_SPELL_GHOST_ARMY, v);
		set_correct_gui_menu();
	end
	--stuff for AI
	set_players_allied(tribe1,tribe2)
	set_players_allied(tribe2,tribe1)
	G_AI_EXPANSION_TABLE[tribe1][1] = G_AI_EXPANSION_TABLE[tribe1][1] + rndb(60,120)
	SET_DEFENCE_RADIUS(tribe1,9)
	SET_DEFENCE_RADIUS(tribe2,7)
	--patrols
	SET_MARKER_ENTRY(tribe1, 0, 69, 70, 0, 1, 0, 1)
	--VEHICLE_PATROL(pn, 3, 71,72,73,74, M_VEHICLE_BOAT_1) --gl with that lol
	--
	SET_MARKER_ENTRY(tribe2, 0, 75, 75, 0, 0, 2, 0)
	SET_MARKER_ENTRY(tribe2, 1, 76, 76, 0, 0, 2, 0)
	SET_MARKER_ENTRY(tribe2, 2, 77, 77, 0, 0, 2, 0)
	SET_MARKER_ENTRY(tribe2, 3, 78, 78, 0, 0, 2, 0)
	SET_MARKER_ENTRY(tribe2, 4, 78, 80, 0, 1, 2, 0)
	SET_MARKER_ENTRY(tribe2, 5, 81, -1, 0, 2, 0, 0)
	SET_MARKER_ENTRY(tribe2, 6, 82, -1, 0, 2, 0, 0)
end

------------------------------------------------------------------------------------------------------------------------
-- SCENERY FUNCTIONS
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
				stalagtites[1] = 90 --seconds
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
--do some only shaman attackos
--remove logs, log_msg