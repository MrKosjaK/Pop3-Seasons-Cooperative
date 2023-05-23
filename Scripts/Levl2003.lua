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

--M_BUILDING_TEPEE,M_BUILDING_DRUM_TOWER,M_BUILDING_WARRIOR_TRAIN,M_BUILDING_SUPER_TRAIN,M_BUILDING_TEMPLE,INT_M_BUILDING_SPY_TRAIN,M_BUILDING_BOAT_HUT_1,M_BUILDING_AIRSHIP_HUT_1 
local stone_heads = {86,87,88}

local AI = {
			{},
			{
				tribe = TRIBE_YELLOW,
				atkTimer = 3700 + (rndb(500,1500)),
				shamanAtkTimer = {4700,2},
				baseMk = {21,14}, --baseMK, rad
				mainTower = {184,8},
				wantedTowers = 5,
				towerMarkers = {30,31,32,33,34},
				atkMks = {27,28,29},
				bldgsCanBuild = {M_BUILDING_TEPEE,M_BUILDING_DRUM_TOWER,M_BUILDING_SUPER_TRAIN,M_BUILDING_TEMPLE,INT_M_BUILDING_SPY_TRAIN},
				spellsCanCast = {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},
				trainingBldgs = {10,4,-1,6}, --required huts to build: spyHut,temple,warHut,fwHut
				unitPref = {spies={8,2},preachers={14,2},wars={0,0},fws={14,2},}, --amt, stageMultiplier
				defPreachMks = {66,67,68,69},
				offPreachMks = {70,71,72,73,74},
				spellsPerStage = {[0]=
								{M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM,M_SPELL_HYPNOTISM},
								{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM}
				},
				Atkspells = {M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND},
				shBlasts = {blast=32, blastNearUnitsChance=30, blastNearUnitsChanceMult=10},
				shLights = {radius=9, lightChance=10, lightChanceMult=10},
				spellEntriesDef = {{spell=M_SPELL_BLAST,cost=8000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=18000,ppl=4,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=24000,ppl=5,pplSM=1,sR=0},{spell=M_SPELL_HYPNOTISM,cost=28000,ppl=5,pplSM=0,sR=1},{spell=M_SPELL_SWAMP,cost=32000,ppl=5,pplSM=0,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=30,pplSM=0,sR=4}},
									--
				spellEntriesOff = {{spell=M_SPELL_BLAST,cost=7000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=14000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=20000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=25000,ppl=8,pplSM=1,sR=1},{spell=M_SPELL_SWAMP,cost=30000,ppl=9,pplSM=1,sR=2},
									--[[{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=25,pplSM=0,sR=4},]]{spell=M_SPELL_EARTHQUAKE,cost=120000,ppl=24,pplSM=2,sR=3},--[[{spell=M_SPELL_EROSION,cost=110000,ppl=20,pplSM=2,sR=3},]]{spell=M_SPELL_FIRESTORM,cost=140000,ppl=32,pplSM=2,sR=3},{spell=M_SPELL_VOLCANO,cost=250000,ppl=40,pplSM=3,sR=4}}
			},
			{
				tribe = TRIBE_GREEN,
				atkTimer = 4000 + (rndb(300,2500)),
				shamanAtkTimer = {3500,3},
				baseMk = {22,13}, --baseMK, rad
				mainTower = {236, 56},
				wantedTowers = 3,
				towerMarkers = {35,36,37},
				atkMks = {38,39,40},
				bldgsCanBuild = {M_BUILDING_TEPEE,M_BUILDING_DRUM_TOWER,M_BUILDING_WARRIOR_TRAIN,M_BUILDING_TEMPLE},
				spellsCanCast = {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},
				trainingBldgs = {-1,5,3,-1}, --required huts to build: spyHut,temple,warHut,fwHut
				unitPref = {spies={0,0},preachers={17,2},wars={14,3},fws={0,0},}, --amt, stageMultiplier
				defPreachMks = {75,76,77,78},
				offPreachMks = {70,71,72,73,74},
				spellsPerStage = {[0]=
								{M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM},
								{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM}
				},
				Atkspells = {M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND},
				shBlasts = {blast=16, blastNearUnitsChance=30, blastNearUnitsChanceMult=10},
				shLights = {radius=9, lightChance=10, lightChanceMult=10},
				spellEntriesDef = {{spell=M_SPELL_BLAST,cost=8000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=20000,ppl=5,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=24000,ppl=6,pplSM=1,sR=0},{spell=M_SPELL_HYPNOTISM,cost=28000,ppl=5,pplSM=0,sR=1},{spell=M_SPELL_SWAMP,cost=32000,ppl=5,pplSM=0,sR=2},
									--[[{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=30,pplSM=0,sR=4}]]},
									--
				spellEntriesOff = {{spell=M_SPELL_BLAST,cost=7000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=15000,ppl=4,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=20000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=25000,ppl=8,pplSM=1,sR=1},{spell=M_SPELL_SWAMP,cost=30000,ppl=9,pplSM=1,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=25,pplSM=0,sR=4},{spell=M_SPELL_EARTHQUAKE,cost=120000,ppl=20,pplSM=2,sR=3},{spell=M_SPELL_EROSION,cost=110000,ppl=20,pplSM=2,sR=3},--[[{spell=M_SPELL_FIRESTORM,cost=140000,ppl=32,pplSM=2,sR=3},{spell=M_SPELL_VOLCANO,cost=250000,ppl=40,pplSM=3,sR=4}]]}
			},
			{
				tribe = TRIBE_CYAN,
				atkTimer = 2900 + (rndb(50,800)),
				shamanAtkTimer = {3100,2},
				baseMk = {23,14}, --baseMK, rad
				mainTower = {154, 116},
				wantedTowers = 8,
				towerMarkers = {41,42,43,44,45},
				atkMks = {46,47,48},
				bldgsCanBuild = {M_BUILDING_TEPEE,M_BUILDING_DRUM_TOWER,M_BUILDING_WARRIOR_TRAIN,M_BUILDING_SUPER_TRAIN},
				spellsCanCast = {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},
				trainingBldgs = {-1,-1,4,5}, --required huts to build: spyHut,temple,warHut,fwHut
				unitPref = {spies={0,0},preachers={0,0},wars={17,2},fws={15,2},}, --amt, stageMultiplier
				defPreachMks = {},
				offPreachMks = {},
				spellsPerStage = {[0]=
								{M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM},
								{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM,M_SPELL_ANGEL_OF_DEATH}
				},
				Atkspells = {M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND},
				shBlasts = {blast=64, blastNearUnitsChance=30, blastNearUnitsChanceMult=10},
				shLights = {radius=9, lightChance=10, lightChanceMult=10},
				spellEntriesDef = {{spell=M_SPELL_BLAST,cost=8000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=20000,ppl=4,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=24000,ppl=7,pplSM=1,sR=0},{spell=M_SPELL_HYPNOTISM,cost=28000,ppl=5,pplSM=0,sR=1},{spell=M_SPELL_SWAMP,cost=32000,ppl=5,pplSM=0,sR=2},
									--[[{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=30,pplSM=0,sR=4}]]},
									--
				spellEntriesOff = {{spell=M_SPELL_BLAST,cost=7000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=18000,ppl=2,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=20000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=25000,ppl=9,pplSM=1,sR=1},{spell=M_SPELL_SWAMP,cost=30000,ppl=9,pplSM=1,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=25,pplSM=0,sR=4},--[[{spell=M_SPELL_EARTHQUAKE,cost=120000,ppl=26,pplSM=2,sR=3},{spell=M_SPELL_EROSION,cost=110000,ppl=20,pplSM=2,sR=3},]]{spell=M_SPELL_FIRESTORM,cost=140000,ppl=32,pplSM=2,sR=3},{spell=M_SPELL_VOLCANO,cost=250000,ppl=38,pplSM=2,sR=4}}
			},
			{
				tribe = TRIBE_MAGENTA,
				atkTimer = 5300 + (rndb(0,500)),
				shamanAtkTimer = {4300,1},
				baseMk = {24,16}, --baseMK, rad
				mainTower = {46, 208},
				wantedTowers = 5,
				towerMarkers = {40,50,51},
				atkMks = {52,53,54},
				bldgsCanBuild = {M_BUILDING_TEPEE,M_BUILDING_DRUM_TOWER,M_BUILDING_SUPER_TRAIN,M_BUILDING_TEMPLE},
				spellsCanCast = {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},
				trainingBldgs = {-1,6,-1,5}, --required huts to build: spyHut,temple,warHut,fwHut
				unitPref = {spies={0,0},preachers={13,3},wars={0,0},fws={18,2},}, --amt, stageMultiplier
				defPreachMks = {79,80,81,82},
				offPreachMks = {70,71,72,73,74},
				spellsPerStage = {[0]=
								{M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM,M_SPELL_FIRESTORM},
								{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM,M_SPELL_HYPNOTISM}
				},
				Atkspells = {M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND},
				shBlasts = {blast=16, blastNearUnitsChance=30, blastNearUnitsChanceMult=10},
				shLights = {radius=9, lightChance=10, lightChanceMult=10},
				spellEntriesDef = {{spell=M_SPELL_BLAST,cost=8000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=22000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=24000,ppl=4,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=28000,ppl=5,pplSM=0,sR=1},{spell=M_SPELL_SWAMP,cost=32000,ppl=5,pplSM=0,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=32,pplSM=1,sR=3}},
									--
				spellEntriesOff = {{spell=M_SPELL_BLAST,cost=7000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=16000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=20000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=25000,ppl=9,pplSM=0,sR=1},{spell=M_SPELL_SWAMP,cost=30000,ppl=9,pplSM=1,sR=2},
									--[[{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=25,pplSM=0,sR=4},{spell=M_SPELL_EARTHQUAKE,cost=120000,ppl=28,pplSM=2,sR=3},]]{spell=M_SPELL_EROSION,cost=110000,ppl=20,pplSM=2,sR=3},{spell=M_SPELL_FIRESTORM,cost=140000,ppl=32,pplSM=2,sR=3},{spell=M_SPELL_VOLCANO,cost=250000,ppl=44,pplSM=3,sR=4}}
			},
			{
				tribe = TRIBE_BLACK,
				atkTimer = 2200 + (rndb(100,900)),
				shamanAtkTimer = {4700,2},
				baseMk = {25,15}, --baseMK, rad
				mainTower = {34, 170},
				wantedTowers = 3,
				towerMarkers = {55,56},
				atkMks = {57,58},
				bldgsCanBuild = {M_BUILDING_TEPEE,M_BUILDING_DRUM_TOWER,M_BUILDING_WARRIOR_TRAIN,M_BUILDING_TEMPLE,INT_M_BUILDING_SPY_TRAIN},
				spellsCanCast = {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},
				trainingBldgs = {8,4,4,-1}, --required huts to build: spyHut,temple,warHut,fwHut
				unitPref = {spies={9,1},preachers={15,2},wars={15,2},fws={0,0},}, --amt, stageMultiplier
				defPreachMks = {83,84,85},
				offPreachMks = {70,71,72,73,74},
				spellsPerStage = {[0]=
								{M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM,M_SPELL_FIRESTORM},
								{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM}
				},
				Atkspells = {M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND},
				shBlasts = {blast=128, blastNearUnitsChance=30, blastNearUnitsChanceMult=10},
				shLights = {radius=9, lightChance=10, lightChanceMult=10},
				spellEntriesDef = {{spell=M_SPELL_BLAST,cost=8000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=24000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=24000,ppl=5,pplSM=1,sR=1},{spell=M_SPELL_HYPNOTISM,cost=28000,ppl=5,pplSM=0,sR=1},{spell=M_SPELL_SWAMP,cost=32000,ppl=5,pplSM=0,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=28,pplSM=1,sR=4}},
									--
				spellEntriesOff = {{spell=M_SPELL_BLAST,cost=7000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=18000,ppl=4,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=20000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=25000,ppl=7,pplSM=1,sR=2},{spell=M_SPELL_SWAMP,cost=30000,ppl=9,pplSM=1,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=25,pplSM=0,sR=4},{spell=M_SPELL_EARTHQUAKE,cost=120000,ppl=18,pplSM=2,sR=3},--[[{spell=M_SPELL_EROSION,cost=110000,ppl=20,pplSM=2,sR=3},{spell=M_SPELL_FIRESTORM,cost=140000,ppl=32,pplSM=2,sR=3},]]{spell=M_SPELL_VOLCANO,cost=250000,ppl=42,pplSM=3,sR=4}}
			},
			{
				tribe = TRIBE_ORANGE,
				atkTimer = 1950 + (rndb(500,900)),
				shamanAtkTimer = {3700,3},
				baseMk = {26,16}, --baseMK, rad
				mainTower = {32, 76},
				wantedTowers = 6,
				towerMarkers = {59,60,61,62},
				atkMks = {63,64,65},
				bldgsCanBuild = {M_BUILDING_TEPEE,M_BUILDING_DRUM_TOWER,M_BUILDING_WARRIOR_TRAIN,M_BUILDING_SUPER_TRAIN},
				spellsCanCast = {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},
				trainingBldgs = {-1,-1,11,4}, --required huts to build: spyHut,temple,warHut,fwHut
				unitPref = {spies={0,0},preachers={0,0},wars={11,3},fws={22,3},}, --amt, stageMultiplier
				defPreachMks = {},
				offPreachMks = {},
				spellsPerStage = {[0]=
								{M_SPELL_INSECT_PLAGUE,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND},
								{M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM},
								{M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_FIRESTORM,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM},
								{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_HYPNOTISM,M_SPELL_HYPNOTISM,M_SPELL_EARTHQUAKE,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM,M_SPELL_ANGEL_OF_DEATH}
				},
				Atkspells = {M_SPELL_LIGHTNING_BOLT,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND},
				shBlasts = {blast=16, blastNearUnitsChance=30, blastNearUnitsChanceMult=10},
				shLights = {radius=9, lightChance=10, lightChanceMult=10},
				spellEntriesDef = {{spell=M_SPELL_BLAST,cost=8000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=26000,ppl=4,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=24000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=28000,ppl=5,pplSM=0,sR=1},{spell=M_SPELL_SWAMP,cost=32000,ppl=5,pplSM=0,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=32,pplSM=0,sR=4}},
									--
				spellEntriesOff = {{spell=M_SPELL_BLAST,cost=7000,ppl=1,pplSM=0,sR=0},{spell=M_SPELL_INSECT_PLAGUE,cost=14000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_LIGHTNING_BOLT,cost=20000,ppl=3,pplSM=0,sR=0},{spell=M_SPELL_HYPNOTISM,cost=25000,ppl=8,pplSM=1,sR=1},{spell=M_SPELL_SWAMP,cost=30000,ppl=9,pplSM=1,sR=2},
									{spell=M_SPELL_ANGEL_OF_DEATH,cost=200000,ppl=25,pplSM=0,sR=4},--[[{spell=M_SPELL_EARTHQUAKE,cost=120000,ppl=20,pplSM=2,sR=3},]]{spell=M_SPELL_EROSION,cost=110000,ppl=25,pplSM=2,sR=3},{spell=M_SPELL_FIRESTORM,cost=140000,ppl=32,pplSM=2,sR=3}--[[,{spell=M_SPELL_VOLCANO,cost=250000,ppl=40,pplSM=3,sR=4}]]}
			}
}

