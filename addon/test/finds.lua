-- Replay the upgrade, gathering and navigation through real events and the
-- kit's actual selector. Called in both game simulations before translations.
return function(g)
  local ns, state, fire, loot, check = g.ns, g.state, g.fire, g.loot, g.check
  local c, M = ns.journal(), ns.data.materials
  local fields = { "fish", "plants", "materials", "finds", "achievements" }
  local saved = {}
  for _, key in ipairs(fields) do
    saved[key], c[key] = c[key], nil
  end
  local oldProfs, oldBags, oldTarget, oldMouse, oldMap, oldSub =
    state.professions, state.bags, state.target, state.mouseover, state.map, state.sub
  state.professions, state.bags, state.target, state.mouseover, state.map, state.sub =
    {}, {}, nil, nil, 1429, "Crystal Lake"
  local oldBagCounts = state.bagCounts
  state.bagCounts = nil
  local oldLocale, oldTime = GetLocale, time
  local offset = 0
  time = function() return oldTime() + offset end
  local function link(id) return ("|cffffffff|Hitem:%d::::::::|h[Material]|h|r"):format(id) end
  local function from(id, source, count) loot({ { link(id), { source, count or 1 }, count or 1 } }) end
  local function cloth() return ns.findRecord(2589) end
  local function announcements(family)
    local count = 0
    for _, banner in ipairs(g.toasted) do
      if banner.kind == "finds" and banner.id == family then count = count + 1 end
    end
    return count
  end
  local function row(text)
    for _, r in ipairs(ns.floraRows) do
      if r.shown and r.text.text == text then return r end
    end
  end
  local function option(value)
    for i, opt in ipairs(YonderFrame.filter.options) do
      if opt.value == value then return i, opt end
    end
  end
  local function selectCategory(value)
    local filter = YonderFrame.filter
    local index = assert(option(value), "missing selector choice " .. value)
    filter.scripts.OnClick(filter)
    filter.rows[index].scripts.OnClick(filter.rows[index])
  end
  local beforeCloth = announcements("cloth")
  fire("SKILL_LINES_CHANGED")
  check(
    ns.findsUnlocked("cloth")
      and not ns.findsUnlocked("fish")
      and not ns.findsUnlocked("plants")
      and not ns.findsUnlocked("mining")
      and not ns.findsUnlocked("leather"),
    "Finds: a new character starts with cloth alone"
  )
  check(announcements("cloth") == beforeCloth + 1, "Finds: the universal collection is announced for each character")
  ns.openFindCategory("all")
  check(
    YonderFrame.selectedTab == ns.TAB.finds and ns.TAB.fish == nil and ns.TAB.plants == nil and YonderFrameTab6 == nil,
    "Finds: one top-level tab replaces Fish and Plants"
  )
  check(
    YonderFrame.filter.shown
      and #YonderFrame.filter.options == 2
      and option("textiles")
      and not option("fish")
      and not option("mining"),
    "Finds: the kit selector lists only available categories"
  )
  check(
    not ns.milestoneVisible(ns.milestoneById["finds-mining-first"])
      and not ns.milestoneVisible(ns.milestoneById["fish-first"]),
    "Finds: locked professions contribute no achievement progress"
  )
  from(2770, "GameObject-0-1-0-0-1731-0000000001", 2)
  from(2318, g.creature(1131))
  from(2447, "GameObject-0-1-0-0-1618-0000000001")
  check(
    not ns.findRecord(2770) and not ns.findRecord(2318) and not ns.findRecord(2447),
    "Finds: materials do not bypass a locked profession family"
  )
  -- Reproduce linen already carried when Finds first notices it. Its
  -- acquisition history is unknown, but its actual bag quantity is known.
  state.bags, state.bagCounts = { [1] = 2589, [2] = 2589 }, { [1] = 20, [2] = 7 }
  fire("BAG_UPDATE_DELAYED")
  check(
    cloth() and cloth().n == 0 and cloth().looted == 0 and cloth().first.how == "other",
    "Finds: carried cloth opens its page without inventing a loot history"
  )
  selectCategory("textiles")
  check(
    row("Linen Cloth") and not row("Light Leather") and YonderFloraPage.title.text == "Cloth & Leather",
    "Finds: cloth pages stay visible while leather is locked"
  )
  row("Linen Cloth").scripts.OnClick(row("Linen Cloth"))
  local function figure(label)
    for _, tile in ipairs(YonderFloraPage.tiles) do
      if tile.shown and tile.label.text == label then return tile.value.text end
    end
  end
  check(
    figure("in bags") == "27" and figure("taken") == "0" and figure("looted") == "0",
    "Finds: the linen page shows the whole carried stack total separately from recorded acquisitions"
  )
  check(
    YonderFloraPage.note.text == table.concat(M.items[2589].note, "\n\n"),
    "Finds: a material page uses its approved naturalist's note"
  )
  fire("BAG_UPDATE_DELAYED")
  check(figure("in bags") == "27" and cloth().n == 0, "Finds: rescanning carried cloth does not count it as new loot")
  state.bags, state.bagCounts = { [1] = 2589 }, { [1] = 4 }
  fire("BAG_UPDATE_DELAYED")
  check(figure("in bags") == "4", "Finds: using or selling cloth refreshes its open page")
  state.bags, state.bagCounts = {}, nil
  fire("BAG_UPDATE_DELAYED")
  check(figure("in bags") == "0" and cloth() ~= nil, "Finds: an empty bag count preserves the discovered page")
  from(2589, g.creature(1131), 3)
  check(
    cloth().n == 3 and cloth().looted == 3 and figure("looted") == "3",
    "Finds: later looted cloth counts once, independently of inventory snapshots"
  )
  check(ns.earnedMilestone("finds-cloth-first") ~= nil, "Finds: the first cloth earns its material milestone")

  -- A bought ore opens a page once Mining is learned, but its quantity is
  -- unknown and it must not be credited as mined. Forever's child id works.
  state.bags = { [1] = 2770 }
  state.professions = { [1] = { "Mining", ns.forever and 2946 or 186 } }
  local miningBefore = announcements("mining")
  fire("SKILL_LINES_CHANGED")
  check(
    ns.findsUnlocked("mining") and ns.findRecord(2770).n == 0 and ns.findRecord(2770).first.how == "other",
    "Finds: learning Mining opens carried ore without inventing a mined count"
  )
  check(
    announcements("mining") == miningBefore + 1 and ns.milestoneVisible(ns.milestoneById["finds-mining-first"]),
    "Finds: learning a profession announces its collection and reveals its milestones"
  )
  fire("SKILL_LINES_CHANGED")
  fire("SPELLS_CHANGED")
  fire("PLAYER_ENTERING_WORLD")
  check(
    announcements("mining") == miningBefore + 1,
    "Finds: login, skill ranks and spell changes do not repeat unlock announcements"
  )
  check(
    ns.earnedMilestone("finds-mining-first").retro == true,
    "Finds: an item already carried before the collection opened earns its first milestone quietly"
  )
  local notification
  for _, b in ipairs(g.toasted) do
    if b.kind == "finds" and b.id == "mining" then notification = b end
  end
  assert(notification)
  notification.click()
  check(
    YonderFrame.selectedTab == ns.TAB.finds and YonderFrame.filter:GetValue() == "mining",
    "Finds: the unlock banner opens its own category"
  )
  ns.openFindCategory("all")
  selectCategory("mining")
  check(
    YonderFrame.filter.text.text == "Ores & Gems"
      and row("Copper Ore")
      and not row("Copper Vein")
      and not row("Tigerseye"),
    "Finds: the real selector shows discovered items, never nodes or undiscovered names"
  )
  from(2770, "GameObject-0-1-0-0-1731-0000000001", 2)
  from(818, "GameObject-0-1-0-0-1731-0000000002")
  from(2770, g.creature(1131))
  check(
    ns.findRecord(2770).n == 3
      and ns.findRecord(2770).gathered == 2
      and ns.findRecord(2770).looted == 1
      and ns.findRecord(818).gathered == 1,
    "Finds: ore and gems share item records and retain mining versus ordinary loot"
  )
  g.follow("yonder:i2770")
  check(
    YonderFloraPage.title.text == "Copper Ore" and YonderFloraPage.note.text == table.concat(M.items[2770].note, "\n\n"),
    "Finds: a material chat link opens its full page"
  )
  g.follow("yonder:i774")
  check(YonderFloraPage.title.text == "Ores & Gems", "Finds: an undiscovered item link cannot reveal its page")
  g.follow("yonder:finds/mining")
  check(YonderFrame.filter:GetValue() == "mining", "Finds: the category chat link opens the right selector choice")
  state.professions, state.bags = {}, {}
  fire("SKILL_LINES_CHANGED")
  from(2771, g.creature(1131), 2)
  check(
    ns.findsUnlocked("mining") and ns.findRecord(2771).n == 2,
    "Finds: dropping Mining preserves its collection and keeps recording new ore"
  )
  ns.openFind(2770)
  check(YonderFloraPage.title.text == "Copper Ore", "Finds: old ore pages remain readable after dropping Mining")
  state.professions = { [1] = { "Mining", 186 } }
  fire("SKILL_LINES_CHANGED")
  check(announcements("mining") == miningBefore + 1, "Finds: relearning a profession does not replay its unlock")

  -- Sparse modern profession slots: no primary trade, only Fishing.
  state.professions = { [4] = { "Fishing", ns.forever and 2943 or 356 } }
  fire("SKILL_LINES_CHANGED")
  check(ns.findsUnlocked("fish"), "Finds: Fishing unlocks without either primary profession")
  g.fishing(true)
  from(6291, "GameObject-0-1-0-0-35591-0000000001")
  g.fishing(false)
  check(ns.fishRecord(6291).n == 1, "Finds: catches still use the original fish record")
  g.follow("yonder:f6291")
  check(
    YonderFrame.filter:GetValue() == "fish" and YonderFloraPage.title.text == "Raw Brilliant Smallfish",
    "Finds: old fish links select Fish within Finds"
  )

  -- Migration keeps references, quantities and first-discovery stamps.
  local oldFish = { first = { at = time(), level = 10 }, n = 7, day = 3, night = 4, school = 2, zones = {} }
  local oldPlant =
    { first = { at = time(), level = 10, how = "gathered" }, n = 9, gathered = 8, looted = 1, zones = {} }
  c.finds, c.fish, c.plants = nil, { [6291] = oldFish }, { [2447] = oldPlant }
  state.professions, state.bags = {}, {}
  fire("SKILL_LINES_CHANGED")
  check(
    ns.findsUnlocked("fish") and ns.findsUnlocked("plants") and c.fish[6291] == oldFish and c.plants[2447] == oldPlant,
    "Finds: upgrade migration preserves old catches and herbs without a current profession"
  )
  from(785, g.creature(1131), 2)
  check(
    ns.plantRecord(785).n == 2 and oldPlant.n == 9 and oldFish.school == 2,
    "Finds: migrated families keep recording after unlearning, without rewriting old counts"
  )
  g.follow("yonder:h2447")
  check(
    YonderFrame.filter:GetValue() == "plants" and YonderFloraPage.title.text == "Peacebloom",
    "Finds: old herb links select Plants within Finds"
  )

  -- A leather drop is not proof of Skinning. Only the successful spell
  -- paired with that same corpse credits the skinning column.
  state.professions = { [2] = { "Skinning", ns.forever and 2947 or 393 } }
  fire("SKILL_LINES_CHANGED")
  from(2318, g.creature(1131))
  check(
    ns.findRecord(2318).looted == 1 and ns.findRecord(2318).skinned == 0,
    "Finds: ordinary leather loot is not falsely marked skinned"
  )
  state.target, state.mouseover = 1131, nil
  fire("UNIT_SPELLCAST_SENT", "player", "Winter Wolf", "skin-1", 8613)
  state.target = nil -- the cast's corpse can leave the target before success
  fire("UNIT_SPELLCAST_SUCCEEDED", "player", "skin-1", 8613)
  from(2318, g.creature(1131), 2)
  check(
    ns.findRecord(2318).skinned == 2 and ns.findRecord(2318).n == 3,
    "Finds: successful Skinning credits the matching corpse even if the target is cleared"
  )
  state.target = 1131
  fire("UNIT_SPELLCAST_SUCCEEDED", "player", "skin-2", 8613)
  from(2318, g.creature(1133))
  check(
    ns.findRecord(2318).skinned == 2 and ns.findRecord(2318).looted == 2,
    "Finds: another corpse cannot inherit a skinning spell"
  )
  fire("UNIT_SPELLCAST_SUCCEEDED", "player", "skin-3", 8613)
  offset = offset + 4
  from(2318, g.creature(1131))
  check(ns.findRecord(2318).skinned == 2, "Finds: a stale skinning spell cannot label a later loot window")
  fire("UNIT_SPELLCAST_SUCCEEDED", "player", "mine-1", 2575)
  from(2318, g.creature(1131))
  check(ns.findRecord(2318).skinned == 2, "Finds: Mining's spell never counts as Skinning")
  state.professions, state.bags = {}, { [1] = 2319 }
  fire("SKILL_LINES_CHANGED")
  check(
    ns.findRecord(2319) and ns.findRecord(2319).first.how == "other" and ns.findRecord(2319).skinned == 0,
    "Finds: received leather keeps its page after unlearning without inventing skinning"
  )
  ns.openFindCategory("textiles")
  check(
    row("Linen Cloth") and row("Light Leather") and row("Medium Leather"),
    "Finds: the shared cloth and leather group keeps both collections"
  )
  ns.openZone(1429)
  local copper
  for _, chip in ipairs(YonderAtlasPage.chipPool) do
    if chip.shown and chip.text.text == "Copper Ore" then copper = chip end
  end
  check(copper ~= nil, "Finds: a discovered material appears in its Atlas zones")
  copper.scripts.OnClick(copper)
  check(
    YonderFloraPage.title.text == "Copper Ore" and YonderFrame.selectedTab == ns.TAB.finds,
    "Finds: its Atlas link returns to the material page"
  )

  -- Localized skill names are a legacy fallback, not translated protocol ids.
  -- Completion totals use this client's item catalog, with no node entries.
  local miningTotal = #ns.findOrder("mining")
  for _, id in ipairs(ns.findOrder("mining")) do
    c.materials[id] = c.materials[id] or { first = { at = time(), level = 10 }, n = 0, zones = {} }
  end
  ns.checkMilestones()
  local done, need = ns.milestoneById["finds-mining-all"].progress()
  check(
    done == miningTotal and need == miningTotal and ns.earnedMilestone("finds-mining-all"),
    "Finds: material completion counts this game's item pages, never its nodes"
  )
  state.professions = {}
  fire("SKILL_LINES_CHANGED")
  check(
    ns.milestoneVisible(ns.milestoneById["finds-mining-all"]),
    "Finds: earned material achievements remain visible after unlearning"
  )

  for _, locale in ipairs({ "frFR", "deDE", "esES", "esMX" }) do
    GetLocale = function() return locale end
    check(
      ns.findName(14256) == M.itemNames[locale][14256],
      "Finds: a cold item cache retains " .. locale .. " material names"
    )
  end
  check(
    M.itemNames.esES[14256] ~= M.itemNames.esMX[14256],
    "Finds: the regional Spanish material fallback is not borrowed from Spain"
  )
  GetLocale = oldLocale

  local oldGet, oldInfo = GetProfessions, GetProfessionInfo
  local oldNum, oldLine, oldExpand, oldCollapse =
    GetNumSkillLines, GetSkillLineInfo, ExpandSkillHeader, CollapseSkillHeader
  GetProfessions, GetProfessionInfo = nil, nil
  GetLocale = function() return "frFR" end
  c.finds, c.fish, c.plants, c.materials, state.bags = nil, nil, nil, nil, {}
  local headers = {
    { name = "Métiers", kids = { "Minage", "Dépeçage" } },
    { name = "Compétences secondaires", kids = { "Pêche" } },
  }
  local function lines()
    local out = {}
    for _, header in ipairs(headers) do
      table.insert(out, { header = header })
      if header.open then
        for _, name in ipairs(header.kids) do
          table.insert(out, { name = name })
        end
      end
    end
    return out
  end
  GetNumSkillLines = function() return #lines() end
  GetSkillLineInfo = function(i)
    local line = lines()[i]
    if line.header then return line.header.name, true, line.header.open or false end
    return line.name, false, false, 1, 0, 0, 75
  end
  local headerChanges = 0
  ExpandSkillHeader = function(i)
    lines()[i].header.open = true
    headerChanges = headerChanges + 1
    fire("SKILL_LINES_CHANGED")
  end
  CollapseSkillHeader = function(i)
    lines()[i].header.open = false
    headerChanges = headerChanges + 1
    fire("SKILL_LINES_CHANGED")
  end
  fire("SKILL_LINES_CHANGED")
  check(
    ns.findsUnlocked("mining")
      and ns.findsUnlocked("leather")
      and ns.findsUnlocked("fish")
      and not ns.findsUnlocked("plants"),
    "Finds: the legacy scanner understands localized gathering professions"
  )
  check(
    not headers[1].open and not headers[2].open and headerChanges == 4,
    "Finds: folded skill headers are restored without recursively scanning"
  )
  GetProfessions, GetProfessionInfo, GetNumSkillLines, GetSkillLineInfo, ExpandSkillHeader, CollapseSkillHeader =
    oldGet, oldInfo, oldNum, oldLine, oldExpand, oldCollapse
  state.bagCounts = oldBagCounts
  GetLocale, time = oldLocale, oldTime
  for _, key in ipairs(fields) do
    c[key] = saved[key]
  end
  state.professions, state.bags, state.target, state.mouseover, state.map, state.sub =
    oldProfs, oldBags, oldTarget, oldMouse, oldMap, oldSub
  g.banners:clear()
  YonderFrame:Hide()
end
