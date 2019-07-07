--[[
   Copyright 2007-2019 The OpenRA Developers (see AUTHORS)
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

Grenadiers = { "e2", "e2", "e2" }

PatrolWaypoints =
{
	{ ETHPatrol1A.Location , ETHPatrol1B.Location },
	{ ETHPatrol2A.Location , ETHPatrol2B.Location },
	{ ETHPatrol3A.Location , ETHPatrol3B.Location },
	{ ETHPatrol4A.Location , ETHPatrol4B.Location },
	{ ETHPatrol5A.Location , ETHPatrol5B.Location }
}

SpawnPatrollers = function()
	ETHRCav1 = Actor.Create("riflecav", true, { Owner = ethiopia, Location = PatrolWaypoints[1][1] })
	ETHRCav2 = Actor.Create("riflecav", true, { Owner = ethiopia, Location = PatrolWaypoints[1][1] })
	ETHHalftrack3 = Actor.Create("ftrk", true, { Owner = ethiopia, Location = PatrolWaypoints[2][1] })
	ETHRifle1 = Actor.Create("e1", true, { Owner = ethiopia, Location = PatrolWaypoints[3][1] })
	ETHRifle2 = Actor.Create("e1", true, { Owner = ethiopia, Location = PatrolWaypoints[3][1] })
	ETHRifle3 = Actor.Create("e1", true, { Owner = ethiopia, Location = PatrolWaypoints[3][1] })
	ETHLTank2 = Actor.Create("1tnk", true, { Owner = ethiopia, Location = PatrolWaypoints[4][1] })
	ETHDog1 = Actor.Create("dog", true, { Owner = ethiopia, Location = PatrolWaypoints[5][1] })
	ETHDog2 = Actor.Create("dog", true, { Owner = ethiopia, Location = PatrolWaypoints[5][1] })

	ETHRCav1.Patrol(PatrolWaypoints[1], true, DateTime.Seconds(4))
	ETHRCav2.Patrol(PatrolWaypoints[1], true, DateTime.Seconds(4))
	ETHHalftrack3.Patrol(PatrolWaypoints[2], true, DateTime.Seconds(3))
	ETHRifle1.Patrol(PatrolWaypoints[3], true, DateTime.Seconds(3))
	ETHRifle2.Patrol(PatrolWaypoints[3], true, DateTime.Seconds(3))
	ETHRifle3.Patrol(PatrolWaypoints[3], true, DateTime.Seconds(3))
	ETHLTank2.Patrol(PatrolWaypoints[4], true, DateTime.Seconds(6))
	ETHDog1.Patrol(PatrolWaypoints[5], true, DateTime.Seconds(2))
	ETHDog2.Patrol(PatrolWaypoints[5], true, DateTime.Seconds(2))
end

Intro = function()
	Media.DisplayMessage("We have a base established up here.", "Lieutenant", italy.Color)

	IntroFlak.Move(IntroMove.Location)
	IntroFlak.AttackMove(ETHTurret1.Location)
	IntroFlak.GrantCondition("RejectsOrders")

	ETHHalftrack1.Stance = "Defend"
	ETHHalftrack2.Stance = "Defend"

	Trigger.OnDamaged(IntroFlak, function(self, attacker)
		if IntroFlak.Health < IntroFlak.MaxHealth * 3 / 4 then
			IntroFlak.Stop()
			IntroFlak.Move(IntroMove.Location)
			IntroFlak.Move(ITAConYard.Location)

			if not damagedMessage then
				Media.DisplayMessage("The Ethiopian base is down here.", "Lieutenant", italy.Color)

				damagedMessage = true
			end

			if attacker.Type == "1tnk" and not tankMessage then
				Media.DisplayMessage("They have vehicles in the area already, we need to expand our base.", "Lieutenant", italy.Color)

				tankMessage = true
			end
		end
	end)

	Trigger.OnKilled(IntroFlak, function(self, attacker)
		Trigger.AfterDelay(DateTime.Seconds(2), function()
			Camera.Position = ITAConYard.CenterPosition

			NewRefinery()
		end)
	end)
end

NewRefinery = function()
	ITAMiner1 = italy.GetActorsByType("harv")[1]

	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("Before that though, that Gem patch is about to run out, let's build a new Refinery near the Ore.", "Lieutenant", italy.Color)
	end)
end

SellOldRefinery = function()
	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("Good, now we no longer need that old refinery.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("You can sell a building by using the Sell button at the Top-Right.", "Lieutenant", italy.Color)
			Trigger.AfterDelay(DateTime.Seconds(3), function()
				Media.DisplayMessage("Click the button and then click the Old Refinery to sell it.", "Lieutenant", italy.Color)

				if not ITARefinery.IsDead then
					Trigger.OnSold(ITARefinery, function()
						Trigger.AfterDelay(DateTime.Seconds(3), function()
							Media.DisplayMessage("Selling a building gives you 50% of its cost back.", "Lieutenant", italy.Color)
							Trigger.AfterDelay(DateTime.Seconds(3), function()
								Media.DisplayMessage("Though, Refinery and PillBox have special case, cost of the Free Ore Miner and Rifle Infantry from them is reduced before calculating the money you get back.", "Lieutenant", italy.Color)
								
								GrenadierAttack()
							end)
						end)
					end)
				else
					Trigger.AfterDelay(DateTime.Seconds(6), function()
						Media.DisplayMessage("Selling a building gives you 50% of its cost back.", "Lieutenant", italy.Color)
						Trigger.AfterDelay(DateTime.Seconds(3), function()
							Media.DisplayMessage("Though, Refinery and PillBox have special case, cost of the Free Ore Miner and Rifle Infantry from them is reduced before calculating the money you get back.", "Lieutenant", italy.Color)
								
							GrenadierAttack()
						end)
					end)
				end
			end)
		end)
	end)
