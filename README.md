# bobs-plugin marketplace

A single-plugin Claude Code marketplace shipping `bobs-plugin`. The plugin bundles one harness agent and in-house design + authoring skills (`resource-design`, `context-map-architecture`, `evaluation-loop-design`, `evaluation-loop-runner`, `skill-creator`, `agent-creator`, `hook-creator`, `creator-gap-eval`) so the whole harness-design / authoring / runtime-cycle workflow is available from one install.

## Layout

```
bobs-plugin/                              ← marketplace repo root
├── .claude-plugin/marketplace.json
├── plugins/
│   └── bobs-plugin/                      ← the actual plugin
│       ├── .claude-plugin/plugin.json
│       ├── agents/
│       │   └── agent-skill-auditor.md
│       ├── skills/
│       │   ├── resource-design/              (in-house)
│       │   ├── context-map-architecture/    (in-house)
│       │   ├── evaluation-loop-design/      (in-house)
│       │   ├── evaluation-loop-runner/      (in-house — runtime cycle executor)
│       │   ├── creator-gap-eval/            (in-house — 3 creator §3-§4 통합 GAP 적용)
│       │   ├── creator-gap-eval-workspace/  (in-house — plugin-unified GAP report workspace)
│       │   └── skill-creator/                (vendored — Apache-2.0)
│       ├── references/                    ← constitution + guides + analyzed OSS snapshots
│       │   ├── CONSTITUTION.md
│       │   ├── SKILL-GUIDE.md / AGENT-GUIDE.md / COMMAND-GUIDE.md / HOOK-GUIDE.md / RUNTIME-GUIDE.md
│       │   ├── GAP-FORMAT.md / GAP-ANALYSIS-PROMPT.md
│       │   ├── harness-principles.md / harness-installation-workflow.md
│       │   ├── skills/  agents/  hooks/    ← OSS read-only snapshots
│       │   └── v1/  v2/                    ← cycle archives + GAP reports
│       └── third_party_licenses/
│           ├── skill-creator-LICENSE
│           └── claude-md-management-LICENSE
├── LICENSE
├── THIRD_PARTY_NOTICES.md
└── README.md
```

## Plugin payload

### Agents

- **`agent-skill-auditor`** — Static auditor for `SKILL.md` / agent `.md` / `settings.json` hooks against the bundled `agent-skill-best-practices` GUIDE. Read-only; emits P0/P1/P2 with confidence + rule evidence.

### Skills