--level vars
local PlayersStats = { --reinc cdr (seconds), yin or yang
		[0]= {-1,"none"},{-1,"none"}				
}
local level_completed = false
local yinYangCDR = 0
local borderRad = 22
--SET_TIMER_GOING(12*60*45 + 12, 1)

function _OnTurn(turn)

	local stage = G_GAMESTAGE
	
	------------------------------------------------------------------------------------------------------------------------
	-- AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	if stage > 0 then
		--build towers
		if everySeconds(180-stage*18) then
			buildTowers(stage)
		end
	end

	--Process AIs on turn
	for k,v in ipairs(G_AI_ALIVE) do
		Sulk(v,stage+5)
		--small AI boosts
		fasterTrain(v,28+12*stage)
		fasterHutBars(v,16+6*stage,false)
		--priorities
		if everySeconds(12) then
			updateGameStage(9,18,24,32)
			updateBasePriorities(v)
			unstuckS(v)
			trainingHutsPriorities(v)
		end
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
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			if tribe.atkTimer == turn then attack(k) end
			if tribe.shamanAtkTimer == turn then Shamanattack(k) end
		end
	end
	
	if everySeconds(3) then
		ProcessAgressiveShaman()
		ProcessUnitMoveTbl()
		--ProcessIslandStalagtites()
		for i = #unitAtkunitTbl,1,-1 do unstuckT(unitAtkunitTbl[i]) table.remove(unitAtkunitTbl,i) end
	end
	if everySeconds(7-stage) then
		ProcessDefensiveShaman()
	end
	if everySeconds(8) then
		FillRndEmptyTower(2,iipp(M_PERSON_SUPER_WARRIOR,M_PERSON_RELIGIOUS,85,15))
		FillRndEmptyTower(3,M_PERSON_RELIGIOUS)
		FillRndEmptyTower(4,M_PERSON_SUPER_WARRIOR)
		FillRndEmptyTower(5,iipp(M_PERSON_SUPER_WARRIOR,M_PERSON_RELIGIOUS,60,40))
		FillRndEmptyTower(6,M_PERSON_RELIGIOUS)
		FillRndEmptyTower(7,M_PERSON_SUPER_WARRIOR)
		updateSpellEntries()
	end
	if everySeconds(15) then
		giveSpellsOccasionally()
		updateConvertParams()
		updateSpellBuckets(stage)
	end
	if everySeconds(30-stage) then
		DefensivePreachMarkers()
		DefendStoneHeads()
		updateTroopsAndAtkParams()
		DefensiveMarkerEntries()
	end
	if everySeconds(60-stage*10) then
		if stage > 0 then
			sendRandomUnit(2,iipp(M_PERSON_RELIGIOUS,M_PERSON_SUPERWARRIOR,50,50))--
			sendRandomUnit(5,iipp(M_PERSON_RELIGIOUS,M_PERSON_SUPERWARRIOR,50,50))
			if stage > 1 then
				sendRandomUnit(3,iipp(M_PERSON_RELIGIOUS,M_PERSON_WARRIOR,50,50))
				sendRandomUnit(6,iipp(M_PERSON_RELIGIOUS,M_PERSON_WARRIOR,50,50))
				if stage > 2 then
					sendRandomUnit(4,iipp(M_PERSON_WARRIOR,M_PERSON_SUPER_WARRIOR,50,50))
					sendRandomUnit(7,iipp(M_PERSON_WARRIOR,M_PERSON_SUPER_WARRIOR,50,50))
				end
			end
		end
	end
	if everySeconds(130-stage*15) then
		OffensiveMarkerEntries()
	end
	if everySeconds(180-stage*10) then
		OffensivePreachMarkers()
	end
	------------------------------------------------------------------------------------------------------------------------
	-- NON-AI STUFF
	------------------------------------------------------------------------------------------------------------------------
	
	if turn == 12 then
		--FooterMsg("Centuries ago, on this very location, the high priests forged a magical rune that would shape the way mana flew through the body. Unfortunately, all of them got murdered by the tribes that inhabited the planet, and the location got lost forever... Until two tribes found it...", 2, 171)
	elseif turn == 12*60 then
		--FooterMsg("Work together and destroy all 6 enemy tribes before you run out of time.", 2, 175)
		FooterMsg("Work together and destroy all 6 enemy tribes.", 2, 175)
	elseif turn == 12*120 then
		FooterMsg("The shaman with yin (offensive) reincarnates after 40 seconds, while the shaman with yan (defensive) reincarnates twice as fast.", 2, 174)
	end
	if everySeconds(1) then
		if not level_completed and (gns.Flags & GNS_LEVEL_COMPLETE ~= 0) then
			level_completed = true
			--REMOVE_TIMER()
		end
		--[[if HAS_TIMER_REACHED_ZERO() and not level_completed then
			FooterMsg("You did not kill all enemy tribes on time. Your journey ends here...", 2, 174)
			LOSE()
			REMOVE_TIMER()
			killTribe(0) killTribe(1)
		end]]
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
	--process swamps
	ProcessTiledSwamps()
	--yin yang cdr
	if yinYangCDR > 0 then yinYangCDR = yinYangCDR - 1 end
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

