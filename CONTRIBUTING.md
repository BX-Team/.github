# Contributing to BX Team projects

Thanks for taking the time. This is the organization-wide policy — GitHub shows it
in every BX Team repository that does not ship its own `CONTRIBUTING.md`.

A repository that needs to explain its own toolchain (how to run it, what to
install first) should add a `CONTRIBUTING.md` of its own. It overrides this file
entirely, so copy the conventions below into it rather than only describing the
build.

Before starting anything substantial, raise it on our
[Discord](https://discord.gg/qNyybSSPm5) or in an issue. It is a much cheaper
place to find out that a design has already been tried than a finished pull
request.

## Commit convention

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
This is not cosmetic: release notes are generated from commit titles, and a title
that does not parse lands in **💬 Other** instead of its section.

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

`<type>` is one of:

| Type | Use it for |
| ---- | ---------- |
| `feat` | A new feature |
| `fix` | A bug fix |
| `perf` | A change that improves performance |
| `refactor` | A change that neither fixes a bug nor adds a feature |
| `docs` | Documentation only |
| `style` | Formatting and whitespace, no change in meaning |
| `build` | Build system, packaging or dependencies |
| `ci` | Workflows and automation |
| `chore` | Anything else that leaves the source alone |
| `revert` | Reverts an earlier commit |

```
feat(daemon): keep the server running after the TUI closes
```

## Pull requests

- `master` is the source of truth: it is where every change lands, and it is kept
  releasable. The latest stable release is its tag, not the branch head.
- Say what changed and why. If it closes an issue, reference it.
- Run what CI runs before you open it. Every repository's `CLAUDE.md` lists the
  exact commands under **Commands**; that list is the contract.
- Keep the pull request to one subject. A formatting sweep bundled with a fix
  makes both harder to review and to revert.
- Add the `📦 upload artifacts` label if you want CI to attach a build of your
  branch. A bot then comments with a table of downloads — useful for anything a
  reviewer would rather run than read.
- Once it is merged you are added to the project's contributors automatically.

## Automation and AI

Use whatever tools you like — but every contribution needs a **responsible person
in the loop** who understands it, has reviewed it before submission, and can answer
questions about it. That covers code, documentation, commit messages, pull request
descriptions and reviews, issue reports, and Discord messages.

- **You are accountable for it.** Read and understand the output before you submit
  it, and make sure it is licensed compatibly and credited. Vibe coding — shipping
  what a model produced without reviewing it — is not accepted, and neither is
  answering review feedback by forwarding it back to a model.
- **Disclose it.** Non-trivial use of an LLM in a commit goes in an `Assisted-by:`
  Git trailer naming the tool and the model:

  ```
  Assisted-by: Claude Code (claude-opus-5)
  ```

  `Co-authored-by:` does not satisfy this. For anything else — a pull request
  description, a review comment, generated documentation — say so in plain words,
  separately from the commits.

Not covered: your editor's autocomplete and formatters, deterministic refactoring
tools, and using a model for research, debugging or testing when little of its
output ends up in the contribution. A draft pull request is exempt from full
self-review until you mark it ready.

If you think someone has skipped this, ask politely and point them here — assume
good faith, it is far more often an oversight than a choice. Repeatedly ignoring
it is treated the same as any other way of wasting reviewers' time.

## Documentation

The documentation site is a separate repository:
[BX-Team/code](https://github.com/BX-Team/code), under
`apps/meridian/content/docs/`. So a change that alters documented behaviour is
two pull requests — the code in the project's own repository, and the docs there.

**Link them to each other.** Paste the docs pull request's URL into the code one
and the code pull request's URL into the docs one. Two unlinked pull requests in
two repositories get reviewed and merged at different times, and the docs half is
the one that gets forgotten; a pair of links is what makes it obvious that
merging one without the other ships a lie.

Projects documented on the site today: DivineMC, NDailyRewards and Quark.
Everything else is documented by its own `README.md`, and that is a single pull
request in the project's repository.

## Labels

Labels are uniform across the organization and every name carries an emoji
(`🐛 bug`, `📝 documentation`, `❌ duplicate`). The set lives in
[`labels.json`](https://github.com/BX-Team/.github/blob/master/labels.json) and is
applied with
[`scripts/sync-labels.sh`](https://github.com/BX-Team/.github/blob/master/scripts/sync-labels.sh)
— add a label there, not by hand in one repository, or the next sync will flag it
as unmanaged.

## Reporting a vulnerability

Do not open an issue. See
[SECURITY.md](https://github.com/BX-Team/.github/blob/master/SECURITY.md).
