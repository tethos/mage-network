-- Round minimap button: left-click toggles, right-click opens options, drag to move.
local _, ns = ...
local L, T = ns.L, ns.Theme

local MinimapButton = {}
ns.MinimapButton = MinimapButton

local SIZE, OFFSET = 30, 10

local function place(b)
    local angle = math.rad(ns.db.minimap.angle or 200)
    local x, y = math.cos(angle), math.sin(angle)
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" then
        -- Slide along the edge of a square minimap instead of a circle.
        local m = math.max(math.abs(x), math.abs(y))
        x, y = x / m, y / m
    end
    local rx = Minimap:GetWidth() / 2 + OFFSET
    local ry = Minimap:GetHeight() / 2 + OFFSET
    b:ClearAllPoints()
    b:SetPoint("CENTER", Minimap, "CENTER", x * rx, y * ry)
end

local function onDragUpdate(self)
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    if not mx or not scale or scale == 0 then return end
    ns.db.minimap.angle = math.deg(math.atan2(cy / scale - my, cx / scale - mx))
    place(self)
end

function MinimapButton:Create()
    if self.button or not Minimap then return end
    local b = CreateFrame("Button", "MageNetworkMinimapButton", Minimap)
    self.button = b
    b:SetSize(SIZE, SIZE)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")

    local ring = T.Dot(b, SIZE)
    ring:SetDrawLayer("BACKGROUND", 0)
    ring:SetPoint("CENTER")
    ring:SetColor(T.line)

    local bg = T.Dot(b, SIZE - 3)
    bg:SetDrawLayer("BACKGROUND", 1)
    bg:SetPoint("CENTER")
    bg:SetColor({ T.bg[1], T.bg[2], T.bg[3], 1 })

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(T.LOGO)
    icon:SetSize(SIZE - 6, SIZE - 6)
    icon:SetPoint("CENTER")
    local mask = b:CreateMaskTexture()
    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)

    b:SetScript("OnClick", function(_, button)
        if button == "RightButton" then ns:OpenOptions() else ns:Toggle() end
    end)
    b:SetScript("OnEnter", function(self)
        ring:SetColor(T.accent)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(ns.Colorize(ns.TITLE))
        GameTooltip:AddLine(L.MINIMAP_LEFT, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_RIGHT, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_DRAG, 0.6, 0.65, 0.7)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function()
        ring:SetColor(T.line)
        GameTooltip:Hide()
    end)
    b:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", onDragUpdate)
    end)
    b:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    self:Update()
end

function MinimapButton:Update()
    local b = self.button
    if not b then return end
    place(b)
    b:SetShown(not ns.db.minimap.hide)
end

ns:On("MN_LOGIN", function() MinimapButton:Create() end)
ns:On("MN_MINIMAP_CHANGED", function() MinimapButton:Update() end)
