--!strict

--[[
	17/9/2024 LadyCelestia
	@class Furnace
--]]

local System = script.Parent
local Drop = require(System:WaitForChild("Drop"))
local Library = System:WaitForChild("Library")
local Types = require(Library:WaitForChild("CommonTypes"))

local Furnace = {}
Furnace.__index = Furnace

Furnace.new = function(): Furnace
	local self = setmetatable({}, Furnace)
	
	self.Owner = 0
	self.Part = nil
	self.Multiplier = 1
	self.Connection = nil
	self.SellConnection = nil
	self.Hooks = {}
	self.Attributes = {}
	
	return self :: any
end

function Furnace._FireHook(self: Furnace, Name: Types.FurnaceHooks, ...: any): any
	if self.Hooks[Name] then
		return self.Hooks[Name](self, ...)
	end
	return nil
end

function Furnace.AddHook(self: Furnace, Name: Types.FurnaceHooks, Hook: (any) -> (any)): Furnace
	assert(type(Name) == "string", "Name must be a string")
	assert(type(Hook) == "function", "Hook must be a function")
	self.Hooks[Name] = Hook
	return self
end

function Furnace.RemoveHook(self: Furnace, Name: Types.FurnaceHooks): Furnace
	assert(type(Name) == "string", "Name must be a string")
	self.Hooks[Name] = nil
	return self
end

function Furnace.SetAttribute(self: Furnace, Name: string, Value: Types.Attribute): Furnace
	assert(type(Name) == "string", "Name must be a string")
	self.Attributes[Name] = Value
	self:_FireHook("OnSetAttribute", Name, Value)
	return self
end

function Furnace.GetAttribute(self: Furnace, Name: string): Types.Attribute?
	assert(type(Name) == "string", "Name must be a string")
	return self.Attributes[Name]
end

function Furnace.Assign(self: Furnace, Owner: number, Part: BasePart, Multiplier: number): Furnace
	assert(type(Owner) == "number", "Owner must be a number")
	assert(typeof(Part) == "Instance" and Part:IsA("BasePart"), "Part must be a BasePart")
	assert(type(Multiplier) == "number", "Value must be a number")
	self.Owner = Owner
	self.Part = Part
	self.Multiplier = Multiplier
	self.Connection = Part.Destroying:Connect(function()
		self:Destroy()
	end)
	Part:SetAttribute("Furnace", true)
	local Communication = Instance.new("BindableEvent")
	Communication.Name = "Communication"
	Communication.Parent = Part
	self.SellConnection = Communication.Event:Connect(function(Drop: Drop.Drop)
		if Drop.Owner == self.Owner then
			self:_FireHook("BeforeSell", Drop)
			local Value = Drop:Sell()
			Value = self:_FireHook("OnSell", Value) or Value
			Value *= self.Multiplier
			local Player = game.Players:GetPlayerByUserId(self.Owner)
			if Player then
				local leaderstats = Player:FindFirstChild("leaderstats")
				if leaderstats then
					-- todo: add money and possibly vfx and sfx
					
				end
			end
		end
	end)
	self:_FireHook("OnAssign")
	return self
end

function Furnace.Destroy(self: Furnace)
	self:_FireHook("OnDestroy")
	setmetatable(self, nil)
	if typeof(self.Connection) == "RBXScriptConnection" then
		self.Connection:Disconnect()
	end
	for _, v in ipairs(self) do
		if type(v) == "table" then
			table.clear(v)
			table.freeze(v)
		end
	end
	table.clear(self)
	table.freeze(self)
end

export type Furnace = typeof(Furnace) & {
	Owner: number,
	Part: BasePart?,
	Multiplier: number,
	Connection: RBXScriptConnection?,
	SellConnection: RBXScriptConnection?,
	Hooks: {[string]: (Furnace, string | number?, Types.Attribute?) -> any},
	Attributes: {[string]: Types.Attribute}
}

return Furnace
