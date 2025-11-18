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
  nixfmt-rfc-style
  yubikey-manager

  # Encryption and security tools
  age
  gnupg

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  emacs-all-the-icons-fonts
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
  nodePackages.npm # globally install npm
  nodePackages.prettier
  nodejs_24
  yarn

  # Text and terminal utilities
  htop
  jetbrains-mono
  jq
  ripgrep
  tree
  tmux
  unzip
  zsh-powerlevel10k

  # Development tools
  curl
  gh
  terraform
  kubectl
  awscli2
  lazygit
  fzf
  direnv
  qemu
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

  # Compilers
  gfortran14

  # Embedded dev
  platformio
  gcc-arm-embedded

  # Hardware dev
  verible
  iverilog
  verilator
  surfer
  openfpgaloader
  pulseview

  # LaTeX
  texlive.combined.scheme-full
]
