# Agent Patterns

Use this reference when designing or revising a subagent `.md`.

## Good Fit

Use an agent when the work benefits from isolated context, a distinct expert role, separate tool permissions, or a cheaper/stronger model than the caller.

Avoid creating an agent when a user-invoked workflow or short reusable procedure in the main context is enough. Use a command for explicit workflow entrypoints, a skill for method, and an agent for role.

## Frontmatter

```yaml
---
name: focused-agent-name
description: Use when <specific trigger>. Produces <output>. Do NOT use for <negative case>.
tools: Read, Grep, Glob, Bash
model: sonnet
color: blue
---
```

Guidelines:
- `model: sonnet` is default.
- `model: opus` only for complex architecture, migration, or high-stakes synthesis.
- Review/analysis agents should be read-only.
- Add `Edit` or `Write` only when the agent is explicitly an implementation worker.
- Avoid omitted tools for custom agents unless it is intentionally catch-all.

## Body Structure

Start with persona:

```markdown
너는 <domain> 전담 에이전트다.
```

Then keep sections compact:
1. Trigger judgment.
2. Input contract.
3. Process.
4. Output format.
5. Boundaries.

## Output Contract

Every agent should return structured, caller-usable output. For review/design agents:

```text
SUMMARY
FINDINGS or PROPOSED_RESOURCES
CONTRACTS
RISKS
NEXT_STEPS
```

For review agents, report only findings with confidence >= 80.

## Responsibility Boundaries

Avoid one agent doing all of:
- analysis
- editing
- test execution
- commit
- push
- PR comment
- cleanup

If a single-call workflow intentionally combines responsibilities, document why and add strong escalation gates. Otherwise split into a command or skill orchestrator plus smaller agents.

## Common Negative Cases

- Do not use for static GUIDE compliance if `agent-skill-auditor` is enough.
- Do not use for PR/code review.
- Do not use for external model review.
- Do not use for file edits when the agent is read-only.

## Migration Pattern

When replacing or introducing an agent:
1. Add new agent read-only first.
2. Update caller prompts/contracts second.
3. Run one dry review or narrow task.
4. Only then allow tools with side effects if needed.
