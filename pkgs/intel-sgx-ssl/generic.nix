{ version, sha256, hasMitigation, targetName ? null }:
{ stdenv, lib, fetchFromGitHub, coreutils, gnugrep, gnused, openssl, perl
, intel-sgx, which, glibc, enableMitigation ? false }:

assert !hasMitigation -> !enableMitigation;
assert hasMitigation -> targetName != null;

stdenv.mkDerivation {
  name = "intel-sgx-ssl";

  src = fetchFromGitHub {
    name = "source";
    owner = "intel";
    repo = "intel-sgx-ssl";
    rev = version;
    inherit sha256;
  };

  patchPhase = ''
    patchShebangs .
    substituteInPlace Linux/build_openssl.sh \
      --replace "/usr/bin/head" "${coreutils}/bin/head" \
      --replace "/bin/ls" "${coreutils}/bin/ls" \
      --replace "/bin/grep" "${gnugrep}/bin/grep" \
      --replace "/bin/sed" "${gnused}/bin/sed"
    substituteInPlace Linux/sgx/libsgx_tsgxssl/tdefines.h \
      --replace "/usr/include/bits/confname.h" "bits/confname.h"
    cp ${openssl.src}  openssl_source/$(stripHash ${openssl.src})
  '';

  preBuild = ''
    cd Linux
    export NIX_PATH=1
    source ${intel-sgx}/sgxsdk/environment
  '';

  buildFlags = if targetName != null then
    [
      (targetName + lib.optionalString (!enableMitigation && hasMitigation)
        "_no_mitigation")
    ]
  else
    null;

  buildInputs = [ glibc which perl ];

  installFlags = [ "DESTDIR=$(out)" ];
}

