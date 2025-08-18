---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil, "LibStub is required to run this addon")

local LibCraftingProfessions = --[[---@type LibCraftingProfessions]] LibStub("LibCraftingProfessions-1.0")
local LibCrafts             = --[[---@type LibCrafts]]              LibStub("LibCrafts-1.0")
local LibItemTooltip        = --[[---@type LibItemTooltip]]        LibStub("LibItemTooltip-1.0")

---@class Addon
---@field professionNameToIcon table<string, Frame>
local Addon = {}

local ICON_SIZE = 15
local getn   = table.getn
local unpack = unpack

-- ========================= helpers =========================

local function ITI_HideAll()
if not Addon or not Addon.professionNameToIcon then return end
    for _, icon in pairs(Addon.professionNameToIcon) do icon:Hide() end
        end

        -- Hook a tooltip so that NON-item tooltips wipe our icons.
        -- We DO NOT purge on :Show() (pfUI may call it multiple times).
        local function ITI_HookNonItem(tt)
        if not tt or tt.__iti_nonitem_hooked then return end
            tt.__iti_nonitem_hooked = true

            -- clear when tooltip hides
            local oldHide = tt:GetScript("OnHide")
            tt:SetScript("OnHide", function()
            ITI_HideAll()
            if oldHide then oldHide() end
                end)

            -- clear on manual ClearLines
            local origClear = tt.ClearLines
            if type(origClear) == "function" then
                tt.ClearLines = function(self, ...)
                ITI_HideAll()
                return origClear(self, unpack(arg))
                end
                end

                -- clear on common non-item builders
                local function wrap(method)
                local orig = tt[method]
                if type(orig) ~= "function" then return end
                    tt[method] = function(self, ...)
                    ITI_HideAll()
                    return orig(self, unpack(arg))
                    end
                    end
                    wrap("SetUnit")
                    wrap("SetSpell")
                    wrap("SetTrainerService")

                    -- optional: starting a new tooltip session
                    local origOwner = tt.SetOwner
                    if type(origOwner) == "function" then
                        tt.SetOwner = function(self, ...)
                        ITI_HideAll()
                        return origOwner(self, unpack(arg))
                        end
                        end
                        end

                        -- ========================= addon logic =========================

                        function Addon:CreateIcons()
                        local nameToIcon = {}
                        for _, profession in ipairs(LibCraftingProfessions:GetSupportedProfessions()) do
                            local icon = CreateFrame("Frame", nil, UIParent)
                            icon:SetWidth(ICON_SIZE); icon:SetHeight(ICON_SIZE)

                            local tex = icon:CreateTexture(nil, "BACKGROUND")
                            tex:SetAllPoints(icon)
                            tex:SetTexture(profession.icon_texture_path)

                            nameToIcon[profession.localized_name] = icon
                            end
                            self.professionNameToIcon = nameToIcon
                            end

                            ---@param tooltip GameTooltip
                            ---@param itemId number
                            ---@return boolean
                            function Addon:EnhanceTooltip(tooltip, itemId)
                            -- ensure this tooltip is hooked to clear on non-item use
                            ITI_HookNonItem(tooltip)

                            self:HideAllIcons()
                            return self:DrawIcons(self:GetIcons(itemId), tooltip)
                            end

                            function Addon:HideAllIcons()
                            for _, icon in pairs(self.professionNameToIcon) do icon:Hide() end
                                end

                                ---@param itemId number
                                ---@return Frame[]
                                function Addon:GetIcons(itemId)
                                local nameSet = {}
                                for _, craft in ipairs(LibCrafts:GetCraftsByReagentId(itemId)) do
                                    nameSet[craft.localized_profession_name] = true
                                    end

                                    local names = {}
                                    for name in pairs(nameSet) do table.insert(names, name) end
                                        table.sort(names)

                                        local icons = {}
                                        for _, name in ipairs(names) do
                                            local icon = self.professionNameToIcon[name]
                                            if icon then table.insert(icons, icon) end
                                                end
                                                return icons
                                                end

                                                ---@param icons Frame[]
                                                ---@param tooltip GameTooltip
                                                ---@return boolean
                                                function Addon:DrawIcons(icons, tooltip)
                                                if next(icons) == nil then return false end

                                                    -- spacer line to make room for icons
                                                    local spacer = ""
                                                    for i = 1, getn(icons) do spacer = spacer .. "....." end
                                                        tooltip:AddLine(spacer, 0.01, 0.01, 0.01)

                                                        local line = tooltip:NumLines()
                                                        for i, icon in ipairs(icons) do
                                                            icon:SetParent(tooltip)
                                                            icon:ClearAllPoints()
                                                            if i == 1 then
                                                                icon:SetPoint("LEFT", getglobal(tooltip:GetName().."TextLeft"..line), "LEFT", 0, -1)
                                                                else
                                                                    icon:SetPoint("LEFT", icons[i-1], "RIGHT", 2, 0)
                                                                    end
                                                                    icon:Show()
                                                                    end
                                                                    return true
                                                                    end

                                                                    Addon:CreateIcons()

                                                                    LibItemTooltip:RegisterEvent("OnShow", function(tooltip, itemLink, itemId)
                                                                    if Addon:EnhanceTooltip(tooltip, itemId) then
                                                                        tooltip:Show() -- redraw so spacer+icons appear immediately
                                                                        end
                                                                        end)

                                                                    -- hook stock + pfUI tooltip frames at login so non-item tooltips purge icons
                                                                    local hooker = CreateFrame("Frame")
                                                                    hooker:RegisterEvent("PLAYER_LOGIN")
                                                                    hooker:RegisterEvent("ADDON_LOADED")
                                                                    hooker:SetScript("OnEvent", function()
                                                                    ITI_HookNonItem(GameTooltip)
                                                                    if pfUITooltip then ITI_HookNonItem(pfUITooltip) end
                                                                        if pfTooltip     then ITI_HookNonItem(pfTooltip) end
                                                                            end)
