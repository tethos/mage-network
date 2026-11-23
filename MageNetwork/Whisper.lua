-- Batch whispers with spacing, per-mage cooldowns and reply tracking.
local _, ns = ...

local Whisper = {}
ns.Whisper = Whisper

local SPACING = 1.5 -- seconds between whispers
local states = {}   -- key -> "queued" | "sent" | "replied" (this session)
local queue, pumping = {}, false

local function key(name)
    local short = ns.ShortName(name)
    return short and short:lower()
end

local sendChat = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage

local function send(text, target)
    if not sendChat or ns.IsBlocked() then return false end
    return pcall(sendChat, text, "WHISPER", nil, target)
end

function Whisper:Fill(template, inn)
    local values = {
        inn = inn and ns.Inns.TownName(inn) or "",
        zone = inn and ns.Inns.ZoneName(inn) or "",
        scroll = ns.Status:ScrollName(),
    }
    local text = template:gsub("{(%a+)}", function(k) return values[k] end)
    return (text:sub(1, 255))
end

function Whisper:State(name)
    local k = key(name)
    return k and states[k]
end

function Whisper:IsOnCooldown(name)
    local k = key(name)
    local t = k and ns.db.contacted[k]
    return t ~= nil and (time() - t) < ns.db.cooldownMinutes * 60
end

local function setState(name, state)
    local k = key(name)
    if not k then return end
    states[k] = state
    ns:Fire("MN_WHISPER_STATE", name, state)
end

local function pump()
    local item = table.remove(queue, 1)
    if not item then
        pumping = false
        return
    end
    if send(item.text, item.name) then
        ns.db.contacted[key(item.name)] = time()
        if states[key(item.name)] == "queued" then setState(item.name, "sent") end
    else
        setState(item.name, nil)
    end
    if #queue > 0 then
        C_Timer.After(SPACING, pump)
    else
        pumping = false
    end
end

local function enqueue(name, text)
    queue[#queue + 1] = { name = name, text = text }
    if not pumping then
        pumping = true
        pump()
    end
end

-- Whisper the first N mages that weren't asked recently.
function Whisper:AskBatch(results, inn)
    if ns.IsBlocked() or not results then return end
    local template = ns.db.template or ns.L.TEMPLATE
    local text = self:Fill(template, inn)
    local count = 0
    for _, r in ipairs(results) do
        if count >= ns.db.batchSize then break end
        local state = self:State(r.name)
        if state ~= "queued" and state ~= "replied" and not self:IsOnCooldown(r.name) then
            setState(r.name, "queued")
            enqueue(r.name, text)
            count = count + 1
        end
    end
    ns:Fire("MN_ASKED", count)
end

-- Follow-up for mages who don't know the scroll.
function Whisper:Explain(name, inn)
    local template = ns.db.explainTemplate or ns.L.EXPLAIN_TEMPLATE
    enqueue(name, self:Fill(template, inn))
end

function Whisper:IsContacted(name)
    local k = key(name)
    return k ~= nil and (states[k] ~= nil or ns.db.contacted[k] ~= nil)
end

local function playReplySound()
    if not ns.db.sound or not SOUNDKIT then return end
    local id = SOUNDKIT.IG_PLAYER_INVITE or SOUNDKIT.TELL_MESSAGE
    if id then PlaySound(id, "Master") end
end

ns:On("CHAT_MSG_WHISPER", function(_, _, sender)
    if not sender or ns.IsSecret(sender) then return end
    local state = Whisper:State(sender)
    if state == "sent" or state == "queued" then
        setState(sender, "replied")
        playReplySound()
        ns:Fire("MN_REPLY", sender)
    end
end)

-- Forget contacts older than a day.
ns:On("MN_DB_READY", function()
    local cutoff = time() - 86400
    for k, t in pairs(ns.db.contacted) do
        if type(t) ~= "number" or t < cutoff then ns.db.contacted[k] = nil end
    end
end)
