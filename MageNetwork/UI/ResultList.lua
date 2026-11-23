-- Result rows: mage name, level, zone; Explain / Invite appear on hover.
local _, ns = ...
local L, T = ns.L, ns.Theme

local ResultList = {}
ns.ResultList = ResultList

local ROWS, ROW_H = 8, 24

local STATE_COLOR = {
    queued = T.muted,
    sent = T.accent,
    replied = T.good,
}

local function openWhisper(name)
    if ChatFrame_SendTell then
        pcall(ChatFrame_SendTell, name)
    end
end

local function createRow(list, i, width)
    local r = CreateFrame("Button", nil, list, "BackdropTemplate")
    r:SetSize(width, ROW_H - 2)
    r:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
    T.Skin(r, { 0, 0, 0, 0 }, { 0, 0, 0, 0 })
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    r.dot = T.Dot(r, 6)
    r.dot:SetPoint("LEFT", 8, 0)

    r.name = T.Text(r, T.fontNormal, T.accent)
    r.name:SetPoint("LEFT", r.dot, "RIGHT", 8, 0)
    r.name:SetWidth(110)

    r.level = T.Text(r, T.fontSmall, T.muted)
    r.level:SetPoint("LEFT", r.name, "RIGHT", 4, 0)
    r.level:SetWidth(22)

    r.info = T.Text(r, T.fontSmall, T.muted)
    r.info:SetPoint("RIGHT", -8, 0)
    r.info:SetPoint("LEFT", r.level, "RIGHT", 4, 0)
    r.info:SetJustifyH("RIGHT")

    r.invite = T.LinkButton(r, L.INVITE)
    r.invite:SetPoint("RIGHT", -4, 0)
    r.explain = T.LinkButton(r, L.EXPLAIN)
    r.explain:SetPoint("RIGHT", r.invite, "LEFT", -2, 0)
    r.invite:Hide()
    r.explain:Hide()

    local function hover(on)
        local over = on or r:IsMouseOver()
        r.invite:SetShown(over)
        r.explain:SetShown(over)
        r.info:SetShown(not over)
        if not r.replied then
            r:SetBackdropColor(unpack(over and T.hover or { 0, 0, 0, 0 }))
        end
    end
    r:SetScript("OnEnter", function() hover(true) end)
    r:SetScript("OnLeave", function() hover(false) end)
    -- Child buttons steal OnEnter; keep actions visible while over them.
    for _, b in ipairs({ r.invite, r.explain }) do
        b:HookScript("OnEnter", function() hover(true) end)
        b:HookScript("OnLeave", function() C_Timer.After(0, function() hover(false) end) end)
    end

    r:SetScript("OnClick", function(self)
        if self.data then openWhisper(self.data.name) end
    end)
    r.invite:SetScript("OnClick", function()
        if r.data then ns.Party:Invite(r.data.name) end
    end)
    r.explain:SetScript("OnClick", function()
        if r.data then ns.Whisper:Explain(r.data.name, ns.Who.inn) end
    end)
    return r
end

function ResultList:Create(parent, width)
    local list = CreateFrame("Frame", nil, parent)
    list:SetSize(width, ROWS * ROW_H)
    list.offset = 0
    list.rows = {}
    for i = 1, ROWS do list.rows[i] = createRow(list, i, width) end

    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(self, delta)
        local max = math.max(0, #ns.Who.results - ROWS)
        self.offset = math.max(0, math.min(max, self.offset - delta))
        self:Refresh()
    end)

    function list:Refresh()
        local results = ns.Who.results
        if self.offset > math.max(0, #results - ROWS) then self.offset = 0 end
        for i, r in ipairs(self.rows) do
            local d = results[i + self.offset]
            r.data = d
            if d then
                local state = ns.Whisper:State(d.name)
                r.replied = state == "replied"
                r.dot:SetColor(STATE_COLOR[state] or T.off)
                r.name:SetText(ns.ShortName(d.name) or d.name)
                r.level:SetText(d.level or "")
                r.info:SetText(state and L["STATE_" .. state:upper()] or (d.area or ""))
                r:SetBackdropColor(unpack(r.replied and { T.good[1], T.good[2], T.good[3], 0.10 }
                    or (r:IsMouseOver() and T.hover) or { 0, 0, 0, 0 }))
                r:Show()
            else
                r:Hide()
            end
        end
    end

    ns:On("MN_SEARCH_DONE", function() list.offset = 0 end)
    return list
end
