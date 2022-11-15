-- Includes
include("Globals.lua");

-- Features
enable_feature(F_SUPER_WARRIOR_NO_AMENDMENT); -- fix fws not shooting
enable_feature(F_MINIMAP_ENEMIES); -- who the hell plays with minimap off?
enable_feature(F_WILD_NO_RESPAWN); -- disable wild respawning, oh boy.


function OnSave(sd)
	_OnSave(sd);

	Engine:SaveData(sd);
	Faith:SaveData(sd);
	SaveRiddles(sd);
	SaveEnhanced(sd);
	SaveGlobals(sd);
end

function OnLoad(ld)
	G_GAME_LOADED = true;

	LoadGlobals(ld);
	LoadEnhanced(ld);
	LoadRiddles(ld);
	Faith:LoadData(ld);
	Engine:LoadData(ld);
	
	_OnLoad(ld);
end


function OnTurn()
	if _OnTurn ~= nil then _OnTurn(getTurn()) end
	if enhanced_active then enhanced_OnTurn() end

	-- Post loading logic, executed only once on load.
	if (G_GAME_LOADED) then
		Engine:PostLoadItems();

		G_GAME_LOADED = false;
	end

	-- Has to be ran every turn
	Engine:ProcessExecution();
end


function OnCreateThing(t)
	if _OnCreateThing ~= nil then _OnCreateThing(t) end
	if enhanced_active then enhanced_OnCreateThing(t) end
	if G_LEVEL > 15 then
		Faith:HandleSpellFaithDepletion(t);
	end
end


function OnFrame()
	local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth()
	if _OnFrame ~= nil then _OnFrame(w,h,guiW) end
	-- Faith
	if G_LEVEL > 15 then
		Faith:RenderFaith();
		Faith:DecayGodMode(TRIBE_BLUE);
	end
	if riddle_active then riddlesOnFrame(w,h,guiW) end
	if enhanced_active then enhanced_OnFrame(w,h,guiW) end

	-- Cutscene
	Engine:RenderFrame();
	--Engine:DisplayDebugInfo();



	--[[***mouse helper
	PopSetFont(11)
	local mouseX,mouseY = get_mouse_x(),get_mouse_y()
	local x,xx = mouseX,math.floor((mouseX*100)/ScreenWidth())
	LbDraw_Text(mouseX+24,mouseY,"" .. x .. "  | " .. xx .. " %",0)
	local y,yy = mouseY,math.floor((mouseY*100)/ScreenHeight())
	LbDraw_Text(mouseX+24,mouseY+24,"" .. y .. "  | " .. yy .. " %",0)]]
end

function OnPlayerDeath(pn)
	if _OnPlayerDeath ~= nil then _OnPlayerDeath(pn) end
end

function OnMouseButton(_key, _down, _x, _y)
	if _OnMouseButton ~= nil then _OnMouseButton(_key, _down, _x, _y) end
	if riddle_active then riddlesOnMouseButton() end
	if enhanced_active then enhancedSpellsOnMouseButton(_key, _down, _x, _y) end

	if G_LEVEL > 15 then
		Faith:HandleMouseInput(_key, _down, _x, _y);
	end
end

function OnKeyDown(k)
	if _OnKeyDown ~= nil then _OnKeyDown(k) end
end

function OnKeyUp(k)
	if _OnKeyUp ~= nil then _OnKeyUp(k) end
	if riddle_active then riddle_onkeyup(k) end

	if k == LB_KEY_1 then

	end
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--SHIT TO USE ONCE AT START OF LEVELS--
ResetSpellsSprites()
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


--[[

MECHANICS IN 69 PACK (some might not be added)

- choice system that affect future levels
- factions
- faith system
- enhanced spell system
--------------
- special units ('heros' or important units)
- riddle totem
- quests
- journal featuring events that happened



MECHANICS UNLOCKING LEVELS (these can be ajusted later)

- level 12: unlocks factions system
- level 20: unlocks faith system
- level 28: ability to enhance spells

]]
