local _text_boxes = {};

function create_text_box(font, box_style)
  local menu =
  {
    Pos = {0, 0},
    Size = {0, 0},
    Lines = {},
    MaxNumLines = 0,
    Rect = TbRect.new(),
    Style = box_style,
    isActive = false
  };
  
  _text_boxes[#_text_boxes + 1] = menu;
  return #_text_boxes;
end

function get_text_box_pos_and_dimensions(idx)
  local b = _text_boxes[idx];
  local data = {}
  data[1] = b.Pos[1];
  data[2] = b.Pos[2];
  data[3] = b.Size[1];
  data[4] = b.Size[2];
  
  return data;
end

function draw_text_boxes()
  for i = 1, #_text_boxes do
    local m = _text_boxes[i];
    
    if (m.isActive) then
      DrawStretchyButtonBox(m.Rect, m.Style);
    end
  end
end

function set_text_box_active(idx)
  _text_boxes[idx].isActive = true;
end

function set_text_box_inactive(idx)
  _text_boxes[idx].isActive = false;
end

function set_text_box_pos_and_dimensions(idx, x, y, w, h)
  _text_boxes[idx].Pos[1] = x;
  _text_boxes[idx].Pos[2] = y;
  _text_boxes[idx].Size[1] = w;
  _text_boxes[idx].Size[2] = h;
  
  _text_boxes[idx].Rect.Left = x;
  _text_boxes[idx].Rect.Right = _text_boxes[idx].Rect.Left + _text_boxes[idx].Size[1];
  _text_boxes[idx].Rect.Top = y;
  _text_boxes[idx].Rect.Bottom = _text_boxes[idx].Rect.Top + _text_boxes[idx].Size[2];
  expand_rectangle(_text_boxes[idx].Rect, 3);
end