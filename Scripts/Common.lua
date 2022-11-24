-- Includes
include("Globals.lua");

-- Features
enable_feature(F_SUPER_WARRIOR_NO_AMENDMENT); -- fix fws not shooting
enable_feature(F_MINIMAP_ENEMIES); -- who the hell plays with minimap off?
enable_feature(F_WILD_NO_RESPAWN); -- disable wild respawning, oh boy.

-- Ghost Army
G_SPELL_CONST[M_SPELL_GHOST_ARMY].Active = SPAC_NORMAL;
G_SPELL_CONST[M_SPELL_GHOST_ARMY].NetworkOnly = 0;

-- Local variables (per human)
local L_SHOW_POPS = false;

-- Main hooks

-- OnLevelInit executed only once at start of the game (level start not lobby)
function OnLevelInit(level_id)
	if _OnLevelInit ~= nil then _OnLevelInit(level_id); end

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
			table.insert(G_EVERYONE_IN_GAME,i);
		end
	end
	-- check if enough humans to play the level
	if G_NUM_OF_HUMANS_FOR_THIS_LEVEL ~= #G_HUMANS_ALIVE then
		LOSE()
		log_msg(8,"The level can not be started. It requires " .. G_NUM_OF_HUMANS_FOR_THIS_LEVEL .. " humans cooperating.")
	end
	-- REMOVE LATER
	set_player_name(0,"mrkosjak",false)
	set_player_name(1,"map_pepe",false)
	for i = 2,3 do
		if isHuman(i) then
			local name = "nici" if i == 3 then name = "leaf" end
			set_player_name(i,name,false)
		end
	end
end

-- OnTurn executed every turn (12 turns per second)
function OnTurn()
	if _OnTurn ~= nil then _OnTurn(getTurn()) end
	if _SnowOnTurn ~= nil then _SnowOnTurn() end

	-- ai specials
	CompPlayer:process_ai();

	--refresh pop table every 3s
	if everySeconds(3) then
		table.sort(G_EVERYONE_IN_GAME, function(a, b) if GetPop(a) ~= GetPop(b) then return GetPop(a) < GetPop(b) else return a > b end end) --change to G_HUMANS
	end
end

-- OnCreateThing executed on each thing creation
function OnCreateThing(t)
	if _OnCreateThing ~= nil then _OnCreateThing(t) end

	CompPlayer:process_on_create_ais(t);
end

-- OnFrame executed on every draw frame (60 times per second or 60FPS)
function OnFrame()
	local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth()
	if _OnFrame ~= nil then _OnFrame(w,h,guiW) end

	-- tab shows/hides humans info
	PopSetFont(3);
	local box = 16;
	for i = 0, #G_EVERYONE_IN_GAME do --change to G_HUMANS
		if _gnsi.PlayerNum == i then
			if L_SHOW_POPS then
				for k,v in ipairs(G_EVERYONE_IN_GAME) do --change to G_HUMANS
					local clr = 4 if v == 1 then clr = 12 elseif v == 2 then clr = 5 elseif v == 3 then clr = 3 end
					if v == 4 then clr = 7 elseif v == 5 then clr = 6 elseif v == 6 then clr = 1 elseif v == 7 then clr = 2 end -- remove later
					local str = "" .. get_player_name(v,false) .. ":  " .. tostring(GetPop(v)) --change to true for online(?)
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


	--debuggo
	if k == LB_KEY_0 then
		readSomeGlobals()
	elseif k == LB_KEY_2 then
		for k,v in ipairs(G_AI_ALIVE) do
			ReadAIAttackers(v)
		end
	elseif k == LB_KEY_3 then
		for k,v in ipairs(G_AI_ALIVE) do
			ReadAITroops(v)
		end
	elseif k == LB_KEY_4 then
		for k,v in ipairs(G_AI_ALIVE) do
			ReadAITrainedTroops(v)
		end
	elseif k == LB_KEY_1 then
		for k,v in ipairs(G_AI_ALIVE) do
			log_msg(v, "house percentage: " .. READ_CP_ATTRIB(v,ATTR_HOUSE_PERCENTAGE) .. " | huts amt (total): " .. countHuts(v,true) .. " | huts amt(only healthy): " .. countHuts(v,false))
		end
	elseif k == LB_KEY_5 then
		for k,v in ipairs(G_AI_ALIVE) do
			log_msg(v, "mana: " .. getPlayer(v).Mana)
		end
	end
end
