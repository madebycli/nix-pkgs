<p align="center">
  <img src="assets/readme-banner.svg" alt="nix-pkgs — curated software, reproducible builds" width="100%">
</p>

<p align="center">
  <a href="https://github.com/madebycli/nix-pkgs/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/madebycli/nix-pkgs/actions/workflows/ci.yml/badge.svg?branch=main"></a>
  <a href="https://github.com/madebycli/nix-pkgs/actions/workflows/update-check.yml"><img alt="Catalog updates" src="https://github.com/madebycli/nix-pkgs/actions/workflows/update-check.yml/badge.svg?branch=main"></a>
  <img alt="Nix Flake" src="https://img.shields.io/badge/Nix-Flake-5277C3?logo=nixos&logoColor=white">
  <img alt="Platform" src="https://img.shields.io/badge/platform-x86__64--linux-7c5cff">
</p>

<p align="center">
  A focused Nix catalog for desktop tools, terminal toys, and Linux applications.
</p>

## Catalog

| Package | What it is | Run it |
|---|---|---|
| [`twintaillauncher`](https://github.com/madebycli/twintail-nix) | Native Nix packaging for TwintailLauncher | `nix run github:madebycli/nix-pkgs#twintaillauncher` |
| [`helium`](https://github.com/madebycli/helium-nix) | Native Nix packaging for the official Helium Linux release | `nix run github:madebycli/nix-pkgs#helium` |
| [`sakura`](https://github.com/madebycli/sakura) | Procedural cherry blossoms for the terminal | `nix run github:madebycli/nix-pkgs#sakura` |
| [`pipes`](https://github.com/madebycli/Pipes) | A modern Python take on the classic terminal screensaver | `nix run github:madebycli/nix-pkgs#pipes` |
| [`gif-player`](https://github.com/madebycli/GIF-Player) | Animated GIF overlays for Wayland desktops | `nix run github:madebycli/nix-pkgs#gif-player` |
| [`github-backup-deck`](https://github.com/madebycli/git-backup) | Graphical GitHub backup manager for Wayland | `nix run github:madebycli/nix-pkgs#github-backup-deck` |

Each package is maintained in its own repository. This catalog re-exports those packages through one shared Nixpkgs input and one reviewed lock file.

## Install

Install a package into the current profile:

```bash
nix profile add github:madebycli/nix-pkgs#helium
nix profile add github:madebycli/nix-pkgs#pipes
nix profile add github:madebycli/nix-pkgs#github-backup-deck
```

Replace the package name with any entry from the catalog.

Update every package in the current profile:

```bash
nix profile upgrade --all --refresh
```

List and remove profile entries:

```bash
nix profile list
nix profile remove <profile-name>
```

## Use as a flake input

```nix
{
  inputs.nix-pkgs.url = "github:madebycli/nix-pkgs";

  outputs = { nixpkgs, nix-pkgs, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = with nix-pkgs.packages.${pkgs.system}; [
            helium
            sakura
            pipes
            gif-player
            github-backup-deck
          ];
        })
      ];
    };
  };
}
```

## Overlay

The default overlay exposes the catalog through `pkgs`:

```nix
{
  nixpkgs.overlays = [ inputs.nix-pkgs.overlays.default ];

  environment.systemPackages = with pkgs; [
    helium
    sakura
    pipes
    gif-player
    github-backup-deck
  ];
}
```

## NixOS module

The catalog re-exports the TwintailLauncher module:

```nix
{
  imports = [ inputs.nix-pkgs.nixosModules.twintaillauncher ];
  programs.twintaillauncher.enable = true;
}
```

Project-specific configuration and usage belong in the corresponding project repository.

## Automatic catalog updates

All six package inputs follow the current default branch of their dedicated repository. The catalog checks Twintail, Helium, Sakura, Pipes, GIF Player, and GitHub Backup Deck every five minutes, which is the shortest schedule interval supported by GitHub Actions.

A source change does not require a manual Nix pin or a version-only catalog commit. The workflow refreshes the lock file, evaluates the complete flake, runs every check, and builds every package. It publishes the new lock file only after the entire catalog succeeds. Failed source changes therefore remain outside the published catalog until a later commit fixes them.

Helium and Twintail also check their external upstream releases every five minutes and publish a package-repository commit only after their own validation succeeds. GitHub may queue or delay hosted workflows, so an exact one-minute delivery time cannot be guaranteed.

After the validated catalog commit is available, update the local profile with:

```bash
nix profile upgrade --all --refresh
```

The update workflow can also receive a `package-updated` repository-dispatch event or be started safely from the GitHub Actions page with **Run workflow**.

## Flake outputs

```text
packages.x86_64-linux.{twintaillauncher,helium,sakura,pipes,gif-player,github-backup-deck}
apps.x86_64-linux.{twintaillauncher,helium,sakura,pipes,gif-player,github-backup-deck}
checks.x86_64-linux
nixosModules.{default,twintaillauncher}
overlays.default
```

The combined catalog targets `x86_64-linux`. Individual projects may support additional systems in their own flakes.

## Development

```bash
nix flake lock
git diff --exit-code -- flake.lock
nix flake show --no-write-lock-file
nix flake check --no-write-lock-file --print-build-logs
nix build .#twintaillauncher .#helium .#sakura .#pipes .#gif-player \
  .#github-backup-deck --no-write-lock-file --print-build-logs
```

Updates are reviewed through the lock file and validated by building every catalog entry.
