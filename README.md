# DeepSeek Harness Plugin Dev Skill

Codex skill for planning, implementing, and reviewing plugin work in the
[`deepseek-harness`](https://github.com/codepunk-gm/deepseek-harness) repository.

The runtime skill entrypoint is [`SKILL.md`](SKILL.md). Fast implementation
paths live in [`references/playbooks.md`](references/playbooks.md), starter
snippets live in [`references/templates.md`](references/templates.md), and the
compact rules checklist lives in [`references/plugin-standards.md`](references/plugin-standards.md).

## Use Cases

- Develop or modify Cordis plugins under `packages/`.
- Add model-facing tools, hook/policy plugins, LLM adapters, Service Providers, or Consumers.
- Plan capability seams across Service Definition, Provider, and Consumer roles.
- Scaffold a simple function plugin package and then finish it against the live repository rules.
- Keep tests, README Model Experience sections, JSDoc, Agent Notes, and verification aligned with the repository rules.

## Install

Clone this repository into your Codex skills directory:

```sh
git clone https://github.com/codepunk-gm/deepseek-harness-plugin-dev.git ~/.codex/skills/deepseek-harness-plugin-dev
```

Codex can then invoke it automatically for matching DeepSeek Harness plugin tasks, or explicitly with:

```text
Use $deepseek-harness-plugin-dev to plan and implement a DeepSeek Harness plugin change.
```

## Validate

Run the standard skill validator:

```sh
~/.codex/skills/deepseek-harness-plugin-dev/scripts/validate.sh
```

The script prefers the official `skill-creator` Python validator when `PyYAML`
is available, then falls back to bash smoke checks. The fallback is useful for
local edits but is not a full replacement for the official validator.

## Scaffold

For a simple function plugin package:

```sh
~/.codex/skills/deepseek-harness-plugin-dev/scripts/create-function-plugin.sh \
  ~/project/github/deepseek-harness context request-marker agents
```

The scaffold creates starter package files only. It does not edit aggregate
tsconfig files, bundle/profile config, or behavior-specific dependencies.

## Maintenance

Keep `SKILL.md` concise and procedural. Put reusable implementation paths and
templates in `references/`, keep scripts conservative, and verify changes
against the live `deepseek-harness` repository docs before treating this skill
as current.
