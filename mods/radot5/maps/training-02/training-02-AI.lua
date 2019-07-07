--[[
   Copyright 2007-2019 The OpenRA Developers (see AUTHORS)
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

Base = { ETHConYard, ETHPower1, ETHPower2, ETHPower3, ETHRefinery, ETHBarracks, ETHStable, ETHWFac, ETHSilo1, ETHSilo2, ETHSilo3, ETHSilo4, ETHPillBox1, ETHPillBox2, ETHPillBox3, ETHPillBox4, ETHPillBox5, ETHPillBox6, ETHTurret1, ETHTurret2, ETHTurret3 }

InfantryTypes = { "e1", "e1", "e2" }
CavalryTypes = { "riflecav", "riflecav", "grencav" }
VehicleTypes = { "ftrk", "ftrk", "1tnk" }

ActivateAI = function()
	local delay = function() return Utils.RandomInteger(DateTime.Minutes(2), DateTime.Minutes(5) + 1) end
	local infantryToBuild = function() return { Utils.Random(InfantryTypes) } end
	local cavalryToBuild = function() return { Utils.Random(CavalryTypes) } end
	local vehiclesToBuild = function() return { Utils.Random(VehicleTypes) } end

	ProduceUnits(ethiopia, ETHBarracks, delay, infantryToBuild, 2, 8)
	ProduceUnits(ethiopia, ETHStable, delay, cavalryToBuild, 2, 8)
	ProduceUnits(ethiopia, ETHWFac, delay, vehiclesToBuild, 2, 8)
end
