# GAP Report — skill `agents-md-author`

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2
검토자: gap-analysis agent (single pass, evidence-based)
asset_type: skill
source_path:
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/agents-md-author/SKILL.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/agents-md-author/references/template.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/agents-md-author/references/section-guide.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, hareness-engineering.md, GAP-FORMAT.md
final_decision: PASS_WITH_NOTES
```

---

## 2. Executive Summary

`agents-md-author` 는 `AGENTS.md` (도구 공통 코딩 에이전트 계약) 의 신규 작성·정비·감사를 담당하는 절차 스킬이다. 검토 결과 v2 헌법의 hard rule 과 design principle 의 핵심 기능 (activation, scope, effect gate, output contract, progressive disclosure, overlap explanation) 을 모두 충족한다.

영향 있는 GAP 은 없다. 다만 가벼운 명확화 항목이 있다:

- 본문 내 normative source 파일명 표기가 일관되지 않음 (`harness-engineering` vs `hareness-engineering`). 실제 파일이 `hareness-engineering.md` 이므로 path 가 들어간 `Normative source` 줄과 `section-guide.md` 줄은 작동하지만, 본문 inline 표기 두 곳은 다른 철자를 쓴다 — 라우팅 실패는 아니지만 grep/링크 작업 시 혼선 가능.
- description 의 near-miss 중 `docs-architect` 가 실재 자산이 아니라 "예정" (본문 §When NOT to use 에 명시). description 의 trigger 신호로는 유효하지만 false routing 가능성을 작은 폭으로 키운다.

전반적 자산 품질은 강하다 — 8-section template, 책임 누수 점검 표, 4-item gate, 구조화된 output contract, no-op/blocked 분리는 모두 SKILL-GUIDE.md §4–§7 의 권장과 부합한다.

---

## 3. Asset Snapshot

```text
name: agents-md-author
description: Use when authoring, scaffolding, refining, or auditing a project's AGENTS.md — the tool-common coding-agent contract read by Codex, Claude, Gemini, Cursor, and similar. Triggers on "make AGENTS.md" / "AGENTS.md 작성" / ... Do NOT use for CLAUDE.md (use claude-md-improver), README/docs tree (use docs-architect or hand-edit), individual subagent definitions (use writing-agents), or per-tool config files.
description_words: 78
body_words: 1247
body_lines: 154
tools: omitted (platform default; mutation scope narrowed by Phase 3 gate)
invocation_controls: workflow-internal approval gate (Phase 3), no auto-invocation suppression flags
has_references: yes (references/template.md, references/section-guide.md)
has_scripts_or_assets: no
has_effect_gate: yes (Phase 3 — 4-item proposal + explicit user signal + post-write verify)
has_output_contract: yes (structured form: file/mode/sections/lines/moved_from/follow_ups/duplication_report + no-op + blocked)
```

---

## 4. Applicable Criteria

- `CONSTITUTION.md §3.1` Activation Must Be Explicit
- `CONSTITUTION.md §3.2` Scope Controls Quality
- `CONSTITUTION.md §3.3` Effects Require Gates
- `CONSTITUTION.md §3.4` Output Is A Contract
- `CONSTITUTION.md §3.5` Capability Surface Must Match Responsibility
- `CONSTITUTION.md §3.6` Reusable Knowledge And Local Memory Must Stay Separate
- `CONSTITUTION.md §3.7` Progressive Disclosure Protects Context
- `CONSTITUTION.md §3.8` Strong Language Belongs To Real Gates
- `CONSTITUTION.md §3.9` Behavior Must Be Verifiable
- `CONSTITUTION.md §3.10` Overlap Must Be Intentional
- `SKILL-GUIDE.md §3` Description 작성
- `SKILL-GUIDE.md §4` Body 설계
- `SKILL-GUIDE.md §5` Effects And Gates
- `SKILL-GUIDE.md §6` Progressive Disclosure
- `SKILL-GUIDE.md §7` Output Contract
- `SKILL-GUIDE.md §11` Anti-Patterns
- `hareness-engineering.md §4.1` Docs: 지식의 원천 (README / AGENTS.md / CLAUDE.md 역할 분리)
- `hareness-engineering.md §5.7` 1차 MVP 생성 순서

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | 한·영 trigger phrase + 명시적 near-miss 4건 (CLAUDE.md / README·docs / subagent / per-tool config) |
| Description avoids workflow shortcut | pass | trigger·near-miss 만 나열. Phase 1–3 절차 요약이 description 에 없음 |
| Scope or near-miss is clear when needed | pass | description + 본문 §When NOT to use 양쪽에 near-miss. 인접 자산 (claude-md-improver, writing-agents) 실재 확인됨 |
| Workflow is actionable | pass | Phase 1 inspect (구체 파일 목록), Phase 2 draft (8-section template + 책임 누수 표), Phase 3 gate (4-item proposal + verify) |
| Effect gate exists when mutation is possible | pass | Phase 3 — inspect → propose → explicit user signal → write → verify. CONSTITUTION §3.3 의 5-step 패턴 충족 |
| Output contract exists | pass | 구조화된 caller-parseable form + no-op + blocked. SKILL-GUIDE §7 의 권장 형태에 부합 |
| Progressive disclosure is appropriate | pass | 본문 154 lines, 큰 template/section-guide 는 references/ 로 분리. metadata-body-references 3단 구조 |
| Reusable vs project memory is separated | pass | 본문에 프로젝트 고유 정보 없음. 모든 예 (pnpm test 등) 는 placeholder. normative source 는 외부 문서 참조 |
| Behavior can be verified | partial | should-trigger / should-not-trigger 케이스는 description·near-miss 로 implicit 하게 정의되지만, 명시적 verification loop (SKILL-GUIDE §8) 는 없음. 절차 자체가 inspect→propose→approve 라 outcome 검증은 caller 가 output contract 로 수행 가능 |
| Overlap is intentional | pass | claude-md-improver / writing-agents / docs-architect 와의 책임 경계가 description·본문·§4.1 표 인용으로 3중 명시 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P3 | `SKILL.md` 본문 inline 표기 vs `Normative source` path | normative source 파일명 inline 표기가 두 가지 철자 (`harness-engineering` / `hareness-engineering`) 로 혼재 | asset 수정 — inline 표기를 path 와 동일하게 통일 |
| GAP-002 | AMBIGUITY | P3 | `CONSTITUTION.md §3.10`, `SKILL-GUIDE.md §3` | description 의 near-miss 에 등장하는 `docs-architect` 가 실재 skill 이 아니라 "예정" 상태 | asset 수정 — "(예정)" 명시를 description 에도 추가하거나 단순 "hand-edit" 만 유지 |

### GAP-001: Inconsistent spelling of normative source filename in body

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL.md` line 11 / 150 vs line 152; `references/section-guide.md` line 7 |

