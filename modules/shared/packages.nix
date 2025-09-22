{ pkgs }:

with pkgs;
[
  # General packages for development and system management
  alacritty
  aspell
  aspellDicts.en
  bash-completion
  bat
  btop
  coreutils
  killall
  neofetch
  openssh
  sqlite
  wget
  zip
  gh
  nixfmt-rfc-style
  qemu
  cmake
  bear

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  emacs-all-the-icons-fonts
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf
  spotify

  # Node.js development tools
  nodePackages.npm # globally install npm
  nodePackages.prettier
  nodejs
  yarn

  # Text and terminal utilities
  htop
  hunspell
  iftop
  jetbrains-mono
  jq
  ripgrep
  tree
  tmux
  unrar
  unzip
  zsh-powerlevel10k

  # Python packages
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
  surfer
  openfpgaloader
  pulseview

  # LaTeX
  texlive.combined.scheme-full
]
