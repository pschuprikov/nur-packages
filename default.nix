{ pkgs ? import <nixpkgs> {} }:
let scope = pkgs.lib.makeScope pkgs.newScope (self: rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = pkgs.lib // import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  otcl = self.callPackage ./pkgs/otcl { };
  tclcl = self.callPackage ./pkgs/tclcl { };
  ns-2 = self.callPackage ./pkgs/ns2 { };
  buildArb = self.callPackage ./pkgs/bioinf/arb/buildArb.nix { };
  arbcommon = self.callPackage ./pkgs/bioinf/arb/common { };
  arbcore = self.callPackage ./pkgs/bioinf/arb/core { };
  arbaisc = self.callPackage ./pkgs/bioinf/arb/aisc { };
  arbaisc_com = self.callPackage ./pkgs/bioinf/arb/aisc_com { };
  arbaisc_mkptps = self.callPackage ./pkgs/bioinf/arb/aisc_mkptps { };
  arbdb = self.callPackage ./pkgs/bioinf/arb/db { };
  arbslcb = self.callPackage ./pkgs/bioinf/arb/sl/cb { };
  arbprobe_com = self.callPackage ./pkgs/bioinf/arb/probe_com { };
  arbslhelix = self.callPackage ./pkgs/bioinf/arb/sl/helix { };
  sina = self.callPackage ./pkgs/bioinf/sina { };
  prokka = self.callPackage ./pkgs/bioinf/prokka { };
  infernal = self.callPackage ./pkgs/bioinf/infernal { };
  cd-hit = self.callPackage ./pkgs/bioinf/cd-hit { };

  splitstree = self.callPackage ./pkgs/bioinf/splitstree { };

  abricate = self.callPackage ./pkgs/bioinf/abricate { };

  any2fasta = self.callPackage ./pkgs/bioinf/any2fasta { };

  easyfig = pkgs.pythonPackages.callPackage ./pkgs/bioinf/easyfig { inherit ncbi_blast; };

  # TODO: mark as no build
  #ncbi_blast_2_6_0 = self.callPackage ./pkgs/bioinf/ncbi_blast/2_6_0.nix { };
  ncbi_blast_2_9_0 = self.callPackage ./pkgs/bioinf/ncbi_blast/2_9_0.nix { 
    inherit (pkgs.darwin.apple_sdk.frameworks) ApplicationServices; 
  };
  ncbi_blast = ncbi_blast_2_9_0;

  ncbi_tools = self.callPackage ./pkgs/bioinf/ncbi_tools { };
  aragorn = self.callPackage ./pkgs/bioinf/aragorn { };
  prodigal = self.callPackage ./pkgs/bioinf/prodigal { };

  mafft = self.callPackage ./pkgs/bioinf/mafft { };

  mcl = self.callPackage ./pkgs/bioinf/mcl { };
  prank = self.callPackage ./pkgs/bioinf/prank { };
  FastTree = self.callPackage ./pkgs/bioinf/fasttree { };

  perlPackages = self.callPackage ./pkgs/perl-packages.nix { 
    inherit (pkgs) perlPackages; 
  } // pkgs.perlPackages // {
    recurseForDerivations = false;
  };

  inherit (perlPackages) BioPerl BioRoary BioSearchIOhmmer;

  autofirma = self.callPackage ./pkgs/autofirma { };
}); 
in scope.packages scope
