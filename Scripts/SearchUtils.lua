function GetPlayerAreaInfo(player, x, z, rad, tabl)
  if (tabl == nil or type(tabl) ~= "table") then
    return;
  end

  tabl["People"] = {};
  tabl["Bldgs"] = {};

  for i = 1, 8 do
    tabl["People"][i] = 0;
  end

  for j = 1, 19 do
    tabl["Bldgs"][j] = 0;
  end

  SearchMapCells(SQUARE, 0, 0, rad, map_xz_to_map_idx(x, z), function(me)
    me.MapWhoList:processList(function(t)
      if (t.Owner ~= player) then
        return true;
      end

      if (t.Type == T_PERSON) then
        tabl["People"][t.Model] = tabl["People"][t.Model] + 1;
        return true;
      end

      if (t.Type == T_BUILDING) then
        tabl["Bldgs"][t.Model] = tabl["Bldgs"][t.Model] + 1;
        return true;
      end
    end);
    return true;
  end);
end
