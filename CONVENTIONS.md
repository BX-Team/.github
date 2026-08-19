# BX Team repository conventions

What every BX Team repository looks like, and where the shared pieces live. This
file is the standard: when a repository and this document disagree, the
repository is what needs fixing.

## What a repository contains

```
├── .github/
│   ├── branding/                    # logo.png, preview.png, screenshots
│   ├── changelog_configuration.json # from templates/, one URL changed
│   ├── PULL_REQUEST_TEMPLATE.md     # the org shape + this project's checklist
│   └── workflows/
│       ├── ci.yml                   # push to master → does it still build
│       ├── pr-check.yml             # pull request → the full check
│       └── release.yml              # workflow_dispatch → ship a version
├── CLAUDE.md                        # the real instructions
├── AGENTS.md                        # a symlink to CLAUDE.md, never a copy
├── README.md
├── LICENSE
└── renovate.json                    # four lines, extending an org preset
```

`CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md` and the issue forms are **not**
copied into a repository. This repository serves them org-wide; a local copy
overrides the shared one and then drifts. Add one only where the project needs to
say something genuinely different — explaining its own toolchain is the usual
reason.

The pull request template is the one health file meant to live locally. The
workflows are local too, for a different reason. Both are below.

Not every piece applies to every project. Each section says where it may be left
out; when it is, that is a decision to state in the pull request that makes it.

## Renovate

The presets live in [`renovate/`](renovate). A repository's whole configuration
is an `extends`:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["github>BX-Team/.github//renovate/go"]
}
```

`//renovate/go` is Renovate's sub-directory syntax for `renovate/go.json` here.

| Preset | Enables |
| ------ | ------- |
| [`renovate/default.json`](renovate/default.json) | github-actions, nix — the base every preset extends; never extend it directly |
| [`renovate/go.json`](renovate/go.json) | gomod (+ `gomodTidy`, the `go` directive pinned) |
| [`renovate/rust.json`](renovate/rust.json) | cargo |
| [`renovate/gradle.json`](renovate/gradle.json) | gradle, gradle-wrapper (no `-SNAPSHOT`) |
| [`renovate/node.json`](renovate/node.json) | npm (minor automerged too) |

Policy in one line: patch bumps automerge once CI is green, everything else waits
for a human, dependencies are grouped per ecosystem so one PR moves a whole
lockfile, and every PR carries `🔄 dependencies`.

Every preset enables the `nix` manager — without a `flake.lock` it finds nothing,
so the presets stay uniform.

`github-actions` is enabled everywhere too, and because actions are pinned to a
major tag it has correspondingly little to raise: patch and minor releases arrive
by themselves when the maintainer moves the tag, and Renovate only opens a pull
request when a new major appears. That is the trade being made. Pinning to a
commit SHA would close the mutable-tag hole, at the cost of a pull request per
action per release and a diff no reviewer can read; a major tag from a first-party
or widely-used action is judged good enough, and what is worth a human look — the
major bump, where a step's inputs change — is exactly what still reaches the
review queue.

A repository may pin a few dependencies on top of its preset, typically for a
compatibility floor. One whose dependencies are not managed from a manifest at all
has no `renovate.json`.

## Workflows

Three files, always these names, and **every repository owns its own copy**:

| File | Trigger | The question it answers |
| ---- | ------- | ----------------------- |
| `ci.yml` | push to `master` | Does `master` still build? |
| `pr-check.yml` | `pull_request` | Is this change good — build, tests, lint, formatting? |
| `release.yml` | `workflow_dispatch` | Ship a version. |

Anything else is a further file named after the job it does.

**What is standardised is the contract, not the bytes.** Which files exist, which
question each one answers, and the style rules below — there is no shared
`build.yml`, no reusable workflow called across repositories, and nothing here
that a project's CI reaches for at run time. Two ecosystems share nothing past the
checkout, so a file both could use would be mostly `if:` conditions, and each of
those is somewhere the two paths can quietly diverge. Local copies mean one
project's CI change is one pull request, a bad edit cannot break every repository
at once, and the duplication that remains is accepted. Keep the files *readable*
rather than clever, so the next person can diff two of them by eye.

