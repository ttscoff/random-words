# Doctor Who (`who`) Dictionary Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a large Doctor Who dictionary at `lib/random-words/words/who/` (triggers `who`, `doctorwho`, `tardis`) focused on dialog and characters, New Who–forward with a Classic sprinkle, without changing generator code.

**Architecture:** Dictionaries are plain-text word-class files plus `config.yml`, auto-discovered from `lib/random-words/words/*/`. This work only adds files under `who/`. Content follows the hybrid design: names/phrases/clauses carry dialog and characters; nouns/verbs/adjectives/adverbs supply Walken-scale franchise lexicon; structural grammar files are copied from `english`.

**Tech Stack:** Ruby gem `random-words`, RSpec, plain `.txt` / `.yml` dictionary files.

## Global Constraints

- Directory name and `config.yml` `name` must be `who`
- Triggers must include exactly: `who`, `doctorwho`, `tardis` (do not add bare `doctor` — that is the medical dictionary)
- Do not modify `lib/random-words/words/doctor/` or any Ruby sources
- Era: mostly New Who; Classic sprinkle heavier for Fourth Doctor, Sarah Jane, UNIT, iconic monsters/catchphrases
- Quote density: medium (~50–70 phrases); bulk is themed vocabulary
- Size target: ~2500+ lines across all word `.txt` files combined
- `names.txt` must be a **single section** (no blank-line separators) so all entries become `full_names` like `alice` — multi-word labels such as `The Doctor` and `Rose Tyler` must not be split into random first+last pairs
- Prefer franchise-common terms; avoid obscure one-off props unless culturally iconic
- Keep singular/plural noun and verb pairs consistent where both files exist
- Sort word lists alphabetically (case-insensitive) within each content file unless the format forbids it (terminators, numbers.yml)
- Spec: `docs/superpowers/specs/2026-10-29-who-dictionary-design.md`

---

## File Structure

| Path | Responsibility |
|------|----------------|
| `lib/random-words/words/who/config.yml` | Name, description, triggers |
| `lib/random-words/words/who/names.txt` | Character full names (~80–120) |
| `lib/random-words/words/who/phrases.txt` | Iconic lines (~50–70) |
| `lib/random-words/words/who/clauses.txt` | Show-voice fragments (~180–250) |
| `lib/random-words/words/who/nouns-singular.txt` | Franchise nouns (~400–500) |
| `lib/random-words/words/who/nouns-plural.txt` | Matching plurals (~300–400) |
| `lib/random-words/words/who/verbs-singular.txt` | 3rd-person singular (~250–300) |
| `lib/random-words/words/who/verbs-plural.txt` | Base/plural verbs (~250–300) |
| `lib/random-words/words/who/verbs-passive.txt` | Passive phrases (~200–350) |
| `lib/random-words/words/who/adjectives.txt` | Themed adjectives (~130–200) |
| `lib/random-words/words/who/adverbs.txt` | Themed adverbs (~130–200) |
| `lib/random-words/words/who/articles-*.txt`, `conjunctions-*.txt`, `prepositions.txt`, `terminators.txt`, `numbers.yml` | Structural glue copied from `english` |

No Ruby file changes.

---

### Task 1: Scaffold directory, config, and structural files

**Files:**
- Create: `lib/random-words/words/who/config.yml`
- Create: `lib/random-words/words/who/articles-singular.txt`
- Create: `lib/random-words/words/who/articles-plural.txt`
- Create: `lib/random-words/words/who/conjunctions-coordinating.txt`
- Create: `lib/random-words/words/who/conjunctions-subordinate.txt`
- Create: `lib/random-words/words/who/prepositions.txt`
- Create: `lib/random-words/words/who/terminators.txt`
- Create: `lib/random-words/words/who/numbers.yml`
- Create (stubs for later tasks so Source can load): empty-or-minimal placeholders for remaining required files listed in Task 1 Step 3 — replace in later tasks

**Interfaces:**
- Consumes: `lib/random-words/words/english/{articles-singular,articles-plural,conjunctions-coordinating,conjunctions-subordinate,prepositions,terminators}.txt` and `numbers.yml`
- Produces: loadable `who` directory with config triggers `[who, doctorwho, tardis]`

- [ ] **Step 1: Create the directory and config**

```bash
mkdir -p lib/random-words/words/who
```

Write `lib/random-words/words/who/config.yml`:

```yaml
---
name: who
description: Doctor Who (New Who-forward, Classic sprinkle)
triggers: [who, doctorwho, tardis]
```

- [ ] **Step 2: Copy structural files from english**

