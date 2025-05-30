local ServerScriptService = game:GetService("ServerScriptService")
local System = ServerScriptService:WaitForChild("TycoonSystem")
local Drop = require(System:WaitForChild("Drop"))

local Template = script:WaitForChild("Drop")
local Dropper = require(System:WaitForChild("Dropper"))

local self: Dropper.Dropper = Dropper.new()
self:Assign(1, Template, script.Parent, 10)
	:AddHook("OnDrop", function(self: Dropper.Dropper, Drop: Drop.Drop)
		self:SetAttribute("DropCount", self:GetAttribute("DropCount") + 1)
		print("Dropped!", Drop.Value, self:GetAttribute("DropCount"))
	end)
	:SetAttribute("DropCount", 0)

while task.wait(2.5) do
	self:Drop()
end
