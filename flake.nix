{
  description = "Curated Nix package catalog for TwintailLauncher, Helium, sakura, Pipes, GIF Player, and GitHub Backup Deck";

  # GitHub Backup Deck 0.3.2 is pinned below and verified by the catalog workflow.
  # This sync branch performs the isolated reproducibility validation.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    "twintail-nix" = {
      url = "github:madebycli/twintail-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "helium-nix" = {
      url = "github:madebycli/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sakura = {
      url = "github:madebycli/sakura/e7d2b08b95df9254e08c70c2325a9d33c7e6fe55";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pipes = {
      url = "github:madebycli/Pipes/7afaa691bac592eadc1302a1ce2e55f586a0196f";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "gif-player" = {
      url = "github:madebycli/GIF-Player/785729d1245b6b9a64ee42804ed720fdc6777dc7";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "git-backup" = {
      url = "github:madebycli/git-backup/95345939705daf05da6fc97bbdccdbb66cf4fe05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      twintailInput = inputs."twintail-nix";
      heliumInput = inputs."helium-nix";
      gifPlayerInput = inputs."gif-player";
      gitBackupInput = inputs."git-backup";

      twintaillauncher = twintailInput.packages.${system}.twintaillauncher;
      helium = heliumInput.packages.${system}.helium;
      sakuraPackage = inputs.sakura.packages.${system}.sakura;
      pipesPackage = inputs.pipes.packages.${system}.pipes;
      gifPlayerPackage = gifPlayerInput.packages.${system}."gif-player";
      gitBackupPackage = gitBackupInput.packages.${system}."github-backup-deck";
    in
    {
      packages.${system} = {
        inherit twintaillauncher helium;
        sakura = sakuraPackage;
        pipes = pipesPackage;
        "gif-player" = gifPlayerPackage;
        "github-backup-deck" = gitBackupPackage;
        default = twintaillauncher;
      };

      apps.${system} = {
        twintaillauncher = {
          type = "app";
          program = "${twintaillauncher}/bin/twintaillauncher";
        };
        helium = {
          type = "app";
          program = "${helium}/bin/helium";
        };
        sakura = {
          type = "app";
          program = "${sakuraPackage}/bin/sakura";
        };
        pipes = {
          type = "app";
          program = "${pipesPackage}/bin/pipes";
        };
        "gif-player" = {
          type = "app";
          program = "${gifPlayerPackage}/bin/gif-player";
        };
        "github-backup-deck" = {
          type = "app";
          program = "${gitBackupPackage}/bin/github-backup-deck";
        };
        default = self.apps.${system}.twintaillauncher;
      };

      checks.${system} = {
        inherit twintaillauncher helium;
        sakura = sakuraPackage;
        pipes = pipesPackage;
        "gif-player" = gifPlayerPackage;
        "github-backup-deck" = gitBackupPackage;
      };

      overlays.default = final: _prev:
        nixpkgs.lib.optionalAttrs (final.stdenv.hostPlatform.system == system) {
          inherit twintaillauncher helium;
          sakura = sakuraPackage;
          pipes = pipesPackage;
          "gif-player" = gifPlayerPackage;
          "github-backup-deck" = gitBackupPackage;
        };

      nixosModules = {
        twintaillauncher = twintailInput.nixosModules.default;
        default = twintailInput.nixosModules.default;
      };
    };
}