### `ci.yml` — the push side

Push to `master`, and it asks one question: **does the thing still build.** No
artifacts, no uploads. It exists to catch the semantic merge conflict that two
individually-green branches produce once one lands on top of the other.

```yaml
name: CI

on:
  push:
    branches: ["master"]

permissions: {}

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

Keep it to the build. Tests that run in seconds can stay; a `ci.yml` that has
grown into a second copy of `pr-check.yml` has stopped earning its runtime.

Leave it out where the push-side build is expensive enough — a cold cache, a
Windows runner, a system dependency install — that it only repeats what the pull
request answered minutes earlier. Add one the first time a semantic merge conflict
actually breaks `master`.

### `pr-check.yml` — the pull request side

`pull_request`, and it runs the lot: formatting, lint, tests, build matrix. This
is the run branch protection is set against.

```yaml
on:
  pull_request:
    # `labeled` so that adding the label to an open pull request starts a run.
    types: [opened, synchronize, reopened, labeled]
    branches: ["master"]
```

`labeled` fires on **any** label, not just the artifact one — putting
`🔄 dependencies` or `🐛 bug` on an open pull request starts a fresh run too. That
is the price of being able to get a build without pushing an empty commit, and the
`concurrency` group keeps it to one run at a time. Triage a pull request before
you open it, or expect the extra run.

Artifacts are opt-in on the `📦 upload artifacts` label. Without it the build
still runs and only the upload is skipped, so nothing a reviewer relies on
changes:

```yaml
      - name: Upload the build
        if: contains(github.event.pull_request.labels.*.name, '📦 upload artifacts')
        uses: actions/upload-artifact@v7
        with:
          name: <PROJECT>-<platform>
          path: dist/<file>
          if-no-files-found: error
          retention-days: 7
```

The label is the whole mechanism — no comment bot, no reusable workflow.
`retention-days: 7` always; these are throwaway builds and a stale one is worse
than none. Where the version is stamped into the binary, a pull request stamps a
dev version — `<base>-dev.pr<number>.<short sha>` — so a build can never be
mistaken for a release.

Drop the `if:` and upload unconditionally where the build *is* what a reporter
downloads to reproduce a bug against; making them get a label onto someone else's
pull request first defeats the point.

### How a workflow file is written

These rules apply to *every* workflow in the organization, including the
project-specific ones nothing here covers:

- **Every step has a `name`.** No exceptions, not even a one-line `run`. The
  Actions UI is a list of step names, and an unnamed step shows up as its own
  shell script — unreadable in a failed run.
- Step names are imperative: `Check out the repository`, `Build the release
  binary`. Not `checkout`, not `build`.
- **One blank line between steps**, and between a job's `steps:` block and the
  next job.
- Every `job` has a `name`, and a matrix job's name interpolates the matrix
  (`Build (${{ matrix.name }})`) so the check list is legible.
- `permissions: {}` at the top of the file, with each job requesting exactly what
  it needs. `persist-credentials: false` on every checkout that does not push.
- **A `concurrency` group on every workflow**, keyed on what a second run would be
  superseding. `ci.yml` keys on `github.ref`; `pr-check.yml` keys on the pull
  request, where it matters most — a push-on-push, or a label added mid-run, would
  otherwise leave two full matrices racing:

  ```yaml
  concurrency:
    group: pr-check-${{ github.event.pull_request.number || github.ref }}
    cancel-in-progress: true
  ```

  The `|| github.ref` fallback matters: `github.event.pull_request.number` is
  empty on any event that is not a pull request, and an empty key would put every
  such run in one group where they cancel each other.

  `release.yml` gets a group too, and **never** `cancel-in-progress: true`. A
  half-cancelled release has already pushed a tag.
- Values from a workflow input or a step output go through `env:` and are read as
  `"$VAR"` inside `run:`, never interpolated into the script body.
- Actions are pinned to a major, never a patch: `actions/checkout@v7`,
  `actions/setup-*@v5`/`v7`, `actions/upload-artifact@v7`. A major tag is mutable,
  so this is deliberately *not* the strongest option — see
  [Renovate](#renovate) for why we take it anyway.
- **No `summary` job.** A trailing job restating `toJSON(needs.*.result)` buys a
  runner and a second place for the asset list to go stale, while the job list at
  the top of the run page already says it in colour. What was worth keeping is one
  line at the end of the job that did the work — `publish` writes the release body
  to `$GITHUB_STEP_SUMMARY` on its way out.
- **A `gate` job in `pr-check.yml` is the one exception**, and it is required
  rather than merely allowed — see [Branch protection](#branch-protection). It
  reports nothing to a human; it exists so branch protection has one check name
  that survives a change to the build matrix.

### The `nix` job

Where a repository has a `flake.nix`, **`pr-check.yml`** carries a `nix` job
running `nix build .#<project>`. Not `ci.yml` — a broken flake is worth catching
before the merge, and the push side is deliberately the cheap one.