**Expected**

자산 내 모든 normative source 파일명 표기가 실제 파일명 (`hareness-engineering.md`) 과 일치하거나, 최소한 자산 내 표기가 일관되어야 grep / 링크 / 후속 자동화가 안정적으로 동작한다.

**Actual**

본문에서 두 가지 철자가 혼재한다:

- 본문 line 11: ``` 핵심 책임 분리는 `harness-engineering` 자산 모델 §4.1 ``` (typo-수정된 철자)
- 본문 line 150: `references/section-guide.md — 섹션별 ... + harness-engineering §4.1 표 발췌` (typo-수정된 철자)
- 본문 line 152: `Normative source: ${CLAUDE_PLUGIN_ROOT}/references/hareness-engineering.md` (실제 파일명)
- `references/section-guide.md` line 7: `${CLAUDE_PLUGIN_ROOT}/references/hareness-engineering.md` (실제 파일명)

**Evidence**

- 실제 파일: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/references/hareness-engineering.md`
- inline mention (no path) 은 `harness-engineering` 으로 표기
- path 형태로 적힌 곳은 `hareness-engineering` 으로 표기

**Impact**

라우팅·안전 영향 없음. grep 기반 후속 검토나 cross-link 자동화가 혼선될 수 있고, 독자에게 "두 문서가 있는가" 라는 인상을 줄 수 있다.

**Recommendation**

asset 수정. inline mention 두 곳을 path 와 동일한 `hareness-engineering` 으로 통일하거나, 별도 PR 에서 실제 파일명을 `harness-engineering.md` 로 rename 한 뒤 모든 참조를 같은 철자로 맞춘다. 본 스킬 단위로 단독 처리할 거면 inline → path 표기 정렬이 최소 변경이다.

### GAP-002: `docs-architect` near-miss references a non-existent skill

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.10 Overlap Must Be Intentional`, `SKILL-GUIDE.md §3` |

