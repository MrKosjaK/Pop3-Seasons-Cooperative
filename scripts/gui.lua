import(Module_Building);
import(Module_Commands);
import(Module_Control);
import(Module_DataTypes);
import(Module_Defines);
import(Module_Draw);
import(Module_Features);
import(Module_Game);
import(Module_Globals);
import(Module_Helpers);
import(Module_ImGui);
import(Module_Level);
import(Module_Map);
import(Module_MapWho);
import(Module_Math);
import(Module_Network);
import(Module_Objects);
import(Module_Person);
import(Module_Players);
import(Module_PopScript);
import(Module_Sound);
import(Module_Shapes);
import(Module_Spells);
import(Module_String);
import(Module_System);
import(Module_Table);

local GUI_MOUSE_POS = get_display_mouse_xy();
GUI_HOVERING_ID = -1;
GUI_TEXT_FONT = 4;

local FLOOR = math.floor;
local BOX_STYLE_SPRITE_INDEX =
{
  794,
  803,
  812,
  510,
  519,
  528,
  821,
  830,
  839,
  848,
  857,
  866,
  879,
  888,
  897,
  906,
  915,
  924,
  933,
  942,
  951,
  960,
  969,
  978,
  987,
  996,
  1005,
  1014,
  1615,
  1624,
  1633,
  1642,
  1651,
  1660,
  1669,
  1678,
  1687,
  1696,
  1705,
  1714,
  1794
}

BOX_STYLE = {
  DEFAULT_N = 1, -- 794 start
  DEFAULT_H = 2, -- 803 start
  DEFAULT_P = 3, -- 812 start 
  DEFAULT_GRAY_N = 4, -- 510 start
  DEFAULT_GRAY_H = 5, -- 519 start
  DEFAULT_GRAY_P = 6, -- 528 start
  DEFAULT2_N = 7, -- 821 start
  DEFAULT2_H = 8, -- 830 START
  DEFAULT2_P = 9, -- 839 START
  DEFAULT3_N = 10, -- 848 START
  DEFAULT3_H = 11, -- 857 START
  DEFAULT3_P = 12, -- 866 START
  BLUE_N = 13, -- 879 START
  BLUE_H = 14, -- 888 START
  BLUE_P = 15, -- 897 START
  RED_N = 16, -- 906 START
  RED_H = 17, -- 915 START
  RED_P = 18, -- 924 START
  YELLOW_N = 19, -- 933 START
  YELLOW_H = 20, -- 942 START
  YELLOW_P = 21, -- 951 START
  GREEN_N = 22, -- 960 START
  GREEN_H = 23, -- 969 START
  GREEN_P = 24, -- 978 START
  INNER_GREEN = 25, -- 987 START
  DEFAULT_SIMPLE_N = 26, -- 996 START
  DEFAULT_SIMPLE_H = 27, -- 1005 START
  DEFAULT_SIMPLE_P = 28, -- 1014 START
  CYAN_N = 29, -- 1615 START
  CYAN_H = 30, -- 1624 START
  CYAN_P = 31, -- 1633 START
  PURPLE_N = 32, -- 1642 START
  PURPLE_H = 33, -- 1651 START
  PURPLE_P = 34, -- 1660 START
  DARK_N = 35, -- 1669 START
  DARK_H = 36, -- 1678 START
  DARK_P = 37, -- 1687 START
  ORANGE_N = 38, -- 1696 START
  ORANGE_H = 39, -- 1705 START
  ORANGE_P = 40, -- 1714 START
  INNER_DARK = 41 -- 1794 START
}

local NUM_STYLES = 41;

local _BOX_LAYOUTS = {};

local function create_all_layouts()
  
  local function _apply_sprites(t, sprite_index_start)
    t.TopLeft = sprite_index_start;
    t.TopRight = t.TopLeft + 1;
    t.BottomLeft = t.TopLeft + 2;
    t.BottomRight = t.TopLeft + 3;
    t.Top = t.TopLeft + 4;
    t.Bottom = t.TopLeft + 5;
    t.Left = t.TopLeft + 6;
    t.Right = t.TopLeft + 7;
    t.Centre = t.TopLeft + 8;
  end
  
  for i = 1, NUM_STYLES do
    _BOX_LAYOUTS[i] = BorderLayout.new();
    _apply_sprites(_BOX_LAYOUTS[i], BOX_STYLE_SPRITE_INDEX[i]);
  end
  log("Registered layouts");
