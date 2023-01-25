-- Includes
include("Common.lua");
include("snow.lua");
include("Spells\\TiledSwamp.lua");
include("FooterMsgs.lua");
SwampTileEnabled = true
SwampTileAffectAllies = true
SwampTileDuration = 12*12
SwampTileRandomness = 12*5

G_NUM_OF_HUMANS_FOR_THIS_LEVEL = 2;
local tribe1 = TRIBE_YELLOW
local tribe2 = TRIBE_GREEN
local tribe3 = TRIBE_CYAN
local tribe4 = TRIBE_PINK
local tribe5 = TRIBE_BLACK
local tribe6 = TRIBE_ORANGE
local TRIBE1atk = 2500 + (rndb(0,500))
local TRIBE2atk = 2000 + (rndb(0,500))
local TRIBE3atk = 1900 + (rndb(0,500))
local TRIBE4atk = 2300 + (rndb(0,500))
local TRIBE5atk = 2200 + (rndb(0,500))
local TRIBE6atk = 1950 + (rndb(0,500))
local TRIBE1ShamanAtk = {1000,2}
local TRIBE2ShamanAtk = {500,3}
local TRIBE3ShamanAtk = {700,2}
local TRIBE4ShamanAtk = {1300,1}
local TRIBE5ShamanAtk = {700,2}
local TRIBE6ShamanAtk = {700,3}

local PlayersStats = { --reinc cdr (seconds), yin or yang
		[0]= {-1,"none"},{-1,"none"}				
}
local level_completed = false
local yinYangCDR = 0
local borderRad = 24
SET_TIMER_GOING(12*60*30 + 12, 1)

