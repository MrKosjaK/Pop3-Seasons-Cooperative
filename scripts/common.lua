-- includes
include("globals.lua");
include("game_state.lua");

local GAME_STARTED = false;
local SHAM_ORIG_POS = {};
local SHAM_CURR_POS = {};
local SHAM_ORDER = {};

-- main hooks

-- triggered on level initialization
function OnLevelInit(level_id)
  if (ScrOnLevelInit ~= nil) then ScrOnLevelInit(level_id); end
  
  if (is_game_state(GM_STATE_SETUP)) then
    -- let's prepare level for lobby
    set_level_unable_to_complete();
    set_level_unable_to_lose();
    
    -- freeze all units and make them unselectable
    ProcessGlobalTypeList(T_PERSON, function(t_thing)
      remove_all_persons_commands(t_thing);
      --if (t_thing.Model ~= M_PERSON_MEDICINE_MAN) then
        set_person_new_state(t_thing, S_PERSON_NONE);
      --end
      t_thing.Flags2 = t_thing.Flags2 | TF2_PERSON_NOT_SELECTABLE;
      return true;
    end);
    
    for i = 0, 7 do
      if (getPlayer(i).NumPeople > 0 and getShaman(i)) then
        set_player_reinc_site_off(getPlayer(i));
        mark_reincarnation_site_mes(getPlayer(i).ReincarnSiteCoord, OWNER_NONE, UNMARK);
        SHAM_ORDER[#SHAM_ORDER + 1] = i;
        SHAM_ORIG_POS[#SHAM_ORIG_POS + 1] = Coord3D.new();
        SHAM_CURR_POS[#SHAM_CURR_POS + 1] = Coord3D.new();
        SHAM_ORIG_POS[#SHAM_ORIG_POS].Xpos = getShaman(i).Pos.D3.Xpos;
        SHAM_ORIG_POS[#SHAM_ORIG_POS].Zpos = getShaman(i).Pos.D3.Zpos;
        SHAM_ORIG_POS[#SHAM_ORIG_POS].Ypos = getShaman(i).Pos.D3.Ypos;
        SHAM_CURR_POS[#SHAM_CURR_POS].Xpos = getShaman(i).Pos.D3.Xpos;
        SHAM_CURR_POS[#SHAM_CURR_POS].Zpos = getShaman(i).Pos.D3.Zpos;
        SHAM_CURR_POS[#SHAM_CURR_POS].Ypos = getShaman(i).Pos.D3.Ypos;
      end
    end
  end
end


-- triggered every game turn
function OnTurn()
  if (is_game_state(GM_STATE_SETUP)) then
    if (GAME_STARTED) then
      ProcessGlobalTypeList(T_PERSON, function(t_thing)
        remove_all_persons_commands(t_thing);
        set_person_top_state(t_thing);
        t_thing.Flags2 = t_thing.Flags2 & ~TF2_PERSON_NOT_SELECTABLE;
        
        if (t_thing.Model == M_PERSON_WILD) then
          set_person_new_state(t_thing, S_PERSON_STAND_FOR_TIME);
        end
        return true;
      end);
      
      for i = 0,7 do
        if (getPlayer(i).NumPeople > 0) then
          set_player_reinc_site_on(getPlayer(i));
          mark_reincarnation_site_mes(getPlayer(i).ReincarnSiteCoord, i, MARK);
          set_players_shaman_initial_command(getPlayer(i));
        end
      end
      
      GAME_STARTED = false;
      set_game_state(GM_STATE_GAME);
    end
  elseif (is_game_state(GM_STATE_GAME)) then
    -- main entry
    if (ScrOnTurn ~= nil) then ScrOnTurn(getTurn()); end
  end
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

PACKET_ROTATE_FORWARD = 0;
PACKET_ROTATE_BACKWARD = 1;
PACKET_ROTATE_RESTORE = 2;

-- triggered on releasing pressed key
function OnKeyUp(key)
  if (ScrOnKeyUp ~= nil) then ScrOnKeyUp(key); end
  
  -- network based/online
  if (is_game_state(GM_STATE_SETUP)) then
    if (am_i_in_network_game() ~= 0) then
      -- for now rotating will be via hotkeys, later will do GUI
      
      -- FORWARD rotation
      if (key == LB_KEY_E) then
        Send(PACKET_ROTATE_FORWARD, "0");
        --elseif (_IsKeyDown(LB_KEY_LCONTROL) or _IsKeyDown(LB_KEY_RCONTROL)) then
          --Send(PACKET_ROTATE_FORWARD, tostring(key));
        --end
      end
      
      -- BACKWARD rotation
      if (key == LB_KEY_Q) then
        Send(PACKET_ROTATE_BACKWARD, "0");
      end
      
      -- RESTORE rotation
      if (key == LB_KEY_W) then
        Send(PACKET_ROTATE_RESTORE, "0");
      end
    else
      -- forward
      if (key == LB_KEY_E) then
        for i,k in ipairs(SHAM_CURR_POS) do
          local value = ((i + 1) % 5);
          if (value == 0) then value = 1; end
          log(string.format("%i", value));
          --set_person_standing_anim(getShaman(SHAM_ORDER[i]));
          move_thing_within_mapwho(getShaman(SHAM_ORDER[i]), SHAM_CURR_POS[value]);
          move_thing_within_mapwho(getShaman(SHAM_ORDER[i]), SHAM_CURR_POS[value]);
          ensure_thing_on_ground(getShaman(SHAM_ORDER[i]));
          --set_person_standing_anim(getShaman(SHAM_ORDER[i]));
        end
        
        for i,k in ipairs(SHAM_CURR_POS) do
          -- update positions
          SHAM_CURR_POS[i].Xpos = getShaman(SHAM_ORDER[i]).Pos.D3.Xpos;
          SHAM_CURR_POS[i].Zpos = getShaman(SHAM_ORDER[i]).Pos.D3.Zpos;
          SHAM_CURR_POS[i].Ypos = getShaman(SHAM_ORDER[i]).Pos.D3.Ypos;
        end
      end
      -- backward
      if (key == LB_KEY_Q) then
      
      end
      -- restore
      if (key == LB_KEY_W) then
      
      end
      
      if (key == LB_KEY_SPACE) then
        GAME_STARTED = true;
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