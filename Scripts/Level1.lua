-- Includes
include("Common.lua");

gns.GameParams.Flags2 = gns.GameParams.Flags2 | GPF2_GAME_NO_WIN;
gns.GameParams.Flags3 = gns.GameParams.Flags3 & ~GPF3_NO_GAME_OVER_PROCESS;

function _OnTurn(turn)
	if (G_INIT) then
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

		G_INIT = false;
	end

	Sulk(TRIBE_RED,6);
end


function _OnPlayerDeath(pn)
end



function _OnCreateThing(t)
end


function _OnSave(sd)
end

function _OnLoad(ld)
end
