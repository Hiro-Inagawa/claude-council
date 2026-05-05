# Naming Conventions

## Topic Slug

- Lowercase, hyphenated, 2–5 words
- Derived from the decision, not the trigger phrase
- Describes the core subject, not the format
- If the question has a clear noun (the thing being decided), use it

**Examples:**
- "Should I launch a course or a workshop?" → `course-vs-workshop`
- "Is this pricing strategy right?" → `pricing-strategy-check`
- "Should I hire a VA or automate first?" → `va-vs-automation`
- "Council this: my landing page copy" → `landing-page-copy`
- "Should I pivot from X to Y?" → `pivot-to-y` or `x-vs-y`

**Avoid:** Generic slugs like `business-decision`, `strategy-question`, `big-choice`.

## File Names

Both files per session follow this exact pattern:

```
council-report-YYYY-MM-DD_HHMM.html
council-transcript-YYYY-MM-DD_HHMM.md
```

- Date: ISO 8601 (`2026-04-27`)
- Time: 24-hour, no colon (`1430` = 2:30 PM)
- Separator: underscore between date and time (sorts cleanly in Windows Explorer)
- No spaces

## Folder Structure

```
C:\Users\hiro\Projects\__COUNCIL\
├── __DOCUMENTATION\
│   ├── README.md
│   ├── CONVENTIONS.md
│   └── _LOGS\
│       ├── CHANGELOG.md     ← skill development history
│       └── sessions.md      ← one line per council run
└── <topic-slug>\            ← auto-created per session
    ├── council-report-YYYY-MM-DD_HHMM.html
    └── council-transcript-YYYY-MM-DD_HHMM.md
```

## Multiple Runs on Same Topic

Same topic, different timestamps → same `<topic-slug>` folder, different filenames. This keeps the evolution of thinking visible in one place.

## Sessions Log Format

Append one line per session to `__DOCUMENTATION\_LOGS\sessions.md`:

```
YYYY-MM-DD HH:MM | <slug> | <one-sentence question summary>
```

**Example:**
```
2026-04-27 22:30 | course-vs-workshop | Should I launch a $297 course or a live $97 workshop for Claude Code beginners?
```
