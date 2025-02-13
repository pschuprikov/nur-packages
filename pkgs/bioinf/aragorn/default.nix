{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "1.2.38";
  name = "aragorn-${version}";

  src = fetchurl {
    url = "http://130.235.244.92/ARAGORN/Downloads/aragorn${version}.tgz";
    sha256 = "sha256:09i1rg716smlbnixfm7q1ml2mfpaa2fpn3hwjg625ysmfwwy712b";
  };

  buildPhase = ''
    $CC -o aragorn aragorn${version}.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp aragorn $out/bin/
  '';
  
  meta = {
    description = "tRNA (and tmRNA) detection";
    homepage = http://130.235.244.92/ARAGORN/;
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
  };
}
