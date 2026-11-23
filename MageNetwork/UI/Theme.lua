-- Flat, minimal look in the mage class color.
local _, ns = ...

local T = {}
ns.Theme = T

local C = ns.COLOR
T.accent = { C.r, C.g, C.b, 1 }
T.bg     = { 0.055, 0.067, 0.086, 0.94 }
T.panel  = { 0.095, 0.110, 0.137, 1 }
T.hover  = { 0.130, 0.150, 0.185, 1 }
T.line   = { C.r, C.g, C.b, 0.45 }
T.subtle = { 1, 1, 1, 0.08 }
T.text   = { 0.90, 0.92, 0.95, 1 }
T.muted  = { 0.55, 0.60, 0.66, 1 }
T.good   = { 0.40, 0.86, 0.55, 1 }
T.off    = { 0.40, 0.43, 0.48, 1 }

local WHITE = "Interface\\Buttons\\WHITE8x8"
local CIRCLE = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
T.WHITE = WHITE
T.INN_ICON = "Interface\\Icons\\INV_Misc_Rune_01" -- hearthstone: marks inns
T.LOGO = ns.ICON                                  -- addon icon (Media/icon.tga)

local BACKDROP = { bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 }

local function font(name, size)
    local f = CreateFont(name)
    f:SetFont(STANDARD_TEXT_FONT, size, "")
    f:SetShadowOffset(1, -1)
    f:SetShadowColor(0, 0, 0, 0.6)
    return f
end
T.fontTitle = font("MageNetworkFontTitle", 13)
T.fontNormal = font("MageNetworkFontNormal", 12)
T.fontSmall = font("MageNetworkFontSmall", 10)

function T.Skin(frame, bg, border)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop(BACKDROP)
    frame:SetBackdropColor(unpack(bg or T.bg))
    frame:SetBackdropBorderColor(unpack(border or T.subtle))
end

function T.Text(parent, fontObj, color, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFontObject(fontObj or T.fontNormal)
    fs:SetTextColor(unpack(color or T.text))
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(false)
    return fs
end

function T.Line(parent, color)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture(WHITE)
    t:SetVertexColor(unpack(color or T.line))
    t:SetHeight(1)
    return t
end

-- Round colored status dot.
function T.Dot(parent, size)
    local t = parent:CreateTexture(nil, "OVERLAY")
    t:SetTexture(WHITE)
    t:SetSize(size or 7, size or 7)
    local mask = parent:CreateMaskTexture()
    mask:SetTexture(CIRCLE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(t)
    t:AddMaskTexture(mask)
    function t:SetColor(c) self:SetVertexColor(c[1], c[2], c[3], c[4] or 1) end
    return t
end

-- Apply the button look to any button (also used on the secure Port button).
function T.StyleButton(b, label, primary)
    T.Skin(b, primary and { C.r * 0.25, C.g * 0.25, C.b * 0.25, 1 } or T.panel,
        primary and T.line or T.subtle)
    local fs = b.Label or T.Text(b, T.fontNormal, primary and T.accent or T.text)
    fs:ClearAllPoints()
    fs:SetPoint("CENTER")
    fs:SetJustifyH("CENTER")
    fs:SetText(label or "")
    b.Label = fs
    b.primary = primary
    b:HookScript("OnEnter", function(self)
        if self:IsEnabled() then self:SetBackdropBorderColor(unpack(T.accent)) end
    end)
    b:HookScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(self.primary and T.line or T.subtle))
    end)
    b:HookScript("OnEnable", function(self) self:SetAlpha(1) end)
    b:HookScript("OnDisable", function(self) self:SetAlpha(0.4) end)
    function b:SetLabel(text) self.Label:SetText(text) end
    return b
end

function T.Button(parent, label, w, h, primary)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(w or 80, h or 24)
    T.StyleButton(b, label, primary)
    return b
end

