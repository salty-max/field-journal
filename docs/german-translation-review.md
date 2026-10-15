# German translation review: Yonder

15 October 2026. Reviewed baseline `2ed72f5`. Review and corrections, applied locally. The riddles' answers are left out: they belong to the riddles' sources, not to a public document.

## Verdict

The German is complete and usable. It preserves the naturalist's dry voice, the surveyor's routes and most of the riddles. The weak spots were literal English constructions, a few changed meanings, and clues that lost an action cue. A wholesale rewrite would erase good work without helping the player.

This pass addresses **43 findings** (26 P2, 17 P3). All listed corrections are applied. Keep the first-translation label until a native German reader has reviewed it. Textual review and simulated sessions cannot certify native fluency or equal puzzle difficulty.

## Coverage

| Area | Reviewed |
| --- | ---: |
| Bestiary families, titles and complete notes | 96 |
| Atlas notes | 47 |
| Herb notes | 31 |
| Fish notes | 39 |
| Expedition zones | 47 |
| Riddle verses, hints, solved notes, margins and danger text | 110 |
| Quarry posters, notes and margins | 39 |
| Interface strings | 619 |
| Bestiary section labels | 9 |

Every authored English/German pair was read. This is 260 translated source units in the locale checker, with 110 riddles and 39 quarry sections inside the 47 expedition units. The JSON ledger records all source files and every riddle's wordplay assessment. No source stamps were refreshed to conceal stale translations.

Generated names were also rebuilt without changing their files: 3,504 Forever creature names, nine Classic overrides and 93 flora place labels. This validates the current generator against pinned data, rather than claiming a fresh manual translation of thousands of names. Atlas map/place names also come from the game at login. A generated map with no authored English note is outside the authored-note count, not an omitted German translation.

## The three runtime wording failures

The baseline's normal checks passed, but the actual German loader showed:

- Classic: `Der Der Zirkel des Cenarius` in the Moonglade note. A durable identity override in `classic-by-hand.json` now prevents the article-only substitution.
- Female characters: `Sei du diejenige, der verfolgt.` The relative pronoun is now inside the gender token, producing `diejenige, die` and `derjenige, der`.
- The Atlas: `1 Fische` when only one species remained. Both counter strings now use the count-neutral `Fehlende Fischarten: %d.` This also distinguishes species from the number of individual catches.

## Riddles and wordplay

Every riddle verse, hint and solved note was read against the deeds it accepts. Twelve clues were weighed closely: where the English cue rests on an English word or idiom, the German keeps an indirect cue that leads to the same deed without naming it. A gesture's cue never names the emote, a place's cue never names the place. Five were corrected (YD-022, YD-034, YD-035, YD-036, YD-028), the other seven kept as they were, their German already doing the same work as the English.

Two broad cues are deliberate textual judgments, not proof from German playtests, and deserve native players' feedback. Neither justified inventing a new game name or handing the player an explicit answer.

Which riddle each concerns, and its answer, is in the riddles' sources and the local review ledger, not here.

## Names, quotations and voice retained

Pinned Classic and Forever creature records support `Bluthörner` for the Sunscale raptors, `Feuerschuppen` for Flamewakers and `Holzplanke` for Timber. These look surprising beside English, but changing them would make the prose less faithful to the selected game.

Game quotations keep the stored German speech and readables, even where awkward, mixed German and French, or different from the English. Their awkwardness is not grounds to manufacture a better client quotation.

NPC profession titles keep the gender of the NPC they describe. A generic English profession can map to a glossary title collected from a different NPC, which is not enough to change it.

The exception is one notice whose German source in wow-data is bracketed English. That does not establish what a real German client contains. Its solved note now gives an unquoted German paraphrase, with no claim to reproduce a verified German inscription.

The good short lines stay short: `Ihre Eier sind begehrt. Ihre Mütter wissen das.` and `Schnee, Stein und Zwerge, in dieser Reihenfolge.` The corrections keep du, the formal forms inside authentic game quotations, narrator voices and all original unlock conditions.

## Applied findings

