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

MY_MENU_MAIN = 1;
MY_MENU_PLAYERS = 2;

_GUI_MENUS =
{
  [MY_MENU_MAIN] = 
  {
  },
  [MY_MENU_PLAYERS] = 
  {
  }
}

ELEM_TYPE_NONE = 1;

MY_ELEM_BACKGROUND = 1;
MY_ELEM_BACKGROUND2 = 2;

_GUI_INIT_ELEMENTS =
{
  -- Name -> X -> Y -> W -> H
  [MY_ELEM_BACKGROUND] = {0.25, 0.25, 0.5, 0.5},
  --[MY_ELEM_BACKGROUND2] = {0.5, 0.5, 0.3, 0.3},
}

_GUI_ELEMENTS =
{
}

local FLOOR = math.floor;

local start_turn = getTurn();

CURR_RES_WIDTH = 0;
CURR_RES_HEIGHT = 0;

function OnTurn()
  local turn = getTurn();
  
  if (turn == (start_turn + 1)) then
    -- cache width and height res
    CURR_RES_HEIGHT = ScreenHeight();
    CURR_RES_WIDTH = ScreenWidth();
    
    gui_init_all();
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
    
    -- go through all elements and resize accordingly
    for i,elem in ipairs(_GUI_ELEMENTS) do
      elem.Data.X = FLOOR(_GUI_INIT_ELEMENTS[i][1] * CURR_RES_WIDTH);
      elem.Data.Y = FLOOR(_GUI_INIT_ELEMENTS[i][2] * CURR_RES_HEIGHT);
      elem.Data.W = FLOOR(_GUI_INIT_ELEMENTS[i][3] * CURR_RES_WIDTH);
      elem.Data.H = FLOOR(_GUI_INIT_ELEMENTS[i][4] * CURR_RES_HEIGHT);
      
      elem.Data.Rect.Left = elem.Data.X;
      elem.Data.Rect.Right = elem.Data.Rect.Left + elem.Data.W;
      elem.Data.Rect.Top = elem.Data.Y;
      elem.Data.Rect.Bottom = elem.Data.Rect.Top + elem.Data.H;
    end
  end

  for i = 1, #_GUI_ELEMENTS do
    local elem = _GUI_ELEMENTS[i];
    
    if (elem ~= nil) then
      LbDraw_Rectangle(elem.Data.Rect, 130);
    end
  end
end