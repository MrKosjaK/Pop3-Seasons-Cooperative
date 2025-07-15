local _MAP_POS_XZ = MapPosXZ.new();
local search_enemy_area_mt = {};

search_enemy_area_mt.__index =
{
  clear = function(self)
    self.hasBuildings = false;
    self.hasEnemy = false;
    self.hasPeople = false;
    self.NumPeople = 0;
    self.NumBuildings = 0;
    
    for i,v in ipairs(self.People) do
      self.People[i] = 0;
    end
    
    for i,v in ipairs(self.Buildings) do
      self.Buildings[i] = 0;
    end
  end,
  
  has_enemy = function(self)
    return (self.hasEnemy);
  end,
  
  get_people_count = function(self)
    return (self.NumPeople);
  end,
  
  scan = function(self, owner, x, z, radius)
    _MAP_POS_XZ.XZ.X = x;
    _MAP_POS_XZ.XZ.Z = z;
    
    SearchMapCells(SQUARE, 0, 0, radius, _MAP_POS_XZ.Pos, function(me)
      if (not me.MapWhoList:isEmpty()) then
        me.MapWhoList:processList(function(t)
          if (are_players_allied(t.Owner, owner) == 0) then
            if (t.Type == T_BUILDING) then
              self.Buildings[t.Model] = self.Buildings[t.Model] + 1;
              self.NumBuildings = self.NumBuildings + 1;
              self.hasEnemy = true;
              self.hasBuildings = true;
              return true;
            end
            
            if (t.Type == T_PERSON) then
              self.People[t.Model] = self.People[t.Model] + 1;
              self.NumPeople = self.NumPeople + 1;
              self.hasEnemy = true;
              self.hasPeople = true;
              return true;
            end
          end
          
          return true;
        end);
      end
      
      return true;
    end);
  end
};

function create_enemy_search_area()
  local area =
  {
    Buildings = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    People = {0, 0, 0, 0, 0, 0, 0, 0},
    hasEnemy = false,
    hasPeople = false,
    hasBuildings = false,
    NumPeople = 0,
    NumBuildings = 0,
  };
  
  setmetatable(area, search_enemy_area_mt);
  
  return area;
end

function is_shape_or_bldg_at_xz(_owner, _model, _x, _z, _radius)
  local result = false;
  _MAP_POS_XZ.XZ.X = _x;
  _MAP_POS_XZ.XZ.Z = _z;
  local t = nil;
  
  SearchMapCells(SQUARE, 0, 0, _radius, _MAP_POS_XZ.Pos, function(me)
      if (not me.ShapeOrBldgIdx:isNull()) then
        t = me.ShapeOrBldgIdx:get();
        
        if (t.Owner == _owner) then
          if (t.Type == T_BUILDING) then
            if (t.Model == _model) then
              result = true;
              return false;
            end
          end
          
          if (t.Type == T_SHAPE) then
            if (t.u.Shape.BldgModel == _model) then
              result = true;
              return false;
            end
          end
        end
      end
      
      return true;
    end);
  
  return result;
end