-- detailed information about tribe's progression
include("lb_box.lua");


local win_box_style = create_layout(713);
local player_collection_data = {};

for i = 0, 7 do
  player_collection_data[i] =
  {
    PopStamps = {},
    BldgStamps = {},
  };
end

local function add_population_stamp()
  for i = 0, 7 do
    local ps = player_collection_data[i].PopStamps;
    ps[#ps + 1] = getPlayer(i).NumPeople;
  end
end

function display_population_graph()
  
end




local rect_area = create_rectangle(250, 420, 0, 0);
local box_sizes = { 250, 420 };

local player_rects =
{
  [0] = TbRect.new(),
  TbRect.new(),
  TbRect.new(),
  TbRect.new(),
  TbRect.new(),
  TbRect.new(),
  TbRect.new(),
  TbRect.new()
};
local player_gauges = 
{
  [0] = 0, 0, 0, 0, 0, 0, 0, 0
};
local margin = 4;

function calculate_population_scores()
  for i = 0, 7 do
    player_gauges[i] = getPlayer(i).NumPeople;
  end
end

function draw_population_scores()
  -- lets draw a score bar on top middle area
  local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth();
  
  box_sizes[1] = (w >> 3) + (w >> 4);
  local last_pos = 0;

  rect_area.Left = (w >> 1) - (box_sizes[1] >> 1) + (guiW >> 1);
  rect_area.Right = rect_area.Left + box_sizes[1];
  
  rect_area.Top = 16;
  rect_area.Bottom = rect_area.Top + (h >> 5) + 4;
  --rect_area.Left = w - box_sizes[1] - 16;
  --rect_area.Right = rect_area.Left + box_sizes[1];
  --rect_area.Top = h - box_sizes[2] - 16;
  --rect_area.Bottom = rect_area.Top + box_sizes[2];
  
  DrawStretchyButtonBox(rect_area, win_box_style);
  
  rect_area.Top = rect_area.Top + margin;
  rect_area.Bottom = rect_area.Bottom - margin;
  rect_area.Left = rect_area.Left + margin;
  rect_area.Right = rect_area.Right - margin;
  LbDraw_Rectangle(rect_area, COLOUR(CLR_BLACK));
  
  last_pos = rect_area.Left;
  for i = 0, 7 do
    if (player_gauges[i] > 0) then
      rect_area.Left = (w >> 1) - (box_sizes[1] >> 1) + (guiW >> 1);
    rect_area.Right = rect_area.Left + box_sizes[1];
  
  rect_area.Top = 16;
  rect_area.Bottom = rect_area.Top + (h >> 5) + 4;
  rect_area.Top = rect_area.Top + margin;
  rect_area.Bottom = rect_area.Bottom - margin;
  rect_area.Left = rect_area.Left + margin;
  rect_area.Right = rect_area.Right - margin;
      
      rect_area.Right = math.min( math.floor(rect_area.Left - ((rect_area.Left - rect_area.Right) * player_gauges[i]) / box_sizes[1]), rect_area.Left + box_sizes[1] - (margin << 1));
      --last_pos = rect_area.Right;
      --rect_area.Left = rect_area.Right;
      LbDraw_Rectangle(rect_area, COLOUR(CLR_BLUE + i));
    end
  end
end