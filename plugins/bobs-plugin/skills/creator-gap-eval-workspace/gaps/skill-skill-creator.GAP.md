# GAP Report — skill `skill-creator`

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2.1
검토자: GAP 분석 위임 subagent (cwd: plugins/bobs-plugin/references/)
asset_type: skill
source_path:
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator/SKILL.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md, GAP-ANALYSIS-PROMPT.md
final_decision: PASS_WITH_NOTES
```

본 리포트는 Step 4b 의 `creator-gap-eval` 추출에 따른 §3-§4 stub 교체 *후* 의 `skill-creator/SKILL.md` 가 SKILL-GUIDE / CONSTITUTION 의 핵심 기대를 여전히 충족하는지 회귀 검증한 결과다. envelope 의 4 stub-특화 검증축을 일반 SKILL-GUIDE 평가에 더한 *additive* 평가다.

---

## 2. Executive Summary

`skill-creator` 의 stub 교체 (§3-§4 본문 ~95 lines 절감, 337 → 241 lines) 는 의도된 progressive disclosure 강화 — 절차 본문은 `creator-gap-eval/SKILL.md` 와 `references/resource-type-matrix.md` 로 위임되고, 본 스킬은 *호출자 책임 영역* (의도 캡처 / scope / draft / 위임 호출 / 분기 행동 / 최종 응답 / 톤 정리) 만 유지한다.

4 stub-특화 검증축 모두 통과:

1. **§3 stub args 6 추출 가능성** — pass. §1 (kebab-case name → `asset_name`), §2 (절대 경로 → `draft_path`) 에서 결정된 값이 §3 yaml 의 placeholder 와 매핑된다. `resource_type` / `delegation_mode` / `reentry_count` / `round_count` 는 stub yaml 에 default 값 명시.
2. **§4 Final Decision 7 enum 완전성** — pass. lines 157-162 에 7 enum 모두 명시 (PASS / PASS_WITH_NOTES → §5, REVISE_GUIDE → §5, REVISE_ASSET → 재호출 round +1, SPLIT_ASSET → §0, DEPRECATE_ASSET → 사용자 confirm, NEEDS_REVIEW → 사용자 입력). 분기 누락 없음.
3. **본문 절감 후 actionability 유지** — pass. §3-§4 본문은 사라지지 않고 *위임* 으로 명시 (line 164 가 Phase 7-9 + matrix 참조). yaml args 6 개와 Final Decision 7 enum 분기는 stub 안에 *직접* 명시되어 호출자가 즉시 행동 가능.
4. **외부 ref 호환** — pass. §3 헤더 = line 137, §4 헤더 = line 153. 헤더 보존되어 외부 인용 ("§3 시점 B gate" 등) 안전.

일반 SKILL-GUIDE 평가에서도 의미 있는 ASSET_GAP 은 없다. 단, P3 잔류 항목 2 건 (informational) 이 있어 `PASS_WITH_NOTES` 가 적합하다 — `final_decision` 이 자산 목적과 충돌하지 않으며 stub 교체 자체가 회귀를 일으키지 않는다.

---

## 3. Asset Snapshot

```text
name: skill-creator
description: Use when creating, scaffolding, editing, or verifying a Claude Code skill (`SKILL.md` under `skills/<name>/`). Triggers on "create a skill", "스킬 만들어줘", "skill 작성·개선", "/skill-name 만들어줘", "draft a skill for X" — including when the user has not yet chosen a name or scope. Do NOT use for writing subagents (`agent-creator`), agent-vs-skill / merge / migration-order decisions (`resource-design`), static rule audit of an existing skill (`agent-skill-auditor`), or PR/code edits.
description_words: ~75 (영문 기준 ~70. trigger phrase 5 + sibling Do-NOT 4)
body_words: ~1,650
body_lines: 241 (stub 교체 후. 교체 전 337 → -96)
tools: omitted (frontmatter — 본문 §Limits 에서 Read/Write/Edit/Bash/Agent 명시)
invocation_controls: default (user-invocable 명시 안 함 — automatic 활성화)
has_references: yes (red-green-refactor.md, trigger-eval.md — 본문 §When the loop stalls / §Description optimization 에서 lazy-load)
has_scripts_or_assets: no
has_effect_gate: yes (§2 시점 A/B — 첫 파일 쓰기 전 + 수정 반영 전, 사용자 명시 신호 필요)
has_output_contract: yes (§5 — created/updated, scope, gap, findings, gap_report, guide_gaps, follow-ups + blocked prefix)
```

---

## 4. Applicable Criteria

본 리포트가 직접 적용한 normative source:

- `CONSTITUTION.md` (§3.1 Activation, §3.3 Effects Require Gates, §3.4 Output Is A Contract, §3.5 Capability Surface, §3.7 Progressive Disclosure, §3.8 Strong Language, §3.10 Overlap Intentional, §3.11 Command Boundary)
- `SKILL-GUIDE.md` (§3 Skill vs Command Boundary, §4 Frontmatter, §5 Description, §6 Body 설계, §7 Effects And Gates, §8 Progressive Disclosure, §9 Output Contract, §11 Quantitative Heuristics, §13 Anti-Patterns)
- `GAP-FORMAT.md` (§4 판정 원칙, §5 원칙 강도, §7 Severity, §16 Final Decision)
- `GAP-ANALYSIS-PROMPT.md` (Skill 점검 축, Evidence 작성 규칙, 리포트 구조)

본 평가가 부여한 **4 stub-특화 검증축** (일반 SKILL-GUIDE 외 additive):

1. §3 stub 의 args 6 (resource_type / draft_path / asset_name / delegation_mode / reentry_count / round_count) 추출 가능성 — §0-§2 산출에서 모두 결정 가능한지
2. §4 stub 의 Final Decision 7 enum (PASS / PASS_WITH_NOTES / REVISE_GUIDE / REVISE_ASSET / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW) 분기 완전성
3. §3-§4 본문 ~95 lines 절감 후 SKILL-GUIDE §6 Body 의 actionability 유지 — 절차 본문이 사라지지 않고 *위임* 으로 명시되었는지
4. 외부 ref 호환 — §3/§4 헤더 (line 137, line 153) 보존으로 외부 인용 (`§3 시점 B gate` 등) 안전

---

## 5. Checks

### 5.1 SKILL-GUIDE 일반 Checks (GAP-FORMAT §12.1)

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | description 에 한·영 trigger phrase 5 + sibling Do-NOT 4 명확. "create a skill" / "스킬 만들어줘" / "/skill-name 만들어줘" 등 |
| Description avoids workflow shortcut | pass | trigger / 호출 시점 / Do-NOT 만 명시. §0-§6 내부 절차 나열 없음 |
| Skill is an automatic external/domain capability, not a user workflow | partial | 메타 스킬 — 자산 생성·검증 capability. user-invocable 명시 안 함 (= 자동 활성화). 본문 §0-§2 의 의도 캡처는 capability 의 일부지 user workflow 자체는 아님 (질문은 *능력 확장* 의 입력 캡처). 다만 §0 의 6 질문 묶음은 일부 workflow 성격이 있어 partial — 단 SKILL-GUIDE §2 의 "Scaffolding/Templates" category 에 해당해 정당화됨 |
| Scope or near-miss is clear when needed | pass | §When NOT to use 에 6 항목 (agent-creator / resource-design / command 트랙 / agent-skill-auditor / evaluation-loop-design / codex-reviewer) 명시 |
| Capability procedure is actionable | pass | §0-§6 모두 실행 가능. 특히 §3 stub yaml + §4 분기 표가 호출 인터페이스 명확. line 137/153 헤더 보존으로 외부 인용 안전 |
| Effect gate exists when mutation is possible | pass | §2 시점 A (첫 파일 쓰기 전, 4 항목 제시) / 시점 B (수정 반영 전, 변경 요약) 명시. "사용자가 '진행' / 'go' / 'proceed' 같은 명시적 신호를 줄 때만" 명시 |
| Output contract exists | pass | §5 형식 7 필드 + blocked prefix + 세부 finding 본문 풀어 쓰지 말고 GAP report 경로 안내 |
| Progressive disclosure is appropriate | pass | stub 교체로 강화됨 — §3-§4 본문 위임. red-green-refactor.md / trigger-eval.md / creator-gap-eval references 모두 lazy-load. SKILL.md 241 lines (메타 스킬치고 적정) |
| Reusable vs project memory is separated | pass | `${CLAUDE_PLUGIN_ROOT}` env + fallback `../../references/` 명시. plugin-portable |
| Behavior can be verified | partial | §Mini example (1 시나리오) + §When the loop stalls (4 분기) 가 verification 신호. round/reentry 한도 시나리오, 7 final_decision 분기 verification 미명시 — 단, Step 4b 회귀 검증은 본 GAP report 자체가 그 역할 |
| Overlap is intentional | pass | 관련 자산 4개 (writing-skills / agent-creator / resource-design / agent-skill-auditor) + When NOT to use 6 항목 모두 차이 설명 |

### 5.2 4 Stub-특화 검증축 Checks

| # | Check | Status | Notes |
|---|---|---|---|
| 1 | §3 stub args 6 추출 가능성 | pass | resource_type=skill (자명) · draft_path=<SKILL_PATH>/SKILL.md (§2 절대 경로) · asset_name=<name> (§1 kebab-case) · delegation_mode/reentry_count/round_count 모두 default 값 명시. Finding GAP-001 (P3) 참조 |
| 2 | §4 Final Decision 7 enum 완전성 | pass | lines 157-162 7 enum 모두 명시. PASS/PASS_WITH_NOTES → §5, REVISE_GUIDE → §5, REVISE_ASSET → 재호출 +1, SPLIT_ASSET → §0, DEPRECATE_ASSET → 사용자 confirm, NEEDS_REVIEW → 사용자 입력 |
| 3 | 본문 절감 후 actionability 유지 | pass | §3 본문 line 137-152 (16 lines) + §4 본문 line 153-164 (12 lines) = stub 28 lines. 위임 명시 (line 164 가 Phase 7-9 + matrix 참조). 절차 손실 없음 |
| 4 | 외부 ref 호환 (§3/§4 헤더 보존) | pass | §3 헤더 = line 137 ✓, §4 헤더 = line 153 ✓. 헤더 텍스트가 "GAP 분석 (creator-gap-eval 호출)" / "Self-feedback refine — Final Decision 처리" 로 *확장* 되었으나 §3/§4 번호 식별자가 명백히 보존 — "§3 시점 B gate" 같은 인용 안전 |

---

## 6. Findings

### 6.1 요약 표

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P3 | `SKILL-GUIDE.md §6 Body 설계` | §2 가 `SKILL_PATH` 변수명을 명시하지 않음 — §3 stub yaml 의 `<SKILL_PATH>/SKILL.md` 가 어디서 결정된 변수인지 약간의 매핑 작업 필요 | 자산 수정 (optional) — §2 의 "작성될 파일 절대 경로" 옆에 "(이하 `SKILL_PATH` 로 칭함)" 1 phrase 추가 |
| GAP-002 | ASSET_GAP | P3 | `CONSTITUTION.md §3.9 Behavior Must Be Verifiable` | §4 의 round 한도 / reentry 한도 / 7 final_decision 분기 verification 시나리오가 본문에 미명시 — Mini example 은 1 시나리오만 | 자산 수정 (optional) — Mini example 에 round 한도 시나리오 1줄 추가 또는 verification 책임을 creator-gap-eval 에 위임함을 본문 명시 |

### 6.2 상세

#### GAP-001: §2 에 `SKILL_PATH` 변수명 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §6 Body 설계` (capability procedure 의 actionability) |