```bash
cd /Users/ttscoff/Desktop/Code/random-words
for f in articles-singular.txt articles-plural.txt conjunctions-coordinating.txt conjunctions-subordinate.txt prepositions.txt terminators.txt numbers.yml; do
  cp "lib/random-words/words/english/$f" "lib/random-words/words/who/$f"
done
```

- [ ] **Step 3: Add minimal placeholders so Source loads**

Create these files with a single placeholder line each (later tasks replace with full content):

| File | Placeholder line |
|------|------------------|
| `names.txt` | `The Doctor` |
| `phrases.txt` | `Allons-y` |
| `clauses.txt` | `the TARDIS materializes` |
| `nouns-singular.txt` | `TARDIS` |
| `nouns-plural.txt` | `Daleks` |
| `verbs-singular.txt` | `regenerates` |
| `verbs-plural.txt` | `regenerate` |
| `verbs-passive.txt` | `was regenerated by` |
| `adjectives.txt` | `timey-wimey` |
| `adverbs.txt` | `brilliantly` |

- [ ] **Step 4: Verify the source loads**

```bash
ruby -e '
require_relative "lib/random-words"
g = RandomWords::Generator.new(:who)
puts g.source
puts g.sources["who"].names.inspect
puts g.sentence
'
```

Expected:
- `source` prints `who`
- `names` / triggers include `who`, `doctorwho`, `tardis`
- A sentence prints without raising

- [ ] **Step 5: Commit scaffold (only if user asked to commit)**

```bash
git add lib/random-words/words/who docs/superpowers/specs/2026-10-29-who-dictionary-design.md docs/superpowers/plans/2026-10-29-who-dictionary.md
git commit -m "$(cat <<'EOF'
Add Doctor Who dictionary scaffold.

@new **who** dictionary directory with config triggers who, doctorwho, tardis
EOF
)"
```

---

### Task 2: Character names and iconic phrases

**Files:**
- Replace: `lib/random-words/words/who/names.txt`
- Replace: `lib/random-words/words/who/phrases.txt`

**Interfaces:**
- Consumes: Task 1 scaffold
- Produces: `names.txt` with 80–120 full-name lines (no blank lines); `phrases.txt` with 50–70 iconic lines

- [ ] **Step 1: Write `names.txt` (single section, full names only)**

Replace the placeholder with ~80–120 alphabetized character labels. Required coverage:

**Doctors (even NuWho spread + Classic sprinkle):** The Doctor, War Doctor, Ninth Doctor, Tenth Doctor, Eleventh Doctor, Twelfth Doctor, Thirteenth Doctor, Fourteenth Doctor, Fifteenth Doctor, Fourth Doctor (and optionally other Classic numbers as light sprinkle)

**Companions (NuWho-heavy):** Rose Tyler, Mickey Smith, Jackie Tyler, Martha Jones, Donna Noble, Wilfred Mott, Amy Pond, Rory Williams, River Song, Clara Oswald, Bill Potts, Nardole, Yasmin Khan, Ryan Sinclair, Graham OBrien, Dan Lewis, Ruby Sunday, Belinda Chandra, Sarah Jane Smith, Jo Grant, Ace (Classic sprinkle)

**Allies / orgs:** Jack Harkness, UNIT, Kate Stewart, Brigadier Lethbridge-Stewart, K-9, Madame Vastra, Jenny Flint, Strax, Osgood

**Villains / monsters (as name-like subjects):** The Master, Missy, Dalek, Dalek Emperor, Cyberman, Cyber Leader, Weeping Angel, The Silence, The Beast, Cassandrashadow, Davros, Rassilon, Omega, Sutekh, The Toymaker, Maestro (keep to widely known figures; skip deep deep-cuts)

Style rules:
- No blank lines anywhere in the file (keeps all entries as `full_names`)
- No actor names as primary entries
- One entry per line; alphabetize case-insensitive

Minimal seed to expand from (implementer must expand to full count):

```text
Ace
Amy Pond
Bill Potts
Brigadier Lethbridge-Stewart
Clara Oswald
Cyberman
Dalek
Dan Lewis
Davros
Donna Noble
Eleventh Doctor
Fifteenth Doctor
Fourteenth Doctor
Fourth Doctor
Graham OBrien
Jack Harkness
Jackie Tyler
Jo Grant
K-9
Kate Stewart
Martha Jones
Mickey Smith
Missy
Nardole
Ninth Doctor
Osgood
Rassilon
River Song
Rory Williams
Rose Tyler
Ruby Sunday
Sarah Jane Smith
Tenth Doctor
The Doctor
The Master
The Silence
Thirteenth Doctor
Twelfth Doctor
UNIT
War Doctor
Weeping Angel
Wilfred Mott
Yasmin Khan
```

