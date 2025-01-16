-- includes
include("globals.lua");

-- main hooks

-- triggered on level initialization
function OnLevelInit(level_id)
  if (ScrOnLevelInit ~= nil) then ScrOnLevelInit(level_id); end
end


-- triggered every game turn
function OnTurn()
  if (ScrOnTurn ~= nil) then ScrOnTurn(getTurn()); end
end


-- triggered on thing spawning
function OnCreateThing(t_thing)
  -- check if t_thing isn't local
  if (t_thing.Flags3 & TF3_LOCAL ~= 0) then
    return;
  end
  
  if (ScrOnCreateThing ~= nil) then ScrOnCreateThing(t_thing); end
end

-- triggered on every frame
function OnFrame()
  if (ScrOnFrame ~= nil) then ScrOnFrame(); end
end


-- triggered on tribe's death
function OnPlayerDeath(player_num)
  if (ScrOnPlayerDeath ~= nil) then ScrOnPlayerDeath(player_num); end
end


-- triggered on pressing down a key
function OnKeyDown(key)
  if (ScrOnKeyDown ~= nil) then ScrOnKeyDown(key); end
end


PACKET_GIVE_SPELL_ADD = 1;
PACKET_GIVE_SPELL_SUB = 2;

-- triggered on releasing pressed key
function OnKeyUp(key)
  if (ScrOnKeyUp ~= nil) then ScrOnKeyUp(key); end
  
  -- network based/online
  if (am_i_in_network_game() ~= 0) then
    -- just a test
    if (key == LB_KEY_1) then
      -- addition
      if (_IsKeyDown(LB_KEY_LSHIFT) or _IsKeyDown(LB_KEY_RSHIFT)) then
        Send(PACKET_GIVE_SPELL_ADD, tostring(key));
      -- subtruction
      elseif (_IsKeyDown(LB_KEY_LCONTROL) or _IsKeyDown(LB_KEY_RCONTROL)) then
        Send(PACKET_GIVE_SPELL_SUB, tostring(key));
      end
    end
  end
end


-- triggered on receiving a network packet
function OnPacket(player_num, packet_type, data)
  if (am_i_in_network_game() ~= 0) then
    if (ScrOnPacket ~= nil) then ScrOnPacket(player_num, packet_type, data); end
    
    if (packet_type == PACKET_GIVE_SPELL_ADD) then
      local key = tonumber(data);
      
      if (key == LB_KEY_1) then
        increment_number_of_one_shots(player_num, M_SPELL_BLAST);
      end
    end
    
    if (packet_type == PACKET_GIVE_SPELL_SUB) then
      local key = tonumber(data);
      
      if (key == LB_KEY_1) then
        reduce_number_of_one_shots(player_num, M_SPELL_BLAST);
      end
    end
  end
end