end

create_all_layouts(); -- registers layouts

ELEM_TYPE_NONE = 1;
ELEM_TYPE_PANEL = 2;
ELEM_TYPE_BUTTON = 3;
ELEM_TYPE_TEXT = 4;

-- Element enums
MY_ELEM_CHECK_IN_BACK = 1;
MY_ELEM_BTN_CHECK_IN = 2;
MY_ELEM_TXT_CHECK_IN1 = 3;
MY_ELEM_TXT_CHECK_IN2 = 4;
MY_ELEM_TXT_CHECK_IN3 = 5;
MY_ELEM_HUMAN_PLAYERS_BACK = 6;
MY_ELEM_COMP_PLAYERS_BACK = 7;
MY_ELEM_BTN_START_GAME = 8;
MY_ELEM_TXT_GAME_MASTER = 9;
MY_ELEM_TXT_HUMAN_PLAYERS = 10;
MY_ELEM_TXT_COMP_PLAYERS = 11;

-- Element justification
HJ_LEFT = 0;
HJ_CENTER = 1;
HJ_RIGHT = 2;

VJ_TOP = 0;
VJ_CENTER = 1;
VJ_BOTTOM = 2;

-- Menu enums
MY_MENU_CHECK_IN = 1;
MY_MENU_HUMAN_PLAYERS = 2;
MY_MENU_COMP_PLAYERS = 3;
MY_MENU_SETUP_GENERAL = 4;

local function gui_auto_scale_menu(menu)
  local sc_w = ScreenWidth();
  local sc_h = ScreenHeight();
  
  log(string.format("Width: %i, Height: %i", sc_w, sc_h));
  
  log("Auto scale in process");
  
  local init_menu = _GUI_INIT_MENUS[menu.ID];
  
  menu.Data.X = FLOOR(init_menu.Data.X * sc_w);
  menu.Data.Y = FLOOR(init_menu.Data.Y * sc_h);
  menu.Data.W = FLOOR(init_menu.Data.W * sc_w);
  menu.Data.H = FLOOR(init_menu.Data.H * sc_h);
  
  for i,elem in ipairs(menu.Elements) do
    if (elem.OnRes ~= nil) then
      elem.OnRes(elem);
    else
      local init_elem = _GUI_INIT_ELEMENTS[elem.ElemID];
      
      elem.Data.X = FLOOR(menu.Data.X + (init_elem.Data.X * menu.Data.W));
      elem.Data.Y = FLOOR(menu.Data.Y + (init_elem.Data.Y * menu.Data.H));
      elem.Data.W = FLOOR(init_elem.Data.W * sc_w);
      elem.Data.H = FLOOR(init_elem.Data.H * sc_h);
      
      if (elem.ElemType == ELEM_TYPE_TEXT) then
        PopSetFont(GUI_TEXT_FONT);
        elem.Data.W = string_width(elem.Text);
        elem.Data.H = CharHeight2();
      end
      
      -- check justification data
      if (init_elem.JustData.H == HJ_CENTER) then
        elem.Data.X = elem.Data.X - (elem.Data.W >> 1);
      elseif (init_elem.JustData.H == HJ_RIGHT) then
        elem.Data.X = elem.Data.X - elem.Data.W;
      end
      
      if (init_elem.JustData.V == VJ_CENTER) then
        elem.Data.Y = elem.Data.Y - (elem.Data.H >> 1);
      elseif (init_elem.JustData.V == VJ_BOTTOM) then
        elem.Data.Y = elem.Data.Y - elem.Data.H;
      end
      
      -- adjust box as well
      elem.Box.Left = elem.Data.X;
      elem.Box.Right = elem.Box.Left + elem.Data.W;
      elem.Box.Top = elem.Data.Y;
      elem.Box.Bottom = elem.Box.Top + elem.Data.H;
    end
  end
  
  log("Auto scale finished");
end

