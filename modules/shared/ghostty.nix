{ pkgs, lib, ... }:

{
  enable = true;
  package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
  enableZshIntegration = true;

  settings = {
    font-size = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 12)
    ];
    theme = "light:One Half Light,dark:One Half Dark";
  };
}
