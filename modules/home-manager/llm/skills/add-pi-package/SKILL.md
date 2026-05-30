---
name: add-pi-package
description: Add a new pi package to the NUR repository's piPackages set. Use when the user wants to package a pi/npm extension for Nix, mentions adding a pi package, provides a pi.dev/packages URL, or asks to package an npm extension for pi. Handles dependency detection, hash computation, lock file generation, and build verification.
---

# Add Pi Package

Package a pi coding agent extension (npm package) into the NUR repository's `piPackages` set.

## When to Use

- User provides a `pi.dev/packages/<name>` or `npmjs.org/package/<name>` URL
- User asks to "add", "package", or "打包" a pi package/extension
- User mentions a pi extension name to add to the NUR repo

## Prerequisites

- Working directory: NUR repository root (contains `pkgs/pi-packages/`)
- Nix with flakes enabled
- npm (for generating lock files when needed)

## Procedure

### Step 1: Get Package Info

Query npm registry to determine package metadata and dependency type:

```bash
curl -s "https://registry.npmjs.org/<scope>/<name>/latest" | jq '{name, version, dependencies, peerDependencies}'
```

**Decision point:**
- **No `dependencies`** (only `peerDependencies` or none) → Use simple extraction (`npmDepsHash = ""`)
- **Has `dependencies`** → Use `buildNpmPackage` with proper `npmDepsHash`

### Step 2: Get Tarball Hash

```bash
HASH=$(nix-prefetch-url --unpack "https://registry.npmjs.org/<scope>/<name>/-/<name>-<version>.tgz" 2>/dev/null)
nix hash to-sri --type sha256 "$HASH"
```

Note: The hash from `nix-prefetch-url` may differ from what nix expects during build. Be prepared to correct it if build fails with hash mismatch (use the `got:` value from the error).

### Step 3: Handle Dependencies (if any)

If the package has `dependencies`:

1. **Download and extract tarball:**
   ```bash
   mkdir -p /tmp/pi-packages-test/<name>
   cd /tmp/pi-packages-test/<name>
   curl -sL "https://registry.npmjs.org/<scope>/<name>/-/<name>-<version>.tgz" | tar xz --strip-components=1
   ```

2. **Generate lock file:**
   ```bash
   npm install --package-lock-only
   ```

3. **Clean lock file** — remove `@earendil-works/*` peer deps (they're private and unavailable on npm):
   ```bash
   cat package-lock.json | jq '
     .packages |= with_entries(
       select(.key == "" or (.key | test("node_modules/@earendil-works") | not))
     )
   ' > package-lock-cleaned.json
   ```

4. **Copy lock file to locks directory:**
   ```bash
   cp package-lock-cleaned.json <repo>/pkgs/pi-packages/locks/-<scope>-<name>-<version>.json
   ```

5. **Get npmDepsHash** — build with a placeholder to discover the real hash:
   ```bash
   cd <repo>
   nix build --impure --expr '
   let
     pkgs = import <nixpkgs> {};
     lib = pkgs.lib;
     mkNodePackage = import ./pkgs/pi-packages/mkNodePackage.nix { inherit pkgs lib; };
     locksDir = ./pkgs/pi-packages/locks;
     mkScopedPackage = scope: name: args: mkNodePackage (args // {
       inherit scope name;
       packageLockJson = locksDir + "/${lib.replaceStrings [ "@" "/" ] [ "-" "-" ] "${scope}/${name}"}-${args.version}.json";
     });
   in mkScopedPackage "<scope>" "<name>" {
     version = "<version>";
     hash = "<tarball-hash>";
     npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
     description = "test";
     homepage = "test";
   }
   ' 2>&1 | grep "got:"
   ```

### Step 4: Add Package to default.nix

Edit `pkgs/pi-packages/default.nix` and add the package definition. Place it in the appropriate section (or create a new section if the package category doesn't exist):

```nix
"<scope>/<name>" = mkScopedPackage "<scope>" "<name>" {
  version = "<version>";
  hash = "<tarball-hash>";
  npmDepsHash = "<deps-hash or empty string>";
  description = "<description from npm/GitHub>";
  homepage = "<GitHub repo URL>";
};
```

For unscoped packages, use `mkPackage` instead of `mkScopedPackage`.

### Step 5: Test Build

```bash
cd <repo>
nix build .#piPackages."<scope>/<name>" 2>&1
```

If hash mismatch error occurs, update the hash with the `got:` value and rebuild.

Verify the output:
```bash
ls result/           # Check files are present
ls result/node_modules/  # If has dependencies, verify they're installed
```

### Step 6: Add to check-updates.sh

Edit `scripts/check-updates.sh` and add an entry to the `PACKAGE_SOURCES` associative array:

```bash
["<scope>/<name>"]="<github-owner>/<github-repo>"
```

### Step 7: Commit

```bash
git add pkgs/pi-packages/default.nix \
        pkgs/pi-packages/locks/-<scope>-<name>-<version>.json \
        scripts/check-updates.sh
git commit -m "feat(pi-packages): add <scope>/<name> v<version>

- <short description>
- <dependency info: 'No dependencies' or 'Dependencies: X, Y'>
- Added to check-updates.sh"
```

## Pitfalls

- **Hash mismatch**: `nix-prefetch-url` hash may differ from build hash. Always use the `got:` value from the error message.
- **@earendil-works/* in lock files**: These are pi internal packages, not on npm. Remove them from lock files or `prefetch-npm-deps` will fail with "non-git dependencies should have associated integrity".
- **fakeHash value**: `lib.fakeHash` equals `sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=`. The `mkNodePackage` function treats this as "no dependencies" and uses simple extraction. Do NOT use this for packages with real dependencies.
- **Lock file not tracked by git**: Nix flakes require git-tracked files. Run `git add` on lock files before building.

## Verification

After commit, verify:
1. `nix build .#piPackages."<scope>/<name>"` succeeds
2. `bash scripts/check-updates.sh` shows the new package
3. `git log -1` shows the commit with correct message
