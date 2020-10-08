{ 
  description = "NUR flake";
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.03;

  outputs = { self, nixpkgs }: 
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
        lib = pkgs.lib;
        nur = import self { pkgs = pkgs; };
    in {
    packages.x86_64-linux = lib.filterAttrs (n: d: lib.isDerivation d) nur;
  };
}
