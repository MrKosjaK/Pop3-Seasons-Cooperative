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


-- triggered on releasing pressed key
function OnKeyUp(key)
  if (ScrOnKeyUp ~= nil) then ScrOnKeyUp(key); end
end


-- triggered on receiving a network packet
function OnPacket(player_num, packet_type, data)
  if (am_i_in_network_game() ~= 0) then
    if (ScrOnPacket ~= nil) then ScrOnPacket(player_num, packet_type, data); end
  end
end