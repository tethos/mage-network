-- Resting inns and capital cities per faction.
-- Coordinates are 0-100 on the zone map. Use "/mn where" in game to correct a pin.
local _, ns = ...

local A, H, N = "Alliance", "Horde", "Neutral"

-- zone: shared zone definitions (Classic-era uiMapIDs; validated at runtime)
local ZONES = {
    stormwind   = { id = 1453, en = "Stormwind City",       de = "Sturmwind" },
    ironforge   = { id = 1455, en = "Ironforge",            de = "Eisenschmiede" },
    darnassus   = { id = 1457, en = "Darnassus",            de = "Darnassus" },
    orgrimmar   = { id = 1454, en = "Orgrimmar",            de = "Orgrimmar" },
    thunderbluff= { id = 1456, en = "Thunder Bluff",        de = "Donnerfels" },
    undercity   = { id = 1458, en = "Undercity",            de = "Unterstadt" },
    elwynn      = { id = 1429, en = "Elwynn Forest",        de = "Wald von Elwynn" },
    dunmorogh   = { id = 1426, en = "Dun Morogh",           de = "Dun Morogh" },
    lochmodan   = { id = 1432, en = "Loch Modan",           de = "Loch Modan" },
    redridge    = { id = 1433, en = "Redridge Mountains",   de = "Rotkammgebirge" },
    duskwood    = { id = 1431, en = "Duskwood",             de = "Dämmerwald" },
    westfall    = { id = 1436, en = "Westfall",             de = "Westfall" },
    wetlands    = { id = 1437, en = "Wetlands",             de = "Sumpfland" },
    hillsbrad   = { id = 1424, en = "Hillsbrad Foothills",  de = "Vorgebirge des Hügellands" },
    hinterlands = { id = 1425, en = "The Hinterlands",      de = "Hinterland" },
    arathi      = { id = 1417, en = "Arathi Highlands",     de = "Arathihochland" },
    badlands    = { id = 1418, en = "Badlands",             de = "Ödland" },
    sorrows     = { id = 1435, en = "Swamp of Sorrows",     de = "Sümpfe des Elends" },
    stranglethorn={ id = 1434, en = "Stranglethorn Vale",   de = "Schlingendorntal" },
    tirisfal    = { id = 1420, en = "Tirisfal Glades",      de = "Tirisfal" },
    silverpine  = { id = 1421, en = "Silverpine Forest",    de = "Silberwald" },
    darkshore   = { id = 1439, en = "Darkshore",            de = "Dunkelküste" },
    teldrassil  = { id = 1438, en = "Teldrassil",           de = "Teldrassil" },
    ashenvale   = { id = 1440, en = "Ashenvale",            de = "Eschental" },
    stonetalon  = { id = 1442, en = "Stonetalon Mountains", de = "Steinkrallengebirge" },
    desolace    = { id = 1443, en = "Desolace",             de = "Desolace" },
    feralas     = { id = 1444, en = "Feralas",              de = "Feralas" },
    dustwallow  = { id = 1445, en = "Dustwallow Marsh",     de = "Düstermarschen" },
    durotar     = { id = 1411, en = "Durotar",              de = "Durotar" },
    mulgore     = { id = 1412, en = "Mulgore",              de = "Mulgore" },
    barrens     = { id = 1413, en = "The Barrens",          de = "Brachland" },
    needles     = { id = 1441, en = "Thousand Needles",     de = "Tausend Nadeln" },
    tanaris     = { id = 1446, en = "Tanaris",              de = "Tanaris" },
    winterspring= { id = 1452, en = "Winterspring",         de = "Winterquell" },
    silithus    = { id = 1451, en = "Silithus",             de = "Silithus" },
}
ns.Zones = ZONES

