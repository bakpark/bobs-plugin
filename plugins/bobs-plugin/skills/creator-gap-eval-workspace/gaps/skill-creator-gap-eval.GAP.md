# GAP Report — skill `creator-gap-eval`

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2.1
검토자: GAP 분석 위임 subagent (cwd: plugins/bobs-plugin/references/)
asset_type: skill
source_path:
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/creator-gap-eval/references/resource-type-matrix.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/creator-gap-eval/references/delegation-envelope.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md, GAP-ANALYSIS-PROMPT.md
final_decision: REVISE_ASSET
```

본 리포트는 3 파일을 **한 skill 자산** (SKILL.md + 2 references) 으로 통합 평가한다. 각 finding 의 `Evidence` 필드에 어느 파일의 어느 위치인지 명시한다.

---

## 2. Executive Summary

`creator-gap-eval` 은 3 creator (skill/agent/hook) 의 §3 GAP 분석을 통합 흡수하는 메타 skill 로, 자원-타입 분기를 matrix 로, 위임 envelope 를 별도 reference 로 분리한 progressive-disclosure 설계가 견고하다. activation signal, 사용자 직접 호출 지원 (`user-invocable: true`), 자체 workspace 결정, path-based self-application 검출, round/reentry 한도, output contract (YAML) 가 모두 명시되어 있다.

다만 다음 4 가지 실제 영향 있는 GAP 이 발견되었다.

1. **Input Contract 의 args 수 불일치 (P1)** — Input Contract YAML 은 5 개 args 만 정의 (`resource_type / draft_path / asset_name / delegation_mode / reentry_count`) 하지만, Phase 2 (line 75) 와 Output Contract (line 166) 가 `round_count` 를 호출자 echo 값 / 반환 필드로 *사용* 한다. 호출자는 "round_count 를 args 로 전달해야 하는가" 를 알 수 없어 round 2+ 분기 실행이 불안정.
2. **Verify Step 의 자원-타입 mismatch 검증 결손 (P1)** — `delegation-envelope.md` §6 Verify Step 의 4 가지 검사 중 `<DELEGATION_CHECK_AXIS>` 자원 타입 mismatch (예: agent 자산인데 `Skill 점검 축` 본문이 envelope 에 복사됨) 를 차단하는 구체 grep 이 없다. §7 Common Failures 가 "Verify Step 1 + 자원 타입 매핑 grep" 으로 막힌다고 주장하지만 Step 1 은 키워드 "점검 축" 만 검사하며, 자원 타입 매핑 grep 은 정의되지 않았다.
3. **Matrix §1 행 수 표기 불일치 (P3)** — `resource-type-matrix.md` §1 제목이 "12 분기 행 × 3 자원" 인데 실제 표는 14 행. 호출자가 matrix lookup 절차 (`lookup 시 행 수 확인`) 를 따를 때 행 수 표기를 기준으로 잘못된 종료 조건을 만들 수 있다.
4. **Phase 0 self-application fallback 경로 모호 (P2)** — SKILL.md Phase 0 (line 50) 의 env 미설정 fallback `../creator-gap-eval/` 가 어디 기준 상대 경로인지 명시되지 않음. Phase 2 workspace fallback (line 70) 은 "본 SKILL.md 디렉토리 기준" 으로 분명하지만, Phase 0 은 cwd 모호. self-application 검출은 reentry 한도의 기반이라 false negative 시 무한 재진입 위험.

전체 구조는 견고하므로 위 4 가지를 수정하면 PASS 로 회복 가능. 그 외에는 SKILL-GUIDE / GAP-FORMAT / CONSTITUTION 의 핵심 기대를 충족한다.

---

## 3. Asset Snapshot

```text
name: creator-gap-eval
description: Use when validating a newly drafted skill / agent / hook against GAP-FORMAT (creation-time GAP loop). Triggers on "GAP 평가", "creator-gap-eval", "자산 GAP 검증", "skill/agent/hook 작성 후 평가", "GAP-FORMAT 적용". Typically called by skill-creator / agent-creator / hook-creator §3. Direct invocation supported when validating an arbitrary asset against GAP-FORMAT. Do NOT use for ...
description_words: ~82 (한·영 혼합. 영문 단어 기준 ~60. trigger phrase 5개 + sibling do-NOT 5개)
body_words: ~1,300 (SKILL.md only). 3 파일 합계 ~3,600.
body_lines: 197 (SKILL.md). 1,055 (matrix). 1,086 (envelope). 총 4,002.
tools: omitted (frontmatter)
invocation_controls: user-invocable: true (사용자 직접 호출 명시 지원)
has_references: yes (2 개 — resource-type-matrix.md, delegation-envelope.md)
has_scripts_or_assets: no
has_effect_gate: partial (Output Contract "Effect gate" 단락이 mkdir + dispatch 직전 1회 확인 권고 명시. 단 GAP report write 자체는 분석 산출이라 자원 수정 gate 와 경계 명확)
has_output_contract: yes (Output Contract YAML — final_decision / report_path / finding_counts / round_count / reentry_count / notes)
```

---

## 4. Applicable Criteria

본 리포트가 직접 적용한 normative source:

- `CONSTITUTION.md` (특히 §3.1 Activation, §3.3 Effects Require Gates, §3.4 Output Is A Contract, §3.5 Capability Surface, §3.7 Progressive Disclosure, §3.10 Overlap Must Be Intentional)
- `SKILL-GUIDE.md` (§4 Frontmatter, §5 Description, §6 Body 설계, §7 Effects And Gates, §9 Output Contract, §11 Quantitative Heuristics, §13 Anti-Patterns)
- `GAP-FORMAT.md` (§4 판정 원칙, §5 원칙 강도, §7 Severity)
- `GAP-ANALYSIS-PROMPT.md` (Skill 점검 축, Evidence 작성 규칙, 리포트 구조)

본 envelope 가 부여한 **8 고유 검증축** (skill 일반 SKILL-GUIDE 외 추가):

1. 호출 인터페이스 (args 5개) 및 workspace_path 가 args 에 없음 명시
2. 반환 contract 의 호출자 §5 분기 충분성
3. path-based self-application 검출 + reentry_count ≤ 2 한도
4. 통합 workspace 정책 (CLAUDE_PLUGIN_ROOT + fallback)
5. matrix lookup 완전성 (14 분기 행 × 3 자원)
6. envelope 9 heading 복사 절차의 원자성 (4 차단 케이스)
7. 사용자 직접 호출 지원 (`user-invocable: true` + Phase 0 직전 args 확인)
8. 본 skill 의 effect gate (GAP report write 전 확인 + 자산 수정은 호출자 책임)

---

## 5. Checks

### 5.1 SKILL-GUIDE 일반 Checks (GAP-FORMAT §12.1)

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | description 에 trigger phrase 5개 + caller 명시 + sibling 5개 명확 |
| Description avoids workflow shortcut | pass | trigger / 호출자 / sibling 만 명시. 내부 phase 절차 나열 없음 |
| Skill is an automatic external/domain capability, not a user workflow | partial | 기본 자동 활성화 (creator chain) + `user-invocable: true` 로 사용자 직접 호출도 명시 지원. SKILL-GUIDE §4 가 "user-invocable 은 예외적 편의" 로 둠 — 본 skill 은 정당화됨 (사용자가 임의 자산 GAP 검증을 직접 시작할 수 있음) |
| Scope or near-miss is clear when needed | pass | When NOT to Use 에 6개 sibling 명시 |
| Capability procedure is actionable | pass | 10 Phase 모두 실행 가능한 절차. matrix lookup 행번호까지 명시 |
| Effect gate exists when mutation is possible | partial | Output Contract "Effect gate" 단락이 명시. 다만 본 skill 의 부수 효과 (GAP report write) 와 호출자 책임 (자원 수정) 의 경계가 명확. 본 skill 만의 mutation 은 GAP report 1 건 write — gate 가 1회 확인 권고로 약함 (P3, finding 미승격) |
| Output contract exists | pass | YAML 형식. final_decision 7 enum + report_path 절대 경로 + finding_counts + round_count + reentry_count + notes |
| Progressive disclosure is appropriate | pass | SKILL.md 197 lines + 2 references 분리. matrix + envelope 가 각각 단일 책임 |
| Reusable vs project memory is separated | pass | SKILL.md 가 ${CLAUDE_PLUGIN_ROOT} env + fallback 으로 plugin-portable |
| Behavior can be verified | partial | matrix 의 §3 Lookup 시뮬레이션 (Case A/B/C) 이 self-test 입력 역할. envelope §6 Verify Step 이 dispatch 전 self-check. 다만 round/reentry 한도와 final_decision 7-분기 시나리오의 verification 미명시 |
| Overlap is intentional | pass | When NOT to Use 가 `agent-skill-auditor`, `evaluation-loop-design/runner`, `resource-design`, `pr-review-toolkit/codex-reviewer`, 호출자 (3 creator) 와의 차이 명시 |

### 5.2 8 고유 검증축 Checks (envelope 부여)

| # | Check | Status | Notes |
|---|---|---|---|
| 1 | args 5개 정의 완전성 + workspace_path 부재 명시 | gap | Input Contract YAML 은 5 args 만 정의하나, Phase 2/Output Contract 가 `round_count` (6번째) 를 *사용*. Finding GAP-001 참조 |
| 2 | 반환 contract 의 호출자 §5 분기 충분성 | pass | Phase 6 표에 7 final_decision 별 호출자 권고 행동 명시. report_path 절대 경로로 즉시 Read 가능 |
| 3 | path-based self-application + reentry ≤ 2 | partial | Phase 0 가 path-based 명시 (line 55) + reentry > 2 시 NEEDS_REVIEW. Common Failures 에도 명시. 다만 fallback 경로 모호 (Finding GAP-004 참조) |
| 4 | 통합 workspace 정책 (env + fallback) | pass | Phase 2 가 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace` + fallback `../../creator-gap-eval-workspace` (본 SKILL.md 기준) 명시 + 호출자 위탁 제거 |
| 5 | matrix lookup 완전성 (14 행 × 3 자원) | partial | 14 행 모두 3 자원 컬럼 채워짐 (일부는 "(일반)" / "(없음)" 등 의도된 빈 마커). hook 의 `target_paths` (행 5) + `delegation_target_wording` (행 12) 모두 2 파일 일관. 다만 §1 제목이 "12 분기 행" 으로 표기 (Finding GAP-003 참조) |
| 6 | envelope 9 heading 복사 원자성 (4 차단) | gap | Verify Step 1 (누락) + Step 2 (placeholder) + Step 4 (workspace path) 는 자동 grep. Step 3 (cwd 외부 path) 는 manual review. **자원-타입 mismatch 차단 grep 부재** (Finding GAP-002 참조) |
| 7 | `user-invocable: true` + Phase 0 직전 args 확인 | pass | frontmatter line 4 명시 + Input Contract 마지막 단락 (line 40) "사용자 직접 호출 시 args 부재 → Phase 0 직전에 사용자에게 묻는다" |
| 8 | effect gate (GAP report write) + 자원 수정 경계 | pass | Output Contract "Effect gate" 단락 (line 173) 이 mkdir + dispatch/write 직전 1회 확인 권고. "단 GAP report 는 분석 산출이지 대상 자원 수정이 아님 — 자원 수정은 호출자 책임" 명시 |

