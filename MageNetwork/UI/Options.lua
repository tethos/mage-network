-- Inline options page (replaces the result list while open).
local _, ns = ...
local L, T = ns.L, ns.Theme

local Options = {}
ns.Options = Options

local function changed() ns:Fire("MN_OPTIONS_CHANGED") end

local function templateBox(parent, width, label, key, default)
    local title = T.Text(parent, T.fontSmall, T.muted)
    title:SetText(label)
    local holder, edit = T.EditBox(parent, width, 54, true)
    holder:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    edit:SetScript("OnTextChanged", function(self, user)
        if not user then return end
        local text = self:GetText()
        ns.db[key] = (text ~= "" and text ~= default()) and text or nil
    end)
    edit:SetScript("OnEnterPressed", edit.ClearFocus)
    function holder:Refresh() edit:SetText(ns.db[key] or default()) end
    return title, holder
end

function Options:Create(parent, width)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(width, 314)

    local batch = T.Stepper(f, L.OPT_BATCH, 1, 10, 1,
        function() return ns.db.batchSize end,
        function(v) ns.db.batchSize = v; changed() end)
    batch:SetWidth(width)
    batch:SetPoint("TOPLEFT", 0, 0)

    local cd = T.Stepper(f, L.OPT_COOLDOWN, 0, 60, 5,
        function() return ns.db.cooldownMinutes end,
        function(v) ns.db.cooldownMinutes = v; changed() end)
    cd:SetWidth(width)
    cd:SetPoint("TOPLEFT", batch, "BOTTOMLEFT", 0, -6)

    local pins = T.Toggle(f, L.OPT_PINS,
        function() return ns.db.showPins end,
        function(v) ns.db.showPins = v; ns:Fire("MN_PINS_CHANGED") end)
    pins:SetPoint("TOPLEFT", cd, "BOTTOMLEFT", 0, -10)

    local sound = T.Toggle(f, L.OPT_SOUND,
        function() return ns.db.sound end,
        function(v) ns.db.sound = v end)
    sound:SetPoint("TOPLEFT", pins, "BOTTOMLEFT", 0, -6)

    local minimap = T.Toggle(f, L.OPT_MINIMAP,
        function() return not ns.db.minimap.hide end,
        function(v) ns.db.minimap.hide = not v; ns:Fire("MN_MINIMAP_CHANGED") end)
    minimap:SetPoint("TOPLEFT", sound, "BOTTOMLEFT", 0, -6)

    local t1, ask = templateBox(f, width, L.OPT_TEMPLATE, "template", function() return L.TEMPLATE end)
    t1:SetPoint("TOPLEFT", minimap, "BOTTOMLEFT", 0, -14)

    local t2, explain = templateBox(f, width, L.OPT_EXPLAIN, "explainTemplate", function() return L.EXPLAIN_TEMPLATE end)
    t2:SetPoint("TOPLEFT", ask, "BOTTOMLEFT", 0, -10)

    local placeholders = T.Text(f, T.fontSmall, T.muted)
    placeholders:SetPoint("TOPLEFT", explain, "BOTTOMLEFT", 0, -6)
    placeholders:SetText(L.OPT_PLACEHOLDERS)

    local reset = T.LinkButton(f, L.OPT_RESET_TEMPLATES)
    reset:SetPoint("RIGHT", explain, "BOTTOMRIGHT", 4, -12)
    reset:SetScript("OnClick", function()
        ns.db.template, ns.db.explainTemplate = nil, nil
        f:Refresh()
    end)

    function f:Refresh()
        batch:Refresh(); cd:Refresh(); pins:Refresh(); sound:Refresh(); minimap:Refresh()
        ask:Refresh(); explain:Refresh()
    end
    return f
end
