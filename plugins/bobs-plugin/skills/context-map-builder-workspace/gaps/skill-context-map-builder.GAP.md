# GAP: skill `context-map-builder`

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2
검토자: gap-analysis (single-pass, cwd /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/references)
asset_type: skill
source_path: /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/context-map-builder/
  - SKILL.md
  - references/template.md
  - references/inventory-guide.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md, hareness-engineering.md (§4.5, §4.7)
final_decision: PASS_WITH_NOTES
```

## 2. Executive Summary

`context-map-builder` 는 `docs/agent/context-map.md` (라우팅 인덱스) 한 산출물에 좁게 scope 된 read→propose→approve→write 절차 스킬이다. activation signal, effect gate (§Phase 3), output contract (parseable yaml-like block + no-op/blocked 케이스), progressive disclosure (template + inventory-guide 분리) 가 모두 v2 기준의 기능을 만족한다.

영향 있는 finding 1건: description 의 첫 near-miss 인 `agent-skill-designer` 가 실재 자산이 아니다 (실제 자산은 `harness-resource-design`). 자원 inventory 와 라우팅 의도가 같은 self-recursive 도메인을 다루는 스킬이라서, ghost reference 가 description 첫 줄에 있는 것은 본 스킬 자체가 안티패턴으로 명시한 *Ghost reference* 와 동일한 카테고리다. 본문 작동에는 영향 없으나 description-only routing 신뢰성을 약하게 깎는다 (P2).

부수적으로 `docs-architect` 도 미존재 (P3, 자매 자산 `agents-md-author` GAP-002 와 동일 패턴), description 의 두 표기 `${CLAUDE_PLUGIN_ROOT}` 경로 fallback 부재 (P3) 가 있다. 그 외 헌법·가이드 핵심 기대는 충족.

## 3. Asset Snapshot

```text
name: context-map-builder
description: (frontmatter 인용, 97 words) "Use when authoring, scaffolding, or refreshing a project's docs/agent/context-map.md — the routing index that maps work types to roles, docs, skills, and hooks. Triggers on 'build context map', '라우팅 표 만들어줘', ...  Do NOT use for deciding whether something should be a skill/agent/hook (use agent-skill-designer), authoring the individual skill/agent/hook files (use skill-creator, writing-agents, hook-creator), AGENTS.md or CLAUDE.md (use agents-md-author, claude-md-improver), or role-definition body for docs/agent/roles.md (hand-edit; this skill only references roles, not defines them)."
description_words: 97
body_words: ~1242 (SKILL.md 1339 total - frontmatter 97)
body_lines: 156
tools: omitted (none specified)
invocation_controls: 사용자 명시적 "진행/go/proceed" 요구 (Phase 3) — 자동 호출 시에도 effect gate 통과 필요
has_references: yes (template.md, inventory-guide.md)
has_scripts_or_assets: no (bash one-liners 인라인)
has_effect_gate: yes (Phase 3: 5-항목 사전 보고 후 사용자 신호 대기)
has_output_contract: yes (Output Contract 섹션, parseable yaml-like + no-op/blocked case)
```

## 4. Applicable Criteria

- `CONSTITUTION.md` §3.1 Activation, §3.2 Scope, §3.3 Effects Require Gates, §3.4 Output Is A Contract, §3.5 Capability Surface, §3.6 Reusable Knowledge vs Local Memory, §3.7 Progressive Disclosure, §3.9 Verifiable, §3.10 Overlap Must Be Intentional
- `SKILL-GUIDE.md` §3 Description (workflow shortcut 회피, near-miss), §4 Body (workflow/contract/failures), §5 Effects And Gates, §6 Progressive Disclosure, §7 Output Contract, §11 Anti-Patterns
- `hareness-engineering.md` §4.5 (Context Map 정의) — 본 스킬이 normative source 로 명시 인용
- `hareness-engineering.md` §4.7 (자산 선택 기준) — overlap 라우팅 근거

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | "build context map / 라우팅 표 만들어줘 / 라우팅 인덱스 / context map 갱신" 등 한·영 trigger 다수. 산출물 파일명 (`docs/agent/context-map.md`) 직접 인용. |
| Description avoids workflow shortcut | pass | description 은 trigger + near-miss만 나열; Phase 1/2/3 workflow 를 description 에 요약하지 않음. |
| Scope or near-miss is clear when needed | partial | 본문 §When NOT to use 와 description 양쪽에 6개 near-miss 명시. 다만 첫 번째 near-miss (`agent-skill-designer`) 가 실재하지 않는 자산 (Finding GAP-001). |
| Workflow is actionable | pass | Phase 1 (inventory bash + 수집 항목 표) → Phase 2 (8 work-type 후보 + 4 매핑 원칙) → Phase 3 (5-항목 effect gate + write 후 verify). 각 단계 실행 가능. |
| Effect gate exists when mutation is possible | pass | Phase 3 의 "작성/수정 경로 + 변경 종류 + 표 변경 요약 + 자산 후보 보고 + 잔여 follow-up" 5항목 사전 보고 후 사용자 "진행" 신호 — CONSTITUTION §3.3 충족. |
| Output contract exists | pass | yaml-like block (`file: / mode: / rows: / filled_cells: / referenced_resources: / missing_resources: / follow_ups:`) + `no-op` / `blocked` 명시 case. caller parseable. |
| Progressive disclosure is appropriate | pass | template (산출물 골격) 과 inventory-guide (자원 수집 절차) 가 SKILL 본문에서 분리. SKILL 본문에 큰 reference 복사 없음. SKILL-GUIDE §6 의 권장 분리 패턴과 일치. |
| Reusable vs project memory is separated | pass | 본문은 *어디서 무엇을 수집하고 어떻게 매핑·검증·기록할지* 만 정의. 프로젝트 고유 컨벤션/명령 없음. 본문 마지막 줄에 self-referential 명시: "본 스킬은 본문에 규칙을 복사하지 않는다". |
| Behavior can be verified | partial | should-trigger 신호 (작업 유형 한·영 8개), no-op (inventory 와 일치), blocked (자원 0개) 3가지 케이스가 명시되어 verification path 가짐. 다만 should-NOT-trigger 와 near-miss pressure scenario 케이스는 명시되지 않음 — SKILL-GUIDE §8 권장이나 heuristic 수준이므로 finding 아님. |
| Overlap is intentional | partial | description + §When NOT to use 양쪽에서 7개 인접 자산과의 경계 설명. 본 스킬은 "표만 만들고 자원 자체는 만들지 않음" 으로 책임 좁게 분리. 다만 인용된 `agent-skill-designer` / `docs-architect` 가 실재하지 않아 라우팅이 dead-end (Finding GAP-001, GAP-002). |

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §3`, `CONSTITUTION.md §3.10`, 본 스킬 §Common Failures "Ghost reference" | description 첫 near-miss `agent-skill-designer` 가 실재 자산이 아님 — 실제는 `harness-resource-design` | asset 수정 — description 의 `agent-skill-designer` 를 `harness-resource-design` 로 교체 (또는 두 자산명 병기) |
| GAP-002 | ASSET_GAP | P3 | `SKILL-GUIDE.md §3`, 본 스킬 §Common Failures | §When NOT to use 의 `docs-architect` 가 실재 자산이 아님 — 본문 line 27 "(도입 시) 또는 직접 편집" 으로 명시되어 있어 영향은 작지만, description 한 줄 외에는 그 단서를 caller 가 보지 못함 | asset 수정 — description 의 라우팅 후보를 단순 "hand-edit" 로 축약하거나 "(도입 시)" 표기를 description 에도 명시 |
| GAP-003 | ASSET_GAP | P3 | `SKILL-GUIDE.md §6`, `harness-resource-design`/`skill-creator`/`agent-creator` 의 `Fallback 경로` 패턴 | `${CLAUDE_PLUGIN_ROOT}` 환경 변수 미설정 환경에서 normative source path 가 깨질 수 있으나 fallback 안내 없음 | asset 수정 — 본문 마지막 "Normative source:" 줄에 sister skill 들과 동일한 fallback 표기 (`env 미설정 시 SKILL.md 기준 ../../references/`) 추가 |

