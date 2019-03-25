--[[
   Copyright 2007-2019 The OpenRA Developers (see AUTHORS)
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]
UnitTypes = { "ftrk", "1tnk", "apc", "2tnk" }
BeachUnitTypes = { "e1", "e2", "e3", "e5", "e1", "e2", "e3", "e5", "e1", "e2", "e3", "e5", "e1", "e2", "e3", "e5" }
ProxyType = "powerproxy.paratroopers"
ProducedUnitTypes =
{
	{ factory = AlliedBarracks1, types = { "dog", "e1", "e2", "e3", "sniper" } },
	{ factory = AlliedBarracks2, types = { "dog", "e1", "e2", "e3", "sniper" } },
	{ factory = AxisBarracks1, types = { "dog", "e1", "e2", "e3", "sniper", "e5" } },
	{ factory = AxisBarracks2, types = { "dog", "e1", "e2", "e3", "sniper", "e5" } },
	{ factory = AxisBarracks3, types = { "dog", "e1", "e2", "e3", "sniper", "e5" } },
	{ factory = AlliedStable1, types = { "riflecav", "grencav" } },
	{ factory = AxisStable1, types = { "riflecav", "grencav" } },
	{ factory = AxisStable2, types = { "riflecav", "grencav" } },
	{ factory = AlliedWarFactory1, types = { "jeep", "ftrk", "1tnk", "2tnk", "arty" } },
	{ factory = AxisWarFactory1, types = { "apc", "ftrk", "1tnk", "2tnk", "arty" } }
}

ShipUnitTypes = { "1tnk", "1tnk", "jeep", "2tnk", "2tnk" }
HelicopterUnitTypes = { "e1", "e1", "e2", "e3", "e3" };

ParadropWaypoints = { Paradrop1, Paradrop2, Paradrop3, Paradrop4, Paradrop5, Paradrop6, Paradrop7, Paradrop8 }

Mig1Waypoints = { Mig11, Mig12, Mig13, Mig14 }
Mig2Waypoints = { Mig21, Mig22, Mig23, Mig24 }

BindActorTriggers = function(a)
	if a.HasProperty("Hunt") then
		if a.Owner == allies then
			Trigger.OnIdle(a, function(a)
				if a.IsInWorld then
					a.Hunt()
				end
			end)
		else
			Trigger.OnIdle(a, function(a)
				if a.IsInWorld then
					a.AttackMove(AlliedHQ.Location)
				end
			end)
		end
	end
end

SendAxisUnits = function(entryCell, unitTypes, interval)
	local units = Reinforcements.Reinforce(axis, unitTypes, { entryCell }, interval)
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Trigger.OnAllKilled(units, function() SendAxisUnits(entryCell, unitTypes, interval) end)
end

SendMigs = function(waypoints)
	local migEntryPath = { waypoints[1].Location, waypoints[2].Location }
	local bombers = Reinforcements.Reinforce(axis, { "bomber" }, migEntryPath, 4)
	Utils.Do(bombers, function(bomber)
		bomber.Move(waypoints[3].Location)
		bomber.Move(waypoints[4].Location)
		bomber.Destroy()
	end)

	Trigger.AfterDelay(DateTime.Seconds(40), function() SendMigs(waypoints) end)
end

ShipAlliedUnits = function()
	local units = Reinforcements.ReinforceWithTransport(allies, "lst",
		ShipUnitTypes, { LstEntry.Location, LstUnload.Location }, { LstEntry.Location })[2]

	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)

	Trigger.AfterDelay(DateTime.Seconds(60), ShipAlliedUnits)
end

InsertAlliedChinookReinforcements = function(entry, hpad)
	local units = Reinforcements.ReinforceWithTransport(allies, "balloon",
		HelicopterUnitTypes, { entry.Location, hpad.Location + CVec.New(1, 2) }, { entry.Location })[2]

	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)

	Trigger.AfterDelay(DateTime.Seconds(60), function() InsertAlliedChinookReinforcements(entry, hpad) end)
end

ParadropSovietUnits = function()
	local lz = Utils.Random(ParadropWaypoints)
	local units = powerproxy.SendParatroopers(lz.CenterPosition)

	Utils.Do(units, function(a)
		BindActorTriggers(a)
	end)

	Trigger.AfterDelay(DateTime.Seconds(35), ParadropSovietUnits)
end

ProduceUnits = function(t)
	local factory = t.factory
	if not factory.IsDead then
		local unitType = t.types[Utils.RandomInteger(1, #t.types + 1)]
		factory.Wait(Actor.BuildTime(unitType))
		factory.Produce(unitType)
		factory.CallFunc(function() ProduceUnits(t) end)
	end
end

SetupAlliedUnits = function()
	Utils.Do(Map.NamedActors, function(a)
		if a.Owner == allies and a.HasProperty("AcceptsCondition") and a.AcceptsCondition("unkillable") then
			a.GrantCondition("unkillable")
			a.Stance = "Defend"
		end
	end)
end

SetupFactories = function()
	Utils.Do(ProducedUnitTypes, function(production)
		Trigger.OnProduction(production.factory, function(_, a) BindActorTriggers(a) end)
	end)
end

ticks = 0
speed = 5

Tick = function()
	ticks = ticks + 1

	local t = (ticks + 45) % (360 * speed) * (math.pi / 180) / speed;
	Camera.Position = viewportOrigin + WVec.New(19200 * math.sin(t), 20480 * math.cos(t), 0)
end

WorldLoaded = function()
	allies = Player.GetPlayer("Allies")
	soviets = Player.GetPlayer("Soviets")
	axis = Player.GetPlayer("Axis")
	viewportOrigin = Camera.Position

	SetupAlliedUnits()
	SetupFactories()
	ShipAlliedUnits()
	InsertAlliedChinookReinforcements(Chinook1Entry, HeliPad1)
	InsertAlliedChinookReinforcements(Chinook2Entry, HeliPad2)
	powerproxy = Actor.Create(ProxyType, false, { Owner = axis })
	ParadropSovietUnits()
	Utils.Do(ProducedUnitTypes, ProduceUnits)

	Trigger.AfterDelay(DateTime.Seconds(30), function() SendMigs(Mig1Waypoints) end)
	Trigger.AfterDelay(DateTime.Seconds(30), function() SendMigs(Mig2Waypoints) end)

	SendAxisUnits(Entry1.Location, UnitTypes, 50)
	SendAxisUnits(Entry2.Location, UnitTypes, 50)
	SendAxisUnits(Entry3.Location, UnitTypes, 50)
	SendAxisUnits(Entry4.Location, UnitTypes, 50)
	SendAxisUnits(Entry5.Location, UnitTypes, 50)
	SendAxisUnits(Entry6.Location, UnitTypes, 50)
	SendAxisUnits(Entry7.Location, BeachUnitTypes, 15)
end
