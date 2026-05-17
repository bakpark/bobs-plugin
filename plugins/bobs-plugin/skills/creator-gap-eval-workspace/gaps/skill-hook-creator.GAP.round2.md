# GAP Report — skill `hook-creator` (round 2)

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2.1
round: 2
검토자: gap-analysis (subagent, opus-4-7-1m)
asset_type: skill
source_path: plugins/bobs-plugin/skills/hook-creator/SKILL.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md
  (HOOK-GUIDE.md — 인용 정확성 spot-check 만)
final_decision: PASS_WITH_NOTES
scope_note: 본 라운드는 Step 4b §3-§4 stub 교체 회귀 검증에 한정.
            hook-creator 자산의 기존 status (🚧 일부 미완) 는 범위 밖.
```

## 2. Executive Summary

Round 1 (PASS) 이후 Step 4b 가 §3-§4 본문을 `creator-gap-eval` 호출 stub
으로 교체. 본 라운드는 stub 교체가 만든 회귀를 본 답변 상단의 4개 특화 검증축
(args 추출 가능성 / Final Decision 분기 완전성 / actionability 유지 / 외부 ref
호환) 중심으로 점검한다.

핵심 결과:

- **Axis 1 (args 추출 가능성)** — 6 args 중 5 args (`resource_type`,
  `draft_path` 2 파일 list, `delegation_mode`, `reentry_count`, `round_count`)
  완전 추출 가능. `asset_name` 만 §1 의 `<name>` placeholder 를 통해 *암묵*
  결정 — mini-example 의 `tsc-check` 가 dry-run 보강이 되어 caller 가 도출
  실패하지는 않음. P3 정도의 명시성 부족.
- **Axis 2 (Final Decision 분기 + 훅 특화 신호)** — 7 enum 모두 명시(§4
  line 165-172). REVISE_ASSET 행에 "registration 변경은 자동 실행 범위에 직접
  영향 — 항상 시점 B gate 지킴" (line 169) 단언 포함. SPLIT_ASSET 행에
  "Mixed responsibility — formatter/blocker/logger 분할" (line 170) 훅 특화
  신호 포함. 완전.
- **Axis 3 (actionability 유지 + matrix 위임)** — §3 stub 7 lines + §4 stub
  12 lines 가 caller 행동(GAP 호출 → 반환 yaml 분기 → 다음 phase)을 결정
  가능하게 유지. 자원-타입별 §11.4/§12.4 / P0/P1/SPLIT 신호는 line 161 의
  matrix 위임 한 줄로 정상 흡수. SKILL-GUIDE §6 의 "본문은 핵심 판단과
  workflow 를 담는다" 만족.
- **Axis 4 (외부 ref 호환)** — line 144 = `## 3. GAP 분석 (creator-gap-eval
  호출)`, line 163 = `## 4. Self-feedback refine — Final Decision 처리`.
  헤더 위치 둘 다 보존.

라운드 1 결론에서 신규 P0/P1 회귀 없음. 새로 1 건의 P3 (asset_name 도출 경로
명시성)만 추가. 다른 모든 §0-§2 본문은 round 1 시점과 동일하여 round 1 의
PASS 판정이 그대로 유효.

## 3. Asset Snapshot (Skill)

```text
name: hook-creator
description: |- (multi-line, ~120 words, round 1 과 동일)
description_words: ~120 (heuristic 15-60 초과지만 trigger + near-miss 풍부)
body_words: ~2750 (round 1: ~3680. §3-§4 stub 교체로 ~930 words 절감)
body_lines: 271 (round 1: 361. ~90 lines 절감 — 사양 명시 91 line 절감과
                 사실상 동일)
tools: omitted (frontmatter 에 명시 없음)
invocation_controls: 없음 (default model invocation 허용)
has_references: yes
  - references/matcher-pressure.md (round 1 잔류)
  - 권위 문서는 ${CLAUDE_PLUGIN_ROOT}/references/ 의 5종
  - creator-gap-eval/references/resource-type-matrix.md (line 161, 174)
has_scripts_or_assets: false
has_effect_gate: yes
  - §2 시점 A (첫 파일 쓰기 전 5항목 제시) — round 1 과 동일
  - §2 시점 B (수정 라운드 변경 요약 제시) — round 1 과 동일
  - §4 REVISE_ASSET 행 (line 169) "registration 변경은 자동 실행 범위에
    직접 영향 — 항상 시점 B gate 지킴" 단언 (stub 교체 후에도 보존)
has_output_contract: yes
  - §5 fenced block 형식 + 10 필드 Required/Value/empty 표 (round 1 잔류)
  - `blocked: needs revision` prefix 규칙 명시
```

## 4. Applicable Criteria

| 출처 | 적용 단원 |
|---|---|
| CONSTITUTION.md | §3 공통 원칙 (특히 §3.3, §3.4, §3.7, §3.14) |
| SKILL-GUIDE.md | §4 Frontmatter, §6 Body 설계, §7 Effects And Gates, §8 Progressive Disclosure, §9 Output Contract, §11 Quantitative Heuristics |
| GAP-FORMAT.md | §11.1 Skill Snapshot, §12.1 Skill Checks, §16 Final Decision (7 enum) |
| (참고) HOOK-GUIDE.md, GAP-ANALYSIS-PROMPT.md | 인용 heading 존재 여부 spot-check 만 |