function _OnTurn(turn)

	local stage = G_GAMESTAGE
	
	------------------------------------------------------------------------------------------------------------------------
	-- AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	--early warrior/maybe preachers boat attacks
	--[[if turn < 5001 and turn % 1000 == 0 then
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
	end]]

	--Process AIs on turn
	for k,v in ipairs(G_AI_ALIVE) do
		Sulk(v,stage+5)
		--small AI boosts
		fasterTrain(v,28+12*stage)
		fasterHutBars(v,16+6*stage,false)
		--priorities
		--[[if everySeconds(12) then
			updateGameStage(6,12,18,24)
			updateBasePriorities(v)
			unstuckS(v)
			trainingHutsPriorities(v)
		end]]
		--update lb expand tbl
		--[[if v == tribe1 then
			if everySeconds(1) then
				if G_AI_EXPANSION_TABLE[v][1] > 0 then G_AI_EXPANSION_TABLE[v][1] = G_AI_EXPANSION_TABLE[v][1] - 1 end
				if G_AI_EXPANSION_TABLE[v][1] == 0 and not G_AI_EXPANSION_TABLE[v][4] then
					LBexpand(v,9+stage,rndb(120,180),false) --pn,radius,cooldownSecondsIncrement,requiresLBmana
				end
				tryToLB(v)
			end
		end]]
	end
	--Process Humans on turn
	for k,v in ipairs(G_HUMANS_ALIVE) do
		if everySeconds(1) then
			if not nilS(v) then
				--reinc timer (normal 30s, yin 20s, yang 40s)
				if PlayersStats[v][1] == -1 then
					PlayersStats[v][1] = 30 if PlayersStats[v][2] == "yin" then PlayersStats[v][1] = 40 elseif PlayersStats[v][2] == "yang" then PlayersStats[v][1] = 20 end
				end
				if PlayersStats[v][1] > 0 then
					PlayersStats[v][1] = PlayersStats[v][1] - 1
				elseif PlayersStats[v][1] == 0 then
					local mk = rndb(1,4)
					if PlayersStats[v][2] == "yin" then mk = rndb(17,20) end
					local s = createThing(T_PERSON,M_PERSON_MEDICINE_MAN,v,marker_to_coord3d(mk),false,false)
					PlayersStats[v][1] = -1
					queue_sound_event(s,SND_EVENT_SHAMAN_RETURN, 0)
				end
			else
				--yin yang marker
				if IS_SHAMAN_IN_AREA(v,0,0) == 1 then
					local count,ShOwner = 0,-1
					SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(marker_to_coord3d(0)), function(me)
						me.MapWhoList:processList( function (t)
							if t.Type == T_PERSON and t.Owner ~= TRIBE_HOSTBOT then
								count = count + 1
								if t.Model == M_PERSON_MEDICINE_MAN and not isGhost(t) then
									ShOwner = t.Owner
								end
							end
						return true end)
					return true end)
					if count == 1 and ShOwner ~= -1 then
						YinYangSwap(v)
					end
				end
			end
		end
	end
	
	--attacks
	--[[if TRIBE1atk == turn then attack(tribe1) end
	if TRIBE2atk == turn then attack(tribe2) end
	--shaman attacks
	if TRIBE1ShamanAtk[1] == turn then Shamanattack(tribe1) end
	if TRIBE2ShamanAtk[1] == turn then Shamanattack(tribe2) end
	--aod late casts
	if turn == 25000 or turn == 35000 then if AI_EntryAvailable(tribe2) and nilS(tribe2) and IS_SHAMAN_AVAILABLE_FOR_ATTACK(tribe2) then GIVE_ONE_SHOT(M_SPELL_ANGEL_OF_DEATH,tribe2) SPELL_ATTACK(tribe2,M_SPELL_ANGEL_OF_DEATH,109,109) end end
	if turn == 35000 or turn == 45000 then if AI_EntryAvailable(tribe1) and nilS(tribe1) and IS_SHAMAN_AVAILABLE_FOR_ATTACK(tribe1) then GIVE_ONE_SHOT(M_SPELL_ANGEL_OF_DEATH,tribe1) SPELL_ATTACK(tribe1,M_SPELL_ANGEL_OF_DEATH,106,106) end end]]
	
	--[[if everySeconds(3) then
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
	if everySeconds(60-stage*10) then
		sendRandomUnit(TRIBE_BLACK,iipp(M_PERSON_WARRIOR,M_PERSON_WARRIOR,50,50))
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
	end]]
	------------------------------------------------------------------------------------------------------------------------
	-- NON-AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	if turn == 12 then
		FooterMsg("Centuries ago, on this very location, the high priests forged a magical rune that would shape the way mana flew through the body. Unfortunately, all of them got murdered by the tribes that inhabited the planet, and the location got lost forever... Until two tribes found it...", 2, 171)
	elseif turn == 12*60 then
		FooterMsg("Work together and destroy all 6 enemy tribes before you run out of time.", 2, 175)
	elseif turn == 12*120 then
		FooterMsg("The shaman with yin (offensive) reincarnates after 40 seconds, while the shaman with yan (defensive) reincarnates twice as fast. If shamans decide to fight without yin-yang, they will reincarnate after 30 seconds, upon death.", 2, 174)
	end
	if everySeconds(1) then
		if not level_completed and (gns.Flags & GNS_LEVEL_COMPLETE ~= 0) then
			level_completed = true
			REMOVE_TIMER()
		end
		if HAS_TIMER_REACHED_ZERO() then
			FooterMsg("You did not kill all enemy tribes on time. Your journey ends here...", 2, 174)
			LOSE()
			REMOVE_TIMER()
			killTribe(0) killTribe(1)
		end
		BorderRadBehaviour()
	end
	--snowing 3 times during level
	--snowAmtTarget, AmtPerSecCreation, speed, (durationSeconds, internTimer), fadeSeconds
	if turn == 1500 then
		createSnow(600, 50, 32, 60*3, 12)
	elseif turn == 8500 then
		createSnow(700, 100, 20, 60*1, 3)
	elseif turn == 15000 then
		createSnow(1300, 50, 42, 60*2, 24)
	elseif turn == 21000 then
		createSnow(900, 30, 24, 60*3, 16)
	elseif turn == 27000 then
		createSnow(600, 100, 28, 60*2, 32)
	end
	--process stalagtites and swamps
	StalagtitesFalling()
	ProcessTiledSwamps()
	--yin yang cdr
	if yinYangCDR > 0 then yinYangCDR = yinYangCDR - 1 end
	if turn == 1 then TJournal:Toggle(); end
