{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  user = "lucg";

  # The sandbox launcher writes a generated authorized_keys file (collected
  # from the host's ~/.ssh/*.pub + ssh-add -L) and exports its path here.
  # Reading via getEnv requires `nix build --impure`. Keeping this as an
  # env var means the module has no host-specific paths baked in — anyone
  # can supply their own keys file by setting this variable.
  authorizedKeysFile = builtins.getEnv "DEVVM_AUTHORIZED_KEYS_FILE";

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

  assertions = [{
    assertion = authorizedKeysFile != "";
    message = ''
      devvm: DEVVM_AUTHORIZED_KEYS_FILE is unset.
      Build with `nix build --impure` and export DEVVM_AUTHORIZED_KEYS_FILE
      pointing to a file containing the authorized SSH public keys for the
      VM's primary user (the sandbox launcher does this for you).
    '';
  }];

  users.mutableUsers = false;
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keyFiles =
      lib.optional (authorizedKeysFile != "") (/. + authorizedKeysFile);
  };

  # NixOS's fstab→systemd path silently drops 9p mounts whose device is a
  # mount tag (not a path); the auto-generated .mount unit never starts.
  # systemd.mounts writes a unit file directly and bypasses that generator.
  systemd.mounts = [{
    what = "workdir";
    where = "/mnt/work";
    type = "9p";
    options = "trans=virtio,version=9p2000.L,msize=1048576";
    wantedBy = [ "multi-user.target" ];
  }];

  security.sudo.wheelNeedsPassword = false;

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

    # qemu-vm.nix defaults add /tmp/xchg and /tmp/shared 9p mounts (used by
    # the NixOS test framework). Our launcher doesn't provide those tags,
    # so override to keep only the nix-store share we do supply via -virtfs.
    sharedDirectories = lib.mkForce {
      nix-store = {
        source = builtins.storeDir;
        target = "/nix/.ro-store";
        securityModel = "none";
      };
    };
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

  # qemu-vm.nix expects the writable qcow2 to be an ext4 filesystem labelled
  # "nixos" (matching virtualisation.rootDevice = /dev/disk/by-label/nixos).
  # Stock nixos-rebuild build-vm creates this on the host with mkfs.ext4, but
  # we run on darwin where the launcher does it; building it as a derivation
  # is simpler than shelling out to mkfs.ext4 from the wrapper.
  system.build.devVmBlankDisk = pkgs.runCommand "devvm-blank-disk.qcow2"
    {
      nativeBuildInputs = [ pkgs.e2fsprogs pkgs.qemu_kvm ];
    }
    ''
      qemu-img create -f raw raw.img ${toString config.virtualisation.diskSize}M
      mkfs.ext4 -L nixos -F raw.img
      qemu-img convert -f raw -O qcow2 raw.img $out
    '';

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
    blankDisk = "${config.system.build.devVmBlankDisk}";
    serialConsole = serial;
    sshPort = 2222;
    sshUser = user;
  });
}