- [ ] **Step 2: Write `phrases.txt` (~50–70)**

Medium quote set — recognizable, not exhaustive. Include a mix of:

- Doctor catchphrases: Allons-y, Geronimo, Fantastic, I am and always will be the Optimist, wibbly-wobbly timey-wimey
- Companion beats: I was gonna be with you forever, Don't you dare
- Monster slogans: Exterminate, Delete, Are you my mummy
- Classic sprinkle: Would you like a jelly baby
- TARDIS / sonic flavor lines

One phrase per line; alphabetize; no blank lines required but allowed only if they do not break parsing (phrases file has no section split — blank lines become empty strings; prefer **no blank lines**).

Seed to expand:

```text
Allons-y
Are you my mummy
Bow ties are cool
Delete
Don't blink
Exterminate
Fantastic
Geronimo
I am and always will be the Optimist
Would you like a jelly baby
wibbly-wobbly timey-wimey stuff
```

Expand to 50–70 distinct phrases in the show’s voice (short enough to embed in random sentences).

- [ ] **Step 3: Verify names load as full_names**

```bash
ruby -e '
require_relative "lib/random-words"
s = RandomWords::Generator.new(:who).sources["who"]
d = s.dictionary
puts "first=#{d[:first_names].size} last=#{d[:last_names].size} full=#{d[:full_names].size}"
puts d[:full_names].sample(5)
puts "phrases=#{d[:phrases].size}"
'
```

Expected:
- `first=0 last=0` and `full` between 80 and 120
- `phrases` between 50 and 70
- Sample names look like characters, not `Rose Q Tyler`-style random recombinations

- [ ] **Step 4: Commit (only if user asked)**

```bash
git add lib/random-words/words/who/names.txt lib/random-words/words/who/phrases.txt
git commit -m "$(cat <<'EOF'
Add Who dictionary names and phrases.

@new **character names** and iconic dialog phrases for the who source
EOF
)"
```

---

### Task 3: Clauses (show-voice fragments)

**Files:**
- Replace: `lib/random-words/words/who/clauses.txt`

**Interfaces:**
- Consumes: Task 1–2
- Produces: 180–250 clause lines

- [ ] **Step 1: Write `clauses.txt`**

Replace placeholder with 180–250 fragments. Categories (approximate budgets):

| Category | ~Count | Examples |
|----------|--------|----------|
| TARDIS / travel | 30 | `the TARDIS materializes in a new century`, `the engines roar through the vortex` |
| Regeneration / Time Lord | 25 | `the Doctor regenerates in a blaze of light`, `two hearts beat out of sync` |
| Daleks / Cybermen / Angels | 40 | `the Daleks open fire`, `a Weeping Angel waits unblinking` |
| Companion loyalty / banter | 40 | `Rose refuses to stay behind`, `Donna saves the day again` |
| UNIT / Earth defense | 20 | `UNIT locks down the perimeter`, `the Brigadier calls for backup` |
| Timey-wimey / paradox | 25 | `a paradox tears open the timeline`, `history rewrites itself` |
| Classic sprinkle | 20 | `Sarah Jane investigates the anomaly`, `a jelly baby seals the deal` |

Voice: Walken-like mix of first person (`I trust the Doctor`) and third person (`the Master laughs in the dark`). One clause per line; no trailing periods required (match `walken`/`alice` style consistency within the file — prefer no terminal period, or all with periods; be consistent). Alphabetize if practical; category order is fine if counts are met.

- [ ] **Step 2: Verify clause count and sample sentences**

```bash
wc -l lib/random-words/words/who/clauses.txt
ruby -e '
require_relative "lib/random-words"
g = RandomWords::Generator.new(:who)
5.times { puts g.sentence; puts "---" }
'
```

Expected: `wc -l` in 180–250; sentences occasionally include Who-flavored clauses/names/phrases.

- [ ] **Step 3: Commit (only if user asked)**

```bash
git add lib/random-words/words/who/clauses.txt
git commit -m "$(cat <<'EOF'
Add Who dictionary clauses.

@new **show-voice clauses** for TARDIS, monsters, companions, and time travel
EOF
)"
```

---

### Task 4: Nouns (singular and plural)

**Files:**
- Replace: `lib/random-words/words/who/nouns-singular.txt`
- Replace: `lib/random-words/words/who/nouns-plural.txt`

