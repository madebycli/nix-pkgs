{
  description = "Pinned Nix package catalog for TwintailLauncher, Helium, sakura, Pipes, and GIF-Player";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    twintail-nix = {
      url = "github:madebycli/twintail-nix/3de4e3d25dd634ba16ea2558b184be2124f04a44";
    };

    sakura = {
      url = "github:madebycli/sakura/2be2ca4697fa292d31ad8f60e924a7cfefc4a627";
    };

    pipes = {
      url = "github:madebycli/Pipes/9aa88d10e33865017242cfe2bd4b44161e4268ad";
    };

    gif-player = {
      url = "github:madebycli/GIF-Player/b49539b93dc982bc706548e319b9bb9df1c47fe9";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      heliumPackage = import ./packages/helium.nix { inherit pkgs system; };
      catalog = {
        twintaillauncher = inputs.twintail-nix.packages.${system}.twintaillauncher;
        helium = heliumPackage;
        sakura = inputs.sakura.packages.${system}.sakura;
        pipes = inputs.pipes.packages.${system}.pipes;
        gif-player = inputs.gif-player.packages.${system}.gif-player;
      };
    in
    {
      packages.${system} = catalog // {
        default = catalog.twintaillauncher;
      };

      apps.${system} = {
        twintaillauncher = {
          type = "app";
          program = "${catalog.twintaillauncher}/bin/twintaillauncher";
        };
        helium = {
          type = "app";
          program = "${catalog.helium}/bin/helium";
        };
        sakura = {
          type = "app";
          program = "${catalog.sakura}/bin/sakura";
        };
        pipes = {
          type = "app";
          program = "${catalog.pipes}/bin/pipes";
        };
        gif-player = {
          type = "app";
          program = "${catalog.gif-player}/bin/gif-player";
        };
        default = self.apps.${system}.twintaillauncher;
      };

      checks.${system} = catalog;

      overlays.default = final: _prev: {
        inherit (catalog) twintaillauncher helium sakura pipes;
        gif-player = catalog.gif-player;
      };

      nixosModules = {
        twintaillauncher = inputs.twintail-nix.nixosModules.default;
        default = self.nixosModules.twintaillauncher;
      };
    };
}