---

## 6. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `SKILL-GUIDE.md §6 Body 설계` (Input Contract) | Input Contract args 5개로 정의했으나 Phase 2/Output 가 `round_count` 를 호출자 echo 로 사용 | `round_count` 를 Input Contract 의 6번째 args 로 명시 추가 (default 0) |
| GAP-002 | ASSET_GAP | P1 | `CONSTITUTION.md §3.9 Behavior Must Be Verifiable` | Envelope Verify Step 에 자원-타입 mismatch 차단 grep 부재 (예: agent 자원에 `Skill 점검 축` 본문 복사) | Verify Step 에 5번째 검사로 `delegation_check_axis vs envelope 내 5번 heading 본문 매핑` grep 추가 |
| GAP-003 | ASSET_GAP | P3 | `GAP-FORMAT.md §18 작성 톤` (정확성) | Matrix §1 제목 "12 분기 행" vs 실제 14 행 | §1 제목을 "14 분기 행 × 3 자원" 으로 수정 |
| GAP-004 | AMBIGUITY | P2 | `CONSTITUTION.md §3.3 Effects Require Gates` (self-application 검출의 안전 기반) | Phase 0 fallback 경로 `../creator-gap-eval/` 가 어디 기준 상대 경로인지 명시 부재 | "본 SKILL.md 디렉토리 기준" 또는 cwd 기준임을 명시 (Phase 2 와 동일 표현) |