end

GrenadierAttack = function()
	local grens = Reinforcements.Reinforce(ethiopia, Grenadiers, { ETHGrenSpawn.Location, ETHGrenRally.Location })
	local ref = italy.GetActorsByType("proc")[1]
	Utils.Do(grens, function(gren)
		gren.Attack(ref)
	end)

	Trigger.OnDamaged(ref, function()
		if ref.Health < ref.MaxHealth / 4 then
			invuln = ref.GrantCondition("invuln")
		end
	end)

	Trigger.OnAllKilled(grens, function()
		if invuln ~= nil then
			ref.RevokeCondition(invuln)
		end

		Repair(ref)
	end)

	Trigger.AfterDelay(DateTime.Seconds(12), function()
		Media.DisplayMessage("They are flanking us with Grenadiers.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(2), function()
			Media.DisplayMessage("To select multipile units, click and hold to draw a selection box. When you release the mouse button, all the units in the box will be selected.", "Lieutenant", italy.Color)
			Trigger.AfterDelay(DateTime.Seconds(3), function()
				Media.DisplayMessage("Then click on the enemy units to attack them.", "Lieutenant", italy.Color)
			end)
		end)
	end)
end

Repair = function(ref)
	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("Good work. They should think twice before doing that again.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("They have damaged the refinery though. We should repair it.", "Lieutenant", italy.Color)
			Trigger.AfterDelay(DateTime.Seconds(3), function()
				Media.DisplayMessage("Like selling, repairing is done via its button on Top-Right of the screen.", "Lieutenant", italy.Color)
				Trigger.AfterDelay(DateTime.Seconds(3), function()
					Media.DisplayMessage("Click the Repair button, then click the refinery to start repairing it.", "Lieutenant", italy.Color)
					Trigger.AfterDelay(DateTime.Seconds(6), function()
						Media.DisplayMessage("Repairing will be done slowly and cost credit, if you are low on funds it'll stop units you get some.", "Lieutenant", italy.Color)
						Trigger.AfterDelay(DateTime.Seconds(3), function()
							Media.DisplayMessage("You can click on the building once again to stop repairing. It'll automatically stop once building is fully repaired.", "Lieutenant", italy.Color)

							if ref.Health < ref.MaxHealth / 2 then
								Trigger.OnDamaged(ref, function()
									if not refhealth and ref.Health >= ref.MaxHealth / 2 then
										refhealth = true

										BuildPBox()
									end
								end)
							else
								Trigger.AfterDelay(DateTime.Seconds(6), function()
									refhealth = true

									BuildPBox()
								end)
							end
						end)
					end)
				end)
			end)
		end)
	end)
end

BuildPBox = function()
	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("We should ensure that this doesn't happen again. Let's build a PillBox there.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("PillBox and all the other Static Defences can be found in the Support Queue.", "Lieutenant", italy.Color)

			pboxobjective = true
		end)
	end)
end

ExpandWall = function()
	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("That flank is now covered, though we need to do something about the left side too.", "Lieutenant", italy.Color)
		local camera = Actor.Create("camera", true, { Owner = italy, Location = WallCameraWaypoint.Location })
		camera.Destroy()

		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("We should expand it to up to the top, but it is too far away to complete the wall.", "Lieutenant", italy.Color)
			Trigger.AfterDelay(DateTime.Seconds(3), function()
				Media.DisplayMessage("Let's build a Stable above the Power Plant there, so we can complete the wall.", "Lieutenant", italy.Color)

				stableobjective = true
			end)
		end)
	end)
