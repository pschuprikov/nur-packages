{
  description = "NUR flake";
  inputs.nixpkgs.url = "github:pschuprikov/nixpkgs/nixos-22.11";
  inputs.mvn2nix.url = "github:fzakaria/mvn2nix";
  inputs.mvn2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, mvn2nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ mvn2nix.overlay ];
        };
        lib = pkgs.lib;
        nur = import self { nixpkgsPath = nixpkgs; pkgs = pkgs; };
        intelSGXPackages_2_7_1 =
          nur.intelSGXPackages_2_7_1.override { debugMode = true; };
      in {
        packages =
          lib.filterAttrs (n: d: lib.isDerivation d && !(d.meta.broken or false))
          (nur // nur.qt5);
        inherit (nur) overlays;
        nixosModules = import ./modules;
      }
  );
}
