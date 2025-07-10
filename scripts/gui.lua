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

local FLOOR = math.floor;

ELEM_TYPE_NONE = 1;
ELEM_TYPE_PANEL = 2;
ELEM_TYPE_BUTTON = 3;

MY_ELEM_BACKGROUND = 1;
MY_ELEM_BTN_CHECK_IN = 2;

HJ_LEFT = 0;
HJ_CENTER = 1;
HJ_RIGHT = 2;

VJ_TOP = 0;
VJ_CENTER = 1;
VJ_BOTTOM = 2;

MY_MENU_CHECK_IN = 1;
MY_MENU_PLAYERS = 2;

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
      
      elem.Data.X = FLOOR(menu.Data.X + (init_elem.Data.X * sc_w));
      elem.Data.Y = FLOOR(menu.Data.Y + (init_elem.Data.Y * sc_h));
      elem.Data.W = FLOOR(init_elem.Data.W * sc_w);
      elem.Data.H = FLOOR(init_elem.Data.H * sc_h);
      
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
    LbDraw_Rectangle(_elem.Box, 130);
  end
end

_GUI_INIT_ELEMENTS =
{
  -- Name -> X -> Y -> W -> H -> Horizontal Just -> Vertical Just
  [MY_ELEM_BACKGROUND] = 
  {
    Data = {X = 0.5, Y = 0.5, W = 0.21, H = 0.12},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    FuncDraw = _gui_draw_basic_background,
    OnRes = nil,
  }, -- 1
  
  [MY_ELEM_BTN_CHECK_IN] = 
  {
    Data = {X = 0.5, Y = 0.5, W = 0.09, H = 0.04},
    JustData = {H = HJ_CENTER, V = VJ_CENTER},
    OnRes = nil,
  }, -- 2
}

_GUI_MENU_INIT_ELEMENTS =
{
  [MY_MENU_CHECK_IN] = 
  {
    {ELEM_TYPE_PANEL, MY_ELEM_BACKGROUND},
    {ELEM_TYPE_BUTTON, MY_ELEM_BTN_CHECK_IN}
  }
}

_GUI_INIT_MENUS =
{
  [MY_MENU_CHECK_IN] = 
  {
    ID = MY_MENU_CHECK_IN,
    Data = {X = 0.0, Y = 0.0, W = 1.0, H = 1.0},
    FuncOpen = gui_open_main_menu,
    FuncClose = gui_close_main_menu,
    FuncMaintain = gui_maintain_main_menu,
    OnRes = gui_auto_scale_menu,
  }
}

_GUI_MENUS = 
{
  
}

_GUI_ELEMENTS =
{

}




local start_turn = getTurn();

CURR_RES_WIDTH = 0;
CURR_RES_HEIGHT = 0;

function OnTurn()
  local turn = getTurn();
  
  if (turn == (start_turn + 1)) then
    -- cache width and height res
    CURR_RES_HEIGHT = ScreenHeight();
    CURR_RES_WIDTH = ScreenWidth();
    
    gui_open_menu(MY_MENU_CHECK_IN);
  end
  
  if ((turn + 1) % 2 == 0) then
    if G_RANDOM(2) == 0 then
      gui_close_menu(MY_MENU_CHECK_IN);
    else
      gui_open_menu(MY_MENU_CHECK_IN);
    end
  end
end

local function _create_elem_panel(_menu_ptr, _elem_ptr, _elem_ptr_idx, _sw, _sh, _mx, _my, _mw, _mh)
-- now convert position & scale data into actual pixels and transform it into correct position
  local elem_x = FLOOR(_mx + (_elem_ptr.Data.X * _sw));
  local elem_y = FLOOR(_my + (_elem_ptr.Data.Y * _sh));
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
    ElemID = _elem_ptr_idx,
    MenuID = _menu_ptr.ID,
    Data = { X = elem_x, Y = elem_y, W = elem_w, H = elem_h},
    FuncDraw =  _elem_ptr.FuncDraw,
    Box = TbRect.new(),
    isActive = true
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