본 라운드 추가 적용: GAP-FORMAT §16 의 7 enum 분기 완전성을 §4 stub 에
대조.

## 5. Checks (Skill)

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | round 1 과 동일. description 미변경 |
| Description avoids workflow shortcut | pass | description 미변경 |
| Skill is an automatic external/domain capability, not a user workflow | pass | round 1 결론 유지. 본 스킬은 hook 작성 procedural capability |
| Scope or near-miss is clear when needed | pass | "When NOT to use" + In-flight escape hatches 표 (§0) + Limits 미변경 |
| Capability procedure is actionable | pass | §0-§2 미변경. §3-§4 가 stub 으로 단축되었지만 caller 가 "args 6개 → creator-gap-eval 호출 → 반환 yaml 7-way 분기" 절차로 행동 가능 |
| Effect gate exists when mutation is possible | pass | §2 시점 A/B gate + §4 line 169 의 "registration 변경 → 항상 시점 B gate" 단언 (회귀 없음) |
| Output contract exists | pass | §5 미변경 (10 필드 표 보존). 추가로 §3 stub yaml schema 가 *creator-gap-eval 으로의* input contract 역할 |
| Progressive disclosure is appropriate | pass | §3-§4 본문 91 lines 절감 — hook 특화 신호를 matrix reference 로 위임. SKILL-GUIDE §8 "큰 reference 는 별도 파일로 분리" 강화 방향 |
| Reusable vs project memory is separated | pass | round 1 과 동일 |
| Behavior can be verified | partial | mini-example (§Mini example) 이 stub 교체 후에도 "round 1 → round 2 → PASS_WITH_NOTES" 흐름을 보임. dry-run 가능. 다만 stub 의 args 도출 step-by-step trace 가 본문에 없어 처음 사용자에게는 mini-example 까지 읽어야 보임 — heuristic 수준 |
| Overlap is intentional | pass | "When NOT to use" + 관련 자산 라인 미변경 |

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P3 | `SKILL-GUIDE.md §6 Body 설계` | §3 stub 의 `asset_name` 도출 경로가 §1 의 `<name>` placeholder 를 통한 *암묵 추출* — §0-§2 어디에서도 "asset_name 을 kebab-case 로 결정한다" 단계가 명시되지 않음 | 자산 수정: §1 첫 항목으로 "asset_name (kebab-case) 확정" 한 줄 추가, 또는 §3 stub 의 `asset_name` 주석에 "§1 path 의 `<name>` 위치 값" 명시 |

