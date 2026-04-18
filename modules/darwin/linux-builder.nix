{ ... }:

{
  nix = {
    distributedBuilds = true;

    linux-builder = {
      enable = true;
      systems = [ "aarch64-linux" ];
      supportedFeatures = [
        "benchmark"
        "big-parallel"
      ];
    };

    settings = {
      builders-use-substitutes = true;
    };
  };
}
