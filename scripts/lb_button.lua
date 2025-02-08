local btns = {};
local text_fields = {};
local icons = {};

function create_icon(bank_idx, sprite_idx)
  local i = {
    Pos = {0, 0},
    Spr = sprite_idx,
    BankNum = bank_idx,
    isActive = false
  }
  
  icons[#icons + 1] = i;
  
  return #icons;
end

function set_icon_active(idx)
  icons[idx].isActive = true;
end

function set_icon_position(idx, x, y)
  icons[idx].Pos[1] = x - (get_sprite(icons[idx].BankNum, icons[idx].Spr).Width >> 1);
  icons[idx].Pos[2] = y;
end

function draw_icons()
  for i = 1, #icons do
    local icon = icons[i];
    
    if (icon.isActive) then
      LbDraw_Sprite(icon.Pos[1], icon.Pos[2], get_sprite(icon.BankNum, icon.Spr));
    end
  end
end

function create_text_field(text, font_idx)
  local t = {
    Pos = {0, 0},
    Str = text,
    FontIdx = font_idx,
    isActive = false
  };
  
  text_fields[#text_fields + 1] = t;
  
  return #text_fields;
end

function set_text_field_position(idx, x, y)
  PopSetFont(text_fields[idx].FontIdx);
  local str_w = string_width(text_fields[idx].Str);
  text_fields[idx].Pos[1] = x - (str_w >> 1);
  text_fields[idx].Pos[2] = y;
end

function set_text_field_text(idx, text)
  text_fields[idx].Str = text;
end

function set_text_field_active(idx)
  text_fields[idx].isActive = true;
end

function set_text_field_inactive(idx)
  text_fields[idx].isActive = false;
end

function draw_text_fields()
  for i = 1, #text_fields do
    local t = text_fields[i];
    
    if (t.isActive) then
      PopSetFont(t.FontIdx);
      LbDraw_Text(t.Pos[1], t.Pos[2], t.Str, 0);
    end
  end
end

function get_button_pos_and_dimensions(idx)
  local b = btns[idx];
  local data = {}
  data[1] = b.Pos[1];
  data[2] = b.Pos[2];
  data[3] = b.Size[1];
  data[4] = b.Size[2];
  
  return data;
end

function create_button_array(font_idx, ls_n, ls_h, ls_hp)
  local button =
  {
    Type = BTN_TYPE_ARRAY,
    Pos = {0, 0},
    Size = {0, 0},
    Strs = {},
    FontIdx = font_idx,
    Styles = {ls_n, ls_h, ls_hp},
    Rect = TbRect.new(),
    CurrData = 1,
    MaxData = 1;
    LeftArrow = TbRect.new(),
    RightArrow = TbRect.new(),
    Func = nil,
    LAFunc = nil,
    RAFunc = nil,
    isPressed = false,
    isActive = false
  };
  
  btns[#btns + 1] = button;
  
  return #btns;
end

function set_array_button_text_table(idx, text_table)
  PopSetFont(btns[idx].FontIdx);
  local biggest_width = 0;
  
  for i = 1, #text_table do
    btns[idx].Strs[i] = text_table[i];
    biggest_width = math.max(biggest_width, string_width(text_table[i]));
  end
  
  btns[idx].Size[1] = biggest_width;
  btns[idx].Size[2] = CharHeight2();
  btns[idx].MaxData = #text_table;
end

function set_array_button_curr_value(idx, value)
  btns[idx].CurrData = value;
end

function set_array_button_position(idx, x, y)
  PopSetFont(btns[idx].FontIdx);
  btns[idx].Pos[1] = x;
  btns[idx].Pos[2] = y;
  
  btns[idx].Rect.Left = x;
  btns[idx].Rect.Right = btns[idx].Rect.Left + btns[idx].Size[1];
  btns[idx].Rect.Top = y;
  btns[idx].Rect.Bottom = btns[idx].Rect.Top + btns[idx].Size[2];
  expand_rectangle(btns[idx].Rect, 3);
  
  -- left arrow box
  btns[idx].LeftArrow.Left = x - (CharWidth2() << 1);
  btns[idx].LeftArrow.Right = btns[idx].LeftArrow.Left + CharWidth2();
  btns[idx].LeftArrow.Top = y;
  btns[idx].LeftArrow.Bottom = btns[idx].LeftArrow.Top + btns[idx].Size[2];
  
  -- right arrow box
  btns[idx].RightArrow.Left = x + btns[idx].Size[1] + (CharWidth2());
  btns[idx].RightArrow.Right = btns[idx].RightArrow.Left + CharWidth2();
  btns[idx].RightArrow.Top = y;
  btns[idx].RightArrow.Bottom = btns[idx].RightArrow.Top + btns[idx].Size[2];
end

function set_array_button_functions(idx, main_func, left_arrow_func, right_arrow_func)
  btns[idx].Func = main_func;
  btns[idx].LAFunc = left_arrow_func;
  btns[idx].RAFunc = right_arrow_func;
end

function create_button(text_str, font_idx, ls_n, ls_h, ls_hp)
  local button = 
  {
    Type = BTN_TYPE_NORMAL,
    Pos = {0, 0},
    Size = {0, 0},
    Str = text_str,
    FontIdx = font_idx,
    Styles = {ls_n, ls_h, ls_hp},
    Rect = TbRect.new(),
    Func = nil,
    isPressed = false,
    isActive = false
  };
  
  PopSetFont(font_idx);
  button.Size[1] = string_width(text_str);
  button.Size[2] = CharHeight2();
  
  btns[#btns + 1] = button;
  
  return #btns;
end

function get_button_ptr(idx)
  return btns[idx];
end

function set_button_position(idx, x, y)
  btns[idx].Pos[1] = x;
  btns[idx].Pos[2] = y;
  
  btns[idx].Rect.Left = x;
  btns[idx].Rect.Right = btns[idx].Rect.Left + btns[idx].Size[1];
  btns[idx].Rect.Top = y;
  btns[idx].Rect.Bottom = btns[idx].Rect.Top + btns[idx].Size[2];
  expand_rectangle(btns[idx].Rect, 3);
end

function set_button_function(idx, func)
  btns[idx].Func = func;
end

function set_button_active(idx)
  btns[idx].isActive = true;
end

function set_button_inactive(idx)
  btns[idx].isActive = false;
end

function draw_buttons()
  local mx, my = get_mouse_x(), get_mouse_y();
  for i = 1, #btns do
    local b = btns[i];
    if (b.isActive) then
      if (b.Type == BTN_TYPE_NORMAL) then
      
        PopSetFont(b.FontIdx);
        
        if (is_point_on_rectangle(b.Rect, mx, my)) then
          if (b.isPressed) then
            DrawStretchyButtonBox(b.Rect, b.Styles[3]);
          else
            DrawStretchyButtonBox(b.Rect, b.Styles[2]);
          end
        else
          DrawStretchyButtonBox(b.Rect, b.Styles[1]);
        end
        
        --log("" .. b.Str);
        LbDraw_Text(b.Pos[1], b.Pos[2], b.Str, 0);
      end
      
      if (b.Type == BTN_TYPE_ARRAY) then
      
        PopSetFont(b.FontIdx);
        
        if (is_point_on_rectangle(b.Rect, mx, my)) then
          if (b.isPressed) then
            DrawStretchyButtonBox(b.Rect, b.Styles[3]);
          else
            DrawStretchyButtonBox(b.Rect, b.Styles[2]);
          end
        else
          DrawStretchyButtonBox(b.Rect, b.Styles[1]);
        end
        
        if (is_point_on_rectangle(b.LeftArrow, mx, my)) then
          LbDraw_SetFlagsOn(LB_DRAW_FLAG_GLASS);
        end
        
        LbDraw_Text(b.LeftArrow.Left, b.Pos[2], "<", 0);
        LbDraw_SetFlagsOff(LB_DRAW_FLAG_GLASS);
        
        if (is_point_on_rectangle(b.RightArrow, mx, my)) then
          LbDraw_SetFlagsOn(LB_DRAW_FLAG_GLASS);
          LbDraw_Text(b.RightArrow.Left, b.Pos[2], ">", 0);
        end
        
        LbDraw_Text(b.RightArrow.Left, b.Pos[2], ">", 0);
        LbDraw_SetFlagsOff(LB_DRAW_FLAG_GLASS);
        
        --log("" .. b.Str);
        LbDraw_Text(b.Pos[1] + (b.Size[1] >> 1) - (string_width(b.Strs[b.CurrData]) >> 1), b.Pos[2], b.Strs[b.CurrData], 0);
      end
    end
  end
end

function process_buttons_input(is_down, x, y)
  for i = 1, #btns do
    local b = btns[i];
    if (b.isActive) then
      b.isPressed = false;
      
      if (b.Type == BTN_TYPE_NORMAL) then
        if (is_point_on_rectangle(b.Rect, x, y)) then
          if (is_down) then
            b.isPressed = true;
          else
            b.isPressed = false;
            
            if (b.Func) then
              b.Func(b);
            end
          end
        end
      end
      
      if (b.Type == BTN_TYPE_ARRAY) then
        if (is_point_on_rectangle(b.Rect, x, y)) then
          if (is_down) then
            b.isPressed = true;
          else
            b.isPressed = false;
            
            if (b.Func) then
              b.Func(b);
            end
          end
        end
        
        if (is_point_on_rectangle(b.LeftArrow, x, y)) then
          if (is_down) then
            if (b.LAFunc) then
              b.LAFunc(b);
            end
          end
        end
        
        if (is_point_on_rectangle(b.RightArrow, x, y)) then
          if (is_down) then
            if (b.RAFunc) then
              b.RAFunc(b);
            end
          end
        end
      end
    end
  end
end

function set_all_elements_inactive()
  for i,k in ipairs(btns) do
    k.isActive = false;
  end
  
  for i,k in ipairs(icons) do
    k.isActive = false;
  end
  
  for i,k in ipairs(text_fields) do
    k.isActive = false;
  end
end