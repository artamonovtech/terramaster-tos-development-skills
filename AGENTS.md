# AGENTS.md — Guide for AI Coding Agents

Instructions for AI agents (Claude Code, OpenCode, Cursor, Codex, …) working **on this repository**.

This repo is **not** an application — it is a [skills.sh](https://skills.sh)-format skill that packages the official TerraMaster TOS 7 application development documentation for AI coding agents. The deliverable is the directory `skills/terramaster-tos-development-skills/`.

## Repository Layout

```
skills/terramaster-tos-development-skills/   # THE deliverable (installed by npx skills)
├── SKILL.md              # Frontmatter + routing tables; < 500 lines
├── references/           # 22 md files, copied 1:1 from upstream (GENERATED)
│   ├── 01_Overview.md … 20_Appendix.md
│   ├── agent-api.md      # renamed from Developer/agent-api/README.md
│   ├── self-testing.md   # renamed from TOSAppSelfTestingTool/README.md
│   └── .source-version   # upstream commit + date tracker
└── assets/templates/     # verbatim upstream package templates (GENERATED)
    ├── deb-single/  deb-dual/  docker/

scripts/generate-references.sh   # Regenerates references/ + assets/templates/ from upstream
.github/workflows/update-references.yml   # Weekly auto-regeneration (cron)
install.sh                       # Multi-tool installer (--claude, --opencode, --custom, …)
docs/publication.md              # Manual publishing runbook (internal)
README.md, LICENSE
```

Gitignored local artifacts (never commit): `.agents/`, `.opencode/`, `.claude/`, `.cursor/`, `skills-lock.json`, `.DS_Store`.

## Critical Rules

### 1. Never hand-edit generated content

Everything under `skills/terramaster-tos-development-skills/references/` and `skills/terramaster-tos-development-skills/assets/templates/` is copied byte-for-byte from upstream [terramaster-tos/tos-app-pkg-tools](https://github.com/terramaster-tos/tos-app-pkg-tools). Do not fix typos, reformat, or "improve" these files — edits will be silently reverted by the next weekly upstream sync and produce noisy diffs.

To change generated content:

```bash
bash scripts/generate-references.sh
```

Only edit the generator (`scripts/generate-references.sh`) if the upstream layout, file set, or copy logic changes.

### 2. SKILL.md is the only hand-written routing layer

`SKILL.md` is hand-maintained. When touching it:

- Keep the body under **500 lines** (skills.sh validation limit).
- Frontmatter: `name` must be kebab-case and exactly match the directory name `terramaster-tos-development-skills`; `description` must contain trigger phrases (this is what skills.sh matches on).
- If upstream adds/renames chapters or templates, update the tables in SKILL.md **and** the generator script together.
- Chapter files cross-link by relative filename; links to `../README.md` are dead by design (upstream TOC is not copied) — SKILL.md replaces that routing role.

### 3. Factual claims about TOS packaging come from references/

TOS packaging rules are specific and review-enforced. When writing README text, docs, or examples that describe TOS app behavior, base claims on the `references/` files — do not improvise generic Debian/Docker conventions that contradict them (e.g. never suggest `-beta` version suffixes; TOS uses `"beta": true` in `config.ini`).

## Validation Before Committing

```bash
# Regenerate and confirm no unintended diffs
bash scripts/generate-references.sh

# Validate skill structure (frontmatter, name/dir match, line limit)
npx skills add . --skill terramaster-tos-development-skills -a opencode
# (places a byte-identical copy into .agents/skills/… — gitignored, safe to delete after)

# Or, if available:
npx skills-ref validate
```

Check `references/.source-version` changed only when upstream actually changed.

## Conventions

- Public docs (README.md, SKILL.md, install.sh) are in **English**; docs/publication.md is an internal note.
- No build step, no test suite, no runtime dependencies — "tests" here are regeneration + `npx skills add .` round-trip.
- Keep install paths in README.md's compatibility table in sync with `install.sh` flags.
- Commits: short imperative subject; generated-content syncs should be their own commit (they are produced by the weekly workflow).
- Publishing to skills.sh / GitHub is **manual by a human only** — see docs/publication.md. Never push, create releases, or run the publish flow on your own.
