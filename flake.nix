{
  description = "Pinned Nix package catalog for TwintailLauncher, Helium, sakura, Pipes, and GIF-Player";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    "twintail-nix" = {
      url = "github:madebycli/twintail-nix/aa583a567a712553769beed96511f6c323c2af84";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sakura = {
      url = "github:madebycli/sakura/4206e9dcbcebf24b33e9a0f396a95bf0ff44fb81";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pipes = {
      url = "github:madebycli/Pipes/cd6658214020cba58fb6246363fa0847afdf008c";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "gif-player" = {
      url = "github:madebycli/GIF-Player/2906e22a0894e2688513c6d6f32bcffda69e8498";
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
      pkgs = import nixpkgs { inherit system; };

      twintailInput = inputs."twintail-nix";
      gifPlayerInput = inputs."gif-player";

      twintaillauncher = twintailInput.packages.${system}.twintaillauncher;
      helium = import ./packages/helium.nix { inherit pkgs system; };
      sakuraPackage = inputs.sakura.packages.${system}.sakura;
      pipesPackage = inputs.pipes.packages.${system}.pipes;
      gifPlayerPackage = gifPlayerInput.packages.${system}."gif-player";
    in
    {
      packages.${system} = {
        inherit twintaillauncher helium;
        sakura = sakuraPackage;
        pipes = pipesPackage;
        "gif-player" = gifPlayerPackage;
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
        default = self.apps.${system}.twintaillauncher;
      };

      checks.${system} = {
        inherit twintaillauncher helium;
        sakura = sakuraPackage;
        pipes = pipesPackage;
        "gif-player" = gifPlayerPackage;
      };

      overlays.default = final: _prev:
        nixpkgs.lib.optionalAttrs (final.stdenv.hostPlatform.system == system) {
          inherit twintaillauncher helium;
          sakura = sakuraPackage;
          pipes = pipesPackage;
          "gif-player" = gifPlayerPackage;
        };

      nixosModules = {
        twintaillauncher = twintailInput.nixosModules.default;
        default = twintailInput.nixosModules.default;
      };
    };
}
