Cmds = 
{
  Command = Commands.new(),
  CTI = CmdTargetInfo.new(),
  Idx = 0,
};

local cmd_mt = {};

local function cmd_mt:clear_persons_commands(t)
  self.Idx = 0;
  remove_all_persons_commands(t);
end

local function cmd_mt:get_person_idx(t)
  self.Idx = t.u.Pers.CurrCmd + 1;
end

local function cmd_mt:attack_person(t, victim_idx)
  self.CTI.TargetIdx:set(victim_idx);
  self.CTI.TMIdxs.TargetIdx:set(victim_idx);
  
  update_cmd_list_entry(self.Command, CMD_ATTACK_TARGET, self.CTI, 0);
  
  add_persons_command(t, self.Command, self.Idx);
  self.Idx = Idx + 1;
end

setmetatable(Cmds,
{
  __index = cmd_mt,
  __call = function(t, ...)
    -- nothing.
  end,
});