**Expected**

description 의 near-miss 가 인접 자산을 가리킬 때, 해당 자산이 실재하거나 "예정" 임을 독자가 즉시 파악할 수 있어야 false routing 이 발생하지 않는다.

**Actual**

- description: ``` README or wider docs tree (use docs-architect or hand-edit) ```
- 본문 §When NOT to use: ``` README.md 정비 / docs/ 구조 → docs-architect (예정) 또는 직접 편집 ```

본문에는 "(예정)" 표시가 있으나 description 에는 없다. 실제 `skills/` 하위에 `docs-architect` 자산이 없는 것을 확인했다.

**Evidence**

```
$ ls plugins/bobs-plugin/skills/
agent-creator           claude-automation-recommender
agent-creator-workspace claude-md-improver
agents-md-author        harness-resource-design
agents-md-author-workspace hook-creator ...
writing-agents
```

`docs-architect` 디렉토리 없음. 본문 line 30 에 "(예정)" 명시.

**Impact**

라우팅 영향 작음. description 만 본 caller 가 `docs-architect` 를 invoke 시도해도 실패하지만, "or hand-edit" fallback 이 description 에 함께 적혀있어 회복 가능하다.

**Recommendation**

asset 수정. description 의 `use docs-architect` 를 `hand-edit (docs-architect 도입 예정)` 또는 단순 `hand-edit` 로 바꾸는 작은 패치. 또는 `docs-architect` 자산을 실제로 생성한 뒤 그대로 둔다.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| description 길이 78 words (heuristic 15–60 의 상한 초과) | near-miss 4건 + 한·영 trigger phrase 를 함께 담는 의도적 확장. SKILL-GUIDE §3 의 trigger·near-miss 우선 원칙과 부합하고 workflow shortcut 을 만들지 않음 |
| `tools` frontmatter 미명시 | 본 스킬은 Read·Edit·Write 가 모두 필요한 mutation 작업이며, Phase 3 effect gate 로 mutation 시점을 좁힌다. SKILL-GUIDE §2 의 "tools 는 capability surface 를 줄이는 의미가 있을 때 명시" 기준에서 제한이 의미를 거의 만들지 않음 |
| 명시적 verification 섹션 없음 | SKILL-GUIDE §8 의 verification loop 는 권장이지 hard rule 이 아님. 본 스킬의 output contract 자체가 caller 의 outcome 검증 통로로 작동 |
| Phase 명칭이 SKILL-GUIDE §4 의 권장과 다름 (Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect gate vs Context / Analysis / Report) | 의미적으로 동일하고 mutation 자산에 더 적합한 어휘 |

---

## 8. Suggested Changes

### Asset Changes

- [ ] (P3) SKILL.md line 11 / line 150 의 ``` `harness-engineering` ``` inline 표기를 line 152 path 와 동일한 `hareness-engineering` 으로 통일 (또는 별도 작업으로 실제 파일을 `harness-engineering.md` 로 rename 후 모든 참조 정렬)
- [ ] (P3) description 의 `use docs-architect` 표현을 실재 상태에 맞게 조정 — 예: `hand-edit (docs-architect 도입 예정 시 그쪽으로 위임)` 또는 단순 `hand-edit`

### Guide Changes

None — 현재 SKILL-GUIDE / CONSTITUTION 으로 본 자산을 평가하는 데 부족함이 없다.

### Constitution Review

None.

---

## 9. Follow-up Questions

1. `${CLAUDE_PLUGIN_ROOT}/references/` 디렉토리에 있는 `hareness-engineering.md` 의 파일명 typo 를 본 자산 단독으로 정정할지, 별도 cross-cutting 작업 (모든 자산 참조 동시 수정) 으로 처리할지 사용자 의도 확인 필요.
2. `docs-architect` 가 향후 실제 skill 로 만들어질 계획인지, 아니면 description 에서 제거할지 결정 필요.

---

## 10. Final Decision

**PASS_WITH_NOTES**

근거: v2 헌법의 hard rule (effect gate, capability surface, output contract) 과 design principle (activation, scope, overlap, progressive disclosure) 의 기능적 요구를 모두 충족한다. 두 finding 은 모두 P3 정리 항목이며 라우팅·안전·산출 신뢰성에 직접 영향을 주지 않는다.
