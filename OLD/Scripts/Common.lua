-- Includes
include("Globals.lua");
include("PSHelpers.lua"); -- PopScript helpers
include("AI\\AIPlayer.lua"); -- AIPlayer class
include("Libs\\LbCommands.lua"); -- Commands class
include("ToolBox.lua"); -- Journal, Quests, Achievements classes

-- Ghost Army
G_SPELL_CONST[M_SPELL_GHOST_ARMY].Active = SPAC_NORMAL;
G_SPELL_CONST[M_SPELL_GHOST_ARMY].NetworkOnly = 0;

-- Constant Adsjutments
G_CONST.ShamenDeadManaPer256Gained = 32; -- lower mana gain from kills

-- Local variables (per human)
local L_SHOW_POPS = true;

-- Main hooks

-- OnLevelInit executed only once at start of the game (level start not lobby)
function OnLevelInit(level_id)
  -- init features only in SP and only at start of level
  if (isOnline() == 0) then
    -- Features
    enable_feature(F_SUPER_WARRIOR_NO_AMENDMENT); -- fix fws not shooting
    enable_feature(F_MINIMAP_ENEMIES); -- who the hell plays with minimap off?
    enable_feature(F_WILD_NO_RESPAWN); -- disable wild respawning, oh boy.
  end
  TJournal:Init();
  TJournal:AddEntry("This is Header", "And this is the text after header");
  TJournal:AddEntry("This is Header", "And this is the text after header");
  TJournal:AddEntry("This is Header", "And this is the text after header");
  TJournal:Separator();
  TJournal:AddEntry("Separated", "And this is the text after header");
  TJournal:AddEntry("Separated", "And this is the text after header");
  TJournal:AddEntry("Separated", "And this is the text after header");
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
		--LOSE()
		log_msg(8,"The level can not be started. It requires " .. G_NUM_OF_HUMANS_FOR_THIS_LEVEL .. " humans cooperating.")
	end
	-- REMOVE LATER
  if (isOnline() == 0) then
	  set_player_name(0,"mrkosjak", false)
	  set_player_name(1,"map_pepe", false)
    set_player_name(2,"nici", false);
    
    set_player_name(4,"Tiyao", false)
    set_player_name(5,"Toktai", false)
    set_player_name(6,"Sahel",false)
    set_player_name(7,"Nomel",false)
  else
    set_player_name(4,"Tiyao", true)
    set_player_name(5,"Toktai", true)
    set_player_name(6,"Sahel",true)
    set_player_name(7,"Nomel",true)
  end
  
	-- AI custom names
	for i = 2,3 do
		if not isHuman(i) then
			if i == 2 then
				set_player_name(i,"Chumara",ntb(isOnline()))
			else
				set_player_name(i,"Matak",ntb(isOnline()))
			end
		end
	end
	
	if _OnPostLevelInit ~= nil then _OnPostLevelInit(level_id); end
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
	if (t.Flags3 & TF3_LOCAL ~= 0) then
	  return;
	end
	
	if _OnCreateThing ~= nil then _OnCreateThing(t) end

	CompPlayer:process_on_create_ais(t);
end

-- OnFrame executed on every draw frame (60 times per second or 60FPS)
function OnFrame()
	local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth()
	if _OnFrame ~= nil then _OnFrame(w,h,guiW) end
	if _FooterMsgOnFrame ~= nil then _FooterMsgOnFrame(w,h,guiW) end

	-- tab shows/hides humans info
	PopSetFont(3);
	local box = 16;
	for i = 0, #G_EVERYONE_IN_GAME do --change to G_HUMANS
		if _gnsi.PlayerNum == i then
			if L_SHOW_POPS then
				for k,v in ipairs(G_EVERYONE_IN_GAME) do --change to G_HUMANS
					local clr = 4 if v == 1 then clr = 12 elseif v == 2 then clr = 5 elseif v == 3 then clr = 3 end
					if v == 4 then clr = 7 elseif v == 5 then clr = 6 elseif v == 6 then clr = 1 elseif v == 7 then clr = 2 end -- remove later
					local str = "" .. get_player_name(v,ntb(isOnline())) .. ":  " .. tostring(GetPop(v))
					LbDraw_Text(w - 4 - (string_width(str)), h - (24*k), str, 0);
					DrawBox(w - 8 - box - (string_width(str)), h - (24*k),box,box,clr)
				end
			end
		end
	end
  
  TJournal:Draw();
