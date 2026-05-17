# bobs-plugin marketplace

A single-plugin Claude Code marketplace shipping `bobs-plugin`. The plugin bundles two harness agents, one design-reference skill, and three vendored upstream skills so the whole harness-design / authoring workflow is available from one install.

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
│       ├── references/
│       │   └── agent-skill-best-practices-GUIDE.md
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

The GUIDE itself ships at `plugins/bobs-plugin/references/agent-skill-best-practices-GUIDE.md` so the auditor is self-contained — no `~/.claude/research/` dependency.

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
