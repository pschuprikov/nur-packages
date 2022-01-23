{ version, sha256, extraPreConfigure ? "", patches ? [] }:
{ stdenv, lib, bison, flex, qtbase, openscenegraph, openmpi, python3, fetchurl, perl
, wrapQtAppsHook, mode ? "release", cppStandard ? null }:
let
  pythonWithDeps = python3.withPackages
    (pkgs: with pkgs; [ posix_ipc numpy scipy pandas matplotlib ]);
in stdenv.mkDerivation rec {
  pname = "omnetpp";
  inherit version patches;
  name = "${pname}-${version}";
  postPatch = ''
    substituteInPlace ./configure.user \
      --replace 'WITH_OSGEARTH=yes' 'WITH_OSGEARTH=no'
  '' + lib.optionalString (cppStandard != null) ''
    sed -i 's/^#CXXFLAGS=.*/CXXFLAGS=-std=${cppStandard}/' ./configure.user 
  '' + ''
    substituteInPlace ./src/utils/Makefile \
      --replace '#!/bin/sh' '#!${stdenv.shell}'
    substituteInPlace ./Makefile.inc.in \
      --replace '$(OMNETPP_ROOT)/images' '$(out)/images' \
      --replace '$(OMNETPP_ROOT)/lib' '$(out)/lib'
    patchShebangs ./src/utils/
  '';
  src = fetchurl {
    urls = [
      "https://github.com/${pname}/${pname}/releases/download/${pname}-${version}/${pname}-${version}-src-linux.tgz"
      "https://github.com/${pname}/${pname}/releases/download/${pname}-${version}/${pname}-${version}-linux-x86_64.tgz"
    ];
    inherit sha256;
  };
  preConfigure = ''
    unset AR
    export PATH=$PWD/bin:$PATH
    ${extraPreConfigure}
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
