# Verification Scenarios

Run these after installing to confirm the skill is working correctly.

---

## 1. Basic trigger test

**Input:** `council this: should I learn Rust or Go for systems programming?`

**What to verify:**
- Claude reads `SKILL.md` and starts the council pipeline
- 5 analytical passes spawn in a single message (parallel, not sequential)
- Gate 1 runs after all 5 responses are collected
- A–E mapping is written to disk before the review stage
- 5 review passes spawn in a single message (parallel)
- Synthesis runs, then Gate 2
- Two files land in `<OUTPUT_FOLDER>/rust-vs-go/` (or similar slug)
- HTML report opens in a browser without errors; all `<details>` toggles work

---

## 2. Trigger discrimination test

**Input:** `should I use markdown for this note?`

**What to verify:**
- The skill does NOT trigger (no stakes, no real tradeoff)
- Claude answers the question directly without running the council

---

## 3. Repeat-topic test

Run the same council question twice.

**What to verify:**
- Both runs land in the same `<topic-slug>/` folder
- Files have different timestamps
- `<OUTPUT_FOLDER>/_logs/sessions.md` has two appended lines

---

## 4. Gate 1 failure path (manual)

If you want to verify Gate 1 works: after the 5 analytical passes run, inspect the `response-quality-checker` output. A `GATE: FAIL` result should surface the failing pass(es) to you before peer review continues.

---

## 5. HTML report check

Open a generated `council-report-*.html` file in a browser and verify:
- Synthesis section renders at the top
- Analytical Passes at a Glance grid shows all 5 passes with stances
- Each pass has a collapsible `<details>` section that expands correctly
- Review Highlights section is present and collapsible
- No JavaScript errors in the browser console
- No external network requests (fully self-contained)
