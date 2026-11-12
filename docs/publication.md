# publication.md — Manual Skill Publishing

Step-by-step publishing instructions for the `terramaster-tos-development-skills`
repository. Publishing is performed **manually, by a human only** — no automated
publishing actions are performed (no repository creation/push, no skills.sh indexing).

> This file is an internal instruction. Pushing it to the public repository is optional:
> the `skills` CLI only takes the `skills/<name>/` directory, so it has no effect on
> installation or indexing.

---

## Progress Status

*Last updated: 2026-11-12*

- [x] Steps 0–3 — done: content transferred into the repository, the skill directory
      renamed to match the frontmatter `name`, the old name replaced in all files.
- [x] Step 4 — local verification passed: the generator ran (upstream `18a13ee`),
      22 md files in `references/`, skill size ~616 KB,
      `npx skills add . --skill terramaster-tos-development-skills -a opencode` places files
      into `.agents/skills/terramaster-tos-development-skills/` (byte-identical copy),
      `skills-ref validate` — "Valid skill".
      The `./install.sh --opencode` check (clones the GitHub repository) is now possible
      — the content is pushed (see Step 5).
- [x] Step 5 — done: content pushed to `main` via PR #1 ("Create init commit"),
      merge commit `3409a56`. Local branch `main` is in sync with `origin/main`.
      Follow-up: README wording fixes ("75+" claims removed) are staged locally and
      need a follow-up commit + push before tagging (see Step 6).
- [ ] Step 6 — tag the release `v1.0.0` (no tags exist yet, locally or on remote;
      SKILL.md declares `version: "1.0.0"`).
- [ ] Step 7 — repository setup (verified via GitHub API on 2026-11-12: description
      empty, no topics). `gh` requires auth first: `gh auth login`.
- [ ] Step 8 — skills.sh indexing: https://skills.sh/artamonovtech/terramaster-tos-development-skills
      returns 404 (first `npx skills add` not yet performed).
- [ ] Step 9 — final verification.

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

## Step 6 — Tag the release (pending)

No tags exist yet (verified locally and on remote). Tag the release to match the
`version` field in the skill frontmatter (`SKILL.md`: `version: "1.0.0"`):

```bash
git tag -a v1.0.0 -m "TerraMaster TOS 7 app development skill v1.0.0 (upstream 18a13ee)"
git push origin v1.0.0
```

Rules:

- Tag **after** the pending README/docs follow-up commit is pushed, so the tag points
  at the final published state of `main`.
- Tag format: `v<major>.<minor>.<patch>`, always matching `SKILL.md` `version`.
- Bump both together: edit `version` in `skills/terramaster-tos-development-skills/SKILL.md`
  frontmatter, then create the next tag.
- Note: skills.sh resolves the skill from the default branch, not from tags — tagging
  is for humans (release tracking, GitHub Releases), not required for indexing.

## Step 7 — Configure the GitHub repository (pending)

`gh` requires authentication first (`gh auth login`), then:

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

Verified on 2026-11-12 via the public GitHub API: description empty, topics `[]` —
this step has not been performed yet.

## Step 8 — Indexing on skills.sh (first `npx skills add`) — pending

Verified on 2026-11-12: https://skills.sh/artamonovtech/terramaster-tos-development-skills
returns 404 — the first `npx skills add` has not been performed yet.

skills.sh indexes the repository **after the first `npx skills add`** — performed manually
from any unrelated folder (not from the repository itself):

```bash
cd "$(mktemp -d)"
npx skills add artamonovtech/terramaster-tos-development-skills --skill terramaster-tos-development-skills
```

The CLI will ask for an agent and an installation scope — pick any; the goal of the step
is the installation itself.

## Step 9 — Final verification (pending)

- [ ] An entry appeared at https://skills.sh/artamonovtech/terramaster-tos-development-skills
      (may take some time after the first add).
- [ ] `npx skills find terramaster` finds the skill.
- [ ] In the project where the skill was installed, `npx skills check` shows the current
      version, and `npx skills update` pulls in changes.

## Going Forward

- Documentation updates arrive **automatically**: weekly CI copies fresh upstream files
  and commits when they change — reinstalling / `npx skills update` delivers them to users.
- Generator errors (renames upstream) fail in CI with the message
  "source file(s)/dir(s) missing upstream" — then fix the paths in `scripts/generate-references.sh`.
- Re-publishing is not required: new commits to `main` are picked up by skills.sh automatically.
- For intentional content changes (rule clarifications, new scenarios in SKILL.md), bump
  `version` in the SKILL.md frontmatter and create the matching `vX.Y.Z` tag (Step 6).
  Weekly upstream syncs don't require a version bump.
