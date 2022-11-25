local convert_markers =
{
  31, 32, 33, 34, 35, 36, 37
};

CompPlayer:init(TRIBE_GREEN);
local ai = CompPlayer(TRIBE_GREEN);

ai:toggle_shaman_ai(true);
local sham = ai:get_shaman_ai();
sham:toggle_fall_damage_save(true, 50);
sham:toggle_land_bridge_save(true, 25);
sham:toggle_lightning_dodge(true, 90);
sham:toggle_spell_check(true);

local function green_build(player)
  AI_SetVar(player, 2, 0);
  local huts = AI_GetHutsCount(player);
  local war_train = AI_GetBldgCount(player, M_BUILDING_WARRIOR_TRAIN);
  local fw_train = AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN);
  
  if (war_train > 0 or fw_train > 0) then
    WRITE_CP_ATTRIB(player, ATTR_MAX_TRAIN_AT_ONCE, 3);
    STATE_SET(player, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
  end
  
  if (huts < 5) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 24);
    WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 4);
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 0);
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 0);
    WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_TRAINS, 0);
    WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 0);
  end
  
  if (huts >= 5 and war_train == 0) then
    -- build warrior hut firsto.
	WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_TRAINS, 1);
	WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 30);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 2);
  end
  
  if (huts >= 6 and war_train > 0) then
    WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 12);
	WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 60);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 3);
	if (AI_GetVar(player, 1) == 0) then
      AI_SetVar(player, 1, 1);
      AI_SetMainDrumTower(player, true, 62, 142);
    end
  end
  
  if (huts >= 8 and fw_train == 0) then
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
	WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 70);
  end
  
  if (huts >= 8 and fw_train > 0) then
    AI_SetVar(player, 2, 1); -- fws!!!!
    WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 1);
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 90);
	WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 12);
	WRITE_CP_ATTRIB(player, ATTR_PREF_WARRIOR_PEOPLE, 16);
  end
end

local function green_towers(player)
end

local function green_convert(player)
  if (AI_GetVar(player, 3) == 0) then
	local turn = getTurn();
	  
	if (turn < 720) then
      sham:toggle_converting(true);
	  SHAMAN_DEFEND(player, 58, 80, TRUE);
	else
      AI_SetVar(player, 3, 1);
	  SHAMAN_DEFEND(player, 54, 126, TRUE);
      sham:toggle_converting(false);
    end
  end
end

ai:create_event(1, 128, 32, green_convert);
ai:create_event(2, 256, 96, green_build);
ai:create_event(3, 340, 150, green_towers);