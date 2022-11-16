-- Includes
include("Globals.lua");

-- Features
enable_feature(F_SUPER_WARRIOR_NO_AMENDMENT); -- fix fws not shooting
enable_feature(F_MINIMAP_ENEMIES); -- who the hell plays with minimap off?
enable_feature(F_WILD_NO_RESPAWN); -- disable wild respawning, oh boy.

-- Local variables (per human)
local L_SHOW_POPS = false;



-- Main hooks

-- OnLevelInit executed only once at start of the game (level start not lobby)
function OnLevelInit(level_id)
	if _OnLevelInit ~= nil then _OnLevelInit(level_id); end
end

-- OnTurn executed every turn (12 turns per second)
function OnTurn()
	if _OnTurn ~= nil then _OnTurn(getTurn()) end
	
	-- STUFF AT START ONCE
	if turn() == 0 then
		-- Ally players at beginning (to ensure they didn't forget in setup) ; unally from AIs
		-- be sure to manually ally any AI's that should have an alliance with eachother
		for i = 0,7 do
			for j = 0,7 do
				if i ~= j then
					if (GetPop(i) > 0) and (GetPop(j) > 0) then
						if isHuman(i) and isHuman(j) then
							set_players_allied(i,j);
							set_players_allied(j,i);
						else
							set_players_enemies(i,j);
							set_players_enemies(j,i);
						end
					end
				end
			end
		end
		-- put players and AIs on their tables
		for i = 0,7 do
			if GetPop(i) > 0 then
				if isHuman(i) then
					table.insert(G_HUMANS,i);
					table.insert(G_HUMANS_ALIVE,i);
				else
					table.insert(G_AI_ALIVE,i);
				end
			end
		end
		-- check if enough humans to play the level
		if G_NUM_OF_HUMANS_FOR_THIS_LEVEL ~= #G_HUMANS_ALIVE then
			LOSE()
			log_msg(8,"The level can not be started. It requires " .. G_NUM_OF_HUMANS_FOR_THIS_LEVEL .. " humans cooperating.")
		end
	end
	--refresh pop table every 3s
	if turn() % 36 == 0 then
		table.sort(G_HUMANS, function(a, b) if GetPop(a) ~= GetPop(b) then return GetPop(a) < GetPop(b) else return a > b end end)
	end
end

-- OnCreateThing executed on each thing creation
function OnCreateThing(t)
	if _OnCreateThing ~= nil then _OnCreateThing(t) end
end

-- OnFrame executed on every draw frame (60 times per second or 60FPS)
function OnFrame()
	local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth()
	if _OnFrame ~= nil then _OnFrame(w,h,guiW) end

	-- tab shows/hides humans info
	for i = 0, #G_HUMANS do
		if _gnsi.PlayerNum == i then
			if L_SHOW_POPS then
				PopSetFont(3);
				local box = 16--math.floor(w/32)
				for k,v in ipairs(G_HUMANS) do
					local clr = 4 if v == 1 then clr = 2 elseif v == 2 then clr = 5 elseif v == 3 then clr = 3 end
					local str = "" .. get_player_name(v,false) .. ": " .. tostring(GetPop(v)) --change to true for online(?)
					LbDraw_Text(w - 4 - (string_width(str)), h - (24*k), str, 0);
					DrawBox(w - 8 - box - (string_width(str)), h - (24*k),box,box,clr)
				end
			end
		end
	end
end

-- OnPlayerDeath executed once upon player's death
function OnPlayerDeath(pn)
	if _OnPlayerDeath ~= nil then _OnPlayerDeath(pn) end
	
	removeFromTable(G_HUMANS_ALIVE,pn);
	removeFromTable(G_AI_ALIVE,pn);
end

-- OnMouseButton executed on each mouse click
function OnMouseButton(_key, _down, _x, _y)
	if _OnMouseButton ~= nil then _OnMouseButton(_key, _down, _x, _y) end
end

-- OnKeyDown executed on keyboard press/hold
function OnKeyDown(k)
	if _OnKeyDown ~= nil then _OnKeyDown(k) end
	if k == LB_KEY_TAB then
		L_SHOW_POPS = not L_SHOW_POPS
	end
end

-- OnKeyDown executed on keyboard release
function OnKeyUp(k)
	if _OnKeyUp ~= nil then _OnKeyUp(k) end

	if k == LB_KEY_1 then

	end
end


--remove after
set_player_name(0,"mrkosjak",false)
set_player_name(1,"map_pepe",false)
set_player_name(2,"nici",false)
set_player_name(3,"leaf",false)
