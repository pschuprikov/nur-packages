{
  description = "NUR flake";
  inputs.nixpkgs.url = "github:pschuprikov/nixpkgs/nixos-24.05";
  inputs.mvn2nix.url = "github:fzakaria/mvn2nix";
  inputs.mvn2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, mvn2nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages =
            [ "openssl-1.1.1u" "python-2.7.18.7" ];
          overlays = [ mvn2nix.overlay self.overlays.gogolFixOverlay ];
        };
        lib = pkgs.lib;
        nur = import self {
          nixpkgsPath = nixpkgs;
          pkgs = pkgs;
        };
      in {
        packages = lib.filterAttrs
          (n: d: lib.isDerivation d && !(d.meta.broken or false))
          (nur // nur.qt5 // nur.haskellPackages);
      }) // {
        overlays = import ./overlays;
        nixosModules = import ./modules;
      };
}
