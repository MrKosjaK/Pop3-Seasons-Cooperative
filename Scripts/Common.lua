-- Includes
include("Globals.lua");

-- Features
enable_feature(F_SUPER_WARRIOR_NO_AMENDMENT); -- fix fws not shooting
enable_feature(F_MINIMAP_ENEMIES); -- who the hell plays with minimap off?
enable_feature(F_WILD_NO_RESPAWN); -- disable wild respawning, oh boy.

-- Main hooks

-- OnLevelInit executed only once at start of the game (level start not lobby)
function OnLevelInit(level_id)
	if _OnLevelInit ~= nil then _OnLevelInit(level_id); end
end

-- OnTurn executed every turn (12 turns per second)
function OnTurn()
	if _OnTurn ~= nil then _OnTurn(getTurn()) end
end

-- OnCreateThing executed on each thing creation
function OnCreateThing(t)
	if _OnCreateThing ~= nil then _OnCreateThing(t) end
end

-- OnFrame executed on every draw frame (60 times per second or 60FPS)
function OnFrame()
	local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth()
	if _OnFrame ~= nil then _OnFrame(w,h,guiW) end

	--[[***mouse helper
	PopSetFont(11)
	local mouseX,mouseY = get_mouse_x(),get_mouse_y()
	local x,xx = mouseX,math.floor((mouseX*100)/ScreenWidth())
	LbDraw_Text(mouseX+24,mouseY,"" .. x .. "  | " .. xx .. " %",0)
	local y,yy = mouseY,math.floor((mouseY*100)/ScreenHeight())
	LbDraw_Text(mouseX+24,mouseY+24,"" .. y .. "  | " .. yy .. " %",0)]]
end

-- OnPlayerDeath executed once upon player's death
function OnPlayerDeath(pn)
	if _OnPlayerDeath ~= nil then _OnPlayerDeath(pn) end
end

-- OnMouseButton executed on each mouse click
function OnMouseButton(_key, _down, _x, _y)
	if _OnMouseButton ~= nil then _OnMouseButton(_key, _down, _x, _y) end
end

-- OnKeyDown executed on keyboard press/hold
function OnKeyDown(k)
	if _OnKeyDown ~= nil then _OnKeyDown(k) end
end

-- OnKeyDown executed on keyboard release
function OnKeyUp(k)
	if _OnKeyUp ~= nil then _OnKeyUp(k) end

	if k == LB_KEY_1 then

	end
end
