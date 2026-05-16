# Skill GAP Report: using-git-worktrees

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/using-git-worktrees/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: detection → native tool 우선 → git fallback → 안전 검증 → baseline test 의 단계가 v2 §3.1, §3.3, §3.5 모두에 부합한다. submodule guard, ignore verification, sandbox fallback 같은 실패 모드가 명시되어 있다. "Native worktree tool 이 있을 때는 그것을 쓴다" 라는 핵심 메시지가 일관되게 강조된다.
- Highest severity: P3
- Main gap: description 이 "ensures an isolated workspace exists via native tools or git worktree fallback" 으로 본문 workflow 의 한 줄 요약 경향이 있고, EnterWorktree 같은 platform-specific 도구 이름이 본문에 노출되어 있다 (이는 의도적 fallback 가이드이므로 GAP 으로 승격할 사안은 아님).
- Recommended next action: description 의 후반부 ("ensures an isolated workspace exists via native tools or git worktree fallback") 압축 또는 trigger 표현으로 재작성.

---

## 3. Asset Snapshot

```text
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback
description_words: ~30
body_words: ~1210
body_lines: 215
tools: omitted
invocation_controls: none
has_references: no
has_scripts_or_assets: no (본문에 bash snippets inline)
has_effect_gate: yes (Step 0 detect + user consent + ignore verification + sandbox fallback)
has_output_contract: yes ("Worktree ready at <full-path>\nTests passing (...)\nReady to implement <feature-name>")
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.2 Scope Controls Quality`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`

### Skill Guide

- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §5 Effects And Gates`
- `SKILL-GUIDE.md §7 Output Contract`
- `SKILL-GUIDE.md §11 Anti-Patterns`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | "Use when starting feature work that needs isolation from current workspace or before executing implementation plans" |
| Description avoids workflow shortcut | partial | "ensures an isolated workspace exists via native tools or git worktree fallback" 가 본문 Step 0-1 요약 |
| Scope or near-miss is clear when needed | pass | Step 0 의 submodule guard, "Already in linked worktree → Skip creation" 케이스 명시 |
| Workflow is actionable | pass | Step 0 → 1a → 1b → 3 → 4 + Quick Reference |
| Effect gate exists when mutation is possible | pass | user consent prompt, ignore verification gate, sandbox fallback, baseline test gate |
| Output contract exists | pass | report template ("Worktree ready at ...") |
| Progressive disclosure is appropriate | pass | 본문이 단일 자산으로 self-contained, references 미보유는 합리적 |
| Reusable vs project memory is separated | pass | generic. `.worktrees/`, `~/.config/superpowers/worktrees/` 두 옵션을 platform-agnostic 으로 둠 |
| Behavior can be verified | pass | "Tests passing (<N> tests, 0 failures)" 으로 종료 조건 검증 가능 |
| Overlap is intentional | pass | "EnterWorktree" 같은 native tool 호환 안내가 명시되어 있어 platform fallback 의도가 분명 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P3 | `SKILL-GUIDE.md §3` | description 후반부가 본문 workflow 한 줄 요약 | trigger-only 로 다듬기 (낮은 우선순위) |

### GAP-001: Description trails into workflow summary

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §3 Description 작성`, `CONSTITUTION.md §3.1 Activation Must Be Explicit` |

**Expected**

description 후반부가 본문 workflow 의 요약이 되지 않도록 한다. 본 자산은 후반부 "ensures an isolated workspace exists via native tools or git worktree fallback" 이 Step 0-1 의 한 줄 요약이다.

**Actual**

`Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback`

**Evidence**

frontmatter line 3.

**Impact**

영향은 작다. routing 자체는 정확하다. 다만 description shortcut 경향 (모델이 본문을 건너뛰고 description 만 따라가는 위험) 이 미세하게 존재한다.

**Recommendation**

asset 수정 (낮은 우선순위). 예: `Use when starting feature work that needs an isolated workspace, or before executing implementation plans.` 후반부는 본문 상단으로 옮기거나 제거. P3 수준의 정리이다.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| 강한 표현 (`MUST`, `Never`) | 실제 gate (ignore 미설정 시 worktree 생성 금지, native tool 우선) 에 적용되어 v2 §3.8 부합 |
| `tools` 생략 | bash 중심 자산이며 platform default 에 의존. 권한 안전 영향 작음 |
| native tool 이름 (`EnterWorktree`, `WorktreeCreate`) 본문 inline | platform-specific fallback 가이드이며 의도적 |
| references 없음 | 본문이 단일 도메인, 215 lines 로 self-contained |

---

## 8. Suggested Changes

### Asset Changes

- [ ] (낮은 우선순위) description 후반부 압축 (GAP-001)

### Guide Changes

None

### Constitution Review

None

---

## 9. Follow-up Questions

None

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- detection → consent → verify → fallback → baseline 의 모든 gate 가 명시되어 있고 v2 §3.3 패턴을 그대로 따른다.
- 발견된 GAP 은 description shortcut 경향 1건 (P3) 이며 영향이 작다.
- P0/P1 안전 / 권한 / 산출 신뢰성 위험 없음.
