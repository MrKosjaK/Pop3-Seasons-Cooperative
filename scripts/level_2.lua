include("common.lua");

local UNUSED = 64
local curr_season = SEASON_WINTER
local floor = math.floor
local game_stage = 1
local game_stage_cutouts = {60*6, 60*12, 60*18, 60*24, 60*30}
local ai_tbl = {}
local ai_static_info = {
	--cyan
	{ base_marker = 142, base_radius = 16, cv_rad = 28,
		houses = function(diff) return 30 + diff*20 + game_stage*5 end,
		base_atk_seconds = 60*8, defence_rad = 7,
		spell_entries_per_diff = {
			[AI_EASY] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 2, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 2, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 4, 	location = 0 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 4, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 7, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 6, 	location = 0,	req = function() return game_stage >= 3 end },
			},
			[AI_MEDIUM] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 2, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 4, 	location = 0 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 4, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 4, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 5, 	location = 0,	req = function() return game_stage >= 2 end },
				{ spell = M_SPELL_HYPNOTISM, 		people = 6, 	location = 1 },
				{ spell = M_SPELL_FIRESTORM, 		people = 10, 	location = 1,	req = function() return game_stage >= 3 end },
			},
			[AI_HARD] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 4, 	location = 0 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 3, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 3, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 4, 	location = 0 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 5, 	location = 1 },
				{ spell = M_SPELL_FIRESTORM, 		people = 7, 	location = 1,	req = function() return game_stage >= 2 end },
				{ spell = M_SPELL_EROSION, 			people = function() return 20 - game_stage end, 	location = 1,	req = function() return game_stage >= 3 end },
			},
			[AI_EXTREME] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 4, 	location = 0 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 3, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 2, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 3, 	location = 0 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 3, 	location = 1 },
				{ spell = M_SPELL_FIRESTORM, 		people = 7, 	location = 1,	req = function() return game_stage >= 2 end },
				{ spell = M_SPELL_EROSION, 			people = function() return 16 - game_stage end, 	location = 1,	req = function() return game_stage >= 3 end },
			},
		},
	},
	
	--black
	{ base_marker = 141, base_radius = 18,
		base_atk_seconds = 60*6, defence_rad = 5, cv_rad = 18,
		houses = function(diff) return 20 + diff*10 + game_stage*4 end,
		spell_entries_per_diff = {
			[AI_EASY] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 2, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 2, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 5, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 6, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 6, 	location = 0,	req = function() return game_stage >= 2 end },
			},
			[AI_MEDIUM] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 2, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 4, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 5, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 5, 	location = 0,	req = function() return game_stage >= 2 end },
				{ spell = M_SPELL_HYPNOTISM, 		people = 6, 	location = 1 },
				{ spell = M_SPELL_FIRESTORM, 		people = 10, 	location = 1,	req = function() return game_stage >= 3 end },
			},
			[AI_HARD] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 3, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 4, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 4, 	location = 0 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 5, 	location = 1 },
				{ spell = M_SPELL_FIRESTORM, 		people = 8, 	location = 1,	req = function() return game_stage >= 2 end },
			},
			[AI_EXTREME] = {
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 0 },
				{ spell = M_SPELL_INSECT_PLAGUE, 	people = 1, 	location = 1 },
				{ spell = M_SPELL_LIGHTNING_BOLT, 	people = 3, 	location = 1 },
				{ spell = M_SPELL_WHIRLWIND, 		people = 4, 	location = 1 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 3, 	location = 0 },
				{ spell = M_SPELL_HYPNOTISM, 		people = 4, 	location = 1 },
				{ spell = M_SPELL_FIRESTORM, 		people = 7, 	location = 1,	req = function() return game_stage >= 2 end },
				{ spell = M_SPELL_VOLCANO, 			people = function() return 18 - game_stage end, 	location = 1,	req = function() return game_stage >= 4 end },
			},
		},
	},
}



set_level_human_count(2);
set_level_computer_count(2);
add_human_player_start_info(139, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER}); --human blue
add_human_player_start_info(140, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER}); --human red
add_ai_player_start_info(ai_static_info[1].base_marker, TRIBE_CYAN, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER}); --cyan
add_ai_player_start_info(ai_static_info[2].base_marker, TRIBE_BLACK, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER}); --black




function ScrOnLevelInit(level_id)
	plants_at_markers(143, 166, curr_season)
