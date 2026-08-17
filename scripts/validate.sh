#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFFICIAL="${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py"

if [[ -f "$OFFICIAL" ]] && command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' >/dev/null 2>&1
import yaml
PY
  then
    python3 "$OFFICIAL" "$ROOT"
    exit 0
  fi
fi

echo "official quick_validate.py is unavailable or PyYAML is missing; running bash smoke checks"

[[ -f "$ROOT/SKILL.md" ]] || { echo "missing SKILL.md" >&2; exit 1; }
[[ -f "$ROOT/agents/openai.yaml" ]] || { echo "missing agents/openai.yaml" >&2; exit 1; }
[[ -f "$ROOT/references/plugin-standards.md" ]] || { echo "missing references/plugin-standards.md" >&2; exit 1; }
[[ -f "$ROOT/references/playbooks.md" ]] || { echo "missing references/playbooks.md" >&2; exit 1; }
[[ -f "$ROOT/references/templates.md" ]] || { echo "missing references/templates.md" >&2; exit 1; }

first_line="$(sed -n '1p' "$ROOT/SKILL.md")"
[[ "$first_line" == "---" ]] || { echo "SKILL.md must start with YAML frontmatter" >&2; exit 1; }
grep -Eq '^name: deepseek-harness-plugin-dev$' "$ROOT/SKILL.md" || { echo "missing skill name" >&2; exit 1; }
grep -Eq '^description: .{80,}$' "$ROOT/SKILL.md" || { echo "description is missing or too short" >&2; exit 1; }
! grep -R '\[TODO\]\|TODO:' "$ROOT/SKILL.md" "$ROOT/references/plugin-standards.md" "$ROOT/references/playbooks.md" >/dev/null || { echo "TODO placeholder found in runtime instructions" >&2; exit 1; }
grep -Fq 'scripts/create-function-plugin.sh' "$ROOT/SKILL.md" || { echo "SKILL.md does not mention scaffold script" >&2; exit 1; }

echo "bash smoke checks passed"