function gui_open_menu(_menu_id)
  local menu = _GUI_MENUS[_menu_id];
  
  if (menu == nil) then
    -- create elements
    local menu = _GUI_INIT_MENUS[_menu_id];
    
    if (menu ~= nil) then
      local sc_w = ScreenWidth();
      local sc_h = ScreenHeight();
      
      local m_x = FLOOR(menu.Data.X * sc_w);
      local m_y = FLOOR(menu.Data.Y * sc_h);
      local m_w = FLOOR(menu.Data.W * sc_w);
      local m_h = FLOOR(menu.Data.H * sc_h);
      
      
      
      _GUI_MENUS[_menu_id] = 
      {
        ID = menu.ID,
        Data = { X = m_x, Y = m_y, W = m_w, H = m_h},
        Elements = {}, -- Pointers to elements
        FuncOpen = menu.FuncOpen,
        FuncClose = menu.FuncClose,
        FuncMaintain = menu.FuncMaintain,
        OnRes = menu.OnRes,
        isActive = true
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
            
            end
            
          end
        end
      end
    else
      log("TRIED TO CREATE UNKNOWN MENU");
    end
  else
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
      for j,elem in ipairs(menu.Elements) do
        if (elem.FuncDraw ~= nil) then
          elem.FuncDraw(elem);
        end
      end
    end
  end
end

function gui_init_all()
  local current_screen_width = ScreenWidth();
  local current_screen_height = ScreenHeight();
  
  --log(string.format("W: %.2f H: %.2f", percent_w, percent_h));
  
  for i,elem in ipairs(_GUI_INIT_ELEMENTS) do
    local e_x = FLOOR((elem[1] * current_screen_width));
    local e_y = FLOOR((elem[2] * current_screen_height));
    local e_w = FLOOR((elem[3] * current_screen_width));
    local e_h = FLOOR((elem[4] * current_screen_height));
    local rect = TbRect.new();
    rect.Left = e_x;
    rect.Right = rect.Left + e_w;
    rect.Top = e_y;
    rect.Bottom = rect.Top + e_h;
    
     log(string.format("X: %d, Y: %d, W: %d H: %d", e_x, e_y, e_w, e_h));
     _GUI_ELEMENTS[i] = 
     {
      Data = {X = e_x, Y = e_y, W = e_w, H = e_h, Rect = rect}
     };
  end
end




function OnFrame()
  if (CURR_RES_HEIGHT ~= ScreenHeight() or CURR_RES_WIDTH ~= ScreenWidth()) then
    -- reapply resolution
    CURR_RES_HEIGHT = ScreenHeight();
    CURR_RES_WIDTH = ScreenWidth();
    log("res changed");
    
    -- go through all created menus and trigger their OnRes function
    for i,menu in ipairs(_GUI_MENUS) do
      log("is type: " .. type(menu.OnRes));
      if (menu.OnRes ~= nil) then
        menu.OnRes(menu);
      end
    end
    
    -- go through all elements and resize accordingly
    --for i,elem in ipairs(_GUI_ELEMENTS) do
      --elem.Data.X = FLOOR(_GUI_INIT_ELEMENTS[i][1] * CURR_RES_WIDTH);
      --elem.Data.Y = FLOOR(_GUI_INIT_ELEMENTS[i][2] * CURR_RES_HEIGHT);
      --elem.Data.W = FLOOR(_GUI_INIT_ELEMENTS[i][3] * CURR_RES_WIDTH);
      --elem.Data.H = FLOOR(_GUI_INIT_ELEMENTS[i][4] * CURR_RES_HEIGHT);
      
      --elem.Data.Rect.Left = elem.Data.X;
      --elem.Data.Rect.Right = elem.Data.Rect.Left + elem.Data.W;
      --elem.Data.Rect.Top = elem.Data.Y;
      --elem.Data.Rect.Bottom = elem.Data.Rect.Top + elem.Data.H;
    --end
  end
  
  gui_draw_menus();
end