It catches the change that updated the build and forgot `flake.nix`: a new runtime
dependency, a renamed binary, a Go `vendorHash` left stale by an edit to `go.mod`.
None of those fail any other check.

Never make it conditional — a skipped job can never satisfy a required check, so
automerge would wait on it forever.

Without a flake the job is a block to delete. Drop it too where a Nix build means
a full from-source rebuild with no cache on every pull request and the flake is
already exercised on every release; add it back the first time the flake breaks
between releases.

### A repository can have no workflows at all

Where a hosting platform builds every pull request and reports that build back to
GitHub as a check, a workflow running the same install and build is a slower
duplicate. The platform's check is the required one there.

### Never upload a `.zip` with `archive: false`

`upload-artifact` with `archive: false` stores the file as the artifact blob
itself, and `download-artifact` cannot tell that blob apart from the zip it
normally wraps an artifact in — so it **unzips it**, and the file you uploaded is
replaced by its contents. A `.tar.gz`, `.deb`, `.rpm`, `.pkg.tar.xz` or `.exe`
survives this; only a `.zip` does not, and it fails silently.

So: `archive: false` for everything except a `.zip`. For a `.zip`, drop the line
and let upload-artifact archive it, and name the artifact without the `.zip`
suffix.

## Releases

`workflow_dispatch` with a `version` input, never a tag push:

```
prepare  → validate the version as semver, refuse a tag that already exists,
           find the previous tag
<checks> → the same jobs pr-check.yml runs, copied in — a release must not be
           the first place they run
tag      → write the version into every manifest that duplicates it, commit,
           push the tag, open the release as a draft
build    → build from the tagged commit, never from the branch head, and upload
           each asset straight onto the draft
cachix   → push the flake package; delete where there is no flake.nix
publish  → verify every expected asset is attached, compose the notes, un-draft
```

The checks are **copied** in rather than called: a release must not be able to
start from an unverified tree, and a `workflow_call` back into `pr-check.yml`
would run it under an event where `github.event.pull_request` is null.

Where there is a flake, `cachix` pushes the package to the `bx-team` cache on
every non-prerelease.

### Assets go straight onto the draft

The draft exists before the build matrix starts, so each job uploads its own files
as it finishes and there is nothing to hand between jobs:

```yaml
      - name: Upload the assets to the draft release
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          TAG: ${{ needs.prepare.outputs.tag }}
        shell: bash
        run: gh release upload "$TAG" dist/* --clobber
```

`--clobber` so re-running one leg of the matrix replaces its assets instead of
failing on a name already there. This is why the release path has no
`upload-artifact` anywhere: an artifact was only ever the courier between `build`
and `publish`, and a draft release does that job in the place the files are going
anyway — without mangling a `.zip` on the way.

`publish` is the gate. It lists what is actually attached and refuses to un-draft
on a gap, so a half-finished matrix cannot ship a partial release:

```yaml
      - name: Verify the release assets
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          TAG: ${{ needs.prepare.outputs.tag }}
        shell: bash
        run: |
          have="$(gh release view "$TAG" --json assets --jq '.assets[].name')"
          printf '%s\n' "$have"   # the next question is always what *did* arrive
          for asset in "<PROJECT>-x86_64-linux.tar.gz" "…"; do
            printf '%s\n' "$have" | grep -qxF "$asset" || {
              echo "::error::missing release asset '$asset'"
              exit 1
            }
          done
```

