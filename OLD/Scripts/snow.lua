--snow

snowing = 0
snowDroplets = {}
snowStuff = {
	--snowAmtTarget, CreationAmtPerSecCreation, speed, (durationSeconds, internTimer), fadeSeconds
	0,0,0,0,0,0
}

function createSnow(amount, CreationAmtPerSec, speed, durationSeconds, fadeSeconds)
	if snowing == 0 then
		snowing = 1
		snowStuff[1] = amount
		snowStuff[2] = CreationAmtPerSec
		snowStuff[3] = speed
		snowStuff[4] = durationSeconds
		snowStuff[5] = durationSeconds
		snowStuff[6] = fadeSeconds
	end
end

function EndSnow()
	snowing = 0
	snowDroplets = {}
	snowStuff = {0,0,0,0,0,0}
end

function FlooredFlakes()
	for i = 0,128 do
		local rndflake = randomItemFromTable(snowDroplets)
		if nilT(rndflake) then
			if rndflake.Move.Velocity.Y == 0 then
				local c3d = CopyC3d(rndflake.Pos.D3)
				c3d.Ypos = rndb(1500,2000)
				c3d.Xpos = G_RANDOM (65500)
				c3d.Zpos = G_RANDOM (65500)
				move_thing_within_mapwho(rndflake,c3d)
			end
		end
	end
end

function _SnowOnTurn()
	if snowing == 1 then
		if everySeconds(1) then
			FlooredFlakes()
			if snowStuff[5] > 0 then snowStuff[5] = snowStuff[5] - 1 else EndSnow() return end
			if #snowDroplets < snowStuff[1] then
				for i = 0, snowStuff[2] do
					local drop = createThing(T_EFFECT,M_EFFECT_LIGHTNING_ELEM,8,marker_to_coord3d(0),false,false)
					drop.u.Effect.Duration = 12*snowStuff[4] + 12*(G_RANDOM(snowStuff[6]))
					local c3d = CopyC3d(drop.Pos.D3)
					c3d.Ypos = rndb(1500,2000)
					c3d.Xpos = G_RANDOM (65500)
					c3d.Zpos = G_RANDOM (65500)
					move_thing_within_mapwho(drop,c3d)
					set_thing_draw_info(drop,0, rndb(1755,1766))
					drop.Move.SelfPowerSpeed = snowStuff[3]
					drop.Move.CurrDest.Angles.ZY = 1024
					table.insert(snowDroplets,drop)				
				end
			end
		end
	end
end