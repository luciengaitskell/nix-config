
## Layout
```
.
├── dock               # MacOS dock configuration
├── casks.nix          # List of homebrew casks
├── default.nix        # Defines module, system-level config
├── files.nix          # Non-Nix, static configuration files (now immutable!)
├── home-manager.nix   # Defines user programs
├── rosetta-builder.nix # On-demand Linux builder (nix-rosetta-builder)
├── packages.nix       # List of packages to install for MacOS
```

## Bootstrap on a fresh Mac

`nix-rosetta-builder` needs an existing Linux builder the first time its VM image is built. After that it can rebuild itself.

Prerequisite:

```bash
softwareupdate --install-rosetta
```

In [`rosetta-builder.nix`](rosetta-builder.nix):

1. Set `bootstrapWithStockBuilder = true`, then `darwin-rebuild switch` (or your usual build-switch). This starts stock `nix.linux-builder`.
2. Confirm it is up: `launchctl print system/org.nixos.linux-builder`
3. Set `bootstrapWithStockBuilder = false`, then switch again. The previous generation’s stock builder builds the rosetta image; activation then removes stock and enables on-demand rosetta.

Leave the flag `false` afterward. If the Lima VM is wiped and no builder is available, repeat the two-switch dance.
