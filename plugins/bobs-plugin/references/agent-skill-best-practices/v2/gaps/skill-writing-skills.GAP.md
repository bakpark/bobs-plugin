# Skill GAP Report: writing-skills

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/writing-skills/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: description 이 trigger-only 이고 본문이 v2 §3.9 Verification, §3.8 Strong Language, §4 의 메타-스킬 변형에 맞는다. TDD 매핑, RED-GREEN-REFACTOR, rationalization table, common mistakes 등 메타 스킬에 적합한 기능을 모두 갖췄다.
- Highest severity: P2
- Main gap: (1) skill-creator 와의 책임 overlap 이 description 에 노출되지 않음. (2) `~/.claude/skills`, `~/.agents/skills/` 처럼 platform-specific path 가 본문 inline. (3) `@graphviz-conventions.dot`, `@testing-skills-with-subagents.md` 의 `@` syntax 사용 — v2 §6 ("`@path` 같은 자동 로딩 링크는 신중히 쓴다. 큰 파일이 의도치 않게 context 에 올라갈 수 있다.") 와 충돌 위험.
- Recommended next action: skill-creator 와의 near-miss 명시. `@` 자동 로딩 링크를 일반 link 로 정리.

---

## 3. Asset Snapshot

```text
name: writing-skills
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
description_words: ~14
body_words: ~3200
body_lines: 655
tools: omitted
invocation_controls: none
has_references: yes (anthropic-best-practices.md, persuasion-principles.md, testing-skills-with-subagents.md, graphviz-conventions.dot, render-graphs.js, examples/)
has_scripts_or_assets: yes (render-graphs.js)
has_effect_gate: partial (Iron Law: "NO SKILL WITHOUT A FAILING TEST FIRST" 이 baseline test gate)
has_output_contract: yes (SKILL.md 구조 template + frontmatter rules + Skill Creation Checklist)
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`
- `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`
- `CONSTITUTION.md §3.9 Behavior Must Be Verifiable`
- `CONSTITUTION.md §3.10 Overlap Must Be Intentional`

### Skill Guide

- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 Body 설계`
- `SKILL-GUIDE.md §6 Progressive Disclosure`
- `SKILL-GUIDE.md §7 Output Contract`
- `SKILL-GUIDE.md §8 Verification`
- `SKILL-GUIDE.md §11 Anti-Patterns`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | trigger-only, 14 words |
| Description avoids workflow shortcut | pass | workflow summary 없음 |
| Scope or near-miss is clear when needed | gap | skill-creator 와의 책임 분리 부재 |
| Workflow is actionable | pass | RED → GREEN → REFACTOR + 체크리스트 |
| Effect gate exists when mutation is possible | pass | "Iron Law: NO SKILL WITHOUT A FAILING TEST FIRST" 가 실제 gate |
| Output contract exists | pass | SKILL.md 구조 template + 검증 checklist |
| Progressive disclosure is appropriate | partial | 본문 3200 words. `@path` auto-load 링크 사용으로 큰 reference 가 의도치 않게 context 에 올라갈 위험 |
| Reusable vs project memory is separated | partial | `~/.claude/skills` / `~/.agents/skills/` 같은 platform path inline 본문 |
| Behavior can be verified | pass | TDD 패러다임 자체가 검증 루프 |
| Overlap is intentional | gap | skill-creator 와의 차이 본문/description 에 없음 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `CONSTITUTION.md §3.10`, `SKILL-GUIDE.md §3` | skill-creator 와의 책임 차이 부재 | description 또는 본문 상단 near-miss 한 줄 |
| GAP-002 | ASSET_GAP | P2 | `SKILL-GUIDE.md §6` | `@graphviz-conventions.dot`, `@testing-skills-with-subagents.md` 등 `@` 자동 로딩 링크 사용 | `@` 제거 또는 "see file at <path>" 로 변경 |
| GAP-003 | ASSET_GAP | P3 | `CONSTITUTION.md §3.8` | "STOP", "MANDATORY", "Iron Law" 등 강한 표현 다수 — 일부는 hard gate, 일부는 권고 | 본문 강한 표현 중 hard gate 아닌 항목 톤 조정 |

### GAP-001: Overlap with skill-creator is not explained

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.10 Overlap Must Be Intentional`, `SKILL-GUIDE.md §3 Description 작성` |

**Expected**

유사 자산은 trigger / scope / output / capability 중 하나로 차이를 드러낸다.

**Actual**

writing-skills description: "Use when creating new skills, editing existing skills, or verifying skills work before deployment"

skill-creator description: "Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals ..."

trigger 가 거의 동일하다. 본문은:
- writing-skills: TDD-style baseline + pressure scenario + rationalization table + 메타 글쓰기 원칙
- skill-creator: eval workspace, benchmark, viewer, description optimization 자동화 루프

description 만으로는 어떤 스킬을 먼저 로드할지 모호하다.

**Evidence**

두 SKILL.md frontmatter.

**Impact**

routing 모호성. 또한 사용자가 둘 다 로드하면 context 비용이 ~8000 words 에 달한다 (3200 + 5200).

**Recommendation**

asset 수정. 예: writing-skills description 끝에 "(For automated eval / benchmark / description-optimization loop, see skill-creator.)" 한 줄. skill-creator 측에 대칭 표기.

