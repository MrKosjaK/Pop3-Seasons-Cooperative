import(Module_DataTypes)
import(Module_Objects)
import(Module_Defines)
import(Module_Math)
import(Module_Map)
import(Module_MapWho)
import(Module_Game)
import(Module_Helpers)

include("UtilRefs.lua")

shamans = {}
eq_models = {3,5,6,7,8,15}
fs_models = {2,3,5}
swamp_models = {5,7,8}
ww_models = {1,2,4,5,6,7,8,13,15}

AIShaman = {}
AIShaman.reg = function(...)
  local args = {...}
  local data = {}

  data.Owner = args[2]
  data.ShamanProxy = ObjectProxy.new()
  data.ShamanProxy:set(args[1])
  data.ShamanThing = data.ShamanProxy:get()
  data.Spells = {
    M_SPELL_WHIRLWIND,
    M_SPELL_EARTHQUAKE,
    M_SPELL_FIRESTORM,
    M_SPELL_SWAMP
  }
  data.SpellsDelay = {
    840,840*2,840*3,840*2
  }
  data.SpellsUsed = {
    3,2,2,3
  }
  data.SpellsCost = {
    840,840*2,840*3,840*2
  }
  data.BldgsIdxs = {}

  function data:CalculateRadiusXZ(spell)
    local my radius = 0
    local spell_input = spell
    local spell_radius = _spti[spell_input].WorldCoordRange
    my_radius = math.ceil((spell_radius+data.ShamanThing.Pos.D3.Ypos*3)/512)
    return my_radius
  end

  function data:DecideSpellToUse()
    local spell = M_SPELL_NONE
    local spell_return = M_SPELL_NONE
    local tries = 32
    while (tries > 0) do
      tries=tries-1
      local index = G_RANDOM(#data.Spells)+1
      spell = data.Spells[index]
      if (data.SpellsUsed[index] >= _spti[spell].OneOffMaximum) then
        index = G_RANDOM(#data.Spells)+1
      else
        spell_return = spell
        break
      end
    end
    return spell_return
  end

  function data:ProcessSpells()
    for i,v in ipairs(data.SpellsDelay) do
      if (v > 0 and data.SpellsUsed[i] ~= 0) then
        data.SpellsDelay[i] = v-16
      end

      if (v <= 0 and data.SpellsUsed[i] >= _spti[data.Spells[i]].OneOffMaximum) then
        data.SpellsDelay[i] = data.SpellsCost[i]
        data.SpellsUsed[i] = data.SpellsUsed[i]-1
      end
    end
  end

  function data:Process()
    if (not data.ShamanProxy:isNull()) then
      if (data.ShamanThing.Model == M_PERSON_MEDICINE_MAN and not isFlagEnabled(data.ShamanThing.Flags2, TF2_THING_IN_AIR)) then
        local spell_input = data:DecideSpellToUse()
        if (spell_input ~= M_SPELL_NONE) then
          local radXZ = data:CalculateRadiusXZ(spell_input)
          SearchMapCells(CIRCULAR,0,radXZ-4,radXZ-2,world_coord2d_to_map_idx(data.ShamanThing.Pos.D2),function(me)
            local found = false
            me.MapWhoList:processList(function(t)
              if (t.Type == T_BUILDING) then
                if (t.Owner ~= data.ShamanThing.Owner and are_players_allied(t.Owner,data.ShamanThing.Owner) == 0) then
                  if not (DoesExist(data.BldgsIdxs,t.ThingNum)) then
                    if (t.u.Bldg.ShapeThingIdx:isNull()) then
                      if (DoesExist(ww_models,t.Model) and spell_input == M_SPELL_WHIRLWIND) then
                        createThing(T_SPELL,spell_input,data.ShamanThing.Owner,t.Pos.D3,false,false)
                        found = true
                        data.SpellsUsed[1] = data.SpellsUsed[1]+1
                        table.insert(data.BldgsIdxs,t.ThingNum)
                        return false
                      end

                      if (DoesExist(eq_models,t.Model) and spell_input == M_SPELL_EARTHQUAKE) then
                        createThing(T_SPELL,spell_input,data.ShamanThing.Owner,t.Pos.D3,false,false)
                        found = true
                        data.SpellsUsed[2] = data.SpellsUsed[2]+1
                        table.insert(data.BldgsIdxs,t.ThingNum)
                        return false
                      end

                      if (DoesExist(fs_models,t.Model) and spell_input == M_SPELL_FIRESTORM) then
                        createThing(T_SPELL,spell_input,data.ShamanThing.Owner,t.Pos.D3,false,false)
                        found = true
                        data.SpellsUsed[3] = data.SpellsUsed[3]+1
                        table.insert(data.BldgsIdxs,t.ThingNum)
                        return false
                      end
                      
                      if (DoesExist(swamp_models,t.Model) and spell_input == M_SPELL_SWAMP) then
                        createThing(T_SPELL,spell_input,data.ShamanThing.Owner,t.Pos.D3,false,false)
                        found = true
                        data.SpellsUsed[4] = data.SpellsUsed[4]+1
                        table.insert(data.BldgsIdxs,t.ThingNum)
                        return false
                      end
                    end
                  end
                end
              end
              return true
            end)
            if (found) then
              return false
            end
            return true
          end)
        end
      end
    else
      local shaman = getShaman(data.Owner)
      if (shaman ~= nil and shaman.Model == M_PERSON_MEDICINE_MAN and GetPlayerPeople(data.Owner) > 0) then
        data.ShamanProxy:set(shaman.ThingNum)
        data.ShamanThing = data.ShamanProxy:get()
      end
    end
  end

  return data
end

ProcessGlobalTypeList(T_PERSON,function(t)
  if (t.Model == M_PERSON_MEDICINE_MAN) then
    if (_gsi.Players[t.Owner].PlayerType == COMPUTER_PLAYER) then
      local shaman = AIShaman.reg(t.ThingNum,t.Owner)
      table.insert(shamans,shaman)
    end
  end
  return true
end)

function OnTurn()
  if (everyPow(2,4)) then
    for i in ipairs(shamans) do
      shamans[i]:Process()
      shamans[i]:ProcessSpells()
    end
  end
end
