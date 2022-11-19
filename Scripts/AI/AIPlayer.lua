CompPlayers = {};

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
      self.Stage = 2;
      return false;
    end

    return true;
  end);
end

AIEvent = {};
AIEvent.__index = AIEvent;

function AIEvent:NewEvent(func, ticks, randomness)
  local self = setmetatable({}, AIEvent);

  self.BaseTicks = ticks;
  self.Randomness = randomness;
  self.Ticks = ticks - G_RANDOM(randomness);
  self.Func = func;

  return self;
end

function AIEvent:Tick()
  self.Ticks = self.Ticks - 1;

  if (self.Ticks <= 0) then
    self.Ticks = self.BaseTicks - (G_RANDOM(self.Randomness));
    return true;
  end

  return false;
end

AIPlayer = {};
AIPlayer.__index = AIPlayer;

function AIPlayer:Init(owner)
  local self = setmetatable({}, AIPlayer);

  self.Owner = owner;
  self.Towers = {};
  self.Events = {};

  return self;
end

function AIPlayer:ProcessEvents()
  for i,Event in pairs(self.Events) do
    if (Event:Tick()) then
      Event.Func(self.Owner);
    end
  end
end

function AIPlayer:RegisterEvent(_name, ticks, randomness, func)
  if (self.Events[_name] == nil) then
    self.Events[_name] = AIEvent:NewEvent(func, ticks, randomness);
  end
end

-- does not destroy actually in-game, just in lua
function AIPlayer:DestroyTower(_name)
  if (self.Towers[_name] ~= nil) then
    self.Towers[_name] = nil;
  end
end

function AIPlayer:TowerIsBuilt(_name)
  if (self.Towers[_name] ~= nil) then
    if (not self.Towers[_name]:isNull()) then
      if (self.Towers[_name].Stage == 2) then
        return true;
      end
    end
  end

  return false;
end

function AIPlayer:CheckTower(_name)
  if (self.Towers[_name] ~= nil) then
    if (self.Towers[_name]:isNull()) then
      if (self.Towers[_name].Stage == 0) then
        self.Towers[_name]:TryCreate();
      elseif (self.Towers[_name].Stage == 1) then
        self.Towers[_name]:TryBind();
      elseif(self.Towers[_name].Stage == 2) then
        self.Towers[_name].Stage = 0; -- rebuild.
      end
    end
  end
end

function AIPlayer:RegisterTower(_name, x, z, orient)
  if (self.Towers[_name] == nil) then
    self.Towers[_name] = AITower:NewTower(self.Owner, x, z, orient);
  end
end

function GetAI(_name)
  return CompPlayers[_name];
end

function Initialize_Special_AI(_name, player_num)
  if (CompPlayers[_name] == nil) then
    CompPlayers[_name] = AIPlayer:Init(player_num);
  end
end

function ProcessSpecialAIs()
  for i,AI in pairs(CompPlayers) do
    AI:ProcessEvents();
  end
end