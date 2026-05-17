---
name: creator-gap-eval
description: Use when validating a newly drafted skill / agent / hook against GAP-FORMAT (creation-time GAP loop). Triggers on "GAP 평가", "creator-gap-eval", "자산 GAP 검증", "skill/agent/hook 작성 후 평가", "GAP-FORMAT 적용". Typically called by skill-creator / agent-creator / hook-creator §3. Direct invocation supported when validating an arbitrary asset against GAP-FORMAT. Do NOT use for 정적 rule 감사 (agent-skill-auditor), runtime task log 사이클 (evaluation-loop-design / evaluation-loop-runner), 자원 타입 결정 (resource-design), 코드/PR 리뷰 (pr-review-toolkit / codex-reviewer).
user-invocable: true
---

# Creator GAP Eval

3 creator (skill-creator / agent-creator / hook-creator) 의 §3 GAP 분석 + §4 Self-feedback refine 절차를 단일 skill 로 통합. `resource_type` args 로 자원-타입 분기 (GAP-FORMAT §11.X / §12.X Snapshot + Checks + SPLIT_ASSET 신호 + Re-run gate 명단). 자원별 specialization 은 `references/resource-type-matrix.md` 의 분기 표가 흡수.

## When to Use

- 3 creator 의 §3 진입 시 main session 이 `Skill` 도구로 자동 호출 (creator chain).
- 사용자가 임의 자산 (skill / agent / hook) 의 GAP-FORMAT 합치 검증을 요청할 때 직접 호출 (예: `/creator-gap-eval` 후 args 캡처).
- creator chain 의 `REVISE_ASSET` 반환 후 호출자가 자산 수정 → 재호출 (round_count 증가).

## When NOT to Use

- 정적 rule 감사 (P0/P1/P2 + rule ID + confidence) → `agent-skill-auditor`.
- runtime task log 사이클 / GAP report 표준화 → `evaluation-loop-design` (Step 4).
- task log + 자동 사이클 실행 → `evaluation-loop-runner` (Step 5).
- 자원 타입 결정 (command / skill / agent / hook / runtime / plugin) → `resource-design`.
- 코드 / PR 리뷰 → `pr-review-toolkit` / `codex-reviewer`.
- 자산 *본문 작성* — 호출자 (`skill-creator` / `agent-creator` / `hook-creator`) 책임.

## Input Contract

호출자 (3 creator 또는 사용자 직접) 가 전달할 args 6 개:

```yaml
resource_type: skill | agent | hook   # 분기 키 (matrix lookup) + 파일명 prefix
draft_path:                            # 분석 대상 절대 경로
  - <abs path to draft asset>          # skill: SKILL.md / agent: .md / hook: [script, registration]
asset_name: <kebab-case name>          # 파일명 결정. report = <resource_type>-<asset_name>.GAP.md
delegation_mode: delegate | inline     # Phase 3 vs Phase 4 (비용 트레이드오프)
reentry_count: 0                       # path-based self-application 카운터. 호출자는 0 으로 시작
                                       # 본 skill 이 자기 자신 분석 시 1 증가, > 2 시 NEEDS_REVIEW
round_count: 1                         # round 카운터 (1-based). 첫 호출 = 1. REVISE_ASSET
                                       # 재호출 시 호출자가 +1 해 다음 round 로 진행.
                                       # round_count >= 2 시 report_path 끝에 .round${round_count}.md
                                       # suffix (round 1 = base .GAP.md, round 2 = .round2.md, ...).
                                       # > 5 시 Phase 8 가 NEEDS_REVIEW 반환.
```

**사용자 직접 호출 시 args 부재** — Phase 0 직전에 사용자에게 묻는다. 우선 캡처: `resource_type` / `draft_path` / `asset_name`. 기본값: `delegation_mode = delegate` / `reentry_count = 0` / `round_count = 1`. 사용자 직접 호출 모드에서는 round_count 가 보통 1 로 고정 (사용자가 자산 수정 후 재호출 시에만 +1 권고 — 본 skill 은 자가 카운트 안 함).

**workspace_path 는 args 아님** — 본 skill 이 자체 결정 (Phase 2 참조). 호출자는 통합 workspace 위치를 알 필요 없음.

## Capability Procedure

10 phase. 자원-타입 분기는 모두 `references/resource-type-matrix.md` lookup.

### Phase 0: Self-application 검사

본 SKILL.md 파일의 dirname (= `creator-gap-eval/` 디렉토리의 절대 경로) 을 결정 — env 우선 (`${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/`), env 미설정 시 *본 SKILL.md 파일 자체의 dirname* (이 SKILL.md 가 디스크에서 어디에 있든 자기 자신을 가리킴). 절대 경로 비교가 안전 — 상대 경로 fallback 은 cwd 의존성으로 false negative 위험.

