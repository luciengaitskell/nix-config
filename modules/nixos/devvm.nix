{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  user = "lucg";
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
  ];

  closureInfo = pkgs.closureInfo {
    rootPaths = [ config.system.build.toplevel ];
  };

  serial =
    if pkgs.stdenv.hostPlatform.isAarch64 then "ttyAMA0"
    else "ttyS0";
in
{
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];

  networking = {
    hostName = "devvm";
    firewall.enable = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.mutableUsers = false;
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = sshKeys;
    shell = pkgs.bashInteractive;
  };

  security.sudo.wheelNeedsPassword = false;

  fileSystems."/mnt/work" = {
    device = "workdir";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
      "msize=1048576"
      "nofail"
    ];
    neededForBoot = false;
  };

  boot.kernelModules = [ "9p" "9pnet_virtio" ];

  virtualisation = {
    cores = 4;
    memorySize = 4096;
    diskSize = 8192;
    graphics = false;
    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    jq
    ripgrep
    fd
    tmux
    htop
  ];

  system.stateVersion = "24.11";

  # Exposed for apps/aarch64-darwin/sandbox to launch QEMU itself.
  # NixOS's stock run-vm script bundles a Linux qemu binary that won't run
  # on darwin, so the host wrapper invokes darwin-native qemu using these paths.
  system.build.devVmInfo = pkgs.writeText "devvm-info.json" (builtins.toJSON {
    system = pkgs.stdenv.hostPlatform.system;
    toplevel = "${config.system.build.toplevel}";
    kernel = "${config.system.build.toplevel}/kernel";
    initrd = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
    init = "${config.system.build.toplevel}/init";
    kernelParamsFile = "${config.system.build.toplevel}/kernel-params";
    regInfo = "${closureInfo}/registration";
    serialConsole = serial;
    sshPort = 2222;
    sshUser = user;
  });
}