상세:

### GAP-001: Input Contract args 수 불일치 — round_count 호출자 echo 미정의

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `SKILL-GUIDE.md §6 Body 설계` (Output Contract / Input Contract 의 actionability) + `CONSTITUTION.md §3.4 Output Is A Contract` (호출자 해석 가능성) |

**Expected**

본 envelope 의 검증축 #1 이 요구하는 args 5개 (`resource_type / draft_path / asset_name / delegation_mode / reentry_count`) 가 *전부* 호출자 (3 creator 또는 사용자) 가 추출 가능한 입력이며, 이 5개로 SKILL.md 의 모든 phase 가 정의 가능해야 한다. 5개 외 추가 args 가 필요하면 Input Contract 에 명시 추가하거나, 5개 안에서 도출 가능함을 본문에 명시한다.

**Actual**

Input Contract YAML (lines 30-38) 은 정확히 5개 args 만 정의:
```yaml
resource_type / draft_path / asset_name / delegation_mode / reentry_count
```

그러나 Phase 2 (line 75) 가 `args.round_count` 를 사용:
```text
round 2+ 시 suffix: args.round_count (호출자 echo 값) 가 2 이상이면 ...
```

Output Contract (line 166) 도 `round_count: <n>          # 호출자가 증가 (REVISE_ASSET 재호출 시)` 를 반환 필드로 *정의* 만 함 — 입력 명세 없음.

