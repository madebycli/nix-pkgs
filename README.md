<p align="center">
  <img src="assets/readme-banner.svg" alt="Nix software index — direct repository installs" width="100%">
</p>

<p align="center">
  Direct Nix commands for the maintained repositories. This repository is documentation only and is not a Flake or package mirror.
</p>

## Why direct repositories?

Every project owns its package, checks, Flake outputs, lock file, and optional NixOS or Home Manager modules. A commit on a project's default branch is available directly without waiting for a second catalog repository.

The normal local update command is:

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
| Nix Settings | [`madebycli/nix-settings`](https://github.com/madebycli/nix-settings) | `nix run github:madebycli/nix-settings#nix-settings -- sound` |

## Install into a Nix profile

```bash
nix profile add github:madebycli/twintail-nix#twintaillauncher
nix profile add github:madebycli/helium-nix#helium
nix profile add github:madebycli/sakura#sakura
nix profile add github:madebycli/Pipes#pipes
nix profile add github:madebycli/GIF-Player#gif-player
nix profile add github:madebycli/git-backup#github-backup-deck
nix profile add github:madebycli/nix-settings#nix-settings
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

Packages previously installed through `github:madebycli/nix-pkgs` should be removed once and added again with the direct repository command above.

## What updates automatically?

### Project source code

Sakura, Pipes, GIF Player, GitHub Backup Deck, and Nix Settings package the source from their own repository. A normal commit to `main` changes the package source immediately, even when the visible application version is unchanged. No Nix file, package version, catalog pin, or extra release commit is required.

After the commit reaches `main`, run:

```bash
nix profile upgrade --all --refresh
```

The same rule applies to changes in the Nix packaging code of TwintailLauncher and Helium. Their external application payloads are handled separately.

### Nixpkgs and build dependencies

Every project commits a `flake.lock`. Each repository has an **Update Nixpkgs input** workflow that:

- runs automatically once per day;
- can be started manually with **Run workflow**;
- updates the `nixpkgs` lock to the current `nixos-unstable` revision;
- evaluates the Flake, runs its checks, and builds the package;
- commits the new lock file only after validation succeeds.

A future installation therefore uses the newest dependency set successfully validated by that repository. An abandoned repository or one with Actions disabled remains reproducibly pinned to its last validated lock file.

### External application releases

TwintailLauncher and Helium package external upstream releases. Their **Update upstream release** workflows run once per day, remain manually startable, and publish an update only after validation succeeds.

## Five-year behavior

An unlocked reference such as:

```bash
nix profile add github:madebycli/nix-settings#nix-settings
```

selects the current `main` commit. Later:

```bash
nix profile upgrade --all --refresh
```

fetches the newest repository commit and uses the validated `flake.lock` contained in that commit. Do not install using an explicit commit SHA when future upgrades are desired; a fixed SHA is intentionally immutable.

## Direct-install verification

Every project CI verifies:

- that `flake.lock` exists and is synchronized;
- Flake evaluation and checks;
- the complete package build;
- the exact public `nix profile add github:…#…` command.

A missing or stale lock file therefore fails CI instead of reaching users unnoticed.

## Use directly in a NixOS Flake

Add only the repositories that the system uses:

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
    nix-settings.url = "github:madebycli/nix-settings";

    twintail-nix.inputs.nixpkgs.follows = "nixpkgs";
    helium-nix.inputs.nixpkgs.follows = "nixpkgs";
    sakura.inputs.nixpkgs.follows = "nixpkgs";
    pipes.inputs.nixpkgs.follows = "nixpkgs";
    gif-player.inputs.nixpkgs.follows = "nixpkgs";
    git-backup.inputs.nixpkgs.follows = "nixpkgs";
    nix-settings.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Use their package outputs directly:

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
    inputs.nix-settings.packages.${pkgs.system}.nix-settings
  ];
}
```

## NixOS and Home Manager modules

TwintailLauncher exposes a NixOS module:

```nix
{
  imports = [ inputs.twintail-nix.nixosModules.default ];
  programs.twintaillauncher.enable = true;
}
```

GitHub Backup Deck exposes NixOS and Home Manager modules:

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

Nix Settings also exposes both module types:

```nix
{
  imports = [ inputs.nix-settings.nixosModules.default ];
  programs.nix-settings.enable = true;
}
```

```nix
{
  imports = [ inputs.nix-settings.homeManagerModules.default ];
  programs.nix-settings.enable = true;
}
```

For Sakura, Pipes, GIF Player, and Helium, use the package output directly unless their repository later adds a dedicated module.

## Archived full catalog

The former combined Flake catalog is preserved unchanged on [`archive/full-catalog-2026-08-06`](https://github.com/madebycli/nix-pkgs/tree/archive/full-catalog-2026-08-06). It is a historical backup only and is not maintained.

```bash
git clone --branch archive/full-catalog-2026-08-06 --single-branch \
  https://github.com/madebycli/nix-pkgs.git nix-pkgs-full-catalog-backup
```

## Repository role

`madebycli/nix-pkgs` on `main` is intentionally only an index and command reference. The individual repositories are the sole source of truth. The archived branch exists only as a rollback and reference snapshot.
