include("common.lua");


local curr_season = SEASON_WINTER
local floor = math.floor
local game_stage = 1
local game_stage_cutouts = {60*6, 60*12, 60*18, 60*24, 60*30}
local max_game_stages = #game_stage_cutouts
local ai_tbl = {}


set_level_human_count(2);
set_level_computer_count(2);
add_human_player_start_info(139, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_human_player_start_info(140, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_ai_player_start_info(141, 6, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_ai_player_start_info(142, 4, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});




function ScrOnLevelInit(level_id)
	plants_at_markers(143, 166, curr_season)
end

function OnGameStart()
	local second = get_script_turn()
	
	for k, tribe in ipairs(AI_PLAYERS) do
		local ai_tribe = {}
		local ai_owner = get_ai_player_info(k).Owner
		local ai_diff = get_ai_player_info(k).Difficulty
		
		ai_tribe.tribe = ai_owner
		ai_tribe.diff = diff
		ai_tribe.attack_timer = second + 60*6 - 45*ai_diff + rndb(0, 30)

		table.insert(ai_tbl, ai_tribe)
	end
end



function ScrOnTurn()
	local turn = G_SCRIPT_TURN
	local second = G_SCRIPT_SECOND
	
	if everySeconds(3) then
		-- ai attacks
		for _, ai in ipairs(ai_tbl) do
			local atk_timer = ai.attack_timer
			
			if G_SCRIPT_SECOND >= atk_timer then
				local tribe = ai.tribe
				local target = TRIBE_BLUE
				
				-- attack here nigga
				
				ai.attack_timer = second + 60*6 - 45*ai_diff + rndb(0, 30) - 20*game_stage
				LOG(ai.tribe .. " is attacking player " .. target)
			end
		end
		
		-- game stage increase
		if game_stage < max_game_stages then
			if second >= game_stage_cutouts[game_stage] then
				game_stage = game_stage + 1
			end
		end
	end
end



function ScrOnCreateThing(t_thing)
	
end



function ScrOnFrame(w, h, guiW)
	
end



