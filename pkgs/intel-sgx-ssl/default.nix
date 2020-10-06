{ stdenv, lib, fetchFromGitHub, coreutils, gnugrep, gnused, openssl, perl, intel-sgx, which, enableMitigation ? false }:
stdenv.mkDerivation {
  name = "intel-sgx-ssl";

  src = fetchFromGitHub {
    name = "source";
    owner = "intel";
    repo = "intel-sgx-ssl";
    rev = "8c0866516ad6eb5f0bd47d15eced0d8c35723f2a";
    sha256 = "0fihw5xld67qilnywlr7jm4nw6k2w10qx5jg352kb1skpbq9i9s8";
  };

  patchPhase = ''
    patchShebangs .
    substituteInPlace Linux/build_openssl.sh \
      --replace "/usr/bin/head" "${coreutils}/bin/head" \
      --replace "/bin/ls" "${coreutils}/bin/ls" \
      --replace "/bin/grep" "${gnugrep}/bin/grep" \
      --replace "/bin/sed" "${gnused}/bin/sed"
    cp ${openssl.src}  openssl_source/$(stripHash ${openssl.src})
  '';

  preBuild = ''
    cd Linux
    export NIX_PATH=1
    source ${intel-sgx}/sgxsdk/environment
  '';

  buildFlags =
    [ ("sgxssl" + lib.optionalString (!enableMitigation) "_no_mitigation") ];

  buildInputs = [ which perl ];

  installFlags = [ "DESTDIR=$(out)" ];
}
