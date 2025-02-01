include("common.lua");
include("pop_helper.lua");

local turn = 0
set_level_human_count(2);
set_level_computer_count(2);
for i = 139, 140 do add_level_human_start_pos(i) end;
for i = 141, 142 do add_level_computer_start_pos(i) end;




function ScrOnLevelInit(level_id)
  calculate_population_scores();
end



function ScrOnTurn(curr_turn)
	turn = turn + 1
	calculate_population_scores();
end



function ScrOnCreateThing(t_thing)
  
end



function ScrOnFrame(w, h, guiW)
  draw_population_scores();
end