local YinSpells = {M_SPELL_BLAST,M_SPELL_CONVERT_WILD,M_SPELL_INSECT_PLAGUE,M_SPELL_GHOST_ARMY,M_SPELL_LIGHTNING_BOLT,M_SPELL_SWAMP,M_SPELL_LAND_BRIDGE,M_SPELL_FIRESTORM,M_SPELL_FLATTEN,M_SPELL_SHIELD}
local YangSpells = {M_SPELL_BLAST,M_SPELL_GHOST_ARMY,M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM,M_SPELL_ANGEL_OF_DEATH,M_SPELL_LAND_BRIDGE,M_SPELL_CONVERT_WILD} --add blizzard

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
			GIVE_ONE_SHOT(M_SPELL_BLAST,0) GIVE_ONE_SHOT(M_SPELL_BLAST,0)
		else
			for k,v in ipairs(YangSpells) do set_player_cannot_cast(v, 1) end for k,v in ipairs(YinSpells) do set_player_can_cast(v, 1) end GIVE_MANA_TO_PLAYER(0,-9999999)
			for k,v in ipairs(YinSpells) do set_player_cannot_cast(v, 0) end for k,v in ipairs(YangSpells) do set_player_can_cast(v, 0) end GIVE_MANA_TO_PLAYER(1,-9999999)
			GIVE_ONE_SHOT(M_SPELL_BLAST,1) GIVE_ONE_SHOT(M_SPELL_BLAST,1)
		end
		set_correct_gui_menu()
	end
