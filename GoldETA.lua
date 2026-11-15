-- GoldETA: maaler hvor meget guld du tjener i timen, og hvornaar du har raad til dit maal (fx mount).
-- Farm runs: start og stop en maaling, og se hvilke spots der giver mest.
-- Samme stil som LevelETA. Er LevelETA installeret, vises maalet ogsaa i LevelETA's vindue.
local ADDON = "GoldETA"
local NAME = "GoldETA"
local PATH = "Interface\\AddOns\\GoldETA\\"
local TEX = PATH .. "Textures\\"
local LOGO = TEX .. "Logo"
local F_SEMI = PATH .. "Fonts\\Inter-SemiBold.ttf"
local F_BOLD = PATH .. "Fonts\\Inter-Bold.ttf"

local WINDOW = 7200     -- dit guld-tempo maales over de sidste 2 timers spilletid (samme som LevelETA's XP-tempo)
local SHORT = 900       -- "sidste 15 min"
local MIN_SPAN = 600    -- mindst 10 min data foer tempoet bruges
local MIN_ZONE = 600    -- en zone skal have mindst 10 min farmtid for at komme paa listen
local DB, ADB

-- ---------- sprog ----------
local LOC = {
  en = {
    daysFull = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"},
    months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"},
    todayW = "Today", tomorrowW = "Tomorrow", at = "%s %02d:%02d", hm = "%dh %02dm",
    perHr = "/hr", of = "of", session = "Session", ready = "%s ready", readyNow = "Ready now!",
    measuring = "Measuring...", notPace = "Not at this pace", last15 = "last 15 m", inBags = "in bags",
    before = "Ready %s before level %d", after = "%s after level %d", dayFmt = "%d days", oneDay = "1 day",
    goalHead = "%s goal", viaGold = "via GoldETA", goldReady = "Gold ready",
    sessHead = "This session", net = "Net", spotsHead = "Best farm spots", runsHead = "Farm log",
    logHead = "GoldETA farm log, best gold per hour first", logLine = "%d. %s: %s/hr  (%dx, %s, best run %s/hr)", logTip = "Save a run with the same name to add it to that farm.",
    avgAll = "Average per hour, all time", noSpots = "Farm 10 min in a zone to see it here", noRuns = "No farm runs yet",
    loot = "Looted coin", vendor = "Vendor", quest = "Quests", mail = "Mail and AH", trade = "Trade", otherIn = "Other income",
    repair = "Repairs", flight = "Flights", training = "Training", ahSpend = "Auction House", buy = "Vendor buys", otherOut = "Other spending",
    farm = "Farm", farming = "Farming %s", paused = "Paused %s", total = "Total", coin = "Looted coin",
    itemsV = "Items, vendor value", itemsA = "Items, AH value", kills = "Kills", topLoot = "Top loot",
    pause = "Pause", resume = "Resume", stop = "Stop", saveHead = "Save farm run", save = "Save", discard = "Discard",
    runSaved = "Farm run saved: %s", runSub = "%s  ·  %s%s", lastSess = "Last session: %s", lastSub = "%s  ·  %s%s",
    sessDone = "Session: %s", bestAt = "best: %s",
    settings = "Settings", tabWindow = "Window", tabGoal = "Goal", tabTime = "Play time",
    winSec = "Window", showWin = "Show window", lock = "Lock window", showMinimap = "Minimap button", size = "Size",
    detailSec = "Details", showDetails = "Show details", fuse = "Show in LevelETA's window", countBags = "Count bag items toward goal",
    goalSec = "Goal", goalAmount = "Goal amount", goalLevel = "Compare with level", presets = "Presets",
    pMount = "Mount", pEpic = "Epic mount", rhythm = "Play time", useRhythm = "Use my play times", wake = "Play from", bed = "Play until",
    rhythmInfo = "Uses LevelETA's play times when it is installed.",
    language = "Language: English", reset = "Reset session", close = "Done",
    standalone = "Works on its own. Fits into LevelETA's window when both are installed.",
    leFound = "LevelETA: found, the goal is shown in its window", leMissing = "LevelETA: not installed",
    aucFound = "Auctionator: found, AH prices are used", auxFound = "auxForever: found, AH prices are used", aucMissing = "No auxForever or Auctionator, vendor prices are used",
    tipLeft = "Left click: show or hide", tipRight = "Right click: settings", tipShift = "Shift click: start or stop farming",
    chars = "Characters", allChars = "All characters", gph = "Gold per hour", none = "none",
    expand = "Click: show or hide details",
    autoGoal = "Next goal automatically", mountDone = "You have your mount!", nextEpic = "New goal: Epic mount",
  },
  da = {
    daysFull = {"Søndag","Mandag","Tirsdag","Onsdag","Torsdag","Fredag","Lørdag"},
    months = {"jan","feb","mar","apr","maj","jun","jul","aug","sep","okt","nov","dec"},
    todayW = "I dag", tomorrowW = "I morgen", at = "%s kl. %02d:%02d", hm = "%dt %02dm",
    perHr = "/t", of = "af", session = "Session", ready = "%s klar", readyNow = "Klar nu!",
    measuring = "Måler...", notPace = "Ikke med dette tempo", last15 = "sidste 15 m", inBags = "i taskerne",
    before = "Klar %s før level %d", after = "%s efter level %d", dayFmt = "%d dage", oneDay = "1 dag",
    goalHead = "Mål: %s", viaGold = "via GoldETA", goldReady = "Guld klar",
    sessHead = "Denne session", net = "Netto", spotsHead = "Bedste farm spots", runsHead = "Farm-log",
    logHead = "GoldETA farm-log, bedste guld pr. time først", logLine = "%d. %s: %s/t  (%dx, %s, bedste run %s/t)", logTip = "Gem et run med samme navn for at lægge det til den farm.",
    avgAll = "Gennemsnit pr. time, i alt", noSpots = "Farm 10 min i en zone for at se den her", noRuns = "Ingen farm runs endnu",
    loot = "Looted coin", vendor = "Vendor", quest = "Quests", mail = "Mail og AH", trade = "Handel", otherIn = "Anden indtægt",
    repair = "Reparation", flight = "Flyveture", training = "Træning", ahSpend = "Auction House", buy = "Køb hos vendor", otherOut = "Andre udgifter",
    farm = "Farm", farming = "Farmer %s", paused = "Pause %s", total = "I alt", coin = "Looted coin",
    itemsV = "Items, vendor-pris", itemsA = "Items, AH-pris", kills = "Kills", topLoot = "Bedste loot",
    pause = "Pause", resume = "Fortsæt", stop = "Stop", saveHead = "Gem farm run", save = "Gem", discard = "Kassér",
    runSaved = "Farm run gemt: %s", runSub = "%s  ·  %s%s", lastSess = "Sidste session: %s", lastSub = "%s  ·  %s%s",
    sessDone = "Session: %s", bestAt = "bedst: %s",
    settings = "Indstillinger", tabWindow = "Vindue", tabGoal = "Mål", tabTime = "Spilletid",
    winSec = "Vindue", showWin = "Vis vinduet", lock = "Lås vinduet", showMinimap = "Minimap-knap", size = "Størrelse",
    detailSec = "Detaljer", showDetails = "Vis detaljer", fuse = "Vis i LevelETA's vindue", countBags = "Tæl items i tasken med",
    goalSec = "Mål", goalAmount = "Beløb", goalLevel = "Sammenlign med level", presets = "Forslag",
    pMount = "Mount", pEpic = "Epic mount", rhythm = "Spilletid", useRhythm = "Brug mine spilletider", wake = "Spiller fra", bed = "Spiller til",
    rhythmInfo = "Bruger LevelETA's spilletider, når den er installeret.",
    language = "Sprog: Dansk", reset = "Nulstil session", close = "Færdig",
    standalone = "Virker helt alene. Passer ind i LevelETA's vindue, når begge er installeret.",
    leFound = "LevelETA: fundet, målet vises i dens vindue", leMissing = "LevelETA: ikke installeret",
    aucFound = "Auctionator: fundet, AH-priser bruges", auxFound = "auxForever: fundet, AH-priser bruges", aucMissing = "Ingen auxForever eller Auctionator, vendor-priser bruges",
    tipLeft = "Venstreklik: vis eller skjul", tipRight = "Højreklik: indstillinger", tipShift = "Shift-klik: start eller stop farm",
    chars = "Karakterer", allChars = "Alle karakterer", gph = "Guld pr. time", none = "ingen",
    expand = "Klik: vis eller skjul detaljer",
    autoGoal = "Næste mål automatisk", mountDone = "Du har dit mount!", nextEpic = "Nyt mål: Epic mount",
  },
}
local function T(k) return (LOC[(DB and DB.lang) or "en"] or LOC.en)[k] end
local labels = {}
local function label(f, key) labels[#labels + 1] = {f, key}; f:SetText(T(key)) end
local function updateLabels() for _, x in ipairs(labels) do x[1]:SetText(T(x[2])) end end

local defaults = {
  play = 0, samples = {}, zones = {}, runs = {}, life = {p = 0, c = 0},
  goal = 1000000, goalName = "pMount", goalLevel = 40, countBags = false,
  goalAuto = true, mountGoal = 1000000, epicGoal = 10000000,
  schedule = true, sleepStart = 23 * 60, sleepEnd = 7 * 60,
  scale = 1, lang = "en", locked = false, hidden = false, mmAngle = 225, showMinimap = true,
  showDetails = false, fuse = true, tab = 1, scaleFollow = true,
}

local INC = {"loot", "vendor", "quest", "mail", "trade", "otherIn"}
local EXP = {"repair", "flight", "training", "ahSpend", "buy", "otherOut"}
-- tempoet (og dermed ETA) regner med al indtaegt minus det det koster at farme (reparation og flyveture).
-- Traening, AH-koeb og andre koeb er valg du traeffer, saa de trykker ikke tempoet ned.
local PACE_MINUS = {repair = true, flight = true}

-- ---------- smaa hjaelpere ----------
local function clock() return (GetTime and GetTime()) or 0 end
local GII = (C_Item and C_Item.GetItemInfo) or GetItemInfo

local GI = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
local SI = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
local CI = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"
-- beloeb med spillets egne moent-ikoner. Kobber skjules over 1 guld, soelv over 1000 guld.
local function money(c)
  c = math.floor((c or 0) + 0.5)
  local neg = c < 0
  if neg then c = -c end
  local g, s, k = math.floor(c / 10000), math.floor(c / 100) % 100, c % 100
  local t
  if g > 0 then
    t = g .. GI
    if s > 0 and g < 1000 then t = t .. " " .. s .. SI end
  elseif s > 0 then
    t = s .. SI
    if k > 0 then t = t .. " " .. k .. CI end
  else
    t = k .. CI
  end
  return (neg and "-" or "") .. t
end

local function gold(c)  -- kun hele guld, til maal ("230g / 100g")
  c = c or 0
  if math.abs(c) < 10000 then return money(c) end
  return math.floor(c / 10000) .. GI
end

local function dur(sec)
  sec = math.floor((sec or 0) + 0.5)
  if sec < 60 then return "<1m" end
  local m = math.floor(sec / 60)
  if m < 60 then return m .. "m" end
  return string.format(T("hm"), math.floor(m / 60), m % 60)
end

local function stopwatch(sec)
  sec = math.floor(sec or 0)
  local h, m, s = math.floor(sec / 3600), math.floor(sec / 60) % 60, sec % 60
  if h > 0 then return string.format("%d:%02d:%02d", h, m, s) end
  return string.format("%02d:%02d", m, s)
end

local function hhmm(m) return string.format("%02d:%02d", math.floor(m / 60) % 24, m % 60) end

local function midnight(t)
  local d = date("*t", math.floor(t)); d.hour, d.min, d.sec = 0, 0, 0
  return time(d)
end

-- naturlig dato som i LevelETA: "I morgen kl. 07:04", "Mandag kl. 18:30"
local function nice(t, roundMin)
  if roundMin then
    local step = roundMin * 60
    t = math.floor((t + step / 2) / step) * step
  end
  t = math.floor(t)
  local d = date("*t", t)
  local diff = math.floor((midnight(t) - midnight(time())) / 86400 + 0.5)
  local day
  if diff <= 0 then day = T("todayW")
  elseif diff == 1 then day = T("tomorrowW")
  elseif diff < 7 then day = T("daysFull")[d.wday]
  elseif DB.lang == "da" then day = string.format("%d. %s", d.day, T("months")[d.month])
  else day = string.format("%s %d", T("months")[d.month], d.day) end
  return string.format(T("at"), day, d.hour, d.min)
end

local function LE()  -- LevelETA's API, hvis LevelETA er installeret og ny nok
  local a = _G.LevelETA_API
  if type(a) == "table" and (a.version or 0) >= 1 then return a end
end

-- ---------- spilletid (bruges kun uden LevelETA; ellers bruges LevelETA's rytme) ----------
local function inRange(m, a, b)
  if a == b then return false end
  if a < b then return m >= a and m < b end
  return m >= a or m < b
end

-- klokkeslaet hvor du har spillet playSec sekunder mere
local function eta(playSec)
  local api = LE()
  if api and api.PlayETA then
    local ok, t = pcall(api.PlayETA, playSec)
    if ok and type(t) == "number" then return t end
  end
  local t0, need = time(), math.floor(playSec)
  if not DB.schedule or DB.sleepStart == DB.sleepEnd then return t0 + need end
  local d = date("*t", t0)
  local m, t = d.hour * 60 + d.min, t0 - d.sec
  for _ = 1, 4000 do
    local edge = inRange(m, DB.sleepStart, DB.sleepEnd) and DB.sleepEnd or DB.sleepStart
    local chunk = ((edge - m) % 1440) * 60
    if chunk == 0 then chunk = 1440 * 60 end
    if not inRange(m, DB.sleepStart, DB.sleepEnd) then
      if chunk >= need then return t + need end
      need = need - chunk
    end
    t = t + chunk
    m = edge
  end
  return t0 + playSec
end

-- ---------- tempo ----------
local function paceRate(span)  -- kobber pr. sekund spilletid over de sidste span sekunder, og hvor meget data der er
  local start = math.max(0, DB.play - span)
  local sum = 0
  for i = #DB.samples, 1, -1 do
    local x = DB.samples[i]
    if x.p < start then break end
    sum = sum + x.c
  end
  local have = math.min(span, DB.play - (DB.paceFrom or 0))
  if have < 1 then return nil, 0 end
  return sum / have, have
end

-- tempoet der bruges til ETA: de sidste 2 timer, ellers dit gennemsnit for al tid
local function rate()
  local r, have = paceRate(WINDOW)
  if r and have >= MIN_SPAN then return r end
  if DB.life.p >= 1800 then return DB.life.c / DB.life.p end
  return nil
end

local function addPace(c)
  if c == 0 then return end
  DB.samples[#DB.samples + 1] = {p = DB.play, c = c}
  DB.life.c = DB.life.c + c
  local cut = DB.play - WINDOW * 1.5
  while DB.samples[1] and DB.samples[1].p < cut do table.remove(DB.samples, 1) end
end

-- ---------- hent guld-historik fra LevelETA ----------
-- LevelETA gemmer dit guld i baggrunden. Har GoldETA ingen egne data endnu, hentes historikken en gang,
-- saa guld i timen og mount-tiden virker fra start. Kopien bliver, selv hvis LevelETA fjernes.
local function importLE()
  if DB.leImported then return end
  local api = LE()
  if not (api and api.GetGoldHistory) then return end
  local ok, h = pcall(api.GetGoldHistory)
  if not ok or type(h) ~= "table" or h.version ~= 1 or type(h.samples) ~= "table" or type(h.life) ~= "table" then return end
  if #DB.samples > 0 or DB.life.p >= 600 then DB.leImported = true; return end  -- har allerede egne data
  local lp = h.life.p or 0
  if lp < 600 then return end  -- for lidt endnu, proev igen ved naeste login
  local off = DB.play - (h.play or 0)
  if off < 0 then  -- flyt GoldETA's ur frem, saa LevelETA's tider passer ind
    local d = -off
    DB.play = DB.play + d
    if DB.sess and DB.sess.p0 then DB.sess.p0 = DB.sess.p0 + d end
    if DB.paceFrom then DB.paceFrom = DB.paceFrom + d end
    off = 0
  end
  for _, x in ipairs(h.samples) do
    local c = (x.k == "in" and x.c) or ((x.k == "repair" or x.k == "flight") and -x.c) or 0
    if c ~= 0 then DB.samples[#DB.samples + 1] = {p = x.p + off, c = c} end
  end
  table.sort(DB.samples, function(a, b) return a.p < b.p end)
  DB.paceFrom = math.min(DB.paceFrom or DB.play, DB.play - math.min(10800, lp))
  DB.life.p = DB.life.p + lp
  DB.life.c = DB.life.c + (h.life.c or 0)
  DB.leImported = true
end

-- ---------- vaerdi af items ----------
local function auctionator() return type(Auctionator) == "table" and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.GetAuctionPriceByItemID end
-- auxForever har et offentligt API (AuxForeverAPI) med priser fra dens egne AH-scanninger
local function auxOK() return type(AuxForeverAPI) == "table" and type(AuxForeverAPI.GetUsualPrice) == "function" end
local function aucLoaded() return auctionator() or auxOK() end

local function sellPrice(id)
  local ok, v = pcall(function() return select(11, GII(id)) end)
  return (ok and type(v) == "number") and v or 0
end

local function ahPrice(id)  -- AH-pris fra auxForever eller Auctionator (kun laesning), ellers nil
  if auxOK() then
    -- den saedvanlige pris over de sidste dage; ellers prisen fra sidste fulde scanning
    local ok, v = pcall(AuxForeverAPI.GetUsualPrice, id)
    if not (ok and type(v) == "number" and v > 0) and AuxForeverAPI.GetLatestPrice then ok, v = pcall(AuxForeverAPI.GetLatestPrice, id) end
    if ok and type(v) == "number" and v > 0 then return v end
  end
  if auctionator() then
    local ok, v = pcall(Auctionator.API.v1.GetAuctionPriceByItemID, ADDON, id)
    if ok and type(v) == "number" and v > 0 then return v end
  end
end

local bagCache = {v = 0, a = 0}
local function scanBags()
  local v, a = 0, 0
  pcall(function()
    if not (C_Container and C_Container.GetContainerNumSlots) then return end
    for b = 0, 4 do
      for s = 1, C_Container.GetContainerNumSlots(b) or 0 do
        local info = C_Container.GetContainerItemInfo(b, s)
        if info and info.itemID and not info.hasNoValue then
          local n = info.stackCount or 1
          local sp = sellPrice(info.itemID) * n
          v = v + sp
          a = a + math.max(sp, (ahPrice(info.itemID) or 0) * n)
        end
      end
    end
  end)
  bagCache.v, bagCache.a = v, a
end
local function bagValue() return aucLoaded() and bagCache.a or bagCache.v end

-- ---------- session ----------
local function newSession()
  return {start = time(), p0 = DB.play, m0 = GetMoney(), inc = {}, exp = {}}
end
local function sessNet() return GetMoney() - (DB.sess.m0 or GetMoney()) end
local function sessTime() return DB.play - (DB.sess.p0 or DB.play) end

-- ---------- farm run ----------
-- en run maaler det du looter (coin + items vaerdi), ikke dine penge. Saa taeller et item kun een gang,
-- ogsaa hvis du saelger det til en vendor midt i runnen.
local function runValue(r)
  if not r then return 0 end
  return r.coin + (aucLoaded() and r.ah or r.vend)
end
local function runTime(r)
  if not r then return 0 end
  return r.t
end
local function runRate(r)
  local t = runTime(r)
  if t < 30 then return nil end
  return runValue(r) / t
end
local function topMob(r)
  local best, n = nil, 0
  for name, k in pairs(r.mobs or {}) do if k > n then best, n = name, k end end
  return best
end
local function runName(r)
  local mob = topMob(r)
  return mob and (r.zone .. " · " .. mob) or r.zone
end

-- ---------- byggeklodser (som i LevelETA) ----------
local function fs(parent, font, size)
  local t = parent:CreateFontString(nil, "OVERLAY")
  t:SetFont(font, size, "")
  t:SetShadowOffset(0, 0)
  if t.SetWordWrap then t:SetWordWrap(false) end
  if t.SetMaxLines then t:SetMaxLines(1) end
  local set = t.SetText
  t.SetText = function(self, s) if self._txt ~= s then self._txt = s; set(self, s) end end
  return t
end

local function skin(frame, prefix, texW, canvasW)
  local top = frame:CreateTexture(nil, "BACKGROUND")
  top:SetPoint("TOPLEFT"); top:SetPoint("TOPRIGHT"); top:SetHeight(20)
  top:SetTexture(TEX .. prefix .. "Top"); top:SetTexCoord(0, texW / canvasW, 0, 40 / 64)
  local bot = frame:CreateTexture(nil, "BACKGROUND")
  bot:SetPoint("BOTTOMLEFT"); bot:SetPoint("BOTTOMRIGHT"); bot:SetHeight(20)
  bot:SetTexture(TEX .. prefix .. "Bottom"); bot:SetTexCoord(0, texW / canvasW, 0, 40 / 64)
  local mid = frame:CreateTexture(nil, "BACKGROUND")
  mid:SetPoint("TOPLEFT", top, "BOTTOMLEFT"); mid:SetPoint("BOTTOMRIGHT", bot, "TOPRIGHT")
  mid:SetTexture(TEX .. prefix .. "Mid"); mid:SetTexCoord(0, texW / canvasW, 0, 40 / 64)
end

local function header(frame, titleText)
  local title = fs(frame, F_BOLD, 15)
  title:SetPoint("LEFT", frame, "TOPLEFT", 14, -20)
  if titleText then title:SetText(titleText) end
  local line = frame:CreateTexture(nil, "ARTWORK")
  line:SetSize(22, 2); line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
  line:SetColorTexture(1, 0.8, 0.35, 0.9)
  return title
end

local function movable(frame, canMove)
  frame:SetMovable(true); frame:EnableMouse(true); frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) if canMove() then self:StartMoving() end end)
end

local function pill(parent, text, w, h)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(w, h or 24)
  local bg = b:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetTexture(TEX .. "Pill"); bg:SetTexCoord(0, 240 / 256, 0, 48 / 64)
  b.bg = bg
  b.text = fs(b, F_SEMI, (h and h < 22) and 11 or 12); b.text:SetPoint("CENTER"); b.text:SetTextColor(0.85, 0.87, 0.92)
  if text then b.text:SetText(text) end
  b.r, b.g, b.b = 0.85, 0.87, 0.92
  b.paint = function(self, r, g, bl) self.r, self.g, self.b = r, g, bl; self.text:SetTextColor(r, g, bl) end
  b:SetScript("OnEnter", function() b.text:SetTextColor(1, 0.82, 0.4) end)
  b:SetScript("OnLeave", function() b.text:SetTextColor(b.r, b.g, b.b) end)
  return b
end

-- ---------- hovedvindue ----------
local W = 260
local IW = W - 28
local f = CreateFrame("Frame", "GoldETAFrame", UIParent)
f:SetSize(W, 120)
skin(f, "Panel", 520, 1024)
movable(f, function() return not DB.locked end)
-- vinduet haenger altid i sit oeverste venstre hjoerne, saa det kun vokser nedad (fx naar en farm run starter)
local function pinTop()
  local l, t = f:GetLeft(), f:GetTop()
  if not (l and t) then return end
  f:ClearAllPoints()
  f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", l, t)
  DB.point = {"TOPLEFT", "BOTTOMLEFT", l, t}
end
f:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  pinTop()
end)
local fTitle = header(f, "|cffffffffGold|r|cffffd24aETA|r")

-- klik paa titlen: vis eller skjul detaljer
local titleBtn = CreateFrame("Button", nil, f)
titleBtn:SetPoint("TOPLEFT", 8, -8); titleBtn:SetSize(80, 26)
titleBtn:RegisterForClicks("LeftButtonUp")
titleBtn:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:AddLine(T("expand"), 0.85, 0.87, 0.92); GameTooltip:Show()
end)
titleBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

local farmBtn = pill(f, nil, 92, 20)
farmBtn:SetPoint("TOPRIGHT", -12, -10)

-- raekker: label til venstre, vaerdi til hoejre, streg eller bjaelke under (samme maal som LevelETA)
local rowPool, rowN = {}, 0
local function getRow()
  rowN = rowN + 1
  local c = rowPool[rowN]
  if c then return c end
  c = CreateFrame("Frame", nil, f)
  c.line = c:CreateTexture(nil, "ARTWORK")
  c.line:SetPoint("BOTTOMLEFT"); c.line:SetPoint("BOTTOMRIGHT"); c.line:SetHeight(1)
  c.line:SetColorTexture(1, 1, 1, 0.06)
  c.track = c:CreateTexture(nil, "ARTWORK"); c.track:SetHeight(3)
  c.track:SetColorTexture(1, 1, 1, 0.08)
  c.fill = c:CreateTexture(nil, "OVERLAY"); c.fill:SetHeight(3)
  c.fill:SetPoint("LEFT", c.track, "LEFT")
  c.value = fs(c, F_BOLD, 13); c.value:SetJustifyH("RIGHT")
  c.title = fs(c, F_SEMI, 12); c.title:SetJustifyH("LEFT")
  c.dot = c:CreateTexture(nil, "ARTWORK"); c.dot:SetSize(7, 7); c.dot:SetTexture(TEX .. "Dot")
  rowPool[rowN] = c
  return c
end

-- kind: "main" (som LevelETA's raekker), "bar" (lille raekke med bjaelke i midten), "small", "head", "dot", "sep"
local function place(c, y, h)
  if c._y ~= y or c._h ~= h then
    c._y, c._h = y, h
    c:SetHeight(h); c:ClearAllPoints()
    c:SetPoint("TOPLEFT", 14, y); c:SetPoint("TOPRIGHT", -14, y)
  end
  c:Show()
end

local function style(c, kind)
  if c._kind == kind then return end
  c._kind = kind
  c.title:ClearAllPoints(); c.value:ClearAllPoints(); c.track:ClearAllPoints()
  c.dot:Hide(); c.line:Hide(); c.track:Hide(); c.fill:Hide(); c.value:Show()
  if kind == "main" then
    c.title:SetFont(F_SEMI, 12); c.value:SetFont(F_BOLD, 13)
    c.value:SetPoint("RIGHT"); c.title:SetPoint("LEFT"); c.title:SetPoint("RIGHT", c.value, "LEFT", -8, 0)
    c.track:SetPoint("BOTTOMLEFT", 0, 1); c.track:SetPoint("BOTTOMRIGHT", 0, 1); c.track:SetHeight(3); c.fill:SetHeight(3)
  elseif kind == "bar" or kind == "barNow" then
    local big = kind == "barNow"
    c.title:SetFont(big and F_BOLD or F_SEMI, big and 13 or 11); c.value:SetFont(F_BOLD, big and 14 or 12)
    c.title:SetPoint("LEFT"); c.title:SetWidth(98)
    c.value:SetPoint("RIGHT")
    c.track:SetPoint("LEFT", 104, 0); c.track:SetPoint("RIGHT", -74, 0)
    c.track:SetHeight(big and 6 or 4); c.fill:SetHeight(big and 6 or 4)
    c.track:SetColorTexture(1, 1, 1, 0.06)
  elseif kind == "small" then
    c.title:SetFont(F_SEMI, 11); c.value:SetFont(F_BOLD, 12)
    c.value:SetPoint("RIGHT"); c.title:SetPoint("LEFT"); c.title:SetPoint("RIGHT", c.value, "LEFT", -8, 0)
  elseif kind == "head" then
    c.title:SetFont(F_BOLD, 11); c.value:SetFont(F_SEMI, 10)
    c.title:SetPoint("LEFT"); c.value:SetPoint("RIGHT")
  elseif kind == "dot" then
    c.title:SetFont(F_SEMI, 11); c.value:Hide()
    c.dot:Show(); c.dot:ClearAllPoints(); c.dot:SetPoint("LEFT", 1, 0)
    c.title:SetPoint("LEFT", 13, 0)
  elseif kind == "sep" then
    c.title:SetText(""); c.value:SetText("")
    c.line:Show()
  end
  if kind ~= "bar" and kind ~= "barNow" then c.title:SetWidth(0) end
  c.track:SetColorTexture(1, 1, 1, kind == "main" and 0.08 or 0.06)
end

local GREY, WHITE, BLUE, GOLD, ORANGE, HEADC = {0.55, 0.58, 0.64}, {0.91, 0.92, 0.94}, {0.62, 0.82, 1}, {1, 0.82, 0.29}, {1, 0.6, 0.35}, {1, 0.82, 0.4}
local function col(fsObj, c) fsObj:SetTextColor(c[1], c[2], c[3]) end

-- tegn en raekke. o = {kind, title, value, tc, vc, frac, fc (bjaelkens farve), fa (alpha), line, dotc}
local function row(y, o)
  local c = getRow()
  style(c, o.kind)
  c.title:SetText(o.title or "")
  if o.kind ~= "dot" and o.kind ~= "sep" then c.value:SetText(o.value or "") end
  col(c.title, o.tc or (o.kind == "head" and HEADC or GREY))
  if o.vc then col(c.value, o.vc) end
  local h
  if o.kind == "main" then
    local bar = type(o.frac) == "number"
    c.track:SetShown(bar); c.fill:SetShown(bar)
    if bar then
      local fc = o.fc or BLUE
      c.fill:SetColorTexture(fc[1], fc[2], fc[3], 0.9)
      c.fill:SetWidth(IW * math.max(0.02, math.min(1, o.frac)))
    end
    c.line:SetShown(not bar and o.line ~= false)
    h = bar and 28 or 24
  elseif o.kind == "bar" or o.kind == "barNow" then
    local bar = type(o.frac) == "number"
    c.track:SetShown(bar); c.fill:SetShown(bar)
    if bar then
      local fc = o.fc or BLUE
      c.fill:SetColorTexture(fc[1], fc[2], fc[3], o.fa or 0.35)
      c.fill:SetWidth(math.max(1, (IW - 104 - 74) * math.max(0, math.min(1, o.frac))))
    end
    h = o.kind == "barNow" and 26 or 17
  elseif o.kind == "small" then h = 17
  elseif o.kind == "head" then h = 20
  elseif o.kind == "dot" then
    local dc = o.dotc or GREY
    c.dot:SetVertexColor(dc[1], dc[2], dc[3]); h = 18
  elseif o.kind == "sep" then h = 13
  end
  place(c, y, h)
  return y - h
end

-- knapper i en farm run (pause og stop)
local runPause = pill(f, nil, (IW - 8) / 2, 22)
local runStop = pill(f, nil, (IW - 8) / 2, 22)
runPause:Hide(); runStop:Hide()

-- chips under raekkerne: "22g sidste 15 m", "6g 85s i taskerne"
local chip1 = fs(f, F_SEMI, 11)
local chip2 = fs(f, F_SEMI, 11)

-- ---------- toast (som LevelETA's advarsel) ----------
local toast = CreateFrame("Button", "GoldETAToast", UIParent)
toast:SetSize(280, 48); toast:SetPoint("TOP", UIParent, "TOP", 0, -150); toast:SetFrameStrata("HIGH"); toast:Hide()
skin(toast, "Panel", 520, 1024)
do
  local icon = toast:CreateTexture(nil, "ARTWORK"); icon:SetSize(26, 26); icon:SetPoint("LEFT", 12, 0); icon:SetTexture(LOGO)
  local title = fs(toast, F_BOLD, 13); title:SetPoint("TOPLEFT", 48, -9); title:SetTextColor(1, 0.82, 0.29)
  local sub = fs(toast, F_SEMI, 11); sub:SetPoint("TOPLEFT", 48, -27); sub:SetTextColor(0.75, 0.78, 0.84)
  local t = 0
  toast:SetScript("OnClick", function() toast:Hide() end)
  toast:SetScript("OnUpdate", function(self, dt)
    t = t + dt
    local a = t < 0.25 and t / 0.25 or (t > 7 and math.max(0, 1 - (t - 7)) or 1)
    self:SetAlpha(a)
    if t > 8 then self:Hide() end
  end)
  toast.show = function(head, text)
    title:SetText(head); sub:SetText(text)
    local w = math.max(title:GetStringWidth() or 0, sub:GetStringWidth() or 0) + 64
    toast:SetWidth(math.max(240, math.min(420, w)))
    t = 0; toast:SetAlpha(0); toast:Show()
    if PlaySound then pcall(PlaySound, (SOUNDKIT and SOUNDKIT.TELL_MESSAGE) or 3081) end
  end
end

-- ---------- beregninger til visning ----------
-- farm-log: alle runs med samme navn laegges sammen til en farm, saa du kan se hvilken der giver mest i timen
local function addFarm(name, zone, t, v, at)
  if not name or t <= 0 then return end
  DB.farms = DB.farms or {}
  local fm = DB.farms[name]
  if not fm then fm = {t = 0, v = 0, n = 0, best = 0}; DB.farms[name] = fm end
  fm.t, fm.v, fm.n = fm.t + t, fm.v + v, fm.n + 1
  if t >= 300 then fm.best = math.max(fm.best or 0, v / t) end  -- korte runs er for tilfaeldige til "bedste"
  fm.zone, fm.last = zone or fm.zone, at or time()
end
local function farmList()
  local l = {}
  for name, fm in pairs(DB.farms or {}) do
    if fm.t > 0 then l[#l + 1] = {name = name, r = fm.v / fm.t, n = fm.n, t = fm.t, best = fm.best or 0} end
  end
  table.sort(l, function(a, b) return a.r > b.r end)
  return l
end

local function goalInfo()
  local have = GetMoney() + (DB.countBags and bagValue() or 0)
  local goal = math.max(1, DB.goal)
  local r = rate()
  local left = goal - have
  local res = {have = have, goal = goal, frac = math.min(1, have / goal), r = r, left = left}
  if left <= 0 then res.done = true
  elseif r and r > 0 then
    res.playSec = left / r
    res.at = eta(res.playSec)
  end
  -- sammenlign med LevelETA's ETA til et level (fx mount ved 40)
  local api = LE()
  if api and api.GetLevelETA and UnitLevel("player") < DB.goalLevel then
    local ok, lt = pcall(api.GetLevelETA, DB.goalLevel)
    if ok and type(lt) == "number" then
      res.levelAt = lt
      if res.done then res.levelDiff = lt - time()
      elseif res.at then res.levelDiff = lt - res.at end
    end
  end
  return res
end

local function wallDur(sec)  -- forskel i rigtig tid: "2 dage" eller "5t 20m"
  sec = math.abs(sec)
  if sec >= 86400 * 1.5 then return string.format(T("dayFmt"), math.floor(sec / 86400 + 0.5)) end
  if sec >= 86400 then return T("oneDay") end
  return dur(sec)
end

local function goalLabel() return T(DB.goalName or "pMount") end

local function compareLine(gi)
  if not gi.levelDiff then return nil end
  if gi.levelDiff >= 0 then return string.format(T("before"), wallDur(gi.levelDiff), DB.goalLevel), {0.36, 1, 0.48} end
  return string.format(T("after"), wallDur(gi.levelDiff), DB.goalLevel), ORANGE
end

-- ---------- tegn vinduet ----------
local function drawRun(y)
  local r = DB.run
  local t = runTime(r)
  local rr = runRate(r)
  y = row(y, {kind = "main", title = string.format(T(r.paused and "paused" or "farming"), stopwatch(t)),
    tc = r.paused and GREY or {1, 0.45, 0.4}, value = rr and (money(rr * 3600) .. T("perHr")) or T("measuring"), vc = BLUE})
  y = row(y, {kind = "main", title = r.zone, value = money(runValue(r)), vc = GOLD})
  y = y - 4
  y = row(y, {kind = "small", title = T("coin"), value = money(r.coin), vc = WHITE})
  y = row(y, {kind = "small", title = T("itemsV"), value = money(r.vend), vc = WHITE})
  if aucLoaded() then y = row(y, {kind = "small", title = T("itemsA"), value = money(r.ah), vc = BLUE}) end
  y = row(y, {kind = "small", title = T("kills"), value = tostring(r.kills), vc = WHITE})
  -- bedste loot
  local list = {}
  for id, it in pairs(r.items) do list[#list + 1] = {id = id, n = it.n, v = aucLoaded() and it.a or it.v} end
  table.sort(list, function(a, b) return a.v > b.v end)
  if #list > 0 then
    y = y - 4
    y = row(y, {kind = "head", title = T("topLoot"), value = ""})
    for i = 1, math.min(3, #list) do
      local x = list[i]
      local name = (GII(x.id)) or ("item " .. x.id)
      y = row(y, {kind = "small", title = name .. " ×" .. x.n, value = money(x.v), vc = WHITE})
    end
  end
  y = y - 6
  runPause:ClearAllPoints(); runPause:SetPoint("TOPLEFT", 14, y); runPause:Show()
  runPause.text:SetText(T(r.paused and "resume" or "pause"))
  runStop:ClearAllPoints(); runStop:SetPoint("TOPRIGHT", -14, y); runStop:Show()
  runStop.text:SetText(T("stop"))
  y = y - 28
  return row(y, {kind = "sep"}) - 6
end

local function drawDetails(y)
  -- denne session: indtaegt og udgifter
  y = row(y, {kind = "sep"}) - 4
  y = row(y, {kind = "head", title = T("sessHead"), value = ""})
  local items, mx = {}, 1
  for _, k in ipairs(INC) do local v = DB.sess.inc[k] or 0; if v > 0 then items[#items + 1] = {k, v, false}; mx = math.max(mx, v) end end
  for _, k in ipairs(EXP) do local v = DB.sess.exp[k] or 0; if v > 0 then items[#items + 1] = {k, v, true}; mx = math.max(mx, v) end end
  if #items == 0 then
    y = row(y, {kind = "small", title = T("measuring"), value = ""})
  else
    for _, it in ipairs(items) do
      local neg = it[3]
      y = row(y, {kind = "bar", title = T(it[1]), value = money(neg and -it[2] or it[2]), vc = neg and ORANGE or WHITE,
        frac = it[2] / mx, fc = neg and ORANGE or BLUE, fa = neg and 0.6 or 0.5})
    end
    local net = sessNet()
    y = y - 4
    y = row(y, {kind = "small", title = T("net"), value = (net >= 0 and "+" or "") .. money(net), vc = net >= 0 and GOLD or ORANGE})
  end

  -- bedste farm spots
  y = row(y, {kind = "sep"}) - 4
  y = row(y, {kind = "head", title = T("spotsHead"), value = ""})
  local zl = {}
  local useA = aucLoaded()
  for name, z in pairs(DB.zones) do
    if z.t >= MIN_ZONE then zl[#zl + 1] = {name = name, r = (useA and z.a or z.v) / z.t} end
  end
  table.sort(zl, function(a, b) return a.r > b.r end)
  if #zl == 0 then
    y = row(y, {kind = "small", title = T("noSpots"), value = ""})
  else
    local cur = GetZoneText and GetZoneText()
    for i = 1, math.min(5, #zl) do
      local z = zl[i]
      local now = z.name == cur
      y = row(y, {kind = "bar", title = z.name, tc = now and BLUE or GREY, value = money(z.r * 3600), vc = i == 1 and BLUE or WHITE,
        frac = z.r / zl[1].r, fc = BLUE, fa = i == 1 and 0.9 or 0.35})
    end
  end

  -- farm runs
  y = row(y, {kind = "sep"}) - 4
  y = row(y, {kind = "head", title = T("runsHead"), value = ""})
  local fl = farmList()
  if #fl == 0 then
    y = row(y, {kind = "small", title = T("noRuns"), value = ""})
  else
    -- dine farms sorteret efter guld i timen (alle runs med samme navn lagt sammen), bedste oeverst
    for i = 1, math.min(6, #fl) do
      local x = fl[i]
      local title = x.name .. (x.n > 1 and ("  |cff5c6270" .. x.n .. "x|r") or "")
      y = row(y, {kind = "bar", title = title, tc = i == 1 and BLUE or GREY, value = money(x.r * 3600), vc = i == 1 and BLUE or WHITE,
        frac = x.r / math.max(1e-9, fl[1].r), fc = BLUE, fa = i == 1 and 0.9 or 0.35})
    end
  end
  if DB.life.p >= 600 then
    y = y - 6
    y = row(y, {kind = "small", title = T("avgAll"), value = money(DB.life.c / DB.life.p * 3600), vc = GOLD})
  end
  return y
end

local updateFuse  -- LevelETA-sektionen (defineres laengere nede)

local function refresh()
  if not DB then return end
  local fused = DB.fuse and LE()
  if DB.hidden then
    f:Hide()
  else
    local sc = DB.scale
    if DB.scaleFollow and LE() and type(LevelETADB) == "table" and type(LevelETADB.scale) == "number" then sc = LevelETADB.scale end
    if f._scale ~= sc then f._scale = sc; f:SetScale(sc) end
    rowN = 0
    local y = -44
    if DB.run then y = drawRun(y) else runPause:Hide(); runStop:Hide() end

    local gi = goalInfo()
    y = row(y, {kind = "main", title = goalLabel(),
      value = string.format("%s / %s  |cff5c6270%d%%|r", gold(gi.have), gold(gi.goal), math.floor(gi.frac * 100)), vc = BLUE, frac = gi.frac})
    y = row(y, {kind = "main", title = T("gph"), value = gi.r and (money(gi.r * 3600) .. T("perHr")) or T("measuring"), vc = WHITE})
    local net = sessNet()
    y = row(y, {kind = "main", title = T("session") .. " " .. dur(sessTime()), value = (net >= 0 and "+" or "") .. money(net),
      vc = net >= 0 and WHITE or ORANGE})
    local etaTxt = gi.done and T("readyNow") or (gi.at and nice(gi.at, 15)) or (gi.r and T("notPace")) or T("measuring")
    y = row(y, {kind = "main", title = string.format(T("ready"), goalLabel()), value = etaTxt, vc = GOLD, line = false})
    local cl, cc = compareLine(gi)
    if cl then y = row(y, {kind = "dot", title = cl, tc = {0.75, 0.78, 0.84}, dotc = cc}) end

    -- chips
    local r15, have15 = paceRate(SHORT)
    y = y - 6
    chip1:ClearAllPoints(); chip1:SetPoint("TOPLEFT", 14, y)
    if r15 and have15 >= 300 then
      chip1:SetText("|cff9fd0ff" .. money(r15 * 3600) .. "|r |cff8c94a3" .. T("last15") .. "|r"); chip1:Show()
    else chip1:SetText(""); chip1:Hide() end
    chip2:ClearAllPoints()
    if chip1:IsShown() then chip2:SetPoint("LEFT", chip1, "RIGHT", 14, 0) else chip2:SetPoint("TOPLEFT", 14, y) end
    chip2:SetText("|cff9fd0ff" .. money(bagValue()) .. "|r |cff8c94a3" .. T("inBags") .. "|r")
    y = y - 16

    if DB.showDetails then y = drawDetails(y - 4) end
    for i = rowN + 1, #rowPool do rowPool[i]:Hide() end
    if f._h ~= y then f._h = y; f:SetHeight(-y + 12) end
    f:Show()
  end

  -- farm-knappen oeverst
  if DB.run then
    farmBtn.text:SetText(stopwatch(runTime(DB.run)))
    if DB.run.paused then farmBtn:paint(0.55, 0.58, 0.64) else farmBtn:paint(1, 0.45, 0.4) end
  else
    farmBtn.text:SetText(T("farm")); farmBtn:paint(1, 0.82, 0.4)
  end
  if GoldETAMinimapButton then GoldETAMinimapButton:SetShown(DB.showMinimap) end
  if updateFuse then updateFuse() end
end

-- ---------- naeste maal: foerst mount (level 40), saa epic mount (level 60) ----------
-- ridning laeses fra dine skills (75 = mount, 150 = epic). Mount-samlingen bruges, hvis skill ikke kan laeses.
local function ridingRank()
  local best = 0
  pcall(function()
    if not (GetNumSkillLines and GetSkillLineInfo) then return end
    for i = 1, GetNumSkillLines() do
      local name, isHeader, _, rank = GetSkillLineInfo(i)
      if not isHeader and type(name) == "string" and name:lower():find("riding", 1, true) and type(rank) == "number" then
        best = math.max(best, rank)
      end
    end
  end)
  if best == 0 then
    pcall(function()
      if not (C_MountJournal and C_MountJournal.GetMountIDs) then return end
      for _, id in ipairs(C_MountJournal.GetMountIDs() or {}) do
        if select(11, C_MountJournal.GetMountInfoByID(id)) then best = 75; return end
      end
    end)
  end
  return best
end

local function setGoal(key)
  DB.goalName = key
  DB.goal = key == "pEpic" and DB.epicGoal or DB.mountGoal
  DB.goalLevel = key == "pEpic" and 60 or 40
end

local function autoGoal()
  if not DB or not DB.goalAuto then return end
  local r = ridingRank()
  if r >= 150 then return end  -- epic er naaet: behold maalet som det er
  local want = r >= 75 and "pEpic" or "pMount"
  if DB.goalName ~= want then
    local was = DB.goalName
    setGoal(want)
    if was == "pMount" and want == "pEpic" then toast.show(T("mountDone"), T("nextEpic")) end
    refresh()
  end
end

-- ---------- gem farm run ----------
local saveFrame = CreateFrame("Frame", "GoldETASave", UIParent)
saveFrame:SetSize(300, 132); saveFrame:SetPoint("CENTER", 0, 120); saveFrame:SetFrameStrata("DIALOG"); saveFrame:Hide()
skin(saveFrame, "Panel", 520, 1024)
movable(saveFrame, function() return true end)
saveFrame:SetScript("OnDragStop", saveFrame.StopMovingOrSizing)
local saveTitle = header(saveFrame); label(saveTitle, "saveHead")
local saveInfo = fs(saveFrame, F_SEMI, 11); saveInfo:SetPoint("TOPRIGHT", -14, -15); saveInfo:SetTextColor(0.62, 0.82, 1)
local edit = CreateFrame("EditBox", nil, saveFrame)
edit:SetSize(272, 24); edit:SetPoint("TOPLEFT", 14, -48); edit:SetAutoFocus(false)
edit:SetFont(F_SEMI, 12, ""); edit:SetTextColor(0.91, 0.92, 0.94); edit:SetTextInsets(10, 10, 0, 0)
do
  local bg = edit:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(1, 1, 1, 0.06)
  local ln = edit:CreateTexture(nil, "ARTWORK"); ln:SetPoint("BOTTOMLEFT"); ln:SetPoint("BOTTOMRIGHT"); ln:SetHeight(1); ln:SetColorTexture(1, 0.8, 0.35, 0.6)
end
local saveBtn = pill(saveFrame, nil, 130, 24); saveBtn:SetPoint("BOTTOMRIGHT", -14, 14); label(saveBtn.text, "save"); saveBtn:paint(1, 0.82, 0.4)
local discardBtn = pill(saveFrame, nil, 130, 24); discardBtn:SetPoint("BOTTOMLEFT", 14, 14); label(discardBtn.text, "discard")
local pendingRun

local function finishSave(keep)
  local r = pendingRun
  pendingRun = nil
  saveFrame:Hide()
  if not (keep and r) then return end
  local name = edit:GetText()
  if not name or name:gsub("%s", "") == "" then name = runName(r) end
  local v = runValue(r)
  table.insert(DB.runs, {name = name, zone = r.zone, t = r.t, v = v, coin = r.coin, vend = r.vend, ah = r.ah, kills = r.kills, at = time()})
  while #DB.runs > 40 do table.remove(DB.runs, 1) end
  addFarm(name, r.zone, r.t, v, time())
  local rr = r.t > 0 and v / r.t or 0
  toast.show(string.format(T("runSaved"), money(v)), string.format(T("runSub"), dur(r.t), money(rr * 3600), T("perHr")))
  refresh()
end
saveBtn:SetScript("OnClick", function() finishSave(true) end)
discardBtn:SetScript("OnClick", function() finishSave(false) end)
edit:SetScript("OnEnterPressed", function() finishSave(true) end)
edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local function startRun()
  DB.run = {zone = (GetZoneText and GetZoneText()) or "?", t = 0, coin = 0, vend = 0, ah = 0, kills = 0, mobs = {}, items = {}, paused = false}
  if DB.hidden then DB.hidden = false end
  refresh()
end
local function stopRun()
  local r = DB.run
  if not r then return end
  DB.run = nil
  if r.t < 30 then refresh(); return end  -- under et halvt minut: ikke vaerd at gemme
  pendingRun = r
  edit:SetText(runName(r))
  saveInfo:SetText(money(runValue(r)) .. "  ·  " .. dur(r.t))
  saveFrame:Show()
  edit:SetFocus(); edit:HighlightText()
  refresh()
end
local function toggleRun() if DB.run then stopRun() else startRun() end end
GoldETA_ToggleFarm = function() if DB then toggleRun() end end  -- til keybind

farmBtn:SetScript("OnClick", toggleRun)
runStop:SetScript("OnClick", stopRun)
runPause:SetScript("OnClick", function() if DB.run then DB.run.paused = not DB.run.paused; refresh() end end)
titleBtn:SetScript("OnClick", function() DB.showDetails = not DB.showDetails; refresh() end)

-- ---------- sektion i LevelETA's vindue ----------
do
  local sec, rowsF, h = nil, {}, 0
  local SW = W - 28
  local function sRow(i)
    local c = rowsF[i]
    if c then return c end
    c = CreateFrame("Frame", nil, sec)
    c.title = fs(c, F_SEMI, 12); c.title:SetPoint("LEFT"); c.title:SetJustifyH("LEFT")
    c.value = fs(c, F_BOLD, 13); c.value:SetPoint("RIGHT"); c.value:SetJustifyH("RIGHT")
    c.track = c:CreateTexture(nil, "ARTWORK"); c.track:SetPoint("BOTTOMLEFT", 0, 1); c.track:SetPoint("BOTTOMRIGHT", 0, 1)
    c.track:SetHeight(3); c.track:SetColorTexture(1, 1, 1, 0.08)
    c.fill = c:CreateTexture(nil, "OVERLAY"); c.fill:SetPoint("BOTTOMLEFT", c.track, "BOTTOMLEFT"); c.fill:SetHeight(3)
    c.fill:SetColorTexture(1, 0.82, 0.29, 0.9)
    c.dot = c:CreateTexture(nil, "ARTWORK"); c.dot:SetSize(7, 7); c.dot:SetTexture(TEX .. "Dot"); c.dot:SetPoint("LEFT", 1, 0)
    rowsF[i] = c
    return c
  end
  local sepT, headT, viaT

  local function build(parent)
    sec = CreateFrame("Frame", nil, parent)
    sec:SetAllPoints(parent)
    sepT = sec:CreateTexture(nil, "ARTWORK"); sepT:SetHeight(1); sepT:SetColorTexture(1, 1, 1, 0.06)
    sepT:SetPoint("TOPLEFT", 0, -6); sepT:SetPoint("TOPRIGHT", 0, -6)
    headT = fs(sec, F_BOLD, 11); headT:SetTextColor(1, 0.82, 0.4); headT:SetPoint("TOPLEFT", 0, -16)
    viaT = fs(sec, F_SEMI, 10); viaT:SetTextColor(0.36, 0.38, 0.44); viaT:SetPoint("TOPRIGHT", 0, -17)
    updateFuse()
  end

  local function height() return h end

  updateFuse = function()
    local api = LE()
    if not api then return end
    if not api._goldReg then
      api._goldReg = true
      pcall(api.RegisterSection, ADDON, build, height)
      return
    end
    local newH = 0
    if DB.fuse and sec then
      local gi = goalInfo()
      headT:SetText(string.format(T("goalHead"), goalLabel())); viaT:SetText("")
      local y = -34
      local c = sRow(1)
      c:SetHeight(28); c:ClearAllPoints(); c:SetPoint("TOPLEFT", 0, y); c:SetPoint("TOPRIGHT", 0, y)
      c.title:SetText(gold(gi.have) .. " / " .. gold(gi.goal)); c.title:SetTextColor(0.55, 0.58, 0.64)
      if gi.done then
        c.value:SetText(string.format("|cff5c6270%d%%|r", math.floor(gi.frac * 100)))
      else
        c.value:SetText(string.format("|cffffd24a%s|r  |cff5c6270%d%%|r", gi.r and (money(gi.r * 3600) .. T("perHr")) or T("measuring"), math.floor(gi.frac * 100)))
      end
      c.track:Show(); c.fill:Show(); c.dot:Hide()
      c.fill:SetWidth(SW * math.max(0.02, gi.frac)); c:Show()
      y = y - 28
      c = sRow(2)
      c:SetHeight(24); c:ClearAllPoints(); c:SetPoint("TOPLEFT", 0, y); c:SetPoint("TOPRIGHT", 0, y)
      c.title:SetText(T("goldReady")); c.title:SetTextColor(0.55, 0.58, 0.64)
      c.value:SetText("|cffffd24a" .. (gi.done and T("readyNow") or (gi.at and nice(gi.at, 15)) or (gi.r and T("notPace")) or T("measuring")) .. "|r")
      c.track:Hide(); c.fill:Hide(); c.dot:Hide(); c:Show()
      y = y - 24
      local cl, cc = compareLine(gi)
      c = sRow(3)
      if cl then
        c:SetHeight(18); c:ClearAllPoints(); c:SetPoint("TOPLEFT", 0, y); c:SetPoint("TOPRIGHT", 0, y)
        c.title:ClearAllPoints(); c.title:SetPoint("LEFT", 13, 0)
        c.title:SetFont(F_SEMI, 11); c.title:SetText(cl); c.title:SetTextColor(0.75, 0.78, 0.84)
        c.value:SetText(""); c.track:Hide(); c.fill:Hide()
        c.dot:SetVertexColor(cc[1], cc[2], cc[3]); c.dot:Show(); c:Show()
        y = y - 18
      else
        c:Hide()
      end
      newH = -y + 2
      sec:Show()
    elseif sec then
      sec:Hide()
    end
    if newH ~= h then
      h = newH
      if api.Refresh then pcall(api.Refresh) end  -- LevelETA's vindue skal skifte hoejde
    end
  end
end

-- ---------- indstillinger ----------
local S, controls, toggleSettings, toggleWindow
do
local SW, COL = 520, 260
S = CreateFrame("Frame", "GoldETASettings", UIParent)
S:SetSize(SW, 430); S:SetPoint("CENTER"); S:SetFrameStrata("DIALOG"); S:Hide()
skin(S, "Wide", 1040, 2048)
movable(S, function() return true end)
S:SetScript("OnDragStop", S.StopMovingOrSizing)
tinsert(UISpecialFrames, "GoldETASettings")
local sTitle = header(S)
label(sTitle, "settings")

local closeX = CreateFrame("Button", nil, S)
closeX:SetSize(20, 20); closeX:SetPoint("TOPRIGHT", -10, -10)
local closeT = fs(closeX, F_BOLD, 16); closeT:SetPoint("CENTER"); closeT:SetText("×"); closeT:SetTextColor(0.55, 0.58, 0.64)
closeX:SetScript("OnEnter", function() closeT:SetTextColor(1, 1, 1) end)
closeX:SetScript("OnLeave", function() closeT:SetTextColor(0.55, 0.58, 0.64) end)
closeX:SetScript("OnClick", function() S:Hide() end)

controls = {}
local colX = 0
local host = S

local function section(y, key)
  local t = fs(host, F_BOLD, 11); t:SetPoint("TOPLEFT", colX + 18, y); t:SetTextColor(1, 0.82, 0.4)
  label(t, key)
end

local function toggle(y, lkey, get, set)
  local c = CreateFrame("CheckButton", nil, host)
  c:SetSize(32, 18); c:SetPoint("TOPRIGHT", host, "TOPLEFT", colX + COL - 18, y)
  local off = c:CreateTexture(nil, "ARTWORK"); off:SetAllPoints(); off:SetTexture(TEX .. "ToggleOff"); off:SetTexCoord(0, 1, 0, 36 / 64)
  local on = c:CreateTexture(nil, "ARTWORK"); on:SetAllPoints(); on:SetTexture(TEX .. "ToggleOn"); on:SetTexCoord(0, 1, 0, 36 / 64)
  local t = fs(host, F_SEMI, 12); t:SetPoint("TOPLEFT", colX + 18, y - 2); t:SetTextColor(0.85, 0.87, 0.92)
  label(t, lkey)
  local function show() local v = get(); on:SetShown(v); off:SetShown(not v) end
  c:SetScript("OnClick", function() set(not get()); show(); refresh() end)
  c.load = show
  controls[#controls + 1] = c
end

local function slider(y, lkey, minV, maxV, step, get, set, fmt)
  local t = fs(host, F_SEMI, 12); t:SetPoint("TOPLEFT", colX + 18, y); t:SetTextColor(0.85, 0.87, 0.92)
  label(t, lkey)
  local val = fs(host, F_BOLD, 12); val:SetPoint("TOPRIGHT", host, "TOPLEFT", colX + COL - 18, y); val:SetTextColor(1, 0.82, 0.4)
  local tw = COL - 36
  local s = CreateFrame("Slider", nil, host)
  s:SetOrientation("HORIZONTAL")
  s:SetSize(tw, 16); s:SetPoint("TOPLEFT", colX + 18, y - 18)
  local track = s:CreateTexture(nil, "BACKGROUND")
  track:SetPoint("LEFT"); track:SetPoint("RIGHT"); track:SetHeight(3); track:SetColorTexture(1, 1, 1, 0.12)
  local fill = s:CreateTexture(nil, "ARTWORK")
  fill:SetPoint("LEFT"); fill:SetHeight(3); fill:SetColorTexture(1, 0.8, 0.35, 0.9)
  s:SetThumbTexture(TEX .. "Thumb")
  local thumb = s:GetThumbTexture(); if thumb then thumb:SetSize(16, 16) end
  s:SetMinMaxValues(minV, maxV); s:SetValueStep(step)
  if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
  s:EnableMouseWheel(true)
  s:SetScript("OnMouseWheel", function(self, d)
    self:SetValue(math.max(minV, math.min(maxV, self:GetValue() + d * step)))
  end)
  local function paint(v)
    val:SetText(fmt(v))
    fill:SetWidth(math.max(1, tw * (v - minV) / (maxV - minV)))
  end
  s:SetScript("OnValueChanged", function(self, v)
    v = math.floor(v / step + 0.5) * step
    paint(v)
    if self.loading then return end
    set(v); refresh()
  end)
  s.load = function() s.loading = true; s:SetValue(get()); paint(get()); s.loading = false end
  controls[#controls + 1] = s
end

local TABS = {"tabWindow", "tabGoal", "tabTime"}
local pages, tabBtns = {}, {}
local function paintTabs()
  for k, b in ipairs(tabBtns) do
    local on = k == (DB and DB.tab or 1)
    b:paint(on and 1 or 0.55, on and 0.82 or 0.58, on and 0.4 or 0.64)
    b.bg:SetAlpha(on and 1 or 0.45)
  end
end
local function showTab(i)
  DB.tab = i
  for k, p in ipairs(pages) do p:SetShown(k == i) end
  paintTabs()
end
local TBW = (SW - 36 - 16) / 3
for i, key in ipairs(TABS) do
  local b = pill(S, nil, TBW); b:SetPoint("TOPLEFT", 18 + (i - 1) * (TBW + 8), -48); label(b.text, key)
  b:SetScript("OnClick", function() showTab(i) end)
  tabBtns[i] = b
  local pg = CreateFrame("Frame", nil, S); pg:SetAllPoints(S); pg:Hide()
  pages[i] = pg
end
local pctFmt = function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end
local clockFmt = function(v) return hhmm(v) end

-- fane 1: vinduet
host = pages[1]
colX = 0
section(-92, "winSec")
toggle(-114, "showWin", function() return not DB.hidden end, function(v) DB.hidden = not v end)
toggle(-142, "lock", function() return DB.locked end, function(v) DB.locked = v end)
toggle(-170, "showMinimap", function() return DB.showMinimap end, function(v) DB.showMinimap = v end)
slider(-202, "size", 0.6, 2.0, 0.05, function() return f._scale or DB.scale end, function(v) DB.scale = v; DB.scaleFollow = false end, pctFmt)
colX = COL
section(-92, "detailSec")
toggle(-114, "showDetails", function() return DB.showDetails end, function(v) DB.showDetails = v end)
toggle(-142, "fuse", function() return DB.fuse end, function(v) DB.fuse = v end)
toggle(-170, "countBags", function() return DB.countBags end, function(v) DB.countBags = v end)

-- fane 2: maal
host = pages[2]
colX = 0
section(-92, "goalSec")
slider(-116, "goalAmount", 5, 2000, 5, function() return math.floor(DB.goal / 10000) end,
  function(v)
    DB.goal = v * 10000
    if DB.goalName == "pEpic" then DB.epicGoal = DB.goal else DB.mountGoal = DB.goal end
  end, function(v) return v .. GI end)
slider(-162, "goalLevel", 10, 60, 1, function() return DB.goalLevel end, function(v) DB.goalLevel = v end,
  function(v) return tostring(v) end)
colX = COL
section(-92, "presets")
local function preset(y, key)
  local b = pill(host, nil, COL - 36); b:SetPoint("TOPLEFT", colX + 18, y)
  label(b.text, key)
  b:SetScript("OnClick", function()
    DB.goalAuto = false  -- du har selv valgt: skift ikke automatisk
    setGoal(key)
    for _, c in ipairs(controls) do c.load() end
    refresh()
  end)
end
preset(-114, "pMount")
preset(-146, "pEpic")
toggle(-184, "autoGoal", function() return DB.goalAuto end, function(v) DB.goalAuto = v; if v then autoGoal() end end)

-- fane 3: spilletid
host = pages[3]
colX = 0
section(-92, "rhythm")
toggle(-114, "useRhythm", function() return DB.schedule end, function(v) DB.schedule = v end)
slider(-146, "wake", 0, 1410, 30, function() return DB.sleepEnd end, function(v) DB.sleepEnd = v end, clockFmt)
slider(-192, "bed", 0, 1410, 30, function() return DB.sleepStart end, function(v) DB.sleepStart = v end, clockFmt)
colX = COL
local rInfo = fs(host, F_SEMI, 11); rInfo:SetPoint("TOPLEFT", colX + 18, -116); rInfo:SetTextColor(0.55, 0.58, 0.64)
rInfo:SetWidth(SW - COL - 36); rInfo:SetJustifyH("LEFT"); rInfo:SetJustifyV("TOP"); if rInfo.SetWordWrap then rInfo:SetWordWrap(true) end  -- bryd linjen, saa den ikke loeber ud over kanten
label(rInfo, "rhythmInfo")
host = S

-- info: LevelETA og Auctionator
local infoText = fs(S, F_SEMI, 11); infoText:SetPoint("TOPLEFT", 18, -300); infoText:SetTextColor(0.55, 0.58, 0.64)
label(infoText, "standalone")
local leDot = S:CreateTexture(nil, "ARTWORK"); leDot:SetSize(7, 7); leDot:SetPoint("TOPLEFT", 19, -320); leDot:SetTexture(TEX .. "Dot")
local leText = fs(S, F_SEMI, 11); leText:SetPoint("TOPLEFT", 32, -318)
local aucDot = S:CreateTexture(nil, "ARTWORK"); aucDot:SetSize(7, 7); aucDot:SetPoint("TOPLEFT", 19, -338); aucDot:SetTexture(TEX .. "Dot")
local aucText = fs(S, F_SEMI, 11); aucText:SetPoint("TOPLEFT", 32, -336)

local langBtn = pill(S, nil, 140); langBtn:SetPoint("BOTTOMLEFT", 18, 16); label(langBtn.text, "language")
langBtn:SetScript("OnClick", function()
  DB.lang = (DB.lang == "da") and "en" or "da"
  updateLabels(); refresh()
  S:GetScript("OnShow")(S)
end)
local resetBtn = pill(S, nil, 130); resetBtn:SetPoint("LEFT", langBtn, "RIGHT", 10, 0); label(resetBtn.text, "reset")
resetBtn:SetScript("OnClick", function() DB.sess = newSession(); refresh() end)
local doneBtn = pill(S, nil, 100); doneBtn:SetPoint("BOTTOMRIGHT", -18, 16); label(doneBtn.text, "close")
doneBtn:SetScript("OnClick", function() S:Hide() end)

local function status(dot, text, ok, yes, no)
  if ok then
    dot:SetVertexColor(0.36, 1, 0.48); text:SetText(T(yes)); text:SetTextColor(0.85, 0.87, 0.92)
  else
    dot:SetVertexColor(0.54, 0.56, 0.6); text:SetText(T(no)); text:SetTextColor(0.55, 0.58, 0.64)
  end
end
S:SetScript("OnShow", function()
  updateLabels()
  status(leDot, leText, LE() ~= nil, "leFound", "leMissing")
  status(aucDot, aucText, aucLoaded() and true or false, auxOK() and "auxFound" or "aucFound", "aucMissing")
  for _, c in ipairs(controls) do c.load() end
  showTab(DB.tab or 1)
end)

toggleSettings = function() S:SetShown(not S:IsShown()) end
toggleWindow = function()
  DB.hidden = f:IsShown()
  if DB.hidden then f:Hide() else refresh() end
  if S:IsShown() then for _, c in ipairs(controls) do c.load() end end
end
end

-- ---------- minimap-knap ----------
local mmb = CreateFrame("Button", "GoldETAMinimapButton", Minimap)
mmb:SetSize(31, 31); mmb:SetFrameStrata("MEDIUM"); mmb:SetFrameLevel(8)
mmb:RegisterForClicks("LeftButtonUp", "RightButtonUp"); mmb:RegisterForDrag("LeftButton")
mmb:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
local mmBg = mmb:CreateTexture(nil, "BACKGROUND")
mmBg:SetSize(20, 20); mmBg:SetPoint("TOPLEFT", 7, -5); mmBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
local mmIcon = mmb:CreateTexture(nil, "ARTWORK")
mmIcon:SetSize(21, 21); mmIcon:SetPoint("TOPLEFT", 5, -5); mmIcon:SetTexture(LOGO)
local mmBorder = mmb:CreateTexture(nil, "OVERLAY")
mmBorder:SetSize(53, 53); mmBorder:SetPoint("TOPLEFT"); mmBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
local function placeButton()
  local a = math.rad(DB.mmAngle)
  local rad = (Minimap:GetWidth() / 2) + 5
  mmb:ClearAllPoints()
  mmb:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * rad, math.sin(a) * rad)
end
mmb:SetScript("OnDragStart", function(self)
  self:SetScript("OnUpdate", function()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local sc = Minimap:GetEffectiveScale()
    DB.mmAngle = math.deg(atan2(py / sc - my, px / sc - mx))
    placeButton()
  end)
end)
mmb:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
mmb:SetScript("OnClick", function(_, btn)
  if IsShiftKeyDown and IsShiftKeyDown() then toggleRun()
  elseif btn == "RightButton" then toggleSettings()
  else toggleWindow() end
end)
mmb:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine(NAME, 1, 0.82, 0.3)
  local gi = goalInfo()
  GameTooltip:AddDoubleLine(T("gph"), gi.r and money(gi.r * 3600) or T("measuring"), 0.85, 0.85, 0.85, 0.62, 0.82, 1)
  GameTooltip:AddDoubleLine(string.format(T("ready"), goalLabel()),
    gi.done and T("readyNow") or (gi.at and nice(gi.at, 15)) or T("measuring"), 0.85, 0.85, 0.85, 1, 0.82, 0)
  -- alle karakterer paa kontoen
  local list, sum = {}, 0
  for _, c in pairs(ADB.chars) do list[#list + 1] = c; sum = sum + (c.m or 0) end
  if #list > 1 then
    table.sort(list, function(a, b) return (a.m or 0) > (b.m or 0) end)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(T("chars"), 1, 0.82, 0.4)
    for i = 1, math.min(10, #list) do
      local c = list[i]
      local cc = RAID_CLASS_COLORS and c.class and RAID_CLASS_COLORS[c.class]
      GameTooltip:AddDoubleLine(c.name, money(c.m), cc and cc.r or 0.85, cc and cc.g or 0.85, cc and cc.b or 0.85, 1, 1, 1)
    end
    GameTooltip:AddDoubleLine(T("allChars"), money(sum), 1, 0.82, 0.4, 1, 1, 1)
  end
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(T("tipLeft"), 0.6, 0.6, 0.6)
  GameTooltip:AddLine(T("tipRight"), 0.6, 0.6, 0.6)
  GameTooltip:AddLine(T("tipShift"), 0.6, 0.6, 0.6)
  GameTooltip:Show()
end)
mmb:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ---------- hvor kommer pengene fra? ----------
local ctx = {}         -- hvilke vinduer er aabne (merchant, mail, AH, taxa, traener, handel)
local until_ = {}      -- korte tidsvinduer efter en haendelse: loot, quest, reparation, flyvning, handel
local lastMoney
local function within(k) return until_[k] and clock() <= until_[k] end

local function category(delta)
  if delta > 0 then
    if ctx.merchant then return "vendor" end
    if ctx.mail then return "mail" end
    if ctx.quest then return "quest" end
    if within("loot") then return "loot" end
    if within("quest") then return "quest" end
    if within("merchant") then return "vendor" end
    if ctx.trade or within("trade") then return "trade" end
    return "otherIn"
  end
  if ctx.merchant or within("merchant") then
    if within("repair") then return "repair" end
    return "buy"
  end
  if ctx.taxi or within("taxi") then return "flight" end
  if ctx.trainer then return "training" end
  if ctx.ah then return "ahSpend" end
  if ctx.trade or within("trade") then return "trade" end
  return "otherOut"
end

local function zoneKey() return (GetZoneText and GetZoneText()) or "?" end
local function zone()
  local k = zoneKey()
  if k == "" then k = "?" end
  local z = DB.zones[k]
  if not z then z = {t = 0, v = 0, a = 0}; DB.zones[k] = z end
  return z
end

local function onMoney()
  local m = GetMoney()
  if not lastMoney then lastMoney = m; return end
  local delta = m - lastMoney
  lastMoney = m
  if delta == 0 then return end
  local cat = category(delta)
  if delta > 0 then
    DB.sess.inc[cat] = (DB.sess.inc[cat] or 0) + delta
    addPace(delta)
  else
    DB.sess.exp[cat] = (DB.sess.exp[cat] or 0) - delta
    if PACE_MINUS[cat] then addPace(delta) end
  end
  if cat == "loot" then
    local z = zone(); z.v = z.v + delta; z.a = z.a + delta
    if DB.run and not DB.run.paused then DB.run.coin = DB.run.coin + delta end
  end
  local key = (GetRealmName and GetRealmName() or "") .. "-" .. (UnitName("player") or "")
  local c = ADB.chars[key]
  if c then c.m = m end
end

-- "You receive loot: [Silk Cloth]x3." bygget af spillets egne tekster, saa det virker paa alle sprog
local lootPats
local function makePat(g)
  if type(g) ~= "string" then return nil end
  local p = g:gsub("%%s", "\1"):gsub("%%d", "\2")
  p = p:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  p = p:gsub("\1", "(.+)"):gsub("\2", "(%%d+)")
  return "^" .. p .. "$"
end
local function onLootMsg(msg)
  if type(msg) ~= "string" then return end
  if issecretvalue then
    local ok, secret = pcall(issecretvalue, msg)
    if not ok or secret then return end
  end
  if not lootPats then
    lootPats = {}
    local m = makePat(_G.LOOT_ITEM_SELF_MULTIPLE)
    if m then lootPats[#lootPats + 1] = {m, true} end
    local s = makePat(_G.LOOT_ITEM_SELF)
    if s then lootPats[#lootPats + 1] = {s, false} end
  end
  local link, n
  for _, p in ipairs(lootPats) do
    local a, b = msg:match(p[1])
    if a then link, n = a, p[2] and tonumber(b) or 1; break end
  end
  if not link then return end
  local id = tonumber(link:match("item:(%d+)"))
  if not id then return end
  local v = sellPrice(id) * n
  local a = math.max(v, (ahPrice(id) or 0) * n)
  local z = zone(); z.v = z.v + v; z.a = z.a + a
  local r = DB.run
  if r and not r.paused then
    r.vend, r.ah = r.vend + v, r.ah + a
    local it = r.items[id] or {n = 0, v = 0, a = 0}
    it.n, it.v, it.a = it.n + n, it.v + v, it.a + a
    r.items[id] = it
  end
end

-- kills: "<mob> dies, you gain N experience." (samme metode som LevelETA)
local killPat
local function onXPMsg(msg)
  local r = DB.run
  if not r or r.paused or type(msg) ~= "string" then return end
  if issecretvalue then
    local ok, secret = pcall(issecretvalue, msg)
    if not ok or secret then return end
  end
  if killPat == nil then
    killPat = false
    local g = _G.COMBATLOG_XPGAIN_FIRSTPERSON
    if type(g) == "string" and g:find("%%s") then
      local p = g:gsub("%%s", "\1"):gsub("%%d", "\2")
      p = p:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
      p = p:gsub("\1", "(.-)"):gsub("\2", "%%d+")
      killPat = "^" .. p
    end
  end
  if not killPat then return end
  local ok, mob = pcall(string.match, msg, killPat)
  if ok and mob and mob ~= "" then
    r.kills = r.kills + 1
    r.mobs[mob] = (r.mobs[mob] or 0) + 1
  end
end

if hooksecurefunc then
  pcall(hooksecurefunc, "RepairAllItems", function() until_.repair = clock() + 3 end)
end

-- ---------- events ----------
local bagPending = false
local function bagsSoon()
  if bagPending then return end
  bagPending = true
  local function run() bagPending = false; scanBags(); if f:IsShown() then refresh() end end
  if C_Timer and C_Timer.After then C_Timer.After(1, run) else run() end
end

local E = CreateFrame("Frame")
for _, ev in ipairs({"ADDON_LOADED", "PLAYER_ENTERING_WORLD", "PLAYER_LOGOUT", "PLAYER_MONEY", "CHAT_MSG_MONEY", "CHAT_MSG_LOOT",
  "CHAT_MSG_COMBAT_XP_GAIN", "LOOT_OPENED", "LOOT_CLOSED", "QUEST_TURNED_IN", "MERCHANT_SHOW", "MERCHANT_CLOSED",
  "MAIL_SHOW", "MAIL_CLOSED", "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED", "TAXIMAP_OPENED", "TAXIMAP_CLOSED",
  "TRAINER_SHOW", "TRAINER_CLOSED", "QUEST_COMPLETE", "QUEST_FINISHED", "TRADE_SHOW", "TRADE_CLOSED", "BAG_UPDATE_DELAYED", "ZONE_CHANGED_NEW_AREA",
  "PLAYER_LEVEL_UP", "SKILL_LINES_CHANGED", "NEW_MOUNT_ADDED", "COMPANION_LEARNED"}) do
  pcall(E.RegisterEvent, E, ev)
end

E:SetScript("OnEvent", function(_, event, a1, a2)
  if event == "ADDON_LOADED" then
    if a1 == ADDON then
      GoldETADB = GoldETADB or {}
      DB = GoldETADB
      for k, v in pairs(defaults) do if DB[k] == nil then DB[k] = v end end
      if not DB.farms then  -- foerste gang: byg farm-loggen ud fra de runs der allerede er gemt
        DB.farms = {}
        for _, r in ipairs(DB.runs or {}) do addFarm(r.name, r.zone, r.t or 0, r.v or 0, r.at) end
      end
      GoldETAAccountDB = GoldETAAccountDB or {}
      ADB = GoldETAAccountDB
      ADB.chars = ADB.chars or {}
      updateLabels()
      f:ClearAllPoints()
      if DB.point then f:SetPoint(DB.point[1], UIParent, DB.point[2], DB.point[3], DB.point[4])
      else f:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -360) end
      placeButton()
    end
    return
  end
  if not DB then return end
  if event == "PLAYER_ENTERING_WORLD" then
    lastMoney = GetMoney()
    local key = (GetRealmName and GetRealmName() or "") .. "-" .. (UnitName("player") or "")
    local _, class = UnitClass("player")
    ADB.chars[key] = {name = UnitName("player"), class = class, m = lastMoney}
    if a1 or not DB.sess then  -- nyt login: ny session, og en kort opsummering af den forrige
      local old = DB.sess
      if old and (DB.play - (old.p0 or DB.play)) >= 600 then
        local t = DB.play - old.p0
        local net = (old.mEnd or old.m0 or 0) - (old.m0 or 0)
        if C_Timer and C_Timer.After then
          C_Timer.After(6, function()
            toast.show(string.format(T("lastSess"), (net >= 0 and "+" or "") .. money(net)),
              string.format(T("lastSub"), dur(t), money(net / t * 3600), T("perHr")))
          end)
        end
      end
      DB.sess = newSession()
      if not DB.paceFrom then DB.paceFrom = DB.play end
    end
    importLE()
    -- er LevelETA med, starter GoldETA's eget vindue skjult (alt kan ses via minimap-knappen)
    if a1 and DB.fuse and LE() and DB.hiddenByFuse == nil then DB.hidden, DB.hiddenByFuse = true, true end
    scanBags()
    if C_Timer and C_Timer.After then
      C_Timer.After(2, function() refresh(); pinTop() end)
      C_Timer.After(4, autoGoal)
    else autoGoal() end
    refresh()
  elseif event == "PLAYER_LOGOUT" then
    if DB.sess then DB.sess.mEnd = GetMoney() end
  elseif event == "PLAYER_MONEY" then
    onMoney()
    if f:IsShown() then refresh() elseif updateFuse then updateFuse() end
  elseif event == "CHAT_MSG_MONEY" then until_.loot = clock() + 1.5
  elseif event == "CHAT_MSG_LOOT" then onLootMsg(a1)
  elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then onXPMsg(a1)
  elseif event == "LOOT_OPENED" then until_.loot = clock() + 600
  elseif event == "LOOT_CLOSED" then until_.loot = clock() + 1.5
  elseif event == "QUEST_TURNED_IN" then until_.quest = clock() + 2
  elseif event == "QUEST_COMPLETE" then ctx.quest = true
  elseif event == "QUEST_FINISHED" then ctx.quest = nil; until_.quest = clock() + 2
  elseif event == "MERCHANT_SHOW" then ctx.merchant = true
  elseif event == "MERCHANT_CLOSED" then ctx.merchant = nil; until_.merchant = clock() + 1
  elseif event == "MAIL_SHOW" then ctx.mail = true
  elseif event == "MAIL_CLOSED" then ctx.mail = nil
  elseif event == "AUCTION_HOUSE_SHOW" then ctx.ah = true
  elseif event == "AUCTION_HOUSE_CLOSED" then ctx.ah = nil
  elseif event == "TAXIMAP_OPENED" then ctx.taxi = true
  elseif event == "TAXIMAP_CLOSED" then ctx.taxi = nil; until_.taxi = clock() + 3
  elseif event == "TRAINER_SHOW" then ctx.trainer = true
  elseif event == "TRAINER_CLOSED" then ctx.trainer = nil
  elseif event == "TRADE_SHOW" then ctx.trade = true
  elseif event == "TRADE_CLOSED" then ctx.trade = nil; until_.trade = clock() + 3
  elseif event == "BAG_UPDATE_DELAYED" then bagsSoon()
  elseif event == "SKILL_LINES_CHANGED" or event == "NEW_MOUNT_ADDED" or event == "COMPANION_LEARNED" then autoGoal()
  elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LEVEL_UP" then
    if f:IsShown() then refresh() end
  end
end)

-- ---------- uret: et tik i sekundet, intet arbejde i hvert billede ----------
local acc = 0
local function farming()  -- taeller kun tid i en zone, naar du er ude og farme (ikke i byen, paa flyvetur, AFK eller doed)
  if IsResting and IsResting() then return false end
  if UnitOnTaxi and UnitOnTaxi("player") then return false end
  if UnitIsDeadOrGhost and UnitIsDeadOrGhost("player") then return false end
  if UnitIsAFK and UnitIsAFK("player") then return false end
  return true
end
local function tick(el)
  if not DB then return end
  DB.play = DB.play + el
  DB.life.p = DB.life.p + el
  if farming() then
    local z = zone(); z.t = z.t + el
  end
  local r = DB.run
  if r and not r.paused then r.t = r.t + el end
  acc = acc + el
  if f:IsShown() then
    if r or acc >= 5 then acc = 0; refresh() end
  elseif acc >= 15 then
    acc = 0
    if updateFuse then updateFuse() end
  end
end
if C_Timer and C_Timer.NewTicker and GetTime then
  local last = GetTime()
  C_Timer.NewTicker(1, function() local now = GetTime(); tick(now - last); last = now end)
else
  local a, clockFrame = 0, CreateFrame("Frame")
  clockFrame:SetScript("OnUpdate", function(_, el) a = a + el; if a >= 1 then tick(a); a = 0 end end)
end

-- ---------- kommandoer og keybind ----------
BINDING_HEADER_GOLDETA = "GoldETA"
BINDING_NAME_GOLDETA_FARM = "Start or stop farm run"

SLASH_GOLDETA1 = "/goldeta"
SLASH_GOLDETA2 = "/geta"
SlashCmdList.GOLDETA = function(msg)
  msg = (msg or ""):lower()
  if msg == "farm" then toggleRun()
  elseif msg == "show" or msg == "vis" then toggleWindow()
  elseif msg == "log" then
    local fl = farmList()
    print("|cffffd24a" .. T("logHead") .. "|r")
    if #fl == 0 then print(T("noRuns")) end
    for i, x in ipairs(fl) do
      print(string.format(T("logLine"), i, x.name, money(x.r * 3600), x.n, dur(x.t), money(x.best * 3600)))
    end
    if #fl > 0 then print("|cff8c94a3" .. T("logTip") .. "|r") end
  elseif msg == "summary" or msg == "opsummering" then
    local t, net = sessTime(), sessNet()
    toast.show(string.format(T("sessDone"), (net >= 0 and "+" or "") .. money(net)),
      string.format(T("lastSub"), dur(t), money(t > 0 and net / t * 3600 or 0), T("perHr")))
  else toggleSettings() end
end
