{ lib, buildFHSUserEnv, fetchurl, fakeroot }:
let
  src = fetchurl {
    url = "file:///anyconnect-linux64-4.10.01075-core-vpn-webdeploy-k9.sh";
    sha256 = "sha256-S94WjcEFldF/PGwEjQMasqtiybcfrjF5z8Ns2v1WPRw=";
  };
  installer =  buildFHSUserEnv {
    name = "vpn_install.sh";
    meta = with lib; {
      license = licenses.unfree;
    };
    extraBuildCommands = ''
      ${fakeroot}/bin/fakeroot -- bash ${src} || true
      echo $out
      mv /tmp/vpn $out
    '';
    runScript = "/vpn/vpn_install.sh";

    passthru = {
      inherit src;
    };
  };
in buildFHSUserEnv {
  name = "anyconnect";
  extraBuildCommands = ''
    ${installer}/bin/vpn_install.sh
  '';
}
