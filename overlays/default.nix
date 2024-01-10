{
  llvmPackagesOverlay = final: prev: {
    llvmPackagesWithGcc10 = let
      gccForLibs = prev.gcc10.cc;
      wrapCCWith = args: prev.wrapCCWith (args // { inherit gccForLibs; });
      llvmPackages = prev.llvmPackages_10.override {
        buildLlvmTools = llvmPackages.tools;
        targetLlvmLibraries = llvmPackages.libraries;
        inherit wrapCCWith gccForLibs;
      };
    in llvmPackages;
  };
  gogolFixOverlay = final: prev: {
    haskellPackages = prev.haskellPackages.override {
      overrides = selfHaskell: superHaskell:
        let
          gogol_src = prev.fetchFromGitHub {
            owner = "brendanhay";
            repo = "gogol";
            rev = "494098af1709d32b75b0be41157547ae7a2bd89d";
            sha256 = "sha256-qoqLpffy6m2vLgmURcCpOQAdSx7OJoIJSHzz6bHUhm4=";
          };
          lib = prev.haskell.lib;
          override_gogol_src = drv:
            lib.overrideSrc drv {
              version = "1.0.0.0";
              src = gogol_src;
            };
        in {

          gogol-core =
            (lib.overrideCabal (override_gogol_src (lib.markUnbroken superHaskell.gogol-core))
              (drv: {
                patches = [ ];
                buildDepends = drv.buildDepends or [ ]
                  ++ [ selfHaskell.base64 ];
              })).overrideAttrs
            (attrs: { sourceRoot = "source/lib/gogol-core"; });
          gogol = (override_gogol_src superHaskell.gogol).overrideAttrs
            (attrs: { sourceRoot = "source/lib/gogol"; });
          gogol-drive = (override_gogol_src
            (lib.markUnbroken superHaskell.gogol-drive)).overrideAttrs
            (attrs: { sourceRoot = "source/lib/services/gogol-drive"; });
        };
    };
  };
}