**Expected**

§3 stub yaml (line 144) 의 `<SKILL_PATH>/SKILL.md  # §2 에서 결정된 절대 경로` 가 placeholder 로 명시되므로, §2 본문에서 *동일 변수명* (`SKILL_PATH`) 이 산출 시점에 정의되어 있으면 호출자가 매핑을 즉시 수행할 수 있다.

**Actual**

§2 line 107: "1. 작성될 파일 절대 경로 (§1 에서 결정된 path)" — 절대 경로가 산출됨은 명백하지만 *변수명* `SKILL_PATH` 가 본문에 등장하지 않는다. §3 stub 의 `<SKILL_PATH>` placeholder 와 §2 산출 사이에 명시적 binding 이 없다.

**Evidence**

- `skill-creator/SKILL.md` §2 line 106-117 ("시점 A — 첫 파일 쓰기 전 (§2 본문 작성)" 의 4 항목 중 1번)
- `skill-creator/SKILL.md` §3 line 144 (`<SKILL_PATH>/SKILL.md  # §2 에서 결정된 절대 경로`)

**Impact**

호출자 (skill-creator 본문을 따라가는 모델) 가 §3 stub yaml 을 채울 때 "§2 에서 결정된 절대 경로 = <SKILL_PATH>" 의 1-step 추론이 필요. 영향은 미미 — 주석으로 매핑이 *이미* 명시되어 있어 실패 가능성 낮음. P3 (informational).

