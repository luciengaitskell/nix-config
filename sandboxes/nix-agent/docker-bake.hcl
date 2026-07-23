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
# Kits (mixin network allowlists under sandboxes/kits/ — stack with --kit):
#   sbx run claude \
#     --template nix-agent:claude-code \
#     --kit ~/nix-config/sandboxes/kits/nix \
#     --kit ./sbx/espressif
#
# Copy sandboxes/kits/espressif into a project as sbx/espressif when needed.
# Prefer kits over one-off: sbx policy allow network "..."

variable "VARIANTS" {
  default = ["claude-code", "cursor-agent", "gemini"]
}

group "default" {
  targets = ["nix-agent"]
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
