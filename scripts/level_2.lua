include("common.lua");
include("pop_helper.lua");
include("snow.lua");

local turn = 0
set_level_human_count(2);
set_level_computer_count(2);
add_human_player_start_info(139, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_human_player_start_info(140, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_ai_player_start_info(141, 4, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});
add_ai_player_start_info(142, 6, {M_SPELL_BLAST, M_SPELL_CONVERT_WILD, M_SPELL_INSECT_PLAGUE}, {M_BUILDING_TEPEE, M_BUILDING_DRUM_TOWER});




function ScrOnLevelInit(level_id)
  calculate_population_scores();
end



function ScrOnTurn(curr_turn)
	turn = turn + 1
	calculate_population_scores();
	process_snow(curr_turn)
	
	if curr_turn == 60 then
		LOG("snow")
		start_snowing(2000, 200, 64, 60*10) -- amount, ~per_second_spawn, speed, duration_seconds
	end
end



function ScrOnCreateThing(t_thing)

end



function ScrOnFrame(w, h, guiW)
  draw_population_scores();
end