**Recommendation**

자산 수정 (optional). §2 line 107 을 "1. 작성될 파일 절대 경로 (§1 에서 결정된 path. 이하 `SKILL_PATH` 로 칭함)" 로 1 phrase 추가하면 명시적 binding 완성. 변경 없이도 작동에는 무리 없음.

---

#### GAP-002: round/reentry 한도 verification 시나리오 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.9 Behavior Must Be Verifiable` |

**Expected**

§4 가 7 final_decision 분기 + round_count 한도 (5 초과 시 NEEDS_REVIEW) + reentry_count 한도 (>2 시 NEEDS_REVIEW) 의 분기를 명시하므로, behavior verification 으로 *각 분기가 의도대로 작동하는지* 검증할 수 있는 시나리오 (예: round 5 도달 시 자동 NEEDS_REVIEW 반환) 가 본문에 1-2 줄 언급되면 좋다.

**Actual**

§Mini example (lines 212-218) 은 1 시나리오 (weather-fetcher, round 2 PASS_WITH_NOTES 종료) 만 제공. round 한도 초과 / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW 시나리오 verification 본문에 미명시. 단 §When the loop stalls (lines 220-229) 가 4 분기 폴백 절차를 명시해 일부 보완.

**Evidence**

- `skill-creator/SKILL.md` §Mini example (lines 210-218): 1 시나리오 only
- `skill-creator/SKILL.md` §When the loop stalls (lines 220-229): 4 분기 폴백 (SPLIT_ASSET / 자원 타입 오류 / GUIDE_GAP / NEEDS_REVIEW)

