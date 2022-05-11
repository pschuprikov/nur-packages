{ stdenv, grpc, judy, protobuf3_2, openssl, boost, pkg-config, python3, autoconf
, automake, libtool, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "PI";
  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "PI";
    rev = "41358da0ff32c94fa13179b9cee0ab597c9ccbcc";
    sha256 = "sha256-bSsZDQtDrxBoJ8ll1Cu4guQVxNkAHQwfUBJQhrhPQ6c=";
    fetchSubmodules = true;
  };
  buildInputs = [ grpc judy protobuf3_2 openssl boost ];
  preConfigure = ''
    ./autogen.sh
  '';
  configureFlags = [ "--with-proto" "--with-boost-thread=boost_thread" ];
  nativeBuildInputs = [ python3 pkg-config autoconf automake libtool ];
  enableParallelBuilding = true;
}