Each item records the incoming wording and the correction. Some are firm meaning/grammar fixes, others are P3 idiomatic polish. Every item is resolved in the companion JSON ledger.

### YD-001 - P2: runtime

[i18n/deDE/classic.json](../i18n/deDE/classic.json:5)

- Before: "Zirkel des Cenarius": "Der Zirkel des Cenarius"
- After: Identity override in classic-by-hand.json, regenerate swaps

Article-only replacement duplicates the existing article in the Moonglade Atlas note on Classic. Test actual loaded text.

### YD-002 - P3: idiom

[i18n/deDE/families/beasts/great-saurians.md](../i18n/deDE/families/beasts/great-saurians.md:8)

- Before: Der Krater gibt ihnen den Rest:
- After: Den Rest bietet ihnen der Krater:

Jemandem den Rest geben normally means finishing someone off, unlike supplying the remaining habitat.

### YD-003 - P3: idiom

[i18n/deDE/families/beasts/insects.md](../i18n/deDE/families/beasts/insects.md:6)

- Before: aus eigenem Recht
- After: auch unabhängig von den Silithiden

In their own right is not legal entitlement. Keep the independent inhabitants sense.

### YD-004 - P3: idiom

[i18n/deDE/families/beasts/wind-serpents.md](../i18n/deDE/families/beasts/wind-serpents.md:8)

- Before: Die wilden Geschöpfe bleiben aus eigenem Recht eindrucksvoll.
- After: Auch für sich genommen sind die wilden Geschöpfe eindrucksvoll.

The English idiom means intrinsically impressive, not possessing a legal right.

### YD-005 - P3: idiom

[i18n/deDE/families/beasts/owls.md](../i18n/deDE/families/beasts/owls.md:8)

- Before: Eine Eule ist eine vorzügliche Studie seines Fehlens.
- After: An einer Eule lässt sich diese Stille vorzüglich studieren.

Preserve the noise/absence joke without the literal study of its lack.

### YD-006 - P3: idiom

[i18n/deDE/families/beasts/wolves.md](../i18n/deDE/families/beasts/wolves.md:8)

- Before: auf ganz anderem Fuß
- After: unter ganz anderen Umständen

On a different footing is not idiomatic German on another foot.

### YD-007 - P2: reference

[i18n/deDE/families/dragonkin/green-dragonflight.md](../i18n/deDE/families/dragonkin/green-dragonflight.md:6)

- Before: doch der Nachtmahr hat einige seiner eigenen Wächter erreicht
- After: doch der Nachtmahr hat einige Wächter dieses Schwarms erreicht

Explicitly identify the afflicted guardians as the flight's. The masculine pronoun beside Nachtmahr suggests the Nightmare's own guardians.

### YD-008 - P3: idiom

[i18n/deDE/families/elementals/fire-elementals.md](../i18n/deDE/families/elementals/fire-elementals.md:8)

- Before: doch seine Gegenwart allein verrät einem Reisenden nicht, wessen Befehl es gehorcht, falls überhaupt jemandes.
- After: doch seine Gegenwart allein verrät einem Reisenden nicht, ob und unter wessen Befehl es steht.

Avoid the stranded genitive and keep uncertainty about a commander.

### YD-009 - P3: idiom

[i18n/deDE/families/elementals/water-elementals.md](../i18n/deDE/families/elementals/water-elementals.md:8)

- Before: doch es braucht etwas vom Ort und seiner Geschichte, um zu erklären, warum sie dort ist.
- After: doch um ihre Anwesenheit zu erklären, muss man etwas über den Ort und seine Geschichte wissen.

It takes some knowledge of is rendered as needing some of the place itself.

### YD-010 - P2: lexical

[i18n/deDE/families/peoples/kobolds.md](../i18n/deDE/families/peoples/kobolds.md:6)

- Before: einem kleinen Gräber
- After: einem kleinen Schürfer

Use an ordinary mining-worker noun instead of the misleading/archaic agent noun Gräber.

### YD-011 - P2: reference

[i18n/deDE/families/peoples/worgen.md](../i18n/deDE/families/peoples/worgen.md:10)

