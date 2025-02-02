local btns = {};

-- button types
BTN_TYPE_NORMAL = 0;
BTN_TYPE_ARRAY = 1;

-- style defines
BTN_STYLE_BLUE = create_layout(879);
BTN_STYLE_BLUE_H = create_layout(888);
BTN_STYLE_BLUE_HP = create_layout(897);
BTN_STYLE_GRAY = create_layout(510); -- normal
BTN_STYLE_GRAY_H = create_layout(519); -- highlight
BTN_STYLE_GRAY_HP = create_layout(528); -- pressed
BTN_STYLE_DEFAULT = create_layout(794); -- normal
BTN_STYLE_DEFAULT_H = create_layout(803); -- highlight
BTN_STYLE_DEFAULT_HP = create_layout(812); -- pressed
BTN_STYLE_DEFAULT2 = create_layout(821); -- normal
BTN_STYLE_DEFAULT2_H = create_layout(830); -- highlight
BTN_STYLE_DEFAULT2_HP = create_layout(839); -- pressed
BTN_STYLE_DEFAULT3 = create_layout(848); -- normal
BTN_STYLE_DEFAULT3_H = create_layout(857); -- highlight
BTN_STYLE_DEFAULT3_HP = create_layout(866); -- pressed

function create_button_array(text_table, font_idx, max_num, ls_n, ls_h, ls_hp)
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
    MaxData = max_num;
    LeftArrow = TbRect.new(),
    RightArrow = TbRect.new(),
    Func = nil,
    isPressed = false,
    isActive = false
  };
  
  PopSetFont(font_idx);
  local biggest_width = 0;
  
  for i = 1, #text_table do
    button.Strs[i] = text_table[i];
    biggest_width = math.max(biggest_width, string_width(text_table[i]));
  end
  
  button.Size[1] = biggest_width;
  button.Size[2] = CharHeight2();
  
  btns[#btns + 1] = button;
  
  return #btns;
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
            b.CurrData = math.min(math.max(b.CurrData - 1, 1), b.MaxData);
          end
        end
        
        if (is_point_on_rectangle(b.RightArrow, x, y)) then
          if (is_down) then
            b.CurrData = math.min(math.max(b.CurrData + 1, 1), b.MaxData);
          end
        end
      end
    end
  end
end