Common Failures (line 180) 도 "호출자가 `round_count` 전달로 결정" 으로 *전달 기대* 만 명시.

**Evidence**

- `SKILL.md` line 30-38: Input Contract YAML — `reentry_count` 까지만.
- `SKILL.md` line 75: `args.round_count` 사용.
- `SKILL.md` line 166: Output Contract `round_count: <n>` (입력→출력 echo 함의는 있으나 입력 명세 부재).
- `SKILL.md` line 180: "호출자가 `round_count` 전달로 결정".

**Impact**

(라우팅·산출 신뢰성) 호출자 (특히 3 creator 의 `REVISE_ASSET` 재호출 분기) 는 Input Contract 만 보고 args 를 구성하므로 `round_count` 를 전달하지 않을 수 있다. 그 결과:
- Phase 2 의 round 2+ suffix 분기가 실행되지 않아 round 2+ 의 GAP report 가 round 1 결과를 *덮어쓴다*.
- Phase 8 Re-run gate (3 라운드 초과 시 §0 책임 정의로 복귀 권고, 5 라운드 초과 시 NEEDS_REVIEW 반환) 의 round_count 카운팅이 호출자에게 위임되었음에도 본 skill 이 자체 카운트 못함 → 무한 round 위험.

`round_count` 와 `reentry_count` 는 둘 다 호출자 echo 카운터인데 `reentry_count` 만 Input Contract 에 있고 `round_count` 는 부재. 비대칭이 contract 의 일관성을 깨트림.

**Recommendation**

(asset 수정) Input Contract YAML 에 `round_count` 를 6번째 args 로 명시 추가:
```yaml
round_count: 0    # round 카운터. REVISE_ASSET 재호출 시 호출자가 +1. round 2+ 는 .round${n}.md suffix
```
+ 사용자 직접 호출 args 부재 케이스 (line 40) 에 `round_count` 기본값 0 명시 추가.