| Skill | Origin | Purpose |
| :--- | :--- | :--- |
| `resource-design` | in-house | Decide which resource type (command / skill / agent / hook / runtime settings / plugin) a work pattern needs + responsibility split + Execution Plan for creator-skill dispatch. Absorbs the former `harness-resource-design` skill and `agent-skill-designer` subagent. |
| `context-map-architecture` | in-house | Design + write the docs tree (AGENTS.md / CLAUDE.md / docs/agent/context-map.md / etc.). Absorbs the former `agents-md-author`, `context-map-builder`, and vendored `claude-md-improver` (see THIRD_PARTY_NOTICES.md for Apache-2.0 attribution). |
| `evaluation-loop-design` | in-house | Design + write the evaluation infrastructure (`docs/agent/roles.md` body / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md`). Self-writing skill — direct file write, no creator dispatch. |
| `evaluation-loop-runner` | in-house | Runtime executor — applies the spec written by `evaluation-loop-design`. Per call: Phase 1 task log entry write + Phase 2 golden-set case compare + Phase 3 Routing Decision + Next Action. Stateless — round counter / 4 stop conditions enforced by main session (see `references/runtime-protocol.md`). `user-invocable: true`. |
| `creator-gap-eval` | in-house | 3 creator (skill / agent / hook) 의 §3 GAP 분석 + §4 Self-feedback refine 절차를 통합한 단일 메타 skill. `resource_type` args 로 자원-타입 분기 (GAP-FORMAT §11.X / §12.X / SPLIT_ASSET 신호). creator chain 자동 호출 + 사용자 직접 호출 모두 지원 (`user-invocable: true`). Plugin-unified workspace `creator-gap-eval-workspace/gaps/`. |
| `skill-creator` | vendored from `claude-plugins-official/skill-creator` (Apache-2.0) | Create / iterate / eval / benchmark skills. §3-§4 는 `creator-gap-eval` 호출 stub. |

The plugin's constitution + five resource guides ship under `plugins/bobs-plugin/references/` so the auditor and designer are self-contained — no `~/.claude/research/` dependency.

## References — analyzed open-source plugins

`plugins/bobs-plugin/references/` is more than a guide bundle. To draft the CONSTITUTION and the five resource-type guides (SKILL / AGENT / COMMAND / HOOK / RUNTIME), we read and snapshotted production skills, subagents, and hooks from public Claude Code plugins. The snapshots are **read-only copies** kept under `references/skills/`, `references/agents/`, `references/hooks/` so the analysis is reproducible after upstream updates.

Every analyzed asset lives in one of the marketplaces installed at `~/.claude/plugins/marketplaces/`. The mapping below shows which OSS plugin contributed to which guide.

### Skills (`references/skills/`)

| Snapshot | Marketplace → Plugin | How it informed our guides |
| :--- | :--- | :--- |
| `brainstorming` | `claude-plugins-official / superpowers` | Process-skill activation pattern → SKILL-GUIDE §"automatic activation", CONSTITUTION trigger taxonomy |
| `writing-plans` | `claude-plugins-official / superpowers` | Plan structure + checkpoint contract → COMMAND-GUIDE workflow gate |
| `writing-skills` | `claude-plugins-official / superpowers` | Skill authoring discipline → SKILL-GUIDE structure, `skill-creator` red-green-refactor |
| `using-git-worktrees` | `claude-plugins-official / superpowers` | Isolation + cleanup pattern → pressure scenarios in `agent-creator` |
| `skill-creator` | `claude-plugins-official / skill-creator` | Directly vendored + analyzed → seeded our in-house `skill-creator` and trigger-eval |
| `claude-md-improver` | `claude-plugins-official / claude-md-management` | Docs-tree audit pattern → absorbed by in-house `context-map-architecture` |
| `frontend-design` | `claude-plugins-official / frontend-design` | Domain-specific skill example → SKILL-GUIDE "domain capability" antipattern checks |

### Agents (`references/agents/`)

| Snapshot | Marketplace → Plugin | How it informed our guides |
| :--- | :--- | :--- |
| `builtin/` | Claude Code built-in (`claude-code-guide`, `general-purpose`, `Explore`, `Plan`) | Baseline tool-scope + role separation → AGENT-GUIDE "when not to spawn a subagent" |
| `code-simplifier.md` | `claude-plugins-official / code-simplifier` | Single-purpose specialist pattern → AGENT-GUIDE role boundary rules |
| `pr-review-toolkit/{code-reviewer,code-simplifier,comment-analyzer}` | `claude-plugins-official / pr-review-toolkit` | Multi-agent toolkit composition → AGENT-GUIDE "overlap & near-miss" axis |

### Hooks (`references/hooks/`)

| Snapshot | Marketplace → Plugin | Event | How it informed our guides |
| :--- | :--- | :--- | :--- |
| `superpowers/` | `claude-plugins-official / superpowers` | `SessionStart` (`startup\|clear\|compact`) | Context-injection-on-session pattern → HOOK-GUIDE "always-on injection" |
| `ralph-loop/` | `claude-plugins-official / ralph-loop` | `Stop` | Loop completion handling → HOOK-GUIDE termination semantics |
| `security-guidance/` | `claude-plugins-official / security-guidance` | `PreToolUse` | Guardrail-on-shell pattern → HOOK-GUIDE blocking-hook example, RUNTIME-GUIDE permission boundary |

### External reference (no local snapshot)

| Source | Use |
| :--- | :--- |
| <https://github.com/shanraisshan/claude-code-best-practice> | Cross-checked Claude Code best-practice phrasings while drafting CONSTITUTION and the five guides. |

Snapshot refresh procedure, version-pin inventory (`v2/v2-update.md`), and GAP reports are documented in `plugins/bobs-plugin/references/README.md`.

## Install

### Local development

```bash
claude --plugin-dir /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin
```

### From this marketplace

```text
/plugin marketplace add /Users/macpro/dev/bobs-plugin
/plugin install bobs-plugin@bobs-plugin
```

After install:

- Skills resolve as `/bobs-plugin:resource-design`, `/bobs-plugin:context-map-architecture`, `/bobs-plugin:evaluation-loop-design`, `/bobs-plugin:evaluation-loop-runner`, `/bobs-plugin:creator-gap-eval`, `/bobs-plugin:skill-creator`, `/bobs-plugin:agent-creator`, `/bobs-plugin:hook-creator`.
- Agent `agent-skill-auditor` appears in `/agents`.

## Licensing

- Root `LICENSE` (MIT) covers original work: manifests, README, the GUIDE snapshot, the `resource-design` / `context-map-architecture` / `evaluation-loop-design` / `evaluation-loop-runner` / `creator-gap-eval` / `skill-creator` / `agent-creator` / `hook-creator` skills, and the `agent-skill-auditor` agent.
- Vendored skills remain under their upstream Apache-2.0 license — see [`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md) and the preserved `LICENSE` copies under `plugins/bobs-plugin/third_party_licenses/`.

## Migration notes

After verifying the plugin loads:

- The user-scope copies at `~/.claude/agents/agent-skill-auditor.md` and any prior `~/.claude/agents/agent-skill-designer.md` / `~/.claude/skills/harness-resource-design/` from older installs can be removed.
- The marketplace copy of `skill-creator` can be uninstalled if you want this plugin to be the sole provider (otherwise it will appear under both namespaces and Claude will route based on description match).
- The bundled GUIDE is frozen at plugin v0.1.0; bump the plugin version when refreshing it from the research source.
