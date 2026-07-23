ARG VARIANT=claude-code
FROM docker/sandbox-templates:${VARIANT}

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates xz-utils \
  && rm -rf /var/lib/apt/lists/*

# Single-user Nix (no systemd in sandbox containers). Chown /nix so `agent` can use it.
# Download then exec (not curl|sh) so a failed download fails the layer build.
RUN curl --proto '=https' --tlsv1.2 -sSf -L -o /tmp/nix-installer \
      https://install.determinate.systems/nix \
  && sh /tmp/nix-installer install linux \
    --init none \
    --no-confirm \
    --extra-conf "sandbox = false" \
    --extra-conf "experimental-features = nix-command flakes" \
    --extra-conf "trusted-users = root agent" \
  && rm -f /tmp/nix-installer \
  && chown -R agent:agent /nix

ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

USER agent
WORKDIR /home/agent

ENV PATH="/nix/var/nix/profiles/default/bin:/home/agent/.nix-profile/bin:${PATH}"
