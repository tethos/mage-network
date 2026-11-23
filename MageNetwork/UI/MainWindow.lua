-- The single compact window.
local _, ns = ...
local L, T = ns.L, ns.Theme

local UI = {}
ns.UI = UI

local WIDTH, HEIGHT = 300, 400
local PAD = 16

local function savePosition(f)
    local point, _, relPoint, x, y = f:GetPoint()
    ns.db.point = { point, relPoint, x, y }
end

function UI:ResetPosition()
    if not self.frame or InCombatLockdown() then return end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
end

local function chip(parent)
    local c = CreateFrame("Frame", nil, parent)
    c:SetSize(130, 16)
    c.dot = T.Dot(c, 7)
    c.dot:SetPoint("LEFT")
    c.text = T.Text(c, T.fontSmall, T.muted)
    c.text:SetPoint("LEFT", c.dot, "RIGHT", 6, 0)
    c.text:SetPoint("RIGHT")
    return c
end

function UI:Build()
    if self.frame then return end
    local f = CreateFrame("Frame", "MageNetworkFrame", UIParent, "BackdropTemplate")
    self.frame = f
    f:SetSize(WIDTH, HEIGHT)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:Hide()
    T.Skin(f, T.bg, T.line)

    local p = ns.db.point
    if p then
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    end

    -- Header (drag handle)
    local header = CreateFrame("Frame", nil, f)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(32)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() if not InCombatLockdown() then f:StartMoving() end end)
    header:SetScript("OnDragStop", function() f:StopMovingOrSizing(); savePosition(f) end)

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(T.ICON)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", PAD - 2, 0)

    local title = T.Text(header, T.fontTitle, T.accent)
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText(ns.TITLE)

    local close = T.IconButton(header, "Interface\\Buttons\\UI-StopButton", 14)
    close:SetPoint("RIGHT", -PAD + 4, 0)
    close:SetScript("OnClick", function() UI:Hide() end)

    local gear = T.IconButton(header, "Interface\\WorldMap\\Gear_64Grey", 16)
    gear:SetPoint("RIGHT", close, "LEFT", -8, 0)
    gear:SetScript("OnClick", function() UI:ToggleOptions() end)

    local line = T.Line(f, T.subtle)
    line:SetPoint("TOPLEFT", 0, -32)
    line:SetPoint("TOPRIGHT", 0, -32)

    -- Status chips
    self.scrollChip = chip(f)
    self.scrollChip:SetPoint("TOPLEFT", PAD, -42)
    self.restChip = chip(f)
    self.restChip:SetPoint("TOPLEFT", self.scrollChip, "TOPRIGHT", 8, 0)

    -- Main page (search + results); options replace it.
    local page = CreateFrame("Frame", nil, f)
    page:SetPoint("TOPLEFT", 0, -64)
    page:SetPoint("BOTTOMRIGHT", 0, 0)
    self.page = page

    self.zoneInput = ns.ZoneInput:Create(page, WIDTH - PAD * 2)
    self.zoneInput:SetPoint("TOPLEFT", PAD, 0)

    local half = (WIDTH - PAD * 2 - 8) / 2
    self.searchBtn = T.Button(page, L.SEARCH, half, 26, true)
    self.searchBtn:SetPoint("TOPLEFT", PAD, -36)
    self.searchBtn:SetScript("OnClick", function() UI:DoSearch() end)

    self.askBtn = T.Button(page, L.ASK:format(ns.db.batchSize), half, 26)
    self.askBtn:SetPoint("LEFT", self.searchBtn, "RIGHT", 8, 0)
    self.askBtn:SetScript("OnClick", function() UI:DoAsk() end)

    self.list = ns.ResultList:Create(page, WIDTH - PAD * 2)
    self.list:SetPoint("TOPLEFT", PAD, -74)

    self.hint = T.Text(page, T.fontSmall, T.muted)
    self.hint:SetPoint("BOTTOMLEFT", PAD, 50)
    self.hint:SetPoint("BOTTOMRIGHT", -PAD, 50)
    self.hint:SetText(L.HINT_IDLE)

    -- Port bar (secure button owned by Party)
    self.portButton = ns.Party:CreateButton(f, WIDTH - PAD * 2, 30)
    self.portButton:SetPoint("BOTTOMLEFT", PAD, PAD - 2)

    self.options = ns.Options:Create(f, WIDTH - PAD * 2)
    self.options:SetPoint("TOPLEFT", PAD, -64)
    self.options:Hide()

    f:SetScript("OnShow", function() ns.Status:Update(); UI:Refresh() end)
    f:SetScript("OnHide", function() if self.zoneInput then self.zoneInput:CloseSuggestions() end end)
