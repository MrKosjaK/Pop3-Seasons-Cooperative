import(Module_Table)
import(Module_System)

include("LibCmd.lua")
include("UtilRefs.lua")

local function is_thing_valid_shape(t)
  if (t.Type == T_SHAPE) then
    if (_gsi.Players[t.Owner].PlayerType == COMPUTER_PLAYER) then
      if (t.u.Shape.BldgModel == 1) then
        local builders = {}
        local count = 0
        ProcessGlobalSpecialList(t.Owner, PEOPLELIST, function(_t)
          if (_t.Model == M_PERSON_BRAVE and count < 2) then
            if (_t.u.Pers.u.Owned.TimeDoingNothing > 0 or _t.State == S_PERSON_SUPRISED_BY_PLAYER) then
              table.insert(builders,_t)
              count=count+1
            end
            return true
          end
          
          return true
        end)
        if (#builders > 0) then
          local tree_found = false
          local treeThing = nil
          ProcessGlobalSpecialList(TRIBE_HOSTBOT, WOODLIST, function(__t)
            if (get_world_dist_xyz(__t.Pos.D3,t.Pos.D3) < 512*12) then
              tree_found = true
              treeThing = __t
              return false
            end
            
            return true
          end)
          for i,k in ipairs(builders) do
            remove_all_persons_commands(k)
            k.Flags = k.Flags | TF_RESET_STATE
            local index = 0
            if (tree_found) then
              add_persons_command(k,cmd_gather_wood(treeThing,true),index)
              index=index+1
            end
            add_persons_command(k,cmd_build(t),index)
          end
        end
      end
    end
  end
end

function OnCreateThing(t)
  is_thing_valid_shape(t)
end