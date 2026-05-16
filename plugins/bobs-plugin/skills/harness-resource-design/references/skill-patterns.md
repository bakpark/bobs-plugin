# Skill Patterns

Use this reference when designing or revising a SKILL.md.

## Good Fit

Create or update a skill when the task needs reusable procedural knowledge, local workflow rules, bundled scripts, or references that should load on demand.

Do not create a skill for a one-off checklist, a role that needs isolated context, or a deterministic event guard. Use an agent or hook instead.

## Frontmatter

Keep frontmatter small.

```yaml
---
name: resource-name
description: Use when <trigger>. Include key user phrases and one negative case. Do not describe the full workflow here.
---
```

Only add invocation controls when needed:

```yaml
disable-model-invocation: true
```

Use this for side effects such as commit, push, deploy, external send, destructive cleanup, or paid API calls.

```yaml
user-invocable: false
```

Use this for background knowledge that should help Claude but should not appear as a user slash command.

## Body Structure

Recommended compact layout:

1. Purpose.
2. Trigger confirmation or input contract.
3. Core workflow.
4. References and when to read them.
5. Output contract.
6. Boundaries and failure modes.

Avoid:
- Long background narrative.
- Workflow summary in description.
- Duplicating full GUIDE text in body.
- Deep reference chains. Keep references one level from SKILL.md.
- `@path` auto-load links.

## References

Use references for detailed rules, variants, examples, schemas, and policy tables.

Good reference split:
- `guide-rule-map.md`: compact rule map.
- `patterns.md`: reusable examples.
- `contracts.md`: input/output schemas.
- `migration.md`: low-risk rollout sequence.

SKILL.md should say exactly when each reference should be read.

## Relation To skill-creator

Use plugin `skill-creator` when the work is primarily "make or improve a skill". Use local `harness-resource-design` first when deciding whether the answer should be a skill, agent, hook, or plugin.

Suggested flow:
1. Designer chooses resource type and contract.
2. If type is skill, apply `skill-creator` principles for SKILL.md structure and progressive disclosure.
3. Run `agent-skill-auditor` for GUIDE compliance.
