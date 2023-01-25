footer_msgs = {}

function FooterMsg(msg, speed, spr)
	table.insert(footer_msgs, {msg = msg, speed = speed, pos = ScreenWidth() + 2, spr = spr})
end

function _FooterMsgOnFrame(w,h,guiW)
	if #footer_msgs > 0 then
		PopSetFont(3)
		local barH = CharHeight2() + 2 + 2
		local str = {}
		for i = 1,#footer_msgs[1].msg do table.insert(str, string.sub(footer_msgs[1].msg, i, i)) end
		local fade = w - (footer_msgs[1].pos + string_width(footer_msgs[1].msg))
		DrawBox(guiW, h-barH, w-guiW-fade, barH,1)
		DrawBox(guiW, h-barH*2, barH, barH,5)
		DrawBox(guiW+1, h-barH*2+1, barH-2, barH-2,1)
		LbDraw_ScaledSprite(guiW+1, h-barH*2+1,get_sprite(0,footer_msgs[1].spr),barH-2,barH-2)
		if footer_msgs[1].pos + string_width(footer_msgs[1].msg) > guiW - 32 then
			footer_msgs[1].pos = footer_msgs[1].pos - footer_msgs[1].speed
			local offset = 0
			for k,v in ipairs(str) do
				if footer_msgs[1].pos + offset > guiW then
					LbDraw_Text(footer_msgs[1].pos + offset, h-barH+2, v, 0)
				end
				offset = offset + string_width(v)
			end
		else
			table.remove (footer_msgs,1)
		end
		if #footer_msgs > 1 then
			PopSetFont(11)
			DrawBox(guiW+barH, h-barH-CharHeight2()-6, CharWidth2()+6, CharHeight2()+6, 5)
			DrawBox(guiW+barH+1, h-barH-CharHeight2()-6+1, CharWidth2()+6-2, CharHeight2()+6-2, 1)
			local str = "" .. #footer_msgs
			LbDraw_Text(guiW+barH+1+2, h-barH-CharHeight2()-4+2,str,0)
		end
	end
end	