- Before: Beide Orte haben denselben schrecklichen Umriss zwischen den Bäumen angenommen:
- After: An beiden Orten erscheint dieselbe schreckliche Gestalt zwischen den Bäumen:

The creatures have the silhouette, not the two places themselves.

### YD-012 - P2: grammar

[i18n/deDE/atlas/darnassus.md](../i18n/deDE/atlas/darnassus.md:7)

- Before: muss sich hier einiges umgewöhnen
- After: muss sich hier erst umgewöhnen

Reflexive sich umgewöhnen does not take einiges as its direct object.

### YD-013 - P3: idiom

[i18n/deDE/atlas/alterac-mountains.md](../i18n/deDE/atlas/alterac-mountains.md:7)

- Before: Die Straße bringt einen Reisenden an die Außenseite ihrer Arbeit.
- After: Auf der Straße kommt ein Reisender nur bis vor die Kuppel.

The English outside of their work means outside the rebuilding behind the dome, not an outside surface of work.

### YD-014 - P3: idiom

[i18n/deDE/atlas/azshara.md](../i18n/deDE/atlas/azshara.md:5)

- Before: Die Straße kommt aus Ashenvale über einer Küste aus zerbrochenen Tempeln und rotgoldenen Bäumen herein.
- After: Die Straße aus Ashenvale führt oberhalb einer Küste mit zerbrochenen Tempeln und rotgoldenen Bäumen ins Land.

Clarify road/coast relation without the literal comes in over construction.

### YD-015 - P2: grammar

[i18n/deDE/atlas/the-barrens.md](../i18n/deDE/atlas/the-barrens.md:7)

- Before: Das offene Land macht ferne Orientierungspunkte leicht sichtbar und leicht unterschätzt.
- After: Im offenen Land sind ferne Orientierungspunkte leicht zu sehen, doch ihre Entfernung wird leicht unterschätzt.

Makes them easy to underestimate needs zu unterschätzen, not a past participle coordinated with sichtbar.

### YD-016 - P2: meaning

[i18n/deDE/words.json](../i18n/deDE/words.json:260)

- Before: Herd
- After: Heimatort

AtlasBook displays the current inn bind, not a cooking stove.

### YD-017 - P2: meaning

[i18n/deDE/words.json](../i18n/deDE/words.json:297)

- Before: Viele Herde
- After: Viele Heimatorte

The achievement counts five inn binds, not stoves.

### YD-018 - P3: grammar

[i18n/deDE/words.json](../i18n/deDE/words.json:233)

- Before: Erste
- After: Erstmals

Neutral timestamp label works for both fish and herbs without an unsupported feminine adjective.

### YD-019 - P3: idiom

[i18n/deDE/words.json](../i18n/deDE/words.json:602)

- Before: das vergisst alles, was dieser Charakter verzeichnet hat
- After: das löscht alles, was dieser Charakter verzeichnet hat

State the reset's actual action clearly.

### YD-020 - P2: runtime-plural

[i18n/deDE/words.json](../i18n/deDE/words.json:31)

- Before: Hier gibt es noch %d Fische zu finden.
- After: Fehlende Fischarten: %d.

AtlasBook calls the same English key for singular and plural. 1 Fische is ungrammatical, and the count is species, not individual catches.

### YD-021 - P2: runtime-plural

[i18n/deDE/words.json](../i18n/deDE/words.json:316)

- Before: Hier noch nichts gefunden: %d Fische zu finden.
- After: Hier noch nichts gefunden. Fehlende Fischarten: %d.

Use a count-neutral label for both number forms and accurately describe missing species.

### YD-022 - P2: wordplay-action

[i18n/deDE/expeditions/dun-morogh.md](../i18n/deDE/expeditions/dun-morogh.md:40)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-023 - P2: meaning

[i18n/deDE/expeditions/dun-morogh.md](../i18n/deDE/expeditions/dun-morogh.md:50)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-024 - P3: lexical

[i18n/deDE/expeditions/badlands.md](../i18n/deDE/expeditions/badlands.md:21)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-025 - P3: lexical

[i18n/deDE/fish.md](../i18n/deDE/fish.md:183)

