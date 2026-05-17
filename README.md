# bobs-plugin marketplace

A single-plugin Claude Code marketplace shipping `bobs-plugin`. The plugin bundles two harness agents, in-house design + authoring skills (`harness-resource-design`, `context-map-architecture`, `skill-creator`, `agent-creator`, `hook-creator`), and one vendored upstream skill (`claude-automation-recommender`, Apache-2.0) so the whole harness-design / authoring workflow is available from one install.

## Layout

```
bobs-plugin/                              ← marketplace repo root
├── .claude-plugin/marketplace.json
├── plugins/
│   └── bobs-plugin/                      ← the actual plugin
│       ├── .claude-plugin/plugin.json
│       ├── agents/
│       │   ├── agent-skill-auditor.md
│       │   └── agent-skill-designer.md
│       ├── skills/
│       │   ├── harness-resource-design/      (in-house)
│       │   ├── skill-creator/                (vendored — Apache-2.0)
│       │   ├── claude-automation-recommender/(vendored — Apache-2.0)
│       │   └── context-map-architecture/    (in-house)
│       ├── references/                    ← constitution + guides + analyzed OSS snapshots
│       │   ├── CONSTITUTION.md
│       │   ├── SKILL-GUIDE.md / AGENT-GUIDE.md / COMMAND-GUIDE.md / HOOK-GUIDE.md / RUNTIME-GUIDE.md
│       │   ├── GAP-FORMAT.md / GAP-ANALYSIS-PROMPT.md
│       │   ├── harness-principles.md / harness-installation-workflow.md
│       │   ├── skills/  agents/  hooks/    ← OSS read-only snapshots
│       │   └── v1/  v2/                    ← cycle archives + GAP reports
│       └── third_party_licenses/
│           ├── skill-creator-LICENSE
│           ├── claude-code-setup-LICENSE
│           └── claude-md-management-LICENSE
├── LICENSE
├── THIRD_PARTY_NOTICES.md
└── README.md
```

## Plugin payload

### Agents

- **`agent-skill-auditor`** — Static auditor for `SKILL.md` / agent `.md` / `settings.json` hooks against the bundled `agent-skill-best-practices` GUIDE. Read-only; emits P0/P1/P2 with confidence + rule evidence.
- **`agent-skill-designer`** — Design decisions, responsibility boundaries, routing, contracts, migration plans. Reads `harness-resource-design` as its rule reference.

### Skills

| Skill | Origin | Purpose |
| :--- | :--- | :--- |
| `harness-resource-design` | in-house | Reference-only design knowledge base used by `agent-skill-designer` and the main session. |
| `skill-creator` | vendored from `claude-plugins-official/skill-creator` (Apache-2.0) | Create / iterate / eval / benchmark skills. |
| `claude-automation-recommender` | vendored from `claude-plugins-official/claude-code-setup` (Apache-2.0) | Recommend hooks / subagents / skills / plugins / MCP servers for a codebase. |
| `context-map-architecture` | in-house | Design + write the docs tree (AGENTS.md / CLAUDE.md / docs/agent/context-map.md / etc.). Absorbs the former `agents-md-author`, `context-map-builder`, and vendored `claude-md-improver` (see THIRD_PARTY_NOTICES.md for Apache-2.0 attribution). |

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
| `claude-automation-recommender` | `claude-plugins-official / claude-code-setup` | Recommender output contract → vendored as-is into this plugin |
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

- Skills resolve as `/bobs-plugin:harness-resource-design`, `/bobs-plugin:context-map-architecture`, `/bobs-plugin:skill-creator`, `/bobs-plugin:claude-automation-recommender`.
- Agents `agent-skill-auditor` and `agent-skill-designer` appear in `/agents`.

## Licensing

- Root `LICENSE` (MIT) covers original work: manifests, README, the GUIDE snapshot, `harness-resource-design`, and the two agents.
- Vendored skills remain under their upstream Apache-2.0 license — see [`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md) and the preserved `LICENSE` copies under `plugins/bobs-plugin/third_party_licenses/`.

## Migration notes

After verifying the plugin loads:

- The user-scope copies at `~/.claude/agents/agent-skill-auditor.md`, `~/.claude/agents/agent-skill-designer.md`, and `~/.claude/skills/harness-resource-design/` can be removed.
- The marketplace copies of `skill-creator` and `claude-automation-recommender` can be uninstalled if you want this plugin to be the sole provider (otherwise both will appear under their respective namespaces and Claude will route based on description match).
- The bundled GUIDE is frozen at plugin v0.1.0; bump the plugin version when refreshing it from the research source.
