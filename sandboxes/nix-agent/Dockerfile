# Nix-ready Docker Sandbox template.
# Extends official sandbox-templates so agent wiring + sbx credential proxy stay intact.
#
# Build (all variants):  docker buildx bake
# Load into sbx:         docker image save nix-agent:claude-code -o /tmp/nix-agent-claude-code.tar
#                        sbx template load /tmp/nix-agent-claude-code.tar
# Run:                   sbx run --template nix-agent:claude-code claude
#
# Network: under default sbx policies you may need to allow Nix caches, e.g.
#   sbx policy allow network "cache.nixos.org:443,*.cachix.org:443,install.determinate.systems:443"

ARG VARIANT=claude-code
FROM docker/sandbox-templates:${VARIANT}

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates xz-utils \
  && rm -rf /var/lib/apt/lists/*

# Single-user Nix (no systemd in sandbox containers). Chown /nix so `agent` can use it.
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install linux \
    --init none \
    --no-confirm \
    --extra-conf "sandbox = false" \
    --extra-conf "experimental-features = nix-command flakes" \
    --extra-conf "trusted-users = root agent" \
  && chown -R agent:agent /nix

ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

USER agent
WORKDIR /home/agent

ENV PATH="/nix/var/nix/profiles/default/bin:/home/agent/.nix-profile/bin:${PATH}"

# direnv + nix-direnv: flaked workspaces auto-enter via `use flake` in .envrc
RUN nix profile install nixpkgs#direnv nixpkgs#nix-direnv \
  && mkdir -p /home/agent/.config/direnv \
  && printf '%s\n' 'source "$HOME/.nix-profile/share/nix-direnv/direnvrc"' \
       > /home/agent/.config/direnv/direnvrc \
  && touch /home/agent/.bashrc /home/agent/.zshrc \
  && printf '\n%s\n%s\n' \
       '# Nix (sandbox nix-agent template)' \
       'export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"' \
       >> /home/agent/.bashrc \
  && printf '%s\n' 'eval "$(direnv hook bash)"' >> /home/agent/.bashrc \
  && printf '\n%s\n%s\n' \
       '# Nix (sandbox nix-agent template)' \
       'export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"' \
       >> /home/agent/.zshrc \
  && printf '%s\n' 'eval "$(direnv hook zsh)"' >> /home/agent/.zshrc
