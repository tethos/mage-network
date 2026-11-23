-- Zone/town input with live suggestions (only places that have a resting inn).
local _, ns = ...
local L, T = ns.L, ns.Theme

local ZoneInput = {}
ns.ZoneInput = ZoneInput

local MAX_SUGGESTIONS, ROW_H = 7, 22

function ZoneInput:Create(parent, width)
    local holder, edit = T.EditBox(parent, width, 26)
    local Inns = ns.Inns

    local placeholder = T.Text(holder, T.fontNormal, T.off)
    placeholder:SetPoint("LEFT", 8, 0)
    placeholder:SetText(L.INPUT_PLACEHOLDER)

    local drop = CreateFrame("Frame", nil, holder, "BackdropTemplate")
    drop:SetFrameStrata("DIALOG")
    drop:SetPoint("TOPLEFT", holder, "BOTTOMLEFT", 0, -2)
    drop:SetWidth(width)
    T.Skin(drop, { T.panel[1], T.panel[2], T.panel[3], 0.98 }, T.line)
    drop:Hide()

    local rows, matches, highlight = {}, {}, 0
    local selected

    local function paint()
        for i, r in ipairs(rows) do
            local on = (i == highlight) or r:IsMouseOver()
            r:SetBackdropColor(unpack(on and T.hover or { 0, 0, 0, 0 }))
        end
    end

    local function select(inn)
        selected = inn
        edit:SetText(Inns.TownName(inn))
        edit:SetCursorPosition(0)
        placeholder:Hide()
        drop:Hide()
        ns:Fire("MN_INN_SELECTED", inn)
    end

    for i = 1, MAX_SUGGESTIONS do
        local r = CreateFrame("Button", nil, drop, "BackdropTemplate")
        r:SetSize(width - 2, ROW_H)
        r:SetPoint("TOPLEFT", 1, -1 - (i - 1) * ROW_H)
        T.Skin(r, { 0, 0, 0, 0 }, { 0, 0, 0, 0 })
        r.icon = r:CreateTexture(nil, "ARTWORK")
        r.icon:SetTexture(T.ICON)
        r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        r.icon:SetSize(12, 12)
        r.icon:SetPoint("LEFT", 8, 0)
        r.town = T.Text(r, T.fontNormal, T.text)
        r.town:SetPoint("LEFT", r.icon, "RIGHT", 8, 0)
        r.zone = T.Text(r, T.fontSmall, T.muted)
        r.zone:SetPoint("RIGHT", -8, 0)
        r.zone:SetJustifyH("RIGHT")
        r:SetScript("OnEnter", paint)
        r:SetScript("OnLeave", paint)
        r:SetScript("OnClick", function(self)
            if self.inn then select(self.inn) end
        end)
        rows[i] = r
    end

    local function update()
        local text = edit:GetText()
        placeholder:SetShown(text == "" and not edit:HasFocus())
        matches = Inns:Search(text, MAX_SUGGESTIONS)
        -- Don't re-suggest the exact place that is already selected.
        if selected and #matches == 1 and matches[1] == selected then matches = {} end
        highlight = #matches > 0 and 1 or 0
        for i, r in ipairs(rows) do
            local inn = matches[i]
            r.inn = inn
            if inn then
                r.town:SetText(Inns.TownName(inn))
                r.zone:SetText(inn.capital and "" or Inns.ZoneName(inn))
                r:Show()
            else
                r:Hide()
            end
        end
        drop:SetHeight(#matches * ROW_H + 2)
        drop:SetShown(#matches > 0 and edit:HasFocus())
        paint()
    end

    edit:SetScript("OnTextChanged", function(_, user)
        if user then selected = nil end
        update()
    end)
    edit:SetScript("OnEditFocusGained", function()
        holder:SetBackdropBorderColor(unpack(T.line))
        placeholder:Hide()
        update()
    end)
    edit:SetScript("OnEditFocusLost", function()
        holder:SetBackdropBorderColor(unpack(T.subtle))
        placeholder:SetShown(edit:GetText() == "")
        -- Delay so a click on a suggestion still lands.
        C_Timer.After(0.15, function() if not edit:HasFocus() then drop:Hide() end end)
    end)
    edit:SetScript("OnArrowPressed", function(_, key)
        if #matches == 0 then return end
        if key == "DOWN" then highlight = highlight % #matches + 1
        elseif key == "UP" then highlight = (highlight - 2) % #matches + 1 end
        paint()
    end)
    edit:SetScript("OnTabPressed", function()
        if matches[highlight] then select(matches[highlight]) end
    end)
    edit:SetScript("OnEnterPressed", function()
        if drop:IsShown() and matches[highlight] then select(matches[highlight]) end
        edit:ClearFocus()
        ns.UI:DoSearch()
    end)
    edit:SetScript("OnEscapePressed", function()
        if drop:IsShown() then drop:Hide() else edit:ClearFocus() end
    end)

    function holder:GetInn()
        return selected or Inns:Search(edit:GetText(), 1)[1]
    end
    function holder:Select(inn)
        if inn ~= selected then select(inn) end
    end
    function holder:CloseSuggestions()
        drop:Hide()
        edit:ClearFocus()
    end
    return holder
end
