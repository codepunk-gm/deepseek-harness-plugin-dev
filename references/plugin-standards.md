# DeepSeek Harness Plugin Standards

Use this reference as a compact checklist after reading the live repository documents.

## Cordis Plugin Basics

- Function plugins named-export `name`, optional `inject`, optional `Config`, and `apply(ctx)`. They must not default-export.
- Service packages default-export the service class.
- Declare required services through `inject`; use `ctx.<name>` only for declared injections.
- Use `ctx.get(name)` for optional services.
- Communicate across plugins through services and typed events, not by importing concrete providers.
- Every contribution must be disposable. Use `ctx.effect()`, `ctx.on()`, `ctx.waterfall()`, registry return disposers, or an equivalent fiber-owned teardown path.
- Waterfall listeners must call `next()` unless they intentionally short-circuit a decision.

## Capability Roles

A replaceable capability normally has three roles:

- Service Definition: declares the interface and owns shared types/events.
- Service Provider: implements the interface for one mechanism, vendor, protocol, or environment.
- Consumer: uses the service, commonly as a model-facing tool.

Split roles into packages when they evolve independently. Keep tool-schema, Loader, UI, transport, and provider-specific behavior out of the Service Definition unless all current consumers need it.

## Package Rules

- Package path: `packages/<group>/<pkg>/`.
- Package name: `@deepseek-ai/dsh-<name>`.
- Use ESM: `"type": "module"`.
- Source relative imports use explicit `.ts` specifiers.
- Cross-package imports use package names.
- `@deepseek-ai/cordis` belongs in both `peerDependencies` and `devDependencies`.
- A package belongs to exactly one aggregate tsconfig, except existing special cases such as `api/remotes`.
- `src/types.ts` contains only types.
- Tests live at package level under `tests/`, not `src/__tests__/`.
- Every package owns `./invariant`: either register meaningful relational runtime checks or give a package-specific no-runtime-invariant reason where the verifier expects it.

## Tool Plugins

- Prefer `defineTool()` for first-party model-facing tools.
- Register through `ctx.tools.register(...)`.
- Treat `args` as readonly. The registry validates them before `execute()` for `defineTool` tools.
- Check constraints that the parameter DSL cannot express, such as non-empty strings, positive values, or cross-field rules.
- Honor `exec.signal` for foreground work.
- Return one canonical JSON value matching `output.schema`.
- Keep human/model prose in `output.render(args, value)`.
- Keep UI cards in pure `presentCall`, `presentResult`, and optional `output.presentationMeta`.
- Do not make Code Mode or UI parse rendered prose for ids or fields; return handles and fields directly in the canonical value.
- Throw for infrastructure failures. Represent successful domain outcomes, including non-ideal outcomes, in the canonical value.
- For long-running work, gate background mode with config and use `ctx.jobs.start(...)`; published background work is no longer owned by the outer tool call signal.

## Events, Logging, and Model Visibility

- Model-visible means logged: anything that reaches a model request must be reconstructable from the session log.
- New durable facts require `SessionEventMap` declaration merging and replay/render logic.
- Typed event JSDoc needs `@mode`; payload parameters need `@param`.
- Closed unions should switch on discriminants and end in `assertNever`.
- Merge-extensible unions should fall through a documented default.
- Publish state only after the operation succeeds.
- Emit notifications from the authoritative commit point, not from speculative intermediate state.

## Config and Policy

- Deployment-varying tunables must be validated `Config` fields, not hardcoded defaults hidden inside `run()` or `execute()`.
- Misconfiguration should fail loudly at load when self-contained, or at the earliest resolvable point.
- Enforcement belongs in the operation that makes the decision. Prompt filtering, listener order, facades, and wrappers are not sufficient if direct callers can bypass them.
- Use the right tool policy extension point:
  - `tools/pre-execute`: allow, deny, or ask policy.
  - `ctx.tools.guard()`: monotonic final denial.
  - `tools/execute`: wrap dispatch lifetime for deadline, retry, metrics, or signal replacement.
  - `tools/post-execute`: transform/block result or attach model-facing context.
  - `tools/result`: observe immutable normalized final outcome.

## Documentation

- Update package README and JSDoc with behavior changes, config keys, defaults, error codes, wire fields, model-visible text, and limitations.
- Package README must include the required Model Experience structure or an allowed no-direct-effect form.
- Keep facts in one home; do not duplicate broad architecture explanations in package README.
- Use current-state prose. Do not preserve review history, implementation narration, or reasoning transcript residue.
- Non-trivial changes need an Agent Note in the same PR.

## Testing and Verification

- Product-visible plugins require a non-unit real-composition test through Loader/app/process.
- Hand-built `ctx.plugin(...)` suites are useful but insufficient for shipped behavior.
- Registry contributions must prove disposal/HMR behavior.
- Model- or user-visible behavior changes usually need keyless snapshot coverage through a runnable example.
- Use focused behavior tests for changed logic, `doc-sync` for docs, build/hygiene for published paths, and e2e only for provider behavior that needs real credentials.
- Before push, use `dsh-pre-push-checks` to select the smallest relevant checks.

## Useful Source Files

- `docs/architecture.md`: system map and extension-point table.
- `docs/cordis-primer.md`: Cordis service, event, waterfall, and Loader basics.
- `docs/cookbook/extension-cookbook.md`: feature-to-mechanism map.
- `docs/cookbook/adding-a-package.md`: package checklist.
- `docs/cookbook/adding-a-tool.md`: model-facing tool contract.
- `packages/AGENTS.md`: package-specific rules.
- `docs/testing.md`: testing policy.
- `docs/defensive-patterns.md`: lifecycle, subprocess, concurrency, teardown patterns.