A failed run leaves the draft behind deliberately — the tag is already pushed, so
the draft is the record of what did get built, and discarding it is one click.
`prepare` refuses the same version twice, so a retry is a new patch version.

Two shapes are allowed to differ. Where one build job produces one artefact for
several destinations, keeping the publishes together in that job is right and the
draft buys nothing. And where releases are driven by another platform — a manifest
exported and shipped to a distribution site that then creates the GitHub release,
with the version coming from the project's own manifest — that project keeps its
own workflow. Both still follow the style rules.

### Release notes

Generated by `mikepenz/release-changelog-builder-action` in `COMMIT` mode from
[`changelog_configuration.json`](templates/changelog_configuration.json). This is
why commit titles must be Conventional Commits — see
[CONTRIBUTING.md](CONTRIBUTING.md).

The dispatch form also takes an optional `description`, because a generated list
of commits says what changed and never what the release is *about*. Leave it empty
and the generated sections stay the top-level outline; fill it in and they are
demoted to `###` under the summary, so the release has one outline instead of a
paragraph competing with a list of headings.

Three mechanics worth knowing before you copy the step:

- **Use `\n` for a line break.** GitHub renders a `workflow_dispatch` string input
  as a single-line box, so `printf '%b'` is what turns a typed `\n` into a real
  newline. The cost is that a literal backslash is read as an escape.
- The demotion is `sed 's/^## /### /'` over the generated changelog. Safe because
  only category titles start a line with `## ` — commit lines start with `- `.
- The composed body goes to the release through `body_path:`, not `body:`.
  Multi-line Markdown through a step output is where this breaks otherwise.

## CLAUDE.md and AGENTS.md

`CLAUDE.md` holds the instructions. `AGENTS.md` is a **symlink** to it:

```bash
ln -s CLAUDE.md AGENTS.md
git add AGENTS.md
git ls-files -s AGENTS.md   # mode 120000 is a symlink; 100644 means you copied it
```

Git stores the symlink and GitHub renders `AGENTS.md` as a single blue link to
`CLAUDE.md`, so there is one file to keep current and the two cannot drift. A
Windows clone without `core.symlinks` checks it out as a one-line text file — a
local quirk; what the repository stores, and what GitHub and every agent see, is
still the link.

Section order, from [`templates/CLAUDE.md`](templates/CLAUDE.md): a one-paragraph
summary, **Architecture** (prose, a package table, and where they exist the
settled decisions), **Commands**, **Code Guidelines** (Comments, Style, the
language of user-facing strings, domain gotchas, Testing), **Bash Guidelines**.
The Comments and Bash Guidelines blocks are shared text — copy them verbatim.

What earns a place is what an agent cannot learn from the code in a minute: why
the architecture has the shape it does, which arguments are already closed, and
the traps that have already cost someone an afternoon.

A repository with no source to have conventions about — a manifest, a set of
assets — has neither file.

## README

Structure and the header rules are in [`templates/README.md`](templates/README.md).
In short: one centred block above the fold with the logo, the name, one paragraph
of pitch and the devins-badges cozy badges; then the emoji sections in a fixed
order — 🖼️ Preview, ⚙️ Features (or 🔥 Why), 📦 Installation, ❄️ Nix, 🚀 Getting
started, 🧪 API, 🔨 Build from source, 🤝 Contributing, ⚖️ License, 💛 Credits.
Drop what does not apply; do not reorder. ❄️ Nix only exists where there is a
flake.

The license badge belongs in the header block. `## ⚖️ License ![Static Badge](…)`
is the old style and is being removed.

## Pull request template

GitHub applies exactly **one** pull request template: a repository's
`.github/PULL_REQUEST_TEMPLATE.md` replaces the org default outright rather than
adding to it, so a local copy carries the whole shape, not just its own checklist.

[`PULL_REQUEST_TEMPLATE.md`](PULL_REQUEST_TEMPLATE.md) here is the org default,
served to any repository without a local one.
[`templates/PULL_REQUEST_TEMPLATE.md`](templates/PULL_REQUEST_TEMPLATE.md) holds
the shape and the rules for writing a `Things done` block — and nothing
project-specific. What a given checklist says is a decision about that repository
and is recorded there, so changing one project's checklist never means editing the
shared shape.

