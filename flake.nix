{
  description = "Pinned Nix package catalog for TwintailLauncher, Helium, sakura, Pipes, and GIF-Player";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    "twintail-nix" = {
      url = "github:madebycli/twintail-nix/3de4e3d25dd634ba16ea2558b184be2124f04a44";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sakura = {
      url = "github:madebycli/sakura/2be2ca4697fa292d31ad8f60e924a7cfefc4a627";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pipes = {
      url = "github:madebycli/Pipes/9aa88d10e33865017242cfe2bd4b44161e4268ad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "gif-player" = {
      url = "github:madebycli/GIF-Player/b49539b93dc982bc706548e319b9bb9df1c47fe9";
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
