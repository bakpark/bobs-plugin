# Skill GAP Report: brainstorming

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/brainstorming/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 본문 구조와 hard-gate 처리가 v2 §3.3 / §3.8 의 의도와 잘 맞는다. 디자인을 승인받기 전 다른 implementation skill 호출을 금지하는 gate 가 명확하고, output (design doc 경로와 spec self-review) 이 contract 로 동작한다.
- Highest severity: P2
- Main gap: description 이 "Explores user intent, requirements and design before implementation" 문구로 workflow 를 요약하는 경향이 있고, "You MUST use this before any creative work" 식 광범위 trigger 가 near-miss filter 없이 들어 있어 over-triggering 가능성이 있다.
- Recommended next action: description 을 trigger-only 로 축소하고 frontend-design / skill-creator 같은 인접 스킬과의 near-miss 를 명시한다.

---

## 3. Asset Snapshot

```text
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
description_words: ~30
body_words: ~1520
body_lines: 164
tools: omitted
invocation_controls: none
has_references: yes (visual-companion.md, spec-document-reviewer-prompt.md, scripts/)
has_scripts_or_assets: yes (scripts/)
has_effect_gate: yes (HARD-GATE + user approval steps + spec self-review)
has_output_contract: yes (docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md + 단계별 산출)
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`
- `CONSTITUTION.md §3.10 Overlap Must Be Intentional`

### Skill Guide

- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §5 Effects And Gates`
- `SKILL-GUIDE.md §7 Output Contract`
- `SKILL-GUIDE.md §11 Anti-Patterns`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | partial | trigger 범위가 매우 넓다. "any creative work" 는 모든 design 요청에 걸린다. |
| Description avoids workflow shortcut | partial | description 끝에 "Explores user intent, requirements and design before implementation" 가 본문 workflow 의 요약처럼 읽힌다. |
| Scope or near-miss is clear when needed | gap | implementation skill 호출 금지는 명시되어 있지만 brainstorming vs frontend-design / writing-plans / skill-creator 의 near-miss 가 description 에 없다. |
| Workflow is actionable | pass | checklist + dot flowchart + section별 instruction 으로 실행 가능. |
| Effect gate exists when mutation is possible | pass | HARD-GATE, design 승인 gate, spec self-review, user review gate 가 단계적으로 있다. |
| Output contract exists | pass | spec 저장 경로, header 형식, 다음 skill 호출까지 contract 가 명시되어 있다. |
| Progressive disclosure is appropriate | pass | visual-companion.md 등 큰 자료는 분리되어 있다. |
| Reusable vs project memory is separated | partial | `docs/superpowers/specs/` 경로 default 가 project convention 색채가 있지만 "user preference overrides" 로 보정되어 있다. |
| Behavior can be verified | partial | hard gate 위반 여부, design 승인 흐름 준수 여부는 검증 가능하지만 trigger eval 은 본문에 없다. |
| Overlap is intentional | partial | "ONLY skill you invoke after brainstorming is writing-plans" 는 명시되어 있지만 brainstorming 자체의 진입 경계가 description 에 충분히 좁혀져 있지 않다. |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §3` | description 의 broad trigger + workflow shortcut 경향 | description 을 trigger-only 로 좁히고 near-miss 한 줄 추가 |
| GAP-002 | AMBIGUITY | P3 | `SKILL-GUIDE.md §6` | `docs/superpowers/specs/` 기본 경로가 reusable skill 에 들어가 있음 | "user preference overrides" 문구 외에 generic fallback 경로 또는 명시적 인지 |

