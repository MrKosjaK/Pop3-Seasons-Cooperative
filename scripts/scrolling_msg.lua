local MSGS_QUEUE = {};

FOOTER_STATE_AWAIT = 0;
FOOTER_STATE_FADE_IN = 1;
FOOTER_STATE_SCROLL_MSG = 2;
FOOTER_STATE_FADE_OUT = 3;
FOOTER_BOX_SIZE_X = 0.6;
FOOTER_BOX_SIZE_Y = 0.048;

local FLOOR = math.floor;

local FOOTER = 
{
  State = FOOTER_STATE_SCROLL_MSG,
  CurrText = nil,
  TextWidth = 0,
  Box = TbRect.new(),
  Pos = {0, 0},
  Size = {0, 0},
  OffsetPosX = 0
};

function auto_scale_footer_box()
  local sw = ScreenWidth();
  local sh = ScreenHeight();
  
  local f = FOOTER;
  
  local bottom_offset = FLOOR(0.05 * sh);
  
  f.Size[1] = FLOOR(FOOTER_BOX_SIZE_X * sw);
  f.Size[2] = FLOOR(FOOTER_BOX_SIZE_Y * sh);
  f.Pos[1] = (sw >> 1) - (f.Size[1] >> 1);
  f.Pos[2] = sh - bottom_offset - (f.Size[2] >> 1);
  
  if (f.CurrText ~= nil) then
    PopSetFont(GUI_TEXT_FONT);
    f.TextWidth = string_width(f.CurrText);
  
    local max_box_width = FLOOR(FOOTER_BOX_SIZE_X * sw)
    f.Size[1] = math.min(f.TextWidth + (CharWidth2() << 1), max_box_width);
    f.Pos[1] = (sw >> 1) - (f.Size[1] >> 1);
  end
  
  f.Box.Left = f.Pos[1];
  f.Box.Right = f.Box.Left + f.Size[1];
  f.Box.Top = f.Pos[2];
  f.Box.Bottom = f.Box.Top + f.Size[2];
  
  f.OffsetPosX = 0;
end

function footer_add_msg(str)
  local f = FOOTER;
  
  PopSetFont(GUI_TEXT_FONT);
  
  local sw = ScreenWidth();
  local sh = ScreenHeight();
  
  f.CurrText = str;
  f.TextWidth = string_width(str);
  
  local max_box_width = FLOOR(FOOTER_BOX_SIZE_X * sw)
  f.Size[1] = math.min(f.TextWidth + (CharWidth2() << 1), max_box_width);
  
  local bottom_offset = FLOOR(0.05 * sh);
  
  f.Pos[1] = (sw >> 1) - (f.Size[1] >> 1);
  f.Pos[2] = sh - bottom_offset - (f.Size[2] >> 1);
  
  f.Box.Left = f.Pos[1];
  f.Box.Right = f.Box.Left + f.Size[1];
  f.Box.Top = f.Pos[2];
  f.Box.Bottom = f.Box.Top + f.Size[2];
  
  f.OffsetPosX = 0;
end

function footer_draw_scrolling_msg()
  local f = FOOTER;
  
  if (f.State == FOOTER_STATE_SCROLL_MSG) then
    
    DrawStretchyButtonBox(f.Box, _BOX_LAYOUTS[BOX_STYLE.INNER_DARK]);
    
    LbDraw_SetClipRect(f.Box);
    
    if (f.CurrText ~= nil) then
      PopSetFont(GUI_TEXT_FONT);
      LbDraw_Text(f.Box.Right - f.OffsetPosX, f.Box.Top + (f.Size[2] >> 1) - (CharHeight2() >> 1), f.CurrText, 0);
    end
    
    
    if (f.OffsetPosX < (f.TextWidth << 1) + (CharWidth2() << 1)) then
      f.OffsetPosX = f.OffsetPosX + (CharWidth2() >> 2);
    end
    
    LbDraw_ReleaseClipRect();
  end
end