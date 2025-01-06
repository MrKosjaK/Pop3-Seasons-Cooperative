local cmd_data =
{
  Data = { Commands.new(), Commands.new(), Commands.new(), Commands.new(), Commands.new(), Commands.new(), Commands.new(), Commands.new() },
  Info = CmdTargetInfo.new(),
  Count = 0
};

local c_xz = MapPosXZ.new();
local c_me = nil;
local c_thing = nil;

local function clear_target_cache()
  local u = cmd_data.Info;
  u.TargetCoord.Xpos = 0;
  u.TargetCoord.Zpos = 0;
  u.TargetIdx:set(0);
  u.TIdxSize.CellsX = 0;
  u.TIdxSize.CellsZ = 0;
  u.TIdxSize.MapIdx = 0;
  u.TMIdxs.MapIdx = 0;
  u.TMIdxs.TargetIdx:set(0);
end

function cmd_clear_cache()
  for i,k in ipairs(cmd_data.Data) do
    k.CommandType = 0;
  end
  
  cmd_data.Count = 0;
  clear_target_cache();
end

function cmd_set_next_command(_cmd_type, _x, _z, _flags)
  if (cmd_data.Count < 8) then cmd_data.Count = cmd_data.Count + 1; else do return; end end
  
  clear_target_cache();
  
  local cmd = cmd_data.Data[cmd_data.Count];
  
  if (_cmd_type == 22) then
    c_xz.XZ.X = _x;
    c_xz.XZ.Z = _z;
    
    c_me = map_xz_to_map_ptr(c_xz);
    c_me.MapWhoList:processList(function(t)
      if (t.Type == 4) then
        cmd_data.Info.TargetIdx:set(t.ThingNum);
        cmd_data.Info.TMIdxs.MapIdx = c_xz.Pos;
        return false;
      end
      
      return true;
    end);
  end
  
  if (_cmd_type == 27) then
    c_xz.XZ.X = _x;
    c_xz.XZ.Z = _z;
    
    c_me = map_xz_to_map_ptr(c_xz);
    c_me.MapWhoList:processList(function(t)
      if (t.Type == 5) then
        if (t.Model == 9) then
          cmd_data.Info.TargetIdx:set(t.ThingNum);
          return false;
        end
      end
      
      return true;
    end);
  end
  
  if (_cmd_type == 8) then
    c_xz.XZ.X = _x;
    c_xz.XZ.Z = _z;
    
    c_me = map_xz_to_map_ptr(c_xz);
    if (not c_me.ShapeOrBldgIdx:isNull()) then
      c_thing = c_me.ShapeOrBldgIdx:get();
      if (c_thing.Type == T_BUILDING) then
        cmd_data.Info.TargetIdx:set(c_thing.ThingNum);
      end
    end
  end
  
  if (_cmd_type == 6 or _cmd_type == 10) then
    c_xz.XZ.X = _x;
    c_xz.XZ.Z = _z;
    
    c_me = map_xz_to_map_ptr(c_xz);
    if (not c_me.ShapeOrBldgIdx:isNull()) then
      cmd_data.Info.TMIdxs.TargetIdx:set(c_me.ShapeOrBldgIdx:getThingNum());
    end
    
    cmd_data.Info.TMIdxs.MapIdx = c_xz.Pos;
  end
  
  if (_cmd_type == 3 or _cmd_type == 7 or _cmd_type == 9 or _cmd_type == 13 or _cmd_type == 15 or _cmd_type == 17 or _cmd_type == 18 or _cmd_type == 23 or _cmd_type == 25) then
    cmd_data.Info.TargetCoord.Xpos = ((_x << 8) & 0xfe00);
    cmd_data.Info.TargetCoord.Zpos = ((_z << 8) & 0xfe00);
  end
  
  if (_cmd_type == 11 or  _cmd_type == 19) then
    c_xz.XZ.X = _x;
    c_xz.XZ.Z = _z;
    cmd_data.Info.TIdxSize.CellsX = 4;
    cmd_data.Info.TIdxSize.CellsZ = 4;
    cmd_data.Info.TIdxSize.MapIdx = c_xz.Pos;
  end
  
  update_cmd_list_entry(cmd, _cmd_type, cmd_data.Info, _flags);
end

function cmd_dispatch_commands(_t)
  remove_all_persons_commands(_t);
  
  for i = 1, cmd_data.Count do
    add_persons_command(_t, cmd_data.Data[i], i-1);
  end
  
  set_person_top_state(_t);
end