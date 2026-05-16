# Skill GAP Report: writing-plans

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/writing-plans/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: description 이 정확히 trigger-only ("Use when you have a spec or requirements for a multi-step task, before touching code") 이며 v2 §3.1 의 모범 사례에 가깝다. 본문은 plan header / task structure / placeholder 금지 / self-review / execution handoff 까지 contract 가 명시되어 있다.
- Highest severity: P2
- Main gap: (1) 기본 저장 경로 `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` 가 project convention 색채 (brainstorming 과 동일 패턴, "user preference overrides" 한 줄로 보정). (2) `superpowers:subagent-driven-development` / `superpowers:executing-plans` 등 namespaced sub-skill 의존이 본문에 강하게 박혀 있어 superpowers plugin 환경 외 다른 환경에서 호출 시 호환 책임이 사용자에게 넘어간다.
- Recommended next action: 저장 경로의 generic fallback 명시. plugin-namespaced 의존 부분을 "if available" 톤으로 보정.

---

## 3. Asset Snapshot

```text
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
description_words: ~16
body_words: ~920
body_lines: 152
tools: omitted
invocation_controls: none
has_references: yes (plan-document-reviewer-prompt.md)
has_scripts_or_assets: no
has_effect_gate: partial (Self-Review 단계, "Save plans to" 경로 명시; mutation 은 plan 문서 작성 자체. user approval gate 보다 self-review gate)
has_output_contract: yes (plan header, task structure, placeholder rules, execution choice template)
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate`
- `CONSTITUTION.md §3.10 Overlap Must Be Intentional`

### Skill Guide

- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 Body 설계`
- `SKILL-GUIDE.md §7 Output Contract`
- `SKILL-GUIDE.md §11 Anti-Patterns`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | trigger-only, 16 words |
| Description avoids workflow shortcut | pass | workflow 요약 없음 |
| Scope or near-miss is clear when needed | partial | "Scope Check" 섹션이 multi-subsystem 처리만 다룸. brainstorming / subagent-driven-development 와의 경계는 본문 마지막에서만 등장 |
| Workflow is actionable | pass | plan header → task structure → step granularity → self-review → execution handoff |
| Effect gate exists when mutation is possible | partial | plan 자체는 문서이므로 hard gate 보다 self-review + 사용자 execution choice 가 gate |
| Output contract exists | pass | plan header template + task structure template + placeholder rules + handoff template |
| Progressive disclosure is appropriate | pass | self-review prompt 는 별도 파일 |
| Reusable vs project memory is separated | partial | `docs/superpowers/plans/` 기본 경로 + plugin-namespaced sub-skill 의존이 잔존 |
| Behavior can be verified | partial | plan header 형식, placeholder 부재, step granularity 는 검증 가능. eval 본문 없음 |
| Overlap is intentional | partial | brainstorming → writing-plans 호출 흐름은 brainstorming 측 본문에서 명시. writing-plans 측에는 "If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill" 정도. 충분하지만 명시도는 약함 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `CONSTITUTION.md §3.6` | `docs/superpowers/plans/` 기본 경로 + superpowers:* sub-skill 의존 | generic fallback + "if available" 톤 보정 |

### GAP-001: superpowers-namespaced defaults leak into reusable skill

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate`, `SKILL-GUIDE.md §11 Anti-Patterns` (Project convention leak) |

**Expected**

재사용 스킬은 특정 toolkit / plugin 의 convention 을 default 로 하드코딩하지 않는다. 또는 명시적 fallback 경로를 둔다.

**Actual**

- 본문: `**Save plans to:** docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` (한 줄 "User preferences for plan location override this default" 로 보정)
- "REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans"
- "it should have been created via the `superpowers:using-git-worktrees` skill"

superpowers plugin 환경 외 다른 환경 (예: 다른 toolkit) 에서 이 스킬을 그대로 가져다 쓰면 sub-skill 호출이 깨지거나 plan header 의 sub-skill 안내가 잘못된 정보가 된다.

**Evidence**

본문 line 18, plan header template, execution handoff 단락.

**Impact**

- routing: superpowers plugin 이 없는 환경에서 plan 작성 → 실행 단계로 넘어갈 때 sub-skill 호출이 실패하거나 우회된다.
- reusability: 다른 toolkit 에 이식 시 superpowers:* prefix 를 일일이 보정해야 한다.
- 실제 사용에서 사용자 override 한 줄이 있고 본문이 짧아 영향은 제한적. 그래서 P2.

**Recommendation**

asset 수정. 두 가지 선택지:

1. **명시적 의도 선언:** 본문 상단에 "This skill is part of the superpowers toolkit and assumes superpowers:subagent-driven-development / superpowers:executing-plans are available. Outside superpowers, substitute equivalent sub-skills." 한 줄 추가 → INTENTIONAL_EXCEPTION 으로 정리 가능.
2. **generic 화:** 기본 경로를 `docs/plans/YYYY-MM-DD-<feature-name>.md` 로 두고 "(superpowers users may prefer docs/superpowers/plans/)" 처럼 fallback. sub-skill 참조는 "(if your environment provides one)" 같은 conditional 톤.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| description 매우 짧음 (~16 words) | v2 §3, §9 의 모범 사례. trigger-only |
| `MUST` 사용 (`Every plan MUST start with this header`) | plan header 구조는 자동화된 후속 sub-skill 의 진입 조건이며 실제 gate |
| `When NOT to Use` 별도 섹션 없음 | "Scope Check" + brainstorming 본문에서 호출 순서 통제 |
| `tools` 생략 | 본문이 문서 작성이며 platform 권한에 의존 |

---

## 8. Suggested Changes

### Asset Changes

- [ ] superpowers plugin 의존 명시 또는 generic fallback 추가 (GAP-001)

### Guide Changes

None

### Constitution Review

None

---

## 9. Follow-up Questions

- 본 스킬이 superpowers plugin 의 일부로만 배포되는 것이 의도인지 (그렇다면 GAP-001 은 INTENTIONAL_EXCEPTION).

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- description 이 정확히 trigger-only 이며 본문 contract 가 강하다.
- 발견된 GAP 은 toolkit 의존 / 기본 경로 수준의 P2.
- P0/P1 안전 / mutation / 산출 신뢰성 위험 없음.
