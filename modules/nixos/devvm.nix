{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  user = "lucg";

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
  # Authorized keys are injected at runtime by import-host-ssh-keys.service
  # below, so the NixOS build sees no static credentials. Quiet the check.
  users.allowNoPasswordLogin = true;
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
  };

  # NixOS's fstab→systemd path silently drops 9p mounts whose device is a
  # mount tag (not a path). The .mount units never run, so we mount both
  # 9p shares ourselves in a oneshot before sshd. Logs go to /dev/kmsg
  # (kernel printk → console, unbuffered) so failures surface in the
  # wrapper's serial tail dump even when sshd auth then fails.
  systemd.services.devvm-setup = {
    description = "Mount host 9p shares and import SSH authorized_keys";
    wantedBy = [ "multi-user.target" "sshd.service" ];
    before = [ "sshd.service" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
    path = [ pkgs.util-linux pkgs.openssh ];
    script = ''
      set -u
      log() { echo "[devvm] $*" | tee /dev/kmsg; }
      log "devvm-setup starting"
      mount_9p() {
        tag=$1
        target=$2
        opts=$3
        if mountpoint -q "$target"; then
          log "$target already mounted"
          return 0
        fi
        mkdir -p "$target"
        if mount -t 9p -o "$opts" "$tag" "$target" 2>&1 | tee /dev/kmsg; then
          log "mounted $tag → $target"
        else
          log "FAIL: mount $tag → $target"
          return 1
        fi
      }
      mount_9p hostkeys /mnt/hostkeys "trans=virtio,version=9p2000.L,ro"
      mount_9p workdir  /mnt/work     "trans=virtio,version=9p2000.L,msize=1048576"

      src=/mnt/hostkeys/authorized_keys
      dst=/home/${user}/.ssh/authorized_keys
      if [ ! -f "$src" ]; then
        log "FAIL: $src missing"
        exit 1
      fi
      install -d -m 700 -o ${user} -g users /home/${user}/.ssh
      install -m 600 -o ${user} -g users "$src" "$dst"
      log "wrote $dst ($(wc -c < "$dst") bytes, $(wc -l < "$dst") lines)"
      log "devvm-setup done"
    '';
  };

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
