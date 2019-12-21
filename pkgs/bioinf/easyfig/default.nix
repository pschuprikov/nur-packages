{ lib, fetchFromGitHub, tkinter, buildPythonApplication, ncbi_blast }:
buildPythonApplication rec {
  version = "2.2.3";
  pname = "Easyfig";

  src = fetchFromGitHub {
    owner = "mjsull";
    repo = "Easyfig";
    rev = "${version}";
    sha256 = "sha256:0cfmwnn6nxd56ngmwj7alhs2l0waby2wnxg2azw1lvqxpa9xksy6";
  };

  configurePhase = "true";
  buildPhase = "true";
  checkPhase = "true";

  installPhase = ''
    install -d $out/bin
    install -t $out/bin Easyfig.py
    runHook postInstall
    wrapProgram $out/bin/Easyfig.py --prefix PATH : ${lib.makeBinPath [ ncbi_blast ]}
  '';

  propagatedBuildInputs = [ tkinter ];

  meta = {
    plaftorms = lib.plaftorms.linux;
  };
}
