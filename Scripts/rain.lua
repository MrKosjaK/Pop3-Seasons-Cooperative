--rain

rain = 0
droplets = {}
fastStopRain = 0

function createRain(amount)
	if rain == 0 then
		rain = 1
		for i = 0,amount do
			local drop = createThing(T_EFFECT,60,8,marker_to_coord3d(rndb(0,32)),false,false)
			set_thing_draw_info(drop,TDI_SPRITE_F1_D1, rndb(1734,1736)+3)
			drop.u.Effect.Duration = -1
			drop.DrawInfo.Alpha = -16
			local c3d = CopyC3d(drop.Pos.D3)
			c3d.Ypos = rndb(1500,2000)
			c3d.Xpos = G_RANDOM (65500)
			c3d.Zpos = G_RANDOM (65500)
			move_thing_within_mapwho(drop,c3d)
			table.insert(droplets,drop)
		end
	end
end

function rainFall(intensity,processWhilePaused)
	local function StopRainChance(rrnd,dropThing)
		--chance of splash
		if rnd() < rrnd then
			local splash = createThing(T_EFFECT,M_EFFECT_SPLASH,8,dropThing.Pos.D3,false,false)
			centre_coord3d_on_block(splash.Pos.D3)
			set_thing_draw_info(splash,TDI_SPRITE_F16_D1_ALPHA, 1304)
		end
		local c3d = CopyC3d(dropThing.Pos.D3)
		c3d.Ypos = rndb(1600,2000)
		c3d.Xpos = G_RANDOM (65500)
		c3d.Zpos = G_RANDOM (65500)
		move_thing_within_mapwho(dropThing,c3d)
	end
	local function process()
		if #droplets > 0 then
			for k,v in ipairs (droplets) do
				if k <= #droplets and v ~= nil then
					if v.Pos.D3.Ypos > (point_altitude(ThingX(v),ThingZ(v))-16) then
						local int = rndb(16,32)
						if intensity == 2 then int = rndb(32,64) elseif intensity == 3 then int = rndb(64,96) end
						v.Pos.D3.Ypos = v.Pos.D3.Ypos - int
					else
						if rain == 1 then
							StopRainChance(20,v)
						else
							if fastStopRain == 0 then
								StopRainChance(8,v)
							else
								if rnd() < 32 then
									v.u.Effect.Duration = 1
									table.remove(droplets,k)
								else
									StopRainChance(20,v)
								end
							end
						end
					end
				end
			end
			--thunderbolts if intensity is 3
			if #droplets > 300 and intensity == 3 then
				if turn() % 4 == 0 and rnd() < 70 then
					local lite = createThing(T_EFFECT,M_EFFECT_LIGHTNING_STRAND,8,coord_to_c3d(math.random(0,256),math.random(0,256)),false,false)
					lite.Pos.D3.Ypos = rndb(1400,2048) lite.u.Effect.Duration = rndb(4,24)
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
	rainFall(3,false) --intensity[1-3],process while paused

create rain this way:
	createRain(500) --amount
	
stop rain this way:
	rain = 0 
	fastStopRain = 1 --0 for slow stopping, 1 for fast

--------------------------
ONSAVE

	for i = 1,#droplets do
		local t = droplets[i]
		if (t ~= nil) then save_data:push_int(t.ThingNum) end
	end
	save_data:push_int(#droplets)
	save_data:push_int(rain)
	save_data:push_int(fastStopRain)
	
ONLOAD

	fastStopRain = load_data:pop_int()
	rain = load_data:pop_int()
	local num_droplets = load_data:pop_int()
	for i = 1, num_droplets do
		local t = GetThing(load_data:pop_int())
		if (t ~= nil) then set_thing_draw_info(t,TDI_SPRITE_F1_D1, rndb(1734,1736)+3) table.insert(droplets, t) end
	end
]]