`args.draft_path` 중 하나라도 위 dirname 으로 시작 (prefix 매칭) 하면 *self-application*. `args.reentry_count` 확인:

- `reentry_count > 2` → `NEEDS_REVIEW` early exit (사용자 보고 + `notes: "self-application reentry limit exceeded (>2)"`).
- `reentry_count ≤ 2` → 진행. 본 호출 종료 시 다음 단계 호출자에게 `reentry_count + 1` 전달 권고 (반환 contract 에 echo).

**path-based 인 이유**: `resource_type: skill` 만으로는 자기 자신 검출 불가 (모든 skill 자산이 `resource_type: skill`). path prefix 가 유일한 검출 기준.

### Phase 1: Read Normative

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/GAP-FORMAT.md
Read ${CLAUDE_PLUGIN_ROOT}/references/GAP-ANALYSIS-PROMPT.md
```

적용 기준: §1 목적 + §6 GAP 유형 (ASSET_GAP / GUIDE_GAP / AMBIGUITY / INTENTIONAL_EXCEPTION / NO_GAP) + §7 Severity (P0–P3) + matrix 의 `snapshot_section` / `checks_section` (§11.X / §12.X 행).

### Phase 2: Workspace 준비 (자체 결정)

```bash
# env 우선 — plugin 정상 설치 시
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
  WORKSPACE="$CLAUDE_PLUGIN_ROOT/skills/creator-gap-eval-workspace"
else
  # env 미설정 fallback: 본 SKILL.md 파일의 dirname 기준 *sibling* 디렉토리.
  # creator-gap-eval/ 의 부모 (plugin 의 skills/) 아래 형제 위치.
  SKILL_DIR="$(dirname <abs path to THIS SKILL.md>)"   # = .../skills/creator-gap-eval
  WORKSPACE="$SKILL_DIR/../creator-gap-eval-workspace"  # = .../skills/creator-gap-eval-workspace