end

OilDerrick = function()
	Trigger.AfterDelay(DateTime.Seconds(5), function()
		Media.DisplayMessage("We have pretty much mined all the Ore here, a single Ore Mine doesn't produce much.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("There is an Oil Derrick under Ethiopian control here, we should capture it.", "Lieutenant", italy.Color)

			local camera = Actor.Create("camera", true, { Owner = italy, Location = ETHDerrick1.Location })
			Camera.Position = ETHDerrick1.CenterPosition
			Trigger.AfterDelay(DateTime.Seconds(3), function()
				Media.DisplayMessage("They have a PillBox and some Dogs guarding it. You should build some Grenadier Cavalry to destroy the PillBox. 6 or 7 should be enough.", "Lieutenant", italy.Color)
				Trigger.AfterDelay(DateTime.Seconds(3), function()
					Media.DisplayMessage("Dogs are effective units against Infantry, but they can't attack Cavalry.", "Lieutenant", italy.Color)

					camera.Destroy()
					local guards = { ETHPillBox4, ETHDog1, ETHDog2 }
					Trigger.OnAllKilled(guards, CaptureDerrick)
				end)
			end)
		end)
	end)
end

CaptureDerrick = function()
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Media.DisplayMessage("Good, now we can capture the derrick.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("To capture a building, you need an Engineer. Train an Engineer and order it to the Oil Derrick to capture it.", "Lieutenant", italy.Color)

			if ETHDerrick1.Owner ~= italy then
				Trigger.OnCapture(ETHDerrick1, function()
					BuildMedic()
				end)
			else
				Trigger.AfterDelay(DateTime.Seconds(3), function()
					BuildMedic()
				end)
			end
		end)
	end)
end

BuildMedic = function()
	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("Oil Derricks provide $100 every once a while.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("Some of the units took damage from the PillBox fire, you can use Medics to heal your Infantry and Cavalry.", "Lieutenant", italy.Color)

			BuildWFac()
		end)
	end)
end

BuildWFac = function()
	Trigger.AfterDelay(Actor.BuildTime("medi") * 2, function()
		Media.DisplayMessage("Now we should build a War Factory so we can get a sizeable Attack Force up.", "Lieutenant", italy.Color)

		weapobjective = true
	end)
end

IntroduceVehicles = function()
	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("We don't need any more Ore Miners, 2 is more than enough for one Ore Mine, but you should go build other 3 vehicles available.", "Lieutenant", italy.Color)
		Trigger.OnProduction(italy.GetActorsByType("weap")[1], function(producer, produced)
			if not apcdesc and produced.Type == "apc" then
				apcdesc = true

				Media.DisplayMessage("The Infantry Fighting Vehicle is a custom vehicle of the Italian Army. Others don't use something like this.", "Lieutenant", italy.Color)
				Trigger.AfterDelay(DateTime.Seconds(3), function()
					Media.DisplayMessage("It can carry up to 5 Infantry and allow them to fire outside from the Vehicle. It is not armed otherwise if there is no Infantry in it, but when built it comes with a Rifle Infantry in it.", "Lieutenant", italy.Color)
				end)
			elseif not ltnkdesc and produced.Type == "1tnk" then
				ltnkdesc = true

				Media.DisplayMessage("The Light Tank is a fast armored vehicle which is really resistant to bullet weapons.", "Lieutenant", italy.Color)
				Trigger.AfterDelay(DateTime.Seconds(3), function()
					Media.DisplayMessage("Their weapon do not deal much of a damage but they can be powerful in groups when used with Hit and Run tactics.", "Lieutenant", italy.Color)
				end)
			elseif not ftrkdesc and produced.Type == "ftrk" then
				ftrkdesc = true

				Media.DisplayMessage("The Halftrack is a light Anti-Infantry and Anti-Air vehicle.", "Lieutenant", italy.Color)
				Trigger.AfterDelay(DateTime.Seconds(3), function()
					Media.DisplayMessage("It can carry 2 Infantry, but those cannot fire outside.", "Lieutenant", italy.Color)
				end)
			end
		end)
	end)
end