end

function _OnCreateThing(t)
	if t.Type == T_SPELL and (t.Model == M_SPELL_LIGHTNING_BOLT or t.Model == M_SPELL_BLAST) then
		if isItemInTable(G_HUMANS_ALIVE,t.Owner) then
			if t.Model == M_SPELL_LIGHTNING_BOLT then
				dodgeLightnings(t.Owner,60+G_GAMESTAGE*10,t) --AI chance to dodge lights
			else
				dodgeAimedBlasts(t.Owner,30+G_GAMESTAGE*10,t) --AI chance to dodge aimed blasts
			end
		end
	end
	ProcessSwampCreate(t)
end

function _OnKeyDown(k)
	if k == LB_KEY_6 then
		
	elseif k == LB_KEY_Q then
		
	end
end

function _OnFrame(w,h,guiW)
	local yySpr = 1788
	local box = math.floor(w/32)
	if PlayersStats[0][2] ~= "none" then
		if PlayersStats[0][2] == "yin" then yySpr = 1789 else yySpr = 1790 end
	end
	LbDraw_ScaledSprite(guiW+5,5,get_sprite(0,yySpr),box-1,box-1)
end

------------------------------------------------------------------------------------------------------------------------
-- LEVEL FUNCTIONS
------------------------------------------------------------------------------------------------------------------------
SearchMapCells(SQUARE ,0, 1, 2, world_coord3d_to_map_idx(marker_to_coord3d(0)), function(me)
	me.ShadeIncr = -32
return true end)
SearchMapCells(SQUARE ,0, 0, 1, world_coord3d_to_map_idx(marker_to_coord3d(0)), function(me)
	me.ShadeIncr = -16
return true end)
for i = 5,16 do
	SearchMapCells(SQUARE ,0, 0, 0, world_coord3d_to_map_idx(marker_to_coord3d(i)), function(me)
		me.Flags = EnableFlag(me.Flags, (1<<2))
	return true end)
end
local a = 0
SearchMapCells(CIRCULAR, 0, borderRad, borderRad-1, world_coord3d_to_map_idx(marker_to_coord3d(0)), function(me)
	local _me = MAP_ELEM_PTR_2_IDX(me)
	local c3d = Coord3D.new()
	map_idx_to_world_coord3d_centre(_me,c3d)
	local spk = createThing(T_EFFECT,74,TRIBE_NEUTRAL,c3d,false,false)
	centre_coord3d_on_block(spk.Pos.D3)
	spk.DrawInfo.Alpha = 0 if a % 2 == 0 then spk.DrawInfo.Alpha = 7 end
	spk.u.Effect.Duration = -1
	a = a + 1
return true end)