### GAP-001: `asset_name` 도출 경로 명시성

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §6 Body 설계` (actionability) |

**Expected**

§3 stub 의 6 args 모두 §0-§2 산출에서 *명시적* 으로 도출 가능해야 한다.
caller 가 stub 본문을 읽고 args 모두를 placeholder 없이 채울 수 있어야 한다.

**Actual**

- `resource_type: hook` — literal value, 추출 trivial. ✔
- `draft_path[0] = SCRIPT_PATH` — §1 의 scope 표 (line 84-86) "hooks/<name>.sh" 에서 추출 가능. ✔
- `draft_path[1] = REGISTRATION_PATH` — §2 시점 A 5항목 중 항목 2 (line 113) "settings.json 의 hooks 절" 또는 "새 hooks.json" 에서 추출 가능. ✔
- `asset_name` — §3 stub 153 line 주석 "§1 에서 결정된 kebab-case" 라 적혀 있지만, §1 본문 (line 80-98) 은 path 템플릿에 `<name>` placeholder 만 사용하고 별도로 "asset_name 을 어떻게 정한다" 결정 단계가 없음. 사용자 의도 + scope 표 → path 의 `<name>` 위치 → kebab-case 도출이라는 3 단 추론 필요.
- `delegation_mode: delegate` — default literal. ✔
- `reentry_count: 0` / `round_count: 0` — fixed literals. ✔

**Evidence**

- `SKILL.md:84-86` (`<name>` placeholder)
- `SKILL.md:153` (asset_name 주석 — "§1 에서 결정된 kebab-case")
- `SKILL.md:246` (mini-example 의 `tsc-check.sh` — `<name>` = `tsc-check` 라는 단서)

**Impact**

caller 가 args 채우기 첫 호출에서 잠시 멈칫할 가능성. mini-example 까지 읽으면
해결되므로 routing 차단/실패는 없음. 영향 낮음 → P3.

**Recommendation**

자산 수정. 최소 변경: §1 첫 줄에 "asset_name 결정: 단일 책임을 표현하는
kebab-case 한 단어 (예: `tsc-check`, `format-on-edit`). path 의 `<name>`
위치에 동일 값을 사용." 한 문장 추가.

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| description ~120 words (heuristic 15-60 초과) | round 1 평가 그대로. trigger + near-miss 풍부. workflow shortcut 아님 |
| body_lines 271 (메타 스킬 + verification loop + escape hatch 구조) | SKILL-GUIDE §11 "긴 메타/교육형 스킬: eval, reference, verification 구조가 있으면 길 수 있다". 본 라운드는 round 1 의 361 → 271 로 *축소* 방향이라 heuristic 압박 완화 |
| §3-§4 stub 의 자원 특화 신호 (P0/P1 패턴, SPLIT 신호, §11.4/§12.4 reference) 가 line 161 한 줄의 matrix 위임에 압축됨 | SKILL-GUIDE §8 Progressive Disclosure 의 "큰 reference 는 별도 파일로 분리" 원칙에 부합. matrix 파일 실재 확인 — `creator-gap-eval/references/resource-type-matrix.md` 의 hook 컬럼이 11 개 분기 키 (snapshot/checks/delegation axis/workspace pattern/reroute 등) 를 모두 다룸 |
| §3 stub line 161 의 reference path 가 `${CLAUDE_PLUGIN_ROOT}/skills/...` prefix 없이 `creator-gap-eval/references/...` 로 시작 | line 174 의 두 번째 reference 도 같은 형식. 두 reference 가 *동일한 plugin sibling skill* 의 내부 자산이라는 점이 명확하므로 prefix 생략이 의도적. 만약 future 에 cross-plugin 사용이 생기면 명시화 필요 |
| `MUST` / `NEVER` 등 강한 표현 사용 | round 1 평가 그대로. 사용 위치가 모두 실제 gate |
| `When the loop stalls` §의 matcher-pressure.md fallback "(있을 경우; 없으면 본 절의 요약만 사용)" 잔류 | round 1 평가 그대로 |

## 8. Stub-replacement regression check (round 2 추가)

본 라운드 핵심. round 1 PASS 자산이 §3-§4 stub 교체로 새 finding 을
얻었는지 검증.

| 검증축 | 결과 | 근거 |
|---|---|---|
| 1. §3 stub args 추출 (6 args) | 5/6 완전 / 1 partial | 위 GAP-001 |
| 2. §4 Final Decision 7 enum 분기 + 훅 특화 신호 | 완전 (no gap) | line 165-172 에 PASS / PASS_WITH_NOTES / REVISE_GUIDE / REVISE_ASSET / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW 7 enum 모두 명시. REVISE_ASSET 행 (169) 에 "registration 변경 → 시점 B gate" 단언. SPLIT_ASSET 행 (170) 에 "Mixed responsibility — formatter/blocker/logger 분할" 훅 특화 신호 |
| 3. §3-§4 ~91 lines 절감 후 actionability 유지 + §11.4/§12.4 matrix 위임 | 완전 (no gap) | body_lines 361 → 271 (≈ 90 lines 절감, 사양 명시 91 와 사실상 동일). caller 행동(args 채우기 → 호출 → 반환 yaml 7-way 분기)이 stub 만 읽어도 결정 가능. §11.4 Hook Snapshot · §12.4 Hook Checks 위임은 line 161 의 matrix reference 한 줄로 단일화 |
| 4. 외부 ref 호환 — §3 (line 144) / §4 (line 163) 헤더 보존 | 완전 (no gap) | 헤더 line 위치, heading text 모두 사양과 일치 |

회귀 없음 결론 — 본 라운드의 신규 finding 은 GAP-001 (P3) 1 건 뿐이며,
이는 stub 교체와 *직접 인과* 가 아닌 §1 본문의 누락 (round 1 시점부터 잠재
존재했으나 stub 으로 옮겨가며 더 가시화됨).

## 9. Suggested Changes

### Asset Changes

- [ ] (P3) §1 첫 줄에 "asset_name 결정: 단일 책임을 표현하는 kebab-case (예: `tsc-check`). path 의 `<name>` 위치에 동일 값." 한 문장 추가. GAP-001 해소.

### Guide Changes

- [ ] None.

### Constitution Review

- [ ] None.

## 10. Follow-up Questions

- (round 1 잔류) `skill-creator` / `agent-creator` / `hook-creator` 세
  자산이 §3-§4 stub 으로 균일화됐다면, 세 자산 모두에 동일한 "asset_name
  결정" 한 줄을 추가하는 것이 일관성 측면에서 합리적. 단일 스킬 GAP
  범위 밖이므로 finding 으로 승격하지 않는다.

## 11. Final Decision

**`PASS_WITH_NOTES`**

Step 4b §3-§4 stub 교체에 따른 회귀는 없음. 4 개 특화 검증축 중 1-4 모두
통과 (Axis 1 만 P3 1 건). round 1 의 PASS 판정이 본 라운드에서도 유효하며,
신규 P3 1 건은 자산 목적과 충돌하지 않아 PASS 를 PASS_WITH_NOTES 로
보정한다.

권고 조치 1 건 (GAP-001, P3 — asset_name 도출 경로 명시 한 줄) 만 적용하면
다음 라운드에서 PASS 로 복귀 가능.
