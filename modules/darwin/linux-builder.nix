{ lib, ... }:

{
  nix = {
    distributedBuilds = true;

    linux-builder = {
      enable = true;
      systems = [ "aarch64-linux" ];
      config = {
        virtualisation.cores = lib.mkForce 4;
        virtualisation.diskSize = lib.mkForce 65536;
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
