---
name: claude-council
description: "Use when faced with a high-stakes decision with genuine uncertainty, multiple options, or tradeoffs that warrant pressure-testing from multiple angles. MANDATORY TRIGGERS: 'council this', 'run the council', 'war room this', 'pressure-test this', 'stress-test this', 'debate this'. STRONG TRIGGERS (when combined with a real decision): 'should I X or Y', 'which option', 'what would you do', 'is this the right move', 'validate this', 'get multiple perspectives', 'I can't decide', 'I'm torn between'. Do NOT trigger on simple yes/no questions, factual lookups, or casual 'should I' without a meaningful tradeoff."
---

# Claude Council

## Overview

One AI gives one answer. The council runs your question through 5 independent analytical passes — each approaching the problem from a fundamentally different angle — then through 5 specialized review passes, audits output at two quality gates, and synthesizes a final verdict.

**Shape:** researcher (optional) → 5 analytical passes → Gate 1 → 5 review passes → synthesis → Gate 2 → 2 artifacts.

**Cost:** 13–14 agent calls per session (14 with research pass). Reserve for decisions where being wrong is expensive.

## When to Run / When Not to Run

| Run the council | Skip the council |
|---|---|
| High-stakes decision with real tradeoffs | One right answer (factual lookup) |
| Genuine uncertainty across multiple options | Creation task (write a tweet) |
| You want pressure-testing, not validation | Processing task (summarize this) |
| The cost of being wrong is high | Casual "should I" with no real stakes |

## The Five Analytical Passes

- **Failure Analysis** — finds the specific flaw that breaks the decision under real conditions
- **First Principles** — strips the question back to what it's actually asking
- **Maximum Upside** — finds the upside and adjacent opportunities nobody is naming
- **Fresh Eyes** — approaches with zero prior context; catches what familiarity hides
- **Execution** — focuses purely on whether this can be done and what the first step is

## Quality Gates

Two audit points prevent low-quality output from propagating downstream:

- **Gate 1 — Response Quality Check** (after analytical passes, before review): flags responses that are too thin or off-angle. `GATE: FAIL` = surface to user before continuing.
- **Gate 2 — Synthesis Audit** (after synthesis, before writing artifacts): independently verifies the verdict accurately represents the inputs. `AUDIT: FAIL` = synthesis re-runs with specific corrections. One retry maximum.

## Output Folder

Set your output folder here. The default is `~/claude-council`. Change it to match your setup:

```
OUTPUT_FOLDER: ~/claude-council
```

All sessions write to `<OUTPUT_FOLDER>/<topic-slug>/`.

## Workflow

### Step 0 — Research (conditional)

Run if the framed question involves: product or tool evaluation, technical stack decisions, market or ecosystem questions, best practice questions, or any decision where external evidence exists and would meaningfully ground the analytical passes.

Skip if: personal decision, internal strategy with no external signal, purely subjective preference, or a question where real-world data doesn't exist.

Spawn `researcher` with the framed question. Append its output to the framing prompt used in Step 3, labeled clearly:

```
## External Research Context
[researcher output]
```

If the researcher finds nothing relevant, proceed without the brief. Do not block the pipeline on an empty search.

### Step 1 — Enrich context
Glob and Read for `CLAUDE.md`, `memory/`, any files the user referenced. Budget: 30 seconds. Goal: give the analytical passes specific, grounded context.

If the question is too vague to frame, ask ONE clarifying question. Then proceed.

### Step 2 — Frame the question + derive slug
Produce a neutral framed prompt: core decision, context from user message, context from workspace, what's at stake.

Self-check before proceeding: *"Is this specific enough that the passes will give non-generic output?"* If not, add more context from the workspace scan or ask one follow-up question.

Derive the topic slug: 2–5 words, lowercase, hyphenated (e.g. `course-launch-decision`).

### Step 3 — Spawn 5 analytical passes IN PARALLEL
Single message, 5 Agent tool calls simultaneously. Each gets their agent file (in `agents/` subfolder), the framed question, and: "Be direct. 150–300 words. No preamble."

Agents: `contrarian`, `first-principles-thinker`, `expansionist`, `outsider`, `executor`.

### Step 4 — Gate 1: Response quality check
Spawn `response-quality-checker` with all 5 responses and the framed question.

- `GATE: PASS` or all HIGH → proceed to Step 5
- `GATE: FAIL` → surface the failing pass(es) to the user. Do not continue to review until resolved.

### Step 5 — Write A–E mapping + partial transcript
Randomly map each analytical pass → letter A–E. Immediately write the mapping and all 5 responses to the transcript file on disk:

**`<OUTPUT_FOLDER>/<slug>/council-transcript-YYYY-MM-DD_HHMM.md`**

Start the file with:
```
## Anonymization Mapping
A = [Pass Name]
B = [Pass Name]
C = [Pass Name]
D = [Pass Name]
E = [Pass Name]

## Analytical Responses
### [Pass Name]
[response]
...
```

Writing the mapping to disk before review ensures it cannot be lost or confused in a long session.

### Step 6 — Spawn 5 review passes IN PARALLEL
Single message, 5 Agent tool calls simultaneously. Each reviewer gets a different lens and all 5 anonymized (A–E) responses.

| Agent | Lens |
|---|---|
| `reviewer-synthesizer` | Finds genuine convergence across responses |
| `reviewer-gap-finder` | Identifies what ALL responses missed |
| `reviewer-skeptic` | Argues against the strongest response |
| `reviewer-devil` | Defends the weakest/most unpopular response |
| `reviewer-integrator` | Finds synthesis opportunities between responses |

### Step 7 — Synthesis
Single Agent call to `chairman`. Input: de-anonymized responses (names restored) + all 5 review outputs labeled by type.

Synthesis produces two sections:
1. **Analytical stances** — one-sentence summary per pass for the at-a-glance grid
2. **Verdict** — Where Passes Agree / Clash / Blind Spots / Recommendation / One Thing First — as HTML fragments

### Step 8 — Gate 2: Synthesis audit
Spawn `chairman-auditor` with: original question, all 5 responses, all 5 reviews, and the synthesis output.

- `AUDIT: PASS` → proceed to Step 9
- `AUDIT: FLAG` → proceed, but prepend a `⚑ Audit Flags` section to the transcript
- `AUDIT: FAIL` → synthesis re-runs with the auditor's corrections noted. One retry, then proceed regardless.

### Step 9 — Write full artifacts + log

**Complete the transcript** → append to the partial file from Step 5:
```
## Review Passes
### Convergence
[output]
### What the Room Missed
[output]
### Against the Best Answer
[output]
### For the Weakest Answer
[output]
### Combinations
[output]

## Synthesis
[full synthesis output]

## Audit Result
[chairman-auditor output]
```

**HTML report** → `<OUTPUT_FOLDER>/<slug>/council-report-YYYY-MM-DD_HHMM.html`

Use `templates/report.html`. Fill all `{{PLACEHOLDER}}` fields with the synthesis output. Responses go in the collapsible `<details>` sections as plain text (the `white-space: pre-wrap` CSS handles it). Write as a complete self-contained file.

**Session log** → append one line to `<OUTPUT_FOLDER>/_logs/sessions.md`:
```
YYYY-MM-DD HH:MM | <slug> | <one-sentence question summary>
```

Create the `<slug>` subfolder and `_logs/` if they don't exist. Multiple runs on the same topic use the same folder with different timestamps.

See `references/naming-conventions.md` for slug rules and filename details.
