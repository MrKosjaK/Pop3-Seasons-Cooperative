-- Includes
include("Common.lua");
include("CVault.lua");

gns.GameParams.Flags2 = gns.GameParams.Flags2 | GPF2_GAME_NO_WIN;
gns.GameParams.Flags3 = gns.GameParams.Flags3 & ~GPF3_NO_GAME_OVER_PROCESS;

-- Fake vault of knowledge
local c3d_vok = MAP_XZ_2_WORLD_XYZ(134, 134);
centre_coord3d_on_block(c3d_vok);
c3d_vok.Ypos = 192;

-- Needs to be saved as well
VaultOfKnowledge = CVault:CreateVault(c3d_vok, 0);

function _OnTurn(turn)
	if (G_INIT) then
		-- Misc stuff
		VaultOfKnowledge:InitVault();

		ProcessGlobalTypeList(T_PERSON, function(t_thing)
			if (t_thing.Owner == TRIBE_RED) then
				if (t_thing.Model == M_PERSON_BRAVE or t_thing.Model == M_PERSON_SUPER_WARRIOR) then
					t_thing.u.Pers.MaxLife = t_thing.u.Pers.MaxLife >> 3;
					t_thing.u.Pers.Life = t_thing.u.Pers.MaxLife;
					return true;
				end

				if (t_thing.Model == M_PERSON_WARRIOR) then
					t_thing.u.Pers.MaxLife = t_thing.u.Pers.MaxLife >> 2;
					t_thing.u.Pers.Life = t_thing.u.Pers.MaxLife;
					return true;
				end
			end
			return true;
		end);

		-- Computer player initialization part

		-- Init the red tribe
		AI_Initialize(TRIBE_RED);

		-- Set spell attributes for red
		set_player_can_cast(M_SPELL_BLAST, TRIBE_RED);
		set_player_can_cast(M_SPELL_CONVERT_WILD, TRIBE_RED);

		-- Set building attributes for red
		set_player_can_build(M_BUILDING_TEPEE, TRIBE_RED);
		set_player_can_build(M_BUILDING_DRUM_TOWER, TRIBE_RED);

		-- Set internal attributes for red
		AI_SetAways(TRIBE_RED, 5, 0, 0, 0, 0);
		AI_SetShamanAway(TRIBE_RED, true);

		AI_SetBuildingParams(TRIBE_RED, false, 0, 0);
		AI_SetTrainingHuts(TRIBE_RED, 0, 0, 0, 0);
		AI_SetTrainingPeople(TRIBE_RED, false, 0, 0, 0, 0, 0);
		AI_SetVehicleParams(TRIBE_RED, false, 0, 0, 0, 0);
		AI_SetFetchParams(TRIBE_RED, false, false, false, false);

		AI_SetAttackingParams(TRIBE_RED, false, 0, 50);
		AI_SetDefensiveParams(TRIBE_RED, false, false, false, false, 3, 1, 0);
		AI_SetSpyParams(TRIBE_RED, false, 0, 0, 128, 255);
		AI_SetShamanParams(TRIBE_RED, 0, 0, false, 0, 12);
		AI_SetPopulatingParams(TRIBE_RED, false, false);

		AI_SetConvertingParams(TRIBE_RED, false, true, 12);

		-- Don't build the drum tower
		AI_SetMainDrumTower(TRIBE_RED, false, 0, 0);

		-- It has to be done right inside OnTurn because when we're loading a level script our resolution is locked to 640x480
		-- And it's updated right after loading script, if you want dialog to have correct fonts with bigger resolutions, run this once in OnTurn.
		-- For loading "PostLoadItems" function does it automatically for you. Make sure to run it once after loading as well.
		-- I'm not responsible for people who play in one resolution and try to load it in different one, game won't crash but the current dialog will be slightly off.
		-- The next ones however will be fine, I hope.
		-- Example somewhere below
		Engine:AutoScale();
		Engine:StartExecution();

		Engine:CinemaShow();
		Engine:HidePanel();

		-- Initial flyby
		FLYBY_CREATE_NEW();
		FLYBY_ALLOW_INTERRUPT(FALSE);

		-- Move to marker 11
		FLYBY_SET_EVENT_POS(92, 32, 24, 50);
		FLYBY_SET_EVENT_ANGLE(1024, 24, 45);
		FLYBY_SET_EVENT_ZOOM(-10, 34, 24);

		--Move to marker 12
		FLYBY_SET_EVENT_POS(96, 44, 64, 48);
		FLYBY_SET_EVENT_ANGLE(1344, 69, 50);
		--FLYBY_SET_EVENT_ZOOM(-5, 82, 12);

		-- Slowly advance to marker 13
		FLYBY_SET_EVENT_POS(104, 54, 112, 84);
		FLYBY_SET_EVENT_ANGLE(1944, 112, 84);
		FLYBY_SET_EVENT_ZOOM(-25, 122, 60);

		-- Slowly rotate to specific angle on same marker 13
		FLYBY_SET_EVENT_ANGLE(194, 196, 84);
		FLYBY_SET_EVENT_ZOOM(-30, 196, 48);

		-- Move to marker 19 and zoom in
		FLYBY_SET_EVENT_POS(116, 66, 280, 36);
		FLYBY_SET_EVENT_ANGLE(384, 296, 24);
		FLYBY_SET_EVENT_ZOOM(40, 280, 24);

		-- Slightly rotate back at same marker 19
		FLYBY_SET_EVENT_ANGLE(114, 320, 24);

		-- Move to Dakini's outpost camp marker 20
		FLYBY_SET_EVENT_POS(142, 86, 350, 48);
		FLYBY_SET_EVENT_ANGLE(1944, 351, 36);
		FLYBY_SET_EVENT_ZOOM(-30, 360, 50);

		-- Slowly rotate and zoom out further marker 20
		FLYBY_SET_EVENT_ANGLE(1101, 387, 84);
		--FLYBY_SET_EVENT_ZOOM(-35, 410, 60);

		-- Keep slowly rotating further marker 20
		FLYBY_SET_EVENT_ANGLE(200, 460, 84);
		--FLYBY_SET_EVENT_ZOOM(-30, 470, 60);

		-- Move to marker 24
		FLYBY_SET_EVENT_POS(132, 114, 540, 48);
		FLYBY_SET_EVENT_ANGLE(432, 532, 50);
		--FLYBY_SET_EVENT_ZOOM(-25, 528, 36);

		-- Move to marker 25
		FLYBY_SET_EVENT_POS(114, 130, 584, 48);
		FLYBY_SET_EVENT_ANGLE(815, 578, 60);
		--FLYBY_SET_EVENT_ZOOM(-35, 560, 48);

		-- Move to marker 26
		FLYBY_SET_EVENT_POS(100, 130, 629, 36);
		FLYBY_SET_EVENT_ANGLE(1400, 630, 48);

		-- Move to marker 27
		FLYBY_SET_EVENT_POS(82, 124, 663, 36);
		FLYBY_SET_EVENT_ANGLE(1900, 674, 84);
		FLYBY_SET_EVENT_ZOOM(-50, 665, 24);

		-- Move to marker 18
		FLYBY_SET_EVENT_POS(100, 50, 740, 36);
		FLYBY_SET_EVENT_ANGLE(374, 740, 40);
		FLYBY_SET_EVENT_ZOOM(0, 748, 24);


		-- Start flyby
		FLYBY_START();

		-- Buffers creation
		Engine:CreateThingBuffers(2);
		Engine:CreateVarBuffers(1);
		Engine:AllocateVarBuffer(1, 4);

		-- Disable all input for cutscene purposes
		Engine:QueueCommand(AM_CMD_DISABLE_INPUT, 0);

		-- First of all, let's spawn a meteor effect, after it lands we'll spawn shaman, to visualize her arrival to the planet.
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 1, 1, 1, T_EFFECT, M_EFFECT_METEOR, TRIBE_HOSTBOT, marker_to_coord3d_centre(10));
		Engine:QueueCommand(AM_CMD_CLEAR_THING_BUFFER, 2, 1);
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 10, 1, 1, T_PERSON, M_PERSON_MEDICINE_MAN, TRIBE_BLUE, marker_to_coord3d_centre(10));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 11, 2, 20, T_PERSON, M_PERSON_BRAVE, TRIBE_BLUE, marker_to_coord3d_centre(10));

		-- Move shaman to next points
		Engine:QueueCommand(AM_CMD_PERS_GOTO_POINT, 26, 1, marker_to_coord2d(11));
		Engine:QueueCommand(AM_CMD_PERS_GOTO_POINT, 28, 2, marker_to_coord2d(11));
		Engine:QueueCommand(AM_CMD_PERS_GOTO_POINT, 72, 1, marker_to_coord2d(12));
		Engine:QueueCommand(AM_CMD_PERS_GOTO_POINT, 74, 2, marker_to_coord2d(12));
		Engine:QueueCommand(AM_CMD_PERS_GOTO_POINT, 162, 1, marker_to_coord2d(18));

		-- Look at followers
		Engine:QueueCommand(AM_CMD_PERS_LOOK_AT, 210, 1, marker_to_coord2d_centre(12));

		-- Notice Warrior "SOUNDS" lol
		Engine:QueueCommand(AM_CMD_PERS_LOOK_AT, 260, 1, marker_to_coord2d_centre(19));
		Engine:QueueCommand(AM_CMD_PERS_GOTO_POINT, 272, 1, marker_to_coord2d(13));
		Engine:QueueCommand(AM_CMD_PERS_LOOK_AT, 300, 1, marker_to_coord2d_centre(19));

		-- Now need to secretly spawn Dakini warriors and patrol them. BUFFERIDX 2
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 210, 2, 10, T_PERSON, M_PERSON_WARRIOR, TRIBE_RED, marker_to_coord3d_centre(21));
		Engine:QueueCommand(AM_CMD_PERS_PATROL, 211, 2, marker_to_coord2d_centre(19), nil, nil, nil, nil, nil, nil, nil);

		Engine:QueueCommand(AM_CMD_CLEAR_THING_BUFFER, 81, 2);

		-- Create destructive effects on Dakini's outpost.
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 590, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(14));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 602, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(15));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 605, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(35));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 607, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(36));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 609, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(16));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 611, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(28));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 612, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(20));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 613, 2, 1, T_EFFECT, M_EFFECT_FIRESTORM, TRIBE_BLUE, marker_to_coord3d_centre(22));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 614, 2, 1, T_EFFECT, M_EFFECT_FIRESTORM, TRIBE_BLUE, marker_to_coord3d_centre(23));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 642, 2, 1, T_EFFECT, M_EFFECT_SWAMP, TRIBE_BLUE, marker_to_coord3d_centre(19));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 650, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(29));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 660, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(37));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 724, 2, 1, T_EFFECT, M_EFFECT_FIRESTORM, TRIBE_BLUE, marker_to_coord3d_centre(30));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 727, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(26));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 767, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(32));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 768, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(33));
		Engine:QueueCommand(AM_CMD_CREATE_THINGS, 790, 2, 1, T_EFFECT, M_EFFECT_WHIRLWIND, TRIBE_BLUE, marker_to_coord3d_centre(31));
		Engine:QueueCommand(AM_CMD_CLEAR_THING_BUFFER, 850, 2);

		-- Shaman goes to create a reincarnation site
		Engine:QueueCommand(AM_CMD_PERS_LOOK_AT, 880, 1, marker_to_coord2d_centre(18));
		Engine:QueueCommand(AM_CMD_PREPARE_COR, 885, TRIBE_BLUE, marker_to_coord3d_centre(18));

		-- Messages part
		Engine:QueueCommand(AM_CMD_QUEUE_MSG, 24, "In my ascension I have seen this new Solar System, larger than any system we've ever encountered before. <d:25> However our people need a new shaman, and I have carefully selected you to lead them. <d:25> You have the visions, as I once did, I have every faith in your ability to lead the Ikani people in my stead.", "Ikani God", 244, 3928, 1, 10, 24);
		Engine:QueueCommand(AM_CMD_QUEUE_MSG, 184, "Thank you, Oh Great One, our people still revere your many triumphant victories over our foes, I can only pray that I am just as capable a Shaman as you once were. <d:90> Wait... <d:30> what is that sound..?", "Ikani Acolyte", 244, 6883, 1, 2, 24);
		Engine:QueueCommand(AM_CMD_QUEUE_MSG, 294, "It sounds like... <d:60> warriors.", "Ikani God", 244, 3928, 1, 10, 24);
		Engine:QueueCommand(AM_CMD_QUEUE_MSG, 424, "Is that the... <d:60> Dakini? <d:60> What are they doing here?! <d:60> And in such large numbers?!", "Ikani Acolyte", 244, 6883, 1, 2, 24);
		Engine:QueueCommand(AM_CMD_QUEUE_MSG, 500, "Urgh... <d:60> I should have known it would not be so simple for us. <d:25> Their presence here no doubt means all of our old enemies know of this system. <d:25> I will assist you, Acolyte. <d:25> However, do not become dependent on my powers, the further you progress into the system the weaker I will become, for I am not God here, that is an honour I will leave to you.", "Ikani God", 244, 3928, 1, 10, 24);
		Engine:QueueCommand(AM_CMD_QUEUE_MSG, 720, "Ikani Tribe, once again you are here dirtying the system with your presence. <d:25> Do you truly believe that this will be enough to stop my Tribe? <d:25> I will crush every last one of you and take great pleasure in squeezing the life out of your acolyte.", "Dakini Shaman", 244, 6903, 1, 3, 24);
		Engine:QueueCommand(AM_CMD_QUEUE_MSG, 840, "Her words are mere bluster, I've dealt them a crippling blow. <d:25> The rest is up to you now, build up your tribe, and crush her. <d:25> I wish I could impart my knowledge unto you, but it is forbidden, each Shaman must gather her own knowledge, her own power.", "Ikani God", 244, 3928, 1, 10, 24);

		-- Enable input back
		Engine:QueueCommand(AM_CMD_ENABLE_INPUT, 910);

		-- Show panel
		Engine:QueueCommand(AM_CMD_CINEMA_FADE, 900);
		Engine:QueueCommand(AM_CMD_SHOW_PANEL, 915);

		-- Clean up
		Engine:QueueCommand(AM_CMD_CLEAR_THING_BUFFER, 916, 1);
		Engine:QueueCommand(AM_CMD_CLEAR_THING_BUFFER, 917, 2);
		Engine:QueueCommand(AM_CMD_SET_VAR, 919, 1, 2, 1);
		Engine:QueueCommand(AM_CMD_ENGINE_STOP, 920);

		G_INIT = false;
	end
	Sulk(TRIBE_RED,6)

	if (Engine:GetVar(1, 2) == 1) then
		AI_SetBuildingParams(TRIBE_RED, true, 9, 1);
		if (get_game_difficulty() == G_DIFF_BEGINNER) then
			Engine:CreateClock("HutTutorial", 100);
			Engine:SetVar(1, 2, 8);
		else
			Engine:CreateClock("HutToolTip", 100);
			Engine:SetVar(1, 2, 2);
		end
	end

	-- Tutorial part brah
	if (Engine:GetVar(1, 2) >= 8) then
		if (Engine:TickClock("HutTutorial")) then
			local TUT_STATE = Engine:GetVar(1, 2);

			if (TUT_STATE == 8) then
				Engine:SetVar(1, 2, 9);
				Engine:QueueMsg("Left click the Buildings Panel and left click the hut icon to select the hut plan, click somewhere on the ground in a suitable location to place the hut. A suitable location is where no part of the hut plan is red.", "Ikani God", 244, 3928, 1, 10, 36);
			end

			if (TUT_STATE == 10) then
				Engine:SetVar(1, 2, 2)
				Engine:QueueMsg("Good, now select braves and click on the hut to begin building it, braves will automatically find nearby wood and start flattening out the land, ready for construction.", "Ikani God", 244, 3928, 1, 10, 36);
				Engine:CreateClock("HutToolTip", 64);
			end
		end
	end

	-- Main stuff
	if (Engine:GetVar(1, 2) == 2) then
		if (Engine:TickClock("HutToolTip")) then
			local huts = G_PLR_PTR[TRIBE_BLUE].NumBuildingsOfType[1] + G_PLR_PTR[TRIBE_BLUE].NumBuildingsOfType[2] + G_PLR_PTR[TRIBE_BLUE].NumBuildingsOfType[3];
			if (huts >= 1) then
				Engine:SetVar(1, 1, 1); -- Make enemy start attacking, if difficulty allows it
				Engine:CreateClock("DakiniAttack", 2440);
				AI_SetAttackingParams(TRIBE_RED, true, 1, 30);

				Engine:SetVar(1, 2, 3);
				Engine:CreateClock("StoneHeadR", 120);
				Engine:QueueMsg("Huts are the backbone of any successful tribe, no tribe can grow without them. Make sure you always build huts and keep your Population growing, doing so will increase your mana-flow and increase the number of followers willing to die in your name.", "Ikani God", 244, 3928, 1, 10, 36);
			else
				Engine:CreateClock("HutToolTip", 48);
			end
		end
	elseif (Engine:GetVar(1, 2) == 3) then
		if (Engine:TickClock("StoneHeadR")) then
			TRIGGER_THING(34);
			Engine:CreateClock("StoneHeadR", 144);
			Engine:SetVar(1, 2, 4);
		end
	elseif (Engine:GetVar(1, 2) == 4) then
		if (Engine:TickClock("StoneHeadR")) then
			local x, z = CAMERA_X(), CAMERA_Z();
			local c3d = MAP_XZ_2_WORLD_XYZ(x, z); -- Camera position
			local c3d_2 = MAP_XZ_2_WORLD_XYZ(68, 66); -- Stone head position

			if (get_world_dist_xyz(c3d, c3d_2) < 512*6) then
				Engine:SetVar(1, 2, 5);
				Engine:QueueMsg("These stoneheads often contain great gifts for your tribe, it is important to worship them wherever possible. Their magicks will do many things, from altering the land to granting you powerful temporary spells.", "Ikani God", 244, 3928, 1, 10, 36);
			else
				Engine:CreateClock("StoneHeadR", 16);
			end
		end
	end

	-- Attacking stuff
	if (Engine:GetVar(1, 1) == 1) then
		if (Engine:TickClock("DakiniAttack")) then
			local my_peeps = PLAYERS_PEOPLE_OF_TYPE(TRIBE_RED, M_PERSON_BRAVE);
			local ikani_peeps = GET_NUM_PEOPLE(TRIBE_BLUE);

			if (my_peeps >= 24 and ikani_peeps > 0) then
				AI_SetAways(TRIBE_RED, 100, 0, 0, 0, 0);
				AI_SetShamanAway(TRIBE_RED, false);
				ATTACK(TRIBE_RED, TRIBE_BLUE, math.min(8, my_peeps >> 2), ATTACK_BUILDING, -1, 100, M_SPELL_NONE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, 24, NO_MARKER, 0);
				AI_SetAways(TRIBE_RED, 5, 0, 0, 0, 0);
				AI_SetShamanAway(TRIBE_RED, true);
			end

			if (ikani_peeps > 0) then
				Engine:CreateClock("DakiniAttack", 2440);
			end
		end
	end

	-- Ending part
	if (Engine:GetVar(1, 4) == 1) then
		-- Flyby !!!!!!!!!!!!!!!!

		-- Ok so we need to fly to blue's shaman's position and make sure she's alive, if not force respawn her.
		local s = getShaman(TRIBE_BLUE);
		local shaman_soul_returned = false;

		if (s == nil) then
			-- shes dead, find her corpse and set to respawn immediately
			ProcessGlobalTypeList(T_INTERNAL, function(t_thing)
				if (t_thing.Owner == TRIBE_BLUE) then
					if (t_thing.u.SoulConvert.CurrModel == M_PERSON_MEDICINE_MAN and
				      t_thing.u.SoulConvert.ReturnModel == M_PERSON_MEDICINE_MAN) then
								t_thing.Substate = SS_SC2_SOUL_RETURN;
								t_thing.Flags = t_thing.Flags | TF_SUB_STATE_INIT;
								t_thing.DrawInfo.Flags = t_thing.DrawInfo.Flags | DF_THING_NO_DRAW;
								shaman_soul_returned = true;
								return false;
					end
				end
				return true;
			end);
		end

		-- if shaman's soul is returned, we skip this turn, on next one we get our fully fleshy shaman back
		-- once conditions are met, we initiate flyby
		if (not shaman_soul_returned and s ~= nil) then
			remove_all_persons_commands(s);
			Engine:SetVar(1, 4, 2);
			-- get shamans position and go there.
			local mp = MapPosXZ.new();
			mp.Pos = world_coord2d_to_map_idx(s.Pos.D2);

			Engine:QueueCommand(AM_CMD_ADD_THINGS_TO_BUFFER, 130, 1, 1, T_PERSON, M_PERSON_MEDICINE_MAN, TRIBE_BLUE, s.Pos.D3, 1);
			Engine:QueueCommand(AM_CMD_PERS_LOOK_AT, 136, 1, marker_to_coord2d_centre(38));
			Engine:QueueCommand(AM_CMD_PERS_GOTO_POINT, 144, 1, marker_to_coord2d_centre(40));

			FLYBY_CREATE_NEW();
			FLYBY_ALLOW_INTERRUPT(FALSE);

			-- shaman's position
			FLYBY_SET_EVENT_POS(mp.XZ.X, mp.XZ.Z, 4, 24);
			FLYBY_SET_EVENT_ZOOM(-5, 12, 36);
			FLYBY_SET_EVENT_ANGLE(256, 8, 12);

			-- move to buried vok
			FLYBY_SET_EVENT_POS(134, 134, 108, 36);
			FLYBY_SET_EVENT_ZOOM(-30, 122, 24);
			FLYBY_SET_EVENT_ANGLE(768, 120, 26);

			-- slowly rotate around
			FLYBY_SET_EVENT_ANGLE(1536, 140, 84);
			FLYBY_SET_EVENT_ANGLE(256, 210, 84);

			FLYBY_START();
		end
	elseif (Engine:GetVar(1, 4) == 3) then
		VaultOfKnowledge:Open();
		Engine:SetVar(1, 4, 4);
	end

	if (Engine:TickClock("DialogueMoment")) then
		if (Engine:GetVar(1, 3) == 3) then
			Engine:SetVar(1, 3, 4);

			-- Need epico epicly cutscene here bruh
			Engine:StartExecution();

			Engine:QueueCommand(AM_CMD_CLEAR_THING_BUFFER, 0, 1);
			Engine:QueueCommand(AM_CMD_CLEAR_THING_BUFFER, 0, 2);
			Engine:QueueCommand(AM_CMD_CINEMA_RAISE, 1);
			Engine:QueueCommand(AM_CMD_HIDE_PANEL, 1);
			Engine:QueueCommand(AM_CMD_DISABLE_INPUT, 12);
			Engine:QueueCommand(AM_CMD_SET_VAR, 13, 1, 4, 1);


			-- earthquakes for cutscene purposes ofc, none harmed
			Engine:QueueCommand(AM_CMD_CREATE_THINGS, 124, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(39));
			Engine:QueueCommand(AM_CMD_CREATE_THINGS, 160, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(39));
			Engine:QueueCommand(AM_CMD_CREATE_THINGS, 196, 2, 1, T_EFFECT, M_EFFECT_EARTHQUAKE, TRIBE_BLUE, marker_to_coord3d_centre(39));

			-- erode vok
			Engine:QueueCommand(AM_CMD_CREATE_THINGS, 148, 2, 1, T_EFFECT, M_EFFECT_EROSION, TRIBE_BLUE, marker_to_coord3d_centre(38));
			Engine:QueueCommand(AM_CMD_CREATE_THINGS, 149, 2, 1, T_EFFECT, M_EFFECT_EROSION, TRIBE_BLUE, marker_to_coord3d_centre(38));
			Engine:QueueCommand(AM_CMD_CREATE_THINGS, 224, 2, 1, T_EFFECT, M_EFFECT_FLATTEN, TRIBE_BLUE, marker_to_coord3d_centre(38));
			Engine:QueueCommand(AM_CMD_SET_VAR, 230, 1, 4, 3);

			Engine:QueueCommand(AM_CMD_ENABLE_INPUT, 310);
			Engine:QueueCommand(AM_CMD_CINEMA_FADE, 300);
			Engine:QueueCommand(AM_CMD_SHOW_PANEL, 315);
			Engine:QueueCommand(AM_CMD_ENGINE_STOP, 320);
		end

		if (Engine:GetVar(1, 3) == 2) then
			Engine:QueueMsg("Fantastic work, Acolyte. <d:25> No... <d:60> Fantastic work, Shaman. <d:25> You don my mantle well and my people follow you with true loyalty in their hearts. <d:25> This victory shall merely be the first of many. <d:25> However, we are on the mere outskirts of the system... <d:60> maybe we should... <d:60> hold on... <d:60> what is that..?", "Ikani God", 244, 3928, 1, 10, 36);
			Engine:CreateClock("DialogueMoment", 24);
			Engine:SetVar(1, 3, 3);
		end

		if (Engine:GetVar(1, 3) == 1) then
			Engine:QueueMsg("I'll let you have this small victory, novice. <d:25> One day, your God won't be there to save you.", "Dakini Shaman", 244, 7839, 1, 3, 36);
			Engine:CreateClock("DialogueMoment", 96);
			Engine:SetVar(1, 3, 2);
		end
	end

	VaultOfKnowledge:Process();
end


function _OnPlayerDeath(pn)
	if (pn == TRIBE_RED) then
		if (Engine:GetVar(1, 3) == 0) then
			Engine:SetVar(1, 3, 1);
			Engine:CreateClock("DialogueMoment", 12);
		end
	end
end



function _OnCreateThing(t)
	if (t.Type == T_SHAPE) then
		if (t.Owner == TRIBE_BLUE) then
			if (t.u.Shape.BldgModel == 1) then
				if (Engine:GetVar(1, 2) == 9) then
					Engine:CreateClock("HutTutorial", 24);
					Engine:SetVar(1, 2, 10);
				end
			end
		end
	end
end


function _OnSave(sd)
	VaultOfKnowledge:Save(sd);
end

function _OnLoad(ld)
	VaultOfKnowledge:Load(ld);
end
