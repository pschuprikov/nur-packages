{ fetchurl, stdenv, autoPatchelfHook, coreutils }:
stdenv.mkDerivation {
  name = "canon-ppd";
  src = fetchurl {
    url = "file://CQue_Linux_v4.0.8_64_EN.tar.gz";
    sha256 = "sha256-OJM+kb7Dp60Egj59xjyEeRyjEUadiM2GeyRoI6IHCko=";
  };

  buildInputs = [ autoPatchelfHook ];

  patchPhase = ''
    autoPatchelfFile sicgsfilter
  '';

  buildPhase = ''
    gzip --decompress ppd/cel-iradvc5550-ps-en.ppd.gz
    substituteInPlace ppd/cel-iradvc5550-ps-en.ppd \
      --replace /bin/cat ${coreutils}/bin/cat \
      --replace sicgsfilter $out/bin/sicgsfilter
  '';

  installPhase = ''
    install -d $out/bin
    install sicgsfilter $out/bin

    install -d $out/share/cups/model/Canon
    install ppd/*.ppd $out/share/cups/model/Canon
  '';
}