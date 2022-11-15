--examples of quick functions that you can use on levels (just need to edit values inside at your taste)






--------------------------------------------------------
Plant(4,7,-1) --this would plant scenery flowers on markers 4 to 7 (random type of flower on each marker)
Plant(8,11,1887) --this would plant scenery flowers on markers 8 to 11 (all flowers are the same type (index 1888 on hfx (yellow flower)))
--------------------------------------------------------





--all the following must be inside onturn

function OnTurn()
	--------------------------------------------------------
	Sulk(TRIBE_RED,6) --red give up and sulk when pop lower than 6
	burnTrees(60,TRIBE_RED,84,126,10) --red shaman blasts a tree every 60 seconds, while inside the (84,126) zone (10 radius) -> this zone is blue's base center
	useShield(90,TRIBE_RED,84,126,10) --every 1.5 minutes, red shaman will shield a location that has an unit, as long as she's inside (84,126) zone (10 radius) -> blue's base
									  --basically, offensive shielding when inside blue's base (could target 1 warrior, or, if lucky, a group of them)
									  --obv can be used in any zone, eg.: defensive, like inside own base
	fasterTrain(TRIBE_RED) --red will train units faster (scaling with difficulty)
	fasterHutBars(TRIBE_RED) --red's huts will upgrade/sproggle faster (scaling with difficulty)
	updateGameStage(5,10,15,20) --this continuously updates the gameStage variable (useful for coding stuff depending if it's early-mid or late-game)
								--in this level example, very early game is from 0 to 5 mins ; early from 5 to 10 ; mid from 10 to 15 ; late from 15 to 20 ; anything later is very lategame
								--just set the values, and then freely use the 'gameStage' variable wherever (no need to initialize it)
								--  0-5mins: very early -> variable (gameStage) returns 0
								--  5-10mins: early -> variable (gameStage) returns 1
								--  10-15mins: middle -> variable (gameStage) returns 2
								--  15-20mins: late -> variable (gameStage) returns 3
								--  20+mins: very late -> variable (gameStage) returns 4
								--			with this variable, you can do anything. example: (train troops, scaling with the stage of the game)
								-- 					* Train(warriors, 5+gameStage) *
								--			in that example, if it's early game (<5m), it will train 5+0 warriors. if it's lategame (15-20m), it will train 5+3 warriors, etc
								--			so basically it will train 5+0, 5+1, 5+2, 5+3, or 5+4 (depending if it's early-->very late)
								
end