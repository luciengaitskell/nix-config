# sandboxes/nix-agent — Nix-ready Docker Sandbox templates
#
# Variants: claude-code, cursor-agent, gemini (no -docker siblings)
#
# Build all:
#   cd sandboxes/nix-agent && docker buildx bake
#
# Build one:
#   docker buildx bake nix-agent-claude-code
#
# Load into the sbx runtime (daemon does not share the host image store):
#   docker image save nix-agent:claude-code -o /tmp/nix-agent-claude-code.tar
#   sbx template load /tmp/nix-agent-claude-code.tar
#
# Run (agent name must match the base variant):
#   sbx run --template nix-agent:claude-code claude
#   sbx run --template nix-agent:cursor-agent cursor
#   sbx run --template nix-agent:gemini gemini
#
# Optional Nix network allowlist if the default policy blocks caches:
#   sbx policy allow network "cache.nixos.org:443,*.cachix.org:443,install.determinate.systems:443"

variable "VARIANTS" {
  default = ["claude-code", "cursor-agent", "gemini"]
}

target "nix-agent" {
  name       = "nix-agent-${variant}"
  matrix     = { variant = VARIANTS }
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    VARIANT = variant
  }
  tags = ["nix-agent:${variant}"]
}
