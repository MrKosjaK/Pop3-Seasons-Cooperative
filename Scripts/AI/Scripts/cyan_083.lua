local ai_convert_markers =
{
  [TRIBE_CYAN] = { 10, 11, 12, 13, 14 },
  [TRIBE_GREEN] = { 1 },
  [TRIBE_PINK] = { 15, 16, 17, 18 }
};

function cyan_attacking(player)
  -- depends on what we want with attacking, let's actually make it patterned for now
  local did_attack = false;
  if (AI_GetVar(player, 3) == 0) then
    AI_SetVar(player, 3, 1); -- always set it to next.

    -- first pattern attack consists of just fws i guess? crap attack
    if (AI_GetUnitCount(player, M_PERSON_SUPER_WARRIOR) > 2) then
      did_attack = true;

      AI_SetAttackFlags(player, 0, 0, 0);
      AI_SetAways(player, 20, 0, 0, 80, 0);
      AI_SetShamanAway(player, false);
      ATTACK(player, TRIBE_BLUE, 2, ATTACK_BUILDING, 0, 250, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, 0);
    end
  elseif (AI_GetVar(player, 3) == 1) then
    -- second pattern attack, we'll try to make invisible priests if we have them! hehe bOIII
    if (AI_GetUnitCount(player, M_PERSON_RELIGIOUS) > 2) then
      if (MANA(player) > 100000 and AI_ShamanFree(player)) then
        did_attack = true;

        AI_SetAttackFlags(player, 0, 0, 0);
        AI_SetAways(player, 0, 0, 100, 0, 0);
        AI_SetShamanAway(player, true);
        ATTACK(player, TRIBE_BLUE, 6, ATTACK_BUILDING, 0, 250, M_SPELL_INVISIBILITY, 0, 0, ATTACK_NORMAL, 0, -1, -1, 0);
      end
    end
    AI_SetVar(player, 3, 2);
  elseif (AI_GetVar(player, 3) == 2) then
    -- this one will have a bigger attack on player.
    if (AI_GetUnitCount(player, M_PERSON_RELIGIOUS) > 2 and AI_GetUnitCount(player, M_PERSON_SUPER_WARRIOR) > 2) then
      did_attack = true;

      AI_SetAttackFlags(player, 0, 0, 0);
      AI_SetAways(player, 10, 0, 50, 50, 0);
      AI_SetShamanAway(player, false);
      ATTACK(player, TRIBE_BLUE, 12, ATTACK_BUILDING, 0, 650, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, 0);

      if (AI_ShamanFree(player) and MANA(player) > 150000) then
        AI_SetShamanAway(player, true);
        AI_SetAttackFlags(player, 3, 1, 0);
        AI_SetAways(player, 0, 0, 0, 0, 0);
        ATTACK(player, TRIBE_BLUE, 0, ATTACK_BUILDING, M_BUILDING_DRUM_TOWER, 36, M_SPELL_WHIRLWIND, M_SPELL_WHIRLWIND, M_SPELL_WHIRLWIND, ATTACK_NORMAL, 0, -1, -1, 0);
      end
    end
    AI_SetVar(player, 3, 3);
  elseif (AI_GetVar(player, 3) == 3) then
    AI_SetVar(player, 3, 0);
  end

  if (not did_attack and AI_GetVar(player, 2) == 1) then
    -- let's check if we should try to take over midhill with anything we can think of.
    -- first, do we have any priests?
    if (AI_GetUnitCount(player, M_PERSON_RELIGIOUS) > 3) then
      -- we got some priests, let's send them to attack the marker.
      AI_SetAttackFlags(player, 3, 1, 0);
      AI_SetAways(player, 25, 0, 75, 0, 0);
      AI_SetShamanAway(player, false);
      ATTACK(player, TRIBE_BLUE, 5, ATTACK_MARKER, 6, 500, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, 0);
    end

    -- check if can support with shaman
    if (AI_ShamanFree(player) and MANA(player) > 150000) then
      AI_SetShamanAway(player, true);
      AI_SetAttackFlags(player, 3, 1, 0);
      AI_SetAways(player, 0, 0, 0, 0, 0);
      ATTACK(player, TRIBE_BLUE, 0, ATTACK_MARKER, 6, 36, M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, M_SPELL_WHIRLWIND, ATTACK_NORMAL, 0, -1, -1, 0);
      return;
    end
  end
end