### GAP-001: Description over-triggers and partially summarizes workflow

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §3 Description 작성`, `CONSTITUTION.md §3.1 Activation Must Be Explicit` |

**Expected**

description 은 activation signal 로서 언제 호출해야 하는지 좁히고, 본문 workflow 의 요약이 되지 않아야 한다. near-miss 가 있다면 함께 드러낸다.

**Actual**

`"You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."`
- "any creative work / creating features / building components / adding functionality / modifying behavior" 는 일반 코딩 작업 대부분을 포함한다.
- "Explores user intent, requirements and design before implementation" 는 본문 workflow 의 한 줄 요약으로 작용한다.

**Evidence**

frontmatter `description` field. brainstorming 본문은 9-step checklist 와 design approval gate 를 요구하지만, description 만 보아도 "design 절차를 실행한다" 가 그대로 읽힌다.

**Impact**

라우팅 측면에서 사소한 버그 수정이나 기존 코드의 작은 변경에도 brainstorming 이 호출될 수 있어 비용·시간을 늘릴 수 있다. description shortcut 경향은 모델이 본문(특히 spec self-review, user approval gate)을 건너뛰고 description 만 따르게 만들 수 있다.

**Recommendation**

asset 수정. trigger 를 "Use when starting new feature design or any non-trivial behavior change that needs requirements and design before implementation" 처럼 좁히고, "Not for trivial bug fixes or simple refactors" 같은 near-miss 한 줄을 추가한다. 본문 workflow 요약 문구는 제거한다.

### GAP-002: Default spec path leaks project convention

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate`, `SKILL-GUIDE.md §11 Anti-Patterns` |

**Expected**

reusable skill 은 project convention 을 default 로 하드코딩하지 않거나, 했다면 명시적 의도를 드러낸다.

**Actual**

`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` 경로가 default 로 들어 있고 "User preferences for spec location override this default" 한 줄로 보정.

**Evidence**

"After the Design > Documentation" 섹션.

**Impact**

다른 프로젝트에서 그대로 쓰면 `docs/superpowers/` 경로가 자동 생성되어 어색할 수 있다. 다만 사용자 override 가 있고 commit 단계가 명시되어 영향은 낮다.

**Recommendation**

asset 수정 옵션. "Save the design doc to a project-appropriate specs location (e.g., `docs/specs/...`); if a project uses superpowers convention, default to `docs/superpowers/specs/...`" 식으로 generic + fallback 로 정리하면 더 깨끗하지만 P3 수준의 정리이다.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| 본문에 `When NOT to Use` 별도 섹션 없음 | HARD-GATE, "ONLY skill you invoke after brainstorming is writing-plans" 등으로 anti-trigger 가 본문에 분산되어 있어 기능을 만족 |
| `tools` 생략 | 본문이 read 중심 + 일부 write(spec 저장, commit)이며 platform default 에 의존. v2 §3.5 의 capability surface 요구를 위반한다고 단정할 증거가 부족 |
| 강한 `MUST` / `HARD-GATE` 사용 | v2 §3.8 의 강한 표현은 실제 gate (design 미승인 시 implementation 금지) 위치에 쓰였다 |
| 본문 길이 (1500+ words) | workflow + visual-companion offer + design-for-isolation 원칙 등 실제 행동에 직결되는 내용이며 큰 reference 는 분리되어 있다 |

---

## 8. Suggested Changes

### Asset Changes

- [ ] description 의 broad trigger 축소 및 본문 workflow 요약 제거 (GAP-001)
- [ ] near-miss 한 줄 추가 (frontend-design / writing-plans 대비) (GAP-001)
- [ ] (선택) default spec 경로를 generic + superpowers fallback 로 정리 (GAP-002)

### Guide Changes

None

### Constitution Review

None

---

## 9. Follow-up Questions

- 현재 description 의 "You MUST" 강조가 baseline trigger rate 개선을 위한 의도된 결정인지 (skill-creator 본문에서 "pushy" 권고가 있는 만큼) 확인 필요. 의도적 결정이라면 GAP-001 은 INTENTIONAL_EXCEPTION 으로 재분류할 여지 있음.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- hard gate 와 output contract 가 잘 동작한다.
- 발견된 GAP 은 라우팅 trigger 범위와 description shortcut 경향에 대한 P2 수준 개선이다.
- P0/P1 위험 (안전, mutation 권한, 산출 신뢰성)이 없다.