local BorderRadBehaviourCDR = 4
function BorderRadBehaviour()
	if BorderRadBehaviourCDR > 0 then BorderRadBehaviourCDR = BorderRadBehaviourCDR - 1 end
	if BorderRadBehaviourCDR == 0 then
		for i = 0,1 do
			if nilS(i) then
				local dist = get_world_dist_xz(getShaman(i).Pos.D2,marker_to_coord2d(0))
				local limit = 1024 + 512*borderRad
				if dist > limit and PlayersStats[i][2] == "yang" then
					createThing(T_EFFECT,M_EFFECT_TELEPORT,i,marker_to_coord3d(rndb(1,4)),false,false)
					FooterMsg("The Yang Shaman can not leave the inner circle (base). Focus on defending.", 2, 174)
					BorderRadBehaviourCDR = 4 break
				elseif dist < limit - 1024 and PlayersStats[i][2] == "yin" then
					local disTbl = {}
					SearchMapCells(CIRCULAR, 0, borderRad+2, borderRad+1, world_coord3d_to_map_idx(marker_to_coord3d(0)), function(me)
						if is_map_elem_all_land(me) > 0 then
							local c2d = Coord2D.new()
							coord3D_to_coord2D(me2c3d(me),c2d)
							local dis = get_world_dist_xz(getShaman(i).Pos.D2,c2d)
							if dis < 512*12 then
								table.insert(disTbl, {dis, me})
							end
						end
					return true end)
					local curr = {99999,0}
					for k,v in ipairs (disTbl) do
						if v[1] < curr[1] then curr[1] = v[1] curr[2] = v[2] end
					end
					if #disTbl > 0 then
						local c3d = Coord3D.new()
						c3d = me2c3d(curr[2])
						createThing(T_EFFECT,M_EFFECT_TELEPORT,i,c3d,false,false)
					else
						createThing(T_EFFECT,M_EFFECT_TELEPORT,i,marker_to_coord3d(rndb(17,20)),false,false)
					end
					FooterMsg("The yin shaman can not enter the inner circle (base). Focus on attacking.", 2, 174)
					BorderRadBehaviourCDR = 4 break
				end
			end
		end
	end
end

local YinSpells = {M_SPELL_BLAST,M_SPELL_CONVERT_WILD,M_SPELL_INSECT_PLAGUE,M_SPELL_GHOST_ARMY,M_SPELL_LIGHTNING_BOLT,M_SPELL_SWAMP,M_SPELL_LAND_BRIDGE}
local YangSpells = {M_SPELL_BLAST,M_SPELL_GHOST_ARMY,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM}

function YinYangSwap(pn)
	if yinYangCDR == 0 then
		if PlayersStats[0][2] == "none" then
			PlayersStats[0][2] = "yang" PlayersStats[1][2] = "yin"
			FooterMsg("Yin-Yang has been acquired. Yin (moon) will grant offensive status, while Yang (sun) will highlight the defense. Stay on the area to swap anytime, at the cost of spells and mana reset for both shamans.", 2, 1788)
			createThing(T_EFFECT,M_EFFECT_TELEPORT,1,marker_to_coord3d(rndb(17,20)),false,false)
			BorderRadBehaviourCDR = 6
		else
			if PlayersStats[0][2] == "yin" then
				PlayersStats[0][2] = "yang" PlayersStats[1][2] = "yin"
				FooterMsg("Yin-Yang energy swapped by " .. get_player_name(pn,ntb(isOnline())) .. ". All mana has been reset. " .. get_player_name(1,ntb(isOnline())) .. " is now Yin (offensive), and " .. get_player_name(0,ntb(isOnline())) .. " is now Yang (defensive).", 3, 1790)
			else
				PlayersStats[0][2] = "yin" PlayersStats[1][2] = "yang"
				FooterMsg("Yin-Yang energy swapped by " .. get_player_name(pn,ntb(isOnline())) .. ". All mana has been reset. " .. get_player_name(0,ntb(isOnline())) .. " is now Yin (offensive), and " .. get_player_name(1,ntb(isOnline())) .. " is now Yang (defensive).", 3, 1789)
			end
			BorderRadBehaviourCDR = 6
			for i = 0,1 do
				if nilS(i) then
					local mk = rndb(1,4)
					if PlayersStats[i][2] == "yin" then mk = rndb(17,20) end
					createThing(T_EFFECT,M_EFFECT_TELEPORT,i,marker_to_coord3d(mk),false,false)
				end
			end
		end
		local s = createThing(T_EFFECT,M_EFFECT_HYPNOSIS_FLASH,8,marker_to_coord3d(0),false,false) centre_coord3d_on_block(s.Pos.D3)
		s.Pos.D3.Ypos = 512 queue_sound_event(s,SND_EVENT_HYPNOTISE, 0)
		yinYangCDR = 12*7
		--reset mana for each player, and swap yinYang spells
		if PlayersStats[0][2] == "yang" then
			for k,v in ipairs(YangSpells) do set_player_cannot_cast(v, 0) end for k,v in ipairs(YinSpells) do set_player_can_cast(v, 0) end GIVE_MANA_TO_PLAYER(0,-9999999)
			for k,v in ipairs(YinSpells) do set_player_cannot_cast(v, 1) end for k,v in ipairs(YangSpells) do set_player_can_cast(v, 1) end GIVE_MANA_TO_PLAYER(1,-9999999)
		else
			for k,v in ipairs(YangSpells) do set_player_cannot_cast(v, 1) end for k,v in ipairs(YinSpells) do set_player_can_cast(v, 1) end GIVE_MANA_TO_PLAYER(0,-9999999)
			for k,v in ipairs(YinSpells) do set_player_cannot_cast(v, 0) end for k,v in ipairs(YangSpells) do set_player_can_cast(v, 0) end GIVE_MANA_TO_PLAYER(1,-9999999)
		end
		set_correct_gui_menu()
	end