-- Small text-only action (row hover actions).
function T.LinkButton(parent, label)
    local b = CreateFrame("Button", nil, parent)
    local fs = T.Text(b, T.fontSmall, T.accent)
    fs:SetPoint("CENTER")
    fs:SetText(label)
    b:SetSize(fs:GetStringWidth() + 10, 18)
    b:SetScript("OnEnter", function() fs:SetTextColor(1, 1, 1) end)
    b:SetScript("OnLeave", function() fs:SetTextColor(unpack(T.accent)) end)
    return b
end

function T.EditBox(parent, w, h, multiline)
    local holder = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    holder:SetSize(w, h)
    T.Skin(holder, T.panel, T.subtle)
    local e = CreateFrame("EditBox", nil, holder)
    e:SetFontObject(T.fontNormal)
    e:SetTextColor(unpack(T.text))
    e:SetAutoFocus(false)
    e:SetMultiLine(multiline or false)
    e:SetPoint("TOPLEFT", 8, multiline and -6 or 0)
    e:SetPoint("BOTTOMRIGHT", -8, multiline and 6 or 0)
    if multiline then e:SetMaxLetters(255) end
    e:SetScript("OnEscapePressed", e.ClearFocus)
    e:HookScript("OnEditFocusGained", function() holder:SetBackdropBorderColor(unpack(T.line)) end)
    e:HookScript("OnEditFocusLost", function() holder:SetBackdropBorderColor(unpack(T.subtle)) end)
    holder:EnableMouse(true)
    holder:SetScript("OnMouseDown", function() e:SetFocus() end)
    holder.edit = e
    return holder, e
end

-- Minimal checkbox: square + label.
function T.Toggle(parent, label, get, set)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(260, 18)
    local box = CreateFrame("Frame", nil, b, "BackdropTemplate")
    box:SetSize(12, 12)
    box:SetPoint("LEFT")
    T.Skin(box, T.panel, T.line)
    local fill = box:CreateTexture(nil, "OVERLAY")
    fill:SetTexture(WHITE)
    fill:SetVertexColor(unpack(T.accent))
    fill:SetPoint("TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", -3, 3)
    local fs = T.Text(b, T.fontNormal, T.text)
    fs:SetPoint("LEFT", box, "RIGHT", 8, 0)
    fs:SetText(label)
    function b:Refresh() fill:SetShown(get() and true or false) end
    b:SetScript("OnClick", function(self) set(not get()); self:Refresh() end)
    b:Refresh()
    return b
end

-- "Label        [-] 5 [+]"
function T.Stepper(parent, label, min, max, step, get, set)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(260, 22)
    local fs = T.Text(f, T.fontNormal, T.text)
    fs:SetPoint("LEFT")
    fs:SetText(label)
    local plus = T.Button(f, "+", 22, 20)
    plus:SetPoint("RIGHT")
    local value = T.Text(f, T.fontNormal, T.accent)
    value:SetJustifyH("CENTER")
    value:SetWidth(28)
    value:SetPoint("RIGHT", plus, "LEFT", -2, 0)
    local minus = T.Button(f, "-", 22, 20)
    minus:SetPoint("RIGHT", value, "LEFT", -2, 0)
    function f:Refresh() value:SetText(get()) end
    local function change(d)
        local v = math.max(min, math.min(max, get() + d))
        set(v)
        f:Refresh()
    end
    minus:SetScript("OnClick", function() change(-step) end)
    plus:SetScript("OnClick", function() change(step) end)
    f:Refresh()
    return f
end

-- Tiny icon button (header).
function T.IconButton(parent, texture, size)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(size or 16, size or 16)
    local t = b:CreateTexture(nil, "ARTWORK")
    t:SetAllPoints()
    t:SetTexture(texture)
    t:SetVertexColor(unpack(T.muted))
    b.icon = t
    b:SetScript("OnEnter", function() t:SetVertexColor(unpack(T.accent)) end)
    b:SetScript("OnLeave", function() t:SetVertexColor(unpack(T.muted)) end)
    return b
end
