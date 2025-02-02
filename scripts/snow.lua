NOT_SNOWING = 0
SNOW_STARTING = 1
SNOWING = 2
SNOW_ENDING = 3

local snow_table = { 	
						state = NOT_SNOWING,
						droplets = {},
						amount = 0,
						per_second_spawn = 0,
						speed = 0,
						duration_seconds = 0,
						turn_snow_ends = 0
}

local function snow_state()
	return snow_table.state
end

local function set_snow_state(state)
	snow_table.state = state
end

local function clear_snow_items()
	local items = #snow_table.droplets
	if items > 0 then
		for i = items, 1, -1 do
			local item = snow_table.droplets[i]
			if item ~= nil then
				item.u.Effect.Duration = 1
			end
		end
	end
	snow_table.droplets = {}
end

function start_snowing(amount, per_second_spawn, speed, duration_seconds)
	if snow_state() == NOT_SNOWING then
		set_snow_state(SNOW_STARTING)
		snow_table.amount = amount
		snow_table.per_second_spawn = per_second_spawn
		snow_table.speed = speed
		snow_table.duration_seconds = duration_seconds
		snow_table.turn_snow_ends = getTurn() + duration_seconds * 12
		clear_snow_items()
	end
end

function stop_snowing()
	if snow_state() == SNOWING then
		snow_table.state = SNOW_ENDING
	end
end

function process_snow(turn)
	local state = snow_table.state
	
	if state == NOT_SNOWING then
		return
	end
	
	local items = #snow_table.droplets
	local every1 = everySeconds(1)
	
	if state == SNOW_STARTING then
		if every1 then
			if items < snow_table.amount then
				local spawn_amt_max = math.floor(snow_table.per_second_spawn * (0.5 + math.random()))
				local spawn_amt = math.min(spawn_amt_max, snow_table.amount - items)
				local pos = marker_to_coord3d(0)
				local dur = 12 * snow_table.duration_seconds
				
				for _ = 1, spawn_amt do
					local drop = createThing(T_EFFECT, M_EFFECT_LIGHTNING_ELEM, 8, pos, false, false)
					drop.u.Effect.Duration = dur + 12 * rndb(5, 15)
					local c3d = CopyC3d(drop.Pos.D3)
					c3d.Ypos = rndb(1500, 2000)
					c3d.Xpos = G_RANDOM (65500)
					c3d.Zpos = G_RANDOM (65500)
					move_thing_within_mapwho(drop, c3d)
					set_thing_draw_info(drop, 0, rndb(1755,1766))
					drop.Move.SelfPowerSpeed = snow_table.speed
					drop.Move.CurrDest.Angles.ZY = 1024
					table.insert(snow_table.droplets, drop)	
				end
			else
				set_snow_state(SNOWING)
			end
		end
	elseif state == SNOWING then
		if turn >= snow_table.turn_snow_ends then
			set_snow_state(SNOW_ENDING)
		end
	elseif state == SNOW_ENDING then
		if items > 0 then
			if every1 then
				local fade_amt = clamp(mf(items, 3), 1, items)
				
				for i = items, items - fade_amt, -1 do
					local item = snow_table.droplets[i]
					
					if item then
						if item.Type == T_EFFECT and item.Model == M_EFFECT_LIGHTNING_ELEM then
							item.u.Effect.Duration = 1
						end
					end
					
					table.remove(snow_table.droplets, i)
				end
			end
		else
			set_snow_state(NOT_SNOWING)
		end
	end
	
	items = #snow_table.droplets
	
	if items > 0 and every1 then
		local reset_amt = clamp(mf(items, 3), 1, items)
		
		for i = 1, reset_amt do
			local item = snow_table.droplets[i]
			
			if item then
				if item.Type == T_EFFECT and item.Model == M_EFFECT_LIGHTNING_ELEM then
					if item.Move.Velocity.Y == 0 then
						local c3d = CopyC3d(item.Pos.D3)
						c3d.Ypos = rndb(1500, 2000)
						c3d.Xpos = G_RANDOM (65500)
						c3d.Zpos = G_RANDOM (65500)
						move_thing_within_mapwho(item,c3d)
					end
				end
			end
		end
	end
end