end

function Shamanattack(attacker)
	local success = false
	if AI_EntryAvailable(attacker) and nilS(attacker) and IS_SHAMAN_AVAILABLE_FOR_ATTACK(attacker) then
		if #G_HUMANS_ALIVE > 0 then --wont bother to continue level(attack) if only AIs exist
			local stage = G_GAMESTAGE
			if attacker == tribe1 then target = iipp(TRIBE_BLUE,TRIBE_RED,40,60) else target = iipp(TRIBE_BLUE,TRIBE_RED,30,70) end --**
			if #G_HUMANS_ALIVE == 1 then target = randomItemFromTable(G_HUMANS_ALIVE) end
			local atkType = ATTACK_NORMAL if attacker == tribe1 then atkType = ATTACK_BY_BOAT end --**
			local targ = iipp(ATTACK_PERSON,ATTACK_BUILDING,50,50) --**
			if (NAV_CHECK(attacker,target,targ,0,0) > 0) or atkType ~= ATTACK_NORMAL then
				if (attacker == tribe1 and TRIBE1ShamanAtk[2] > 0) or (attacker == tribe2 and TRIBE2ShamanAtk[2] > 0) then
					local spell1,spell2,spell3 = M_SPELL_LIGHTNING_BOLT,0,0
					local tierSpellsPerStageVsPers = {[0]=
						{M_SPELL_BLAST,M_SPELL_INSECT_PLAGUE},
						{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT},
						{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_HYPNOTISM},
						{M_SPELL_HYPNOTISM,M_SPELL_SWAMP},
						{M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_SWAMP,M_SPELL_FIRESTORM}}
					local tierSpellsPerStageVsBldgs = {[0]=
						{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT},
						{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND},
						{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
						{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE},
						{M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE}}
					if targ == ATTACK_BUILDING then
						spell2,spell3 = randomItemFromTable(tierSpellsPerStageVsBldgs[stage]),randomItemFromTable(tierSpellsPerStageVsBldgs[stage]) else spell2,spell3 = randomItemFromTable(tierSpellsPerStageVsPers[stage]),randomItemFromTable(tierSpellsPerStageVsPers[stage])
					end
					if stage == 0 then spell3 = 0 end
					GIVE_ONE_SHOT(spell1,attacker) GIVE_ONE_SHOT(spell2,attacker) GIVE_ONE_SHOT(spell3,attacker)
					WRITE_CP_ATTRIB(attacker, ATTR_DONT_GROUP_AT_DT, 1) WRITE_CP_ATTRIB(attacker, ATTR_GROUP_OPTION, 3)
					AI_SetTargetParams(attacker,target,true,true)
					ATTACK(attacker, target, 1, targ, 0, 850+(stage*10), spell1, spell2, spell3, atkType, 0, -1, -1, 0)
					IncrementShamanAtkVar(attacker,(rndb(600,1000)) - (G_GAMESTAGE*rndb(50,100))) --**
					success = true
					if attacker == tribe1 then TRIBE1ShamanAtk[2] = TRIBE1ShamanAtk[2] - 1 else TRIBE2ShamanAtk[2] = TRIBE2ShamanAtk[2] - 1 end
					log_msg(attacker,"shaman atack vs " .. target .. ", spells: " .. spell1 .. " " .. spell2 .. " " .. spell3)
				end
			end
		end
	end
	
	if not success then IncrementShamanAtkVar(attacker,300-G_GAMESTAGE*25) LOG("fail shaman atk") end
end

function IncrementShamanAtkVar(pn,amt)
	if pn == tribe1 then
		TRIBE1ShamanAtk[1] = TRIBE1ShamanAtk[1] + amt
	else
		TRIBE2ShamanAtk[1] = TRIBE2ShamanAtk[1] + amt
	end
end

function attack(attacker)
	local success = false
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
				if atkType == ATTACK_NORMAL or ((atkType == ATTACK_BY_BOAT and countBoats(attacker) > 0) or (atkType == ATTACK_BY_BALLOON and countBalloons(attacker) > 0)) then
					if stage < 2 then
						WRITE_CP_ATTRIB(attacker, ATTR_BASE_UNDER_ATTACK_RETREAT, 1) WRITE_CP_ATTRIB(attacker, ATTR_RETREAT_VALUE, rndb(0,12))
					else
						WRITE_CP_ATTRIB(attacker, ATTR_BASE_UNDER_ATTACK_RETREAT, 0) WRITE_CP_ATTRIB(attacker, ATTR_RETREAT_VALUE, 0)
					end
					if attacker == tribe1 then WRITE_CP_ATTRIB(attacker, ATTR_FIGHT_STOP_DISTANCE, 24+G_RANDOM(8)) else WRITE_CP_ATTRIB(attacker, ATTR_FIGHT_STOP_DISTANCE, 16+G_RANDOM(4)) end --**
					local mksTbl = {}
					if attacker == tribe1 then for i = 106,108 do table.insert(mksTbl,i) end else for i = 102,105 do table.insert(mksTbl,i) end end --**
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
					local targType = -1
					if countBuildings(target) > 0 then
						if (NAV_CHECK(attacker,target,ATTACK_BUILDING,0,0) > 0) or atkType ~= ATTACK_NORMAL then targType = ATTACK_BUILDING else targType = ATTACK_PERSON end
					else
						if (NAV_CHECK(attacker,target,ATTACK_PERSON,0,0) > 0) or atkType ~= ATTACK_NORMAL then targType = ATTACK_PERSON end
					end
					if targType ~= -1 then
						if targType == ATTACK_PERSON and allPopOnVehicles(target) then spell1,spell2,spell3 = M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_INSECT_PLAGUE end
						GIVE_ONE_SHOT(spell1,attacker) GIVE_ONE_SHOT(spell2,attacker) GIVE_ONE_SHOT(spell3,attacker)
						local bbv = iipp(0,1,30,70) --**
						if atkType == ATTACK_NORMAL then bbv = 0 end
						AI_SetTargetParams(attacker,target,true,true)
						ATTACK(attacker, target, numTroops, targType, 0, 969+(stage*10), spell1, spell2, spell3, atkType, bbv, mk1, mk2, 0)
						IncrementAtkVar(attacker,(rndb(1800,2500)) - (G_GAMESTAGE*rndb(150,250))) --**
						success = true
						if attacker == tribe1 then TRIBE1ShamanAtk[1] = getTurn()+rndb(200,300) TRIBE1ShamanAtk[2] = rndb(2,3) else TRIBE2ShamanAtk[1] = getTurn()+rndb(200,300) TRIBE2ShamanAtk[2] = rndb(3,4) end
						log_msg(attacker,"target: " .. target .. ", numTroops: " .. numTroops .. ", targType: " .. targType .. ", spell1: " .. spell1 .. ", spell2: " .. spell2 .. ", spell3: " .. spell3 .. ", atkType: " .. atkType .. ", mk1: " .. mk1 .. ", mk2: " .. mk2)
					end
				end
			end
		end
	end

	if not success then IncrementAtkVar(attacker,400-G_GAMESTAGE*50) log_msg(attacker,"attack") end
end

function IncrementAtkVar(pn,amt)
	if pn == tribe1 then
		TRIBE1atk = TRIBE1atk + amt
	else
		TRIBE2atk = TRIBE2atk + amt
	end
end

function sendRandomUnit(pn,model)
	local t = randomUnit(pn,model,false)
	local targetThing,targetOwner = nil,iipp(TRIBE_BLUE,TRIBE_RED,20,80)
	if rnd() < 60 then
		targetThing = get_me_a_random_building(targetOwner,false,true)
	else
		targetThing = get_me_a_random_person(targetOwner)
	end
	if nilT(targetThing) then
		unitNavAndMoveC3d(t,targetThing.Pos.D3)
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
M_SPELL_SWAMP,
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
M_SPELL_SWAMP,
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
	--for i = 5,55 do Plant(i,i,-1) end
	
	SET_NO_REINC(TRIBE_BLUE)
	SET_NO_REINC(TRIBE_RED)

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
	set_player_can_build(M_BUILDING_SUPER_TRAIN, pn);
	set_player_can_build(M_BUILDING_TEMPLE, pn);
	set_player_can_build(M_BUILDING_BOAT_HUT_1, pn);
	set_player_can_build(M_BUILDING_AIRSHIP_HUT_1, pn);

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
	set_player_can_build(M_BUILDING_TEMPLE, pn);
	set_player_can_build(M_BUILDING_BOAT_HUT_1, pn);
	set_player_can_build(M_BUILDING_AIRSHIP_HUT_1, pn);

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
	
	-------------------------------------------------------------------------
	
	local pn = tribe3
	AI_Initialize(pn);
	
	-------------------------------------------------------------------------
	
	local pn = tribe4
	AI_Initialize(pn);
	
	-------------------------------------------------------------------------
	
	local pn = tribe5
	AI_Initialize(pn);
	
	-------------------------------------------------------------------------
	
	local pn = tribe6
	AI_Initialize(pn);
end

function _OnPostLevelInit(level_id)
	--stuff for humans
	--[[set_player_can_cast(M_SPELL_LAND_BRIDGE, TRIBE_BLUE);
	set_player_can_cast(M_SPELL_LIGHTNING_BOLT, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_INVISIBILITY, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_SWAMP, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_HYPNOTISM, TRIBE_RED);
	set_player_cannot_cast(M_SPELL_EARTHQUAKE, TRIBE_RED);
	for k,v in ipairs(G_HUMANS) do
		set_player_can_cast(M_SPELL_GHOST_ARMY, v);
		set_correct_gui_menu();
	end]]
	--stuff for AI
	
	for k,v in ipairs(G_AI_ALIVE) do
		for kk,vv in ipairs(G_AI_ALIVE) do
			if v ~= vv then
				set_players_allied(v,vv)
				set_players_allied(vv,v)
			end
		end
	end
	G_AI_EXPANSION_TABLE[tribe1][1] = G_AI_EXPANSION_TABLE[tribe1][1] + rndb(60,120)
	SET_DEFENCE_RADIUS(tribe1,9)
	SET_DEFENCE_RADIUS(tribe2,9)
	SET_DEFENCE_RADIUS(tribe3,9)
	SET_DEFENCE_RADIUS(tribe4,9)
	--patrols
	
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