**Interfaces:**
- Consumes: Task 1 scaffold
- Produces: ~400–500 singular nouns; ~300–400 plural nouns; pairs consistent where both forms exist

- [ ] **Step 1: Write `nouns-singular.txt` (~400–500)**

Alphabetized franchise lexicon. Category budgets (approximate):

| Category | Examples |
|----------|----------|
| Ship / tech | TARDIS, sonic screwdriver, chameleon circuit, dematerialization circuit, psychic paper, vortex manipulator |
| Time Lord lore | regeneration, Gallifrey, Rassilon, Time Lord, matrix, hermit |
| Monsters / species | Dalek, Cyberman, Weeping Angel, Silence, Sontaran, Judoon, Ood, Auton |
| Places | Skaro, Trenzalore, Satellite Five, Cardiff, Powell Estate |
| Abstract adventure | paradox, timeline, prophecy, extinction, invasion, miracle |
| People roles | companion, companion, soldier, scientist, refugee (also ordinary adventure nouns to reach Walken scale) |

Include enough general adventure/sci-fi nouns (corridor, bunker, signal, distress call) to hit ~400–500 without inventing fake episode titles.

- [ ] **Step 2: Write `nouns-plural.txt` (~300–400)**

Matching plurals for countable nouns (`Daleks`, `Cybermen`, `Weeping Angels`, `Timelines`, `companions`). Uncountable/proper singulars need not have forced plurals. Alphabetize.

- [ ] **Step 3: Verify counts**

```bash
wc -l lib/random-words/words/who/nouns-singular.txt lib/random-words/words/who/nouns-plural.txt
ruby -e '
require_relative "lib/random-words"
d = RandomWords::Generator.new(:who).sources["who"].dictionary
puts d[:nouns].sample(8)
puts d[:plural_nouns].sample(8)
'
```

Expected: singular 400–500; plural 300–400; samples look Who/sci-fi themed.

- [ ] **Step 4: Commit (only if user asked)**

```bash
git add lib/random-words/words/who/nouns-singular.txt lib/random-words/words/who/nouns-plural.txt
git commit -m "$(cat <<'EOF'
Add Who dictionary nouns.

@new **franchise nouns** covering tech, species, places, and time lore
EOF
)"
```

---

### Task 5: Verbs (singular, plural, passive)

**Files:**
- Replace: `lib/random-words/words/who/verbs-singular.txt`
- Replace: `lib/random-words/words/who/verbs-plural.txt`
- Replace: `lib/random-words/words/who/verbs-passive.txt`

**Interfaces:**
- Consumes: Task 1 scaffold
- Produces: ~250–300 singular; ~250–300 plural; ~200–350 passive

- [ ] **Step 1: Write verb files**

**verbs-singular.txt** — third-person singular (`regenerates`, `dematerializes`, `exterminates`, `converts`, `warns`, `arrives`, `vanishes`, `rewrites`). Target 250–300.

**verbs-plural.txt** — base forms used with plural subjects (`regenerate`, `dematerialize`, `exterminate`, `convert`, `warn`, `arrive`). Target 250–300. Keep pairs aligned with singular where possible.

**verbs-passive.txt** — phrases like walken (`was regenerated by`, `was converted by`, `was chased by`, `was saved by`, `was rewritten by`). Target 200–350.

Tone: action, threat, wonder, rescue — not medical chart verbs.

- [ ] **Step 2: Verify**

```bash
wc -l lib/random-words/words/who/verbs-*.txt
ruby -e '
require_relative "lib/random-words"
d = RandomWords::Generator.new(:who).sources["who"].dictionary
puts d[:verbs].sample(5)
puts d[:plural_verbs].sample(5)
puts d[:passive_verbs].sample(5)
'
```

Expected: counts in ranges above; samples Who-flavored.

- [ ] **Step 3: Commit (only if user asked)**

```bash
git add lib/random-words/words/who/verbs-singular.txt lib/random-words/words/who/verbs-plural.txt lib/random-words/words/who/verbs-passive.txt
git commit -m "$(cat <<'EOF'
Add Who dictionary verbs.

@new **action and passive verbs** for time travel, monsters, and rescue
EOF
)"
```

---

### Task 6: Adjectives and adverbs

**Files:**
- Replace: `lib/random-words/words/who/adjectives.txt`
- Replace: `lib/random-words/words/who/adverbs.txt`

**Interfaces:**
- Consumes: Task 1 scaffold
- Produces: ~130–200 adjectives; ~130–200 adverbs

