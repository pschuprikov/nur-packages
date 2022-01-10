{
  description = "NUR flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.mvn2nix.url = "github:fzakaria/mvn2nix";

  outputs = { self, nixpkgs, mvn2nix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ mvn2nix.overlay ];
      };
      lib = pkgs.lib;
      nur = import self { pkgs = pkgs; };
      intelSGXPackages_2_7_1 = nur.intelSGXPackages_2_7_1.override {
          debugMode = true;
      };
    in {
      packages.${system} =
        lib.filterAttrs (n: d: lib.isDerivation d && !(d.meta.broken or false))
        nur // {
          intel-sgx-sdk_2_7_1-debug = intelSGXPackages_2_7_1.sdk;
          intel-sgx-psw_2_7_1-debug = intelSGXPackages_2_7_1.psw;
          inherit (nur.qt5) omnetpp omnetpp-inet; 
        };
      inherit (nur) overlays;
    };
}