**Impact**

stub 교체로 §3-§4 본문이 creator-gap-eval 로 위임되었으므로 round/reentry 한도 verification 책임도 creator-gap-eval/SKILL.md Phase 8 에 자연스럽게 위임된 상태. 본 스킬의 verification 부담은 reduced. 영향 미미. P3 (informational).

**Recommendation**

자산 수정 (optional). §When the loop stalls 또는 §Mini example 끝에 "round/reentry 한도 verification 은 creator-gap-eval/SKILL.md Phase 8 책임" 1줄 추가. 또는 round 한도 시나리오 1 줄 추가. 변경 없이도 위임 구조상 작동.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| §3-§4 본문이 ~28 lines stub 으로 축소 | 의도된 Step 4b 추출. 절차는 creator-gap-eval/SKILL.md + references/resource-type-matrix.md 로 위임. progressive disclosure 강화 (SKILL-GUIDE §8) |
| §3/§4 헤더가 텍스트 확장 ("GAP 분석 (creator-gap-eval 호출)") | §3/§4 번호 식별자 보존 — 외부 인용 ("§3 시점 B gate") 안전. 헤더 텍스트 확장은 stub 의도 명시 (호출 위임) 로 가독성 ↑ |
| 메타 스킬임에도 본문 241 lines | SKILL-GUIDE §11 의 "긴 메타/교육형 스킬은 eval/reference/verification 구조가 있으면 길 수 있다" 적용. §0 의도 캡처 6 질문 + §2 시점 A/B gate + §6 톤 정리 + §Mini example + §When the loop stalls 가 메타 스킬 필수 구조 |
| `tools` frontmatter omitted (본문 §Limits 에서 capability surface 명시) | §Limits (lines 237-241) 가 본 스킬 사용 도구 (Read/Write/Edit/Bash/Agent) 와 *미사용* (Web/MCP/외부 모델) 을 명시. frontmatter `tools` 가 아니라 본문 §2 시점 A/B gate + §4b gate (구 §3-§4) 로 통제됨을 명시. SKILL-GUIDE §4 "`tools` 명시는 필수 필드가 아니다. 다만 read-only 나 mutation 제한이 중요하면 명시하는 편이 낫다" — 본 스킬은 mutation 제한을 *gate* 로 처리해 정당화 |
| description 길이 ~75 words (권장 15-60 초과) | SKILL-GUIDE §11 heuristic — 본 스킬은 trigger phrase 5 (한·영) + sibling Do-NOT 4 가 필수 (라우팅 정확도 위해). workflow shortcut 없음 확인 |
| §0 의 6 질문 묶음이 일부 workflow 성격 | SKILL-GUIDE §2 "Scaffolding/Templates" category — 의도 캡처는 자산 생성 capability 의 입력 단계. user workflow 자체가 아니며 user-invocable 명시 안 함 (자동 활성화) |

