local _RECENT_EVENTS = {};

EVENT_TYPE_INFO = 0;
EVENT_TYPE_MSG = 1;

function create_log_event(_type, ...)
  local _args = {...};
  
  local _event = {};
  _event._state = 0;
  _event._timestamp = getTurn();
  
  if (_type == EVENT_TYPE_INFO) then
    _event._sprite_idx = 176;
    _event._str = _args[1];
    _event._duration = _args[2];
  end
  
  if (_type == EVENT_TYPE_MSG) then
    _event._sprite_idx = 173;
    _event._str = _args[1];
    _event._owner = _args[2];
    _event._posx = _args[3];
    _event._posz = _args[4];
    _event._duration = _args[5];
  end
  
  _RECENT_EVENTS[#_RECENT_EVENTS + 1] = _event;
end

function draw_log_events(w, h, guiW)
  -- find bottom right corner
  local x = w;
  local y = h - 32;
  
  -- go through all log events and draw them
  for i = 1, #_RECENT_EVENTS do
    local _e = _RECENT_EVENTS[i];
    local _spr = get_sprite(0, _e._sprite_idx);
    PopSetFont(4);
    local str_w = string_width(_e._str);
    local _x = x - 32 - str_w;
    local _y = y - ((i - 1) * 20);
    
    LbDraw_Text(_x, (_y - CharHeight2()) - (_spr.Height >> 1) + (CharHeight2() >> 1) , _e._str, 0);
    LbDraw_Sprite(_x - _spr.Width, _y - _spr.Height, _spr);
    LbDraw_Text(_x - _spr.Width - 20, (_y - CharHeight2()) - (_spr.Height >> 1) + (CharHeight2() >> 1) , string.format("%i", _e._timestamp), 0);
  end
end