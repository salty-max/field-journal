-- Spanish is a complete book, including warnings and authored answer labels.
-- Load both regional clients and both player genders through the shipped files.
return function(DIR, FOREVER, check)
  local oldSex = UnitSex
  for _, locale in ipairs({ "esES", "esMX" }) do
    for _, sex in ipairs({ 2, 3 }) do
      UnitSex = function() return sex end
      local target = { on = function() end, secret = function() return false end }
      for _, file in ipairs({ "Kit.lua", FOREVER and "Data_Forever.lua" or "Data_Classic.lua", "Locale.lua" }) do
        assert(loadfile(DIR .. file))("Yonder", target)
      end
      local catalog
      local translate = target.translate
      target.translate = function(t)
        catalog = t
        translate(t)
      end
      assert(loadfile(DIR .. "Text_" .. locale .. ".lua"))("Yonder", target)
      assert(loadfile(DIR .. "Expeditions.lua"))("Yonder", target)
      local function finished(text, label)
        check(
          type(text) == "string"
            and #text > 0
            and not text:find("$g", 1, true)
            and not text:find(";", 1, true)
            and not text:find("{{", 1, true)
            and not text:find("[classic]", 1, true)
            and not text:find("[forever]", 1, true),
          locale .. " finished Spanish text: " .. label
        )
      end
      local data, families, zones, riddles, quarries = target.data, 0, 0, 0, 0
      for _, section in ipairs(data.sections) do
        check(catalog.sections[section.id] ~= nil, locale .. " translated section " .. section.id)
      end
      for _, family in ipairs(data.families) do
        families = families + 1
        check(catalog.families[family.id] ~= nil, locale .. " translated family " .. family.id)
        finished(family.title, family.id)
        for _, paragraph in ipairs(family.note) do
          finished(paragraph, family.id)
        end
      end
      for id, zone in pairs(data.atlas.zones) do
        if zone.note and #zone.note > 0 then
          zones = zones + 1
          check(catalog.atlas[id] ~= nil, locale .. " translated atlas " .. id)
          for _, paragraph in ipairs(zone.note) do
            finished(paragraph, "atlas " .. id)
          end
        end
      end
      for kind, entries in pairs({ fish = data.flora.fish, herbs = data.flora.herbs }) do
        for id, entry in pairs(entries) do
          check(catalog[kind][id] ~= nil, locale .. " translated " .. kind .. " " .. id)
          for _, paragraph in ipairs(entry.note) do
            finished(paragraph, kind .. " " .. id)
          end
        end
      end
      for zone, expedition in pairs(data.expeditions) do
        local translated = catalog.expeditions[zone]
        for _, riddle in ipairs(expedition.riddles) do
          riddles = riddles + 1
          local text = translated and translated.riddles[riddle.id]
          check(
            text and #text.verse > 0 and text.hint and text.note and text.margin and text.danger,
            locale .. " complete riddle, including its warning: " .. riddle.id
          )
          for _, line in ipairs(riddle.verse) do
            finished(line, riddle.id)
          end
          finished(riddle.hint, riddle.id .. " hint")
          finished(riddle.danger, riddle.id .. " danger")
          finished(target.riddleName(riddle), riddle.id .. " name")
          finished(target.riddleNote(riddle), riddle.id .. " note")
          finished(target.riddleMargin(riddle), riddle.id .. " margin")
          if riddle.id == "ungoro-crater-simone" then
            check(
              target.riddleNote(riddle):find(sex == 3 and "amiga" or "amigo", 1, true) ~= nil,
              locale .. " spoken greeting agrees with the player's gender"
            )
          end
          if riddle.id == "dun-morogh-range" then
            check(target.riddleName(riddle) == "El campo de tiro de Estruendo", locale .. " custom answer translated")
          end
        end
        if expedition.quarry then
          quarries = quarries + 1
          local quarry, text = expedition.quarry, translated and translated.quarry
          check(text and #text.verse > 0 and text.note and text.margin, locale .. " complete quarry " .. zone)
          for _, line in ipairs(quarry.verse) do
            finished(line, "quarry " .. zone)
          end
          finished(target.quarryNote(quarry), "quarry note " .. zone)
          finished(target.quarryMargin(quarry), "quarry margin " .. zone)
        end
      end
      check(families == 96 and zones == (FOREVER and 47 or 46), locale .. " full Bestiary and Atlas coverage")
      check(
        riddles == (FOREVER and 119 or 115) and quarries == (FOREVER and 39 or 38),
        locale .. " full expedition coverage"
      )
      check(target.kit.L["Achievements"] == "Logros", locale .. " Spanish interface loaded")
      check(
        target.kit.L["%d more fish to find here."]:format(2) == "2 peces más por encontrar aquí.",
        locale .. " plural fish counter"
      )
      check(target.kit.isOne(1) and not target.kit.isOne(0), locale .. " Spanish singular rule")
      check(
        table
          .concat(data.atlas.zones[1455].note, " ")
          :find(locale == "esMX" and "Sala de los Expedicionarios" or "Sala de los Exploradores", 1, true)
          ~= nil,
        locale .. " regional place name reaches the prose"
      )
      check(
        data.expeditions[1444].riddles[1].hint:find(locale == "esMX" and "La Marra" or "La Masacre", 1, true) ~= nil,
        locale .. " the fighting pit stays distinct from Dire Maul"
      )
      check(target.catchNames[6309] == "Siluro", locale .. " own regional catch names retained")
    end
  end
  UnitSex = oldSex
end
