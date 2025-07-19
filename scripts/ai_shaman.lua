local sh_mt = {};
sh_mt.__index = sh_mt;
local c_mposxz = MapPosXZ.new();

function create_shaman_ai(player_num)
  return setmetatable({
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

function sh_mt:can_cast_spell_from_entry(idx)
  return (self.SpellEntries[idx].UsageCount < self.SpellEntries[idx].MaxUsage);
end

function sh_mt:process_mana()
  local curr_mana_amt = G_PLR[self.Owner].LastManaIncr >> 4;
  
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
				  self.CastDelay = 52;
				  self.SpellCheckCurr = 0;
				  CREATE_THING_WITH_PARAMS4(T_SPELL, M_SPELL_CONVERT_WILD, s.Owner, t.Pos.D3, 10000, 0, 0, 0);
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
		    if (not is_item_in_table(self.CheckedBldgs, shape_or_bldg.ThingNum) and shape_or_bldg.State == S_BUILDING_STAND) then
		      if (are_players_allied(s.Owner, shape_or_bldg.Owner) == 0) then
			    for m = 1, se_size do
			      for k = 1, #se[m].Models do
				    if (se[m].Models[k] == shape_or_bldg.Model and se[m].UsageCount < se[m].MaxUsage) then
				      self.CastDelay = 12;
					  self.SpellCheckCurr = 0;
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