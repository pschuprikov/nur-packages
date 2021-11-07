{ stdenv, fetchurl, python3, perl, openscenegraph, libGL, omnetpp, mode ? "release" }:
stdenv.mkDerivation rec {
  pname = "inet";
  name = "${pname}-${version}";
  version = "4.2.5";
  src = fetchurl {
    url = "https://github.com/inet-framework/${pname}/releases/download/v${version}/${pname}-${version}-src.tgz";
    sha256 = "sha256-ThMz014tXjVa/OUL4xUm7Xyw/4X5QCNwSzzg3nzbIz4=";
  };
  configureScript = "make makefiles";
  makeFlags = [ "MODE=${mode}" ];
  dontAddPrefix = true;
  nativeBuildInputs = [ python3 perl ];
  buildInputs = [ openscenegraph libGL omnetpp ];
  enableParallelBuilding = true;

  meta = {
    broken = true;
  };
}
