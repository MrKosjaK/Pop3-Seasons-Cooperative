local area_info_mt = {};
local wood_area_info = {};
area_info_mt.__index = area_info_mt;
wood_area_info.__index = wood_area_info;

function area_info_mt:is_empty()
  return (self.isEmpty);
end

function area_info_mt:contains_people()
  return (self.hasPeople);
end

function area_info_mt:contains_buildings()
  return (self.hasBuildings);
end

function area_info_mt:get_person_count(model)
  return (self[1][model]);
end

function area_info_mt:get_building_count(model)
  return (self[2][model]);
end

function wood_area_info:is_empty()
  return (self.isEmpty);
end

function wood_area_info:contains_trees()
  return (self.hasTrees);
end

function wood_area_info:contains_wood_piles()
  return (self.hasWoodPiles);
end

function CreateWoodAreaInfo()
  local t =
  {
    [1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	hasTrees = false,
	hasWoodPiles = false,
	isEmpty = true
  };
  setmetatable(t, wood_area_info);
  return t;
end

function CreateAreaInfo()
  local t =
  {
    [1] =
	{
	  [1] = 0,
	  [2] = 0,
	  [3] = 0,
	  [4] = 0,
	  [5] = 0,
	  [6] = 0,
	  [7] = 0,
	  [8] = 0
	},
	[2] =
	{
	  [1] = 0,
	  [2] = 0,
	  [3] = 0,
	  [4] = 0,
	  [5] = 0,
	  [6] = 0,
	  [7] = 0,
	  [8] = 0
	},
	isEmpty = true,
	hasPeople = false,
	hasBuildings = false
  };
  setmetatable(t, area_info_mt);
  return t;
end

local c_mposxz = MapPosXZ.new();

function GetWoodAreaInfo(x, z, r, tabl)
  if (tabl == nil or type(tabl) ~= "table") then
    return;
  end
  
  for k = 1, 7 do
    tabl[k] = 0;
  end
  
  tabl.isEmpty = true;
  tabl.hasTrees = false;
  tabl.hasWoodPiles = false;
  
  c_mposxz.XZ.X = x;
  c_mposxz.XZ.Z = z;
  
  SearchMapCells(SQUARE, 0, 0, r, c_mposxz.Pos, function(me)
    me.MapWhoList:processList(function(t)
      if (t.Owner ~= TRIBE_HOSTBOT) then
        return true;
      end

      if (t.Type == 5) then
	    if (t.Model <= 6) then
          tabl[t.Model] = tabl[t.Model] + 1;
		  tabl.isEmpty = false;
		  tabl.hasTrees = true;
		  return true;
		end
		
		if (t.Model == M_SCENERY_WOOD_PILE) then
		  tabl[7] = tabl[7] + 1;
		  tabl.isEmpty = false;
		  tabl.hasWoodPiles = true;
		  return true;
		end
        return true;
      end
      return true;
    end);
    return true;
  end);
end

function GetPlayerAreaInfo(player, x, z, r, tabl)
  if (tabl == nil or type(tabl) ~= "table") then
    return;
  end
  
  for k = 1, #tabl[1] do
    tabl[1][k] = 0;
  end
  
  for l = 1, #tabl[2] do
    tabl[2][l] = 0;
  end
  
  tabl.isEmpty = true;
  tabl.hasPeople = false;
  tabl.hasBuildings = false;
  
  c_mposxz.XZ.X = x;
  c_mposxz.XZ.Z = z;

  SearchMapCells(SQUARE, 0, 0, r, c_mposxz.Pos, function(me)
    me.MapWhoList:processList(function(t)
      if (t.Owner ~= player) then
        return true;
      end

      if (t.Type == 1) then
	    if (t.Flags & TF2_PERSON_NOT_SELECTABLE ~= 0) then
	      return true;
	    end
        tabl[1][t.Model] = tabl[1][t.Model] + 1;
		tabl.isEmpty = false;
		tabl.hasPeople = true;
        return true;
      end

      if (t.Type == 2) then
        tabl[2][t.Model] = tabl[2][t.Model] + 1;
		tabl.isEmpty = false;
		tabl.hasBuildings = true;
        return true;
      end
      return true;
    end);
    return true;
  end);
end

function GetAllyAreaInfo(player, x, z, r, tabl)
  if (tabl == nil or type(tabl) ~= "table") then
    return;
  end

  for k = 1, #tabl[1] do
    tabl[1][k] = 0;
  end
  
  for l = 1, #tabl[2] do
    tabl[2][l] = 0;
  end
  
  tabl.isEmpty = true;
  tabl.hasPeople = false;
  tabl.hasBuildings = false;
  
  c_mposxz.XZ.X = x;
  c_mposxz.XZ.Z = z;

  SearchMapCells(SQUARE, 0, 0, r, c_mposxz.Pos, function(me)
    me.MapWhoList:processList(function(t)
      if (are_players_allied(player, t.Owner) == 0) then
        return true;
      end

      if (t.Type == 1) then
        tabl[1][t.Model] = tabl[1][t.Model] + 1;
		tabl.isEmpty = false;
		tabl.hasPeople = true;
        return true;
      end

      if (t.Type == 2) then
        tabl[2][t.Model] = tabl[2][t.Model] + 1;
		tabl.isEmpty = false;
		tabl.hasBuildings = true;
        return true;
      end
      return true;
    end);
    return true;
  end);
end

function GetEnemyAreaInfo(player, x, z, r, tabl)
  if (tabl == nil or type(tabl) ~= "table") then
    return;
  end

  for k = 1, #tabl[1] do
    tabl[1][k] = 0;
  end
  
  for l = 1, #tabl[2] do
    tabl[2][l] = 0;
  end
  
  tabl.isEmpty = true;
  tabl.hasPeople = false;
  tabl.hasBuildings = false;
  
  c_mposxz.XZ.X = x;
  c_mposxz.XZ.Z = z;

  SearchMapCells(SQUARE, 0, 0, r, c_mposxz.Pos, function(me)
    me.MapWhoList:processList(function(t)
      if (are_players_allied(player, t.Owner) == 1) then
        return true;
      end

      if (t.Type == 1) then
	    if (t.Flags & TF2_PERSON_NOT_SELECTABLE ~= 0) then
	      return true;
	    end
        tabl[1][t.Model] = tabl[1][t.Model] + 1;
		tabl.isEmpty = false;
		tabl.hasPeople = true;
        return true;
      end

      if (t.Type == 2) then
        tabl[2][t.Model] = tabl[2][t.Model] + 1;
		tabl.isEmpty = false;
		tabl.hasBuildings = true;
        return true;
      end
      return true;
    end);
    return true;
  end);
end
