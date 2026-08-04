<p align="center">
  <img src="assets/readme-banner.svg" alt="nix-pkgs — curated software, reproducible builds" width="100%">
</p>

<p align="center">
  <a href="https://github.com/madebycli/nix-pkgs/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/madebycli/nix-pkgs/actions/workflows/ci.yml/badge.svg?branch=main"></a>
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
| `helium` | Helium browser packaged from the official Linux release | `nix run github:madebycli/nix-pkgs#helium` |
| [`sakura`](https://github.com/madebycli/sakura) | Procedural cherry blossoms for the terminal | `nix run github:madebycli/nix-pkgs#sakura` |
| [`pipes`](https://github.com/madebycli/Pipes) | A modern Python take on the classic terminal screensaver | `nix run github:madebycli/nix-pkgs#pipes` |
| [`gif-player`](https://github.com/madebycli/GIF-Player) | Animated GIF overlays for Wayland desktops | `nix run github:madebycli/nix-pkgs#gif-player` |

Each project remains independently maintained in its own repository. This repository provides one convenient entry point with reviewed source pins and a shared Nixpkgs input.

## Install

Install a package into the current profile:

```bash
nix profile add github:madebycli/nix-pkgs#helium
nix profile add github:madebycli/nix-pkgs#pipes
```

Replace the package name with any entry from the catalog.

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
  ];
}
```

## NixOS module

The catalog re-exports the TwintailLauncher module for users who prefer a module-based setup:

```nix
{
  imports = [ inputs.nix-pkgs.nixosModules.twintaillauncher ];
  programs.twintaillauncher.enable = true;
}
```

Project-specific configuration and usage belong in the corresponding project repository.

## Flake outputs

```text
packages.x86_64-linux.{twintaillauncher,helium,sakura,pipes,gif-player}
apps.x86_64-linux.{twintaillauncher,helium,sakura,pipes,gif-player}
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
  --no-write-lock-file --print-build-logs
```

Updates are reviewed through the lock file and validated by building every catalog entry.
