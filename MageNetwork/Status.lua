-- Player readiness: scroll in bags and rested state.
local _, ns = ...

local Status = { scrolls = 0, rested = false, place = nil }
ns.Status = Status

local function countScrolls()
    local id = ns.SCROLL_ITEM_ID
    if C_Item and C_Item.GetItemCount then
        local ok, n = pcall(C_Item.GetItemCount, id)
        if ok and type(n) == "number" then return n end
    end
    -- Fallback: walk the backpack and bags.
    local total = 0
    if C_Container and C_Container.GetContainerNumSlots then
        for bag = 0, (NUM_BAG_SLOTS or 4) do
            for slot = 1, C_Container.GetContainerNumSlots(bag) or 0 do
                if C_Container.GetContainerItemID(bag, slot) == id then
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    total = total + (info and info.stackCount or 1)
                end
            end
        end
    end
    return total
end

-- Localized item name for whisper templates (cached by the client after first query).
function Status:ScrollName()
    if C_Item and C_Item.GetItemNameByID then
        local name = C_Item.GetItemNameByID(ns.SCROLL_ITEM_ID)
        if name and name ~= "" then return name end
        if C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(ns.SCROLL_ITEM_ID) end
    end
    return ns.L.SCROLL_NAME
end

function Status:CanPort()
    return self.scrolls > 0 and self.rested and not ns.IsBlocked()
end

function Status:Update()
    local scrolls = countScrolls()
    local rested = (IsResting() and not ns.IsBlocked()) and true or false
    local place
    if rested then
        local inn = ns.Inns:FindCurrent()
        place = inn and ns.Inns.TownName(inn)
            or (GetSubZoneText() ~= "" and GetSubZoneText())
            or GetZoneText()
    end
    if scrolls ~= self.scrolls or rested ~= self.rested or place ~= self.place then
        self.scrolls, self.rested, self.place = scrolls, rested, place
        ns:Fire("MN_STATUS")
    end
end

local function update() Status:Update() end
ns:On("MN_LOGIN", function()
    Status:ScrollName() -- warm the item cache
    update()
end)
ns:On("BAG_UPDATE_DELAYED", update)
ns:On("PLAYER_UPDATE_RESTING", update)
ns:On("ZONE_CHANGED", update)
ns:On("ZONE_CHANGED_INDOORS", update)
ns:On("ZONE_CHANGED_NEW_AREA", update)
ns:On("PLAYER_ENTERING_WORLD", update)
