# publication.md — Manual Skill Publishing

Step-by-step publishing instructions for the `terramaster-tos-development-skills`
repository. Publishing is performed **manually, by a human only** — no automated
publishing actions are performed (no repository creation/push, no skills.sh indexing).

> This file is an internal instruction. Pushing it to the public repository is optional:
> the `skills` CLI only takes the `skills/<name>/` directory, so it has no effect on
> installation or indexing.

---

## Progress Status

- [x] Steps 0–3 — done: content transferred into the repository, the skill directory
      renamed to match the frontmatter `name`, the old name replaced in all files.
- [x] Step 4 — local verification passed: the generator ran (upstream `18a13ee`),
      22 md files in `references/`, skill size ~616 KB,
      `npx skills add . --skill terramaster-tos-development-skills -a opencode` places files
      into `.agents/skills/terramaster-tos-development-skills/` (byte-identical copy),
      `skills-ref validate` — "Valid skill".
      The `./install.sh --opencode` check is only possible **after step 5** — the script
      clones the GitHub repository, and the content has not been pushed yet.
- [ ] Steps 5–8 — publishing: commit/push, repository setup, first `npx skills add`,
      final verification.

---

## Step 0 — Prerequisites (done)

- [x] GitHub repository created: `artamonovtech/terramaster-tos-development-skills`
      (initial commit: LICENSE, branch `main`).
- [x] Local clone configured, remote `origin` points to the repository (SSH).

Tool requirements: Node.js **22.20+** (for `npx skills`), `git`, `gh` (optional, for steps 5–6).

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

## Step 5 — Commit and push

```bash
git add -A
git status   # make sure there is nothing extra (docs/ is optional)
git commit -m "Initial skill: TOS 7 app development references, templates, CI"
git push origin main
```

After the push, GitHub Actions picks up the `update-references.yml` workflow
(weekly cron, Mon 06:00 UTC + `workflow_dispatch`). For a one-off verification run:
`gh workflow run update-references.yml` — or just wait until the nearest Monday.

## Step 6 — Configure the GitHub repository

- **Topics** (About tab → gear, or):
  ```bash
  gh repo edit --add-topic terramaster --add-topic tos --add-topic homelab \
               --add-topic docker --add-topic docker-compose \
               --add-topic self-hosted --add-topic agent-skills \
               --add-topic skill-md --add-topic claude-code \
               --add-topic codex --add-topic opencode
  ```
- **About description**:
  "🤖 Auto-updated TerraMaster TOS 7 app development documentation for AI coding assistants — works with 20+ tools via the Agent Skills standard (SKILL.md)".

## Step 7 — Indexing on skills.sh (first `npx skills add`)

skills.sh indexes the repository **after the first `npx skills add`** — performed manually
from any unrelated folder (not from the repository itself):

```bash
cd "$(mktemp -d)"
npx skills add artamonovtech/terramaster-tos-development-skills --skill terramaster-tos-development-skills
```

The CLI will ask for an agent and an installation scope — pick any; the goal of the step
is the installation itself.

## Step 8 — Final verification

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
