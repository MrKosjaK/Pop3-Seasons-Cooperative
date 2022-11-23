CompPlayer =
{
  Data =
  {
    [0] = nil,
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
    [7] = nil
  }
};

local cp_mt = {}
local pl_mt = {}
pl_mt.__index = pl_mt;

setmetatable(CompPlayer,
{
  __call = function(t, key)
    LOG(string.format("Accessing %i player data", key));
    return t.Data[key];
  end,
  __index = cp_mt
});

-- preallocate 12 towers & 8 events.
function cp_mt:init(player_num)
  if (self.Data[player_num] == nil) then
    local tribe_info =
    {
      Owner = player_num,
      Towers = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil},
      Events = {nil, nil, nil, nil, nil, nil, nil, nil},
      Shaman = nil
    };
    setmetatable(tribe_info, pl_mt);
    self.Data[player_num] = tribe_info;
    LOG(string.format("Player %i initialized", player_num));
  end
end

function cp_mt:process_ai()
  for i = 0, #self.Data do
    local ai = self.Data[i];
    if (ai ~= nil) then
      ai:process();
    end
  end
end

function pl_mt:process()
  -- events processing
  for i = 1, #self.Events do
    local ev = self.Events[i];
    if (ev ~= nil) then

    end
  end
end
-- AITower = {};
-- AITower.__index = AITower;
--
-- function AITower:NewTower(owner, x, z, orient)
--   local self = setmetatable({}, AITower);
--
--   self.Owner = owner;
--   self.X = x;
--   self.Z = z;
--   self.Orient = orient or -1;
--   self.Obj = ObjectProxy.new();
--   self.Stage = 0;
--
--   return self;
-- end
--
-- function AITower:isNull()
--   return self.Obj:isNull();
-- end
--
-- function AITower:TryCreate()
--   -- will attempt to place a tower shape at given pos, then link its idx
--   local map_idx = map_xz_to_map_idx(self.X, self.Z);
--   local orient = 0;
--   if (self.Orient == -1) then
--     orient = G_RANDOM(4);
--   else
--     orient = self.Orient;
--   end
--
--   if (is_map_cell_bldg_markable(getPlayer(self.Owner), map_idx, 0, M_BUILDING_DRUM_TOWER, 0, 0) ~= 0) then
--     -- place tower plan.
--     process_shape_map_elements(map_idx, M_BUILDING_DRUM_TOWER, orient, self.Owner, SHME_MODE_SET_PERM);
--
--     -- bind thingidx
--     local me = MAP_ELEM_IDX_2_PTR(map_idx);
--     self.Obj:set(me.ShapeOrBldgIdx:getThingNum());
--     self.Stage = 1;
--   end
-- end
--
-- function AITower:TryBind()
--   local map_idx = map_xz_to_map_idx(self.X, self.Z);
--   local me = MAP_ELEM_IDX_2_PTR(map_idx);
--
--   me.MapWhoList:processList(function(t)
--     if (t.Type == T_BUILDING and t.Model == M_BUILDING_DRUM_TOWER and t.Owner == self.Owner) then
--       self.Obj:set(t.ThingNum);
--       self.Stage = 2;
--       return false;
--     end
--
--     return true;
--   end);
-- end
--
-- AIEvent = {};
-- AIEvent.__index = AIEvent;
--
-- function AIEvent:NewEvent(func, ticks, randomness)
--   local self = setmetatable({}, AIEvent);
--
--   self.BaseTicks = ticks;
--   self.Randomness = randomness;
--   self.Ticks = ticks - G_RANDOM(randomness);
--   self.Func = func;
--
--   return self;
-- end
--
-- function AIEvent:Tick()
--   self.Ticks = self.Ticks - 1;
--
--   if (self.Ticks <= 0) then
--     self.Ticks = self.BaseTicks - (G_RANDOM(self.Randomness));
--     return true;
--   end
--
--   return false;
-- end
--
-- AIPlayer = {};
-- AIPlayer.__index = AIPlayer;
--
-- function AIPlayer:Init(owner)
--   local self = setmetatable({}, AIPlayer);
--
--   self.Owner = owner;
--   self.Towers = {};
--   self.Events = {};
--   self.Shaman = nil;
--
--   return self;
-- end
--
-- AISpellEntry = {};
-- AISpellEntry.__index = AISpellEntry;
--
-- function AISpellEntry:NewEntry(spell, target_type, target_models, cost)
--   local self = setmetatable({}, AISpellEntry);
--
--   self.Spell = spell;
--   self.TargetType = target_type;
--   self.TargetModels = {table.unpack(target_models)};
--   self.Cost = cost;
--
--   return self;
-- end
--
-- AIShaman = {};
-- AIShaman.__index = AIShaman;
--
-- function AIShaman:NewShaman(pn)
--   local self = setmetatable({}, AIShaman);
--
--   self.Owner = pn;
--   self.Proxy = ObjectProxy.new();
--   self.LandBridgeSave = false;
--   self.FallDamageSave = false;
--   self.CustomSpellEntries = false;
--   self.LightningDodge = false;
--   self.RetaliateWithSpell = M_SPELL_NONE;
--   self.RetaliateWait = 0;
--   self.FallDamageChance = 100;
--   self.LightningDodgeChance = 100;
--   self.LandBridgeChance = 100;
--   self.MaxRad = 0;
--   self.CurrRad = 0;
--   self.OffsetRad = 0;
--   self.SpellEntries = {};
--
--   return self;
-- end
--
-- function AIShaman:Process()
--   if (self.Proxy:isNull()) then
--     -- try getting shaman back
--     if (getShaman(self.Owner) ~= nil) then
--       self.Proxy:set(getShaman(self.Owner).ThingNum);
--     end
--   else
--     local s = self.Proxy:get();
--
--     if (s.State == S_PERSON_SPELL_TRANCE) then
--       return;
--     end
--
--     if (self.RetaliateWithSpell ~= M_SPELL_NONE) then
--       self.RetaliateWait = self.RetaliateWait - 1;
--       if (self.RetaliateWait <= 0) then
--         -- let's check if any enemy shaman is around, HEHEBOI
--         local found = false;
--         for i = 0, 7 do
--           local es = getShaman(i);
--           if (es ~= nil) then
--             if (are_players_allied(es.Owner, s.Owner) == 0) then
--               -- found evil, cleanse if nearby.
--               if (get_world_dist_xyz(es.Pos.D3, s.Pos.D3) <= 4096) then
--                 CREATE_THING_WITH_PARAMS4(T_SPELL, self.RetaliateWithSpell, s.Owner, es.Pos.D3, 10000, es.ThingNum, 0, 0);
--                 self.RetaliateWithSpell = M_SPELL_NONE;
--                 found = true;
--                 break;
--               end
--             end
--           end
--         end
--
--         if (not found) then
--           CREATE_THING_WITH_PARAMS4(T_SPELL, self.RetaliateWithSpell, s.Owner, s.Pos.D3, 10000, 0, 0, 0);
--           self.RetaliateWithSpell = M_SPELL_NONE;
--           return;
--         end
--       end
--     end
--
--     -- process custom entries.
--     local found_target = false;
--     SearchMapCells(CIRCULAR, 0, 0, 6, world_coord2d_to_map_idx(s.Pos.D2), function(me)
--       if (not me.MapWhoList:isEmpty()) then
--         me.MapWhoList:processList(function(t)
--           if (are_players_allied(s.Owner, t.Owner) == 1) then
--             return true;
--           end
--
--           if (t.Type == T_BUILDING) then
--             -- find entry that fits the bill
--             for i,Spell in ipairs(self.SpellEntries) do
--               if (Spell.TargetType == t.Type) then
--                 return false;
--               end
--             end
--           end
--
--           if (t.Type == T_PERSON) then
--             for i,SP in ipairs(self.SpellEntries) do
--               if (SP.TargetType == t.Type) then
--                 -- now check if model fits
--                 for j,Model in ipairs(SP.TargetModels) do
--                   if (Model == t.Model) then
--                     CREATE_THING_WITH_PARAMS4(T_SPELL, SP.Spell, s.Owner, t.Pos.D3, 10000, t.ThingNum, 0, 0);
--                     return false;
--                     --break;
--                   end
--                 end
--               end
--             end
--           end
--           return true;
--         end);
--       end
--       if (found_target) then return false; else return true; end
--     end);
--   end
-- end
--
-- function AIShaman:WatchForDodges(t)
--   if (self.Proxy:isNull()) then
--     return;
--   end
--
--   local s = self.Proxy:get();
--
--   if (self.FallDamageSave == true) then
--     if (G_RANDOM(100) < self.FallDamageChance) then
--       if (t.Type == T_EFFECT) then
--         if (t.Model == M_EFFECT_SPELL_BLAST and are_players_allied(t.Owner, s.Owner) == 0) then
--           if (get_world_dist_xyz(t.Pos.D3, s.Pos.D3) <= 512) then
--             self.RetaliateWait = 2;
--             self.RetaliateWithSpell = M_SPELL_LIGHTNING_BOLT;
--             return;
--           end
--         end
--       end
--     end
--   end
-- end
--
-- function AIPlayer:ToggleShamanAI(bool)
--   if (self.Shaman == nil and bool) then
--     self.Shaman = AIShaman:NewShaman(self.Owner);
--   elseif (self.Shaman ~= nil and not bool) then
--     self.Shaman = nil;
--   end
-- end
--
-- function AIPlayer:Shaman_ToggleLBSave(bool)
--   if (self.Shaman ~= nil) then
--     self.Shaman.LandBridgeSave = bool;
--   end
-- end
--
-- function AIPlayer:Shaman_ToggleLightningDodge(bool)
--   if (self.Shaman ~= nil) then
--     self.Shaman.LightningDodge = bool;
--   end
-- end
--
-- function AIPlayer:Shaman_ToggleFallDamageSave(bool)
--   if (self.Shaman ~= nil) then
--     self.Shaman.FallDamageSave = bool;
--   end
-- end
--
-- function AIPlayer:Shaman_ToggleSpellEntries(bool)
--   if (self.Shaman ~= nil) then
--     self.Shaman.CustomSpellEntries = bool;
--   end
-- end
--
-- function AIPlayer:Shaman_AddSpellEntry(spell, target_type, target_models, cost);
--   if (self.Shaman ~= nil) then
--     self.Shaman.SpellEntries[#self.Shaman.SpellEntries + 1] = AISpellEntry:NewEntry(spell, target_type, target_models, cost);
--   end
-- end
--
-- function AIPlayer:ProcessEvents()
--   for i,Event in pairs(self.Events) do
--     if (Event:Tick()) then
--       Event.Func(self.Owner);
--     end
--   end
-- end
--
-- function AIPlayer:RegisterEvent(_name, ticks, randomness, func)
--   if (self.Events[_name] == nil) then
--     self.Events[_name] = AIEvent:NewEvent(func, ticks, randomness);
--   end
-- end
--
-- -- does not destroy actually in-game, just in lua
-- function AIPlayer:DestroyTower(_name)
--   if (self.Towers[_name] ~= nil) then
--     self.Towers[_name] = nil;
--   end
-- end
--
-- function AIPlayer:TowerIsBuilt(_name)
--   if (self.Towers[_name] ~= nil) then
--     if (not self.Towers[_name]:isNull()) then
--       if (self.Towers[_name].Stage == 2) then
--         return true;
--       end
--     end
--   end
--
--   return false;
-- end
--
-- function AIPlayer:CheckTower(_name)
--   if (self.Towers[_name] ~= nil) then
--     if (self.Towers[_name]:isNull()) then
--       if (self.Towers[_name].Stage == 0) then
--         self.Towers[_name]:TryCreate();
--       elseif (self.Towers[_name].Stage == 1) then
--         self.Towers[_name]:TryBind();
--       elseif(self.Towers[_name].Stage == 2) then
--         self.Towers[_name].Stage = 0; -- rebuild.
--       end
--     end
--   end
-- end
--
-- function AIPlayer:RegisterTower(_name, x, z, orient)
--   if (self.Towers[_name] == nil) then
--     self.Towers[_name] = AITower:NewTower(self.Owner, x, z, orient);
--   end
-- end
--
-- function GetAI(_name)
--   return CompPlayers[_name];
-- end
--
-- function Initialize_Special_AI(_name, player_num)
--   if (CompPlayers[_name] == nil) then
--     CompPlayers[_name] = AIPlayer:Init(player_num);
--   end
-- end
--
-- function AIOnCreateCheck(t)
--   for i,AI in pairs(CompPlayers) do
--     if (AI.Shaman ~= nil) then
--       AI.Shaman:WatchForDodges(t);
--     end
--   end
-- end
--
