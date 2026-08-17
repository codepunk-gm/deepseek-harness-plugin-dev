# DeepSeek Harness Plugin Templates

Use these as starting points after inspecting the closest live package. Replace placeholders before committing.

## Function Plugin Package Files

Minimal source entry:

```ts
/**
 * <one-sentence package contract>.
 *
 * @module @deepseek-ai/dsh-<pkg>
 */

import type { Context } from '@deepseek-ai/cordis'

/** Cordis plugin name used by loader diagnostics. */
export const name = '<pkg>'

/** Services required before this plugin can register. */
export const inject = ['<service>']

/**
 * Register <owned contribution> for the lifetime of `ctx`.
 * @param ctx - plugin context carrying required services.
 */
export function apply(ctx: Context): void {
  ctx.effect(() => {
    // Register one current contribution here.
    return () => {
      // Dispose resources that are not already owned by a registry disposer.
    }
  })
}
```

Minimal invariant companion:

```ts
/**
 * Package-owned invariant companion for `@deepseek-ai/dsh-<pkg>`.
 * @module @deepseek-ai/dsh-<pkg>/invariant
 */

/* jscpd:ignore-start */
import type { Context } from '@deepseek-ai/cordis'
import type { InvariantInstaller } from '@deepseek-ai/dsh-invariants'

const PACKAGE_NAME = '@deepseek-ai/dsh-<pkg>'

/** Cordis companion plugin name. */
export const name = '<pkg>-invariant'
/** Service required before the companion can reserve package ownership. */
export const inject = ['invariants']

/**
 * No runtime invariant: <specific package-owned reason>.
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
```

## Model-Facing Tool

```ts
import type { Context } from '@deepseek-ai/cordis'
import { defineTool } from '@deepseek-ai/dsh-tools'

export const name = '<tool-plugin>'
export const inject = ['tools']

export function apply(ctx: Context): void {
  ctx.tools.register(defineTool({
    name: '<tool_name>',
    description: '<task-relevant model-facing description>',
    parameters: {
      input: {
        type: 'string',
        required: true,
        description: '<model-facing field description>',
      },
    },
    output: {
      schema: {
        type: 'object',
        properties: {
          result: { type: 'string' },
        },
        required: ['result'],
      },
      render: (_args, value) => [{ type: 'text', text: value.result }],
    },
    async execute(args, exec) {
      if (args.input.trim() === '') {
        throw new Error('<tool_name>: input must not be empty')
      }
      exec.signal.throwIfAborted()
      return { result: args.input }
    },
  }))
}
```

## Hook Policy Plugin

```ts
import type { Context } from '@deepseek-ai/cordis'
import type { PreToolDecision } from '@deepseek-ai/dsh-tools'

export const name = '<policy-plugin>'
export const inject = ['tools']

export function apply(ctx: Context): void {
  ctx.on('tools/pre-execute', async (exec, next): Promise<PreToolDecision> => {
    if (exec.name === '<tool_name>') {
      return { kind: 'deny', reason: '<clear model-facing denial>' }
    }
    return next()
  })
}
```

## Context Injector

```ts
import type { Context } from '@deepseek-ai/cordis'
import { createUserMessage } from '@deepseek-ai/dsh-llm'

export const name = '<context-plugin>'
export const inject = ['agents']

export function apply(ctx: Context): void {
  ctx.on('agent/pre-step', async (agent, input, next) => {
    const decision = await next()
    if (decision.kind !== 'enter') return decision
    return {
      ...decision,
      messages: [
        createUserMessage({
          content: [{ type: 'text', text: '<durable model-visible context>' }],
          source: { kind: 'plugin', plugin: name },
        }),
        ...decision.messages,
      ],
    }
  }, { prepend: true })
}
```

## Service Definition And Provider

Service Definition sketch:

```ts
import { Service } from '@deepseek-ai/cordis'

export interface <Capability>Request {
  readonly input: string
}

export interface <Capability>Result {
  readonly output: string
}

export abstract class <Capability> extends Service {
  static readonly inject = []

  abstract run(request: <Capability>Request, signal: AbortSignal): Promise<<Capability>Result>
}
```

Provider sketch:

```ts
import type { Context } from '@deepseek-ai/cordis'
import { <Capability> } from '@deepseek-ai/dsh-<capability>'

export default class <Provider> extends <Capability> {
  constructor(ctx: Context) {
    super(ctx, '<ctxKey>')
  }

  async run(request: <Capability>Request, signal: AbortSignal): Promise<<Capability>Result> {
    signal.throwIfAborted()
    return { output: request.input }
  }
}
```

Use live package examples before committing either template; Service constructors and registration details vary by existing seam.

## README Model Experience Skeleton

```md
## Model Experience

### <direct or indirect context entry>

#### What the model sees

<Exact model-visible fields, generated catalog link, or stable text reference.>

#### Token effect

<Fixed, conditional, retained, replaced, capped, or zero-direct token effect.>

#### KV Cache effect

<Prefix-stable, append-only, replacing, or independent request behavior.>

## Known Limitations and Deferred Work

- **<consumer-visible gap>** — <exact missing case and consequence>.
```

## Test Skeleton

```ts
import { describe, expect, it } from 'vitest'

describe('<package behavior>', () => {
  it('<observable behavior>', async () => {
    // Arrange through the same public API or Loader path a consumer uses.
    // Act once.
    // Assert committed output, durable event, registry state, or denial.
    expect(true).toBe(true)
  })
})
```

For product-visible plugins, add a real composition test through Loader/app/process in addition to focused unit tests.
