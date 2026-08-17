# DeepSeek Harness Plugin Playbooks

Use this reference to move from a user request to a first working plugin slice.

## Type Router

| User asks for | Start with | Main extension point | Template |
|---|---|---|---|
| A new model-callable action | Model-facing tool | `ctx.tools.register()` | `templates.md#model-facing-tool` |
| Permission, approval, timeout, retry, audit, result filtering | Hook/policy plugin | `tools/pre-execute`, `ctx.tools.guard()`, `tools/execute`, `tools/post-execute`, `tools/result` | `templates.md#hook-policy-plugin` |
| Extra request context | Context injector | `agent/pre-step` or `agent.inject()` plus durable `user/message` source | `templates.md#context-injector` |
| A new swappable capability | Capability seam | Service Definition + Provider + Consumer | `templates.md#service-definition-and-provider` |
| A new provider for an existing capability | Service Provider | Register behind the existing `ctx.<service>` API | `templates.md#service-definition-and-provider` |
| A new model backend | LLM adapter | `ctx.llm` adapter registration | live `docs/cookbook/adding-an-llm-adapter.md` |
| A UI/business chat node | UI plugin | `session/event`, `ctx.agents`, or conversation node registration | live `docs/cookbook/adding-a-conversation-node.md` |
| A profile/bundle install path | Bundle/profile wiring | Cordis config rows and package `dsh` metadata | live bundle packages |

## Universal First Slice

1. Read `docs/architecture.md`, `packages/AGENTS.md`, and the relevant cookbook.
2. Locate the closest package by role with `rg` or `find packages -path '*/package.json'`.
3. Copy the local style, not the exact code.
4. Implement only one current behavior and one current caller.
5. Add a package README section for owned API/config/model experience.
6. Add `src/invariant.ts`. If there is no runtime relation, write the specific no-runtime-invariant reason and register ownership.
7. Add focused tests. For product-visible behavior, include a real Loader/app/process composition test.
8. Add an Agent Note for non-trivial changes.
9. Run focused tests and the smallest relevant gates.

## Model-Facing Tool Playbook

1. Read `docs/cookbook/adding-a-tool.md`.
2. Inspect a nearby `packages/*/tool-*` package.
3. Define the canonical JSON return value before writing prose.
4. Implement `defineTool()` with schema, `execute`, `output.schema`, and `output.render`.
5. Put handles, ids, paths, and structured fields in the canonical value. Do not require Code Mode or UI to parse rendered text.
6. Add pure `presentCall`, `presentResult`, and `presentationMeta` only when UI replay needs card data.
7. Route deployment policy through `tools/*` listeners instead of embedding it in the tool.
8. Test argument validation, success value, error containment, cancellation, rendering, and disposal.
9. Add snapshot coverage when model-visible output changes in the assembled app.

## Hook Or Policy Playbook

1. Choose the event by ownership:
   - `tools/pre-execute`: allow, deny, or ask before execution.
   - `ctx.tools.guard()`: final monotonic denial.
   - `tools/execute`: wrap dispatch lifetime for deadlines, retries, or metrics.
   - `tools/post-execute`: transform/block result or attach model-facing context.
   - `tools/result`: observe immutable final outcome.
   - `agent/pre-step`, `agent/request`, `agent/turn-stopping`: request and turn policies.
2. Call `next()` for waterfall listeners unless intentionally short-circuiting.
3. Keep policy decisions enforceable at the operation that makes the decision.
4. Test allow and deny paths through the real executor, not only direct helper calls.

## Context Injector Playbook

1. Decide whether context wakes the agent. `agent.inject()` queues context for the next admitted request; it does not wake an idle agent.
2. If the model sees the context, make it durable as a `user/message` with source `{ kind: 'plugin', plugin: '<name>' }` or a package-owned session event rendered into history.
3. Derive scheduling from durable events when resume or compaction matters.
4. Add an invariant that validates source ownership, rendering, and event position.
5. Test first step, later steps, rejection/failure containment, resume behavior when relevant, and duplicate suppression.

## Capability Seam Playbook

1. Identify all current consumers before designing the Service Definition.
2. Keep provider-specific concepts out of the Service Definition unless all current consumers need them.
3. Put defaults in an explicit `resolve(request): Spec` step owned by the implementation, not hidden inside `run()`.
4. Split packages only when roles evolve independently.
5. Test the Service Definition contract, at least one provider, and at least one consumer path.
6. Document provider limitations and model/token effects in the owning READMEs.

## Fast Scaffold Use

Use `scripts/create-function-plugin.sh` only for simple function plugins such as hooks, context injectors, or local policy plugins. Do not use it for Service Definition packages, LLM adapters, client plugins, or generated API packages.

After scaffolding:

1. Add the package to `tsconfig.host.json` or `tsconfig.client.json`.
2. Add peer/dev dependencies for every injected service.
3. Replace placeholder README and invariant text.
4. Add tests under package-level `tests/`.
5. Run `pnpm run constraints && pnpm run typecheck` before expanding behavior.

## Verification Matrix

| Change | Minimum useful evidence |
|---|---|
| New package skeleton | `pnpm run constraints`, `pnpm run typecheck` |
| Tool behavior | focused package tests plus real composition test |
| Model-visible text or tool schema | snapshot through a runnable example |
| README/JSDoc/prose | `pnpm run doc-sync` and prose review |
| Registry contribution | disposal/HMR test |
| Provider behavior | provider contract tests; e2e only when real external behavior is required |
| Published package surface | `pnpm run build && pnpm run hygiene` when the emitted package surface changes |
