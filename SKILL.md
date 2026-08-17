---
name: deepseek-harness-plugin-dev
description: Rapidly develop, scaffold, modify, review, or plan plugins for the DeepSeek Harness repository. Use when working in deepseek-harness on Cordis plugins, model-facing tools, Service Definition/Provider/Consumer capability seams, LLM adapters, hook/policy plugins, UI/protocol drivers, package scaffolding, plugin tests, README Model Experience sections, Agent Notes, or related dsh package conventions.
---

# DeepSeek Harness Plugin Development

Use this skill to ship a small, correct DeepSeek Harness plugin change quickly while staying aligned with the repository's Cordis architecture, package conventions, documentation requirements, and verification policy.

## Required Orientation

Before changing code under `packages/`, read the active repository sources, not this skill alone:

- `AGENTS.md`
- `docs/architecture.md`
- `packages/AGENTS.md`
- `docs/cookbook/extension-cookbook.md`
- For new packages: `docs/cookbook/adding-a-package.md`
- For model-facing tools: `docs/cookbook/adding-a-tool.md`
- For lifecycle, subprocess, concurrency, or teardown work: `docs/defensive-patterns.md`
- For docs/prose changes: use `dsh-prose-standard`
- Before push or ready-for-review: use `dsh-pre-push-checks`

Read `references/playbooks.md` when the user wants a plugin implemented or scaffolded quickly.
Read `references/templates.md` when writing new package, plugin, README, invariant, or test skeletons.
Read `references/plugin-standards.md` when you need the compact rules checklist or when reviewing a plugin change.

## Fast Build Loop

1. Classify the request into one plugin type: model tool, hook/policy, context injector, Service Definition, Service Provider, Consumer, LLM adapter, UI/protocol driver, settings card, or bundle/profile wiring.
2. Load only the matching playbook and template references.
3. Inspect the closest existing package in the same role.
4. Produce the smallest working slice: package skeleton, registration, core behavior, README/JSDoc, invariant companion, and focused test plan.
5. Run the smallest checks that prove the slice.

For a new simple function plugin package, optionally use:

```bash
~/.codex/skills/deepseek-harness-plugin-dev/scripts/create-function-plugin.sh \
  /path/to/deepseek-harness <group> <pkg> [inject_csv]
```

The script creates starter files only. The agent must still inspect the live repository, add aggregate tsconfig references, add dependencies for injected services, and write behavior-specific tests.

## Workflow

1. State the target behavior, scope, completion criteria, and verification plan before editing.
2. Identify the plugin kind: tool, hook/policy, Service Definition, Service Provider, Consumer, LLM adapter, UI/protocol driver, settings card, or bundle/profile wiring.
3. Pick the documented extension point. Do not patch `agent-loop` for behavior that can attach through `ctx.tools`, `ctx.llm`, `ctx.agents`, `ctx.systemPrompt`, `session/event`, or a capability event.
4. Inspect the nearest existing package in the same role and follow its file layout, imports, README style, tests, and invariant companion pattern.
5. Keep the implementation scoped and simple. Add abstractions only for a current owner and current consumer.
6. Make registrations reversible with `ctx.effect()`, `ctx.on()`, or registry methods whose disposer is tied to the plugin fiber.
7. For any model-visible input or durable state, verify that it is reconstructable from the session log.
8. Add or update focused tests. Product-visible plugins require a real Loader/app/process composition test, not only hand-built `ctx.plugin(...)` tests.
9. Update README/JSDoc and add an Agent Note for non-trivial changes.
10. Run only the smallest checks that cover the changed surface, then report exactly what passed and what was not verified.

## Common Decisions

- Add a model-facing capability: register a typed tool on `ctx.tools`; if the capability is swappable, design the Service Definition, Provider, and Consumer roles together.
- Add request/tool policy: use `tools/pre-execute`, `ctx.tools.guard()`, `tools/execute`, `tools/post-execute`, or `tools/result` according to whether the plugin denies, wraps dispatch, transforms results, or observes final outcomes.
- Add model context: prefer `agent.inject()` or `agent/pre-step` with a durable `user/message` source. New model-visible facts usually need a `SessionEventMap` member and invariant.
- Add a provider: implement the Service Definition without importing consumers or provider-specific assumptions into the interface.
- Add a UI or protocol bridge: drive agents through `ctx.agents` and render from `session/event`.

## Guardrails

- Address the user as `老板` when replying in this project.
- Preserve UTF-8 Chinese text.
- Do not overwrite unrelated dirty worktree changes.
- Do not add compatibility shims for unreleased on-disk formats unless the user explicitly asks; this repo is pre-release.
- Do not hardcode deployment-varying tunables in plugin code; expose validated `Config` fields.
- Do not put UI, transport, or implementation vocabulary in model-facing prompts, tool schemas, results, or diagnostics.