end

----------------------------------------------------

function DefensiveMarkerEntries()
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			if AI_EntryAvailable(k) then
				if _gsi.Players[k].NumPeopleOfType[M_PERSON_SUPER_WARRIOR] > 4 and rnd() < 70 then
					MARKER_ENTRIES(k, 0,1,2,-1)
				end
				if _gsi.Players[k].NumPeopleOfType[M_PERSON_WARRIOR] > 4 and rnd() < 60 then
					MARKER_ENTRIES(k, 3,4,5,-1)
				end
			end
		end
	end
end

function OffensiveMarkerEntries()
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			if AI_EntryAvailable(k) then
				if _gsi.Players[k].NumPeopleOfType[M_PERSON_SUPER_WARRIOR] > 6 and rnd() < 50 then
					MARKER_ENTRIES(k, 6,7,8,-1)
				end
			end
		end
	end	
end

function buildTowers(stage)
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			local ct = countTowers(k,true)
			if ct < tribe.wantedTowers then
				local towerMk = randomItemFromTable(tribe.towerMarkers)
				BUILD_DRUM_TOWER(k,markerIdxX(towerMk),markerIdxZ(towerMk))
			end
		end
	end
end

function Shamanattack(attacker)
	local success = false
	if AI_EntryAvailable(attacker) and nilS(attacker) and IS_SHAMAN_AVAILABLE_FOR_ATTACK(attacker) then
		if #G_HUMANS_ALIVE > 0 then --wont bother to continue level(attack) if only AIs exist
			local stage = G_GAMESTAGE
			local target = iipp(TRIBE_BLUE,TRIBE_RED,50,50)
			if #G_HUMANS_ALIVE == 1 then target = randomItemFromTable(G_HUMANS_ALIVE) end
			local atkType = ATTACK_NORMAL
			local targ = iipp(ATTACK_PERSON,ATTACK_BUILDING,50,50) --**
			if (NAV_CHECK(attacker,target,targ,0,0) > 0) or atkType ~= ATTACK_NORMAL then
				if AI[attacker].shamanAtkTimer[2] > 0 then
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
						{M_SPELL_WHIRLWIND,M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_EROSION},
						{M_SPELL_WHIRLWIND,M_SPELL_EARTHQUAKE,M_SPELL_FIRESTORM,M_SPELL_EROSION,iipp(M_SPELL_ANGEL_OF_DEATH,M_SPELL_EARTHQUAKE,20,80)}}
					if targ == ATTACK_BUILDING then
						spell2,spell3 = randomItemFromTable(tierSpellsPerStageVsBldgs[stage]),randomItemFromTable(tierSpellsPerStageVsBldgs[stage]) else spell2,spell3 = randomItemFromTable(tierSpellsPerStageVsPers[stage]),randomItemFromTable(tierSpellsPerStageVsPers[stage])
					end
					if stage == 0 then spell3 = 0 end
					GIVE_ONE_SHOT(spell1,attacker) GIVE_ONE_SHOT(spell2,attacker) GIVE_ONE_SHOT(spell3,attacker)
					WRITE_CP_ATTRIB(attacker, ATTR_DONT_GROUP_AT_DT, 1) WRITE_CP_ATTRIB(attacker, ATTR_GROUP_OPTION, 3)
					AI_SetTargetParams(attacker,target,true,true)
					ATTACK(attacker, target, 1, targ, 0, 999, spell1, spell2, spell3, atkType, 0, -1, -1, 0)
					IncrementShamanAtkVar(attacker,(rndb(3500,4500)) - (stage*rndb(200,400))) --**
					success = true
					AI[attacker].shamanAtkTimer[2] = AI[attacker].shamanAtkTimer[2] - 1
					--log_msg(attacker,"shaman atack vs " .. target .. ", spells: " .. spell1 .. " " .. spell2 .. " " .. spell3)
				end
			end
		end
	end
	
	if not success then IncrementShamanAtkVar(attacker,450-G_GAMESTAGE*25) --[[LOG("fail shaman atk")]] end
