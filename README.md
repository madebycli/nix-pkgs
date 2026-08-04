# nix-pkgs

Pinned Nix catalog for the restored `madebycli` projects:

- `twintaillauncher`
- `helium`
- `sakura`
- `pipes`
- `gif-player`

The four project inputs are pinned to reviewed repository commits. Helium is fetched from the official `imputnet/helium-linux` release and verified with a fixed hash. No upstream release binary is committed here.

## Deployed revisions

| Package | Source revision |
| --- | --- |
| TwintailLauncher | `madebycli/twintail-nix@aa583a567a712553769beed96511f6c323c2af84` |
| sakura | `madebycli/sakura@4206e9dcbcebf24b33e9a0f396a95bf0ff44fb81` |
| Pipes | `madebycli/Pipes@cd6658214020cba58fb6246363fa0847afdf008c` |
| GIF-Player | `madebycli/GIF-Player@2906e22a0894e2688513c6d6f32bcffda69e8498` |
| Helium | official `imputnet/helium-linux` release `0.12.1.1` |

## Install

```bash
nix profile add github:madebycli/nix-pkgs#twintaillauncher
nix profile add github:madebycli/nix-pkgs#helium
nix profile add github:madebycli/nix-pkgs#sakura
nix profile add github:madebycli/nix-pkgs#pipes
nix profile add github:madebycli/nix-pkgs#gif-player
```

Run without installing:

```bash
nix run github:madebycli/nix-pkgs#twintaillauncher
nix run github:madebycli/nix-pkgs#helium
nix run github:madebycli/nix-pkgs#sakura
nix run github:madebycli/nix-pkgs#pipes
nix run github:madebycli/nix-pkgs#gif-player -- --help
```

## NixOS module

The catalog re-exports the TwintailLauncher module:

```nix
{
  inputs.nix-pkgs.url = "github:madebycli/nix-pkgs";

  outputs = { nixpkgs, nix-pkgs, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nix-pkgs.nixosModules.twintaillauncher
        { programs.twintaillauncher.enable = true; }
      ];
    };
  };
}
```

Enabling the module installs TwintailLauncher and supplies the host integration required by its downloaded runners:

- native and 32-bit OpenGL/Vulkan driver support;
- GameMode and Gamescope;
- a multi-architecture SteamRT-compatible FHS environment;
- MangoHud and the command-line helpers used by Winetricks;
- the Wine 11 Visual C++ 2022 and Sparkle overwrite fixes.

TwintailLauncher continues to download and manage its selected Wine/Proton and Steam Linux Runtime versions itself. The Nix package deliberately does not pin a second, unrelated Wine or Proton build.

## Validate locally

```bash
nix flake lock
git diff --exit-code -- flake.lock
nix flake show --no-write-lock-file
nix flake check --no-write-lock-file --print-build-logs
nix build .#twintaillauncher .#helium .#sakura .#pipes .#gif-player \
  --no-write-lock-file --print-build-logs
```

## Updates

The update workflow is manual-only. It has read-only repository permissions, displays lock-file changes, and validates changed inputs without committing or opening pull requests.

The combined catalog currently targets `x86_64-linux`, because TwintailLauncher is available only for that platform. The individual GIF-Player, sakura, and Pipes repositories additionally expose their own supported systems.
