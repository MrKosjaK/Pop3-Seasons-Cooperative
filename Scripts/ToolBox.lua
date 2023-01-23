TJournal = 
{
  Blocks = {},
  DrawInfo = 
  {
    isOpen = false,
    Pos = {0, 0},
    Size = {240, 320},
    RenderArea = TbRect.new(),
    Style = BorderLayout.new()
  }
};

TQuest = {};

local j_mt = {}; j_mt.__index = j_mt;
local q_mt = {}; q_mt.__index = q_mt;

setmetatable(TJournal,
{
  __index = j_mt,
  __call = function(t, ...) end
});

function j_mt:Draw()
  if (self.DrawInfo.isOpen) then
    DrawStretchyButtonBox(self.DrawInfo.RenderArea, self.DrawInfo.Style);
  end
end

function j_mt:Toggle()
  self.DrawInfo.isOpen = not self.DrawInfo.isOpen;
end

function j_mt:Init()
  self.Blocks = nil;
  self.Blocks = {};
  
  self.DrawInfo.isOpen = true;
  self.DrawInfo.Size[1] = ScreenWidth() >> 1;
  self.DrawInfo.Size[2] = (ScreenHeight() >> 1) + 128;
  self.DrawInfo.Pos[1] = (ScreenWidth() >> 1) - (self.DrawInfo.Size[1] >> 1);
  self.DrawInfo.Pos[2] = 32;
  self.DrawInfo.RenderArea.Left = self.DrawInfo.Pos[1]
  self.DrawInfo.RenderArea.Top = self.DrawInfo.Pos[2]
  self.DrawInfo.RenderArea.Right = self.DrawInfo.RenderArea.Left + self.DrawInfo.Size[1];
  self.DrawInfo.RenderArea.Bottom = self.DrawInfo.RenderArea.Top + self.DrawInfo.Size[2];
  
  self.DrawInfo.Style.TopLeft = 713;
  self.DrawInfo.Style.TopRight = self.DrawInfo.Style.TopLeft + 1;
  self.DrawInfo.Style.BottomLeft = self.DrawInfo.Style.TopRight + 1;
  self.DrawInfo.Style.BottomRight = self.DrawInfo.Style.BottomLeft + 1;
  self.DrawInfo.Style.Top = self.DrawInfo.Style.BottomRight + 1;
  self.DrawInfo.Style.Bottom = self.DrawInfo.Style.Top + 1;
  self.DrawInfo.Style.Left = self.DrawInfo.Style.Bottom + 1;
  self.DrawInfo.Style.Right = self.DrawInfo.Style.Left + 1;
  self.DrawInfo.Style.Centre = self.DrawInfo.Style.Right + 1;
end