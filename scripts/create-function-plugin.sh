#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  create-function-plugin.sh <deepseek-harness-root> <group> <pkg> [inject_csv]

Example:
  create-function-plugin.sh ~/project/github/deepseek-harness context request-marker agents

Creates a starter function-plugin package only. It does not edit aggregate
tsconfig files, bundle/profile config, or dependency lists for injected services.
EOF
}

if [[ $# -lt 3 || $# -gt 4 ]]; then
  usage
  exit 2
fi

REPO_ROOT="$1"
GROUP="$2"
PKG="$3"
INJECT_CSV="${4:-}"

case "$GROUP" in
  (*[!a-z0-9-]*|'') echo "group must use lowercase letters, digits, and hyphens" >&2; exit 2 ;;
esac
case "$PKG" in
  (*[!a-z0-9-]*|'') echo "pkg must use lowercase letters, digits, and hyphens" >&2; exit 2 ;;
esac

if [[ ! -f "$REPO_ROOT/docs/architecture.md" || ! -f "$REPO_ROOT/packages/AGENTS.md" ]]; then
  echo "not a deepseek-harness checkout: $REPO_ROOT" >&2
  exit 2
fi

TARGET="$REPO_ROOT/packages/$GROUP/$PKG"
if [[ -e "$TARGET" ]]; then
  echo "target already exists: $TARGET" >&2
  exit 1
fi

PACKAGE_NAME="@deepseek-ai/dsh-$PKG"
VERSION="$(cd "$REPO_ROOT" && node -e "console.log(require('./package.json').version)")"

INJECT_LINE=""
if [[ -n "$INJECT_CSV" ]]; then
  IFS=',' read -r -a INJECTS <<< "$INJECT_CSV"
  QUOTED=()
  for item in "${INJECTS[@]}"; do
    item="${item//[[:space:]]/}"
    [[ -n "$item" ]] || continue
    case "$item" in
      (*[!a-zA-Z0-9_-]*)
        echo "inject entries must be service keys, got: $item" >&2
        exit 2
        ;;
    esac
    QUOTED+=("'$item'")
  done
  if [[ ${#QUOTED[@]} -gt 0 ]]; then
    joined="$(IFS=', '; echo "${QUOTED[*]}")"
    INJECT_LINE=$'/** Services required before this plugin can register. */\nexport const inject = ['"$joined"$']\n'
  fi
fi

mkdir -p "$TARGET/src" "$TARGET/tests"

cat > "$TARGET/package.json" <<EOF
{
  "name": "$PACKAGE_NAME",
  "description": "TODO: describe the current plugin responsibility",
  "version": "$VERSION",
  "publishConfig": {
    "access": "public"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/deepseek-ai/deepseek-harness.git",
    "directory": "packages/$GROUP/$PKG"
  },
  "type": "module",
  "main": "lib/index.js",
  "types": "lib/types/index.d.ts",
  "exports": {
    ".": {
      "types": "./lib/types/index.d.ts",
      "default": "./lib/index.js"
    },
    "./invariant": {
      "types": "./lib/types/invariant.d.ts",
      "default": "./lib/invariant.js"
    },
    "./src/*": "./src/*",
    "./package.json": "./package.json"
  },
  "files": [
    "lib/index.js",
    "lib/invariant.js",
    "lib/types/**/*.d.ts"
  ],
  "license": "MIT",
  "peerDependencies": {
    "@deepseek-ai/dsh-invariants": "workspace:^",
    "@deepseek-ai/cordis": "workspace:^"
  },
  "devDependencies": {
    "@deepseek-ai/dsh-invariants": "workspace:^",
    "@deepseek-ai/cordis": "workspace:^"
  }
}
EOF

cat > "$TARGET/tsconfig.json" <<'EOF'
{
  "extends": "../../../tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "src",
    "outDir": "lib/types"
  },
  "include": ["src"],
  "references": [
    {
      "path": "../../../vendor/cosmokit"
    },
    {
      "path": "../../../vendor/cordis"
    },
    {
      "path": "../../runtime-diagnostics/invariants"
    }
  ]
}
EOF

cat > "$TARGET/src/index.ts" <<EOF
/**
 * TODO: replace with the package contract.
 *
 * @module $PACKAGE_NAME
 */

import type { Context } from '@deepseek-ai/cordis'

/** Cordis plugin name used by loader diagnostics. */
export const name = '$PKG'

$INJECT_LINE/**
 * Register this plugin's contribution for the lifetime of \`ctx\`.
 * @param ctx - plugin context carrying required services.
 */
export function apply(ctx: Context): void {
  ctx.effect(() => {
    // TODO: register one current contribution and return its disposer.
    return () => {}
  })
}
EOF

cat > "$TARGET/src/invariant.ts" <<EOF
/**
 * Package-owned invariant companion for \`$PACKAGE_NAME\`.
 * @module $PACKAGE_NAME/invariant
 */

/* jscpd:ignore-start */
import type { Context } from '@deepseek-ai/cordis'
import type { InvariantInstaller } from '@deepseek-ai/dsh-invariants'

const PACKAGE_NAME = '$PACKAGE_NAME'

/** Cordis companion plugin name. */
export const name = '$PKG-invariant'
/** Service required before the companion can reserve package ownership. */
export const inject = ['invariants']

/**
 * No runtime invariant: TODO replace with the package-specific reason or add relational checks.
 */
const install: InvariantInstaller = () => {}

/**
 * Register this package's invariant companion.
 * @param ctx - Cordis context carrying the invariant service.
 * @returns the installed registration's disposer after setup succeeds.
 */
export const apply = (ctx: Context): Promise<() => void> =>
  Promise.resolve(ctx.invariants.register(PACKAGE_NAME, install))
/* jscpd:ignore-end */
EOF

cat > "$TARGET/README.md" <<EOF
# $PACKAGE_NAME

TODO: describe the plugin's current responsibility, config, extension points, and owned behavior.

## Model Experience

### Direct contribution

#### What the model sees

TODO: state exact model-visible text/schema or use an allowed no-direct-effect sentence.

#### Token effect

TODO: fixed, conditional, retained, replaced, capped, or zero-direct token effect.

#### KV Cache effect

TODO: prefix-stable, append-only, replacing, or independent request behavior.

## Known Limitations and Deferred Work

- **TODO** — replace with a consumer-visible gap or add a justified allowlist entry.
EOF

cat > "$TARGET/tests/.gitkeep" <<'EOF'
EOF

cat >&2 <<EOF
Created $TARGET

Next steps:
1. Add {"path": "./packages/$GROUP/$PKG"} to the correct aggregate tsconfig.
2. Add peer/dev dependencies for injected services: ${INJECT_CSV:-none}.
3. Replace TODOs in README.md, src/index.ts, and src/invariant.ts.
4. Add behavior tests under packages/$GROUP/$PKG/tests.
5. Run pnpm run constraints && pnpm run typecheck.
EOF
