<p align="center">
  <img src="assets/readme-banner.svg" alt="Nix software index — direct repository installs" width="100%">
</p>

<p align="center">
  Direct Nix commands for the maintained repositories. This repository is documentation only and is not a Flake or package mirror.
</p>

## Why direct repositories?

Every project owns its package, checks, Flake outputs, and optional NixOS modules. A commit on a project's default branch is therefore available directly without waiting for a second catalog repository to update a lock file.

The only local command needed to refresh installed profile packages is:

```bash
nix profile upgrade --all --refresh
```

## Packages

| Package | Repository | Run directly |
|---|---|---|
| TwintailLauncher | [`madebycli/twintail-nix`](https://github.com/madebycli/twintail-nix) | `nix run github:madebycli/twintail-nix#twintaillauncher` |
| Helium | [`madebycli/helium-nix`](https://github.com/madebycli/helium-nix) | `nix run github:madebycli/helium-nix#helium` |
| Sakura | [`madebycli/sakura`](https://github.com/madebycli/sakura) | `nix run github:madebycli/sakura#sakura` |
| Pipes | [`madebycli/Pipes`](https://github.com/madebycli/Pipes) | `nix run github:madebycli/Pipes#pipes` |
| GIF Player | [`madebycli/GIF-Player`](https://github.com/madebycli/GIF-Player) | `nix run github:madebycli/GIF-Player#gif-player` |
| GitHub Backup Deck | [`madebycli/git-backup`](https://github.com/madebycli/git-backup) | `nix run github:madebycli/git-backup#github-backup-deck` |

## Install into a Nix profile

Install any or all packages directly from their own repositories:

```bash
nix profile add github:madebycli/twintail-nix#twintaillauncher
nix profile add github:madebycli/helium-nix#helium
nix profile add github:madebycli/sakura#sakura
nix profile add github:madebycli/Pipes#pipes
nix profile add github:madebycli/GIF-Player#gif-player
nix profile add github:madebycli/git-backup#github-backup-deck
```

Refresh every installed profile package:

```bash
nix profile upgrade --all --refresh
```

Inspect or remove profile entries:

```bash
nix profile list
nix profile remove <profile-name-or-index>
```

Packages previously installed through `github:madebycli/nix-pkgs` should be removed once and added again with the direct repository command above. After that migration, future upgrades no longer pass through this index.

## Use directly in a NixOS Flake

Add only the repositories that the system actually uses:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    twintail-nix.url = "github:madebycli/twintail-nix";
    helium-nix.url = "github:madebycli/helium-nix";
    sakura.url = "github:madebycli/sakura";
    pipes.url = "github:madebycli/Pipes";
    gif-player.url = "github:madebycli/GIF-Player";
    git-backup.url = "github:madebycli/git-backup";

    twintail-nix.inputs.nixpkgs.follows = "nixpkgs";
    helium-nix.inputs.nixpkgs.follows = "nixpkgs";
    sakura.inputs.nixpkgs.follows = "nixpkgs";
    pipes.inputs.nixpkgs.follows = "nixpkgs";
    gif-player.inputs.nixpkgs.follows = "nixpkgs";
    git-backup.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Use their packages directly:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.twintail-nix.packages.${pkgs.system}.twintaillauncher
    inputs.helium-nix.packages.${pkgs.system}.helium
    inputs.sakura.packages.${pkgs.system}.sakura
    inputs.pipes.packages.${pkgs.system}.pipes
    inputs.gif-player.packages.${pkgs.system}.gif-player
    inputs.git-backup.packages.${pkgs.system}.github-backup-deck
  ];
}
```

## NixOS and Home Manager modules

TwintailLauncher exposes its NixOS module directly:

```nix
{
  imports = [ inputs.twintail-nix.nixosModules.default ];
  programs.twintaillauncher.enable = true;
}
```

GitHub Backup Deck exposes both NixOS and Home Manager modules directly:

```nix
{
  imports = [ inputs.git-backup.nixosModules.default ];
}
```

```nix
{
  imports = [ inputs.git-backup.homeManagerModules.default ];
}
```

For Sakura, Pipes, GIF Player, and Helium, use the package output directly unless their repository later adds a dedicated module.

## Update behavior

### Sakura, Pipes, GIF Player, and GitHub Backup Deck

Their Nix packages use the source from the same repository. A normal commit to the default branch is the new package source immediately; no separate Nix catalog commit is required.

To fetch it locally:

```bash
nix profile upgrade --all --refresh
```

### Helium and TwintailLauncher

These repositories package external upstream releases. Their `Update upstream release` workflow:

- checks automatically once per day;
- remains manually startable from the GitHub Actions page;
- validates the new source and package before committing an update.

When an upstream release is known to exist, open the repository's **Actions** page, select **Update upstream release**, and choose **Run workflow**. After it succeeds, run the normal profile upgrade command locally.

## Archived full catalog

The former combined Flake catalog is preserved unchanged on the branch [`archive/full-catalog-2026-08-06`](https://github.com/madebycli/nix-pkgs/tree/archive/full-catalog-2026-08-06).

That branch points to commit `88775d2535465dc8e837541eafa921b1c75a99ca` and contains the previous `flake.nix`, `flake.lock`, package re-exports, overlay, module re-export, CI, and catalog-update workflow. It is a historical backup only: it is not maintained, its package revisions are frozen, and its workflows are not part of the active `main` architecture.

Clone only the archived catalog:

```bash
git clone --branch archive/full-catalog-2026-08-06 --single-branch \
  https://github.com/madebycli/nix-pkgs.git nix-pkgs-full-catalog-backup
```

Restore it locally onto a new working branch without changing `main`:

```bash
git fetch origin archive/full-catalog-2026-08-06
git switch -c restore-full-catalog origin/archive/full-catalog-2026-08-06
```

## Repository role

`madebycli/nix-pkgs` on `main` is intentionally only an index and command reference. It has no `flake.nix`, no `flake.lock`, no package outputs, and no update workflow. The individual repositories are the sole source of truth. The archived full-catalog branch exists only as a rollback and reference snapshot.