local function _gui_draw_basic_background(_elem)
  if (_elem.isActive) then
    local mx = GUI_MOUSE_POS.X;
    local my = GUI_MOUSE_POS.Y;
    
    if (mx >= _elem.Box.Left and mx < _elem.Box.Right and my >= _elem.Box.Top and my < _elem.Box.Bottom) then
      GUI_HOVERING_ID = _elem.ElemID;
    end
    
    DrawStretchyButtonBox(_elem.Box, _elem.Style);
  end
end

local function _gui_draw_basic_button(_elem)
  if (_elem.isActive) then
    local mx = GUI_MOUSE_POS.X;
    local my = GUI_MOUSE_POS.Y;
    
    if (is_point_on_rectangle(_elem.Box, mx, my)) then
      GUI_HOVERING_ID = _elem.ElemID;
      if (_elem.Pressed) then
        DrawStretchyButtonBox(_elem.Box,_elem.Style.P);
      else
        DrawStretchyButtonBox(_elem.Box, _elem.Style.H);
      end
    else
      DrawStretchyButtonBox(_elem.Box, _elem.Style.N);
    end
    
    PopSetFont(GUI_TEXT_FONT);
    
    LbDraw_Text(_elem.Box.Left + (_elem.Data.W >> 1) - (string_width(_elem.Text) >> 1), _elem.Box.Top + (_elem.Data.H >> 1) - (CharHeight2() >> 1), _elem.Text, 0);
  end
end

local function _gui_draw_basic_text(_elem)
  if (_elem.isActive) then
    local mx = GUI_MOUSE_POS.X;
    local my = GUI_MOUSE_POS.Y;
    
    if (is_point_on_rectangle(_elem.Box, mx, my)) then
      GUI_HOVERING_ID = _elem.ElemID;
    end
    
    PopSetFont(GUI_TEXT_FONT);
    
    LbDraw_Text(_elem.Data.X, _elem.Data.Y, _elem.Text, 0);
  end
end

local function _gui_maintain_basic_text(elem)
  local init_elem = _GUI_INIT_ELEMENTS[elem.ElemID];
  local menu = _GUI_MENUS[elem.MenuID];
  local sc_w = ScreenWidth();
  local sc_h = ScreenHeight();
  
  elem.Data.X = FLOOR(menu.Data.X + (init_elem.Data.X * menu.Data.W));
  elem.Data.Y = FLOOR(menu.Data.Y + (init_elem.Data.Y * menu.Data.H));
  elem.Data.W = FLOOR(init_elem.Data.W * sc_w);
  elem.Data.H = FLOOR(init_elem.Data.H * sc_h);
  
  if (elem.ElemType == ELEM_TYPE_TEXT) then
    PopSetFont(GUI_TEXT_FONT);
    elem.Data.W = string_width(elem.Text);
    elem.Data.H = CharHeight2();
  end
  
  -- check justification data
  if (init_elem.JustData.H == HJ_CENTER) then
    elem.Data.X = elem.Data.X - (elem.Data.W >> 1);
  elseif (init_elem.JustData.H == HJ_RIGHT) then
    elem.Data.X = elem.Data.X - elem.Data.W;
  end
  
  if (init_elem.JustData.V == VJ_CENTER) then
    elem.Data.Y = elem.Data.Y - (elem.Data.H >> 1);
  elseif (init_elem.JustData.V == VJ_BOTTOM) then
    elem.Data.Y = elem.Data.Y - elem.Data.H;
  end
  
  -- adjust box as well
  elem.Box.Left = elem.Data.X;
  elem.Box.Right = elem.Box.Left + elem.Data.W;
  elem.Box.Top = elem.Data.Y;
  elem.Box.Bottom = elem.Box.Top + elem.Data.H;
end

