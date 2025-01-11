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

local p_rect = {
  [0] = create_rectangle(0, 0, 0, 0),
  create_rectangle(0, 0, 0, 0),
  create_rectangle(0, 0, 0, 0),
  create_rectangle(0, 0, 0, 0),
  create_rectangle(0, 0, 0, 0),
  create_rectangle(0, 0, 0, 0),
  create_rectangle(0, 0, 0, 0),
  create_rectangle(0, 0, 0, 0)
};

local player_gauges = 
{
  [0] = 0, 0, 0, 0, 0, 0, 0, 0
};
local margin = 4;
local total_score = 0;

function calculate_population_scores()
  total_score = 0;
  for i = 0, 7 do
    player_gauges[i] = getPlayer(i).NumPeople;
    player_gauges[i] = player_gauges[i] + (getPlayer(i).NumBuildings * 2);
    
    total_score = total_score + player_gauges[i];
  end
end

local tribe_clr = {[0] = 220, 244, 236, 227, 145, 212, 173, 135};

function draw_population_scores()
  -- lets draw a score bar on top middle area
  local w,h,guiW = ScreenWidth(), ScreenHeight(), GFGetGuiWidth();
  
  box_sizes[1] = (w >> 3) + (w >> 4);
  local last_pos = 0;

  rect_area.Left = (w >> 1) - (box_sizes[1] >> 1) + (guiW >> 1);
  rect_area.Right = rect_area.Left + box_sizes[1];
  
  rect_area.Top = 16;
  rect_area.Bottom = rect_area.Top + (h >> 6) + 4;
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
  
  local next_s_pos = rect_area.Left;
  
  local bar_size = rect_area.Right - rect_area.Left;
  local percent_taken = 0;
  
  LbDraw_SetClipRect(rect_area);
  for i = 0, 7 do
    if (player_gauges[i] > 0) then
      percent_taken = math.ceil((player_gauges[i] / total_score) * 100);
      p_rect[i].Left = next_s_pos;
      p_rect[i].Right = p_rect[i].Left + math.ceil((bar_size / 100) * percent_taken);
      p_rect[i].Top = rect_area.Top;
      p_rect[i].Bottom = rect_area.Bottom;
      
      LbDraw_Rectangle(p_rect[i], tribe_clr[i]);
      
      next_s_pos = p_rect[i].Right;
    end
  end
  LbDraw_ReleaseClipRect();
  
  for i = 0, 7 do
    if (player_gauges[i] > 0) then
      PopSetFont(4);
      --percent_taken = ((player_gauges[i] / total_score) * 100);
      --p_rect[i].Left = next_s_pos;
      --p_rect[i].Top = rect_area.Top;
      --p_rect[i].Bottom = rect_area.Bottom;
      --p_rect[i].Right = math.min( math.floor(p_rect[i].Left - ((p_rect[i].Left - rect_area.Right) * player_gauges[i]) / box_sizes[1]), rect_area.Left + box_sizes[1] - (margin << 1));
      --next_s_pos = p_rect[i].Right;
      --last_pos = rect_area.Right;
      --rect_area.Left = rect_area.Right;
      --LbDraw_Rectangle(p_rect[i], COLOUR(CLR_BLUE + i));
      --LbDraw_Text(rect_area.Left - 64, rect_area.Top + (i * CharHeight(1)), string.format("%.2f", percent_taken), 0);
    end
  end
end