
weather = {
			[WEATHER_SNOW] = { min = 1755, max = 1766 },
			[WEATHER_ASH_PARTICLES] = { min = 1740, max = 1754, horizontal_movement = true },
			[WEATHER_RAIN] = { min = 1734, max = 1739, instant_reset = true, splash = true },
}

_NO_WEATHER = 0
_WEATHER_STARTING = 1
_WEATHER_ON_GOING = 2
_WEATHER_ENDING = 3

local weather_table = { 	
						weather_type = WEATHER_NONE,
						state = _NO_WEATHER,
						droplets = {},
						amount = 0,
						per_second_spawn = 0,
						speed = 0,
						duration_seconds = 0,
						turn_weather_ends = 0
}

local function weather_state()
	return weather_table.state
end

local function set_weather_state(state)
	weather_table.state = state
end

local function clear_weather_items()
	local items = #weather_table.droplets
	if items > 0 then
		for i = items, 1, -1 do
			local item = weather_table.droplets[i]
			if item ~= nil then
				item.u.Effect.Duration = 1
			end
		end
	end
	weather_table.droplets = {}
end

function is_any_weather_event_happening()
	return weather_table.state ~= _NO_WEATHER
end

function is_this_weather_event_happening(event)
	if is_any_weather_event_happening() then
		return weather_table.weather_type == event
	end
	
	return false
end

function set_weather_speed(speed)
	if is_any_weather_event_happening() then
		weather_table.speed = speed
		local items = #weather_table.droplets
		for k, item in ipairs(weather_table.droplets) do
			if item then
				if item.Type == T_EFFECT and item.Model == M_EFFECT_LIGHTNING_ELEM then
					item.Move.SelfPowerSpeed = speed
				end
			end
		end
	end
end

function increase_weather_speed_by(amt)
	set_weather_speed(weather_table.speed + amt)
end

function set_weather_particles_amt(new_amt)
	if weather_state() == _WEATHER_ON_GOING then
		if new_amt > weather_table.amount then
			set_weather_state(_WEATHER_STARTING)
			weather_table.amount = new_amt
		end
	end
end

function start_weather(type, amount, per_second_spawn, speed, duration_seconds)
	if weather_state() == _NO_WEATHER then
		weather_table.weather_type = type
		set_weather_state(_WEATHER_STARTING)
		weather_table.amount = amount
		weather_table.per_second_spawn = per_second_spawn
		weather_table.speed = speed
		weather_table.duration_seconds = duration_seconds
		weather_table.turn_weather_ends = getTurn() + duration_seconds * 12
		clear_weather_items()
	end
end

function stop_weather()
	if weather_state() == _WEATHER_ON_GOING then
		weather_table.weather_type = WEATHER_NONE
		weather_table.state = _WEATHER_ENDING
	end
end

function process_weather(turn)
	local state = weather_table.state
	
	if state == _NO_WEATHER then
		return
	end
	
	local items = #weather_table.droplets
	local every1 = everySeconds(1)
	local weather_tbl = weather[weather_table.weather_type]
	
	if state == _WEATHER_STARTING then
		if every1 then
			if items < weather_table.amount then
				local spawn_amt_max = math.floor(weather_table.per_second_spawn * (0.5 + math.random()))
				local spawn_amt = math.min(spawn_amt_max, weather_table.amount - items)
				local pos = marker_to_coord3d(0)
				local dur = 12 * weather_table.duration_seconds
				local spr_min, spr_max = weather_tbl.min, weather_tbl.max
				
				for _ = 1, spawn_amt do
					local drop = createThing(T_EFFECT, M_EFFECT_LIGHTNING_ELEM, 8, pos, false, false)
					drop.u.Effect.Duration = dur + 12 * rndb(5, 15)
					local c3d = CopyC3d(drop.Pos.D3)
					c3d.Ypos = rndb(1500, 2000)
					c3d.Xpos = G_RANDOM (65500)
					c3d.Zpos = G_RANDOM (65500)
					move_thing_within_mapwho(drop, c3d)
					set_thing_draw_info(drop, 0, rndb(spr_min,spr_max))
					drop.Move.SelfPowerSpeed = weather_table.speed
					drop.Move.CurrDest.Angles.ZY = 1024
					table.insert(weather_table.droplets, drop)	
				end
			else
				set_weather_state(_WEATHER_ON_GOING)
			end
		end
	elseif state == _WEATHER_ON_GOING then
		if turn >= weather_table.turn_weather_ends then
			set_weather_state(_WEATHER_ENDING)
		end
	elseif state == _WEATHER_ENDING then
		if items > 0 then
			if every1 then
				local fade_amt = clamp(mf(items, 3), 1, items)
				
				for i = items, items - fade_amt, -1 do
					local item = weather_table.droplets[i]
					
					if item then
						if item.Type == T_EFFECT and item.Model == M_EFFECT_LIGHTNING_ELEM then
							item.u.Effect.Duration = 1
						end
					end
					
					table.remove(weather_table.droplets, i)
				end
			end
		else
			set_weather_state(_NO_WEATHER)
			weather_table.weather_type = WEATHER_NONE
		end
	end
	
	items = #weather_table.droplets
	
	if items > 0 then
		local reset_amt = 0
		
		if every1 then
			reset_amt = clamp(mf(items, 3), 1, items)
		end
		
		for i = 1, items do
			local item = weather_table.droplets[i]
			
			if item then
				if item.Type == T_EFFECT and item.Model == M_EFFECT_LIGHTNING_ELEM then
					if item.Move.Velocity.Y == 0 then
						if weather_tbl.instant_reset or i <= reset_amt then
							local c3d = CopyC3d(item.Pos.D3)
							
							if weather_tbl.splash then
								if chance(10 + 15 * btn(is_c3d_water(c3d))) then
									local splash = createThing(T_EFFECT, M_EFFECT_SPLASH, 8, c3d, false, false)
								end
							end
							
							c3d.Ypos = rndb(1500, 2000)
							c3d.Xpos = G_RANDOM (65500)
							c3d.Zpos = G_RANDOM (65500)
							move_thing_within_mapwho(item, c3d)
						end
					else
						if weather_tbl.horizontal_movement then
							local c3d = CopyC3d(item.Pos.D3)
							c3d.Ypos = c3d.Ypos + rndb(0, 8)
							c3d.Xpos = c3d.Xpos + rndb(-16, 16)
							c3d.Zpos = c3d.Zpos + rndb(-16, 16)
							move_thing_within_mapwho(item, c3d)
						end
					end
				end
			end
		end
	end
end