{ version, sha256, postPatch ? "", patches ? [] }:
{ lib, stdenv, fetchurl, coreutils, procps, cpio, zlib, bzip2, pcre, lmdb, ApplicationServices }:
let oldPostPatch = postPatch;
    oldPatches = patches;
in stdenv.mkDerivation rec {
  inherit version;

  patches = oldPatches ++ lib.optional stdenv.isDarwin ./ncbi_test.patch;

  name = "ncbi-blast-${version}";
  src = fetchurl {
    url = "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${version}/${name}+-src.tar.gz";
    inherit sha256;
  };

  hardeningDisable = [ "format" ];

  postPatch = ''
    patchShebangs ./scripts

    for f in ./scripts/common/impl/*.sh ./src/build-system/Makefile* ./src/build-system/configure; do
      substituteInPlace $f \
        --replace "PATH=/bin:/usr/bin" "" \
        --replace "/bin/rm" "rm" \
        --replace "/bin/echo" "echo"\
        --replace "/bin/mkdir" "mkdir"\
        --replace "/bin/cp" "cp"\
        --replace "/bin/pwd" "pwd"\
        --replace "/bin/date" "date"\
        --replace "/bin/mv" "mv"\
        --replace "/bin/ln" "ln"\
        --replace "/bin/\$base_action" "\$base_action"\
        --replace "/bin/\$LN_S" "\$LN_S"\
        --replace "/usr/bin/dirname" "dirname" \
        2>/dev/null
    done
    substituteInPlace ./src/build-system/helpers/run_with_lock.c \
      --replace "/bin/rm" "${coreutils}/bin/rm" \
  '' + "\n" + oldPostPatch;

  preConfigure = ''
    export AR="$AR cr"
  '';

  configureFlags = [
    "--with-dll"
    "--without-boost"
  ];

  preBuild = ''
    makeFlagsArray+=(
      '-j'
      "-l''${NIX_BUILD_CORES}"
    )
  '';

  buildInputs = [ procps cpio ] ++ lib.optionals stdenv.isDarwin [ ApplicationServices ];

  nativeBuildInputs = [ zlib bzip2 pcre lmdb ];

  sourceRoot = "${name}+-src/c++";

  meta = with stdenv.lib; {
    platforms = platforms.unix;
  };
} // lib.optionalAttrs stdenv.isDarwin {
  configurePhase = ''
    echo "HI!!! It's me"
    cat config.log
    ./configure $configureFlags || cat config.log
  '';
}

