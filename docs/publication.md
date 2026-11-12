# publication.md — Manual Skill Publishing

Step-by-step publishing instructions for the `terramaster-tos-development-skills`
repository. Publishing is performed **manually, by a human only** — no automated
publishing actions are performed (no repository creation/push, no skills.sh indexing).

> This file is an internal instruction. Pushing it to the public repository is optional:
> the `skills` CLI only takes the `skills/<name>/` directory, so it has no effect on
> installation or indexing.

---

## Progress Status

*Last updated: 2026-11-12 (publishing completed)*

- [x] Steps 0–3 — done: content transferred into the repository, the skill directory
      renamed to match the frontmatter `name`, the old name replaced in all files.
- [x] Step 4 — local verification passed: the generator ran (upstream `18a13ee`),
      22 md files in `references/`, skill size ~616 KB,
      `npx skills add . --skill terramaster-tos-development-skills -a opencode` places files
      into `.agents/skills/terramaster-tos-development-skills/` (byte-identical copy),
      `skills-ref validate` — "Valid skill".
- [x] Step 5 — done: content pushed to `main` via PR #1 ("Create init commit"),
      merge commit `3409a56`, plus follow-up commits (`b54b067` README wording,
      `76828f6` this doc). Local branch `main` is in sync with `origin/main`.
- [x] Step 6 — done: tag `v1.0.0` created and pushed (annotated, points at `76828f6`,
      the final published state of `main`).
- [x] Step 7 — done: description and all 11 topics set via `gh repo edit`
      (verified via GitHub API on 2026-11-12).
- [x] Step 8 — done: first `npx skills add` performed from a temp folder
      (agent: opencode, `--copy`); the entry appeared at
      https://www.skills.sh/artamonovtech/terramaster-tos-development-skills
      (note: skills.sh redirects to `www.skills.sh`; a bare-URL check must follow -L).
- [ ] Step 9 — partially done: `skills list` / `skills check` pass
      ("All project skills are up to date"); `npx skills find` does not return the
      skill yet — the search index updates with a delay after the first add.
      Re-check `npx skills find terramaster` later.

---

## Step 0 — Prerequisites (done)

- [x] GitHub repository created: `artamonovtech/terramaster-tos-development-skills`
      (initial commit: LICENSE, branch `main`).
- [x] Local clone configured, remote `origin` points to the repository (SSH).

Tool requirements: Node.js **22.20+** (for `npx skills`), `git`, `gh` (optional, for steps 5 and 7).

## Steps 1–3 — Transfer content, rename, replace the old name (done)

Historical record of the one-time setup: the working content was rsynced into the
repository, the skill directory was renamed to `skills/terramaster-tos-development-skills/`
(the directory name must match the `name` in the frontmatter), and the old skill name was
replaced in the 5 hand-written files (SKILL.md, README.md, install.sh,
scripts/generate-references.sh, .github/workflows/update-references.yml). Generated
content (`references/`, templates) never contained the old name.

## Step 4 — Local verification (done)

```bash
# 1. The generator runs with the new paths and writes .source-version
bash scripts/generate-references.sh

# 2. Size and composition
du -sh skills/terramaster-tos-development-skills/        # ~616 KB
find skills/terramaster-tos-development-skills/references -name '*.md' | wc -l   # 22

# 3. CLI install test from the repository root:
#    files must land in .agents/skills/terramaster-tos-development-skills/
npx skills add . --skill terramaster-tos-development-skills -a opencode

# 4. install.sh
./install.sh --opencode
```

Additionally, you can check with the format validator (same as in CI):

```bash
npx --yes skills-ref@0.1.5 validate skills/terramaster-tos-development-skills
```

## Step 5 — Commit and push (done)

Content was pushed via PR #1 ("Create init commit"), merge commit `3409a56`;
`main` is in sync with `origin/main`.

After the push, GitHub Actions picks up the `update-references.yml` workflow
(weekly cron, Mon 06:00 UTC + `workflow_dispatch`). For a one-off verification run:
`gh workflow run update-references.yml` — or just wait until the nearest Monday.

## Step 6 — Tag the release (done)

Tag `v1.0.0` created and pushed on 2026-11-12 (annotated tag, points at the final
published state of `main` after the follow-up commits).

Rules:

- Tag **after** the pending README/docs follow-up commit is pushed, so the tag points
  at the final published state of `main`.
- Tag format: `v<major>.<minor>.<patch>`, always matching `SKILL.md` `version`.
- Bump both together: edit `version` in `skills/terramaster-tos-development-skills/SKILL.md`
  frontmatter, then create the next tag.
- Note: skills.sh resolves the skill from the default branch, not from tags — tagging
  is for humans (release tracking, GitHub Releases), not required for indexing.

## Step 7 — Configure the GitHub repository (done)

Done on 2026-11-12 via `gh repo edit` (account `artamonovtech`):

- **Topics** (About tab → gear, or):
  ```bash
  gh repo edit --add-topic terramaster --add-topic tos --add-topic homelab \
               --add-topic docker --add-topic docker-compose \
               --add-topic self-hosted --add-topic agent-skills \
               --add-topic skill-md --add-topic claude-code \
               --add-topic codex --add-topic opencode
  ```
- **About description**:
  "🤖 Auto-updated TerraMaster TOS 7 app development documentation for AI coding assistants — works with all major agents via the Agent Skills standard (SKILL.md)".

Verified on 2026-11-12 via the public GitHub API: description and all 11 topics are set.

## Step 8 — Indexing on skills.sh (first `npx skills add`) — done

Done on 2026-11-12: the first `npx skills add` was performed from a temp folder
(not from the repository), with `--agent opencode --yes --copy`. The installation
succeeded and the entry appeared at
https://www.skills.sh/artamonovtech/terramaster-tos-development-skills
("1 skill"; bare skills.sh URLs redirect to `www.skills.sh` — check with `curl -L`).

skills.sh indexes the repository **after the first `npx skills add`** — performed manually
from any unrelated folder (not from the repository itself):

```bash
cd "$(mktemp -d)"
npx skills add artamonovtech/terramaster-tos-development-skills --skill terramaster-tos-development-skills
```

The CLI will ask for an agent and an installation scope — pick any; the goal of the step
is the installation itself.

## Step 9 — Final verification (partially done)

- [x] An entry appeared at https://www.skills.sh/artamonovtech/terramaster-tos-development-skills
      ("1 skill"; indexed after the first add on 2026-11-12).
- [ ] `npx skills find terramaster` finds the skill — **not yet**: the search index
      updates with a delay after the first add; re-check later.
- [x] In the project where the skill was installed, `npx skills check` shows
      "All project skills are up to date" (and `npx skills update` is available).

## Going Forward

- Documentation updates arrive **automatically**: weekly CI copies fresh upstream files
  and commits when they change — reinstalling / `npx skills update` delivers them to users.
- Generator errors (renames upstream) fail in CI with the message
  "source file(s)/dir(s) missing upstream" — then fix the paths in `scripts/generate-references.sh`.
- Re-publishing is not required: new commits to `main` are picked up by skills.sh automatically.
- For intentional content changes (rule clarifications, new scenarios in SKILL.md), bump
  `version` in the SKILL.md frontmatter and create the matching `vX.Y.Z` tag (Step 6).
  Weekly upstream syncs don't require a version bump.
