local _, ns = ...

-- Missing keys fall back to the key itself so a typo never throws.
local L = setmetatable({}, { __index = function(_, k) return k end })
ns.L = L

L.IN_COMBAT = "Not available in combat. It will open when combat ends."
L.BLOCKED = "Not available in dungeons, raids or battlegrounds."
L.RESET_DONE = "Window position and ask history reset."
L.TOOLTIP_TOGGLE = "Click to toggle the window."

L.STATUS_SCROLL = "Scroll"
L.STATUS_RESTED = "Rested"
L.STATUS_NOT_RESTED = "Not rested"

L.INPUT_PLACEHOLDER = "Where to? e.g. Theramore"
L.SEARCH = "Search"
L.ASK = "Ask %d"

L.HINT_IDLE = "Pick a place with an inn and search."
L.HINT_PICK = "Pick a place from the list first."
L.SEARCHING = "Looking for mages in %s..."
L.FOUND = "%d mages in %s"
L.NONE_FOUND = "No mages in %s right now."
L.WHO_TIMEOUT = "No answer from the server. Try again in a moment."
L.SEARCH_THROTTLE = "Wait a moment before searching again."
L.ASKED = "Asked %d. Waiting for replies..."
L.NOTHING_TO_ASK = "Everyone here was asked recently."
L.REPLIED = "%s replied"

L.STATE_QUEUED = "queued"
L.STATE_SENT = "asked"
L.STATE_REPLIED = "replied"

L.EXPLAIN = "Explain"
L.INVITE = "Invite"

L.PORT_TO = "Port to %s"
L.PORT_NEED_SCROLL = "No scroll in your bags"
L.PORT_NEED_REST = "You need to be rested"
L.PORT_WAIT_JOIN = "Waiting for %s to join"
L.PORT_TIP = "Both of you must be resting in an inn or a capital city."
L.PARTNER_SET = "Port partner: %s"
L.PARTNER_NONE = "Target a party member first."

L.OPTIONS = "Options"
L.BACK = "Back"
L.OPT_BATCH = "Mages per ask"
L.OPT_COOLDOWN = "Ask again after (min)"
L.OPT_PINS = "Inn icons on the map"
L.OPT_SOUND = "Sound on reply"
L.OPT_TEMPLATE = "Ask message"
L.OPT_EXPLAIN = "Explain message"
L.OPT_PLACEHOLDERS = "{inn}  {zone}  {scroll}"
L.OPT_RESET_TEMPLATES = "Reset messages"

L.PIN_TITLE = "Resting inn"
L.PIN_CAPITAL = "Capital city, rested anywhere"
L.PIN_HINT = "Mages can port to you here."

L.SCROLL_NAME = "Scroll of Liminal Passage"
L.TEMPLATE = "Hey! Could you move to the inn at {inn}? I'd like to teleport to you with a {scroll}. You just need to invite me. Thanks :)"
L.EXPLAIN_TEMPLATE = "It's a mage-only {scroll}: if we are in a party and both resting in an inn or capital, I can teleport to you. Just stand in the inn at {inn} and invite me, takes a few seconds :)"
