local _menus = {};

function create_menu(header_text, ls)
  local menu =
  {
    Pos = {0, 0},
    Size = {0, 0},
    HeaderTitle = header_text,
    Rect = TbRect.new(),
    Style = ls,
    OpenFunc = nil,
    CloseFunc = nil,
    isOpen = false
  };
  
  _menus[#_menus + 1] = menu;
  return #_menus
end

function draw_menus()
  for i = 1, #_menus do
    local m = _menus[i];
    
    if (m.isOpen) then
      DrawStretchyButtonBox(m.Rect, m.Style);
      
      PopSetFont(9);
      local str_width = string_width(m.HeaderTitle);
      LbDraw_Text(m.Pos[1] + (m.Size[1] >> 1) - (str_width >> 1), m.Pos[2] - CharHeight2() - 3, m.HeaderTitle, 0);
    end
  end
end

function is_menu_open(idx)
  return (_menus[idx].isOpen == true);
end

function get_menu_pos_and_dimensions(idx)
  local m = _menus[idx];
  local data = {}
  data[1] = m.Pos[1];
  data[2] = m.Pos[2];
  data[3] = m.Size[1];
  data[4] = m.Size[2];
  
  return data;
end

function set_menu_position(idx, x, y)
  local m = _menus[idx];
  
  m.Pos[1] = x;
  m.Pos[2] = y;
  
  m.Rect.Left = x;
  m.Rect.Right = m.Rect.Left + m.Size[1];
  m.Rect.Top = y;
  m.Rect.Bottom = m.Rect.Top + m.Size[2];
end

function set_menu_dimensions(idx, w, h)
  local m = _menus[idx];
  
  m.Size[1] = w;
  m.Size[2] = h;
  
  m.Rect.Left = m.Pos[1];
  m.Rect.Right = m.Rect.Left + w;
  m.Rect.Top = m.Pos[2];
  m.Rect.Bottom = m.Rect.Top + h;
  expand_rectangle(m.Rect, 3);
end

function set_menu_position_and_dimensions(idx, x, y, w, h)
  local m = _menus[idx];

  m.Pos[1] = x;
  m.Pos[2] = y;
  m.Size[1] = w;
  m.Size[2] = h;
  
  m.Rect.Left = x;
  m.Rect.Right = m.Rect.Left + w;
  m.Rect.Top = y;
  m.Rect.Bottom = m.Rect.Top + h;
  expand_rectangle(m.Rect, 3);
end

function open_menu(idx)
  _menus[idx].isOpen = true;
  
  if (_menus[idx].OpenFunc ~= nil) then
    _menus[idx].OpenFunc(_menus[idx]);
  end
end

function close_menu(idx)
  _menus[idx].isOpen = false;
  
  if (_menus[idx].CloseFunc ~= nil) then
    _menus[idx].CloseFunc(_menus[idx]);
  end
end

function set_menu_open_function(idx, func)
  _menus[idx].OpenFunc = func;
end

function set_menu_close_function(idx, func)
  _menus[idx].CloseFunc = func;
end

function close_all_menus()
  for i,k in ipairs(_menus) do
    k.isOpen = false;
    
    if (k.CloseFunc ~= nil) then
    k.CloseFunc(k);
  end
  end
end