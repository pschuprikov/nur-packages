{ version, hasMitigation, sha256, optlibsSha256, binutilsSha256 ? null
, patchOpenMP ? false }:
{ stdenv, lib, overrideCC, wrapCCWith, fetchFromGitHub, fetchurl
, autoPatchelfHook, buildEnv, binutils-unwrapped, wrapBintoolsWith, file
, coreutils, ocaml, autoconf, automake, which, python, libtool, openssl
, llvmPackages_8, ocamlPackages, perl, cmake, bash, enableMitigation ? false }:

assert !hasMitigation -> !enableMitigation;

let
  useIntelBinUtils = binutilsSha256 != null;

  dcap_version = "1.8";

  intel-sgx-path = "https://download.01.org/intel-sgx/";

  server-url-path = "${intel-sgx-path}/sgx-linux/${version}/";

  bintools-unwrapped-intel = stdenv.mkDerivation rec {
    name = "intel-sgx-binutils-${version}";

    inherit version;

    src = fetchurl {
      url = "${server-url-path}/as.ld.objdump.gold.r2.tar.gz";
      sha256 = binutilsSha256;
    };

    installPhase = ''
      mkdir -p $out/bin
      cp toolset/nix/* $out/bin
    '';

    buildInputs = [ stdenv.cc.cc autoPatchelfHook ];
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

  intel-optlibs-prebuilt = fetchurl {
    url = "${server-url-path}/optimized_libs_${version}.tar.gz";
    sha256 = optlibsSha256;
  };

  intel-dcap-prebuilt = fetchurl {
    url =
      "${intel-sgx-path}/sgx-dcap/${dcap_version}/linux/prebuilt_dcap_${dcap_version}.tar.gz";
    sha256 = "14mk253sdggvqi90fhkywp14a0w4wx4ll22dvddqvdbgknmf9jfc";
  };

  sgxStdenv = if useIntelBinUtils then intelStdenv else stdenv;

in sgxStdenv.mkDerivation {
  name = "linux-sgx";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "linux-sgx";
    rev = "sgx_${version}";
    sha256 = sha256;
    fetchSubmodules = true;
  };

  dontUseCmakeConfigure = true;

  patchPhase = ''
    tar -xzvf ${intel-optlibs-prebuilt}
    tar -xzvf ${intel-dcap-prebuilt}
  '' + lib.optionalString patchOpenMP ''
    pushd external/openmp/openmp_code
    patch -p1 < ../*.patch
    popd
  '' + ''

    substituteInPlace buildenv.mk \
      --replace /bin/cp ${coreutils}/bin/cp

    patchShebangs linux/installer
  '';

  installPhase = ''
    ./linux/installer/bin/sgx_linux_x64_sdk_* -prefix $out;
  '';

  buildFlags = [
    ("sdk_install_pkg" + lib.optionalString (hasMitigation && !enableMitigation)
      "_no_mitigation")
  ];

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

