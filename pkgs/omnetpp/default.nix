{ callPackage }:
{
  omnetpp_5_6_2 = callPackage (import ./common.nix {
    version = "5.6.2";
    sha256 = "sha256-l7DWUzmEhtwXK4Qnb4Xv1izQiwKftpnI5QeqDpJ3G2U=";
    patches = [ ./dont-touch-home.patch ];
  }) {};

  omnetpp_5_7 = callPackage (import ./common.nix {
    version = "5.7";
    sha256 = "sha256-BNx7NzG1vVY44fRu8h+virlVLY2rShS9Iil0EeJXM5k=";
    extraPreConfigure = ''
      export __omnetpp_root_dir=$PWD
    '';
    patches = [ ./dont-touch-home.patch ];
  }) {};

  omnetpp_6_0 = callPackage (import ./common.nix {
    version = "6.0pre13";
    sha256 = "sha256-bjXX8DtmdxkwQ9TuOOl5anIoZ07AcwFRT+BoZ2Uet9g=";
    extraPreConfigure = ''
      export PYTHONPATH=$PWD/python
      export __omnetpp_root_dir=$PWD
    '';
  }) {};
}