fi
mkdir -p "$WORKSPACE/gaps"
REPORT_PATH="$WORKSPACE/gaps/${resource_type}-${asset_name}.GAP.md"
```

**round 2+ 시 suffix**: `args.round_count` (1-based) 가 2 이상이면 `REPORT_PATH` 끝에 `.round${round_count}.md` 붙임 (기존 패턴 `skill-agent-creator.GAP.round2.md` 따름). round 1 = base `.GAP.md`. 호출자가 REVISE_ASSET 받고 round +1 해 재호출 시 자동으로 새 round 파일.

**round 1 덮어쓰기 위험**: 호출자가 실수로 같은 자산을 `round_count: 1` 로 *두 번* 호출 시 이전 round 1 GAP report 손실. REVISE_ASSET 분기에서는 *반드시* `round_count + 1` 전달 — 3 creator stub §4 가 이를 명시.

통합 workspace 채택 — 호출자에게 위탁하지 않음. 모든 GAP report 가 동일 디렉토리, 파일명 prefix (`skill-` / `agent-` / `hook-`) 가 자산 분리.

### Phase 3: GAP 분석 — 위임 (`delegation_mode: delegate`)

`references/delegation-envelope.md` 의 dispatch envelope template 사용. 절차 요약:

1. `${CLAUDE_PLUGIN_ROOT}/references/GAP-ANALYSIS-PROMPT.md` 를 한 번 더 Read.
2. envelope template 의 `<RESOLVED_REFS_DIR>` placeholder 를 절대 경로로 치환 (main session 책임 — env 우선, fallback `../../references/`).
3. matrix lookup 으로 `delegation_check_axis` / `delegation_target_wording` / `target_paths` / `snapshot_section` / `checks_section` 채움.
4. GAP-ANALYSIS-PROMPT 의 9 heading 본문 (heading 다음 줄 ~ 다음 heading 직전) 을 *순서·원문 그대로* 복사 → envelope 의 placeholder 자리. 복사 순서: §판정 원칙 → §원칙 강도 → §Finding 유형 → §Severity → §`<delegation_check_axis>` 점검 축 → §Evidence 작성 규칙 → §리포트 구조 → §최종 결정 → §완료 보고.
5. 복사 제외 (envelope 가 직접 지시 — 중복 회피): §목표 / §반드시 먼저 읽을 문서 / §분석 대상 / §수정 가능 범위 / §작업 방식.
6. 현재 환경의 subagent dispatch 도구로 호출. Claude Code: `Agent` 도구 + `subagent_type: "general-purpose"`.

위임 이유: main context 절약 + GAP-FORMAT "이전 컨텍스트를 전혀 모른다고 가정" 원칙 충족 (평가자 독립성).

### Phase 4: GAP 분석 — 직접 (`delegation_mode: inline`)

비용 절감 필요 시 main session 이 직접 GAP-FORMAT §9 의 10 섹션 작성 (Metadata → Executive Summary → Asset Snapshot → Applicable Criteria → Checks → Findings → Acceptable Deviations → Suggested Changes → Follow-up Questions → Final Decision). Asset Snapshot 은 matrix `snapshot_section` (§11.X), Checks 는 matrix `checks_section` (§12.X) 사용.

평가자 독립성이 약하므로 Phase 3 위임을 1회 이상 거치는 것이 권장. 호출자가 비용 트레이드오프 결정해 `delegation_mode` 전달.

**axis self-check (inline 모드 한정)** — Phase 3 의 envelope verify step 이 우회되므로 main session 이 직접 검사: 본 phase 에서 사용한 `snapshot_section` / `checks_section` / `guide_name` 값이 matrix 의 `args.resource_type` 컬럼과 *모두 일치* 하는지 1회 확인. mismatch 발견 시 본 phase 재실행.

### Phase 5: Self-Check (리포트 작성 전 GAP-FORMAT §17)

위임 결과 수신 또는 인라인 완료 직후 8개 self-check:

1. 헌법 → matrix `guide_name` (`SKILL-GUIDE` / `AGENT-GUIDE` / `HOOK-GUIDE`) → GAP-FORMAT 순서로 적용했나?
2. `guide_ref` 가 실제 존재하는 heading 인가?
3. finding 은 형식 차이가 아니라 실제 영향 (라우팅·안전·산출·재사용·유지보수) 인가?
4. heuristic 을 hard rule 처럼 적용하지 않았나?
5. platform behavior (자원별) 를 확인 없이 단정하지 않았나? (예: agent `tools` 생략 = 전체 권한 / hook exit code / matcher precedence)
6. 좋은 예외를 finding 으로 과잉 승격하지 않았나?
7. recommendation 이 asset 수정인지 guide 수정인지 명확한가?
8. Constitution Review 를 너무 쉽게 제안하지 않았나?

### Phase 6: Final Decision 분기

GAP report 의 §16 Final Decision 확인. 7 가지:

| Final Decision | 호출자가 받는 권고 행동 |
|---|---|
| `PASS` | 호출자 §5 (Output to caller) 로 진행 |
| `PASS_WITH_NOTES` | 낮은 severity finding 잔류 — 옵션 적용 후 §5 |
| `REVISE_ASSET` | P0/P1/P2 적용 후 본 skill 재호출 (round_count 증가) |
| `REVISE_GUIDE` | 본 skill 범위 밖 — 사용자에게 보고하고 §5 (자산은 통과) |
| `SPLIT_ASSET` | 호출자 §0 으로 복귀, 책임 분리 재설계. 자원별 신호는 matrix `split_asset_signals` 참조 |
| `DEPRECATE_ASSET` | 호출 경로·차별점 모두 약함 — 폐기 권고로 사용자 confirm |
| `NEEDS_REVIEW` | 근거 부족·추정 과다·재진입 한도 초과·라운드 한도 초과 — 사용자 입력 받기 |

본 skill 은 *분기 결정* 만 반환 (Output Contract). 실제 분기 실행은 호출자 책임.

### Phase 7: Finding 적용 순서

호출자가 `REVISE_ASSET` 받고 자산 수정 시 본 skill 의 권고 우선순위:

**각 finding 의 실제 적용은 호출자 §2 시점 B gate (변경 요약 → 사용자 명시 신호 → 수정) 를 거친다.** 아래 순위는 *어떤 finding 을 먼저 처리할지* 의 우선순위이며, gate 자체를 우회하지 않는다.

1. **P0 first** — 안전 / 데이터 / destructive. 최우선. 자원별 P0 예시는 matrix `severity_examples`.
2. **P1** — 라우팅 / 권한 / 부수 효과 / 산출 신뢰성. 다음 우선. 자원별 P1 예시는 matrix `severity_examples`.
3. **P2** — 품질·반복 비용. 사용자 위임 가능 (기본 적용 권장).
4. **P3** — 보고만 하고 적용은 선택.

각 finding 의 `Recommendation` 필드를 따른다. evidence 가 약하거나 `AMBIGUITY` 면 사용자 확인 후 진행.

### Phase 8: Re-run gate

호출자가 `REVISE_ASSET` 받고 수정 후 재호출. 호출자가 `args.round_count` 를 +1 해 전달:

- 3 라운드까지: 평소 흐름.
- 3 라운드 초과: 호출자 §0 *책임* 정의로 복귀 권고 — 책임 모호가 진짜 원인. 또는 자원 타입 재검토 (matrix `reroute_candidates` 참조).
- 5 라운드 초과: 본 skill 이 `NEEDS_REVIEW` 반환 (사용자 보고).

사용자 직접 호출 모드에서는 사용자가 명시적으로 round_count 를 증가시켜 재호출해야 본 한도가 발동. 기본값 0 에서 자가 증가 안 함.

### Phase 9: GUIDE_GAP 처리

자산이 좋은데 가이드가 잡지 못해 false positive 가 나오면 (`GUIDE_GAP`): 자산은 수정하지 *말고* 사용자에게 보고. 가이드 보완은 본 skill 범위 밖 (다음 v3 사이클의 입력). 자원별 GUIDE_GAP 후보는 matrix `guide_gap_candidates` (예: agent 의 AGENT-GUIDE §10 sibling / §6.2 inherit).

## Output Contract

호출자에게 yaml 반환:

```yaml
final_decision: PASS | PASS_WITH_NOTES | REVISE_ASSET | REVISE_GUIDE | SPLIT_ASSET | DEPRECATE_ASSET | NEEDS_REVIEW
report_path: <abs path to .GAP.md>   # 통합 workspace 의 절대 경로
                                      # = ${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/<resource_type>-<asset_name>.GAP.md
                                      # round 2+ 는 .round${n}.md suffix
