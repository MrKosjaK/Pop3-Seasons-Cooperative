--volcanic ash hail

ashhail = 0
ashDroplets = {}
fastStopAshhail = 0
AshHailStyleBeingUsed = 0

function createAshhail(amount,style) --style: 0 all shades ; 1 dark ; 2 dark grey ; 3 light grey
	if ashhail == 0 then
		ashhail = 1
		for i = 0,amount do
			local drop = createThing(T_EFFECT,60,8,marker_to_coord3d(rndb(0,32)),false,false)
			AshHailStyleBeingUsed = style
			local spr = rndb(1740,1754)
			if style == 1 then spr = rndb(1740,1744) elseif style == 2 then spr = rndb(1745,1749) elseif style == 3 then spr = rndb(1750,1754) end
			set_thing_draw_info(drop,TDI_SPRITE_F1_D1, spr)
			drop.u.Effect.Duration = -1
			drop.DrawInfo.Alpha = -16
			local c3d = CopyC3d(drop.Pos.D3)
			c3d.Ypos = rndb(1500,2000)
			c3d.Xpos = G_RANDOM (65500)
			c3d.Zpos = G_RANDOM (65500)
			move_thing_within_mapwho(drop,c3d)
			local direction = rndb(0,3)
			table.insert(ashDroplets,{drop,direction})
		end
	end
end

function ashFall(intensity,processWhilePaused)
	local function StopAshHailChance(rrnd,dropThing)
		--chance of splash
		if rnd() < rrnd then
			local splash = createThing(T_EFFECT,M_EFFECT_SMOKE,8,dropThing.Pos.D3,false,false)
		end
		local c3d = CopyC3d(dropThing.Pos.D3)
		c3d.Ypos = rndb(1600,2000)
		c3d.Xpos = G_RANDOM (65500)
		c3d.Zpos = G_RANDOM (65500)
		move_thing_within_mapwho(dropThing,c3d)
	end
	local function process()
		if #ashDroplets > 0 then
			for i = 1,#ashDroplets do
				local v = ashDroplets[i][1]
				if i <= #ashDroplets and v ~= nil then
					if v.Pos.D3.Ypos > (point_altitude(ThingX(v),ThingZ(v))-16) then
						AshDirection(v,intensity,ashDroplets[i][2])
					else
						if ashhail == 1 then
							StopAshHailChance(20,v)
						else
							if fastStopAshhail == 0 then
								StopAshHailChance(8,v)
							else
								if rnd() < 32 then
									v.u.Effect.Duration = 1
									table.remove(ashDroplets,i)
								else
									StopAshHailChance(20,v)
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

--fall+direction
function AshDirection(thing,intensidade,direccao)
	if thing ~= nil then
		thing.Pos.D3.Ypos = thing.Pos.D3.Ypos - intensidade
		local xz = CopyC3d(thing.Pos.D3)
		local a = direccao
		if a == 0 then
			xz.Xpos = xz.Xpos - intensidade
		elseif a == 1 then
			xz.Xpos = xz.Xpos + intensidade
		elseif a == 2 then
			xz.Zpos = xz.Zpos - intensidade
		else
			xz.Zpos = xz.Zpos + intensidade
		end
		move_thing_within_mapwho(thing, xz)
	end
end

--[[
place inside onframe:
	ashFall(2,false)(3,false) --intensity[1-3],process while paused

create ash this way:
	createAshhail(400,3) --amount,type (multi,dark,darkgrey,lightgrey)
	
stop ash this way:
	ashhail = 0 
	fastStopAshhail = 1 --0 for slow stopping, 1 for fast

--------------------------
ONSAVE

	for i = 1,#ashDroplets do
		local t = ashDroplets[i][1]
		if (t ~= nil) then save_data:push_int(t.ThingNum) end
	end
	save_data:push_int(#ashDroplets)
	save_data:push_int(ashhail)
	save_data:push_int(fastStopAshhail)
	save_data:push_int(AshHailStyleBeingUsed)
	
ONLOAD

	AshHailStyleBeingUsed = load_data:pop_int()
	fastStopAshhail = load_data:pop_int()
	ashhail = load_data:pop_int()
	local num_droplets = load_data:pop_int()
	for i = 1, num_droplets do
		local t = GetThing(load_data:pop_int())
		if (t ~= nil) then
			local style,spr = AshHailStyleBeingUsed,rndb(1740,1754)
			if style == 1 then spr = rndb(1740,1744) elseif style == 2 then spr = rndb(1745,1749) elseif style == 3 then spr = rndb(1750,1754) end
			set_thing_draw_info(t,TDI_SPRITE_F1_D1, spr) table.insert(ashDroplets, {t,rndb(0,3)}) 
		end
	end
]]