-- Mage-only /who search for a zone.
local _, ns = ...

local Who = { results = {}, pending = false, inn = nil }
ns.Who = Who

local THROTTLE, TIMEOUT = 3, 6
local lastQuery, queryToken = 0, 0
local friendsWasShown

local function mageClassName()
    return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE.MAGE) or "Mage"
end

local function hideFriendsFrameIfWeOpenedIt()
    if friendsWasShown or InCombatLockdown() then return end
    if FriendsFrame and FriendsFrame:IsShown() then
        pcall(HideUIPanel, FriendsFrame)
    end
end

function Who:Search(inn)
    if not inn or ns.IsBlocked() then return end
    if not (C_FriendList and C_FriendList.SendWho) then return end
    local now = GetTime()
    if self.pending or now - lastQuery < THROTTLE then
        ns:Fire("MN_SEARCH_THROTTLED")
        return
    end

    local query = string.format('c-"%s" z-"%s"', mageClassName(), ns.Inns.ZoneName(inn))
    self.inn = inn
    self.pending = true
    lastQuery = now
    queryToken = queryToken + 1
    local token = queryToken

    friendsWasShown = FriendsFrame and FriendsFrame:IsShown()
    if C_FriendList.SetWhoToUi then C_FriendList.SetWhoToUi(true) end
    local origin = Enum and Enum.SocialWhoOrigin and Enum.SocialWhoOrigin.Social
    local ok = pcall(C_FriendList.SendWho, query, origin)
    if not ok then pcall(C_FriendList.SendWho, query) end

    ns:Fire("MN_SEARCH_STARTED", inn)

    C_Timer.After(TIMEOUT, function()
        if self.pending and token == queryToken then
            self.pending = false
            if C_FriendList.SetWhoToUi then C_FriendList.SetWhoToUi(false) end
            ns:Fire("MN_SEARCH_TIMEOUT")
        end
    end)
end

ns:On("WHO_LIST_UPDATE", function()
    if not Who.pending then return end
    Who.pending = false
    if C_FriendList.SetWhoToUi then C_FriendList.SetWhoToUi(false) end

    local results = {}
    local me = UnitName("player")
    local mageName = mageClassName()
    local count = C_FriendList.GetNumWhoResults and C_FriendList.GetNumWhoResults() or 0
    for i = 1, count do
        local info = C_FriendList.GetWhoInfo(i)
        if info and info.fullName and not ns.IsSecret(info.fullName)
            and (info.filename == "MAGE" or info.classStr == mageName)
            and not ns.SameName(info.fullName, me) then
            results[#results + 1] = {
                name = info.fullName,
                level = info.level,
                area = info.area,
                guild = info.fullGuildName,
            }
        end
    end
    table.sort(results, function(a, b)
        if (a.level or 0) ~= (b.level or 0) then return (a.level or 0) > (b.level or 0) end
        return a.name < b.name
    end)
    Who.results = results

    -- Blizzard's handler may open the Friends frame after ours; close it next frame.
    C_Timer.After(0, hideFriendsFrameIfWeOpenedIt)
    ns:Fire("MN_SEARCH_DONE", Who.inn, #results)
end)
