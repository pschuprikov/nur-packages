{ stdenv, bison, flex, qtbase, openscenegraph, openmpi, python3, fetchurl, perl, wrapQtAppsHook, mode ? "release" }:
let
  pythonWithDeps = python3.withPackages
    (pkgs: with pkgs; [ posix_ipc numpy scipy pandas matplotlib ]);
in stdenv.mkDerivation rec {
  pname = "omnetpp";
  name = "${pname}-${version}";
  version = "5.6.2";
  patches = [ ./dont-touch-home.patch ];
  postPatch = ''
    substituteInPlace ./configure.user \
      --replace 'WITH_OSGEARTH=yes' 'WITH_OSGEARTH=no'
    substituteInPlace ./src/utils/Makefile \
      --replace '#!/bin/sh' '#!${stdenv.shell}'
    substituteInPlace ./Makefile.inc.in \
      --replace '$(OMNETPP_ROOT)/images' '$(out)/images' \
      --replace '$(OMNETPP_ROOT)/lib' '$(out)/lib'
    patchShebangs ./src/utils/
  '';
  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/${pname}-${version}/${pname}-${version}-src-linux.tgz";
    sha256 = "sha256-l7DWUzmEhtwXK4Qnb4Xv1izQiwKftpnI5QeqDpJ3G2U=";
  };
  preConfigure = ''
    unset AR
    export PATH=$PATH:$PWD/bin
  '';
  installPhase = ''
    mkdir -p $out
    cp -vr Makefile.inc lib bin include images $out/
  '';
  makeFlags = [ "MODE=${mode}" ];
  enableParallelBuilding = true;
  nativeBuildInputs = [ perl bison flex pythonWithDeps wrapQtAppsHook ];
  buildInputs = [ openscenegraph openmpi ];
}