FirstAttack = function()
	Trigger.AfterDelay(DateTime.Seconds(9), function()
		Media.DisplayMessage("We should go check the state of enemy defences. Maybe we can go around somehere.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("Let's fill that IFV with Grenadiers and see if we can do something.", "Lieutenant", italy.Color)

			Trigger.AfterDelay(DateTime.Seconds(30), function()
				Media.DisplayMessage("This area seems to be guarded less. Maybe we can go around the base, there seems to be a Bridge above the river.", "Lieutenant", italy.Color)

				local camera = Actor.Create("camera", true, { Owner = italy, Location = ETHTurret3.Location })
				camera.Destroy()

				-- Trigger.OnAnyDamaged(italy.GetActorsByTypes( { "apc", "1tnk", "ftrk" } ), function()
					-- if not repair then
						-- Media.DisplayMessage("To repair vehicles, you need a Service Depot. You can also sell vehicles on the Service Depot.", "Lieutenant", italy.Color)
					-- end
				-- end)

				local towndefences = { ETHPillBox5, ETHPillBox6, ETHTurret3 }
				Trigger.OnAllKilled(towndefences, function()
					Media.DisplayMessage("This Bridge seems to be an easy access to the enemy base. Gather all your troops and attack from there.", "Lieutenant", italy.Color)

					ActivateAI()
					Camera.Position = BridgeWaypoint.CenterPosition
					local camera = Actor.Create("camera", true, { Owner = italy, Location = BridgeWaypoint.Location })
					camera.Destroy()
				end)
			end)
		end)
	end)
end

Tick = function()
	if not IntroFlak.IsDead then
		Camera.Position = IntroFlak.CenterPosition
	end

	if not refineryBuilt and #Utils.Where(italy.GetActorsByType("proc"), function(ref) return ref.Location.X > 24 end) > 0 then
		refineryBuilt = true

		SellOldRefinery()
	end

	if not minerMessage and ITAMiner1 ~= nil and ITAMiner1.IsIdle then
		Media.DisplayMessage("Ore Miner is idle now, you should send it to the Ore Patch manually.", "Lieutenant", italy.Color)

		minerMessage = true
	end

	if pboxobjective and #Utils.Where(italy.GetActorsByType("pbox"), function(pbox) return pbox.Location.X > 24 and pbox.Location.Y < 9 end) > 0 then
		pboxobjective = false

		ExpandWall()
	end

	if stableobjective and #Utils.Where(italy.GetActorsByType("tent"), function(tent) return tent.Location.X < 10 and tent.Location.Y < 8 end) > 0 then
		stableobjective = false

		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.DisplayMessage("Good. You can now build cavalry from the Cavalry Queue, shown with a Horseshoe.", "Lieutenant", italy.Color)
			Trigger.AfterDelay(DateTime.Seconds(3), function()
				Media.DisplayMessage("Cavalry are overall better than Infantry, but they cost more and not all Infantry have Cavalry variant.", "Lieutenant", italy.Color)
				Trigger.AfterDelay(DateTime.Seconds(5), function()
					Media.DisplayMessage("Walls are placed in lines. When you put down a wall, up to 6 cell between the wall you place and an old wall is also filled with walls.", "Lieutenant", italy.Color)
					
					wallobjective = true
				end)
			end)
		end)
	end

	if wallobjective and #Utils.Where(italy.GetActorsByType("brik"), function(brik) return brik.Location.X == 5 and brik.Location.Y < 8 end) >= 7 then
		wallobjective = false

		OilDerrick()
	end

	if weapobjective and #italy.GetActorsByType("weap") > 0 then
		weapobjective = false

		IntroduceVehicles()
	end
	
	if not firstattack and apcdesc and ltnkdesc and ftrkdesc then
		firstattack = true

		FirstAttack()
	end

	if not outro and ethiopia.HasNoRequiredUnits() then
		outro = true

		Media.DisplayMessage("Nice work, Commander. With this defence line broken. We should easily push them to the Capital.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(5), function()
			italy.MarkCompletedObjective(MainObjective)
		end)
	end
end

WorldLoaded = function()
	italy = Player.GetPlayer("Italy")
	ethiopia = Player.GetPlayer("Ethiopia")

	DefendAndRepairBase(ethiopia, Base, 0.75, 6)
	IdlingUnits[ethiopia] = { }
	InitObjectives(italy)
	SpawnPatrollers()

	Intro()

	MainObjective = italy.AddPrimaryObjective("Destroy all the Ethiopian forces in the area.")

	EthiopiaProduction = { ETHConYard, ETHBarracks, ETHStable, ETHWFac }
	Trigger.OnAllKilled(EthiopiaProduction, function()
		local ethiopiaUnits = ethiopia.GetGroundAttackers()

		if #ethiopiaUnits > 0 then
			Utils.Do(ethiopiaUnits, function(a)
				a.Stop()
				IdleHunt(a)
			end)
		end
	end)
end
