# Skill GAP Report: skill-creator

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/skill-creator/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 메타 스킬이며 v2 §4 의 "허용되는 변형: 메타 스킬 (baseline, pressure scenario, eval loop, description optimization)" 에 정확히 부합한다. eval workspace 구조, subagent 호출, benchmark 산출, description optimization 까지 contract 가 분명하다.
- Highest severity: P2
- Main gap: (1) 길이가 본문 5200+ words, 485 lines 로 일반 호출 빈도 대비 큰 편. progressive disclosure 측면에서 일부 단계 (Claude.ai-specific, Cowork-specific) 는 reference 분리 후보. (2) writing-skills 와의 책임 차이가 description 에 노출되지 않음 — overlap 명료화 필요.
- Recommended next action: writing-skills 와의 near-miss 한 줄을 description 또는 본문 상단에 추가. platform-specific 분기는 references 로 옮기는 것 고려.

---

## 3. Asset Snapshot

```text
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
description_words: ~50
body_words: ~5200
body_lines: 485
tools: omitted
invocation_controls: none
has_references: yes (agents/, references/, assets/, eval-viewer/, scripts/)
has_scripts_or_assets: yes (multiple scripts under scripts/, agents/grader.md, etc.)
has_effect_gate: partial (mutation 자체가 본질이지만 eval-driven iteration loop 가 review gate 역할)
has_output_contract: yes (workspace 구조, eval_metadata.json, benchmark.json, feedback.json, package_skill.py 산출)
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`
- `CONSTITUTION.md §3.9 Behavior Must Be Verifiable`
- `CONSTITUTION.md §3.10 Overlap Must Be Intentional`

### Skill Guide

- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 Body 설계`
- `SKILL-GUIDE.md §6 Progressive Disclosure`
- `SKILL-GUIDE.md §7 Output Contract`
- `SKILL-GUIDE.md §8 Verification`
- `SKILL-GUIDE.md §9 Quantitative Heuristics`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | "Use when users want to create a skill from scratch, edit, or optimize ..." |
| Description avoids workflow shortcut | partial | "run evals ... benchmark ... optimize description" 으로 본문 단계가 일부 노출되지만 trigger 의 합리적 키워드이기도 함 |
| Scope or near-miss is clear when needed | gap | writing-skills 와의 책임 분리가 description 또는 본문 상단에 없다 |
| Workflow is actionable | pass | Capture Intent → Test Cases → Run/Evaluate → Iterate → Description Optimization → Package |
| Effect gate exists when mutation is possible | partial | 명시적 사용자 승인 gate 보다 "user reviews results in viewer → improvements" 형태의 review loop 가 gate 역할 |
| Output contract exists | pass | workspace 디렉토리 구조, JSON schema, feedback.json, package 산출 모두 명시 |
| Progressive disclosure is appropriate | partial | 본문 5200+ words. Claude.ai / Cowork 분기는 references 로 분리 후보 |
| Reusable vs project memory is separated | pass | generic |
| Behavior can be verified | pass | 본 스킬이 곧 verification framework 를 제공 |
| Overlap is intentional | gap | writing-skills 와의 책임 차이가 본문에 명시되지 않음 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `CONSTITUTION.md §3.10`, `SKILL-GUIDE.md §3` | writing-skills 와의 overlap 미설명 | description 또는 본문 상단에 near-miss 한 줄 추가 |
| GAP-002 | ASSET_GAP | P2 | `SKILL-GUIDE.md §6, §9` | platform-specific 분기 (Claude.ai, Cowork) 가 본문에 inline | references/claude-ai.md, references/cowork.md 로 분리 후보 |

### GAP-001: Overlap with writing-skills is not explained

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.10 Overlap Must Be Intentional`, `SKILL-GUIDE.md §3 Description 작성` |

**Expected**

유사 자산은 trigger, scope, output, capability 중 하나로 차이를 드러내야 한다. skill-creator 와 writing-skills 는 모두 "스킬을 만든다" 라는 도메인을 다룬다.

**Actual**

skill-creator description: "Create new skills, modify and improve existing skills, and measure skill performance."

writing-skills description: "Use when creating new skills, editing existing skills, or verifying skills work before deployment"

