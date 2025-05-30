--!strict

--[[
	17/9/2024 LadyCelestia
	@class Upgrader
--]]

local System = script.Parent
local Drop = require(System:WaitForChild("Drop"))
local Library = System:WaitForChild("Library")
local Types = require(Library:WaitForChild("CommonTypes"))

local Upgrader = {}
Upgrader.__index = Upgrader

Upgrader.new = function(): Upgrader
	local self = setmetatable({}, Upgrader)

	self.Owner = 0
	self.Part = nil
	self.Tag = ""
	self.Connection = nil
	self.UpgradeConnection = nil
	self.Hooks = {}
	self.Attributes = {}

	return self :: any
end

function Upgrader._FireHook(self: Upgrader, Name: Types.UpgraderHooks, ...: any): any
	if self.Hooks[Name] then
		return self.Hooks[Name](self, ...)
	end
	return nil
end

function Upgrader.AddHook(self: Upgrader, Name: Types.UpgraderHooks, Hook: (any) -> (any)): Upgrader
	assert(type(Name) == "string", "Name must be a string")
	assert(type(Hook) == "function", "Hook must be a function")
	self.Hooks[Name] = Hook
	return self
end

function Upgrader.RemoveHook(self: Upgrader, Name: Types.UpgraderHooks): Upgrader
	assert(type(Name) == "string", "Name must be a string")
	self.Hooks[Name] = nil
	return self
end

function Upgrader.SetAttribute(self: Upgrader, Name: string, Value: Types.Attribute): Upgrader
	assert(type(Name) == "string", "Name must be a string")
	self.Attributes[Name] = Value
	self:_FireHook("OnSetAttribute", Name, Value)
	return self
end

function Upgrader.GetAttribute(self: Upgrader, Name: string): Types.Attribute?
	assert(type(Name) == "string", "Name must be a string")
	return self.Attributes[Name]
end

function Upgrader.Assign(self: Upgrader, Owner: number, Part: BasePart, Tag: string): Upgrader
	assert(type(Owner) == "number", "Owner must be a number")
	assert(typeof(Part) == "Instance" and Part:IsA("BasePart"), "Part must be a BasePart")
	assert(type(Tag) == "string", "Value must be a number")
	self.Owner = Owner
	self.Part = Part
	self.Tag = Tag
	self.Connection = Part.Destroying:Connect(function()
		self:Destroy()
	end)
	Part:SetAttribute("Upgrader", true)
	Part:SetAttribute("Tag", Tag)
	local Communication = Instance.new("BindableEvent")
	Communication.Name = "Communication"
	Communication.Parent = Part
	self.UpgradeConnection = Communication.Event:Connect(function(Drop: Drop.Drop)
		if Drop.Owner == Owner and not Drop:GetAttribute(self.Tag) then
			Drop:SetAttribute(self.Tag, true)
			Drop:SetAttribute("UpgradeCount", (Drop:GetAttribute("UpgradeCount") :: number or 0) + 1)
			Drop.Value = self:_FireHook("OnUpgrade", Drop) or Drop.Value
		end
	end)
	self:_FireHook("OnAssign")
	return self
end

function Upgrader.Destroy(self: Upgrader)
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

export type Upgrader = typeof(Upgrader) & {
	Owner: number,
	Part: BasePart?,
	Tag: string,
	Connection: RBXScriptConnection?,
	UpgradeConnection: RBXScriptConnection?,
	Hooks: {[string]: (Upgrader, string | number?, Types.Attribute?) -> any},
	Attributes: {[string]: Types.Attribute}
}

return Upgrader