end

function IncrementShamanAtkVar(pn,amt)
	AI[pn].shamanAtkTimer[1] = AI[pn].shamanAtkTimer[1] + amt
end

function attack(attacker)
	local success = false
	if #G_HUMANS_ALIVE > 0 then --wont bother to continue level(attack) if only AIs exist
		if AI_EntryAvailable(attacker) then
			local stage = G_GAMESTAGE
			local target = iipp(TRIBE_BLUE,TRIBE_RED,50,50)
			if #G_HUMANS_ALIVE == 1 then target = randomItemFromTable(G_HUMANS_ALIVE) end
			local troops = countTroops(attacker)
			if troops > 4 + stage*2 then
				local numTroops = rndb(3,4) + stage*2 --**
				if IS_SHAMAN_AVAILABLE_FOR_ATTACK(attacker) == 0 then WRITE_CP_ATTRIB(attacker, ATTR_AWAY_MEDICINE_MAN, 0) else WRITE_CP_ATTRIB(attacker, ATTR_AWAY_MEDICINE_MAN, btn(rnd() < 80+10*stage)) end
				local atkType = ATTACK_NORMAL
				if atkType == ATTACK_NORMAL then
					if stage < 2 then
						WRITE_CP_ATTRIB(attacker, ATTR_BASE_UNDER_ATTACK_RETREAT, 1) WRITE_CP_ATTRIB(attacker, ATTR_RETREAT_VALUE, rndb(0,12))
					else
						WRITE_CP_ATTRIB(attacker, ATTR_BASE_UNDER_ATTACK_RETREAT, 0) WRITE_CP_ATTRIB(attacker, ATTR_RETREAT_VALUE, 0)
					end
					WRITE_CP_ATTRIB(attacker, ATTR_FIGHT_STOP_DISTANCE, 32+G_RANDOM(8))
					local mksTbl = AI[attacker].atkMks
					local mk1,mk2 = randomItemFromTable(mksTbl),-1
					updateAtkSpells(stage)
					local spell1,spell2,spell3 = AI[attacker].Atkspells[1],AI[attacker].Atkspells[2],AI[attacker].Atkspells[3]
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
						if (NAV_CHECK(attacker,target,ATTACK_BUILDING,0,0) > 0) then targType = ATTACK_BUILDING else if (NAV_CHECK(attacker,target,ATTACK_PERSON,0,0) > 0) then targType = ATTACK_PERSON end end
					else
						if (NAV_CHECK(attacker,target,ATTACK_PERSON,0,0) > 0) then targType = ATTACK_PERSON end
					end
					if targType ~= -1 then
						--if targType == ATTACK_PERSON and allPopOnVehicles(target) then spell1,spell2,spell3 = M_SPELL_INSECT_PLAGUE,M_SPELL_LIGHTNING_BOLT,M_SPELL_INSECT_PLAGUE end
						GIVE_ONE_SHOT(spell1,attacker) GIVE_ONE_SHOT(spell2,attacker) GIVE_ONE_SHOT(spell3,attacker)
						AI_SetTargetParams(attacker,target,true,true)
						ATTACK(attacker, target, numTroops, targType, 0, 959+(stage*10), spell1, spell2, spell3, atkType, 0, mk1, mk2, 0)
						IncrementAtkVar(attacker,(rndb(3800,4800)) - (stage*rndb(400,600))) --**
						success = true
						AI[attacker].shamanAtkTimer[1] = getTurn()+rndb(500,800)
						AI[attacker].shamanAtkTimer[2] = getTurn()+rndb(1,4)
						--log_msg(attacker,"target: " .. target .. ", numTroops: " .. numTroops .. ", targType: " .. targType .. ", spell1: " .. spell1 .. ", spell2: " .. spell2 .. ", spell3: " .. spell3 .. ", atkType: " .. atkType .. ", mk1: " .. mk1 .. ", mk2: " .. mk2)
					end
				end
			end
		end
	end

	if not success then IncrementAtkVar(attacker,600-G_GAMESTAGE*50) --[[log_msg(attacker,"fail attack")]] end
