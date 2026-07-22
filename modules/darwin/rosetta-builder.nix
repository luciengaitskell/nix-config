{ lib, ... }:

let
  # Fresh Apple silicon machine with no Linux builder yet:
  #   1. Set true, darwin-rebuild switch  (starts stock qemu builder)
  #   2. Set false, darwin-rebuild switch (builds rosetta image via still-running
  #      stock builder from the previous generation, then tears stock down)
  # Leave false afterward. Rosetta can rebuild itself from then on.
  bootstrapWithStockBuilder = false;
in
{
  nix.linux-builder = lib.mkIf bootstrapWithStockBuilder {
    enable = true;
    systems = [ "aarch64-linux" ];
  };

  # Upstream defaults enable=true, so always set it explicitly for mutual exclusion.
  nix-rosetta-builder = {
    enable = !bootstrapWithStockBuilder;
    onDemand = true;
    cores = 4;
    diskSize = "64GiB";
  };
}