### GAP-001: Ghost reference in description — `agent-skill-designer`

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §3 Description` (near-miss 정확성), `CONSTITUTION.md §3.10 Overlap Must Be Intentional`, 본 스킬 §Common Failures "Ghost reference" |

**Expected**

description 의 near-miss 로 인용된 자산명은 실제 호출 가능한 자산이어야 한다. caller 가 description 만 보고 라우팅 판단을 할 때 가짜 자원으로 보낼 수 없어야 한다.

**Actual**

description 의 첫 번째 `Do NOT use` 항목:
```
deciding whether something should be a skill/agent/hook (use agent-skill-designer)
```
`agent-skill-designer` 디렉토리는 `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/` 와 `~/.claude/skills/` 어디에도 존재하지 않는다. 실제로 자원 타입 결정 (skill/agent/hook 중 무엇?) 도메인의 자산은 `harness-resource-design` 이다 (자체 description 도 "Reference material only for agent-skill-designer or the main session..." 로 향후 자산을 가정).

**Evidence**

- `find /Users/macpro/dev/bobs-plugin -type d -name "agent-skill-designer"` → 결과 없음
- `find ~/.claude/skills -type d -name "agent-skill-designer"` → 본 검토에서 확인하지 않았으나 cwd context 와 plugin scope 양쪽 모두에서 실존하지 않음을 사이드 검증: `harness-resource-design/SKILL.md` 자체가 `agent-skill-designer` 를 "subagent design delegation" 가정으로만 언급
- 자매 자산 `agents-md-author` 의 이미 작성된 GAP-002 가 동일 패턴 ("`docs-architect` 가 실재 자산이 아니라 '예정'") 을 finding 으로 기록한 선례 있음

**Impact**

description 만 본 caller (모델이 본문을 읽기 전 단계) 가 "자원 타입 결정 작업" 을 만났을 때 존재하지 않는 `agent-skill-designer` 를 invoke 하려 시도해 실패하거나, 본 스킬이 부적절하게 활성화될 수 있다. 본 스킬이 §Common Failures 표에 "Ghost reference" 를 안티패턴으로 명시한 self-referential 도메인이므로, 자체 description 에서 같은 안티패턴을 보이는 것은 일관성 비용이 추가된다. 라우팅 영향은 보통 (P2) — 본 스킬의 핵심 활성화 trigger (산출물 파일명, "라우팅 표/context map") 와 분리되어 있어 본 스킬의 잘못된 활성화로 직결되진 않는다.

**Recommendation**

asset 수정. description 의 `use agent-skill-designer` 를 다음 중 하나로 교체:
1. `use harness-resource-design` (실재 자산명, 가장 직관적)
2. `use harness-resource-design (also reference for agent-skill-designer)` (subagent 도입 예정 단서 보존)
3. 단순 삭제 후 일반 표현 `(separate resource-type decision)` 으로 대체

### GAP-002: Ghost reference in description — `docs-architect`

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §3`, 본 스킬 §Common Failures "Ghost reference" |

