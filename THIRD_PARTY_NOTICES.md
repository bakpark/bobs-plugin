# Third-party notices

This marketplace bundles skills copied from the official Anthropic plugins marketplace (`claude-plugins-official`). The upstream sources are licensed under Apache-2.0 or MIT (see the License column); each upstream `LICENSE` file is preserved under `plugins/bobs-plugin/third_party_licenses/`.

| Vendored path | Upstream source | License | LICENSE copy |
| :--- | :--- | :--- | :--- |
| `plugins/bobs-plugin/skills/claude-automation-recommender/` | `claude-plugins-official/plugins/claude-code-setup/skills/claude-automation-recommender` | Apache-2.0 | `third_party_licenses/claude-code-setup-LICENSE` |

No upstream vendored files (the directories listed in the table above) have been modified — they remain byte-for-byte copies of upstream. Compressed/re-structured excerpts of other upstream skills are tracked separately in the per-skill paragraphs below. Refer to each `LICENSE` for the full upstream license terms; the root `LICENSE` (MIT) of this repo applies only to original work (manifests, README, agent-skill-best-practices GUIDE corpus, and the harness-resource-design / context-map-architecture / skill-creator / agent-creator / hook-creator skill/agents authored by the repo owner).

`skill-creator/references/red-green-refactor.md` and `skill-creator/references/trigger-eval.md` contain brief excerpts originally from `writing-skills` (MIT, `claude-plugins-official/plugins/superpowers/skills/writing-skills`), restructured for self-containment within `skill-creator`. The upstream `writing-skills` directory is no longer vendored in this repo, but the MIT terms continue to apply to those excerpts; attribution is provided in each excerpt file, and the upstream `LICENSE` is preserved as `third_party_licenses/superpowers-LICENSE`.

`context-map-architecture/references/claude-md-write.md` contains compressed excerpts originally from `claude-md-improver` (Apache-2.0, `claude-plugins-official/plugins/claude-md-management/skills/claude-md-improver`), restructured for self-containment within `context-map-architecture`. The upstream `claude-md-improver` directory is no longer vendored in this repo, but the Apache-2.0 terms continue to apply to that excerpt; attribution is provided in the excerpt file header, and the upstream `LICENSE` is preserved as `third_party_licenses/claude-md-management-LICENSE`.