end

-- OnPlayerDeath executed once upon player's death
function OnPlayerDeath(pn)
	if _OnPlayerDeath ~= nil then _OnPlayerDeath(pn) end

	removeFromTable(G_HUMANS_ALIVE,pn);
	removeFromTable(G_AI_ALIVE,pn);
end

-- OnKeyDown executed on keyboard press/hold
function OnKeyDown(k)
	if _OnKeyDown ~= nil then _OnKeyDown(k) end
	if k == LB_KEY_TAB then
		L_SHOW_POPS = not L_SHOW_POPS
	end
end

local PACKET_KEYS_DEBUG = 1;

-- OnKeyDown executed on keyboard release
function OnKeyUp(k)
	if _OnKeyUp ~= nil then _OnKeyUp(k) end


	--debuggo
  if (am_i_in_network_game() == 0) then
    if k == LB_KEY_0 then
      readSomeGlobals()
	  elseif k == LB_KEY_1 then
      for k,v in ipairs(G_AI_ALIVE) do
        log_msg(v, "house percentage: " .. READ_CP_ATTRIB(v,ATTR_HOUSE_PERCENTAGE) .. " | huts amt (total): " .. countHuts(v,true) .. " | huts amt(only healthy): " .. countHuts(v,false))
      end
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
    elseif k == LB_KEY_5 then
      for k,v in ipairs(G_AI_ALIVE) do
        log_msg(v, "mana: " .. getPlayer(v).Mana)
      end
    elseif k == LB_KEY_J then
      TJournal:Toggle();
    end
  else
    if k == LB_KEY_0 then
      Send(PACKET_KEYS_DEBUG, tostring(k));
	  elseif k == LB_KEY_1 then
      Send(PACKET_KEYS_DEBUG, tostring(k));
    elseif k == LB_KEY_2 then
      Send(PACKET_KEYS_DEBUG, tostring(k));
    elseif k == LB_KEY_3 then
      Send(PACKET_KEYS_DEBUG, tostring(k));
    elseif k == LB_KEY_4 then
      Send(PACKET_KEYS_DEBUG, tostring(k));
    elseif k == LB_KEY_5 then
      Send(PACKET_KEYS_DEBUG, tostring(k));
    end
  end
end


function OnPacket(player_num, packet_type, data)
  if (am_i_in_network_game() ~= 0) then
    if _OnPacket ~= nil then _OnPacket(player_num, packet_type, data); end

    if (packet_type == PACKET_KEYS_DEBUG) then
      local key_num = tonumber(data);
      if (key_num == LB_KEY_0) then
        readSomeGlobals();
      elseif (key_num == LB_KEY_1) then
        for k,v in ipairs(G_AI_ALIVE) do
          log_msg(v, "house percentage: " .. READ_CP_ATTRIB(v,ATTR_HOUSE_PERCENTAGE) .. " | huts amt (total): " .. countHuts(v,true) .. " | huts amt(only healthy): " .. countHuts(v,false));
        end
      elseif (key_num == LB_KEY_2) then
        for k,v in ipairs(G_AI_ALIVE) do
          ReadAIAttackers(v);
        end
      elseif (key_num == LB_KEY_3) then
        for k,v in ipairs(G_AI_ALIVE) do
          ReadAITroops(v);
        end
      elseif (key_num == LB_KEY_4) then
        for k,v in ipairs(G_AI_ALIVE) do
          ReadAITrainedTroops(v);
        end
      elseif (key_num == LB_KEY_5) then
        for k,v in ipairs(G_AI_ALIVE) do
          log_msg(v, "mana: " .. getPlayer(v).Mana);
        end
      end
    end
  end
end
