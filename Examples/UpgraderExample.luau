local ServerScriptService = game:GetService("ServerScriptService")
local System = ServerScriptService:WaitForChild("TycoonSystem")
local Drop = require(System:WaitForChild("Drop"))

local Upgrader = require(System:WaitForChild("Upgrader"))
local self: Upgrader.Upgrader = Upgrader.new()
self:Assign(1, script.Parent, "Test")
	:AddHook("OnUpgrade", function(self: Upgrader.Upgrader, Value: number, Attributes: {[string]: any}): number
		print("Before:", Value)
		task.delay(.1, function()
			print("After:", (Value + 5) * 2)
		end)
		self:SetAttribute("UpgradeCount", self:GetAttribute("UpgradeCount") + 1)
		return (Value + 5) * 2
	end)
	:AddHook("OnDestroy", function(): ()
		print("Upgrader is destroying!")
	end)
	:SetAttribute("UpgradeCount", 0)
