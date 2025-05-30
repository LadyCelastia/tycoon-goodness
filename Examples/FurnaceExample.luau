local ServerScriptService = game:GetService("ServerScriptService")
local System = ServerScriptService:WaitForChild("TycoonSystem")
local Drop = require(System:WaitForChild("Drop"))

local Furnace = require(System:WaitForChild("Furnace"))

local self: Furnace.Furnace = Furnace.new()
self
	:Assign(1, script.Parent, 1.5)
	:AddHook("BeforeSell", function(self: Furnace.Furnace, Value: number, Attributes: {[string]: any})
		print("Value before sell:", Value)
		print("Attributes:", Attributes)
	end)
	:AddHook("OnSell", function(self: Furnace.Furnace, Value: number, Attributes: {[string]: any})
		print("Value after sell:", Value)
	end)
