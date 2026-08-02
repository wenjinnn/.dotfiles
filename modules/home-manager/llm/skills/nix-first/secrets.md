# Secrets & Runtime Data

Rules for secrets (API keys, tokens) and mutable runtime data in a Nix-managed environment. Load when secrets or agent state are involved.

## Secrets

- **Never interpolate secrets into the Nix store** — store paths are world-readable and land in `/nix/store`
- Use sops-nix: `secrets.yaml` + age keys; one key per host (`.sops.yaml` defines host keys)
- Prefer `sops exec-env` / preLaunchHook patterns to inject secrets into a process env at launch — not into files that end up in the store
- Don't echo secret values into tool logs or agent output — redact in commands and responses
- The repo will not build without the age keys — expect build failures on machines missing them

## Runtime data (never declared in Nix)

- Agent memory, sessions DBs (e.g. `~/.pi/agent/pi-hermes-memory/*`), user profile, learning results — all mutable state
- Never move them into the store or into a Nix package
- Back up before upgrading or migrating the tool that owns them (see `nix-packing` Step 5)

## Verification

- Secret values appear nowhere in store paths, build logs, or `nix` evaluation output
- Runtime data survives an upgrade: backup → upgrade → restore
