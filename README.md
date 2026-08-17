# DeepSeek Harness Plugin Dev Skill

Codex skill for planning, implementing, and reviewing plugin work in the
[`deepseek-harness`](https://github.com/codepunk-gm/deepseek-harness) repository.

The runtime skill entrypoint is [`SKILL.md`](SKILL.md). The compact implementation
checklist lives in [`references/plugin-standards.md`](references/plugin-standards.md).

## Use Cases

- Develop or modify Cordis plugins under `packages/`.
- Add model-facing tools, hook/policy plugins, LLM adapters, Service Providers, or Consumers.
- Plan capability seams across Service Definition, Provider, and Consumer roles.
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
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py ~/.codex/skills/deepseek-harness-plugin-dev
```

If the host Python lacks `PyYAML`, run the validator from an environment that has it installed.

## Maintenance

Keep `SKILL.md` concise and procedural. Put only reusable, task-specific details in
`references/`, and verify changes against the live `deepseek-harness` repository docs
before treating this skill as current.
