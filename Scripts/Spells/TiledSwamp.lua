SwampTiles = {}; -- buffer for tiles

SwampTile = {};
SwampTile.__index = SwampTile;

SwampTileSize = 2;
SwampTileDuration = 240;
SwampTileRandomness = 60;
SwampTileEnabled = false;

function SwampTile:NewTile(owner, c3d, duration)
  local self = setmetatable({}, SwampTile);

  self.Duration = duration;
  self.Owner = owner;
  self.Coord = c3d;
  self.MapWho = world_coord3d_to_map_ptr(c3d).MapWhoList;
  self.MistThingIdx = createThing(T_EFFECT, M_EFFECT_SWAMP_MIST, owner, self.Coord, false, false);
  self.GrassThingIdx = createThing(T_EFFECT, M_EFFECT_REEDY_GRASS, owner, self.Coord, false, false);
  self.Finished = false;

  return self;
end

function SwampTile:Process()
  self.Duration = self.Duration - 1;

  if (self.Duration <= 0 or self.Finished == true) then
    if (self.MistThingIdx ~= nil) then delete_thing_type(self.MistThingIdx); end
    if (self.GrassThingIdx ~= nil) then delete_thing_type(self.GrassThingIdx); end
    self.Finished = true;
    return self.Finished;
  end

  self.MapWho:processList(function(t)
    if (t.Type == T_PERSON) then
      if (t.Model > 1 and t.Model < 8) then
        if (are_players_allied(t.Owner, self.Owner) == 0) then
          if (is_thing_on_ground(t) == 1 and is_person_in_airship(t) == 0 and is_person_on_a_building(t) == 0) then
            set_person_new_state(t, S_PERSON_DYING);
            self.Finished = true;
            return false;
          end
        end
      end
    end
    return true;
  end);

  return false;
end

function CreateSwamp(owner, c3d, size)
  local m1 = MapPosXZ.new();
  m1.Pos = world_coord3d_to_map_idx(c3d);
  m1.XZ.X = m1.XZ.X-size+1;
  m1.XZ.Z = m1.XZ.Z-size+1;
  local x = 0;
  local z = 0;
  for i = 0, size do
    x = m1.XZ.X + i * 2;
    for j = 0, size do
      z = m1.XZ.Z + j * 2;
      local coord = MAP_XZ_2_WORLD_XYZ(x, z);
      centre_coord3d_on_block(coord);
      local me = world_coord3d_to_map_ptr(coord);
      if (is_map_elem_all_land(me) == 1) then
        table.insert(SwampTiles, SwampTile:NewTile(owner, coord, SwampTileDuration + G_RANDOM(SwampTileRandomness)));
      end
    end
  end
end

function ProcessSwampCreate(t)
  if (SwampTileEnabled) then
    if (t.Type == T_EFFECT) then
      if (t.Model == M_EFFECT_SWAMP) then
        CreateSwamp(t.Owner, t.Pos.D3, SwampTileSize);
        delete_thing_type(t);
      end
    end
  end
end

function ProcessTiledSwamps()
  if (SwampTileEnabled) then
    for i,Swamp in ipairs(SwampTiles) do
      if (Swamp:Process()) then
        table.remove(SwampTiles, i);
      end
    end
  end
end
