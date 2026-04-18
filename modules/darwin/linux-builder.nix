{ ... }:

{
  nix = {
    distributedBuilds = true;

    linux-builder = {
      enable = true;
      systems = [ "aarch64-linux" ];
      config = {
        nix.settings = {
          "download-buffer-size" = 134217728;
        };
      };
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
