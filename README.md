<div align="center">

# .github

Organization-wide configuration for [BX Team](https://github.com/BX-Team) — the
shared conventions, the Renovate presets, the label set, and the community health
files GitHub serves to every repository that does not ship its own.

[![Chat on Discord](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/social/discord-plural_vector.svg)](https://discord.gg/qNyybSSPm5)
[![documentation](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/documentation/website_vector.svg)](https://bxteam.org)

</div>

## 📖 Start here

**[CONVENTIONS.md](CONVENTIONS.md)** — what every BX Team repository looks like,
what it is allowed to leave out, and why.

## 📂 What is in here

| Path | What it does |
| ---- | ------------ |
| [`CONVENTIONS.md`](CONVENTIONS.md) | The standard itself |
| [`renovate/`](renovate) | Renovate presets — repositories `extends` these instead of carrying a config |
| [`labels.json`](labels.json) + [`scripts/sync-labels.sh`](scripts/sync-labels.sh) | The label set and the script that applies it |
| [`templates/`](templates) | Files a repository copies once — `CLAUDE.md`, `AGENTS.md`, `README.md`, the per-project PR template, changelog config |
| `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/` | Served by GitHub to every repository without its own copy — do not duplicate them downstream |
| [`profile/README.md`](profile/README.md) | The organization profile page |

## 🏷️ Applying the labels

```bash
./scripts/sync-labels.sh                 # dry run over every repository in labels.json
./scripts/sync-labels.sh irori --apply   # write one repository
./scripts/sync-labels.sh --apply         # write all of them
```

Needs `gh` (authenticated, `repo` scope) and `jq`. Legacy names are renamed rather
than recreated, so nothing loses a label it already had.

## 🔄 Using the Renovate presets

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["github>BX-Team/.github//renovate/rust"]
}
```

The `//` is Renovate's sub-directory syntax — `//renovate/rust` is
[`renovate/rust.json`](renovate/rust.json). Changing a preset here changes the
policy in every repository at once, which is the point. Test a change on one
repository's branch before merging it.

## 📦 Getting artifacts from a pull request

Add the `📦 upload artifacts` label and re-run — or just add it, the workflows
trigger on `labeled` too. The build attaches itself to the run and the files are on
the run page. Without the label the build still runs; only the upload is skipped.

Workflows themselves are **not** shared from here. Every repository owns its
`ci.yml`, `pr-check.yml` and `release.yml`, and nothing in this repository is
called at CI run time — see [CONVENTIONS.md → Workflows](CONVENTIONS.md#workflows)
for why.

## ⚖️ License

The templates and configuration here are provided as-is for BX Team projects. Each
project carries its own license.