end

function IncrementAtkVar(pn,amt)
	AI[pn].atkTimer = AI[pn].atkTimer + amt
end

function sendRandomUnit(pn,model)
	local t = randomUnit(pn,model,false)
	local targetThing,targetOwner = nil,iipp(TRIBE_BLUE,TRIBE_RED,50,50)
	if rnd() < 60 then
		targetThing = get_me_a_random_building(targetOwner,false,true)
	else
		targetThing = get_me_a_random_person(targetOwner)
	end
	if nilT(targetThing) then
		unitNavAndMoveC3d(t,targetThing.Pos.D3)
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
	for k, tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			if isShamanHome(k,tribe.baseMk[1],tribe.baseMk[2]) then --pn,mk,rad
				GetRidOfNearbyEnemies(k,1,tribe.shBlasts.blastNearUnitsChance + G_GAMESTAGE*tribe.shBlasts.blastNearUnitsChanceMult)
				if rnd() < 50 then TargetNearbyShamans(k,tribe.shLights.radius+G_GAMESTAGE, tribe.shLights.lightChance + G_GAMESTAGE*tribe.shLights.lightChanceMult) end
			end
		end
	end
end

function ProcessAgressiveShaman()
	for k, tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			if not isShamanHome(k,tribe.baseMk[1],tribe.baseMk[2]) then --pn,mk,rad
				GetRidOfNearbyEnemies(k,1,tribe.shBlasts.blastNearUnitsChance + G_GAMESTAGE*tribe.shBlasts.blastNearUnitsChanceMult)
				if rnd() < 50 then GIVE_ONE_SHOT(M_SPELL_LIGHTNING_BOLT,k) TargetNearbyShamans(k,tribe.shLights.radius+G_GAMESTAGE, tribe.shLights.lightChance + G_GAMESTAGE*tribe.shLights.lightChanceMult) end
			end
		end
	end
end

function updateTroopsAndAtkParams()
	local stage = G_GAMESTAGE
	local atkp = 100 + stage*5 if atkp > 140 then atkp = 140 end
	
	for k, tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			WRITE_CP_ATTRIB(k, ATTR_ATTACK_PERCENTAGE, atkp)
			--auto train units occasionally
			if rnd() < 50 then --50% chance for main code executte
				local braves = _gsi.Players[k].NumPeopleOfType[M_PERSON_BRAVE]
				local troopAmmount = countTroops(k)
				if troopAmmount < math.floor(braves/3) then
					local up = tribe.unitPref
					local troopsType = {{M_PERSON_WARRIOR,up.wars[1]+up.wars[2]*stage},{M_PERSON_RELIGIOUS,up.preachers[1]+up.preachers[2]*stage},{M_PERSON_SUPER_WARRIOR,up.fws[1]+up.fws[2]*stage},{M_PERSON_SPY,up.spies[1]+up.spies[2]*stage}}
					for kk,v in ipairs(troopsType) do
						if AI_EntryAvailable(k) then
							if AI_GetUnitCount(k,v[1]) < v[2] then TRAIN_PEOPLE_NOW(k,1,v[1]) end
						end
					end
				end
			end
		end
	end