-- capital = true: the whole city counts as rested.
-- areas: extra subzone names inside the town (e.g. the inn itself) that /who may report.
local INNS = {
    -- Alliance
    { faction = A, zone = "stormwind",  x = 52.6, y = 65.7, en = "Stormwind City", de = "Sturmwind", capital = true },
    { faction = A, zone = "ironforge",  x = 18.1, y = 51.4, en = "Ironforge", de = "Eisenschmiede", capital = true },
    { faction = A, zone = "darnassus",  x = 67.4, y = 15.7, en = "Darnassus", de = "Darnassus", capital = true },
    { faction = A, zone = "elwynn",     x = 43.8, y = 65.8, en = "Goldshire", de = "Goldhain", areas = { "Lion's Pride Inn" } },
    { faction = A, zone = "dunmorogh",  x = 47.4, y = 52.5, en = "Kharanos", de = "Kharanos", areas = { "Thunderbrew Distillery" } },
    { faction = A, zone = "lochmodan",  x = 35.5, y = 48.4, en = "Thelsamar", de = "Thelsamar" },
    { faction = A, zone = "redridge",   x = 27.0, y = 44.8, en = "Lakeshire", de = "Seenhain" },
    { faction = A, zone = "duskwood",   x = 73.8, y = 44.5, en = "Darkshire", de = "Dunkelhain", areas = { "Scarlet Raven Tavern" } },
    { faction = A, zone = "westfall",   x = 52.9, y = 53.7, en = "Sentinel Hill", de = "Späherkuppe" },
    { faction = A, zone = "wetlands",   x = 10.7, y = 60.9, en = "Menethil Harbor", de = "Hafen von Menethil", areas = { "Deepwater Tavern" } },
    { faction = A, zone = "hillsbrad",  x = 51.1, y = 58.9, en = "Southshore", de = "Süderstade" },
    { faction = A, zone = "hinterlands",x = 14.1, y = 41.6, en = "Aerie Peak", de = "Nistgipfel" },
    { faction = A, zone = "darkshore",  x = 37.0, y = 44.1, en = "Auberdine", de = "Auberdine" },
    { faction = A, zone = "teldrassil", x = 55.6, y = 59.8, en = "Dolanaar", de = "Dolanaar" },
    { faction = A, zone = "ashenvale",  x = 37.0, y = 49.2, en = "Astranaar", de = "Astranaar" },
    { faction = A, zone = "stonetalon", x = 35.6, y = 5.9,  en = "Stonetalon Peak", de = "Steinkrallengipfel" },
    { faction = A, zone = "desolace",   x = 66.3, y = 6.6,  en = "Nijel's Point", de = "Nijelspitze" },
    { faction = A, zone = "feralas",    x = 31.0, y = 43.4, en = "Feathermoon Stronghold", de = "Mondfederfeste" },
    { faction = A, zone = "dustwallow", x = 66.6, y = 45.2, en = "Theramore Isle", de = "Insel Theramore" },

    -- Horde
    { faction = H, zone = "orgrimmar",  x = 54.1, y = 68.4, en = "Orgrimmar", de = "Orgrimmar", capital = true },
    { faction = H, zone = "thunderbluff", x = 45.8, y = 64.6, en = "Thunder Bluff", de = "Donnerfels", capital = true },
    { faction = H, zone = "undercity",  x = 67.7, y = 37.9, en = "Undercity", de = "Unterstadt", capital = true },
    { faction = H, zone = "durotar",    x = 51.5, y = 41.6, en = "Razor Hill", de = "Klingenhügel" },
    { faction = H, zone = "mulgore",    x = 46.6, y = 61.0, en = "Bloodhoof Village", de = "Dorf der Bluthufe" },
    { faction = H, zone = "barrens",    x = 51.9, y = 29.9, en = "The Crossroads", de = "Das Wegekreuz" },
    { faction = H, zone = "barrens",    x = 45.6, y = 59.0, en = "Camp Taurajo", de = "Camp Taurajo" },
    { faction = H, zone = "tirisfal",   x = 61.7, y = 52.0, en = "Brill", de = "Brill" },
    { faction = H, zone = "silverpine", x = 43.2, y = 41.3, en = "The Sepulcher", de = "Das Grabmal" },
    { faction = H, zone = "hillsbrad",  x = 62.8, y = 19.0, en = "Tarren Mill", de = "Tarrens Mühle" },
    { faction = H, zone = "arathi",     x = 73.9, y = 32.6, en = "Hammerfall", de = "Hammerfall" },
    { faction = H, zone = "badlands",   x = 2.9,  y = 46.0, en = "Kargath", de = "Kargath" },
    { faction = H, zone = "sorrows",    x = 45.0, y = 56.6, en = "Stonard", de = "Steinard" },
    { faction = H, zone = "stranglethorn", x = 31.5, y = 29.7, en = "Grom'gol Base Camp", de = "Basislager von Grom'gol" },
    { faction = H, zone = "stonetalon", x = 47.5, y = 62.1, en = "Sun Rock Retreat", de = "Sonnenfels" },
    { faction = H, zone = "ashenvale",  x = 73.9, y = 60.6, en = "Splintertree Post", de = "Splitterholzposten" },
    { faction = H, zone = "needles",    x = 46.0, y = 51.5, en = "Freewind Post", de = "Freiwindposten" },
    { faction = H, zone = "desolace",   x = 24.1, y = 68.2, en = "Shadowprey Village", de = "Schattenflucht" },
    { faction = H, zone = "feralas",    x = 74.8, y = 45.1, en = "Camp Mojache", de = "Camp Mojache" },
    { faction = H, zone = "hinterlands",x = 78.1, y = 81.4, en = "Revantusk Village", de = "Dorf der Bruchhauer" },
    { faction = H, zone = "dustwallow", x = 35.5, y = 30.4, en = "Brackenwall Village", de = "Brackenwall" },

    -- Neutral (goblin towns, usable by both factions)
    { faction = N, zone = "stranglethorn", x = 27.0, y = 77.5, en = "Booty Bay", de = "Beutebucht", areas = { "The Salty Sailor Tavern" } },
    { faction = N, zone = "tanaris",    x = 52.5, y = 27.9, en = "Gadgetzan", de = "Gadgetzan" },
    { faction = N, zone = "barrens",    x = 62.0, y = 39.4, en = "Ratchet", de = "Ratschet" },
    { faction = N, zone = "winterspring", x = 61.3, y = 38.9, en = "Everlook", de = "Ewige Warte" },
    { faction = N, zone = "silithus",   x = 51.9, y = 39.2, en = "Cenarion Hold", de = "Burg Cenarius" },
}