**Expected**

description 의 라우팅 권고에 있는 자산은 실재해야 한다.

**Actual**

description 후반 `Do NOT use for ...` 에는 `docs-architect` 가 없지만 본문 line 27 `§When NOT to use`:
```
docs/README.md 인덱스 / docs/architecture.md 등 docs 트리 일반 → docs-architect (도입 시) 또는 직접 편집
```
description 본문에는 `docs/agent/roles.md ... (hand-edit; this skill only references roles, not defines them)` 까지만 있고 docs 트리 일반 처리에 대한 라우팅은 description 에 없다 — 즉 description-only 단계에서는 ghost reference 가 노출되지 않는다. 본문에는 "(도입 시)" 단서가 있어 도입 예정임을 표기.

**Evidence**

- `find /Users/macpro/dev/bobs-plugin -type d -name "docs-architect"` → 결과 없음
- 본문 line 27 의 "(도입 시)" 명시

**Impact**

본문까지 읽은 caller 만 노출되고 그 단계에선 "(도입 시) 또는 직접 편집" fallback 이 함께 있으므로 즉각 라우팅 실패는 없다. 자매 자산 `agents-md-author` 의 GAP-002 와 동일한 패턴인데, 본 스킬은 본문에서만 등장하고 fallback 도 명시되어 영향이 더 작다 (P3).

