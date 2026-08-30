---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')
---@class Database: AceModule
local db = BetterBags:GetModule('Database')
---@class Constants: AceModule
local const = BetterBags:GetModule('Constants')
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
---@class Sort: AceModule
local sort = BetterBags:GetModule('Sort')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')

---@enum Add gear section order
const.GEAR_SECTION_ORDER = {
    _G["INVTYPE_HEAD"],
    _G["INVTYPE_NECK"],
    _G["INVTYPE_SHOULDER"],
    _G["INVTYPE_CLOAK"],
    _G["INVTYPE_CHEST"],
    _G["INVTYPE_WRIST"],
    _G["INVTYPE_HAND"],
    _G["INVTYPE_WAIST"],
    _G["INVTYPE_LEGS"],
    _G["INVTYPE_FEET"],
    _G["INVTYPE_FINGER"],
    _G["INVTYPE_TRINKET"],
    _G["INVTYPE_WEAPONMAINHAND"],
    _G["INVTYPE_2HWEAPON"],
    _G["INVTYPE_WEAPON"],
    _G["INVTYPE_SHIELD"],
    _G["INVTYPE_HOLDABLE"],
    _G["INVTYPE_RANGED"],
    L:G("Low iLvl"),
}
---@enum Add sort types
const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY = 4
const.SECTION_SORT_TYPE.HEARTHSTONE_GEAR_ALPHABETICALLY = 5

-- Add config option
local selectValueToLabel = {
    [const.SECTION_SORT_TYPE.ALPHABETICALLY] = L:G("Alphabetically"),
    [const.SECTION_SORT_TYPE.SIZE_DESCENDING] = L:G("Size Descending"),
    [const.SECTION_SORT_TYPE.SIZE_ASCENDING] = L:G("Size Ascending"),
    [const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY] = L:G("Gear > Alphabetically"),
    [const.SECTION_SORT_TYPE.HEARTHSTONE_GEAR_ALPHABETICALLY] = L:G("Hearthstone > Gear > Alphabetically")
}
local selectLabelToValue = {
    [L:G("Alphabetically")] = const.SECTION_SORT_TYPE.ALPHABETICALLY,
    [L:G("Size Descending")] = const.SECTION_SORT_TYPE.SIZE_DESCENDING,
    [L:G("Size Ascending")] = const.SECTION_SORT_TYPE.SIZE_ASCENDING,
    [L:G("Gear > Alphabetically")] = const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY,
    [L:G("Hearthstone > Gear > Alphabetically")] = const.SECTION_SORT_TYPE.HEARTHSTONE_GEAR_ALPHABETICALLY
}
local sortItemsList = {
    L:G("Alphabetically"),
    L:G("Size Descending"),
    L:G("Size Ascending"),
    L:G("Gear > Alphabetically"),
    L:G("Hearthstone > Gear > Alphabetically"),
}

local ALL_BAG_KINDS = { const.BAG_KIND.BACKPACK, const.BAG_KIND.BANK }

local eventFrame = CreateFrame("Frame", "GearFirstEventFrame", UIParent)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...;
        if name ~= "BetterBags_GearFirst" then return end

        if not BetterBags_GearFirstDB then BetterBags_GearFirstDB = {} end
        if not BetterBags_GearFirstDB.initialized then
            BetterBags_GearFirstDB.initialized = true
            BetterBags_GearFirstDB.sortBank = true
            for _, kind in ipairs(ALL_BAG_KINDS) do
                db:SetSectionSortType(kind, db:GetBagView(kind), const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY)
            end
        end

        config:AddPluginConfig("Gear First", {
            [1] = {
                name = function()
                    config.configFrame.layout:AddInlineSubSection({
                        title = "Gear First - Section Order",
                        description = "The order of sections in the backpack when not pinned.\nThis option overrides the default \"Backpack > Section Order\" option.",
                    })
                end
            },
            [2] = {
                name = function()
                    config.configFrame.layout:AddDropdown({
                        title = L:G("Section Order"),
                        items = sortItemsList,
                        getValue = function(ctx, value)
                            return value == selectValueToLabel[db:GetSectionSortType(const.BAG_KIND.BACKPACK, db:GetBagView(const.BAG_KIND.BACKPACK))]
                        end,
                        setValue = function(ctx, value)
                            db:SetSectionSortType(const.BAG_KIND.BACKPACK, db:GetBagView(const.BAG_KIND.BACKPACK), selectLabelToValue[value])
                            if BetterBags_GearFirstDB.sortBank then
                                db:SetSectionSortType(const.BAG_KIND.BANK, db:GetBagView(const.BAG_KIND.BANK), selectLabelToValue[value])
                            end
                            events:SendMessage(ctx, "bags/FullRefreshAll")
                        end,
                    })
                end
            },
            [3] = {
                name = function()
                    config.configFrame.layout:AddCheckbox({
                        title = L:G("Apply to Bank"),
                        getValue = function(ctx)
                            return BetterBags_GearFirstDB.sortBank
                        end,
                        setValue = function(ctx, value)
                            BetterBags_GearFirstDB.sortBank = value
                            if value then
                                local currentSort = db:GetSectionSortType(const.BAG_KIND.BACKPACK, db:GetBagView(const.BAG_KIND.BACKPACK))
                                db:SetSectionSortType(const.BAG_KIND.BANK, db:GetBagView(const.BAG_KIND.BANK), currentSort)
                            else
                                db:SetSectionSortType(const.BAG_KIND.BANK, db:GetBagView(const.BAG_KIND.BANK), const.SECTION_SORT_TYPE.ALPHABETICALLY)
                            end
                            events:SendMessage(ctx, "bags/FullRefreshAll")
                        end,
                    })
                end
            },
        })
    end
