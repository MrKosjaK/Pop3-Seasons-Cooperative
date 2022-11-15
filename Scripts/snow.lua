--snow

snow = 0
snowDroplets = {}
fastStopSnow = 0

function createSnow(amount)
	if snow == 0 then
		snow = 1
		for i = 0,amount do
			local drop = createThing(T_EFFECT,60,8,marker_to_coord3d(rndb(0,32)),false,false)
			set_thing_draw_info(drop,TDI_SPRITE_F1_D1, rndb(1755,1766))
			drop.u.Effect.Duration = -1
			drop.DrawInfo.Alpha = -16
			local c3d = CopyC3d(drop.Pos.D3)
			c3d.Ypos = rndb(1500,2000)
			c3d.Xpos = G_RANDOM (65500)
			c3d.Zpos = G_RANDOM (65500)
			move_thing_within_mapwho(drop,c3d)
			table.insert(snowDroplets,drop)
		end
	end
end

function snowFall(intensity,processWhilePaused)
	local function StopSnowChance(rrnd,dropThing)
		--chance of splash
		if rnd() < rrnd then
			local splash = createThing(T_EFFECT,M_EFFECT_SMOKE,8,dropThing.Pos.D3,false,false)
			--set_thing_draw_info(splash,TDI_SPRITE_F8_D1, 1280)
		end
		local c3d = CopyC3d(dropThing.Pos.D3)
		c3d.Ypos = rndb(1600,2000)
		c3d.Xpos = G_RANDOM (65500)
		c3d.Zpos = G_RANDOM (65500)
		move_thing_within_mapwho(dropThing,c3d)
	end
	local function process()
		if #snowDroplets > 0 then
			for k,v in ipairs (snowDroplets) do
				if k <= #snowDroplets and v ~= nil then
					if v.Pos.D3.Ypos > (point_altitude(ThingX(v),ThingZ(v))-16) then
						local int = rndb(2,4)
						if intensity == 2 then int = rndb(4,8) elseif intensity == 3 then int = rndb(8,16) end
						v.Pos.D3.Ypos = v.Pos.D3.Ypos - int
					else
						if snow == 1 then
							StopSnowChance(20,v)
						else
							if fastStopSnow == 0 then
								StopSnowChance(8,v)
							else
								if rnd() < 32 then
									v.u.Effect.Duration = 1
									table.remove(snowDroplets,k)
								else
									StopSnowChance(20,v)
								end
							end
						end
					end
				end
			end
		end
	end
	if processWhilePaused == true then
		process()
	else
		if (gns.Flags & GNS_PAUSED == 0) then
			process()
		end
	end
end

--[[
place inside onframe:
	snowFall(2,false) --intensity[1-3],process while paused

create snow this way:
	createSnow(600) --amount
	
stop snow this way:
	snow = 0 
	fastStopSnow = 1 --0 for slow stopping, 1 for fast

--------------------------
ONSAVE

	for i = 1,#snowDroplets do
		local t = snowDroplets[i]
		if (t ~= nil) then save_data:push_int(t.ThingNum) end
	end
	save_data:push_int(#snowDroplets)
	save_data:push_int(snow)
	save_data:push_int(fastStopSnow)
	
ONLOAD

	fastStopSnow = load_data:pop_int()
	snow = load_data:pop_int()
	local num_droplets = load_data:pop_int()
	for i = 1, num_droplets do
		local t = GetThing(load_data:pop_int())
		if (t ~= nil) then set_thing_draw_info(t,TDI_SPRITE_F1_D1, rndb(1755,1766)) table.insert(snowDroplets, t) end
	end
]]