end

function OnGameStart()
	local second = get_script_turn()
	
	for k, tribe in ipairs(AI_PLAYERS) do
		local ai_tribe = {}
		local ai_owner = get_ai_player_info(k).Owner
		local ai_diff = get_ai_player_info(k).Difficulty
		local static_tbl_ptr = ai_static_info[k]
		local base_marker, base_radius = static_tbl_ptr.base_marker, static_tbl_ptr.base_radius
		local shaman_in_base = is_ai_shaman_in_base(ai_owner, base_marker, base_radius)
		
		ai_tribe.tribe = ai_owner
		ai_tribe.diff = ai_diff
		ai_tribe.attack_timer = second + 60*6 - 45*ai_diff + rndb(0, 30)
		ai_tribe.base_marker = base_marker
		ai_tribe.base_radius = base_radius
		ai_tribe.shaman_inside_base = shaman_in_base
		table.insert(ai_tbl, ai_tribe)
		
		update_ai_spell_entries(ai_owner, k, ai_diff, shaman_in_base)
		ai_set_defence_rad(ai_owner, static_tbl_ptr.defence_rad)
		ai_set_converting_info(ai_owner, true, true, static_tbl_ptr.cv_rad)
		ai_set_bldg_info(ai_owner, true, static_tbl_ptr.houses(ai_diff), ai_diff)
		ai_set_populating_info(ai_owner, true, true)
		ai_set_fetch_info(ai_owner, true, k == 1, k == 1, true)
		
		-- ai_main_drum_tower_info(ai_owner, true, 36, 88)
		-- ai_set_shaman_info(ai_owner, 22, 110, true, 56 - ((AI_PLR2_DIFF - 1) * 16), 16)
		-- ai_set_defensive_info(ai_owner, true, true, true, true, 1, 3, 1)
		-- ai_set_attack_info(ai_owner, true, 1, 30 - ((AI_PLR2_DIFF - 1) * 10), 12)
		-- ai_set_training_huts(ai_owner, 1, 0, 1, 0)
		-- ai_set_training_people(ai_owner, true, 10, 0, 12, 0, 0 + AI_PLR2_DIFF)
	end
end

function ScrOnTurn()
	local turn = G_SCRIPT_TURN
	local second = G_SCRIPT_SECOND
	
	if everySeconds(3) then
		for k, ai in ipairs(ai_tbl) do
			local static_tbl_ptr = ai_static_info[k]
			local tribe = ai.tribe
			local tribe_diff = ai.diff
			
			--update if shaman inside base
			local shaman_inside_base = ai.shaman_inside_base
			local updated_shaman_inside_base = is_ai_shaman_in_base(tribe, ai.base_marker, ai.base_radius)
			if shaman_inside_base ~= updated_shaman_inside_base then
				ai.shaman_inside_base = updated_shaman_inside_base
				
				--update spell entries
				update_ai_spell_entries(tribe, k, tribe_diff, inside_int)
			end
			
			-- ai attacks
			local atk_timer = ai.attack_timer
			if second >= atk_timer then
				local target = TRIBE_BLUE
				
				-- attack here nigga
				
				ai.attack_timer = second + static_tbl_ptr.base_atk_seconds - 45*tribe_diff + rndb(0, 30) - 20*game_stage
				LOG(ai.tribe .. " is attacking player " .. target)
			end
		end
		
		-- game stage increase
		if game_stage < #game_stage_cutouts then
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












function update_ai_spell_entries(tribe, tribe_idx, tribe_diff, shaman_in_base)
	local curr_entry = 0
	local cost_by_diff = {1.25, 1, 0.75, 0.50}
	local inside_int = shaman_in_base and 0 or 1

	for _, spell_entry in ipairs(ai_static_info[tribe_idx].spell_entries_per_diff[tribe_diff]) do
		if spell_entry.location == shaman_in_base then
			if not spell_entry.req or spell_entry.req() then
				local spell = spell_entry.spell
				local spell_cost = floor(SPELL_COST(spell) * cost_by_diff[tribe_diff])
				ai_set_spell_entry(tribe, curr_entry, spell, spell_cost, UNUSED, type(spell_entry.people) == "function" and spell_entry.people() or spell_entry.people, inside_int)
				curr_entry = curr_entry + 1
			end
		end
	end
end