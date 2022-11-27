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

local cp_mt = {};
local ev_mt = {};
ev_mt.__index = ev_mt;
local tw_mt = {};
tw_mt.__index = tw_mt;
local sh_mt = {};
sh_mt.__index = sh_mt;
local pl_mt = {};
pl_mt.__index = pl_mt;

setmetatable(CompPlayer,
{
  __call = function(t, key)
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
      Shaman = setmetatable({
        Owner = player_num,
        Enabled = false,
        Proxy = ObjectProxy.new(),
		CastDelay = 0,
		ConvertWild = false;
        LandBridgeSave = false,
        LandBridgeChance = 0,
        FallDamageSave = false,
        FallDamageChance = 0,
        LightningDodge = false,
        LightningDodgeChance = 0,
        SpellCheck = false,
        SpellCheckMax = 0,
        SpellCheckCurr = 0,
        SpellEntries = {nil, nil, nil, nil, nil, nil, nil, nil},
		CheckedCooldown = 0,
		CheckedBldgs = {}
      }, sh_mt);
    };
    setmetatable(tribe_info, pl_mt);
    self.Data[player_num] = tribe_info;
  end
end

function cp_mt:deinit(player_num)
  if (self.Data[player_num] ~= nil) then
    self.Data[player_num] = nil;
  end
end

function cp_mt:process_ai()
  for i = 0, 7 do
    local ai = self.Data[i];
    if (ai ~= nil) then
      ai:process();
    end
  end
end

function cp_mt:process_on_create_ais(t)
  for i = 0, 7 do
    local ai = self.Data[i];
    if (ai ~= nil) then
      if (ai.Shaman.Enabled) then
        ai.Shaman:watch_for_dodges(t);
      end
    end
  end
end

function pl_mt:process()
  -- events processing
  for i = 1, #self.Events do
    local ev = self.Events[i];
    if (ev ~= nil) then
      if (ev:is_triggered()) then
        ev.Func(self.Owner);
      end
    end
  end

  -- shaman binding
  if (self.Shaman.Enabled) then
    self.Shaman:process();
  end
end

function pl_mt:toggle_shaman_ai(bool)
  self.Shaman.Enabled = bool;
end

function pl_mt:get_shaman_ai()
  return self.Shaman;
end

function sh_mt:set_spell_entry(idx, spell, t_models, used_count, max_count, cost)
  local spell_entry =
  {
    Spell = spell,
	Models = t_models,
	MaxUsage = max_count,
	UsageCount = math.max(0, used_count),
	ManaStored = 0,
	ManaCost = math.max(100, cost);
  }
  self.SpellEntries[idx] = spell_entry;
end

function sh_mt:process_mana()
  local curr_mana_amt = G_PLR_PTR[self.Owner].LastManaIncr >> 4;
  
  local se_size = #self.SpellEntries;
  local se = self.SpellEntries;
  local entry;
  
  for i = 1, se_size do
    entry = se[i];
	if (entry.UsageCount > 0) then
      entry.ManaStored = entry.ManaStored + curr_mana_amt;
	
	  if (entry.ManaStored >= entry.ManaCost) then
	    entry.UsageCount = entry.UsageCount - 1;
		entry.ManaStored = 0;
	  end
	end
  end
end

function sh_mt:process()
  if (self.Proxy:isNull()) then
    local s = getShaman(self.Owner);
	if (s ~= nil) then
	  self.Proxy:set(s.ThingNum);
	end
  else
    local s = self.Proxy:get();
	self:process_mana();
	
	--log(string.format("Mana Gen Rate: %i", G_PLR_PTR[s.Owner].LastManaIncr));
	
	if (self.CastDelay > 0) then
	  self.CastDelay = self.CastDelay - 1;
	  return;
	end
	
	if (s.State == S_PERSON_SPELL_TRANCE or (s.Flags & TF_DROWNING ~= 0) or (s.Flags & TF_LOST_CONTROL ~= 0) or (s.Flags & TF2_THING_IN_AIR ~= 0)) then
	  return;
	end
	
	if (self.SpellCheck) then
	  if (#self.CheckedBldgs) then
	    self.CheckedCooldown = self.CheckedCooldown - 1;
		
		if (self.CheckedCooldown <= 0) then
		  self.CheckedBldgs = {};
		end
	  end
	
	  if (self.ConvertWild) then
	    self.SpellCheckMax = G_SPELL_CONST[M_SPELL_CONVERT_WILD].WorldCoordRange >> 9;
	  else
	    self.SpellCheckMax = 8;
	  end
	  
	  if (self.SpellCheckCurr > self.SpellCheckMax) then
	    self.SpellCheckCurr = 0;
	  end
	  
	  --local c3d_c = Coord3D.new();
	  local stop_me_search = false;
	  local s_target;
	  local se_size = #self.SpellEntries;
	  local se = self.SpellEntries;
	  local shape_or_bldg;
	  local break2 = false;

	  SearchMapCells(CIRCULAR, 0, self.SpellCheckCurr, self.SpellCheckCurr, world_coord3d_to_map_idx(s.Pos.D3), function(me)
	    if (self.ConvertWild) then
		  if (MANA(s.Owner) > 10000) then
		    if (not me.PlayerMapWho[8]:isEmpty()) then
			  me.PlayerMapWho[8]:processList(function(t)
			    if (t.Type == T_PERSON) then
				  self.CastDelay = 32;
				  CREATE_THING_WITH_PARAMS4(T_SPELL, M_SPELL_CONVERT_WILD, s.Owner, t.Pos.D3, 0, 0, 0, 0);
				  stop_me_search = true;
				  return false;
			    end
			    return true;
			  end);
		    end
		  end
	    end
	  
	    if (stop_me_search) then return false; end
	  
	    shape_or_bldg = me.ShapeOrBldgIdx:get();
	    if (shape_or_bldg ~= nil) then
		  if (shape_or_bldg.Type == T_BUILDING) then
		    if (not isItemInTable(self.CheckedBldgs, shape_or_bldg.ThingNum) and shape_or_bldg.State == S_BUILDING_STAND) then
		      if (are_players_allied(s.Owner, shape_or_bldg.Owner) == 0) then
			    for m = 1, se_size do
			      for k = 1, #se[m].Models do
				    if (se[m].Models[k] == shape_or_bldg.Model and se[m].UsageCount < se[m].MaxUsage) then
				      self.CastDelay = 12;
					  se[m].UsageCount = se[m].UsageCount + 1;
				      CREATE_THING_WITH_PARAMS4(T_SPELL, se[m].Spell, s.Owner, shape_or_bldg.Pos.D3, 0, 0, 0, 0);
				      stop_me_search = true;
				      break2 = true;
				      self.CheckedBldgs[#self.CheckedBldgs + 1] = shape_or_bldg.ThingNum;
				      self.CheckedCooldown = 240;
				      break;
					end
				  end
				
				  if (break2) then break; end
				end
			  end
		    end
		  end
	    end
	  
	    if (stop_me_search) then return false; else return true; end
	  end);

	  
	  self.SpellCheckCurr = self.SpellCheckCurr + 1;
	end
	-- if (self.ConvertWild) then
	  -- -- converting wild is pog
	  -- local radius = G_SPELL_CONST[M_SPELL_CONVERT_WILD].WorldCoordRange >> 9;
	  -- if (self.SpellCheckMax < radius) then self.SpellCheckMax = radius; end
	  
	  -- SearchMapCells(CIRCULAR, 0, self.SpellCheckCurr, self.SpellCheckCurr, world_coord3d_to_map_idx(s.Pos.D3), function(me)
	    -- if (not me.PlayerMapWho[TRIBE_HOSTBOT]:isEmpty()) then
		  -- me.PlayerMapWho[TRIBE_HOSTBOT]:processList(function(t)
		    -- if (t.Type == T_PERSON) then
			  -- CREATE_THING_WITH_PARAMS4(T_SPELL, M_SPELL_CONVERT_WILD, s.Owner, t.Pos.D3, 10000, 0, 0, 0);
			  -- return false;
			-- end
		    -- return true;
		  -- end);
		-- end
		-- local idx = map_xz_to_map_idx(me.X, me.Y);
		-- local c3d_c = Coord3D.new();
		-- map_idx_to_world_coord3d_centre(idx, c3d_c);
		-- createThing(T_EFFECT, 4, 8, c3d_c, false, false);
		-- return true;
	  -- end);
	  -- self.SpellCheckCurr = self.SpellCheckCurr + 1;
	  -- if (self.SpellCheckCurr > radius) then self.SpellCheckCurr = 0; end
	  -- return;
	-- end
  end
end

function sh_mt:toggle_converting(bool)
  self.ConvertWild = bool;
end

function sh_mt:toggle_land_bridge_save(bool, chance)
  self.LandBridgeSave = bool;
  self.LandBridgeChance = math.min(chance, 100);
end

function sh_mt:toggle_fall_damage_save(bool, chance)
  self.FallDamageSave = bool;
  self.FallDamageChance = math.min(chance, 100);
end

function sh_mt:toggle_lightning_dodge(bool, chance)
  self.LightningDodge = bool;
  self.LightningDodgeChance = math.min(chance, 100);
end

function sh_mt:toggle_spell_check(bool)
  self.SpellCheck = bool;
end

function sh_mt:watch_for_dodges(t)
  local s = self.Proxy:get();

  if (s == nil) then return; end

  if (self.FallDamageSave == true) then
    if (G_RANDOM(100) < self.FallDamageChance) then
      if (t.Type == T_EFFECT) then
        if (t.Model == M_EFFECT_SPELL_BLAST and are_players_allied(t.Owner, s.Owner) == 0) then
          if (get_world_dist_xyz(t.Pos.D3, s.Pos.D3) <= 5120) then
            CREATE_THING_WITH_PARAMS4(T_SPELL, M_SPELL_BLAST, s.Owner, s.Pos.D3, 10000, 0, 0, 0);
            return;
          end
        end
      end
    end
  end
end

function pl_mt:create_tower(idx, x, z, orient)
  if (self.Towers[idx] == nil) then
    local tower =
    {
      Owner = self.Owner;
      X = x;
      Z = z;
      Orient = orient or -1;
      Obj = ObjectProxy.new();
      Stage = 0;
    };
    setmetatable(tower, tw_mt);
    self.Towers[idx] = tower;
  end
end

function pl_mt:is_tower_constructed(idx)
  return self.Towers[idx]:is_finished();
end

function pl_mt:construct_tower(idx)
  self.Towers[idx]:check_for_creation();
end

function tw_mt:check_for_creation()
  if (self.Stage == 0) then
    if (self.Obj:isNull()) then
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
	  
	  -- just in case, check if theres actually already a tower existing.
	  local me = MAP_ELEM_IDX_2_PTR(map_idx);
	  local obj = me.ShapeOrBldgIdx:get();
	  if (obj ~= nil) then
        if (obj.Type == T_BUILDING and obj.Model == M_BUILDING_DRUM_TOWER and obj.Owner == self.Owner) then
          self.Stage = 1;
          self.Obj:set(obj.ThingNum);
          return;
        end
      end
    end
  elseif (self.Stage == 1) then
    if (self.Obj:isNull()) then
      local map_idx = map_xz_to_map_idx(self.X, self.Z);
      local me = MAP_ELEM_IDX_2_PTR(map_idx);
      local obj = me.ShapeOrBldgIdx:get();
      if (obj ~= nil) then
        if (obj.Type == T_BUILDING and obj.Model == M_BUILDING_DRUM_TOWER and obj.Owner == self.Owner) then
          self.Stage = 2;
          self.Obj:set(obj.ThingNum);
          return;
        end
      else
        self.Stage = 0;
      end
    end
  else
    self.Stage = 0;
  end
end

function tw_mt:is_finished()
  -- first check if our proxy is null or not
  local t = self.Obj:get();
  if (t ~= nil) then
    if (t.Type == T_BUILDING and t.State == S_BUILDING_STAND) then
      return true;
    end
  end

  return false;
end

function pl_mt:create_event(idx, ticks, randomness, func)
  if (self.Events[idx] == nil) then
    local event =
    {
      BaseTicks = ticks,
      Randomness = randomness;
      Ticks = ticks - G_RANDOM(randomness);
      Func = func;
    };
    setmetatable(event, ev_mt);
    self.Events[idx] = event;
  end
end

function ev_mt:is_triggered()
  self.Ticks = self.Ticks - 1;

  if (self.Ticks <= 0) then
    self.Ticks = self.BaseTicks - (G_RANDOM(self.Randomness));
    return true;
  end

  return false;
end

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
  -- if (self.Proxy:isNull()) then
  --   return;
  -- end
  --
  -- local s = self.Proxy:get();
  --
  -- if (self.FallDamageSave == true) then
  --   if (G_RANDOM(100) < self.FallDamageChance) then
  --     if (t.Type == T_EFFECT) then
  --       if (t.Model == M_EFFECT_SPELL_BLAST and are_players_allied(t.Owner, s.Owner) == 0) then
  --         if (get_world_dist_xyz(t.Pos.D3, s.Pos.D3) <= 512) then
  --           self.RetaliateWait = 2;
  --           self.RetaliateWithSpell = M_SPELL_LIGHTNING_BOLT;
  --           return;
  --         end
  --       end
  --     end
  --   end
  -- end
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
-- function AIOnCreateCheck(t)
--   for i,AI in pairs(CompPlayers) do
--     if (AI.Shaman ~= nil) then
--       AI.Shaman:WatchForDodges(t);
--     end
--   end
-- end
--
