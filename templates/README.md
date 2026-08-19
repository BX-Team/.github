<!--
  Drop a section that does not apply rather than reordering, and keep the emoji —
  they are what makes a long README skimmable on mobile.

  Above the fold: one centred <div>, a 128×128 logo from .github/branding/, one
  paragraph of pitch (what it is and who it is for, not a feature list), and the
  devins-badges cozy set. The license badge belongs there too, never appended to
  the ## License heading.
-->

<div align="center">

<img src=".github/branding/logo.png" width="128" height="128" alt="<PROJECT> logo" />

# <PROJECT>

One paragraph. What it is, what it is built on, and the one thing that makes it
worth a reader's attention.

[![Chat on Discord](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/social/discord-plural_vector.svg)](https://discord.gg/qNyybSSPm5)
[![github](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/available/github_vector.svg)](https://github.com/BX-Team/<PROJECT>)

</div>

## 🖼️ Preview

Screenshots from `.github/branding/`, each under a line saying what it shows.
Skip the section entirely for a library.

## ⚙️ Features

Either a bulleted feature list (`## ⚙️ Features`) or a short argued case for the
project (`## 🔥 Why`). Pick one, not both.

## 📦 Installation

Per platform, in the order most users will need: the one-line installer, the
package managers, then the manual download. Name the actual asset filenames so a
reader can match them against the releases page.

## ❄️ Nix

Only for a repository that actually ships a `flake.nix` — most do not, and an
empty Nix section is worse than none. Where there is one: `nix run`, the flake
input, adding the package,
the NixOS module if there is one, and the Cachix substituter block:

```nix
nix = {
  settings = {
    substituters = [
      "https://bx-team.cachix.org"
    ];
    trusted-public-keys = [
      "bx-team.cachix.org-1:tnGNc1rsS8QOav+VGxXCZzf/Y0/SGchOwVCCBA/eG6E="
    ];
  };
};
```

## 🚀 Getting started

The shortest path from installed to working, then the command or configuration
reference as a table.

## 🧪 API

For a library: the repository, then the dependency snippet, Maven and Gradle both.

## 🔨 Build from source

The toolchain floor in one sentence, then the clone-and-build block, then the
`nix develop` alternative where there is a flake.

## 🤝 Contributing

One paragraph pointing at CONTRIBUTING.md, or — where there is none — naming the
checks CI runs so a contributor can run them first.

## ⚖️ License

This project is licensed under the <NAME> License — see the [LICENSE](LICENSE) file for details.

## 💛 Credits

The upstreams and the projects this was built on or learned from, one line each,
linked.