end

function updateSpellEntries()
	local s = G_GAMESTAGE
	
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) and nilS(k) then
			if isShamanHome(k,tribe.baseMk[1],tribe.baseMk[2]) then --pn,mk,rad
				for kk,entry in ipairs(tribe.spellEntriesDef) do
					if s >= entry.sR then
						SET_SPELL_ENTRY(k, kk-1, entry.spell, entry.cost >> (1+s), 64, entry.ppl-(entry.pplSM*s), 1)
					end
				end
			else
				for kk,entry in ipairs(tribe.spellEntriesOff) do
					if s >= entry.sR then
						SET_SPELL_ENTRY(k, kk-1, entry.spell, entry.cost >> (1+s), 64, entry.ppl-(entry.pplSM*s), 0)
					end
				end
			end
		end
	end
end

function updateAtkSpells(s)
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			local spellList = {}
			for k,v in ipairs(tribe.spellsPerStage[s]) do table.insert(spellList, v) end
			for i = 1,3 do
				local spell = randomItemFromTable(spellList)
				tribe.Atkspells[i] = spell
				removeFromTable(spellList, spell)
			end
			--feel the need to use SHIELD/INVI?
			if s > 1 then
				local chance = 20+s*10 --40-60% chance
				if rnd() < chance then
					tribe.Atkspells[1] = iipp(M_SPELL_INVISIBILITY,M_SPELL_SHIELD,50,50)
				end
			end
		end
	end
end

function DefensivePreachMarkers()
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			if _gsi.Players[k].NumPeopleOfType[M_PERSON_RELIGIOUS] > 3 then
				for kk,mk in ipairs(tribe.defPreachMks) do
					if rnd() >= 50 then
						PREACH_AT_MARKER(k,mk)
					end
				end
			end
		end
	end
end

function OffensivePreachMarkers()
	if G_GAMESTAGE > 1 then
		for k,tribe in ipairs(AI) do
			if k > 1 and isAlive(k) then
				if _gsi.Players[k].NumPeopleOfType[M_PERSON_RELIGIOUS] > 5 then
					for kk,mk in ipairs(tribe.offPreachMks) do
						if rnd() >= 40 then
							PREACH_AT_MARKER(k,mk)
						end
					end
				end
			end
		end
	end
end

function DefendStoneHeads()
	for key, head in ipairs(stone_heads) do
		for k,tribe in ipairs(AI) do
			if k > 1 and isAlive(k) then
				if countPeopleInArea(TRIBE_BLUE,head,0) > 0 or countPeopleInArea(TRIBE_RED,head,0) > 0 then
					if _gsi.Players[k].NumPeopleOfType[M_PERSON_RELIGIOUS] > 4 and rnd() > 50 then PREACH_AT_MARKER(k,head) end
					if rnd() < 40 and AI_ShamanFree(k) then
						local spellsTbl = {M_SPELL_BLAST,M_SPELL_LIGHTNING_BOLT,M_SPELL_INSECT_PLAGUE,M_SPELL_SWAMP}
						local s = randomItemFromTable(spellsTbl)
						GIVE_ONE_SHOT(s,k)
						SPELL_ATTACK(k,s,head,head)
					end
					break
				end
			end
		end
	end
end

function updateSpellBuckets(s)
	for tribe = 2,7 do
		AI_SpellBucketCost(tribe, M_SPELL_BLAST, 2);
		AI_SpellBucketCost(tribe, M_SPELL_CONVERT_WILD, 2);
		AI_SpellBucketCost(tribe, M_SPELL_INSECT_PLAGUE, 10-s);
		AI_SpellBucketCost(tribe, M_SPELL_INVISIBILITY, 13-s);
		AI_SpellBucketCost(tribe, M_SPELL_LIGHTNING_BOLT, 12-s);
		AI_SpellBucketCost(tribe, M_SPELL_HYPNOTISM, 17-s);
		AI_SpellBucketCost(tribe, M_SPELL_EARTHQUAKE, 32-s);
		AI_SpellBucketCost(tribe, M_SPELL_FIRESTORM, 48-s);
		AI_SpellBucketCost(tribe, M_SPELL_WHIRLWIND, 22-s);
		AI_SpellBucketCost(tribe, M_SPELL_GHOST_ARMY, 9-s);
	end
end

function updateConvertParams()
	for pn = 2,7 do
		local cv = btn(GetPop(pn)<45+20*G_GAMESTAGE)
		STATE_SET(pn, cv, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS)
		WRITE_CP_ATTRIB(pn, ATTR_EXPANSION, 25+10*G_GAMESTAGE)
	end
end

