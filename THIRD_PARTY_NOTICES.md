# Third-party notices

This marketplace bundles skills copied from the official Anthropic plugins marketplace (`claude-plugins-official`). The upstream sources are licensed under Apache-2.0 or MIT (see the License column); each upstream `LICENSE` file is preserved under `plugins/bobs-plugin/third_party_licenses/`.

| Vendored path | Upstream source | License | LICENSE copy |
| :--- | :--- | :--- | :--- |
| `plugins/bobs-plugin/skills/claude-automation-recommender/` | `claude-plugins-official/plugins/claude-code-setup/skills/claude-automation-recommender` | Apache-2.0 | `third_party_licenses/claude-code-setup-LICENSE` |
| `plugins/bobs-plugin/skills/claude-md-improver/` | `claude-plugins-official/plugins/claude-md-management/skills/claude-md-improver` | Apache-2.0 | `third_party_licenses/claude-md-management-LICENSE` |

No upstream vendored files have been modified. Refer to each `LICENSE` for the full upstream license terms; the root `LICENSE` (MIT) of this repo applies only to original work (manifests, README, agent-skill-best-practices GUIDE corpus, and the harness-resource-design / skill-creator / agent-creator / hook-creator / agents-md-author / context-map-builder skill/agents authored by the repo owner).

`skill-creator/references/red-green-refactor.md` and `skill-creator/references/trigger-eval.md` contain brief excerpts originally from `writing-skills` (MIT, `claude-plugins-official/plugins/superpowers/skills/writing-skills`), restructured for self-containment within `skill-creator`. The upstream `writing-skills` directory is no longer vendored in this repo, but the MIT terms continue to apply to those excerpts; attribution is provided in each excerpt file, and the upstream `LICENSE` is preserved as `third_party_licenses/superpowers-LICENSE`.
