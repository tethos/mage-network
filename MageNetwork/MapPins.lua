-- Hearthstone pins for resting inns on the Blizzard world map.
-- Uses a native map data provider, so map addons that keep the Blizzard
-- world map canvas (Questie, etc.) show the pins without any extra hooks.
local _, ns = ...
local L = ns.L

local TEMPLATE = "MageNetworkInnPinTemplate"

-- Filled with MapCanvasPinMixin once the world map is loaded; referenced by MapPins.xml.
MageNetworkInnPinMixin = {}
local PinMixin = MageNetworkInnPinMixin

local function setupPin(pin)
    if pin.mnInit then return end
    pin.mnInit = true
    if pin.SetMouseClickEnabled then pin:SetMouseClickEnabled(false) end
    if pin.UseFrameLevelType then pin:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI") end

    local ring = pin:CreateTexture(nil, "BACKGROUND")
    ring:SetTexture(ns.Theme.WHITE)
    ring:SetVertexColor(ns.COLOR.r, ns.COLOR.g, ns.COLOR.b, 0.9)
    ring:SetPoint("TOPLEFT", -1.5, 1.5)
    ring:SetPoint("BOTTOMRIGHT", 1.5, -1.5)
    local mask = pin:CreateMaskTexture()
    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(ring)
    ring:AddMaskTexture(mask)

    local iconMask = pin:CreateMaskTexture()
    iconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    iconMask:SetAllPoints(pin.Icon)
    pin.Icon:AddMaskTexture(iconMask)
end

local methods = {}

function methods:OnAcquired(inn, x, y, small)
    setupPin(self)
    self.inn = inn
    local size = small and 12 or 18
    self:SetSize(size, size)
    if self.SetScalingLimits then self:SetScalingLimits(1, 0.85, 1.25) end
    self:SetPosition(x, y)
    if self.ApplyFrameLevel then self:ApplyFrameLevel() end
end

function methods:OnMouseEnter()
    local inn = self.inn
    if not inn then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(ns.Colorize(ns.Inns.TownName(inn)))
    if not inn.capital then
        GameTooltip:AddLine(ns.Inns.ZoneName(inn), 0.6, 0.65, 0.7)
    end
    GameTooltip:AddLine(inn.capital and L.PIN_CAPITAL or L.PIN_TITLE, 1, 1, 1)
    GameTooltip:AddLine(L.PIN_HINT, 0.6, 0.65, 0.7, true)
    GameTooltip:Show()
end

function methods:OnMouseLeave()
    GameTooltip:Hide()
end

-- Safe no-ops in case the base mixin lacks them.
function methods:OnMouseDown() end
function methods:OnMouseUp() end
function methods:OnClick() end

---------------------------------------------------------------------------
-- Data provider
---------------------------------------------------------------------------
local cache = {} -- [innIndex .. ":" .. mapID] = { x, y } or false

local function translate(fromMap, x, y, toMap)
    if not (C_Map.GetWorldPosFromMapPos and C_Map.GetMapPosFromWorldPos and CreateVector2D) then return end
    local ok, continent, world = pcall(C_Map.GetWorldPosFromMapPos, fromMap, CreateVector2D(x, y))
    if not ok or not continent or not world then return end
    local ok2, _, pos = pcall(C_Map.GetMapPosFromWorldPos, continent, world, toMap)
    if not ok2 or not pos then return end
    local px, py = pos:GetXY()
    if px and py and px >= 0 and px <= 1 and py >= 0 and py <= 1 then return px, py end
end

local function positionOn(inn, mapID, mapInfo)
    local innMap = ns.Inns.MapID(inn)
    if not innMap then return end
    if innMap == mapID then return inn.x / 100, inn.y / 100, false end

    -- Smaller pins on the continent map, and capitals on their parent zone.
    local continent = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
    local innInfo = C_Map.GetMapInfo(innMap)
    local wanted = (mapInfo.mapType == continent)
        or (inn.capital and innInfo and innInfo.parentMapID == mapID)
    if not wanted then return end

    local k = tostring(inn) .. ":" .. mapID
    if cache[k] == nil then
        local px, py = translate(innMap, inn.x / 100, inn.y / 100, mapID)
        cache[k] = px and { px, py } or false
    end
    if cache[k] then return cache[k][1], cache[k][2], true end
end

local Provider

local function buildProvider()
    Provider = CreateFromMixins(MapCanvasDataProviderMixin)

    function Provider:RemoveAllData()
        self:GetMap():RemoveAllPinsByTemplate(TEMPLATE)
    end

    function Provider:RefreshAllData()
        self:RemoveAllData()
        if not (ns.db and ns.db.showPins) then return end
        local map = self:GetMap()
        local mapID = map and map:GetMapID()
        local mapInfo = mapID and C_Map.GetMapInfo(mapID)
        if not mapInfo then return end
        for _, inn in ipairs(ns.Inns:GetAvailable()) do
            local x, y, small = positionOn(inn, mapID, mapInfo)
            if x then map:AcquirePin(TEMPLATE, inn, x, y, small) end
        end
    end
end

local attached = false
local function attach()
    if attached or not WorldMapFrame or not WorldMapFrame.AddDataProvider then return end
    if not (MapCanvasDataProviderMixin and MapCanvasPinMixin) then return end
    attached = true
    -- Base pin behaviour first, our methods on top.
    for k, v in pairs(MapCanvasPinMixin) do PinMixin[k] = v end
    for k, v in pairs(methods) do PinMixin[k] = v end
    buildProvider()
    WorldMapFrame:AddDataProvider(Provider)
end

local function safeAttach()
    local ok, err = pcall(attach)
    if not ok then
        attached = true -- don't retry and spam
        if ns.debug then ns.Print("map pins disabled: " .. tostring(err)) end
    end
end

ns:On("MN_LOGIN", safeAttach)
ns:On("ADDON_LOADED", function(_, name)
    if name == "Blizzard_WorldMap" then safeAttach() end
end)
ns:On("MN_PINS_CHANGED", function()
    if Provider and Provider:GetMap() then pcall(Provider.RefreshAllData, Provider) end
end)
