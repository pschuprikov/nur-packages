{ stdenv, lib, overrideCC, wrapCCWith, fetchFromGitHub, fetchurl
, autoPatchelfHook, buildEnv, binutils-unwrapped, wrapBintoolsWith, file
, coreutils, ocaml, autoconf, automake, which, python, libtool, openssl
, llvmPackages_8, ocamlPackages, perl, cmake, bash, enableMitigation ? false }:
let
  version = "2.11";
  dcap_version = "1.8";

  intel-sgx-path = "https://download.01.org/intel-sgx/";

  server-url-path = "${intel-sgx-path}/sgx-linux/${version}/";

  bintools-unwrapped-intel = stdenv.mkDerivation rec {
    name = "intel-sgx-binutils";
    version = "2.11";

    src = fetchurl {
      url = "${server-url-path}/as.ld.objdump.gold.r2.tar.gz";
      sha256 = "1q1mf7p8xvwfkvw0fkvbv28q3wffwaz9c96s7hqv7r3095cj7xlp";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp toolset/nix/* $out/bin
    '';

    buildInputs = [ stdenv.cc.cc autoPatchelfHook ];
  };

  intel-optlibs-prebuilt =  fetchurl {
    url = "${server-url-path}/optimized_libs_${version}.tar.gz";
    sha256 = "sha256:0qki299mxdp937vwg3163c79qj9976hdd6qs72j7h7jc25chiba3";
  };

  intel-dcap-prebuilt =  fetchurl {
      url = "${intel-sgx-path}/sgx-dcap/${dcap_version}/linux/prebuilt_dcap_${dcap_version}.tar.gz";
      sha256 = "14mk253sdggvqi90fhkywp14a0w4wx4ll22dvddqvdbgknmf9jfc";
  };

  binutils-intel-unwrapped = buildEnv {
    name = "intel-sgx-binutils-merged";
    paths = [ bintools-unwrapped-intel binutils-unwrapped ];
  };

  binutils-intel = wrapBintoolsWith { bintools = binutils-intel-unwrapped; };

  intelStdenv = overrideCC stdenv (wrapCCWith {
    cc = stdenv.cc.cc;
    bintools = binutils-intel;
  });

  openmp_src = llvmPackages_8.openmp.src;

in intelStdenv.mkDerivation {
  name = "linux-sgx";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "linux-sgx";
    rev = "33f4499173497bdfdf72c5f61374c0fadc5c5365";
    sha256 = "009hlkgnn3wvbsnawpfcwdxyncax9mb260vmh9anb91lmqbj74rp";
    fetchSubmodules = true;
  };

  dontUseCmakeConfigure = true;

  patchPhase = ''
    tar -xzvf ${intel-optlibs-prebuilt}
    tar -xzvf ${intel-dcap-prebuilt}

    pushd external/openmp/openmp_code
    patch -p1 < ../*.patch
    popd

    substituteInPlace buildenv.mk \
      --replace /bin/cp ${coreutils}/bin/cp

    patchShebangs linux/installer
  '';

  installPhase = ''
    ./linux/installer/bin/sgx_linux_x64_sdk_* -prefix $out;
  '';

  buildFlags =
    [ ("sdk_install_pkg" + lib.optionalString (!enableMitigation) "_no_mitigation") ];

  buildInputs = [
    cmake
    file
    ocaml
    openssl
    libtool
    which
    python
    ocamlPackages.ocamlbuild
    autoconf
    automake
    perl
  ];
}