function cyan_towers(player)
  -- for building towers we want to have at least 1 fw and some population
  if (AI_GetPopCount(player) > 14) then
    if (AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) > 0) then
      if (AI_EntryAvailable(player)) then
        -- build our first row of defense once we built fw hut and got enough huts to support
        if (AI_GetVar(player, 4) == 1) then
          -- for middle hilled part we want to check if theres no enemy present.
          -- if there is, set user var to specific value to indicate they exist.
          AI_SetVar(player, 2, 0);
          if (AI_AreaContainsEnemy(player, 138, 78, 6)) then
            AI_SetVar(player, 2, 1);
          end

          -- check one by one
          if (not GetAI("Cyan"):TowerIsBuilt("Front1")) then
            GetAI("Cyan"):CheckTower("Front1");
            return;
          end

          if (not GetAI("Cyan"):TowerIsBuilt("Front2")) then
            GetAI("Cyan"):CheckTower("Front2");
            return;
          end

          if (not GetAI("Cyan"):TowerIsBuilt("Front3")) then
            GetAI("Cyan"):CheckTower("Front3");
            return;
          end

          if (AI_GetVar(player, 2) == 1) then
            return;
          end

          if (not GetAI("Cyan"):TowerIsBuilt("MidHill1")) then
            GetAI("Cyan"):CheckTower("MidHill1");
            return;
          end

          if (not GetAI("Cyan"):TowerIsBuilt("MidHill2")) then
            GetAI("Cyan"):CheckTower("MidHill2");
            return;
          end

          if (not GetAI("Cyan"):TowerIsBuilt("MidHill3")) then
            GetAI("Cyan"):CheckTower("MidHill3");
            return;
          end
        end
      end
    end
  end
end

function cyan_convert(player)
  -- check if we have a low pop count
  if (AI_GetPopCount(player) < 35) then
    -- enable converting and convert at random markers
    STATE_SET(player, 1, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
    WRITE_CP_ATTRIB(player, ATTR_EXPANSION, 36);

    local mk = ai_convert_markers[player][G_RANDOM(#ai_convert_markers[player]) + 1];
    AI_ConvertAt(player, mk);
  else
    -- disable converting
    STATE_SET(player, 0, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS);
  end
end

function cyan_build(player)
  -- let's see what we got here, we probably want to get FW hut after some huts.
  if (AI_GetHutsCount(player) >= 5 and AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) == 0) then
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1);
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 27);
  end

  -- we want to keep building huts now
  if (AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) > 0) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 45);
    if (AI_GetVar(player, 1) == 0) then
      AI_SetVar(player, 1, 1);
      AI_SetMainDrumTower(TRIBE_CYAN, true, 138, 128);
    end
  end

  -- check if we got any training building, if so, enable training
  if (AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) > 0 or
      AI_GetBldgCount(player, M_BUILDING_TEMPLE) > 0 or
      AI_GetBldgCount(player, M_BUILDING_WARRIOR_TRAIN) > 0) then
        WRITE_CP_ATTRIB(player, ATTR_MAX_TRAIN_AT_ONCE, 3);
        STATE_SET(player, TRUE, CP_AT_TYPE_TRAIN_PEOPLE);
  end

  -- once we get more huts, we can afford to train some fws
  if (AI_GetHutsCount(player) > 6 and AI_GetBldgCount(player, M_BUILDING_SUPER_TRAIN) > 0) then
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 10);
    AI_SetVar(player, 4, 1);
  end

  -- we got more huts, let's get priests up !
  if (AI_GetHutsCount(player) > 8 and AI_GetBldgCount(player, M_BUILDING_TEMPLE) == 0) then
    WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_TRAINS, 1);
    WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 10);
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 15);
  end

  -- let's keep expanding on our tribe once temple is up
  if (AI_GetBldgCount(player, M_BUILDING_TEMPLE) > 0) then
    WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 4);
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 75);
  end

  -- once we got big enough tribe, increase training %
  if (AI_GetHutsCount(player) > 11) then
    WRITE_CP_ATTRIB(player, ATTR_HOUSE_PERCENTAGE, 90);
    WRITE_CP_ATTRIB(player, ATTR_PREF_RELIGIOUS_PEOPLE, 15);
    WRITE_CP_ATTRIB(player, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 21);
    WRITE_CP_ATTRIB(player, ATTR_MAX_BUILDINGS_ON_GO, 2); -- slowdown there
  end
end
