-- Simple countdown clocks
local _TURN_CLOCKS = {};
local _NUM_CLOCKS = 0;
local MAX = math.max;

TurnClock = {};
setmetatable(TurnClock,
{
  __index =
  {
    new = function(_turn, _func, _ticks, _owner, _randomness)
      _NUM_CLOCKS = _NUM_CLOCKS + 1;
      rawset(_TURN_CLOCKS, _NUM_CLOCKS,
      {
        ResetCount = _ticks or 1,
        Randomness = _randomness or 1,
        NextTurn = _turn + _ticks + G_RANDOM(_randomness),
        Owner = _owner,
        Function = _func
      });
    end,
    
    process_clocks = function()
      for i = 1, _NUM_CLOCKS do
        local c = _TURN_CLOCKS[i];
        local sturn = get_script_turn();
        
        if (sturn >= c.NextTurn) then
          c.NextTurn = sturn + c.ResetCount + G_RANDOM(c.Randomness);
          
          if (c.Function ~= nil) then
            c.Function(c.Owner, sturn);
          end
        end
      end
    end
  }
});