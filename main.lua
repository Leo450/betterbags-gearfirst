---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')
---@class Sort: AceModule
local sort = BetterBags:GetModule('Sort')

-- Override the default sort function
---@param a Section
---@param b Section
---@return boolean
function sort.SortSectionsAlphabetically(a, b)
    local titleA = a.title:GetText()
    local titleB = b.title:GetText()

    if titleA == L:G("Recent Items") then return true end
    if titleB == L:G("Recent Items") then return false end

    if a:GetFillWidth() then return false end
    if b:GetFillWidth() then return true end

    if titleA == L:G("Free Space") then return false end
    if titleB == L:G("Free Space") then return true end

    if titleA == L:G("Head") then return true end
    if titleB == L:G("Head") then return false end

    if titleA == L:G("Neck") then return true end
    if titleB == L:G("Neck") then return false end

    if titleA == L:G("Shoulder") then return true end
    if titleB == L:G("Shoulder") then return false end

    if titleA == L:G("Back") then return true end
    if titleB == L:G("Back") then return false end

    if titleA == L:G("Chest") then return true end
    if titleB == L:G("Chest") then return false end

    if titleA == L:G("Wrist") then return true end
    if titleB == L:G("Wrist") then return false end

    if titleA == L:G("Hands") then return true end
    if titleB == L:G("Hands") then return false end

    if titleA == L:G("Waist") then return true end
    if titleB == L:G("Waist") then return false end

    if titleA == L:G("Legs") then return true end
    if titleB == L:G("Legs") then return false end

    if titleA == L:G("Feet") then return true end
    if titleB == L:G("Feet") then return false end

    if titleA == L:G("Finger") then return true end
    if titleB == L:G("Finger") then return false end

    if titleA == L:G("Trinket") then return true end
    if titleB == L:G("Trinket") then return false end

    return stripColorCode(titleA) < stripColorCode(titleB)
end

---@param text string
---@return string
function stripColorCode(text)
    if string.sub(text, 1, 4) == "|cff" then
        return string.sub(text, 11)
    end
    return text
end
