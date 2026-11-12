# TerraMaster TOS Development Skills

A **TerraMaster TOS 7 application development skill for AI coding agents (Claude Code, OpenCode, Cursor)** and 75+ other tools supported by the [skills](https://skills.sh) CLI: it teaches your agent to build, package, sign, and publish apps for TerraMaster NAS devices running TOS 7.

References are **copied unmodified** from the official [terramaster-tos/tos-app-pkg-tools](https://github.com/terramaster-tos/tos-app-pkg-tools) repository (TOS 7 Application Development Guide v2.7, Agent API docs, self-testing tool) plus the three official package templates, and are **auto-updated weekly** by GitHub Actions.

## Sources

| Upstream content | What it provides |
|-----------|-----------------|
| [TOS 7 Application Development Guide](https://github.com/terramaster-tos/tos-app-pkg-tools/tree/main/TOS%207%20Application%20Development%20Guide) | 20 chapters: architecture, package spec, Deb/Docker development, permissions, signing, publishing, review, FAQ |
| [Agent API](https://github.com/terramaster-tos/tos-app-pkg-tools/tree/main/Developer/agent-api) | Developer platform REST API: auth, tokens, endpoints |
| [TOSAppSelfTestingTool](https://github.com/terramaster-tos/tos-app-pkg-tools/tree/main/TOSAppSelfTestingTool) | Pre-submission package validation tool |
| [Package templates](https://github.com/terramaster-tos/tos-app-pkg-tools) | `deb-single`, `deb-dual`, `docker` starter projects |

## Install

### Recommended: the skills CLI

```bash
npx skills add artamonovtech/terramaster-tos-development-skills
```

Or pick the skill and agent explicitly:

```bash
npx skills add artamonovtech/terramaster-tos-development-skills --skill terramaster-tos-development-skills -a claude-code
```

Requires Node.js 22.20+. See [skills.sh](https://skills.sh) for details.

### Install with git clone

Clone so that `SKILL.md` lands directly in your tool's skill directory:

```bash
# Claude Code (global, all projects)
git clone --depth 1 https://github.com/artamonovtech/terramaster-tos-development-skills.git "$HOME/.claude/skills/tmp-clone" && mv "$HOME/.claude/skills/tmp-clone/skills/terramaster-tos-development-skills" "$HOME/.claude/skills/terramaster-tos-development-skills" && rm -rf "$HOME/.claude/skills/tmp-clone"

# OpenCode
git clone --depth 1 https://github.com/artamonovtech/terramaster-tos-development-skills.git .opencode/skills/tmp-clone && mv .opencode/skills/tmp-clone/skills/terramaster-tos-development-skills .opencode/skills/terramaster-tos-development-skills && rm -rf .opencode/skills/tmp-clone

# Cross-agent standard (.agents/skills works with most skill-aware tools)
git clone --depth 1 https://github.com/artamonovtech/terramaster-tos-development-skills.git .agents/skills/tmp-clone && mv .agents/skills/tmp-clone/skills/terramaster-tos-development-skills .agents/skills/terramaster-tos-development-skills && rm -rf .agents/skills/tmp-clone
```

### With the install script

```bash
curl -fsSL https://raw.githubusercontent.com/artamonovtech/terramaster-tos-development-skills/main/install.sh | bash -s -- --claude
curl -fsSL https://raw.githubusercontent.com/artamonovtech/terramaster-tos-development-skills/main/install.sh | bash -s -- --opencode
curl -fsSL https://raw.githubusercontent.com/artamonovtech/terramaster-tos-development-skills/main/install.sh | bash -s -- --custom /path/you/want
```

Run `./install.sh --help` for all options.

## Update

```bash
# skills CLI
npx skills check && npx skills update

# install script
curl -fsSL https://raw.githubusercontent.com/artamonovtech/terramaster-tos-development-skills/main/install.sh | bash -s -- <your flags>
```

References are refreshed weekly by GitHub Actions, so reinstalling always gives you the latest documentation.

## What it covers

| Category | Topics |
|----------|--------|
| **Architecture** | Container-first strategy, pre-installed dependencies, ABI compatibility |
| **Packaging** | Package specification (control, config.ini, lang files), versioning, upgrades |
| **Deb apps** | Full Deb development spec, three subtypes (WebUI Internal/External, Headless), single vs dual packages |
| **Docker apps** | docker-compose.yml spec, image requirements, multi-arch |
| **Security** | Permission model (SPC), package signing, supply-chain audits |
| **Quality** | Best practices, local testing & debugging, self-testing tool |
| **Automation** | CI/CD GitHub Actions templates, Agent API |
| **Publishing** | Developer platform submission, review standards, rejection reasons, operations & delisting |
| **Reference** | App categories, system ports, TOS directories, systemd targets |

## How it works

```
User asks about TerraMaster TOS app development
        |
        v
AI reads matching reference file from references/
        |
        v
Copies the matching template from assets/templates/ for a new app
        |
        v
Builds/validates per the guide (build.sh, self-testing tool)
```

`SKILL.md` is a routing table: it maps scenarios to chapters and templates. The `references/` files are the **full unmodified upstream docs** — not summaries.

## How references stay up to date

A [GitHub Actions workflow](.github/workflows/update-references.yml) runs weekly:

1. Sparse-clones `terramaster-tos/tos-app-pkg-tools` (only the documentation subtrees)
2. Copies the 20 guide chapters 1:1 into `references/` (no renaming, so inter-chapter relative links keep working and diffs stay clean)
3. Copies the Agent API and self-testing docs, and the three package templates into `assets/templates/`
4. Validates the skill (`skills-ref validate`, SKILL.md under 500 lines) and commits if upstream changed

Regenerate manually any time:

```bash
bash scripts/generate-references.sh
```

## Structure

```
terramaster-tos-development-skills/
├── SKILL.md                              # Skill instructions and routing table
├── references/                           # Upstream docs, copied 1:1
│   ├── .source-version                   # Upstream commit tracker
│   ├── 01_Overview.md … 20_Appendix.md   # Guide chapters (original names)
│   ├── agent-api.md                      # Developer platform REST API
│   └── self-testing.md                   # Self-testing tool guide
├── assets/templates/                     # Official package templates, verbatim
│   ├── deb-single/
│   ├── deb-dual/
│   └── docker/
├── install.sh                            # Multi-tool install script
├── scripts/
│   └── generate-references.sh            # Fetches upstream docs and regenerates
└── .github/workflows/
    └── update-references.yml             # Weekly auto-update from upstream
```

## Compatibility

Built on the SKILL.md skill format used by [skills.sh](https://skills.sh). Install into whichever directory your tool reads:

| Tool | Install path |
|------|-------------|
| **Cross-agent standard** | `.agents/skills/terramaster-tos-development-skills` |
| Claude Code (global) | `~/.claude/skills/terramaster-tos-development-skills` |
| Claude Code (project) | `.claude/skills/terramaster-tos-development-skills` |
| OpenCode | `.opencode/skills/terramaster-tos-development-skills` |
| Cursor | `.cursor/skills/terramaster-tos-development-skills` |
| Windsurf | `.windsurf/skills/terramaster-tos-development-skills` |
| GitHub Copilot / VS Code | `.github/skills/terramaster-tos-development-skills` |
| Gemini CLI | `.gemini/skills/terramaster-tos-development-skills` |
| OpenAI Codex | `.agents/skills/terramaster-tos-development-skills` |
| Cline | `.cline/skills/terramaster-tos-development-skills` |
| Aider | `.aider/skills/terramaster-tos-development-skills` |
| Goose | `.goose/skills/terramaster-tos-development-skills` |
| Roo Code | `.roo/skills/terramaster-tos-development-skills` |

For tools not listed, use the skills CLI (`npx skills add artamonovtech/terramaster-tos-development-skills`) — it supports [75+ agents](https://github.com/vercel-labs/skills/blob/main/docs/agents.md).

## Examples

```
> Create a TOS 7 Deb app template for my media server tool
> What goes into config.ini vs DEBIAN/control for a TOS app?
> How do I package a Python app for TerraMaster NAS?
> My Docker app needs Node.js — how do I structure the TOS package?
> How do I submit my app to the TOS App Center and pass review?
> Add a GitHub Actions workflow that builds my TOS deb package
> Validate my TOS package with the self-testing tool before submitting
```

## Credits

- [TerraMaster](https://www.terra-master.com/) — [tos-app-pkg-tools](https://github.com/terramaster-tos/tos-app-pkg-tools) documentation and templates
- [skills.sh](https://skills.sh) — skills directory and discovery
- [vercel-labs/skills](https://github.com/vercel-labs/skills) — skills CLI

## License

MIT — see [LICENSE](LICENSE). The referenced documentation and templates belong to their respective upstream authors.
