-- Tracks the "port partner" (the mage who invited you, or whom you invited)
-- and drives the secure Port button: /target <their unit> + /use the scroll.
local _, ns = ...
local L = ns.L

local Party = { partner = nil, source = nil, unit = nil, joined = false }
ns.Party = Party

local function myName()
    return UnitName("player")
end

-- Iterate group unit tokens except the player.
local function eachMember()
    local raid = IsInRaid()
    local n = raid and GetNumGroupMembers() or GetNumSubgroupMembers()
    local i = 0
    return function()
        while i < n do
            i = i + 1
            local unit = (raid and "raid" or "party") .. i
            local name = UnitName(unit)
            if name and not ns.IsSecret(name) and not ns.SameName(name, myName()) then
                return unit, name
            end
        end
    end
end

local function findUnit(name)
    if not name or not IsInGroup() then return nil end
    for unit, n in eachMember() do
        if ns.SameName(n, name) then return unit end
    end
end

-- If exactly one other mage is in the group, that's almost certainly the partner.
local function onlyMage()
    local found
    for unit, n in eachMember() do
        local _, class = UnitClass(unit)
        if class == "MAGE" then
            if found then return nil end
            found = GetUnitName and GetUnitName(unit, true) or n
        end
    end
    return found
end

local function isKnownMage(name)
    if ns.Whisper:IsContacted(name) then return true end
    for _, r in ipairs(ns.Who.results) do
        if ns.SameName(r.name, name) then return true end
    end
    return false
end

function Party:SetPartner(name, source)
    if not name or ns.IsSecret(name) then return end
    if self.partner and ns.SameName(self.partner, name) then
        self.source = source
    else
        self.partner, self.source, self.joined, self.unit = name, source, false, nil
        ns.Print(L.PARTNER_SET:format(ns.ShortName(name) or name))
    end
    self:Refresh()
end

function Party:Clear()
    self.partner, self.source, self.unit, self.joined = nil, nil, nil, false
    self:UpdateButton()
end

function Party:SetPartnerFromTarget()
    if UnitExists("target") and UnitIsPlayer("target") and (UnitInParty("target") or UnitInRaid("target")) then
        self:SetPartner(GetUnitName("target", true), "manual")
    else
        ns.Print(L.PARTNER_NONE)
    end
end

function Party:Invite(name)
    if not name or ns.IsBlocked() then return end
    self:SetPartner(name, "invited")
    local invite = (C_PartyInfo and C_PartyInfo.InviteUnit) or InviteUnit
    if invite then pcall(invite, name) end
end

function Party:Refresh()
    if self.partner then
        local unit = findUnit(self.partner)
        if unit then
            local firstJoin = not self.joined
            self.unit, self.joined = unit, true
            if firstJoin and ns.Status:CanPort() and ns.UI then ns.UI:Show() end
        else
            self.unit = nil
            -- They were with us and now aren't: the trip is over.
            if self.joined then
                self:Clear()
                return
            end
        end
    elseif IsInGroup() then
        local mage = onlyMage()
        if mage then
            self.partner, self.source = mage, "auto"
            self.unit, self.joined = findUnit(mage), true
        end
    end
    self:UpdateButton()
end

---------------------------------------------------------------------------
-- Secure Port button
---------------------------------------------------------------------------
function Party:CreateButton(parent, width, height)
    local b = CreateFrame("Button", "MageNetworkPortButton", parent,
        "SecureActionButtonTemplate,BackdropTemplate")
    b:SetSize(width, height)
    b:RegisterForClicks("AnyUp", "AnyDown")
    ns.Theme.StyleButton(b, "", true)
    b:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(ns.Colorize(ns.Status:ScrollName()))
        GameTooltip:AddLine(L.PORT_TIP, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    b:HookScript("OnLeave", function() GameTooltip:Hide() end)
    b:Hide()
    self.button = b
    self:UpdateButton()
    return b
end

function Party:UpdateButton()
    local b = self.button
    if not b then return end
    if InCombatLockdown() then
        self.dirty = true
        return
    end
    self.dirty = false

    if not self.partner then
        b:SetAttribute("type", nil)
        b:Hide()
        return
    end

    local short = ns.ShortName(self.partner) or self.partner
    local S = ns.Status
    local label, ready
    if not self.unit then
        label = L.PORT_WAIT_JOIN:format(short)
    elseif S.scrolls == 0 then
        label = L.PORT_NEED_SCROLL
    elseif not S.rested then
        label = L.PORT_NEED_REST
    else
        label = L.PORT_TO:format(short)
        ready = true
    end

    b:SetLabel(label)
    if ready then
        b:SetAttribute("type", "macro")
        b:SetAttribute("macrotext", "/target " .. self.unit .. "\n/use item:" .. ns.SCROLL_ITEM_ID)
        b:SetAlpha(1)
    else
        b:SetAttribute("type", nil)
        b:SetAlpha(0.55)
    end
    b:Show()
end

---------------------------------------------------------------------------
-- Events and hooks
---------------------------------------------------------------------------
ns:On("PARTY_INVITE_REQUEST", function(_, name)
    if name and not ns.IsSecret(name) then Party:SetPartner(name, "inviter") end
end)

local function onInvite(target)
    if type(target) ~= "string" or ns.IsSecret(target) then return end
    if UnitExists(target) then target = GetUnitName(target, true) end
    if target and isKnownMage(target) then Party:SetPartner(target, "invited") end
end
if C_PartyInfo and C_PartyInfo.InviteUnit then hooksecurefunc(C_PartyInfo, "InviteUnit", onInvite) end
if type(InviteUnit) == "function" and InviteUnit ~= (C_PartyInfo and C_PartyInfo.InviteUnit) then
    hooksecurefunc("InviteUnit", onInvite)
end

local function refresh() Party:Refresh() end
ns:On("GROUP_ROSTER_UPDATE", refresh)
ns:On("MN_STATUS", refresh)
ns:On("MN_LOGIN", refresh)
ns:On("PLAYER_REGEN_ENABLED", function()
    if Party.dirty then Party:UpdateButton() end
end)