대안 (less preferred): SKILL.md 본문에서 `round_count` 사용 제거하고, `report_path` suffix 결정을 본 skill 자체 결정 (기존 파일 존재 여부 + 호출자 명시 의도) 로 옮김. 단 본 skill 의 input-driven 설계와 충돌.

---

### GAP-002: Envelope Verify Step — 자원-타입 mismatch 차단 grep 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §3.9 Behavior Must Be Verifiable` + `GAP-ANALYSIS-PROMPT.md §점검 축` (자원별 분기 정합성) |

**Expected**

본 envelope 의 검증축 #6 은 envelope 9 heading 복사 절차가 **4 가지** 차단을 모두 보장해야 한다고 요구:
(a) 누락 (missing 9 heading)
(b) 자원 타입 미스매치 (예: agent 자산인데 envelope 5번 heading 본문이 `Skill 점검 축`)
(c) placeholder 잔류
(d) wrong workspace path

각 차단은 manual review 가 아닌 결정론적 grep 으로 dispatch 직전 자동 차단되어야 한다.

**Actual**

`delegation-envelope.md` §6 Verify Step 의 4 가지 검사:
- Step 1: 9 heading 키워드 grep ✓ (axis a 충족)
- Step 2: placeholder 잔류 grep ✓ (axis c 충족)
- Step 3: cwd 외부 path 노출 — **manual review** (envelope template 자체가 외부 path 슬롯 1곳이라 보통 통과)
- Step 4: workspace path grep ✓ (axis d 충족)

axis (b) 자원-타입 mismatch 검증이 자동 검사로 *존재하지 않음*. §7 Common Failures (line 125-126) 가:
```text
**5번 heading 의 `점검 축` 가 잘못된 자원 타입으로 복사** — matrix `delegation_check_axis` lookup 누락. 예: agent 자산인데 `Skill 점검 축` 본문이 복사됨. Verify Step 1 + 자원 타입 매핑 grep 으로 차단.
```
"Verify Step 1 + 자원 타입 매핑 grep 으로 차단" 이라고 주장하나:
- Step 1 은 키워드 "점검 축" 만 검사 — `Skill / Agent / Hook 점검 축` 중 어느 것이든 일치하므로 mismatch 검출 불가.
- "자원 타입 매핑 grep" 은 Verify Step §6 의 4 step 중 *어디에도 정의되지 않음*.

**Evidence**

- `delegation-envelope.md` line 100-117: Verify Step 의 4 step 모두.
- `delegation-envelope.md` line 125-126: Common Failures 가 "Verify Step 1 + 자원 타입 매핑 grep" 으로 차단된다고 주장하나, 후자 grep 미정의.
- `delegation-envelope.md` line 74: 9 heading 복사 순서의 5번이 "`<DELEGATION_CHECK_AXIS>` 점검 축 ← matrix 분기 적용" 이지만 dispatch 후 실제 envelope 본문에 *올바른* 자원 축이 복사됐는지는 grep 가능한 검사가 없음.

**Impact**

(산출 신뢰성·라우팅) 자원-타입 mismatch 가 *조용히* dispatch 되면 subagent 가 wrong 점검 축 (예: agent 자산인데 Skill 점검 축) 으로 GAP 분석을 수행한다. 그 결과:
- agent 자산의 `tools` / `model` / `Agent Snapshot` (§11.2) / `Agent Checks` (§12.2 10 축) 가 누락된 GAP report.
- GAP 분석의 자원-타입 분기 자체가 무의미해짐 (matrix 가 7 행만 분기 채워도 envelope 가 axis 만 잘못 복사하면 subagent 는 잘못된 점검 축으로 평가).

본 skill 의 핵심 가치 (자원-타입 분기 흡수) 가 외부 envelope 의 mismatch 로 무력화될 수 있어 P1.

**Recommendation**

