Clocks = {}; -- buffer for clocks

Clock = {};
Clock.__index = Clock;

function Clock:NewClock(_ticks, _randomness)
  local self = setmetatable({}, Clock);

  self.Randomness = _randomness;
  self.BaseTicks = _ticks;
  self.Ticks = self.BaseTicks - (G_RANDOM(_randomness));
  self.Count = 0;

  return self;
end

function Clock:Tick()
  self.Ticks = self.Ticks - 1;

  if (self.Ticks <= 0) then
    self.Ticks = self.BaseTicks - (G_RANDOM(self.Randomness));
    self.Count = self.Count + 1;
    return true;
  end

  return false;
end

function CreateClock(_name, _ticks, _randomness)
  if (Clocks[_name] == nil) then
    Clocks[_name] = Clock:NewClock(_ticks, _randomness);
  end
end

function TickClock(_name)
  if (Clocks[_name] ~= nil) then
    return Clocks[_name]:Tick();
  end

  return false;
end

function AdjustClock(_name, _ticks)
  if (Clocks[_name] ~= nil) then
    Clocks[_name].Ticks = _ticks;
  end
end
