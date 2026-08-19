# <PROJECT>

<!--
  Sections in this order; only the two marked optional may be dropped.
  AGENTS.md is a symlink to this file, never a copy: `ln -s CLAUDE.md AGENTS.md`.

  What belongs here is what an agent cannot get from the code in a minute — why
  the architecture is the shape it is, which decisions are settled, the traps
  that already cost someone an afternoon. Not an inventory of the source tree.
-->

One paragraph: what this is, what it is built on, and the single most important
structural fact about it. Three sentences is about right — "A terminal UI for
running a Minecraft server. Go + Bubble Tea, one binary: the CLI, the TUI and the
supervising daemon all live in `cmd/<project>`."

## Architecture

A paragraph or two of prose for the thing a table cannot say — what owns what,
what talks to what, where the source of truth is. Then the table:

| Package | Responsibility |
| ------- | -------------- |
| `internal/foo` | One line. What it is *for*, not what it contains. |

### Decisions that are settled

<!-- Optional, but the most valuable section in the file when it exists. -->

Each entry is a decision that has already been argued and closed, written so that
an agent proposing the alternative reads why it was rejected. Include the cost
that was paid to learn it — the version boundary that broke a JVM, the borrow
that panicked, the palette that turned out unreadable. Facts, not preferences.

- **The daemon owns the process, not tmux.** Any "just attach to a screen
  session" idea has already been rejected.

## Commands

```bash
# The handful actually used day to day, one comment each.
```

Then, in one sentence, what CI runs and therefore what has to pass before a
commit. Name any check that is easy to forget — a cross-compile, a second OS, a
generated file that has to be regenerated.

## Code Guidelines

### Comments

<!-- Shared across the organization. Copy verbatim; adjust only the syntax. -->

- NO file-header banners and NO divider comments (`// --- helpers ---`). Group
  code with functions, not comment art.
- Add an inline comment only where the code is genuinely non-obvious — a real
  footgun, a wire-format quirk, a reason a thing is done backwards. Then keep it
  to a line or two.
- Don't narrate the obvious. If a comment restates the next line, delete it.
- Doc comments on public items are fine and should say *why*, in one or two
  sentences.

### Style

- The formatter is the source of truth — never hand-format against it.
- Match the surrounding code: follow the idiom already in the file you're editing.
- Then the project's own invariants — the one module colors must come from, the
  one writer config files must go through, the layer business logic belongs in.
  Each as a rule an agent can check itself against.

### <Language of user-facing strings>

<!-- Required whenever the answer is not obvious. English-only, Russian-only, or
     everything routed through i18n keys that must exist in every locale file —
     say which, and say what happens if you get it wrong (a missing key that
     falls back silently is the usual failure). -->

### <Domain> gotchas

The traps specific to this stack — the framework's borrow rules, the platform
split, the migration ordering. One bullet per trap, each naming the symptom, not
just the rule, so it is recognisable when it happens.

### Testing

<!-- Optional; include wherever there are tests. -->

Where tests live, what earns one, and what does not. "One test per real trap, not
one per function" is the organization's position.

## Bash Guidelines

<!-- Shared across the organization. Copy verbatim; adjust only the examples. -->

- Don't pipe output through `head`/`tail`/`less` to truncate — use tool-native
  flags (`git log -n 10`, `go test ./internal/confs`). Read the full output.
- Don't create scratch files (scripts, notes) unless asked.
- When given failures, just fix them — don't argue about who introduced them.
