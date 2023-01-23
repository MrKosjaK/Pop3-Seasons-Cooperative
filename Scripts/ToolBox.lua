TJournal = 
{
  Blocks = {},
  DrawInfo = 
  {
    isOpen = false,
    Pos = {0, 0},
    Size = {240, 320},
    RenderArea = TbRect.new()
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
    LbDraw_Rectangle(self.DrawInfo.RenderArea, 128);
  end
end

function j_mt:Toggle()
  self.DrawInfo.isOpen = not self.DrawInfo.isOpen;
end

function j_mt:Init()
  self.Blocks = nil;
  self.Blocks = {};
  
  self.DrawInfo.isOpen = true;
  self.DrawInfo.Pos[1] = 0;
  self.DrawInfo.Pos[2] = 0;
  self.DrawInfo.Size[1] = 240;
  self.DrawInfo.Size[2] = 320;
  self.DrawInfo.RenderArea.Left = self.DrawInfo.Pos[1]
  self.DrawInfo.RenderArea.Top = self.DrawInfo.Pos[2]
  self.DrawInfo.RenderArea.Right = self.DrawInfo.RenderArea.Left + self.DrawInfo.Size[1];
  self.DrawInfo.RenderArea.Bottom = self.DrawInfo.RenderArea.Top + self.DrawInfo.Size[2];
end