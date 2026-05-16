# Hook Patterns

Use this reference when designing Claude Code hooks.

## Event Choice

| Need | Hook |
|---|---|
| Block dangerous command or sensitive file edit before it happens | PreToolUse |
| Format, log, or verify after edits without blocking normal flow | PostToolUse |
| Add a small routing hint from user prompt | UserPromptSubmit |
| Add project/cwd context once per session | SessionStart |
| Notify or collect result after subagent work | SubagentStop |

## Matcher

Always narrow matcher by tool/event.

Examples:
- `Edit|Write` for file mutation guards.
- `Bash` for command safety.
- `Skill|Agent` for telemetry.

Avoid broad matchers unless the script is extremely fast and read-only.

## Failure Behavior

Default: silent fail.

```bash
... || exit 0
exit 0
```

Use non-zero only when the hook is explicitly a PreToolUse blocker and the message explains what was blocked.

## Routing Hints

UserPromptSubmit can return one short `additionalContext` line.

Good:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Likely resource task: consider agent-skill-designer for skill/agent/hook design."
  }
}
```

Bad:
- Multi-paragraph guidance.
- Running a planner inside the hook.
- Injecting instructions that conflict with the user.

## Safety Rules

Do not:
- run long test suites synchronously
- send prompt/tool data to unknown external hosts
- block PostToolUse results
- use broad path globs for secret/lockfile protection
- mutate settings or source files from a hook unless the hook is explicitly a formatter and scoped to edited files

## Rollout

1. Start as logging-only or context-only.
2. Add exact matcher.
3. Add timeout or async behavior.
4. Test with representative hook input JSON.
5. Only then enable blocking behavior.