finding_counts:
  p0: <n>
  p1: <n>
  p2: <n>
  p3: <n>
round_count: <n>          # 호출자가 증가 (REVISE_ASSET 재호출 시)
reentry_count: <n>        # path-based self-application 카운터 echo (보통 0)
notes: <optional 1-2 lines>   # PASS_WITH_NOTES / REVISE_GUIDE / NEEDS_REVIEW 사유
```

호출자는 `final_decision` 으로 §5 진행 또는 본 skill 재호출 (round_count 증가) 분기. `report_path` 는 절대 경로 — 호출자가 즉시 `Read` 가능.

**Effect gate** — GAP report 파일 write 는 부수 효과 (CONSTITUTION §3.3). Phase 2 의 mkdir + Phase 3/4 의 subagent dispatch 또는 inline write 직전에 경로 + 자산 요약 1회 확인 권고. 단 GAP report 는 *분석 산출* 이지 대상 자원 수정이 아님 — 자원 수정은 호출자 (creator 또는 사용자) 책임.

## Common Failures

- **args 누락** — 사용자 직접 호출 시 args 부재 → Phase 0 직전에 사용자에게 묻는다. creator chain 호출 시 호출자 §0-§2 가 미리 결정.
- **matrix lookup 실패** — unknown `resource_type` (skill / agent / hook 외) → `unknown_resource_type` 에러 + `NEEDS_REVIEW` 반환.
- **self-application 무한 재진입** — `args.draft_path` 가 `creator-gap-eval/` 하위인데 `args.reentry_count > 2` → Phase 0 가 `NEEDS_REVIEW` early exit. path-based 검출이라 `resource_type: skill` 만으로는 검출 불가 (review P0#2 결정).
- **`asset_name` 충돌** — 같은 `<resource_type>-<asset_name>.GAP.md` 가 이미 존재 시: round 1 은 *덮어쓰기* (이전 round 산출이지만 호출자가 명시적 재호출), round 2+ 는 `.round${n}.md` suffix. 호출자가 `round_count` 전달로 결정.
- **GAP report 작성 후 호출자가 final_decision 무시** — 본 skill 은 분기 *권고* 만 반환. 호출자 §5 분기가 final_decision 을 *반드시* 참조해야 함 (creator stub 본문 명시).
- **envelope 9 heading 복사 누락** — `references/delegation-envelope.md` 의 verify step 으로 사전 차단.
- **통합 workspace 경로 결정 실패** — `${CLAUDE_PLUGIN_ROOT}` env 미설정 + fallback 도 실패 시 사용자 보고 + 종료. 임의 경로 임시 사용 금지.

## References

3 파일. 모두 *creator-gap-eval 고유* content — GUIDE / GAP-FORMAT / GAP-ANALYSIS-PROMPT 본문 재생산 없음.

- `references/resource-type-matrix.md` — `resource_type` ∈ {skill, agent, hook} 별 11 분기 행 표 + lookup 절차.
- `references/delegation-envelope.md` — Phase 3 dispatch envelope template + `<RESOLVED_REFS_DIR>` 치환 책임 + 9 heading 복사 절차.

Normative source 직접 참조 (`${CLAUDE_PLUGIN_ROOT}/references/`):

- `GAP-FORMAT.md` — §1/§6/§7 적용 기준 + §11.X Snapshot + §12.X Checks + §17 Self-Check + §16 Final Decision.
- `GAP-ANALYSIS-PROMPT.md` — Phase 3 envelope 의 9 heading 본문 source.
- `CONSTITUTION.md` §3.3 Effects Require Gates + §3.7 Progressive Disclosure + §3.7.1 Outcomes And Constraints Before Routes.
- `SKILL-GUIDE.md` / `AGENT-GUIDE.md` / `HOOK-GUIDE.md` — matrix `guide_name` 행에 따라 자원-타입별 직접 참조.