(asset 수정) `delegation-envelope.md` §6 Verify Step 에 5번째 검사 추가:
```bash
# 5. delegation_check_axis 와 envelope 5번 heading 본문 일치 여부 (자원-타입 mismatch 검출)
case "$delegation_check_axis" in
  Skill) expected_axis="Skill 점검 축" ;;
  Agent) expected_axis="Agent 점검 축" ;;
  Hook)  expected_axis="Hook 점검 축" ;;
esac
# envelope prompt 에 expected_axis 가 정확히 1회 등장하는지 (다른 axis 가 잘못 복사되면 0 또는 2회)
count=$(echo "$envelope_prompt" | grep -c "$expected_axis")
[ "$count" -eq 1 ] || echo "AXIS MISMATCH: expected '$expected_axis' (count=$count)"

# 추가: 다른 두 axis 가 envelope 본문에 없음을 확인
for other in "Skill" "Agent" "Hook"; do
  [ "$other" = "$delegation_check_axis" ] && continue
  echo "$envelope_prompt" | grep -q "$other 점검 축" && echo "FOREIGN AXIS LEAKED: $other"
done
```
+ §7 Common Failures 의 "Verify Step 1 + 자원 타입 매핑 grep" 문구를 "Verify Step 5" 로 갱신.

---

### GAP-003: Matrix §1 행 수 표기 불일치 (12 vs 14)

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `GAP-FORMAT.md §18 작성 톤` (정확성) + `SKILL-GUIDE.md §13 Anti-Patterns` (Obvious advice dump 의 반대 — 사실 부정확) |

**Expected**

Matrix §1 제목이 표기하는 행 수가 실제 표 행 수와 일치해야 한다. 호출자/유지보수자가 매트릭스 추가/변경 시 행 수 표기를 동기 갱신해야 함 (§5 Maintenance 가 이를 암시).

**Actual**

- `resource-type-matrix.md` line 7: `## 1. Matrix 표 (12 분기 행 × 3 자원)` ← 12 행
- `resource-type-matrix.md` line 11-24: 행 1 ~ 14 (14 행)
- `resource-type-matrix.md` line 26: `총 14 분기 행. 행 5-12 는 dispatch envelope 채움 ...` ← 14 행 (본문은 일치)

§1 제목 "12 분기 행" 만 outdated.

**Evidence**

- `resource-type-matrix.md` line 7: "## 1. Matrix 표 (12 분기 행 × 3 자원)"
- `resource-type-matrix.md` line 26: "총 14 분기 행."
- `bash 검증`: `grep -c "^| [0-9]" resource-type-matrix.md` → 14.

**Impact**

(유지보수성) 호출자가 matrix lookup 절차 (행 번호로 lookup) 를 따를 때 행 수 표기를 신뢰하면 행 13-14 (`guide_gap_candidates`, `extra_envelope_hint`) 를 건너뛸 수 있다. 본 envelope 의 검증축 #6 이 `extra_envelope_hint` (행 14) 누락을 P1 인지로 다루므로 (delegation-envelope.md §7 Common Failures 마지막) 무시할 수 없으나, 영향이 간접적이라 P3.

**Recommendation**

(asset 수정) `resource-type-matrix.md` line 7 을 `## 1. Matrix 표 (14 분기 행 × 3 자원)` 으로 수정.

---