- [ ] **Step 1: Write `adjectives.txt` and `adverbs.txt`**

Adjectives: `timey-wimey`, `wibbly-wobbly`, `ancient`, `doomed`, `brilliant`, `impossible`, `gallifreyan`, `cybernetic`, `paradoxical`, `lonely`, `last`, `forbidden`, plus broad adventure descriptors to reach count.

Adverbs: `brilliantly`, `suddenly`, `bravely`, `paradoxically`, `silently`, `furiously`, `impossibly`, etc.

Alphabetize; targets 130–200 each.

- [ ] **Step 2: Verify**

```bash
wc -l lib/random-words/words/who/adjectives.txt lib/random-words/words/who/adverbs.txt
```

Expected: both in 130–200.

- [ ] **Step 3: Commit (only if user asked)**

```bash
git add lib/random-words/words/who/adjectives.txt lib/random-words/words/who/adverbs.txt
git commit -m "$(cat <<'EOF'
Add Who dictionary adjectives and adverbs.

@new **themed modifiers** for timey-wimey and adventure tone
EOF
)"
```

---

### Task 7: Final size check, trigger check, and sample review

**Files:**
- Modify: any `lib/random-words/words/who/*.txt` that are under target (top up lexicon)
- Test: manual ruby checks (no new RSpec file required unless counts fail unexpectedly)

**Interfaces:**
- Consumes: Tasks 1–6 complete dictionary
- Produces: ≥2500 total lines; triggers work; sample output feels Who-themed

- [ ] **Step 1: Line-count audit**

```bash
wc -l lib/random-words/words/who/*.txt | sort -n
echo "---"
wc -l lib/random-words/words/who/*.txt | tail -1
```

Expected per-file ranges (from spec):

| File | Target |
|------|--------|
| names | 80–120 |
| phrases | 50–70 |
| clauses | 180–250 |
| nouns-singular | 400–500 |
| nouns-plural | 300–400 |
| verbs-singular | 250–300 |
| verbs-plural | 250–300 |
| verbs-passive | 200–350 |
| adjectives | 130–200 |
| adverbs | 130–200 |
| **all .txt total** | **≥2500** |

If under 2500, expand nouns/verbs/clauses first (highest bulk), then adjectives/adverbs.

- [ ] **Step 2: Trigger alias check**

```bash
ruby -e '
require_relative "lib/random-words"
%s[who doctorwho tardis].each do |t|
  sym = t.to_s.to_source
  puts "#{t} -> #{sym}"
end
g = RandomWords::Generator.new(:who)
puts g.paragraph
'
```

Expected: each of `who`, `doctorwho`, `tardis` resolves to `:who` (or source name `who`). Paragraph prints with Who flavor. Bare `doctor` must still resolve to the medical dictionary, not `who`.

```bash
ruby -e '
require_relative "lib/random-words"
puts "doctor".to_source
'
```

Expected: `:doctor` (medical), not `:who`.

- [ ] **Step 3: Confirm no Ruby or medical-doctor changes**

```bash
git status
git diff --stat
```

Expected: only `lib/random-words/words/who/**` and docs under `docs/superpowers/` (if uncommitted). No changes to `generator.rb` or `words/doctor/`.

- [ ] **Step 4: Final commit (only if user asked)**

```bash
git add lib/random-words/words/who docs/superpowers/specs/2026-10-29-who-dictionary-design.md docs/superpowers/plans/2026-10-29-who-dictionary.md
git commit -m "$(cat <<'EOF'
Complete Doctor Who dictionary.

@new **who** source with dialog, characters, and franchise lexicon
EOF
)"
```

---

## Spec coverage checklist

| Spec requirement | Task |
|------------------|------|
| Directory `who/` + config triggers | Task 1 |
| names ~80–120, character focus | Task 2 |
| phrases ~50–70 medium quotes | Task 2 |
| clauses ~180–250 | Task 3 |
| nouns/verbs/adj/adv Walken-scale | Tasks 4–6 |
| structural files from english | Task 1 |
| ≥2500 lines; Generator.new(:who); triggers | Task 7 |
| No generator / medical doctor changes | Task 7 Step 3 |
| New Who–forward, Classic sprinkle, even NuWho Doctors | Tasks 2–3 content guidance |

## Self-review notes

- No TBD/TODO placeholders left in tasks
- Names format explicitly constrained to alice-style full_names (avoids broken `The Q Doctor` recombinations)
- Commits gated on user request to match repo commit preference
- Content tasks specify category budgets and verification commands; implementer writes full alphabetized lists during execution (lists are too large to embed twice)
