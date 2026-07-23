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
