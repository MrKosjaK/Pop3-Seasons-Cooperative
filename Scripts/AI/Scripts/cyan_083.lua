local convert_markers =
{
  10, 11, 12, 13, 14
};

CompPlayer:init(TRIBE_CYAN);
local ai = CompPlayer(TRIBE_CYAN);

-- shaman ai options
ai:toggle_shaman_ai(true); -- enable it first u dummy

local sham = ai:get_shaman_ai(); -- get pointer to it as local, so it's fasto
sham:toggle_spell_check(true); -- spell entries
sham:toggle_fall_damage_save(true, 50);
sham:toggle_land_bridge_save(true, 25);
sham:toggle_lightning_dodge(true, 90);
sham:toggle_spell_check(true);
sham:set_spell_entry(1, M_SPELL_WHIRLWIND, {M_BUILDING_DRUM_TOWER, 1, 2, 3}, 3, 50000);

-- towers
ai:create_tower(1, 124, 104, -1);
ai:create_tower(2, 146, 106, -1);
ai:create_tower(3, 124, 96, -1);
ai:create_tower(4, 130, 76, -1);
ai:create_tower(5, 148, 78, -1);
ai:create_tower(6, 138, 78, -1);

local function cyan_attacking(player)
  -- depends on what we want with attacking, let's actually make it patterned for now
end

local function cyan_towers(player)
  -- for building towers we want to have at least 1 fw and some population
end

local function cyan_convert(player)
  -- check if we have a low pop count
  if (AI_GetPopCount(player) < 35 and AI_ShamanFree(player)) then
    -- enable converting and convert at random markers
    STATE_SET(player, 1, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
    WRITE_CP_ATTRIB(player, ATTR_EXPANSION, 36);
	sham:toggle_converting(true);

    local mk = convert_markers[G_RANDOM(#convert_markers) + 1];
    AI_ConvertAt(player, mk);
  else
    -- disable converting
    STATE_SET(player, 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
	sham:toggle_converting(false);
  end
end

local function cyan_build(player)
  -- we want fw hut built as soon as possible.
  AI_SetVar(player, 2, 0); -- fw building.
  AI_SetVar(player, 3, 0); -- war building
  AI_SetVar(player, 4, 0); -- bigger troops counts.
  local fw_trains = AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN);
  local temples = AI_GetBldgCount(player, M_BUILDING_TEMPLE);
  local huts = AI_GetHutsCount(player);
  
  if (fw_trains > 0 or temples > 0) then
    WRITE_CP_ATTRIB(player, ATTR_MAX_TRAIN_AT_ONCE, 3);
    STATE_SET(player, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
  end
  
  if (huts < 8) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 45);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 6);
	AI_SetVar(player, 2, 1);
  elseif (huts < 15) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 90);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 3);
	AI_SetVar(player, 2, 1);
	AI_SetVar(player, 3, 1);
	if (AI_GetVar(player, 1) == 0) then
      AI_SetVar(player, 1, 1);
      AI_SetMainDrumTower(player, true, 138, 128);
    end
  elseif (huts < 21) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 121);
	WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 1);
	AI_SetVar(player, 2, 1);
	AI_SetVar(player, 3, 1);
	AI_SetVar(player, 4, 1);
  end
  
  if (AI_GetVar(player, 2) == 1) then
    if (fw_trains == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 12);
	end
  end
  
  if (AI_GetVar(player, 3) == 1) then
    if (temples == 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_TRAINS, 1);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 0);
	else
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 12);
	end
  end
  
  if (AI_GetVar(player, 4) == 1) then
    if (fw_trains > 0 and temples > 0) then
	  WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 18);
	  WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 20);
	end
  end
end

-- events
ai:create_event(1, 256, 64, cyan_build);
ai:create_event(2, 128, 24, cyan_convert);
ai:create_event(3, 128, 32, cyan_towers);
ai:create_event(4, 740, 112, function(player) end);
ai:create_event(5, 1536, 256, cyan_attacking);
