local CASTINGM_NONE = 0;
local CASTINGM_DEFENSIVE = 1;
local CASTINGM_OFFENSIVE = 2;

local MP_POS = MapPosXZ.new();

local ACCEPTABLE_DEFENSIVE_PERSON_MODELS = {false, true, true, true, true, true, false, false};
local is_person_valid_for_defensive_spell =
{
  [M_SPELL_SHIELD] = function(t) return (t.u.Pers.u.Owned.ShieldCount == 0); end,
  [M_SPELL_INVISIBILITY] = function(t) return (t.u.Pers.u.Owned.InvisibleCount == 0); end,
  [M_SPELL_BLOODLUST] = function(t) return (t.u.Pers.u.Owned.BloodlustCount == 0); end
}

local sh_mt = {};
sh_mt.__index = 
{
  set_offensive_spell_entry = function(self, idx, spell, b_models, max_shots, cost)
    self.SpellOffensiveEntry[idx] =
    {
      _spell = spell;
      _targets = {
        [1] = false, 
        [2] = false, 
        [3] = false, 
        [4] = false, 
        [5] = false, 
        [6] = false, 
        [7] = false, 
        [8] = false,
        [13] = false,
        [15] = false
      },
      _max_shots = max_shots,
      _cost = cost,
      _used_count = max_shots,
      _mana = 0
    };
    
    local curr_entry = self.SpellOffensiveEntry[idx];
    
    for i,model in ipairs(b_models) do
      curr_entry._targets[model] = true;
    end
  end,
  
  set_defensive_spell_entry = function(self, idx, spell, max_shots, cost)
    self.SpellDefensiveEntry[idx] =
    {
      _spell = spell;
      _max_shots = max_shots,
      _cost = cost,
      _used_count = 0,
      _mana = 0
    };
  end,
  
  can_cast_offensive_spell = function(self, idx)
    return (self.SpellOffensiveEntry[idx]._used_count < self.SpellOffensiveEntry[idx]._max_shots);
  end,
  
  set_casting_delay = function(self, val)
    self.SpellDelay = val;
  end,
  
  toggle_converting_wilds = function(self, toggle)
    if (toggle) then
      self.ConvertWild = true;
      self.MaxRad = (G_PLR[self.Owner].LimitsSpell.WorldCoordRange[M_SPELL_CONVERT_WILD] >> 9) + 1;
      self.CurrRad = 0;
    else
      self.ConvertWild = false;
      self.CurrEntry = -1;
      self.MaxRad = 0;
      self.CurrRad = 0;
    end
  end,
  
  set_no_casting = function(self)
    self.CastingMode = CASTINGM_NONE;
    self.CurrRad = 0;
    self.MaxRad = 0;
  end,
  
  set_defensive_mode = function(self)
    self.CastingMode = CASTINGM_DEFENSIVE;
    -- get radius of the first spell in defensive entry
    for i,spell in ipairs(self.SpellDefensiveEntry) do
      if (spell ~= nil) then
        if (spell._used_count < spell._max_shots) then
          self.CurrEntry = i;
          self.MaxRad = G_PLR[self.Owner].LimitsSpell.WorldCoordRange[spell._spell] >> 9;
          self.CurrRad = 0;
          break;
        end
      end
    end
  end,
  
  set_offensive_mode = function(self)
    self.CastingMode = CASTINGM_OFFENSIVE;
    
    -- get radius of the first spell in defensive entry
    for i,spell in ipairs(self.SpellOffensiveEntry) do
      if (spell ~= nil) then
        if (spell._used_count < spell._max_shots) then
          self.CurrEntry = i;
          self.MaxRad = G_PLR[self.Owner].LimitsSpell.WorldCoordRange[spell._spell] >> 9;
          self.CurrRad = 0;
          break;
        end
      end
    end
  end,
  
  process_mana_sharing = function(self, sturn)
    if ((sturn + self.Owner) & 3 == 0) then
      local curr_mana_amt = G_PLR[self.Owner].LastManaIncr >> 2;
      
      local se_size = #self.SpellDefensiveEntry;
      local se = self.SpellDefensiveEntry;
      local entry;
      
      for i = 1, se_size do
        entry = se[i];
        
        if (entry ~= nil) then
          if (entry._used_count > 0) then
            entry._mana = entry._mana + curr_mana_amt;
          
            if (entry._mana >= entry._cost) then
              entry._used_count = entry._used_count - 1;
              entry._mana = 0;
            end
          end
        end
      end
      
      se_size = #self.SpellOffensiveEntry;
      se = self.SpellOffensiveEntry;
      
      for i = 1, se_size do
        entry = se[i];
        
        if (entry ~= nil) then
          if (entry._used_count > 0) then
            entry._mana = entry._mana + curr_mana_amt;
          
            if (entry._mana >= entry._cost) then
              entry._used_count = entry._used_count - 1;
              entry._mana = 0;
            end
          end
        end
      end
    end
  end,
  
  process_casting_modes = function(self, sturn)
    if (self.CastDelay > 0) then
      self.CastDelay = self.CastDelay - 1;
      goto pcm_end;
    end
    
    local s = getShaman(self.Owner);
      
    if (s == nil) then
      goto pcm_end;
    end
    
    if (is_med_man_in_valid_state_to_cast_a_spell(s) == 0) then
      goto pcm_end;
    end
    
    if ((sturn + self.Owner) & 3 ~= 0) then
      --log("SKIP TURN: " .. sturn);
      goto pcm_end;
    end
    
    -- Made it forced, since it'll cause some issues later with older approach
    if (self.ConvertWild) then
      if (MANA(s.Owner) > 0) then
        local break_look2 = false;
        SearchMapCells(CIRCULAR, 0, self.CurrRad, self.CurrRad, world_coord3d_to_map_idx(s.Pos.D3), function(map_elem)
          if (not map_elem.PlayerMapWho[TRIBE_HOSTBOT]:isEmpty()) then
            map_elem.PlayerMapWho[TRIBE_HOSTBOT]:processList(function(t)
              if (t.Type == T_PERSON) then
                if (t.Model == M_PERSON_WILD) then
                  break_look2 = true;
                  self.CurrRad = 0;
                  self.CastDelay = self.SpellDelay;
                  CREATE_THING_WITH_PARAMS4(T_SPELL, M_SPELL_CONVERT_WILD, s.Owner, t.Pos.D3, 0, t.ThingNum, 0, 0);
                  return false;
                end
              end
              
              return true;
            end);
          end
            
          --map_ptr_to_world_coord2d_centre(map_elem, c2d);
          --coord2D_to_coord3D(c2d, c3d);
          --createThing(T_EFFECT, 2, 8, c3d, false, false);
            
          if (break_look2) then
            return false;
          end
            
          return true;
        end);
      end
      
      if (self.CurrRad < self.MaxRad) then
        self.CurrRad = self.CurrRad + 1;
      else
        self.CurrRad = 0;
      end
      
      goto pcm_end;
    end
    
    if (self.CastingMode == CASTINGM_NONE) then
      goto pcm_end;
    end
    
    if (self.CastingMode == CASTINGM_DEFENSIVE) then
      if (self.CurrEntry == -1) then
        -- spell was reset supposedly
        for i,spell in ipairs(self.SpellDefensiveEntry) do
          if (spell ~= nil) then
            if (spell._used_count < spell._max_shots) then
              self.CurrEntry = i;
              self.MaxRad = G_PLR[self.Owner].LimitsSpell.WorldCoordRange[spell._spell] >> 9;
              self.CurrRad = 0;
              goto pcm_process_def;
              break;
            end
          end
        end
        
        goto pcm_end;
      end
      
      ::pcm_process_def::
      
      local curr_entry = self.SpellDefensiveEntry[self.CurrEntry];
      local break_loop = false;
      
      if (curr_entry._used_count < curr_entry._max_shots) then
        SearchMapCells(CIRCULAR, 0, self.CurrRad, self.CurrRad, world_coord3d_to_map_idx(s.Pos.D3), function(map_elem)
          if (not map_elem.PlayerMapWho[self.Owner]:isEmpty()) then
            map_elem.PlayerMapWho[self.Owner]:processList(function(t)
              if (t.Type == T_PERSON) then
                if (ACCEPTABLE_DEFENSIVE_PERSON_MODELS[t.Model]) then
                  if (is_person_valid_for_defensive_spell[curr_entry._spell](t)) then
                    break_loop = true;
                    self.CurrRad = 0
                    self.CastDelay = self.SpellDelay;
                    curr_entry._used_count = curr_entry._used_count + 1;
                    CREATE_THING_WITH_PARAMS4(T_SPELL, curr_entry._spell, s.Owner, t.Pos.D3, curr_entry._cost, t.ThingNum, 0, 0);
                    return false;
                  end
                end
              end
              
              return true;
            end);
          end
          
          if (break_loop) then
            return false;
          end
          
          return true;
        end);
      else
        self.CurrEntry = -1;
      end
      
      if (self.CurrRad < self.MaxRad) then
        self.CurrRad = self.CurrRad + 1;
      else
        self.CurrRad = 0;
      end
      
      goto pcm_end;
    end
    
    if (self.CastingMode == CASTINGM_OFFENSIVE) then
      if (self.CurrEntry == -1) then
        -- spell was reset supposedly
        for i,spell in ipairs(self.SpellOffensiveEntry) do
          if (spell ~= nil) then
            if (spell._used_count < spell._max_shots) then
              self.CurrEntry = i;
              self.MaxRad = G_PLR[self.Owner].LimitsSpell.WorldCoordRange[spell._spell] >> 9;
              self.CurrRad = 0;
              goto pcm_process_off;
              break;
            end
          end
        end
        
        goto pcm_end;
      end
      
      ::pcm_process_off::
      
      local curr_entry = self.SpellOffensiveEntry[self.CurrEntry];
      local shape_or_bldg = nil;
      
      if (curr_entry._used_count < curr_entry._max_shots) then
        SearchMapCells(CIRCULAR, 0, self.CurrRad, self.CurrRad, world_coord3d_to_map_idx(s.Pos.D3), function(map_elem)
        
          shape_or_bldg = map_elem.ShapeOrBldgIdx:get();
          
          if (shape_or_bldg ~= nil) then
            if (shape_or_bldg.Type == T_BUILDING) then
              if (are_players_allied(shape_or_bldg.Owner, s.Owner) == 0) then
                if (curr_entry._targets[shape_or_bldg.Model]) then
                  break_loop3 = true;
                  self.CurrRad = 0
                  self.CastDelay = self.SpellDelay;
                  curr_entry._used_count = curr_entry._used_count + 1;
                  CREATE_THING_WITH_PARAMS4(T_SPELL, curr_entry._spell, s.Owner, shape_or_bldg.Pos.D3, curr_entry._cost, shape_or_bldg.ThingNum, 0, 0);
                  return false;
                end
              end
            end
          end
          
          return true;
        end);
      else
        self.CurrEntry = -1;
      end
      
      if (self.CurrRad < self.MaxRad) then
        self.CurrRad = self.CurrRad + 1;
      else
        self.CurrRad = 0;
      end
      
      goto pcm_end;
    end
    
    ::pcm_end::
  end,
}

local _AI_SHAMANS = {};

function register_shaman_ai(player_num)
  _AI_SHAMANS[#_AI_SHAMANS + 1] = setmetatable(
  {
    Owner = player_num;
    Enabled = true,
    CastDelay = 0,
    SpellDelay = 12, -- DEFAULT
    CastingMode = CASTINGM_NONE,
    SpellOffensiveEntry = {nil, nil, nil, nil, nil},
    SpellDefensiveEntry = {nil, nil, nil},
    CurrEntry = -1,
    CurrRad = 0,
    MaxRad = -1,
  }, sh_mt);
  
  return _AI_SHAMANS[#_AI_SHAMANS];
end

function process_shaman_ai(sturn);
  for i,ai in ipairs(_AI_SHAMANS) do
    ai:process_mana_sharing(sturn);
    ai:process_casting_modes(sturn);
  end
end


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