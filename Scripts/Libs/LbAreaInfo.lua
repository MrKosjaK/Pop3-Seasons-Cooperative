local m_xz = MapPosXZ.new();

function create_area_info()
  local t =
  {
    -- T_PERSON
    [1] = { 0, 0, 0, 0, 0, 0, 0, 0 },
    
    -- T_BUILDING
    [2] = { 0, 0, 0, 0, 0, 0, 0, 0 },
    
    isEmpty = true,
    hasPeople = false,
    hasBlgds = false,
    hasEnemy = false,
    hasAlly = false,
  };
  
  return t;
end

function clear_area_info(area_info)
  for i,k in ipairs(area_info[1]) do
    area_info[1][i] = 0;
  end
  
  for i,k in ipairs(area_info[2]) do
    area_info[1][i] = 0;
  end
  
  area_info.isEmpty = true;
  area_info.hasPeople = false;
  area_info.hasBlgds = false;
  area_info.hasEnemy = false;
  area_info.hasAlly = false;
end

function get_enemy_area_info(self_owner, x, z, r, area_info)
  m_xz.XZ.X = x;
  m_xz.XZ.Z = z;
  
  SearchMapCells(SQUARE, 0, 0, r, m_xz.Pos, function(me)
    me.MapWhoList:processList(function(t)
      if (are_players_allied(self_owner, t.Owner) == 1) then
        return true;
      end
      
      if (t.Type == 1) then
        if (is_person_selectable(t) == 1) then
          area_info[1][t.Model] = area_info[1][t.Model] + 1;
          area_info.hasPeople = true;
          area_info.hasEnemy = true;
          area_info.isEmpty = false;
          return true;
        end
      end
      
      if (t.Type == 2) then
        area_info[2][t.Model] = area_info[2][t.Model] + 1;
        area_info.hasBlgds = true;
        area_info.hasEnemy = true;
        area_info.isEmpty = false;
        return true;
      end
      
      return true;
    end);
    return true;
  end);
end

function is_area_empty(area_info)
  return (area_info.isEmpty);
end

function does_area_contain_people(area_info)
  return (area_info.hasPeople);
end

function does_area_contain_bldgs(area_info)
  return (area_info.hasBlgds);
end

function does_area_contain_enemy(area_info)
  return (area_info.hasEnemy);
end

function does_area_contain_ally(area_info)
  return (area_info.hasAlly);
end