function trainingHutsPriorities(pn)
	local pop,huts,s = GetPop(pn),countHuts(pn,false),G_GAMESTAGE
	
	for k,tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			local up = tribe.unitPref
			WriteAiTrainTroops(k, up.wars[1]+up.wars[2]*s, up.preachers[1]+up.preachers[2]*s, up.fws[1]+up.fws[2]*s, up.spies[1]+up.spies[2]*s)
			local bldgsIdx = {ATTR_PREF_SPY_TRAINS,ATTR_PREF_RELIGIOUS_TRAINS,ATTR_PREF_WARRIOR_TRAINS,ATTR_PREF_SUPER_WARRIOR_TRAINS}
			for kk,idx in ipairs(tribe.trainingBldgs) do
				if idx ~= -1 then
					WRITE_CP_ATTRIB(k, bldgsIdx[kk], btn(huts >= idx))
				end
			end
		end
	end
end

--update base priorities
function updateBasePriorities(pn)
	local s,h,b = G_GAMESTAGE, countHuts(pn,true), AI_GetUnitCount(pn, M_PERSON_BRAVE)
	for pn = 2,7 do
		AI_SetBuildingParams(pn,true,96+s*8,rndb(2,4))
	end
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function _OnLevelInit(level_id)
	--scenery
	--for i = 5,55 do Plant(i,i,-1) end
	
	SET_NO_REINC(TRIBE_BLUE)
	SET_NO_REINC(TRIBE_RED)

	--stuff for AI
	for k, tribe in ipairs(AI) do
		if k > 1 and isAlive(k) then
			AI_Initialize(k);

			for kk,spell in ipairs(tribe.spellsCanCast) do
				set_player_can_cast(spell, k);
			end
			
			for kk,bldg in ipairs(tribe.bldgsCanBuild) do
				set_player_can_build(bldg, k);
			end
			
			AI_EnableBuckets(k);
			AI_SpellBucketCost(k, M_SPELL_BLAST, 1);
			AI_SpellBucketCost(k, M_SPELL_CONVERT_WILD, 2);
			AI_SpellBucketCost(k, M_SPELL_INSECT_PLAGUE, 6);
			AI_SpellBucketCost(k, M_SPELL_INVISIBILITY, 13);
			AI_SpellBucketCost(k, M_SPELL_LIGHTNING_BOLT, 11);
			AI_SpellBucketCost(k, M_SPELL_HYPNOTISM, 16);
			AI_SpellBucketCost(k, M_SPELL_EARTHQUAKE, 32);
			AI_SpellBucketCost(k, M_SPELL_FIRESTORM, 48);
			AI_SpellBucketCost(k, M_SPELL_WHIRLWIND, 18);
			AI_SpellBucketCost(k, M_SPELL_GHOST_ARMY, 8);

			AI_SetAways(k, 1, 0, 0, 0, 0);
			AI_SetShamanAway(k, true);
			AI_SetConvertingParams(k, false, false, 24);

			AI_SetBuildingParams(k, true, 50, 3);
			AI_SetTrainingHuts(k, 0, 0, 0, 0);
			AI_SetTrainingPeople(k, true, 10, 0, 0, 0, 0);
			AI_SetVehicleParams(k, false, 0, 0, 0, 0);
			AI_SetFetchParams(k, true, true, true, true);

			AI_SetAttackingParams(k, true, 255, 10, 20);
			AI_SetDefensiveParams(k, true, true, true, true, 3, 2, 1);
			AI_SetSpyParams(k, false, 0, 100, 128, 1);
			AI_SetPopulatingParams(k, true, true);
			
			SET_DEFENCE_RADIUS(k, iipp(7,9,40,60))
			AI_SetShamanParams(k, tribe.mainTower[1], tribe.mainTower[2], true, tribe.shBlasts.blast, 12);
			AI_SetMainDrumTower(k, true, tribe.mainTower[1], tribe.mainTower[2]);
		end
	end
	
	AI_SetSpyParams(TRIBE_YELLOW, true, 32, 40, 64, 4);
end

function _OnPostLevelInit(level_id)
	--stuff for humans
	
	TJournal:AddEntry("The hidden Rune","Me and Dakini have found the location of the magical rune left behind by the high priests, centuries ago.")
	
	--stuff for AI
	
	for k,v in ipairs(G_AI_ALIVE) do
		for kk,vv in ipairs(G_AI_ALIVE) do
			if v ~= vv then
				set_players_allied(v,vv)
				set_players_allied(vv,v)
			end
		end
	end
	
	--marker entries
	local fwDefMks = {{},{89,90,91},{},{95,96,97},{101,102,103},{},{107,108,109}}
	local fwOffMks = {{},{92,93,94},{},{98,99,100},{104,105,106},{},{110,111}}
	local warDefMks = {{},{},{112,113},{114,115,116},{},{117,118},{}}

	for k, tribes in ipairs(AI) do
		if k > 1 and isAlive(k) then
			local entryIdx = 0
			for i = 1,#fwDefMks[k] do
				SET_MARKER_ENTRY(k,entryIdx, fwDefMks[k][i], fwDefMks[k][i], 0, 0, 2, 0)
				entryIdx = entryIdx + 1
			end
			for i = 1,#fwOffMks[k] do
				SET_MARKER_ENTRY(k,entryIdx, fwOffMks[k][i], fwOffMks[k][i], 0, 0, 2, 0)
				entryIdx = entryIdx + 1
			end
			for i = 1,#warDefMks[k] do
				SET_MARKER_ENTRY(k,entryIdx, warDefMks[k][i], -1, 0, math.max(2,G_GAMESTAGE-1), 0, 0)
				entryIdx = entryIdx + 1
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- SCENERY FUNCTIONS
------------------------------------------------------------------------------------------------------------------------




--to do: