--[[
   Copyright 2007-2019 The OpenRA Developers (see AUTHORS)
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

SpawnMCV = function()
	local transport = Actor.Create("lst.mcv", true, { Owner = italy, Location = MCVSpawn.Location })
	transport.Move(MCVMove1.Location)
	transport.Move(MCVMove2.Location)

	Trigger.AfterDelay(DateTime.Seconds(6), function()
		Media.DisplayMessage("The Mobile Construction vehicle has arrived.", "Lieutenant", italy.Color)
		EstablishBase = italy.AddPrimaryObjective("Land your MCV and establish a base.")

		Trigger.AfterDelay(DateTime.Seconds(4), function()
			Media.DisplayMessage("Click on the transport boat to select it.", "Lieutenant", italy.Color)

			Trigger.AfterDelay(DateTime.Seconds(3), function()
				Media.DisplayMessage("Then click near the beach to move it there.", "Lieutenant", italy.Color)

				flare = Actor.Create("flare", true, { Owner = italy, Location = LandingZone.Location })
				Trigger.OnEnteredFootprint({LandingZone.Location}, function(a, id)
					if a ~= transport then
						return
					end

					Trigger.RemoveFootprintTrigger(id)
					Media.DisplayMessage("Now click on the transport again to unload it.", "Lieutenant", italy.Color)
				end)
			end)
		end)
	end)
end

MCVLanded = function()
	Trigger.AfterDelay(DateTime.Seconds(2), function()
		Media.DisplayMessage("Select your Mobile Construction Vehicle and move it to the shown place.", "Lieutenant", italy.Color)

		flare.Destroy()
		flare = Actor.Create("flare", true, { Owner = italy, Location = ConstructionZone.Location })
		Trigger.OnEnteredFootprint({ConstructionZone.Location}, function(a, id)
			if a.Type ~= "mcv" then
				return
			end

			Trigger.RemoveFootprintTrigger(id)
			Media.DisplayMessage("Click on the MCV again to deploy it into a Construction Yard.", "Lieutenant", italy.Color)
		end)
	end)
end

BuildPower = function()
	BuildPP = italy.AddPrimaryObjective("Construct a Power Plant.")

	Trigger.AfterDelay(DateTime.Seconds(5), function()
		Media.DisplayMessage("Now we can start constructing buildings.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(5), function()
			Media.DisplayMessage("Most buildings require power to operate efficently, some don't work at all without power.", "Lieutenant", italy.Color)
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				Media.DisplayMessage("So you should build a Power Plant first, click on the Power Plant icon on the right to start construction.", "Lieutenant", italy.Color)
				Trigger.AfterDelay(Actor.BuildTime("powr"), function()
					Media.DisplayMessage("Once completed, click on the icon to pick up the building.", "Lieutenant", italy.Color)
					Trigger.AfterDelay(DateTime.Seconds(5), function()
						Media.DisplayMessage("To be able to place a building the placement preview should show white stripes for all the cells building is going to occupy.", "Lieutenant", italy.Color)
						Trigger.AfterDelay(DateTime.Seconds(5), function()
							Media.DisplayMessage("This is determined by several factors, like terrain type, distance between other buildings and your Construction Yard.", "Lieutenant", italy.Color)
						end)
					end)
				end)
			end)
		end)
	end)
end

BuildRef = function()
	BuildRefinery = italy.AddPrimaryObjective("Construct an Ore Refinery.")

	Trigger.AfterDelay(DateTime.Seconds(5), function()
		Media.DisplayMessage("Good work. As we have power up now. We can now focus on the economy.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(5), function()
			Media.DisplayMessage("There are some Ore nearby, we need an Ore Refinery to collect and process them, build one.", "Lieutenant", italy.Color)

			cam = Actor.Create("camera", true, { Owner = italy, Location = OreMine.Location })
			cam.Destroy()
			Trigger.AfterDelay(Actor.BuildTime("proc"), function()
				Media.DisplayMessage("It would be a good idea to place the Ore Refinery as close to Ore as possible.", "Lieutenant", italy.Color)
			end)
		end)
	end)
end

GetCash = function()
	GetCredits = italy.AddPrimaryObjective("Store $3000 worth of Ore.")

	Trigger.AfterDelay(DateTime.Seconds(5), function()
		Media.DisplayMessage("Each refinery comes with a free Ore Miner. Miners automatically collect Ore to be processed in the Ore Refinery", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(10), function()
			BuildBarracks = italy.AddPrimaryObjective("Construct a Barracks.")
			BuildShipyard = italy.AddPrimaryObjective("Construct a Naval Yard.")

			Media.DisplayMessage("While the Miner is working, let's build the other Structures.", "Lieutenant", italy.Color)
		end)
	end)
end

BuildUnits = function()
	Trigger.AfterDelay(DateTime.Seconds(5), function()
		Media.DisplayMessage("You can now build Ships and train Infantry. You can switch the queue by clicking the Soldier or Anchor icons on the right side. Or you can select the respective production building.", "Lieutenant", italy.Color)

		unitmessage = true
	end)
end

BuildSilo = function()
	Trigger.AfterDelay(DateTime.Seconds(2), function()
		Media.DisplayMessage("Each Ore Refinery can store up to $2000 worth of Ore. You can build a Silo to store more Ore. They are in the Support Queue.", "Lieutenant", italy.Color)
		Trigger.AfterDelay(DateTime.Seconds(5), function()
			Media.DisplayMessage("You can see how much Ore you are storing how and how much more you can store by hovering over your Credits.", "Lieutenant", italy.Color)
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				Media.DisplayMessage("Only the Credits from Ores count towards this limit. If you see you are storing less that you have the extra is from the Starting Credits.", "Lieutenant", italy.Color)
			end)
		end)
	end)

	silomessage = true
end

Tick = function()
	if EstablishBase ~= nil and not italy.IsObjectiveCompleted(EstablishBase) then
		if #italy.GetActorsByType("mcv") > 0 and not landed then
			MCVLanded()
			landed = true
		end
		if #italy.GetActorsByType("fact") > 0 then
			flare.Destroy()
			BuildPower()

			italy.MarkCompletedObjective(EstablishBase)
		end
	end

	if BuildPP ~= nil and not italy.IsObjectiveCompleted(BuildPP) and #italy.GetActorsByType("powr") > 0 then
		BuildRef()

		italy.MarkCompletedObjective(BuildPP)
	end

	if BuildRefinery ~= nil and not italy.IsObjectiveCompleted(BuildRefinery) and #italy.GetActorsByType("proc") > 0 then
		GetCash()

		italy.MarkCompletedObjective(BuildRefinery)
	end

	if BuildBarracks ~= nil and not italy.IsObjectiveCompleted(BuildBarracks) and #italy.GetActorsByType("barr") > 0 then
		if italy.IsObjectiveCompleted(BuildShipyard) then
			BuildUnits()
		else
			Media.DisplayMessage("Good, now the Naval Yard.", "Lieutenant", italy.Color)
		end

		italy.MarkCompletedObjective(BuildBarracks)
	end

	if BuildShipyard ~= nil and not italy.IsObjectiveCompleted(BuildShipyard) and #italy.GetActorsByType("syrd") > 0 then
		if italy.IsObjectiveCompleted(BuildBarracks) then
			BuildUnits()
		else
			Media.DisplayMessage("Good, now the Barracks.", "Lieutenant", italy.Color)
		end

		italy.MarkCompletedObjective(BuildShipyard)
	end

	if unitmessage and not silomessage and italy.Resources >= italy.ResourceCapacity then
		BuildSilo()
	end

	if italy.Resources >= 3000 and not italy.IsObjectiveCompleted(GetCredits) then
		italy.MarkCompletedObjective(GetCredits)
	end

	if GetCredits ~= nil and BuildBarracks ~= nil and BuildShipyard ~= nil and italy.IsObjectiveCompleted(GetCredits) and italy.IsObjectiveCompleted(BuildBarracks) and italy.IsObjectiveCompleted(BuildShipyard) and not completed then
		completed = true

		Trigger.AfterDelay(DateTime.Seconds(2), function()
			Media.DisplayMessage("Good work, Commander. This base is now good for future use.", "Lieutenant", italy.Color)

			Trigger.AfterDelay(DateTime.Seconds(3), function()
				italy.MarkCompletedObjective(MainObjective)
			end)
		end)
	end
end

WorldLoaded = function()
	italy = Player.GetPlayer("Italy")

	Camera.Position = MCVMove2.CenterPosition

	InitObjectives(italy)
	SpawnMCV()

	MainObjective = italy.AddPrimaryObjective("Follow the instructions to establish an operational base.")
end