**Recommendation**

asset 수정 (선택). 다음 중 하나:
1. 현재 표현 유지 (영향 작음, 이미 "(도입 시)" fallback 있음)
2. `docs-architect` 가 향후 작성될 자산이 맞으면 그대로 두고 작성 후 자동 해소
3. 미작성 확정이면 `직접 편집 (docs-architect 같은 별도 스킬은 현재 없음)` 으로 표현 정리

### GAP-003: Normative source 경로의 `${CLAUDE_PLUGIN_ROOT}` fallback 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §6 Progressive Disclosure` (외부 reference 의 환경 fallback), `CONSTITUTION.md §3.7` |

**Expected**

`${CLAUDE_PLUGIN_ROOT}` 같은 환경 의존 경로를 reference 로 인용할 때, 환경 미설정 시의 fallback 을 명시하는 것이 sister skill 들의 패턴이다.

**Actual**

SKILL.md 마지막 줄:
```
Normative source: `${CLAUDE_PLUGIN_ROOT}/references/hareness-engineering.md` §4.5 ..., §4.7 ...
```
fallback 안내 없음. 자매 자산 `skill-creator/SKILL.md:20` 과 `agent-creator/SKILL.md:22` 는 동일 변수 사용 시 "Fallback 경로: `${CLAUDE_PLUGIN_ROOT}` 미설정 환경에서는 현재 SKILL.md 기준 `../../references/` 를 사용한다" 명시.

**Evidence**

- `grep -rn "CLAUDE_PLUGIN_ROOT"` 결과 — `skill-creator`, `agent-creator` 는 fallback 명시; `context-map-builder`, `agents-md-author`, `writing-agents`, `harness-resource-design` 은 인용만 함

**Impact**

본 스킬은 normative source 를 호출자가 읽지 않아도 작동하도록 본문에 핵심 매핑 원칙·workflow 가 self-contained 되어 있다 (본문 마지막 줄 "본 스킬은 본문에 규칙을 복사하지 않는다" 와는 별개로, 라우팅 표 작성에 필요한 절차는 SKILL 본문에 모두 있음). 따라서 fallback 부재의 실질 영향은 작다 (P3). sister skill 일관성 차원의 정리 항목.

**Recommendation**

asset 수정 (선택). `Normative source:` 줄을 `skill-creator` 패턴과 맞춰 fallback 한 줄 추가. 또는 본 스킬이 self-contained 임을 명시하고 normative source 는 background 인용임을 분명히 함.

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| description 길이 97 words (SKILL-GUIDE §9 권장 15–60 의 상한 초과) | heuristic 수준. 본 스킬은 한·영 trigger 다국어 인용 + 6개 near-miss 동시 명시가 라우팅 정확성에 직접 기여. workflow shortcut 으로 변질되지 않았음 (Phase 1/2/3 절차는 description 에 없음). |
| Output contract 가 별도 yaml schema 가 아니라 free-form yaml-like block | caller parseable 하면 형식 자유가 v2 원칙 (GAP-FORMAT §11 snapshot 메모). 본 스킬은 `mode: new\|partial-edit\|rewrite\|no-op\|blocked` 명시 enum + no-op/blocked case 별도 단락으로 caller 가 다음 행동 결정 가능. |
| body 약 1242 words (sister skill 중간 수준) | reference 가 별도 분리되어 본문은 workflow + 매핑 원칙 + Common Failures + Output Contract 만. 길이가 핵심 workflow 를 가리지 않음. |
| `tools` frontmatter 미명시 | 본 스킬은 read (Bash one-liners + Read) + propose + (사용자 승인 후) Write 가 모두 필요. read-only 가 아니므로 명시 의무 약함. effect gate 가 mutation 통로를 명시. |
| should-NOT-trigger 와 pressure scenario 검증 케이스 본문 부재 | SKILL-GUIDE §8 권장이나 heuristic. no-op/blocked case 는 명시되어 핵심 verification path 있음. |