local Inns = {}
ns.Inns = Inns

-- Two-letter key for the client language: "en", "de", "fr", ... (falls back to "en").
local LANG = (GetLocale() or "enUS"):sub(1, 2):lower()

-- Localized zone name (also the string sent to /who).
local function zoneName(zone)
    if zone.resolvedName then return zone.resolvedName end
    return zone[LANG] or zone.en
end

function Inns.ZoneName(inn)
    return zoneName(ZONES[inn.zone])
end

function Inns.TownName(inn)
    return inn[LANG] or inn.en
end

-- How well a /who area matches the chosen inn:
--   1 = in the town itself, 2 = name overlaps the town, 3 = elsewhere in the zone.
local function addFolded(set, name)
    if name and name ~= "" then set[#set + 1] = ns.Fold(name) end
end

local function townNames(inn)
    if inn._folded then return inn._folded end
    local set = {}
    addFolded(set, inn.en)
    addFolded(set, inn.de)
    addFolded(set, inn[LANG])
    for _, a in ipairs(inn.areas or {}) do addFolded(set, a) end
    inn._folded = set
    return set
end

function Inns.MatchRank(inn, area)
    if not inn or not area or area == "" then return 3 end
    if inn.capital then return 1 end
    local a = ns.Fold(area)
    local names = townNames(inn)
    for _, n in ipairs(names) do
        if a == n then return 1 end
    end
    for _, n in ipairs(names) do
        if #n >= 4 and (a:find(n, 1, true) or n:find(a, 1, true)) then return 2 end
    end
    return 3
end

function Inns.MapID(inn)
    local z = ZONES[inn.zone]
    return z and z.resolvedID
end

-- Build a name -> uiMapID index from the live client so wrong IDs self-heal.
local function buildMapIndex()
    local index = {}
    if not (C_Map and C_Map.GetMapChildrenInfo) then return index end
    local roots = {}
    if C_Map.GetFallbackWorldMapID then roots[#roots + 1] = C_Map.GetFallbackWorldMapID() end
    roots[#roots + 1] = 947  -- Azeroth (some clients)
    for _, root in ipairs(roots) do
        local ok, children = pcall(C_Map.GetMapChildrenInfo, root, nil, true)
        if ok and type(children) == "table" then
            for _, info in ipairs(children) do
                if info.name and not index[ns.Fold(info.name)] then
                    index[ns.Fold(info.name)] = info.mapID
                end
            end
        end
    end
    return index
end

local resolved = false
function Inns:Resolve()
    if resolved then return end
    resolved = true
    local index
    for _, zone in pairs(ZONES) do
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(zone.id)
        local fen, fde = ns.Fold(zone.en), ns.Fold(zone.de)
        if info and info.name and (ns.Fold(info.name) == fen or ns.Fold(info.name) == fde) then
            zone.resolvedID, zone.resolvedName = zone.id, info.name
        else
            index = index or buildMapIndex()
            local id = index[fen] or index[fde]
            if id then
                zone.resolvedID = id
                local i2 = C_Map.GetMapInfo(id)
                zone.resolvedName = i2 and i2.name or nil
            elseif info and info.name then
                -- Unknown locale: trust the static ID and use the client's name.
                zone.resolvedID, zone.resolvedName = zone.id, info.name
            end
        end
    end
end

-- Inns usable by the player's faction (own faction + neutral).
local available
function Inns:GetAvailable()
    if available then return available end
    local faction = UnitFactionGroup("player")
    if faction ~= A and faction ~= H then return {} end
    self:Resolve()
    available = {}
    for _, inn in ipairs(INNS) do
        if inn.faction == faction or inn.faction == N then
            inn.search = {
                ns.Fold(inn.en), ns.Fold(inn.de),
                ns.Fold(ZONES[inn.zone].en), ns.Fold(ZONES[inn.zone].de),
                ns.Fold(zoneName(ZONES[inn.zone])),
                ns.Fold(Inns.TownName(inn)),
            }
            available[#available + 1] = inn
        end
    end
    table.sort(available, function(a, b) return Inns.TownName(a) < Inns.TownName(b) end)
    return available
end

-- Matches against town and zone names in every supported language.
-- Prefix matches on the town rank highest, then zone prefixes, then substrings.
function Inns:Search(text, limit)
    local q = ns.Fold(text)
    if q == "" then return {} end
    local scored = {}
    for _, inn in ipairs(self:GetAvailable()) do
        local best
        for i, s in ipairs(inn.search) do
            local pos = s:find(q, 1, true)
            if pos then
                local score = (pos == 1 and 0 or 10) + (i <= 2 and 0 or 5)
                if not best or score < best then best = score end
            end
        end
        if best then scored[#scored + 1] = { inn = inn, score = best } end
    end
    table.sort(scored, function(a, b)
        if a.score ~= b.score then return a.score < b.score end
        return Inns.TownName(a.inn) < Inns.TownName(b.inn)
    end)
    local out = {}
    for i = 1, math.min(#scored, limit or 7) do out[i] = scored[i].inn end
    return out
end

-- The inn/capital the player is standing in, if any (by sub-zone or zone name).
function Inns:FindCurrent()
    local sub, zone = ns.Fold(GetSubZoneText() or ""), ns.Fold(GetZoneText() or "")
    for _, inn in ipairs(self:GetAvailable()) do
        if inn.capital then
            if zone == inn.search[1] or zone == inn.search[2] or zone == inn.search[5] then return inn end
        elseif sub ~= "" and (sub == inn.search[1] or sub == inn.search[2]) then
            return inn
        end
    end
end
