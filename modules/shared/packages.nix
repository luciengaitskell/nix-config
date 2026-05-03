{ pkgs }:

with pkgs;
[
  # General packages for development and system management
  alacritty
  bash-completion
  bat
  btop
  coreutils
  killall
  openssh
  sqlite
  wget
  zip
  nixfmt
  yubikey-manager
  tailscale

  # Encryption and security tools
  age
  gnupg

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  dejavu_fonts
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-color-emoji
  meslo-lgs-nf
  spotify
  pandoc
  poppler-utils

  # Node.js development tools
  # nodePackages.npm # globally install npm
  # nodePackages.prettier
  # nodejs_24
  # yarn

  # Text and terminal utilities
  htop
  jetbrains-mono
  jq
  ripgrep
  tree
  tmux
  unzip

  # Development tools
  curl
  gh
  terraform
  kubectl
  awscli2
  lazygit
  fzf
  # direnv
  qemu
  cmake
  compiledb

  # Programming languages and runtimes
  go
  rustc
  cargo
  openjdk

  # Python packages
  python3
  uv

  # Dev tools
  vscode
  antigravity

  # Compilers
  gfortran14

  # Embedded dev
  platformio
  gcc-arm-embedded

  # Hardware dev
  iverilog
  verilator
  surfer
  openfpgaloader
  pulseview
  yosys

  # LaTeX
  texlive.combined.scheme-full
]
