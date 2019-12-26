{ version, sha256, postPatch ? "", patches ? [] }:
{ lib, stdenv, fetchurl, coreutils, procps, cpio, zlib, bzip2, pcre, lmdb, ApplicationServices }:
let oldPostPatch = postPatch; oldPatches = patches;
in stdenv.mkDerivation rec {
  inherit version;

  patches = oldPatches;

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
        --replace "/usr/bin/sort" "sort" \
        2>/dev/null
    done
    substituteInPlace ./src/build-system/helpers/run_with_lock.c \
      --replace "/bin/rm" "${coreutils}/bin/rm" \
  '' + "\n" + oldPostPatch;

  preConfigure = ''
    unset AR
  '';

  configureFlags = [
    # with flat make file we can use all_projects not to build everything
    "--with-flat-makefile"
    "--with-dll"
    "--without-autodep"
    "--without-makefile-auto-update"
    "--without-boost"
  ];

  preBuild = ''
    makeFlagsArray+=(
      '-j'
      "-l''${NIX_BUILD_CORES}"
      'all_projects=app/'
    )
  '';

  buildInputs = [ procps cpio ] ++ lib.optionals stdenv.isDarwin [ ApplicationServices ];

  nativeBuildInputs = [ zlib bzip2 pcre lmdb ];

  sourceRoot = "${name}+-src/c++";

  meta = with stdenv.lib; {
    platforms = platforms.unix;
  };
}
