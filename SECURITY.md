# Security Policy

## Supported versions

Only the latest release of a project receives security fixes. For projects that
track an upstream Minecraft version — [DivineMC](https://github.com/BX-Team/DivineMC)
in particular — support follows the versions the upstream still supports; older
branches are marked `🚫 unsupported` and will not receive fixes.

## Reporting a vulnerability

**Do not open a public issue, and do not post it in Discord.** A report in the
open is a disclosure, and it reaches operators of affected servers last.

Use GitHub's private reporting instead: go to the repository's **Security** tab →
**Report a vulnerability**. It is private to the maintainers and gives us a place
to co-ordinate a fix and a release with you.

If private reporting is not enabled on the repository in question, mail
**security@bxteam.org** with `SECURITY` in the subject.

Please include:

- which project and version, and the platform it runs on;
- what an attacker gains — the impact is what decides how fast this moves;
- the steps to reproduce it, and a proof of concept if you have one;
- anything you already know about a fix or a workaround.

## What to expect

- We aim to acknowledge a report within 72 hours.
- We will tell you whether we consider it a vulnerability, and if so our
  assessment of the severity and the intended timeline.
- We will keep you updated as the fix progresses, and credit you in the release
  notes unless you would rather we did not.
- Please give us a reasonable window to ship a fix before disclosing publicly.

We do not run a paid bug bounty. We are grateful anyway.
