{ buildArb, fetchsvn, pkg-config, arbcore, arbcommon, arbslcb, glib, libtirpc }:
buildArb rec {
  version = "6.0.6";
  name = "arbdb-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/ARBDB";
    rev = "18244";
    sha256 = "sha256:0374rwjzkcjzy25gnrk1pnz9w5ssd0l71sghr81gmnc0wihpgf1k";
  };

  MAIN="libARBDB.a";

  nativeBuildInputs = [ pkg-config arbcore arbcommon glib arbslcb libtirpc ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags glib-2.0) $(pkg-config --cflags libtirpc)"
  '';

  installPhase = ''
    mkdir -p $out/lib/
    cp libARBDB.so $out/lib/
    mkdir -p $out/include/
    cp ad_cb.h ad_cb_prot.h ad_config.h ad_p_prot.h \
       ad_prot.h ad_remote.h ad_t_prot.h adGene.h adperl.h \
       arbdb.h arbdbt.h dbitem_set.h \
       $out/include/
  '';
}

