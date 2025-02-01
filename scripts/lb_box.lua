-- library for managing TbRect with BorderLayouts

function create_rectangle(width, height, pos_x, pos_y)
  local t = TbRect.new();
  
  t.Left = pos_x;
  t.Right = pos_x + width;
  t.Top = pos_y;
  t.Bottom = pos_y + height;
  
  return t;
end

function expand_rectangle(rect, value)
  rect.Left = rect.Left - value;
  rect.Right = rect.Right + value;
  rect.Top = rect.Top - value;
  rect.Bottom = rect.Bottom + value;
end

function shrink_rectangle(rect, value)
  rect.Left = rect.Left + value;
  rect.Right = rect.Right - value;
  rect.Top = rect.Top + value;
  rect.Bottom = rect.Bottom - value;
end

function expand_rectangle_leftright(rect, value)
  rect.Left = rect.Left - value;
  rect.Right = rect.Right + value;
end

function is_point_on_rectangle(rect, x, y)
  return (x >= rect.Left and x <= rect.Right and y >= rect.Top and y <= rect.Bottom);
end


function create_layout(sprite_index_start)
  local t = BorderLayout.new();
  
  t.TopLeft = sprite_index_start;
  t.TopRight = t.TopLeft + 1;
  t.BottomLeft = t.TopLeft + 2;
  t.BottomRight = t.TopLeft + 3;
  t.Top = t.TopLeft + 4;
  t.Bottom = t.TopLeft + 5;
  t.Left = t.TopLeft + 6;
  t.Right = t.TopLeft + 7;
  t.Centre = t.TopLeft + 8;
  
  return t;
end