_GUI_INIT_ELEMENTS =
{
  -- Name -> X -> Y -> W -> H -> Horizontal Just -> Vertical Just
  [MY_ELEM_CHECK_IN_BACK] = 
  {
    Data = {X = 0.5, Y = 0.5, W = 0.32, H = 0.30},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    FuncDraw = _gui_draw_basic_background,
    StyleData = BOX_STYLE.INNER_DARK;
    OnRes = nil,
  }, -- 1
  
  [MY_ELEM_BTN_CHECK_IN] = 
  {
    Data = {X = 0.5, Y = 0.6, W = 0.12, H = 0.04},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    StyleData = {N = BOX_STYLE.DEFAULT2_N, H = BOX_STYLE.DEFAULT2_H, P = BOX_STYLE.DEFAULT2_P},
    Text = "Check In",
    FuncDraw = _gui_draw_basic_button,
    FuncClick = nil,
    OnRes = nil,
  }, -- 2
  
  [MY_ELEM_TXT_CHECK_IN1] = 
  {
    Data = {X = 0.5, Y = 0.40, W = 0.0, H = 0.0},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    Text = "Welcome to Seasons Cooperative!",
    FuncDraw = _gui_draw_basic_text,
    FuncMaintain = nil,
    OnRes = nil
  }, -- 3
  
  [MY_ELEM_TXT_CHECK_IN2] = 
  {
    Data = {X = 0.5, Y = 0.44, W = 0.0, H = 0.0},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    Text = "Click on 'Check In' button to sign in",
    FuncDraw = _gui_draw_basic_text,
    FuncMaintain = nil,
    OnRes = nil
  }, -- 4
  
  [MY_ELEM_TXT_CHECK_IN3] = 
  {
    Data = {X = 0.5, Y = 0.48, W = 0.0, H = 0.0},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    Text = "as a player for this mission.",
    FuncDraw = _gui_draw_basic_text,
    FuncMaintain = nil,
    OnRes = nil
  }, -- 5
  
  [MY_ELEM_HUMAN_PLAYERS_BACK] =
  {
    Data = {X = 0.0, Y = 0.0, W = 0.4, H = 0.6},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    FuncDraw = _gui_draw_basic_background,
    StyleData = BOX_STYLE.INNER_DARK;
    OnRes = nil,
  }, -- 6
  
  [MY_ELEM_COMP_PLAYERS_BACK] =
  {
    Data = {X = 0.0, Y = 0.0, W = 0.4, H = 0.6},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    FuncDraw = _gui_draw_basic_background,
    StyleData = BOX_STYLE.INNER_DARK;
    OnRes = nil,
  }, -- 7
  
  [MY_ELEM_BTN_START_GAME] =
  {
    Data = {X = 0.5, Y = 0.9, W = 0.12, H = 0.04},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    StyleData = {N = BOX_STYLE.DEFAULT2_N, H = BOX_STYLE.DEFAULT2_H, P = BOX_STYLE.DEFAULT2_P},
    Text = "Start Game",
    FuncDraw = _gui_draw_basic_button,
    FuncClick = nil,
    OnRes = nil,
  }, -- 8
  
  [MY_ELEM_TXT_GAME_MASTER] =
  {
    Data = {X = 0.5, Y = 0.16, W = 0.0, H = 0.0},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    Text = "Game Master",
    FuncDraw = _gui_draw_basic_text,
    FuncMaintain = _gui_maintain_basic_text,
    OnRes = nil
  }, -- 9
  
  [MY_ELEM_TXT_HUMAN_PLAYERS] =
  {
    Data = {X = 0.0, Y = -0.40, W = 0.0, H = 0.0},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    Text = "Player Squad",
    FuncDraw = _gui_draw_basic_text,
    FuncMaintain = nil,
    OnRes = nil
  }, -- 10
  
  [MY_ELEM_TXT_COMP_PLAYERS] =
  {
    Data = {X = 0.0, Y = -0.40, W = 0.0, H = 0.0},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    Text = "Stupid Bots",
    FuncDraw = _gui_draw_basic_text,
    FuncMaintain = nil,
    OnRes = nil
  }, -- 11
}

