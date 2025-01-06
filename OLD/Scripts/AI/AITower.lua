AITowers = {}; -- buffer for towers

AITower = {};
AITower.__index = AITower;

function AITower:NewTower(owner, x, z, orient)
  local self = setmetatable({}, AITower);

  self.Owner = owner;
  self.X = x;
  self.Z = z;
  self.Orient = orient or -1;
  self.Obj = ObjectProxy.new();
  self.Stage = 0;

  return self;
end

function AITower:isNull()
  return self.Obj:isNull();
end

function AITower:TryCreate()
  -- will attempt to place a tower shape at given pos, then link its idx
  local map_idx = map_xz_to_map_idx(self.X, self.Z);
  local orient = 0;
  if (self.Orient == -1) then
    orient = G_RANDOM(4);
  else
    orient = self.Orient;
  end

  if (is_map_cell_bldg_markable(getPlayer(self.Owner), map_idx, 0, M_BUILDING_DRUM_TOWER, 0, 0) ~= 0) then
    -- place tower plan.
    process_shape_map_elements(map_idx, M_BUILDING_DRUM_TOWER, orient, self.Owner, SHME_MODE_SET_PERM);

    -- bind thingidx
    local me = MAP_ELEM_IDX_2_PTR(map_idx);
    self.Obj:set(me.ShapeOrBldgIdx:getThingNum());
    self.Stage = 1;
  end
end

function AITower:TryBind()
  local map_idx = map_xz_to_map_idx(self.X, self.Z);
  local me = MAP_ELEM_IDX_2_PTR(map_idx);

  me.MapWhoList:processList(function(t)
    if (t.Type == T_BUILDING and t.Model == M_BUILDING_DRUM_TOWER and t.Owner == self.Owner) then
      self.Obj:set(t.ThingNum);
      self.Stage = 0;
      return false;
    end

    return true;
  end);
end

function CreateTower(_name, owner, x, z, orient)
  if (AITowers[_name] == nil) then
    AITowers[_name] = AITower:NewTower(owner, x, z, orient);
  end
end

function CheckTower(_name)
  if (AITowers[_name] ~= nil) then
    if (AITowers[_name]:isNull()) then
      if (AITowers[_name].Stage == 0) then
        AITowers[_name]:TryCreate();
      elseif (AITowers[_name].Stage == 1) then
        AITowers[_name]:TryBind();
      end
    end
  end
end