Write a local template only where the project has real, checkable specifics: patch
markers, locale files, a platform matrix, API compatibility. Otherwise the org
default beats a checklist padded out to look thorough.

The two rules that get broken most:

- **It is not a set of gates.** The items tell a reviewer what has been covered
  and where to look. A checklist that blocks a merge gets ticked dishonestly; one
  that informs a reviewer gets filled in honestly.
- **It does not ask a contributor to confirm the checks ran.** CI runs them on
  every push and reports the answer.

## Documentation

The documentation site lives in [BX-Team/code](https://github.com/BX-Team/code)
under `apps/meridian/content/docs/`. A project is documented either there or by
its own `README.md`. A change touching behaviour documented on the site is two
pull requests, and **each links to the other** — see
[CONTRIBUTING.md](CONTRIBUTING.md) → Documentation.

## Labels

Every label is `<emoji> <lowercase name>`. The emoji is not decoration — it is
what stays readable when the sidebar truncates the text.

The set is [`labels.json`](labels.json); apply it with
[`scripts/sync-labels.sh`](scripts/sync-labels.sh) (needs `gh` and `jq`):

```bash
./scripts/sync-labels.sh                 # dry run, every repository
./scripts/sync-labels.sh <repo> --apply  # write, one repository
```

Legacy names are **renamed**, not recreated, so every issue and PR already
carrying one keeps it. Labels the manifest does not list are reported and left
alone unless `--prune` is passed — deleting a label strips it from every issue
that had it.

Add a label to `labels.json` and re-run the script. A label created by hand in one
repository is reported as unmanaged on the next sync.

## Branch protection

Every repository's default branch carries a ruleset — repository-level, not the
classic branch protection screen, and not org-level, which needs a paid plan.
Deletions and force pushes are blocked, a pull request is required, and one status
check must pass.

**Zero required approving reviews.** A required approval on a repository with one
active maintainer means nothing can ever merge — you cannot approve your own pull
request. The gate here is CI, not a second pair of eyes; add the review requirement
the day there is someone to do the reviewing.

Organization admins keep a bypass. A ruleset that can lock you out of your own
default branch is a ruleset you will disable in a hurry at the worst moment.

### The `gate` job

Required checks are matched **by exact name, with no wildcards**, and a matrix job's
name contains its matrix values — `Build (linux/amd64)`, `Build (windows/amd64)`.
Listing those directly makes branch protection break on every matrix edit: a
removed target leaves a required check that never reports again, so pull requests
hang in *Expected* forever, and an added target is not required at all, so a broken
build merges. This is the usual reason branch protection gets switched off.

So `pr-check.yml` ends in one job with a fixed name, and that name is the only
required check:

```yaml
  gate:
    name: PR check
    if: always()
    needs: [check, build, nix]     # every job that must pass
    runs-on: ubuntu-latest
    permissions: {}
    steps:
      - name: Fail if any required job did not succeed
        env:
          RESULTS: ${{ join(needs.*.result, ' ') }}
        run: |
          printf 'upstream results: %s\n' "$RESULTS"
          case "$RESULTS" in
            *failure*|*cancelled*|*skipped*) exit 1 ;;
          esac
```

`if: always()` is what makes it run after a failed dependency — without it the job
is skipped, and a skipped required check never reports. `needs:` lists every job
that must pass; adding a job to the workflow means adding it here too, and that is
the one thing to remember when editing the file.

`skipped` counts as a failure because no job in `pr-check.yml` is conditional — a
skip means a dependency failed, not that the work was unnecessary.

Where a hosting platform already publishes a stable check name per deployment,
require those directly and skip the `gate` job; there is no matrix to hide from.

## Branches

`master` is where development lands: every pull request merges there, and it is
kept in a state that could be released at any point. It is not a mirror of the
last release — that is the release tag, and `master` is normally ahead of it.

A project that has to support several upstream versions at once keeps a branch per
version (`ver/26.2`), and its default branch moves as those versions do.