### GAP-004: Phase 0 self-application fallback 경로 모호

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.3 Effects Require Gates` (self-application 검출이 reentry 한도의 안전 기반) + `CONSTITUTION.md §3.13 Freshness Requires Evidence` (경로 가정 명시) |

**Expected**

Phase 0 의 self-application 검출은 reentry_count ≤ 2 한도의 *유일한 trigger* 다 (검증축 #3 명시). 따라서 env 미설정 fallback 경로가 *어디 기준* (cwd / SKILL.md 디렉토리 / user home) 인지 명확해야 무한 재진입 방어가 결정론적이 된다.

Phase 2 workspace fallback 은 line 70 에 "본 SKILL.md 디렉토리 기준" 으로 명시되어 결정론적. Phase 0 도 동일 명시 필요.

**Actual**

`SKILL.md` Phase 0 (line 50):
```text
args.draft_path 중 하나라도 ${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/ (또는 env 미설정 시 fallback `../creator-gap-eval/`) 하위면 self-application
```

`../creator-gap-eval/` 가 어느 기준 상대 경로인지 명시 부재:
- cwd 기준이면 cwd 는 호출 시점마다 다름 (호출자가 어디서 호출하느냐에 따라 변함).
- SKILL.md 디렉토리 기준이면 `../creator-gap-eval/` 가 *자기 디렉토리 옆 디렉토리* 를 가리키므로 자기 자신 검출 실패.
- 실제 의도는 SKILL.md 디렉토리 자체 (`./` 또는 절대 경로 resolution) 일 것이나, 표현이 잘못됨.

**Evidence**

- `SKILL.md` line 50: `fallback '../creator-gap-eval/'` (단일 `../`)
- `SKILL.md` line 70 (Phase 2 비교): `# env 미설정 fallback: ../../creator-gap-eval-workspace  (본 SKILL.md 디렉토리 기준)` — 이중 `../../` + 기준 명시. *workspace* 가 skill 디렉토리의 형제 (sibling) 이므로 `../../<sibling>` 이 맞음.

→ 같은 논리로 Phase 0 fallback 도 SKILL.md 디렉토리 기준이면 *자기 디렉토리* 를 가리켜야 하므로 단순 `./` 또는 SKILL.md 파일 path 의 dirname 자체. `../creator-gap-eval/` 은 *부모 디렉토리에 같은 이름 디렉토리* 를 검사 — 이는 잘못된 위치.

**Impact**

(안전·라우팅) self-application 검출 false negative 시:
- 본 skill 이 자기 자신을 분석하는데 self-application 으로 인지 못함.
- reentry_count 증가 안 함 → 한도 ≤ 2 가 강제 안 됨 → 무한 재진입 위험.

P2 인 이유: env 가 설정된 환경 (정상 plugin 설치) 에서는 절대 경로 비교로 정확히 동작. fallback 경로는 env 미설정 + plugin 외부 설치 같은 edge case 에서만 trigger. 다만 검증축 #3 이 path-based 검출의 *유일성* 을 강조하므로 P3 가 아닌 P2.

**Recommendation**

(asset 수정) Phase 0 fallback 경로 명시:
```text
또는 env 미설정 시 fallback: 본 SKILL.md 파일의 dirname (`<dir of this SKILL.md>`)
```
또는:
```text
또는 env 미설정 시 fallback: cwd 가 plugin root 라고 가정하고 `./skills/creator-gap-eval/`
```
선택은 작성자 의도에 따름 (Phase 2 의 `../../creator-gap-eval-workspace` 와 같은 "SKILL.md 디렉토리 기준" 표현 일관성 권장).

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `user-invocable: true` 명시 | SKILL-GUIDE §4 가 "user-invocable 은 예외적 편의" 로 둠. 본 skill 은 자동 호출 (creator chain) 이 기본이며 직접 호출은 사용자가 임의 자산을 GAP 검증할 때만 사용 — 정당화됨 |
| description 길이 ~82 단어 (한·영 혼합) | SKILL-GUIDE §11 의 권장 15-60 단어 초과. 다만 trigger phrase 5개 + 호출자 명시 + sibling 6개 do-NOT 가 라우팅 신호로 *필요한* 정보이며 workflow shortcut 을 만들지 않음. 라우팅 정확도가 길이 비용 정당화 |
| 본문 197 lines + references 합계 4,002 lines | 메타 skill 로 10 phase + 자원-타입 분기 + envelope 절차를 흡수. references 가 progressive disclosure 로 잘 분리됨. SKILL-GUIDE §11 의 "긴 메타/교육형 스킬은 길 수 있다" 에 해당 |
| GAP report write 가 "분석 산출" 로 effect gate 1회 확인 권고 (강한 차단 아님) | 본 skill 의 mutation 은 단일 파일 write (workspace 하위) 로 scope 가 좁고, 대상 자원 수정 (실제 mutation) 은 호출자 책임. Output Contract 의 Effect gate 단락이 경계를 명확히 분리 |
| Matrix §3 의 Case A/B/C 시뮬레이션 (skill / agent / hook 각 1) | self-test 입력으로 verifiability 확보 (SKILL-GUIDE §10 verification 권장 충족) |

---

## 8. Suggested Changes

### Asset Changes

- [ ] **GAP-001** SKILL.md Input Contract YAML 에 `round_count: 0` 6번째 args 추가. line 40 의 사용자 직접 호출 args 부재 케이스에도 `round_count` 기본 0 명시.
- [ ] **GAP-002** delegation-envelope.md §6 Verify Step 에 5번째 검사 (자원-타입 axis mismatch grep) 추가. §7 Common Failures 의 "Verify Step 1 + 자원 타입 매핑 grep" 문구를 "Verify Step 5" 로 갱신.
- [ ] **GAP-003** resource-type-matrix.md line 7 의 "12 분기 행" 을 "14 분기 행" 으로 수정.
- [ ] **GAP-004** SKILL.md Phase 0 (line 50) 의 fallback 경로를 "본 SKILL.md 디렉토리 기준" 으로 명시 + 경로 표현 교정 (`./` 또는 SKILL.md dirname).

### Guide Changes

None. SKILL-GUIDE / CONSTITUTION / GAP-FORMAT 의 일반 원칙이 본 skill 의 모든 검증축에 적절히 적용 가능.

### Constitution Review

None. 본 finding 4건 모두 자산 수정 범위.

---

## 9. Follow-up Questions

1. Phase 0 fallback 경로의 의도된 동작은? (a) cwd 기준 (`./skills/creator-gap-eval/`), (b) SKILL.md dirname 기준 (자기 디렉토리 자체), (c) plugin root 추정 후 절대 경로 resolution — 셋 중 어느 것이어야 self-application 검출이 결정론적인지 작성자 의도 확인 필요. GAP-004 의 권고가 의도와 다를 수 있음.
2. `round_count` 를 호출자가 항상 전달해야 한다면 (GAP-001 권고대로 6번째 args 화), 사용자 직접 호출 시 사용자가 round 카운트를 인지하기 어려운데 — 사용자 직접 호출 모드에서는 round_count 가 항상 0 으로 고정되는 별도 표시가 필요한가? Phase 8 의 5 라운드 초과 NEEDS_REVIEW 가 사용자 직접 호출 분기에서도 발동되는가?
3. envelope §6 Verify Step 5 (GAP-002 권고) 가 추가되면 dispatch 비용이 증가 (5 step 실행). 호출자가 fast-path 선택 가능한가? `delegation_mode: inline` 은 Phase 4 로 분기 — Verify Step 자체가 우회되는데, inline 모드의 axis mismatch 검증은 어떻게 보장되는가? (현재 SKILL.md 본문 미명시)

---

## 10. Final Decision

**`REVISE_ASSET`**

근거:
- P1 finding 2건 (GAP-001 Input Contract args 불일치, GAP-002 Verify Step axis mismatch 검증 결손) 이 자산의 핵심 가치 (자원-타입 분기 흡수 + round/reentry 한도 강제) 를 *조용히* 무력화할 수 있음.
- P2 finding 1건 (GAP-004 Phase 0 fallback 경로 모호) 이 self-application 검출의 결정론성을 흔듬.
- P3 finding 1건 (GAP-003 행 수 표기) 은 단독으로는 미미하나 호출자 lookup 절차의 정확성을 떨어뜨림.

4건 모두 자산 본문 수정만으로 해결 가능 (Guide 보완 불필요, Constitution Review 불필요). 수정 후 재호출 (`round_count: 2` 또는 `.round2.md` suffix) 권장.

전체 구조 (10 phase + 자원-타입 분기 + envelope 분리 + user-invocable + 자체 workspace + path-based self-application + final_decision 7 enum 반환) 는 견고하므로 SPLIT_ASSET / DEPRECATE_ASSET 불필요. NEEDS_REVIEW 도 불필요 (모든 finding evidence 가 구체적이며 platform behavior 의존 없음).
