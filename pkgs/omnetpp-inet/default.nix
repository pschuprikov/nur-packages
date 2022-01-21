{ callPackage }: {
  omnetpp-inet_4_2_5 = callPackage (import ./common.nix { 
    version = "4.2.5";
    sha256 = "sha256-ThMz014tXjVa/OUL4xUm7Xyw/4X5QCNwSzzg3nzbIz4=";
  }) { };
}
