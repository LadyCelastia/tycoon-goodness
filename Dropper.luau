--!strict

--[[
	17/9/2024 LadyCelestia
	@class Dropper
--]]

local Debris = game:GetService("Debris")
local System = script.Parent
local Drop = require(System:WaitForChild("Drop"))
local Library = System:WaitForChild("Library")
local Types = require(Library:WaitForChild("CommonTypes"))

local Dropper = {}
Dropper.__index = Dropper

Dropper.new = function(): Dropper
	local self = setmetatable({}, Dropper)
	
	self.Owner = 0
	self.Part = nil
	self.Template = nil
	self.Value = 0
	self.Connection = nil
	self.Hooks = {}
	self.Attributes = {}
	
	return self :: any
end

function Dropper._FireHook(self: Dropper, Name: Types.DropperHooks, ...: any): () -- calling a lambda with an escaped varodic is so cursed but i don't want to spend 10 minutes typecasting the varodic, lets pray that the engine can infer the type
	if self.Hooks[Name] then
		self.Hooks[Name](self, ...)
	end
end

function Dropper.Drop(self: Dropper): (Dropper, Drop.Drop)
	assert(typeof(self.Part) == "Instance" and self.Part:IsA("BasePart"), "self.Part must be a BasePart")
	assert(typeof(self.Template) == "Instance" and self.Template:IsA("BasePart"), "self.Template must be a BasePart")
	assert(type(self.Owner) == "number", "self.Owner must be a number")
	local NewPart = self.Template:Clone()
	Debris:AddItem(NewPart, 120)
	NewPart.CFrame = self.Part.CFrame
	NewPart.Parent = workspace
	local NewDrop: Drop.Drop = Drop.new()
	NewDrop:Assign(self.Owner, NewPart, self.Value)
	self:_FireHook("OnDrop", NewDrop)
	return self, NewDrop
end

function Dropper.AddHook(self: Dropper, Name: Types.DropperHooks, Hook: (any) -> (any)): Dropper
	assert(type(Name) == "string", "Name must be a string")
	assert(type(Hook) == "function", "Hook must be a function")
	self.Hooks[Name] = Hook
	return self
end

function Dropper.RemoveHook(self: Dropper, Name: Types.DropperHooks): Dropper
	assert(type(Name) == "string", "Name must be a string")
	self.Hooks[Name] = nil
	return self
end

function Dropper.SetAttribute(self: Dropper, Name: string, Value: Types.Attribute): Dropper
	assert(type(Name) == "string", "Name must be a string")
	self.Attributes[Name] = Value
	self:_FireHook("OnSetAttribute", Name, Value)
	return self
end

function Dropper.GetAttribute(self: Dropper, Name: string): Types.Attribute?
	assert(type(Name) == "string", "Name must be a string")
	return self.Attributes[Name]
end

function Dropper.Assign(self: Dropper, Owner: number, Template: BasePart, Part: BasePart, Value: number): Dropper
	assert(type(Owner) == "number", "Owner must be a number")
	assert(typeof(Template) == "Instance" and Template:IsA("BasePart"), "Template must be a BasePart")
	assert(typeof(Part) == "Instance" and Part:IsA("BasePart"), "Part must be a BasePart")
	assert(type(Value) == "number", "Value must be a number")
	self.Owner = Owner
	self.Template = Template
	self.Part = Part
	self.Value = Value
	self.Connection = Part.Destroying:Connect(function()
		self:Destroy()
	end)
	self:_FireHook("OnAssign")
	return self
end

function Dropper.Destroy(self: Dropper): ()
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

export type Dropper = typeof(Dropper) & {
	Owner: number,
	Part: BasePart?,
	Template: BasePart?,
	Value: number,
	Connection: RBXScriptConnection?,
	Hooks: {[string]: (Dropper, string | number | Drop.Drop | BasePart?, Types.Attribute?) -> any},
	Attributes: {[string]: Types.Attribute}
}

return Dropper
