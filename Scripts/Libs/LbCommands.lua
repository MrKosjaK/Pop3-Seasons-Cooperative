Cmds = 
{
  Command = Commands.new(),
  CTI = CmdTargetInfo.new(),
  Idx = 0,
};

local cmd_mt = {};

function cmd_mt:clear_persons_commands(t)
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