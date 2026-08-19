<!--
  How a repository's pull request template is built. Not itself a template, and
  holds nothing project-specific — a repository's checklist is a decision about
  that repository and is recorded there, in its own `.github/`.

  The org-wide default sits at the root of this repository; GitHub serves it to
  every repository that has none of its own.
-->

## How it is put together

GitHub applies exactly **one** pull request template. A repository's
`.github/PULL_REQUEST_TEMPLATE.md` replaces the org default outright rather than
adding to it, so a local template carries the whole shape below — not just its own
checklist.

Everything is fixed except one block. Keep the leading comment, the heading, the
trailing hints and the reference links exactly as they are; swap only the
`Things done` items.

```markdown
<!--
^ Summarise what this changes and why, above this comment. ^

Title this pull request as a Conventional Commit — `feat(scope): …`, `fix: …`.
Release notes are generated from commit titles, so a title that does not parse
lands under "💬 Other" instead of its section.

If it closes an issue, write "Closes #123" so GitHub links the two.
If it changes behaviour a user can see, say what the old behaviour was.
-->

## Things done

<!-- Check what applies. These are not hard requirements — they tell a reviewer
     what you have already covered and where to look. Delete a group that has
     nothing to do with this change rather than leaving it unchecked. -->

<<< THE PER-PROJECT BLOCK GOES HERE >>>

- [ ] This pull request has one subject. A formatting sweep bundled with a fix is
      harder to review and harder to revert.
- [ ] Fits [CONTRIBUTING.md].

<!--
Want a build of this branch to review? Add the "📦 upload artifacts" label and the
PR check attaches it to its run — the Artifacts box at the bottom of the run
summary. The build runs either way; only the upload depends on the label.

Found a security issue? Do not open a pull request in the open — see [SECURITY.md].
-->

[CONTRIBUTING.md]: https://github.com/BX-Team/.github/blob/master/CONTRIBUTING.md
[SECURITY.md]: https://github.com/BX-Team/.github/blob/master/SECURITY.md
[BX-Team/code]: https://github.com/BX-Team/code
```

## Rules for the `Things done` block

- **These are not gates.** The items tell a reviewer what has already been covered
  and where to look. A checklist that blocks a merge gets ticked dishonestly; one
  that informs a reviewer gets filled in honestly. Say so in the comment above it,
  and never wire one of these boxes into a required check.
- **Never ask a contributor to confirm the checks ran.** CI runs them on every push
  and reports the answer, so a box promising the same thing costs a line and adds
  no information. This is why there is no "the commands in `CLAUDE.md` pass
  locally" item anywhere.
- **Every item has to be checkable by looking at the diff or at the running
  software.** "Follows the code style" is not checkable and gets ticked blind;
  "every modified upstream file carries its change marker" is.
- **Group with a parent bullet** (`- Tested, as applicable:`) when the items are
  alternatives or a matrix, so the list reads as a few decisions rather than a
  wall of boxes.
- **Prefer the project's own words.** Where a project already documents what it
  expects from a contribution, the checklist is a summary of that document with a
  link to it — not a second, drifting copy.
- **Not every repository needs one.** A local template earns its place where the
  project has real, checkable specifics: patch markers, locale files, a platform
  matrix, API compatibility. Where it does not, the org default is a better answer
  than a checklist padded out to look thorough.
- Keep the `[BX-Team/code]` link definition when the block has a documentation
  item and drop it otherwise. An unused reference definition is invisible in the
  rendered body; a used one that is missing renders as literal brackets.

## Where the per-project blocks live

In the repository they belong to, and nowhere else. This file stays generic so
that changing one project's checklist never means editing the shared shape, and
so that a repository without real specifics can simply have no local template and
inherit the org default.
