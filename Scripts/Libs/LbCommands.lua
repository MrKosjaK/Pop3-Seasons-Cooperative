Cmds = 
{
  Command = Commands.new(),
  CTI = CmdTargetInfo.new(),
  Idx = 0,
};

local cmd_mt = {};

function cmd_mt:clear_person_commands(t)
  self.Idx = 0;
  remove_all_persons_commands(t);
end

function cmd_mt:get_person_idx(t)
  -- check the amount of commands person has
  local cmds = 0;
  for i = 0, 7 do
    if (t.u.Pers.CmdIdxs[i] ~= nil) then
	  cmds = cmds + 1;
    end
  end
  
  self.Idx = cmds;
end

function cmd_mt:get_commands_amount(t)
  local cmds = 0;
  for i = 0, 7 do
    if (t.u.Pers.CmdIdxs[i] ~= nil) then
	  cmds = cmds + 1;
    end
  end
  
  return cmds;
end

function cmd_mt:patrol_point(t, c2d)
  if (self.Idx < 8) then
    self.CTI.TargetCoord.Xpos = c2d.Xpos;
	self.CTI.TargetCoord.Zpos = c2d.Zpos;
	
	self.CTI.TIdxSize.MapIdx = world_coord2d_to_map_idx(c2d);
	self.CTI.TIdxSize.CellsX = 6;
	self.CTI.TIdxSize.CellsZ = 6;
	
	update_cmd_list_entry(self.Command, CMD_GUARD_AREA_PATROL, self.CTI, 0);
	
	t.Flags = t.Flags | TF_RESET_STATE;
	add_persons_command(t, self.Command, self.Idx);
	self.Idx = self.Idx + 1;
  end
end

function cmd_mt:patrol_circle(t, x, z)
  if (self.Idx < 8) then
    self.CTI.TIdxSize.MapIdx = map_xz_to_map_idx(x, z);
	self.CTI.TIdxSize.CellsX = 6;
	self.CTI.TIdxSize.CellsZ = 6;
	
	update_cmd_list_entry(self.Command, CMD_GUARD_AREA, self.CTI, 0);
	
	t.Flags = t.Flags | TF_RESET_STATE;
	add_persons_command(t, self.Command, self.Idx);
	self.Idx = self.Idx + 1;
  end
end

function cmd_mt:construct_building(t, target_thing)
  if (self.Idx < 8) then
    self.CTI.TargetIdx:set(0);
    self.CTI.TMIdxs.TargetIdx:set(target_thing.ThingNum);
	self.CTI.TMIdxs.MapIdx = world_coord2d_to_map_idx(target_thing.Pos.D2);
	
	update_cmd_list_entry(self.Command, CMD_BUILD_BUILDING, self.CTI, 0);
	
	t.Flags = t.Flags | TF_RESET_STATE;
	add_persons_command(t, self.Command, self.Idx);
	self.Idx = self.Idx + 1;
  end
end

function cmd_mt:attack_person(t, victim_idx)
  if (self.Idx < 8) then
    self.CTI.TargetIdx:set(victim_idx);
    self.CTI.TMIdxs.TargetIdx:set(victim_idx);
  
    update_cmd_list_entry(self.Command, CMD_ATTACK_TARGET, self.CTI, 0);
  
    t.Flags = t.Flags | TF_RESET_STATE;
    add_persons_command(t, self.Command, self.Idx);
    self.Idx = self.Idx + 1;
  end
end

setmetatable(Cmds,
{
  __index = cmd_mt,
  __call = function(t, ...)
    -- nothing.
  end,
});