## 8. Suggested Changes

### Asset Changes

- [ ] (P2) description 의 `agent-skill-designer` 를 `harness-resource-design` 로 교체 (또는 두 자산명 병기)
- [ ] (P3) 본문 §When NOT to use 의 `docs-architect (도입 시)` 를 실제 상태에 맞게 정리 — 작성 예정이면 그대로, 미작성 확정이면 표현 변경
- [ ] (P3) SKILL.md 마지막 `Normative source:` 줄에 `${CLAUDE_PLUGIN_ROOT}` 미설정 시 fallback 한 줄 추가 (sister skill 패턴 통일)
- [ ] (선택) should-NOT-trigger 케이스 한 줄 추가 — 예: "사용자가 '이걸 skill 로 만들지 agent 로 만들지' 를 묻는 자원 타입 결정 작업"

### Guide Changes

- [ ] None — 본 스킬의 finding 은 가이드 부족이 아니라 자산 내 ghost reference 와 fallback 부재로 모두 자산 수정으로 해결됨

### Constitution Review

- [ ] None

## 9. Follow-up Questions

1. `agent-skill-designer` 가 향후 실제 subagent (`.claude/agents/agent-skill-designer.md`) 로 작성될 계획인가? 그러면 description 을 그대로 두고 자산 작성을 기다린다. 아니면 description 을 `harness-resource-design` 로 교체.
2. `docs-architect` 가 향후 실제 skill 로 작성될 계획인가? `agents-md-author/GAP-002` 와 동일 follow-up — 두 자산을 같은 시점에 정리하는 것이 일관적.
3. context-map-builder 가 다루는 `docs/agent/context-map.md` 가 `harness-resource-design/references/` 의 어느 도구와도 산출물이 겹치는지 — 만약 `harness-resource-design` 이 context-map 의 일부 행 (자원 타입 결정 경로) 을 함께 출력하는 변형을 갖는다면 §When NOT to use 명시가 더 필요할 수 있음.

## 10. Final Decision

**PASS_WITH_NOTES**

세 finding 모두 자산 수정 항목이며, 영향은 ghost reference (P2) 1건과 정리 항목 (P3) 2건으로 self-referential 안티패턴 표를 가진 스킬이 description 에서 같은 안티패턴을 노출한다는 일관성 비용이 주된 원인이다. 핵심 v2 기준 (activation / scope / effect gate / output contract / progressive disclosure / overlap 설명) 은 모두 통과. 자산 목적과 충돌하는 finding 은 없음.

`REVISE_ASSET` 으로 격상하지 않은 이유:
- description 의 핵심 활성화 trigger (`docs/agent/context-map.md`, "라우팅 표", "context map") 가 정확하므로 본 스킬의 잘못된 활성화는 발생하지 않음
- Phase 3 effect gate 가 작동하므로 mutation 안전성은 유지
- ghost reference 가 본 스킬의 *대상 산출물* 이 아닌 description 의 *라우팅 권고* 에 있으므로 산출물 품질에 영향 없음
- 작은 패치 (description 단어 한 개 교체) 로 P2 해소 가능
