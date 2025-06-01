---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil, "LibStub is required to run this addon")

local LibCraftingProfessions = --[[---@type LibCraftingProfessions]] LibStub("LibCraftingProfessions-1.0")
local LibCrafts = --[[---@type LibCrafts]] LibStub("LibCrafts-1.0")
local LibItemTooltip = --[[---@type LibItemTooltip]] LibStub("LibItemTooltip-1.0")

---@class Addon
---@field professionNameToIcon table<string, Frame>
local Addon = {}

local ICON_SIZE = 15

function Addon:CreateIcons()
    ---@type table<string, Frame>
    local nameToIcon = {}
    for _, profession in ipairs(LibCraftingProfessions:GetSupportedProfessions()) do
        local icon = CreateFrame("Frame", nil, nil)
        icon:SetWidth(ICON_SIZE)
        icon:SetHeight(ICON_SIZE)

        local texture = icon:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints(icon)
        texture:SetTexture(profession.icon_texture_path)

        nameToIcon[profession.localized_name] = icon
    end
    self.professionNameToIcon = nameToIcon
end

---@param tooltip GameTooltip
---@param itemId number
---@return boolean
function Addon:EnhanceTooltip(tooltip, itemId)
    self:HideAllIcons()
    return self:DrawIcons(self:GetIcons(itemId), tooltip)
end

function Addon:HideAllIcons()
    for _, icon in pairs(self.professionNameToIcon) do
        icon:Hide()
    end
end

---@param itemId number
---@return Frame[]
function Addon:GetIcons(itemId)
    ---@type table<string, boolean>
    local nameSet = {}
    for _, craft in ipairs(LibCrafts:GetCraftsByReagentId(itemId)) do
        nameSet[craft.localized_profession_name] = true
    end

    ---@type string[]
    local names = {}
    for name, _ in pairs(nameSet) do
        tinsert(names, name)
    end
    table.sort(names)

    ---@type Frame[]
    local icons = {}
    for _, name in ipairs(names) do
        local icon = self.professionNameToIcon[name]
        if icon ~= nil then
            tinsert(icons, icon)
        end
    end
    return icons
end

---@param icons Frame[]
---@param tooltip GameTooltip
---@return boolean
function Addon:DrawIcons(icons, tooltip)
    if next(icons) == nil then
        return false
    end

    -- Create "invisible" spacer line to fit icons
    local spacerText = ""
    for i = 1, getn(icons) do
        spacerText = spacerText .. "....."
    end
    tooltip:AddLine(spacerText, 0.01, 0.01, 0.01)

    local lineIndex = tooltip:NumLines()
    for i, icon in ipairs(icons) do
        icon:SetParent(tooltip)
        icon:ClearAllPoints()
        if i == 1 then
            icon:SetPoint("LEFT", getglobal(tooltip:GetName() .. "TextLeft" .. lineIndex), "LEFT", 0, -1)
        else
            icon:SetPoint("LEFT", icons[i - 1], "RIGHT", 2, 0)
        end
        icon:Show()
    end

    return true
end

Addon:CreateIcons()

LibItemTooltip:RegisterEvent("OnShow", function(tooltip, itemLink, itemId)
    if Addon:EnhanceTooltip(tooltip, itemId) then
        tooltip:Show()
    end
end)
