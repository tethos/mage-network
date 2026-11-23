if GetLocale() ~= "deDE" then return end
local _, ns = ...
local L = ns.L

L.IN_COMBAT = "Im Kampf nicht verfügbar. Öffnet sich nach dem Kampf."
L.BLOCKED = "In Dungeons, Schlachtzügen und Schlachtfeldern nicht verfügbar."
L.RESET_DONE = "Fensterposition und Anfrageverlauf zurückgesetzt."
L.TOOLTIP_TOGGLE = "Klicken, um das Fenster zu öffnen oder zu schließen."
L.WELCOME = "geladen. Tippe /mn oder klicke auf den Minimap-Button."
L.MINIMAP_LEFT = "Linksklick: öffnen / schließen"
L.MINIMAP_RIGHT = "Rechtsklick: Optionen"
L.MINIMAP_DRAG = "Ziehen zum Verschieben"

L.STATUS_SCROLL = "Rolle"
L.STATUS_NONE = "Keine"
L.STATUS_RESTED = "Erholt"
L.STATUS_NOT_RESTED = "Nicht erholt"

L.INPUT_PLACEHOLDER = "Wohin? z. B. Theramore"
L.SEARCH = "Suchen"
L.ASK = "Fragen %d"

L.HINT_IDLE = "Ort mit Gasthaus wählen und suchen."
L.HINT_PICK = "Wähle zuerst einen Ort aus der Liste."
L.SEARCHING = "Suche Magier in %s..."
L.FOUND = "%d Magier in %s"
L.FOUND_MATCH = "%d in %s, %d weitere in %s"
L.NONE_FOUND = "Gerade keine Magier in %s."
L.WHO_TIMEOUT = "Keine Antwort vom Server. Gleich nochmal versuchen."
L.SEARCH_THROTTLE = "Kurz warten, bevor du erneut suchst."
L.ASKED = "%d gefragt. Warte auf Antworten..."
L.NOTHING_TO_ASK = "Alle hier wurden kürzlich gefragt."
L.REPLIED = "%s hat geantwortet"

L.STATE_QUEUED = "wartet"
L.STATE_SENT = "gefragt"
L.STATE_REPLIED = "antwortet"

L.EXPLAIN = "Erklären"
L.INVITE = "Einladen"

L.PORT_TO = "Porten zu %s"
L.PORT_NEED_SCROLL = "Keine Rolle in den Taschen"
L.PORT_NEED_REST = "Du musst erholt sein"
L.PORT_WAIT_JOIN = "Warte, bis %s beitritt"
L.PORT_TIP = "Ihr müsst beide in einem Gasthaus oder einer Hauptstadt ausruhen."
L.PARTNER_SET = "Port-Partner: %s"
L.PARTNER_NONE = "Ziele zuerst ein Gruppenmitglied an."

L.OPTIONS = "Optionen"
L.BACK = "Zurück"
L.OPT_BATCH = "Magier pro Anfrage"
L.OPT_COOLDOWN = "Erneut fragen nach (Min.)"
L.OPT_PINS = "Gasthaus-Symbole auf der Karte"
L.OPT_SOUND = "Ton bei Antwort"
L.OPT_MINIMAP = "Minimap-Button"
L.OPT_TEMPLATE = "Anfrage-Nachricht"
L.OPT_EXPLAIN = "Erklär-Nachricht"
L.OPT_RESET_TEMPLATES = "Nachrichten zurücksetzen"

L.PIN_TITLE = "Gasthaus (erholt)"
L.PIN_CAPITAL = "Hauptstadt, überall erholt"
L.PIN_HINT = "Magier können sich hier zu dir porten."

L.SCROLL_NAME = "Schriftrolle des liminalen Übergangs"
L.TEMPLATE = "Hey! Könntest du ins Gasthaus in {inn} gehen? Ich würde mich gern mit einer {scroll} zu dir teleportieren. Du musst mich nur einladen. Danke :)"
L.EXPLAIN_TEMPLATE = "Das ist eine {scroll} (nur für Magier): Wenn wir in einer Gruppe sind und beide in einem Gasthaus oder einer Hauptstadt ausruhen, kann ich mich zu dir teleportieren. Stell dich einfach ins Gasthaus in {inn} und lad mich ein, dauert nur ein paar Sekunden :)"