end

function UI:ToggleOptions()
    local show = not self.options:IsShown()
    self.options:SetShown(show)
    self.page:SetShown(not show)
    if show then self.options:Refresh() end
    self:Refresh()
end

function UI:Show()
    if ns.IsBlocked() then ns.Print(L.BLOCKED) return end
    self:Build()
    ns:SetWindowShown(self.frame, true)
end

function UI:Hide()
    if self.frame then ns:SetWindowShown(self.frame, false) end
end

function UI:Toggle()
    self:Build()
    if self.frame:IsShown() then self:Hide() else self:Show() end
end

function UI:SetHint(text, color)
    if not self.hint then return end
    self.hint:SetText(text or "")
    self.hint:SetTextColor(unpack(color or T.muted))
end

function UI:DoSearch()
    local inn = self.zoneInput:GetInn()
    if not inn then
        self:SetHint(L.HINT_PICK)
        return
    end
    self.zoneInput:Select(inn)
    ns.Who:Search(inn)
end

function UI:DoAsk()
    ns.Whisper:AskBatch(ns.Who.results, ns.Who.inn)
end

function UI:Refresh()
    local f = self.frame
    if not f or not f:IsShown() then return end
    local S = ns.Status

    local sc = self.scrollChip
    sc.dot:SetColor(S.scrolls > 0 and T.good or T.off)
    sc.text:SetText(L.STATUS_SCROLL .. "  " .. S.scrolls)
    sc.text:SetTextColor(unpack(S.scrolls > 0 and T.text or T.muted))

    local rc = self.restChip
    rc.dot:SetColor(S.rested and T.good or T.off)
    rc.text:SetText(S.rested and (S.place or L.STATUS_RESTED) or L.STATUS_NOT_RESTED)
    rc.text:SetTextColor(unpack(S.rested and T.text or T.muted))

    self.askBtn:SetLabel(L.ASK:format(ns.db.batchSize))
    local blocked = ns.IsBlocked()
    self.askBtn:SetEnabled(not blocked and #ns.Who.results > 0)
    self.searchBtn:SetEnabled(not blocked and not ns.Who.pending)
    self.list:Refresh()
end

---------------------------------------------------------------------------
-- Wiring
---------------------------------------------------------------------------
local function refresh() UI:Refresh() end
ns:On("MN_STATUS", refresh)
ns:On("MN_WHISPER_STATE", refresh)
ns:On("MN_OPTIONS_CHANGED", refresh)

ns:On("MN_SEARCH_STARTED", function(_, inn)
    UI:SetHint(L.SEARCHING:format(ns.Inns.ZoneName(inn)))
    refresh()
end)
ns:On("MN_SEARCH_DONE", function(_, inn, count)
    local zone = ns.Inns.ZoneName(inn)
    if count > 0 then
        UI:SetHint(L.FOUND:format(count, zone), T.text)
    else
        UI:SetHint(L.NONE_FOUND:format(zone))
    end
    refresh()
end)
ns:On("MN_SEARCH_TIMEOUT", function() UI:SetHint(L.WHO_TIMEOUT); refresh() end)
ns:On("MN_SEARCH_THROTTLED", function() UI:SetHint(L.SEARCH_THROTTLE) end)
ns:On("MN_ASKED", function(_, count)
    if count > 0 then UI:SetHint(L.ASKED:format(count), T.text) else UI:SetHint(L.NOTHING_TO_ASK) end
    refresh()
end)
ns:On("MN_REPLY", function(_, name)
    UI:SetHint(L.REPLIED:format(ns.ShortName(name) or name), T.good)
    refresh()
end)

-- Instance guard: close and stay closed inside instances.
local function guard()
    if ns.IsBlocked() then UI:Hide() end
end
ns:On("PLAYER_ENTERING_WORLD", guard)
ns:On("ZONE_CHANGED_NEW_AREA", guard)
