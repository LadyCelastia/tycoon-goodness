--!strict

--[[
	17/9/2024 LadyCelestia
	@class Drop
--]]

local System = script.Parent
local Library = System:WaitForChild("Library")
local Types = require(Library:WaitForChild("CommonTypes"))

local Drop = {}
Drop.__index = Drop

Drop.new = function(): Drop
	local self = setmetatable({}, Drop)
	
	self.Owner = 0
	self.Part = nil
	self.Value = 0
	self.Connection = nil
	self.TouchConnection = nil
	self.Hooks = {}
	self.Attributes = {}
	
	return self :: any
end

function Drop._FireHook(self: Drop, Name: Types.DropHooks, ...: any): ()
	if self.Hooks[Name] then
		self.Hooks[Name](self, ...)
	end
end

function Drop.AddHook(self: Drop, Name: Types.DropHooks, Hook: (any) -> (any)): Drop
	assert(type(Name) == "string", "Name must be a string")
	assert(type(Hook) == "function", "Hook must be a function")
	self.Hooks[Name] = Hook
	return self
end

function Drop.RemoveHook(self: Drop, Name: Types.DropHooks): Drop
	assert(type(Name) == "string", "Name must be a string")
	self.Hooks[Name] = nil
	return self
end

function Drop.SetAttribute(self: Drop, Name: string, Value: Types.Attribute): Drop
	assert(type(Name) == "string", "Name must be a string")
	self.Attributes[Name] = Value
	self:_FireHook("OnSetAttribute", Name, Value)
	return self
end

function Drop.GetAttribute(self: Drop, Name: string): Types.Attribute?
	assert(type(Name) == "string", "Name must be a string")
	return self.Attributes[Name]
end

function Drop.Assign(self: Drop, Owner: number, Part: BasePart, Value: number): Drop
	assert(type(Owner) == "number", "Owner must be a number")
	assert(typeof(Part) == "Instance" and Part:IsA("BasePart"), "Part must be a BasePart")
	assert(type(Value) == "number", "Value must be a number")
	self.Owner = Owner
	self.Part = Part
	self.Value = Value
	self.Connection = Part.Destroying:Connect(function()
		self:Destroy(false)
	end)
	self.TouchConnection = Part.Touched:Connect(function(otherPart: BasePart)
		if otherPart:GetAttribute("Furnace") then
			local Communication = otherPart:FindFirstChildOfClass("BindableEvent")
			if Communication then
				Communication:Fire(self)
			end
		elseif otherPart:GetAttribute("Upgrader") and not self:GetAttribute(otherPart:GetAttribute("Tag")) then
			local Communication = otherPart:FindFirstChildOfClass("BindableEvent")
			if Communication then
				Communication:Fire(self)
			end
		end
	end)
	self:_FireHook("OnAssign")
	return self
end

function Drop.AddValue(self: Drop, Value: number): Drop
	assert(type(Value) == "number", "Value must be a number")
	self.Value += Value
	self:_FireHook("OnIncrement", Value, self.Value)
	return self
end

function Drop.MultiplyValue(self: Drop, Multiplier: number): Drop
	assert(type(Multiplier) == "number", "Multiplier must be a numberr")
	self.Value *= Multiplier
	self:_FireHook("OnMultiply", Multiplier, self.Value)
	return self
end

function Drop.Sell(self: Drop): number
	local Value = self.Value
	self:_FireHook("OnSell", self.Value)
	self:Destroy(true)
	return Value
end

function Drop.Destroy(self: Drop, Sold: boolean?): ()
	self:_FireHook("OnDestroy")
	if not Sold then
		self:_FireHook("OnDestroyNoSell")
	end
	setmetatable(self, nil)
	if typeof(self.Connection) == "RBXScriptConnection" then
		self.Connection:Disconnect()
	end
	if typeof(self.Part) == "Instance" and self.Part.Parent ~= nil then
		self.Part:Destroy()
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

export type Drop = typeof(Drop) & {
	Owner: number,
	Part: BasePart?,
	Value: number,
	Connection: RBXScriptConnection?,
	TouchConnection: RBXScriptConnection?,
	Hooks: {[string]: (Drop, string | number?, Types.Attribute?) -> any},
	Attributes: {[string]: Types.Attribute}
}

return Drop
