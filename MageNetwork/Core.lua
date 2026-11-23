-- Mage Network: core namespace, events, saved variables, guards, slash commands.
local ADDON, ns = ...

ns.ADDON = ADDON
ns.TITLE = "Mage Network"
ns.VERSION = "0.1.0"
ns.SCROLL_ITEM_ID = 213548
ns.COLOR_HEX = "3fc7eb"
ns.COLOR = { r = 0.247, g = 0.780, b = 0.922 }

-- Prefer the live class color if the client provides one.
do
    local cc = (C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor("MAGE"))
        or (RAID_CLASS_COLORS and RAID_CLASS_COLORS.MAGE)
    if cc and cc.r then
        ns.COLOR = { r = cc.r, g = cc.g, b = cc.b }
        ns.COLOR_HEX = string.format("%02x%02x%02x", cc.r * 255, cc.g * 255, cc.b * 255)
    end
end

local DEFAULTS = {
    batchSize = 5,
    cooldownMinutes = 15,
    showPins = true,
    sound = true,
    template = nil,        -- nil = use localized default
    explainTemplate = nil, -- nil = use localized default
    point = nil,
    contacted = {},
}

---------------------------------------------------------------------------
-- Event bus (game events + internal messages share one registry)
---------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
local handlers = {}

function ns:On(event, fn)
    local list = handlers[event]
    if not list then
        list = {}
        handlers[event] = list
        if not event:find("^MN_") then
            eventFrame:RegisterEvent(event)
        end
    end
    list[#list + 1] = fn
end

function ns:Fire(event, ...)
    local list = handlers[event]
    if not list then return end
    for i = 1, #list do
        list[i](event, ...)
    end
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    ns:Fire(event, ...)
end)

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.COLOR_HEX .. "Mage Network|r " .. tostring(msg))
end

function ns.Colorize(text)
    return "|cff" .. ns.COLOR_HEX .. tostring(text) .. "|r"
end

local function isSecret(v)
    return issecretvalue and issecretvalue(v) or false
end
ns.IsSecret = isSecret

-- Strip the realm part and return a comparable key.
function ns.ShortName(name)
    if not name or isSecret(name) then return nil end
    if Ambiguate then
        name = Ambiguate(name, "none")
    end
    name = name:gsub("%-.*$", "")
    return name
end

function ns.SameName(a, b)
    a, b = ns.ShortName(a), ns.ShortName(b)
    return a ~= nil and b ~= nil and a:lower() == b:lower()
end

-- Lowercase and fold German umlauts / common accents so "Dämm" == "damm".
local FOLD = {
    ["ä"] = "a", ["Ä"] = "a", ["ö"] = "o", ["Ö"] = "o", ["ü"] = "u", ["Ü"] = "u",
    ["ß"] = "ss", ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["à"] = "a", ["á"] = "a",
    ["ó"] = "o", ["í"] = "i", ["ñ"] = "n", ["ç"] = "c",
}
function ns.Fold(s)
    if not s then return "" end
    for k, v in pairs(FOLD) do
        s = s:gsub(k, v)
    end
    s = s:lower():gsub("['%-%s]", "")
    return s
end

-- True inside dungeons, raids, battlegrounds, arenas, scenarios.
function ns.IsBlocked()
    local inInstance, kind = IsInInstance()
    return inInstance and kind ~= "none" or false
end

---------------------------------------------------------------------------
-- Combat-safe show/hide for the main window (it owns a secure button)
---------------------------------------------------------------------------
local pendingVisibility
function ns:SetWindowShown(frame, shown)
    if not frame then return end
    if InCombatLockdown() then
        pendingVisibility = { frame = frame, shown = shown }
        if shown then ns.Print(ns.L.IN_COMBAT) end
        return
    end
    frame:SetShown(shown)
end

ns:On("PLAYER_REGEN_ENABLED", function()
    if pendingVisibility then
        local p = pendingVisibility
        pendingVisibility = nil
        p.frame:SetShown(p.shown)
    end
end)

---------------------------------------------------------------------------
-- Saved variables
---------------------------------------------------------------------------
local function applyDefaults(db, defaults)
    for k, v in pairs(defaults) do
        if db[k] == nil then
            if type(v) == "table" then
                db[k] = {}
                applyDefaults(db[k], v)
            else
                db[k] = v
            end
        end
    end
end

ns:On("ADDON_LOADED", function(_, name)
    if name ~= ADDON then return end
    if type(MageNetworkDB) ~= "table" then MageNetworkDB = {} end
    applyDefaults(MageNetworkDB, DEFAULTS)
    ns.db = MageNetworkDB
    ns:Fire("MN_DB_READY")
end)

ns:On("PLAYER_LOGIN", function()
    ns:Fire("MN_LOGIN")
end)

---------------------------------------------------------------------------
-- Entry points
---------------------------------------------------------------------------
function ns:Toggle()
    if ns.IsBlocked() then
        ns.Print(ns.L.BLOCKED)
        return
    end
    if ns.UI and ns.UI.Toggle then ns.UI:Toggle() end
end

SLASH_MAGENETWORK1 = "/mn"
SLASH_MAGENETWORK2 = "/magenetwork"
SlashCmdList.MAGENETWORK = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "where" then
        local mapID = C_Map.GetBestMapForUnit("player")
        local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then
            local x, y = pos:GetXY()
            ns.Print(string.format("mapID %d  x %.1f  y %.1f  (%s)", mapID, x * 100, y * 100,
                GetSubZoneText() ~= "" and GetSubZoneText() or GetZoneText()))
        else
            ns.Print("mapID " .. tostring(mapID))
        end
    elseif msg == "partner" then
        if ns.Party then ns.Party:SetPartnerFromTarget() end
    elseif msg == "reset" then
        ns.db.point = nil
        ns.db.contacted = {}
        if ns.UI and ns.UI.ResetPosition then ns.UI:ResetPosition() end
        ns.Print(ns.L.RESET_DONE)
    elseif msg == "help" then
        ns.Print("/mn  |  /mn where  |  /mn partner  |  /mn reset")
    else
        ns:Toggle()
    end
end

function MageNetwork_OnCompartmentClick()
    ns:Toggle()
end

function MageNetwork_OnCompartmentEnter(_, button)
    local owner = button or (AddonCompartmentFrame)
    if not owner then return end
    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip:SetText(ns.Colorize(ns.TITLE))
    GameTooltip:AddLine(ns.L.TOOLTIP_TOGGLE, 1, 1, 1)
    GameTooltip:Show()
end

function MageNetwork_OnCompartmentLeave()
    GameTooltip:Hide()
end

-- Keybinding (Bindings.xml)
BINDING_HEADER_MAGENETWORK = "Mage Network"
BINDING_NAME_MAGENETWORK_TOGGLE = "Toggle window"
function MageNetwork_ToggleBinding()
    ns:Toggle()
end