---

## 8. Suggested Changes

### Asset Changes

- [ ] §2 line 107 에 "(이하 `SKILL_PATH` 로 칭함)" 1 phrase 추가 (GAP-001, optional)
- [ ] §When the loop stalls 끝 또는 §Mini example 에 round/reentry 한도 verification 위임 1 줄 명시 (GAP-002, optional)

### Guide Changes

None — SKILL-GUIDE 의 핵심 기대를 본 자산이 충족하며, stub 교체가 일으킨 새로운 GUIDE_GAP 패턴은 없다.

### Constitution Review

None.

---

## 9. Follow-up Questions

None. 본 회귀 검증의 4 stub-특화 검증축 + 일반 SKILL-GUIDE 평가 모두 추가 사용자 확인 없이 판단 가능.

---

## 10. Final Decision

**`PASS_WITH_NOTES`**

이유:
1. 4 stub-특화 검증축 모두 pass — Step 4b 의 §3-§4 stub 교체가 회귀를 일으키지 않았다.
2. 일반 SKILL-GUIDE 평가에서 P0/P1/P2 finding 없음 — P3 informational 2건만 잔류.
3. 잔류 P3 (GAP-001 변수명 / GAP-002 verification 시나리오) 는 자산 목적과 충돌하지 않으며 작동에는 무리 없음.
4. progressive disclosure 강화 (SKILL-GUIDE §8) + actionability 유지 (§3/§4 stub 안에 yaml args 6 + 7 enum 분기 직접 명시) 의 trade-off 가 잘 균형 잡힘.

추후 자산 수정 시 P3 2 건 반영 권장 (optional). 본 결정은 stub 교체 *후* 의 회귀 검증이며, REVISE_ASSET 으로 승격할 사유 없음.