_GUI_MENU_INIT_ELEMENTS =
{
  [MY_MENU_CHECK_IN] = 
  {
    {ELEM_TYPE_PANEL, MY_ELEM_CHECK_IN_BACK},
    {ELEM_TYPE_BUTTON, MY_ELEM_BTN_CHECK_IN},
    {ELEM_TYPE_TEXT, MY_ELEM_TXT_CHECK_IN1},
    {ELEM_TYPE_TEXT, MY_ELEM_TXT_CHECK_IN2},
    {ELEM_TYPE_TEXT, MY_ELEM_TXT_CHECK_IN3},
  },
  
  [MY_MENU_HUMAN_PLAYERS] = 
  {
    {ELEM_TYPE_PANEL, MY_ELEM_HUMAN_PLAYERS_BACK},
    {ELEM_TYPE_TEXT, MY_ELEM_TXT_HUMAN_PLAYERS},
  },
  
  [MY_MENU_COMP_PLAYERS] = 
  {
    {ELEM_TYPE_PANEL, MY_ELEM_COMP_PLAYERS_BACK},
    {ELEM_TYPE_TEXT, MY_ELEM_TXT_COMP_PLAYERS},
  },
  
  [MY_MENU_SETUP_GENERAL] =
  {
   {ELEM_TYPE_BUTTON, MY_ELEM_BTN_START_GAME}, 
   {ELEM_TYPE_TEXT, MY_ELEM_TXT_GAME_MASTER},
  }
}

_GUI_INIT_MENUS =
{
  [MY_MENU_CHECK_IN] = 
  {
    ID = MY_MENU_CHECK_IN,
    Data = {X = 0.0, Y = 0.0, W = 1.0, H = 1.0},
    FuncOpen = nil,
    FuncClose = nil,
    OnRes = gui_auto_scale_menu,
  },
  
  [MY_MENU_HUMAN_PLAYERS] =
  {
    ID = MY_MENU_HUMAN_PLAYERS,
    Data = {X = 0.25, Y = 0.5, W = 0.4, H = 0.6},
    FuncOpen = nil,
    FuncClose = nil,
    OnRes = gui_auto_scale_menu,
  },
  
  [MY_MENU_COMP_PLAYERS] =
  {
    ID = MY_MENU_COMP_PLAYERS,
    Data = {X = 0.75, Y = 0.5, W = 0.4, H = 0.6},
    FuncOpen = nil,
    FuncClose = nil,
    OnRes = gui_auto_scale_menu,
  },
  
  [MY_MENU_SETUP_GENERAL] =
  {
    ID = MY_MENU_SETUP_GENERAL,
    Data = {X = 0.0, Y = 0.0, W = 1.0, H = 1.0},
    FuncOpen = nil,
    FuncClose = nil,
    OnRes = gui_auto_scale_menu,
  }
}

_GUI_MENUS = 
{
  
}

_GUI_ELEMENTS =
{

}

CURR_RES_WIDTH = 0;
CURR_RES_HEIGHT = 0;

