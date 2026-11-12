---
name: terramaster-tos-development-skills
description: Develop, package, sign, and publish TerraMaster TOS 7 apps (DEB and Docker). Covers TOS App package structure (control, config.ini, myapp.lang), build.sh, app signing, App Center publishing, Agent API, CI/CD, and self-testing. Use when building apps for TerraMaster NAS or working with tos-app-pkg-tools templates.
license: MIT
metadata:
  author: Alexander Artamonov
  version: "1.0.0"
  source-repo: https://github.com/artamonovtech/terramaster-tos-development-skills
---

# TerraMaster TOS 7 App Development

Complete reference for developing, packaging, and publishing third-party applications for TerraMaster NAS devices running TOS 7, auto-copied unmodified from the official [terramaster-tos/tos-app-pkg-tools](https://github.com/terramaster-tos/tos-app-pkg-tools) repository (guide v2.7):

- **TOS 7 Application Development Guide** — 20 chapters (`references/01_Overview.md` … `references/20_Appendix.md`)
- **Agent API** — `references/agent-api.md` (developer platform REST API)
- **TOSAppSelfTestingTool** — `references/self-testing.md` (pre-submission package validation)
- **Package templates** — verbatim starter projects under `assets/templates/` (deb-single, deb-dual, docker)

The `references/` files are full upstream docs, not summaries. Source commit: see `references/.source-version`.

## How to Use

1. Identify the scenario from the user's request and read the matching files from the tables below. Start with the smallest sufficient set; load more only if needed.
2. Base answers strictly on these files — TOS packaging rules are specific and review-enforced; do not improvise Debian/Ubuntu conventions that contradict them.
3. When creating a new app, copy the matching template from `assets/templates/` (do not invent a layout) and adapt `config.ini`, `DEBIAN/control`, and `myapp.lang`.
4. Chapter files link to each other by relative filename (`04_Package_Specification.md`), so follow links directly within `references/`. Links pointing at `../README.md` are dead (upstream TOC); route via this file instead.

## Rules for TOS Apps

- A TOS app package is defined by three core files: `DEBIAN/control` (dpkg metadata), `config.ini` (app identity/version, read by the platform), and `<appid>.lang` (localized strings). `build.sh` assembles the package; see `references/04_Package_Specification.md`.
- Keep `config.ini` `version` and `DEBIAN/control` `Version` consistent; the control `Version` must never decrease (dpkg downgrade protection). Use the `"beta": true` field in `config.ini` for beta builds — never a `-beta`/`-rc` version suffix.
- Respect the container-first architecture: Node.js, Java, Go runtimes are **not** pre-installed on TOS — a Deb app must not depend on them; use Docker apps for such stacks. Declare only pre-installed dependencies; see ABI compatibility in `references/05_ABI_Compatibility.md`.
- Deb apps choose one of three subtypes (WebUI Internal / WebUI External / Headless); subtype and single-vs-dual packaging are independent dimensions.
- Docker apps ship as a `.tar.gz` with `docker-compose.yml` per `references/09_Docker_Development.md`; multi-arch images must cover the target architectures in `references/06_Development_Environment.md`.
- Before submitting for review, validate the package with the self-testing tool (`references/self-testing.md`, `-c/--check`) and re-check the one-vote-veto list in `references/16_Review_Standards.md`.

## Reference Files

### Guide Chapters

| # | Topic | File |
|---|-------|------|
| 1 | Overview (platform, app types) | **`references/01_Overview.md`** |
| 2 | Architecture strategy (container-first, pre-installed deps) | **`references/02_Architecture_Strategy.md`** |
| 3 | Quick start (first app in 5 steps) | **`references/03_Quick_Start.md`** |
| 4 | Package specification (control, config.ini, lang, versions, upgrades) | **`references/04_Package_Specification.md`** |
| 5 | ABI compatibility (declaring runtime dependencies) | **`references/05_ABI_Compatibility.md`** |
| 6 | Development environment (Ubuntu 22.04, toolchain, architectures) | **`references/06_Development_Environment.md`** |
| 7 | Application types (Deb subtypes, Docker) | **`references/07_Application_Types.md`** |
| 8 | Deb development (full packaging spec, config.ini reference) | **`references/08_Deb_Development.md`** |
| 9 | Docker development (docker-compose.yml spec, image requirements) | **`references/09_Docker_Development.md`** |
| 10 | Permission model (SPC, users/groups, filesystem, network) | **`references/10_Permission_Model.md`** |
| 11 | Package signing security (integrity, publisher trust, audits) | **`references/11_Package_Signing.md`** |
| 12 | Best practices (directory layout, persistence, logging) | **`references/12_Best_Practices.md`** |
| 13 | Local testing & debugging (install, logs, service checks) | **`references/13_Local_Testing.md`** |
| 14 | CI/CD guide (GitHub Actions build workflows, multi-arch) | **`references/14_CICD_Guide.md`** |
| 15 | Publishing process (developer platform submission) | **`references/15_Publishing_Process.md`** |
| 16 | Review standards (validation, rejection reasons, veto items) | **`references/16_Review_Standards.md`** |
| 17 | Operations & delisting (rollback, delisting, maintenance) | **`references/17_Operations_Delisting.md`** |
| 18 | Commercialization & donations | **`references/18_Commercialization_Donations.md`** |
| 19 | FAQ (review, technical, installation) | **`references/19_FAQ.md`** |
| 20 | Appendix (app categories, system ports, TOS directories, systemd targets) | **`references/20_Appendix.md`** |

### Standalone Documentation

| Topic | File |
|-------|------|
| Agent API (developer platform REST: auth, tokens, endpoints) | **`references/agent-api.md`** |
| Self-testing tool (download, `-c/--check`, `-i/--install`, exit codes) | **`references/self-testing.md`** |

### Package Templates (`assets/templates/`)

| Template | Use when | Files of interest |
|----------|----------|-------------------|
| `assets/templates/deb-single/` | New Deb app from scratch, single package | `build.sh`, `config.ini`, `DEBIAN/control`, `myapp.lang`, `init.d/myapp.service` |
| `assets/templates/deb-dual/` | Deb app wrapping an existing universal deb (data + source packages) | `build.sh`, `data-pkg/DEBIAN/control`, `data-pkg/config.ini`, `source-pkg/init.d/myapp.service` |
| `assets/templates/docker/` | Docker app, containerized deployment | `docker-compose.yml`, `config.ini`, `myapp-docker.lang` |

## Routing by Scenario

| Scenario | Read |
|----------|------|
| First TOS app / how publishing works end-to-end | `references/03_Quick_Start.md`, `references/02_Architecture_Strategy.md` |
| Package layout, versioning, upgrade rules | `references/04_Package_Specification.md` |
| Build a Deb app (any subtype) | `references/08_Deb_Development.md` + `assets/templates/deb-single/` or `assets/templates/deb-dual/` |
| Build a Docker app | `references/09_Docker_Development.md` + `assets/templates/docker/` |
| Permissions, users, network access | `references/10_Permission_Model.md` |
| Signing and supply-chain security | `references/11_Package_Signing.md` |
| Logging, data persistence, layout conventions | `references/12_Best_Practices.md` |
| Debugging on device / locally | `references/13_Local_Testing.md`, `references/19_FAQ.md` |
| GitHub Actions build & release automation | `references/14_CICD_Guide.md` |
| Submit to App Center / prepare for review | `references/15_Publishing_Process.md`, `references/16_Review_Standards.md` |
| Automate via API (tokens, uploads) | `references/agent-api.md` |
| Validate a package before submission | `references/self-testing.md`, `references/16_Review_Standards.md` |
| Ports, TOS directories, systemd targets, categories | `references/20_Appendix.md` |

## Live Fetching

Reference files may lag upstream. To fetch the latest version of any file:

```
https://raw.githubusercontent.com/terramaster-tos/tos-app-pkg-tools/main/<path>
```

For example: `TOS 7 Application Development Guide/04_Package_Specification.md` (URL-encode the spaces as `%20`), `Developer/agent-api/README.md`, `TOSAppSelfTestingTool/README.md`.

Templates are also published as GitHub template repositories under the [app-pkg-tools](https://github.com/terramaster-tos/tos-app-pkg-tools) repository (formerly `TerraMasterOfficial/app-pkg-tools`); clone or "Use this template" from there when starting a standalone project.