두 description 만 보면 trigger 가 거의 동일하다. 본문을 보면 차이가 분명하다:
- skill-creator: eval workspace, benchmark, viewer, description optimization 루프 등 정량 평가 중심
- writing-skills: TDD-style baseline + pressure scenario + rationalization table 중심

하지만 description 단계에서는 어느 쪽을 로드할지 모델이 구분하기 어렵다.

**Evidence**

두 SKILL.md frontmatter.

**Impact**

라우팅 모호성. 호출자가 어떤 스킬을 먼저 읽어야 할지 description 만 보고 결정하기 어렵다. context 비용은 둘 다 큰 편(5200 vs 3200 words)이라 잘못 호출되면 비용도 커진다.

**Recommendation**

asset 수정. 예: skill-creator description 끝에 "(For pressure-scenario / rationalization-driven approach instead, see writing-skills.)" 같은 near-miss 한 줄 또는 본문 상단의 차이 설명. writing-skills 측에도 대칭 표기.

### GAP-002: Platform-specific branches inline inflate body

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §6 Progressive Disclosure`, `SKILL-GUIDE.md §9 Quantitative Heuristics` |

**Expected**

큰 reference / 환경-의존 분기는 본문 밖으로 분리. 본문은 호출 시 매번 읽힌다.

**Actual**

"Claude.ai-specific instructions" (line 420-441), "Cowork-Specific Instructions" (line 444-455) 가 본문에 inline. 본문 전체 5200+ words 의 일부지만 일반 Claude Code 사용 시 매번 읽힌다.

**Evidence**

본문 line 420-455.

**Impact**

context 비용. 단일 자산이라 안전 위험은 없으나, 빈번 호출되면 누적된다.

**Recommendation**

asset 수정 옵션. `references/platform-specific.md` 또는 `references/claude-ai.md`, `references/cowork.md` 로 분리하고 본문에는 "If running in Claude.ai, see ..." 한 줄로 link.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| 본문 길이 (5200 words) | 메타 스킬, eval 파이프라인 전체를 포함. v2 §9 의 "긴 메타/교육형 스킬은 eval, reference, verification 구조가 있으면 길 수 있다" 에 해당 |
| 분야별 강한 톤 ("GENERATE THE EVAL VIEWER *BEFORE* ...") | 모델 우회 방지 목적, 실제 gate (viewer 미생성 시 사용자 review 불가) 위치 |
| `tools` 생략 | mutation, subagent dispatch, browser open 등 다양한 도구를 사용하는 메타 작업 |
| `disable-model-invocation` 없음 | 사용자가 직접 호출하는 경로도 있고 모델 자동 호출 경로도 의도되어 보임 |

---

## 8. Suggested Changes

### Asset Changes

- [ ] writing-skills 와의 near-miss 한 줄 추가 (GAP-001)
- [ ] platform-specific 분기를 references 로 분리 (GAP-002)
- [ ] (선택) 본문 마지막의 "core loop" 반복 요약은 본문 상단 overview 와 중복 가능 — 정리 후보

### Guide Changes

- [ ] **GUIDE_GAP 후보 (낮은 우선순위):** `SKILL-GUIDE.md` 의 "허용되는 변형: 메타 스킬" 항목에 "platform-specific instructions 는 references 분리를 권장한다" 한 줄 추가 검토. 단, 이는 skill-creator + writing-skills 두 자산에서만 나타나는 패턴이며 일반 권장으로 승격할 만큼 누적되었는지 불명. 본 리포트에서는 우선 ASSET_GAP 으로 남긴다.

### Constitution Review

None

---

## 9. Follow-up Questions

- writing-skills 와 skill-creator 가 의도적으로 분리되어 있는지 (한쪽은 "discipline" 측면, 다른 쪽은 "eval loop" 측면) 여부. 만약 통합 / 분리 의도가 분명하다면 description 에 그 의도를 한 줄 노출하는 것만으로 GAP-001 해소.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- 메타 스킬로서 v2 §4, §8 의 "검증 루프" 구조를 본 자산 스스로가 가장 잘 구현한다.
- 발견된 GAP 은 overlap 설명 부재와 progressive disclosure 미세 개선이며 모두 P2.
- P0/P1 안전/권한/산출 신뢰성 위험은 없다.