local function _create_elem_button(_menu_ptr, _elem_ptr, _elem_ptr_idx, _sw, _sh, _mx, _my, _mw, _mh)
  -- now convert position & scale data into actual pixels and transform it into correct position
  local elem_x = FLOOR(_mx + (_elem_ptr.Data.X * _mw));
  local elem_y = FLOOR(_my + (_elem_ptr.Data.Y * _mh));
  local elem_w = FLOOR(_elem_ptr.Data.W * _sw);
  local elem_h = FLOOR(_elem_ptr.Data.H * _sh);
  
  -- check justification data
  if (_elem_ptr.JustData.H == HJ_CENTER) then
    elem_x = elem_x - (elem_w >> 1);
  elseif (_elem_ptr.JustData.H == HJ_RIGHT) then
    elem_x = elem_x - elem_w;
  end
  
  if (_elem_ptr.JustData.V == VJ_CENTER) then
    elem_y = elem_y - (elem_h >> 1);
  elseif (_elem_ptr.JustData.V == VJ_BOTTOM) then
    elem_y = elem_y - elem_h;
  end
  
  _GUI_ELEMENTS[_elem_ptr_idx] = 
  {
    ElemType = ELEM_TYPE_BUTTON,
    ElemID = _elem_ptr_idx,
    MenuID = _menu_ptr.ID,
    Data = { X = elem_x, Y = elem_y, W = elem_w, H = elem_h},
    Style = {N = _BOX_LAYOUTS[_elem_ptr.StyleData.N], H = _BOX_LAYOUTS[_elem_ptr.StyleData.H], P = _BOX_LAYOUTS[_elem_ptr.StyleData.P]},
    Text = _elem_ptr.Text,
    FuncDraw = _elem_ptr.FuncDraw,
    FuncClick = _elem_ptr.FuncClick,
    Pressed = false,
    Box = TbRect.new(),
    isActive = false
  };
  
  local e_b = _GUI_ELEMENTS[_elem_ptr_idx].Box;
  e_b.Left = elem_x;
  e_b.Right = e_b.Left + elem_w;
  e_b.Top = elem_y;
  e_b.Bottom = e_b.Top + elem_h;
  
  -- add element to menu
  local actual_menu_elements = _GUI_MENUS[_menu_ptr.ID].Elements;
  actual_menu_elements[#actual_menu_elements + 1] = _GUI_ELEMENTS[_elem_ptr_idx];
  
  log("Created button element");
end

local function _create_elem_text(_menu_ptr, _elem_ptr, _elem_ptr_idx, _sw, _sh, _mx, _my, _mw, _mh)
  -- now convert position & scale data into actual pixels and transform it into correct position
  local elem_x = FLOOR(_mx + (_elem_ptr.Data.X * _mw));
  local elem_y = FLOOR(_my + (_elem_ptr.Data.Y * _mh));
  
  -- width and height are dynamically calculated depending on current font.
  PopSetFont(GUI_TEXT_FONT);
  local text_width = string_width(_elem_ptr.Text);
  local elem_w = text_width;
  local elem_h = CharHeight2();
  
  -- check justification data
  if (_elem_ptr.JustData.H == HJ_CENTER) then
    elem_x = elem_x - (elem_w >> 1);
  elseif (_elem_ptr.JustData.H == HJ_RIGHT) then
    elem_x = elem_x - elem_w;
  end
  
  if (_elem_ptr.JustData.V == VJ_CENTER) then
    elem_y = elem_y - (elem_h >> 1);
  elseif (_elem_ptr.JustData.V == VJ_BOTTOM) then
    elem_y = elem_y - elem_h;
  end
  
  _GUI_ELEMENTS[_elem_ptr_idx] = 
  {
    ElemType = ELEM_TYPE_TEXT,
    ElemID = _elem_ptr_idx,
    MenuID = _menu_ptr.ID,
    Data = { X = elem_x, Y = elem_y, W = elem_w, H = elem_h},
    Text = _elem_ptr.Text,
    FuncDraw =  _elem_ptr.FuncDraw,
    FuncMaintain = _elem_ptr.FuncMaintain,
    Box = TbRect.new(),
    isActive = false
  };
  
  local e_b = _GUI_ELEMENTS[_elem_ptr_idx].Box;
  e_b.Left = elem_x;
  e_b.Right = e_b.Left + elem_w;
  e_b.Top = elem_y;
  e_b.Bottom = e_b.Top + elem_h;
  
  -- add element to menu
  local actual_menu_elements = _GUI_MENUS[_menu_ptr.ID].Elements;
  actual_menu_elements[#actual_menu_elements + 1] = _GUI_ELEMENTS[_elem_ptr_idx];
  
  log("Created text element");
end

local function _create_elem_panel(_menu_ptr, _elem_ptr, _elem_ptr_idx, _sw, _sh, _mx, _my, _mw, _mh)
  -- now convert position & scale data into actual pixels and transform it into correct position
  local elem_x = FLOOR(_mx + (_elem_ptr.Data.X * _mw));
  local elem_y = FLOOR(_my + (_elem_ptr.Data.Y * _mh));
  local elem_w = FLOOR(_elem_ptr.Data.W * _sw);
  local elem_h = FLOOR(_elem_ptr.Data.H * _sh);
  
  -- check justification data
  if (_elem_ptr.JustData.H == HJ_CENTER) then
    elem_x = elem_x - (elem_w >> 1);
  elseif (_elem_ptr.JustData.H == HJ_RIGHT) then
    elem_x = elem_x - elem_w;
  end
  
  if (_elem_ptr.JustData.V == VJ_CENTER) then
    elem_y = elem_y - (elem_h >> 1);
  elseif (_elem_ptr.JustData.V == VJ_BOTTOM) then
    elem_y = elem_y - elem_h;
  end
  
  _GUI_ELEMENTS[_elem_ptr_idx] = 
  {
    ElemType = ELEM_TYPE_PANEL,
    ElemID = _elem_ptr_idx,
    MenuID = _menu_ptr.ID,
    Data = { X = elem_x, Y = elem_y, W = elem_w, H = elem_h},
    FuncDraw =  _elem_ptr.FuncDraw,
    Style = _BOX_LAYOUTS[_elem_ptr.StyleData];
    Box = TbRect.new(),
    isActive = false
  };
  
  local e_b = _GUI_ELEMENTS[_elem_ptr_idx].Box;
  e_b.Left = elem_x;
  e_b.Right = e_b.Left + elem_w;
  e_b.Top = elem_y;
  e_b.Bottom = e_b.Top + elem_h;
  
  -- add element to menu
  local actual_menu_elements = _GUI_MENUS[_menu_ptr.ID].Elements;
  actual_menu_elements[#actual_menu_elements + 1] = _GUI_ELEMENTS[_elem_ptr_idx];
  
  log("Created panel element");
end

function gui_close_menu(_menu_id)
  local menu = _GUI_MENUS[_menu_id];
  
  if (menu ~= nil) then
    menu.isActive = false;
    
    if (menu.FuncClose ~= nil) then
      menu.FuncClose(menu);
    else
      for i,elem_entry in ipairs(menu.Elements) do
        elem_entry.isActive = false;
      end
    end
  end
end

function gui_init_all_menus()
  for i,menu in ipairs(_GUI_INIT_MENUS) do
    local sc_w = ScreenWidth();
    local sc_h = ScreenHeight();
    
    local m_x = FLOOR(menu.Data.X * sc_w);
    local m_y = FLOOR(menu.Data.Y * sc_h);
    local m_w = FLOOR(menu.Data.W * sc_w);
    local m_h = FLOOR(menu.Data.H * sc_h);
    
    
    
    _GUI_MENUS[menu.ID] = 
    {
      ID = menu.ID,
      Data = { X = m_x, Y = m_y, W = m_w, H = m_h},
      Elements = {}, -- Pointers to elements
      FuncOpen = menu.FuncOpen,
      FuncClose = menu.FuncClose,
      OnRes = menu.OnRes,
      isActive = false
    };
    
    log("Created Menu");
    
    -- now go through elements that menu consists of and see if they need to be created/binded
    local init_menu_elems = _GUI_MENU_INIT_ELEMENTS[menu.ID];
    
    for index,elem_entry in ipairs(init_menu_elems) do
      local elem_type = elem_entry[1];
      local elem_ptr_idx = elem_entry[2];
      
      local elem_ptr = _GUI_ELEMENTS[elem_ptr_idx];
      
      if (elem_ptr == nil) then
        -- create it.
        elem_ptr = _GUI_INIT_ELEMENTS[elem_ptr_idx];
        
        if (elem_ptr ~= nil) then
          -- now check it's type and create stuff accordingly
          
          if (elem_type == ELEM_TYPE_NONE) then
          
          elseif (elem_type == ELEM_TYPE_PANEL) then
            _create_elem_panel(menu, elem_ptr, elem_ptr_idx, sc_w, sc_h, m_x, m_y, m_w, m_h);
          elseif (elem_type == ELEM_TYPE_BUTTON) then
            _create_elem_button(menu, elem_ptr, elem_ptr_idx, sc_w, sc_h, m_x, m_y, m_w, m_h);
          elseif (elem_type == ELEM_TYPE_TEXT) then
            _create_elem_text(menu, elem_ptr, elem_ptr_idx, sc_w, sc_h, m_x, m_y, m_w, m_h);
          end
          
        end
      end
    end
  end
end

function gui_open_menu(_menu_id)
  local menu = _GUI_MENUS[_menu_id];
  
  if (menu ~= nil) then
    menu.isActive = true;
    
    if (menu.FuncOpen ~= nil) then
      menu.FuncOpen(menu);
    else
      for i,elem_entry in ipairs(menu.Elements) do
        elem_entry.isActive = true;
      end
    end
  end
end

function gui_draw_menus()
  for i,menu in ipairs(_GUI_MENUS) do
    if (menu.isActive) then
      LbDraw_SetViewPort(menu.Box);
      LbDraw_SetClipRect(menu.Box);
      for j,elem in ipairs(menu.Elements) do
        if (elem.FuncDraw ~= nil) then
          elem.FuncDraw(elem);
        end
      end
      LbDraw_ReleaseViewPort();
      LbDraw_ReleaseClipRect();
    end
  end
end

function process_gui_mouse_inputs(key, is_down, x, y)
  for i,menu in ipairs(_GUI_MENUS) do
    if (menu.isActive) then
      for j,elem in ipairs(menu.Elements) do
        if (elem.isActive) then
          if (elem.ElemType == ELEM_TYPE_BUTTON) then
            elem.Pressed = false;
            if (is_point_on_rectangle(elem.Box, x, y)) then
              if (is_down) then
                elem.Pressed = true;
              else
                elem.Pressed = false;
                --log("clicked");
                if (elem.FuncClick ~= nil) then
                  elem.FuncClick();
                end
              end
            end
          end
        end
      end
    end
  end
end

-- function OnMouseButton(key, is_down, x, y)
  -- if (key == LB_KEY_MOUSE0) then
    -- -- left click
    -- for i,menu in ipairs(_GUI_MENUS) do
      -- if (menu.isActive) then
        -- for j,elem in ipairs(menu.Elements) do
          -- if (elem.isActive) then
            -- if (elem.ElemType == ELEM_TYPE_BUTTON) then
              -- elem.Pressed = false;
              -- if (is_point_on_rectangle(elem.Box, x, y)) then
                -- if (is_down) then
                  -- elem.Pressed = true;
                -- else
                  -- elem.Pressed = false;
                  -- --log("clicked");
                  -- if (elem.FuncClick ~= nil) then
                    -- elem.FuncClick();
                  -- end
                -- end
              -- end
            -- end
          -- end
        -- end
      -- end
    -- end
  -- end
-- end


-- function OnFrame()
  -- if (CURR_RES_HEIGHT ~= ScreenHeight() or CURR_RES_WIDTH ~= ScreenWidth()) then
    -- -- reapply resolution
    -- CURR_RES_HEIGHT = ScreenHeight();
    -- CURR_RES_WIDTH = ScreenWidth();
    -- log("res changed");
    
    -- if (CURR_RES_WIDTH >= 1920 and CURR_RES_HEIGHT >= 1080) then
      -- GUI_TEXT_FONT = 9;
    -- elseif (CURR_RES_WIDTH >= 1280 and CURR_RES_HEIGHT >= 720) then
      -- GUI_TEXT_FONT = 3;
    -- else
      -- GUI_TEXT_FONT = 4;
    -- end
    
    -- -- go through all created menus and trigger their OnRes function
    -- for i,menu in ipairs(_GUI_MENUS) do
      -- log("is type: " .. type(menu.OnRes));
      -- if (menu.OnRes ~= nil) then
        -- menu.OnRes(menu);
      -- end
    -- end
  -- end
  
  -- local gui_width = GFGetGuiWidth();
  
  -- if (am_i_not_in_igm()) then
    -- gui_draw_menus();
  -- end
  
  -- PopSetFont(GUI_TEXT_FONT);
  -- LbDraw_Text(gui_width, ScreenHeight() - CharHeight2(), string.format("GUI ID: %i", GUI_HOVERING_ID), 0);
  
  -- GUI_HOVERING_ID = -1;
-- end

function get_elem_ptr(_elem_idx)
  return _GUI_ELEMENTS[_elem_idx];
end

function set_elem_text_string(_elem_idx, _str)
  local txt = _GUI_ELEMENTS[_elem_idx];
  
  if (txt ~= nil) then
    if (txt.ElemType == ELEM_TYPE_TEXT) then
      txt.Text = _str;
      
      if (txt.FuncMaintain ~= nil) then
        txt.FuncMaintain(txt);
        log("maintain");
      end
    end
  end
end

function set_elem_btn_function(_elem_idx, _func)
  local btn = _GUI_ELEMENTS[_elem_idx];
  
  if (btn ~= nil) then
    if (btn.ElemType == ELEM_TYPE_BUTTON) then
      btn.FuncClick = _func;
    end
  end
end