### GAP-002: `@` auto-loading link conflicts with progressive disclosure

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`, `SKILL-GUIDE.md §6 Progressive Disclosure` |

**Expected**

큰 reference 는 필요할 때 읽도록 link 한다. `@path` 같은 auto-loading 링크는 신중히 쓴다.

**Actual**

본문 내:
- "See @graphviz-conventions.dot for graphviz style rules."
- "**Testing methodology:** See @testing-skills-with-subagents.md for the complete testing methodology"

writing-skills 본문에서 사용된 `@` syntax 는 platform 에 따라 자동 로딩될 수 있다. testing-skills-with-subagents.md 같은 큰 reference 가 의도치 않게 context 에 매번 들어가면 토큰 비용이 누적된다.

**Evidence**

본문 line 316, line 556 부근.

**Impact**

context 비용 증가 가능. 실제 platform 동작 (`@` 가 자동 로딩되는지) 은 unknown 이지만, v2 SKILL-GUIDE 가 명시적으로 경고한 패턴이라 자산 본문에서 사용한 것은 risk 측면에서 GAP.

**Recommendation**

asset 수정. `@` 제거하고 일반 link 로:
- "See `graphviz-conventions.dot` for graphviz style rules."
- "Testing methodology: see `testing-skills-with-subagents.md` for the complete testing methodology."

또한 writing-skills 본문이 writing-skills 자신의 `Cross-Referencing Other Skills` 단락에서 "**Why no @ links:** `@` syntax force-loads files immediately, consuming 200k+ context before you need them." 라고 명시한다. 즉 자기 자신의 권고에 반하는 사용 사례. asset 내부 일관성 측면에서도 정리 필요.

### GAP-003: Strong language overloaded with non-gate items

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`, `SKILL-GUIDE.md §11 Anti-Patterns` (Must-bombing) |

**Expected**

`MUST`, `NEVER`, `STOP`, `MANDATORY` 같은 표현은 실제 gate 에 쓴다. 일반 권장과 섞이면 우선순위가 흐려진다.

**Actual**

- "STOP: Before Moving to Next Skill"
- "The deployment checklist below is MANDATORY for EACH skill."
- "The Iron Law: NO SKILL WITHOUT A FAILING TEST FIRST"
- "**No exceptions:**", "Delete means delete"
- "All of these mean: Test before deploying. No exceptions."

일부는 실제 gate (test 없이 skill 배포 금지) 이지만, "STOP: Before Moving to Next Skill" 처럼 절차 권고도 같은 톤으로 적혀 있다.

**Evidence**

본문 "STOP: Before Moving to Next Skill", "Skill Creation Checklist (TDD Adapted)", "Common Rationalizations for Skipping Testing" 단락.

**Impact**

영향이 작다. 다만 hard gate 와 일반 권장이 같은 톤이면 모델이 우회 가능 항목과 진짜 차단을 구분하기 어려워진다.

**Recommendation**

asset 수정 옵션 (낮은 우선순위). hard gate (test 없이 skill 배포 금지) 와 일반 권고 (deploy 전 checklist 점검) 의 톤을 분리.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| 본문 길이 (~3200 words) | 메타 스킬 + verification 루프 구조 보유. v2 §9 의 긴 메타 스킬 변형에 해당 |
| 강한 톤 일부 ("Iron Law: NO SKILL WITHOUT A FAILING TEST FIRST") | 실제 gate (test 없는 skill 은 삭제) 에 사용되어 v2 §3.8 부합 |
| `tools` 생략 | 메타 작업 (read + write + subagent) 가 모두 필요 |
| `~/.claude/skills` / `~/.agents/skills/` 본문 inline | platform 별 path 안내, generic 한 위치 안내로 정당화 가능 (heuristic) |

---

## 8. Suggested Changes

### Asset Changes

- [ ] skill-creator 와의 near-miss 한 줄 추가 (GAP-001)
- [ ] `@` 자동 로딩 링크 제거 (GAP-002) — 본 스킬 자신이 권고한 원칙에 부합시키기
- [ ] (선택) hard gate 와 일반 권고 톤 분리 (GAP-003)

### Guide Changes

- [ ] **GUIDE_GAP 후보:** `SKILL-GUIDE.md §6` 의 `@path` 경고는 이미 명시되어 있다. writing-skills 본문이 이 경고를 스스로 어기는 것은 가이드 보완보다 자산 수정으로 다룬다. 본 리포트는 GUIDE_GAP 으로 승격하지 않는다.

### Constitution Review

None

---

## 9. Follow-up Questions

- writing-skills 와 skill-creator 가 별도 자산으로 유지되어야 하는지, 통합 가능한지의 의도 확인. 만약 별도 유지가 의도라면, description 차원에서 차이를 명시하는 것만으로 GAP-001 해소.
- `@path` syntax 가 실제 platform (Claude Code v2 시점) 에서 자동 로딩되는지 확인 — 만약 자동 로딩이 아니면 GAP-002 영향도는 P3 로 낮아질 수 있음.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- description 이 모범적 trigger-only 이고 본문이 verification 루프와 hard gate (Iron Law) 를 모두 갖춘다.
- 발견된 GAP 은 overlap 미설명, `@` 자동 로딩 링크, 강한 표현 over-use 의 P2/P3 수준.
- P0/P1 안전 / mutation / 산출 신뢰성 위험 없음.
