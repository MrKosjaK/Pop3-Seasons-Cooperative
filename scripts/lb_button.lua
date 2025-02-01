local btns = {};

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

function create_button(text_str, font_idx, ls_n, ls_h, ls_hp)
  local button = 
  {
    Pos = {0, 0},
    Size = {0, 0},
    Str = text_str,
    FontIdx = font_idx,
    Styles = {ls_n, ls_h, ls_hp},
    Rect = TbRect.new(),
    Func = nil,
    isPressed = false,
    isActive = true
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

function set_button_inactive(idx)
  btns[idx].isActive = false;
end

function draw_buttons()
  local mx, my = get_mouse_x(), get_mouse_y();
  for i = 1, #btns do
    local b = btns[i];
    if (b.isActive) then
    
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
  end
end

function process_buttons_input(is_down, x, y)
  for i = 1, #btns do
    local b = btns[i];
    if (b.isActive) then
      b.isPressed = false;
      
      if (is_point_on_rectangle(b.Rect, x, y)) then
        if (is_down) then
          b.isPressed = true;
        else
          b.isPressed = false;
          
          if (b.Func) then
            b.Func();
          end
        end
      end
    end
  end
end