- Before: ein weniger bekannter Preis
- After: ein weniger bekannter Fang

Prize refers to the fish caught, not its price or an award.

### YD-026 - P3: lexical

[i18n/deDE/fish.md](../i18n/deDE/fish.md:149)

- Before: sind ein anderer Preis, einer,
- After: sind ein anderer Fang, einer,

Keep the prized-catch sense, avoiding a literal price.

### YD-027 - P2: meaning

[i18n/deDE/fish.md](../i18n/deDE/fish.md:275)

- Before: Auch ohne die Zutaten eines Anglers
- After: Auch ohne die Ausschmückungen eines Anglers

The angler's additions are embellishments to the fishing story, not cooking ingredients.

### YD-028 - P2: clue-fidelity

[i18n/deDE/expeditions/ashenvale.md](../i18n/deDE/expeditions/ashenvale.md:17)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-029 - P3: grammar

[i18n/deDE/expeditions/duskwood.md](../i18n/deDE/expeditions/duskwood.md:33)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-030 - P2: name-consistency

[i18n/deDE/expeditions/feralas.md](../i18n/deDE/expeditions/feralas.md:10)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-031 - P2: meaning

[i18n/deDE/expeditions/hillsbrad-foothills.md](../i18n/deDE/expeditions/hillsbrad-foothills.md:13)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-032 - P2: lexical

[i18n/deDE/expeditions/loch-modan.md](../i18n/deDE/expeditions/loch-modan.md:40)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-033 - P2: runtime-gender

[i18n/deDE/expeditions/teldrassil.md](../i18n/deDE/expeditions/teldrassil.md:9)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-034 - P2: wordplay-action

[i18n/deDE/expeditions/stormwind-city.md](../i18n/deDE/expeditions/stormwind-city.md:27)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-035 - P2: wordplay-action

[i18n/deDE/expeditions/tanaris.md](../i18n/deDE/expeditions/tanaris.md:26)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-036 - P2: wordplay-action

[i18n/deDE/expeditions/wetlands.md](../i18n/deDE/expeditions/wetlands.md:10)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-037 - P2: grammar

[i18n/deDE/expeditions/zephras-isle.md](../i18n/deDE/expeditions/zephras-isle.md:38)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-038 - P2: grammar

[i18n/deDE/expeditions/zephras-isle.md](../i18n/deDE/expeditions/zephras-isle.md:50)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-039 - P2: reference

[i18n/deDE/expeditions/western-plaguelands.md](../i18n/deDE/expeditions/western-plaguelands.md:6)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-040 - P2: meaning

[i18n/deDE/expeditions/thunder-bluff.md](../i18n/deDE/expeditions/thunder-bluff.md:8)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-041 - P2: coverage-provenance

[i18n/deDE/expeditions/dun-morogh.md](../i18n/deDE/expeditions/dun-morogh.md:11)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-042 - P3: route-clarity

[i18n/deDE/expeditions/thousand-needles.md](../i18n/deDE/expeditions/thousand-needles.md:15)

Riddle text corrected. The wording is left out here: it would give the riddle away (the change is in the file).

### YD-043 - P3: functional-idiom

[i18n/deDE/words.json](../i18n/deDE/words.json:197)

- Before: Entdeckt am %s. Klicken, um es auf der Karte zu umreißen.
- After: Entdeckt am %s. Klicken, um den Umriss auf der Karte anzuzeigen.

Describe showing an outline, rather than sketching or summarizing the place.

## Verification and limits

`bun run check` passed: script tests, Lua lint, generated-data and locale checks, and the Classic/Forever simulations. The added checks load fresh German namespaces for both character genders and inspect the finished family, Atlas, flora, riddle, quarry and interface text. They cover veiled-text decoding, UTF-8, prose semicolons, gender expansion, the faction article, singular/plural fish counters and client-specific coverage. `bun scripts/package.ts --check` also passed for all three TOCs and the legacy handover package.

The original English content, resolver data, answer fingerprints, ids, source hashes and French translations are preserved. The German metadata stays flagged. A live WoW layout check and native German puzzle feedback remain separate from these checks.
