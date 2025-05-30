local module = {}

export type enumPair<T> = {[string]: T}
export type DropHooks = "OnAssign" | "OnSell" | "OnDestroy" | "OnDestroyNoSell" | "OnIncrement" | "OnMultiply" | "OnSetAttribute"
export type DropperHooks = "OnDestroy" | "OnSetAttribute" | "OnDrop" | "OnAssign"
export type FurnaceHooks = "OnDestroy" | "OnSetAttribute" | "BeforeSell" | "OnSell" | "OnAssign"
export type UpgraderHooks = "OnDestroy" | "OnSetAttribute" | "OnUpgrade" | "OnAssign"
export type Attribute = string | number | boolean | Color3 | BrickColor | Vector3 | Vector2 | CFrame | UDim2 | UDim | ColorSequence | NumberSequence | NumberRange | Rect | Font

return module
