# nix-pkgs

Pinned Nix catalog for the restored `madebycli` projects:

- `twintaillauncher`
- `helium`
- `sakura`
- `pipes`
- `gif-player`

The four project inputs are pinned to reviewed repository commits. Helium is fetched from the official `imputnet/helium-linux` release and verified with a fixed hash. No upstream release binary is committed here.

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

## Validate locally

```bash
nix flake metadata --no-write-lock-file .
nix flake show --no-write-lock-file
nix flake check --no-write-lock-file --print-build-logs
nix build .#twintaillauncher .#helium .#sakura .#pipes .#gif-player \
  --no-write-lock-file --print-build-logs
```

## Updates

The update workflow is manual-only. It has read-only repository permissions, displays lock-file changes, and validates changed inputs without committing or opening pull requests.

The combined catalog currently targets `x86_64-linux`, because TwintailLauncher is available only for that platform. The individual GIF-Player, sakura, and Pipes repositories additionally expose their own supported systems.