end)

-- Override sort function getter
---@param kind BagKind
---@param view BagView
---@return function
function sort:GetSectionSortFunction(kind, view)
    local sortType = db:GetSectionSortType(kind, view)
    if sortType == const.SECTION_SORT_TYPE.ALPHABETICALLY then
        return function(a, b)
            return self.SortSectionsAlphabetically(kind, a, b)
        end
    elseif sortType == const.SECTION_SORT_TYPE.SIZE_ASCENDING then
        return function(a, b)
            return self.SortSectionsBySizeAscending(kind, a, b)
        end
    elseif sortType == const.SECTION_SORT_TYPE.SIZE_DESCENDING then
        return function(a, b)
            return self.SortSectionsBySizeDescending(kind, a, b)
        end
    elseif sortType == const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY then
        return function(a, b)
            return self.SortSectionsGearAlphabetically(kind, a, b)
        end
    elseif sortType == const.SECTION_SORT_TYPE.HEARTHSTONE_GEAR_ALPHABETICALLY then
        return function(a, b)
            return self.SortSectionsHearthstoneGearAlphabetically(kind, a, b)
        end
    end
    -- Fallback to alphabetical sort for unknown sort types (e.g. from other plugins).
    return function(a, b)
        return self.SortSectionsAlphabetically(kind, a, b)
    end
end

-- Add gear sort function
---@param a Section
---@param b Section
---@return boolean
function sort.SortSectionsGearAlphabetically(kind, a, b)
    if a == nil or b == nil then return false end

    local aText = a.title:GetText()
    local bText = b.title:GetText()
    if aText == bText then return false end

    local shouldSort, sortResult = sort.SortSectionsByPriority(kind, a, b)
    if shouldSort then return sortResult end

    if aText == L:G("Recent Items") then return true end
    if bText == L:G("Recent Items") then return false end

    for _, gearType in ipairs(const.GEAR_SECTION_ORDER) do
        if aText == gearType then return true end
        if bText == gearType then return false end
    end

    if string.find(aText, L:G("Gear") .. ":") then return true end
    if string.find(bText, L:G("Gear") .. ":") then return false end

    if a:GetFillWidth() then return false end
    if b:GetFillWidth() then return true end

    if aText == L:G("Free Space") then return false end
    if bText == L:G("Free Space") then return true end

    return stripColorCode(aText) < stripColorCode(bText)
end

-- Add hearthstone + gear sort function
---@param a Section
---@param b Section
---@return boolean
function sort.SortSectionsHearthstoneGearAlphabetically(kind, a, b)
    local aText = a.title:GetText()
    local bText = b.title:GetText()
    if aText == bText then return false end

    local shouldSort, sortResult = sort.SortSectionsByPriority(kind, a, b)
    if shouldSort then return sortResult end

    if aText == L:G("Recent Items") then return true end
    if bText == L:G("Recent Items") then return false end

    if aText == L:G("Hearthstones") then return true end
    if bText == L:G("Hearthstones") then return false end

    for _, gearType in ipairs(const.GEAR_SECTION_ORDER) do
        if aText == gearType then return true end
        if bText == gearType then return false end
    end

    if string.find(aText, L:G("Gear") .. ":") then return true end
    if string.find(bText, L:G("Gear") .. ":") then return false end

    if a:GetFillWidth() then return false end
    if b:GetFillWidth() then return true end

    if aText == L:G("Free Space") then return false end
    if bText == L:G("Free Space") then return true end

    return stripColorCode(aText) < stripColorCode(bText)
end

---@param text string
---@return string
function stripColorCode(text)
    if string.sub(text, 1, 4) == "|cff" then
        return string.sub(text, 11)
    end
    return text
end