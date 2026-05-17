# Harness Installation — Step 4b Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 3 creator skill (`skill-creator` / `agent-creator` / `hook-creator`) 의 §3 GAP 분석 절 + §4 Self-feedback refine 절 — 실측 약 125 lines × 3 자원 = **~375 lines 중 ~70% 가 본질 중복**. 이를 신규 skill `creator-gap-eval` 로 추출. 3 creator 의 §3-§4 는 *args 전달 + 호출* 한 묶음 stub 으로 축약.

본 추출의 *본질 가치는 line 절감이 아니라 진실 source 1 곳* — extraction 후 creator-gap-eval 본문 (SKILL.md + 2 references) 이 ~410-590 lines 가 새로 추가되므로 *순 line count 는 증가 가능*. 그러나 (a) GAP loop 절차가 1 곳에서만 유지·진화하고, (b) 1 자원 작성 시 main context 에 로드되는 양은 *stub + creator-gap-eval lazy-load* 로 작아진다 (CONSTITUTION §3.7 Progressive Disclosure).

**Architecture:** `creator-gap-eval` 은 자원 타입 분기 (`skill | agent | hook`) 를 args 로 받아 §3 (Workspace / 위임 / 직접 / Self-Check) + §4 (Final Decision 분기 / Finding 적용 / Re-run gate / GUIDE_GAP) 를 *단일 절차* 로 통합. 자원별 specialization (GAP-FORMAT §11.{1/2/3} Snapshot + §12.{1/2/3} Checks + SPLIT_ASSET 신호 + Re-run gate 자원 타입 명단) 은 *분기 표* references 1 파일로 관리.

**Workspace 정책 — plugin 단위 통합** (호출자에게 위탁하지 않음): 모든 GAP report 는 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/<resource_type>-<asset_name>.GAP.md` 단일 디렉토리에 누적. 호출자는 `workspace_path` args 를 *전달하지 않음* — `creator-gap-eval` 이 자체 결정. 이전 3 creator 의 분산 workspace (`agent-creator-workspace/gaps/`, `hook-creator-workspace/gaps/`) 는 `git mv` 로 통합 (Task 6 추가). 통합 효과: (a) plugin-wide GAP history 한 곳, (b) 호출자 책임 감소, (c) bootstrap 예외 처리 불필요 — bootstrap 도 동일 경로 (`creator-gap-eval-workspace/gaps/skill-creator-gap-eval.GAP.md`).

Creator 의 §3 진입 시 main session 이 `Skill` tool 로 `creator-gap-eval` 호출 → 결과 (Final Decision + `report_path` 절대 경로 + finding 목록) 를 받아 §5 (Output to caller) 로 진행. **사용자 직접 호출도 허용** (`user-invocable: true`) — 임의 자산을 args 로 지정해 검증 가능 (예: `/creator-gap-eval` 후 args 사용자 캡처). **자기 자신 호출 (self-application) 도 path-based 검출로 허용하되 재진입 최대 2회 로 제한** (3 회째는 NEEDS_REVIEW 반환).

**Tech Stack:** skill-creator (메타 스킬, creator-gap-eval 작성용), Edit/Write tools, agent-skill-auditor (정적 감사 — 추출 결과의 회귀 검증)

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §7 Step 7 (Creator skill 정리) 의 *prerequisite refinement* — 본 Step 은 spec §7 에 명시되지 않았던 *추출 작업* 으로, Step 7 의 "spec 인터페이스 호환 확인" 이 의미를 가지려면 먼저 creator 본문이 정리되어야 함. spec §7 도 본 plan 의 Task 5 에서 동기 갱신.

**전체 migration 중 위치:** Step 4b of 7+. Step 4 (`evaluation-loop-design`) 완료 후 즉시 진행 권장 — Step 5 (`evaluation-loop-runner`) 가 creator chain 패턴 (호출 시 `creator-gap-eval` 가 별도 skill 인지) 을 인식한 채 작성되어야 함. Step 4 와 Step 4b 의 *layer 차이*: Step 4 = runtime evaluation (task log + 사이클), Step 4b = creation-time evaluation (GAP-FORMAT 적용 절차). 이름 충돌 없음.

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md` | Create (skill-creator §2) | §3-§4 통합 절차 + 자원-타입 args 분기 (~250-350 lines) |
| `plugins/bobs-plugin/skills/creator-gap-eval/references/resource-type-matrix.md` | Create (main session, §2 직후) | resource_type ∈ {skill, agent, hook} 별 분기 표 (GAP-FORMAT §11.X / §12.X / guide 이름 / SPLIT_ASSET 신호 / Re-run gate 명단 / Self-Check 1번 guide ref) |
| `plugins/bobs-plugin/skills/creator-gap-eval/references/delegation-envelope.md` | Create (main session, §2 직후) | §3b 위임 envelope (subagent dispatch payload + prompt 본문 구성 절차) — 현재 `GAP-ANALYSIS-PROMPT.md` 호출 패턴을 한 곳에 집약 |
| `plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/skill-creator-gap-eval.GAP.md` | Create (skill-creator §3a) | Bootstrap GAP report — 모든 GAP report 가 동일 패턴 `<resource_type>-<asset_name>.GAP.md` 으로 본 단일 workspace 에 누적. 호출자는 workspace 결정 안 함 |
| `plugins/bobs-plugin/skills/agent-creator-workspace/gaps/` | git mv → 통합 workspace | 기존 GAP report (`skill-agent-creator.GAP.md`, `skill-agent-creator.GAP.round2.md`) 를 `creator-gap-eval-workspace/gaps/` 로 이동. 빈 디렉토리 삭제 |
| `plugins/bobs-plugin/skills/hook-creator-workspace/gaps/` | git mv → 통합 workspace | 기존 GAP report (`skill-hook-creator.GAP.md`) 를 `creator-gap-eval-workspace/gaps/` 로 이동. 빈 디렉토리 삭제 |
| `plugins/bobs-plugin/skills/skill-creator/SKILL.md` | Edit (§3-§4 → stub) | ~125 lines → ~15 lines stub + args 정의 |
| `plugins/bobs-plugin/skills/agent-creator/SKILL.md` | Edit (§3-§4 → stub) | ~140 lines → ~15 lines stub + args 정의 (자원별 specialization 은 `resource-type-matrix.md` 가 흡수) |
| `plugins/bobs-plugin/skills/hook-creator/SKILL.md` | Edit (§3-§4 → stub) | ~125 lines → ~15 lines stub + args 정의 |
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` | Edit (§7 Step 7 + §8 Asset Disposition) | Step 7 본문에 "creator-gap-eval 추출 (Step 4b) prerequisite" 한 줄 + §8 Asset Disposition 표에 `creator-gap-eval` 행 추가 (신규, 유지) |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (§5.1 채움) | "creator skills" 행에 `creator-gap-eval` 호출 패턴 언급 — Step 5 의 workflow doc 마무리 작업 prerequisite |
| `plugins/bobs-plugin/.claude-plugin/plugin.json` | Edit (description) | creator-gap-eval 추가 |
| `.claude-plugin/marketplace.json` | Edit (description) | 동일 |
| `README.md` | Edit (file tree + skill 표 + namespace) | creator-gap-eval 추가 |
| `plugins/bobs-plugin/agents/agent-skill-auditor.md` | Edit (description When NOT 절) | creator-gap-eval 라우팅 명시 (creation-time GAP 적용은 본 agent 가 아님 — 정적 rule 감사만) |

**유지** (변경 없음):
- `skills/skill-creator/references/trigger-eval.md` — skill 전용 specialized, 추출 불가 (diff 결과 확인됨)
- `skills/skill-creator/references/red-green-refactor.md` — skill 전용 specialized
- `skills/agent-creator/references/trigger-eval.md` — agent 전용 specialized
- `skills/agent-creator/references/red-green-refactor.md` — agent 전용 specialized
- `skills/agent-creator/references/pressure-scenarios.md` — agent 고유
- `skills/hook-creator/references/matcher-pressure.md` — hook 고유
- 3 creator 의 §0 (Capture intent) / §1 (Choose scope) / §2 (Draft) / §5 (Output to caller) / §6 (Terminology and tone pass) / §Mini example / §When the loop stalls / §Limits — 자원-타입별 분기가 본질, 통합 효용 < 통합 비용

**deprecation 없음**: 본 Step 은 *추출 + stub 교체* 이지 자산 삭제가 아님. 3 creator 는 그대로 존재.

---

## Note on bootstrap (chicken-and-egg)

`creator-gap-eval` 자체는 skill 이므로 *그 자신을 만드는 데 skill-creator 의 §3-§4 가 필요함*. 그러나 §3-§4 가 *추출 대상* — 순환 의존?

해결:

1. **Task 2 시점 — 현재 skill-creator 의 §3-§4 그대로 사용**해 `creator-gap-eval` 작성. 즉 *추출 전 마지막 사용*.
2. **Task 3 시점 — 3 creator §3-§4 stub 교체**. `creator-gap-eval` 자체는 stub 안 함 (자기 자신을 호출 시 Phase 0 self-application 검출 동작).
3. **Task 4 시점 — 3 creator self-eval** (새 `creator-gap-eval` 호출). 새 chain 작동 확인.

`creator-gap-eval` 자체의 GAP 검증 (skill-creator §3 단계) 은 *이전 패턴* (§3b 위임 = generic subagent dispatch) 사용. 추출 후에도 `creator-gap-eval` 의 본문 안에 동일 절차가 통합되어 있으므로 *추출이 곧 self-application 패턴 정의* — chicken-and-egg 아닌 *재진입* (Step 4 plan 의 self-application 노트와 동일 패턴).

**Self-application 안전장치** (추가 의견 — 무한 루프 방지 정책):
- `creator-gap-eval` 의 Phase 0 (Capability Procedure 첫 단계) 가 `args.draft_path` 가 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/` 하위인지 *path-based* 검출.
- 검출되면 `args.reentry_count` 확인. **최대 2회** 까지 허용 (즉 첫 호출 + 재진입 1 + 재진입 2 = 3 차례). 3 차례 초과 시 `NEEDS_REVIEW` early exit + 사용자 보고.
- `resource_type` enum (skill/agent/hook) 으로는 자기 자신 검출 불가 (`creator-gap-eval` 도 `resource_type: skill`) — *path* 가 유일한 안전한 검출 기준 (review P0#2 결정).

---

## Task 1: 추출 source 정밀 분석 — Phase별 자원-타입 분기 매핑

**Files:**
- (편집 없음 — 분석 + 결정 문서화)

`creator-gap-eval/SKILL.md` 의 본문 골격과 `resource-type-matrix.md` 의 분기 표를 *작성하기 전* 에 어느 라인이 *공통* 이고 어느 라인이 *자원별* 인지 정밀 매핑한다. 본 Task 는 commit 없음 — 결과는 Task 2 의 brief block + matrix 표 입력으로 사용.

- [ ] **Step 1: 3 creator §3-§4 의 *공통* 본문 식별**

```bash
echo "--- §3 본문 라인 추출 ---"
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c ==="
  sed -n '/^## 3\. GAP 분석/,/^## 5\./p' "plugins/bobs-plugin/skills/$c/SKILL.md" | wc -l
done

echo "--- §4 본문 라인 추출 ---"
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c ==="
  sed -n '/^## 4\. Self-feedback refine/,/^## 5\./p' "plugins/bobs-plugin/skills/$c/SKILL.md" | wc -l
done
```

Expected:
- §3 본문 ≈ 80 lines × 3 = 240 lines (skill 73 / agent 91 / hook 77)
- §4 본문 ≈ 45 lines × 3 = 135 lines

총 ≈ 375 lines × 70% 공통 = ~260 lines 추출, ~115 lines 자원별 분기.

- [ ] **Step 2: 자원별 분기 항목 카탈로그 (resource-type-matrix 후보)**

| 분기 항목 | skill | agent | hook | matrix 행 키 |
|---|---|---|---|---|
| GAP-FORMAT Snapshot 섹션 | §11.1 | §11.2 | §11.3 | `snapshot_section` |
| GAP-FORMAT Checks 섹션 | §12.1 | §12.2 | §12.3 | `checks_section` |
| Self-Check #1 guide 이름 | `SKILL-GUIDE` | `AGENT-GUIDE` | `HOOK-GUIDE` | `guide_name` |
| 위임 prompt §"점검 축" | Skill | Agent | Hook | `delegation_check_axis` |
| 분석 대상 path 형태 | 1 파일 (`SKILL.md`) | 1 파일 (`agent .md`) | 2 파일 (script + registration) | `target_paths` |
| Workspace path 명명 | `skill-<name>` | `agent-<path-safe-name>` | `hook-<name>` | `workspace_name_pattern` |
| SPLIT_ASSET 자원별 신호 | (없음) | persona drift / 분석+수정+commit | Mixed responsibility (formatter/blocker/logger) | `split_asset_signals` |
| Finding 적용 자원별 P0/P1/P2 예시 | (없음) | advisory + Write, 자동 commit/push | destructive Bash, 숨은 외부 송신 | `severity_examples` |
| Re-run gate 자원 타입 변경 명단 | command/agent/hook/runtime/CLAUDE.md | command/skill/hook/runtime/CLAUDE.md | skill/agent/CLAUDE.md | `reroute_candidates` |
| 위임 prompt "분석 대상 1건" 어법 | "새 스킬 1개" | "새 에이전트 1개" | "새 훅 1건 (script + registration 한 쌍)" | `delegation_target_wording` |
| GUIDE_GAP 자원별 후보 | (없음) | AGENT-GUIDE §10 sibling, §6.2 inherit | (없음) | `guide_gap_candidates` |

Step 2 산출: 위 표 *최종본* — Task 2 Step 2 의 `resource-type-matrix.md` 입력.

- [ ] **Step 3: 공통 본문 골격 (resource_type 무관 부분) 결정**

| Phase | 절차 |
|---|---|
| §3 진입 | GAP-FORMAT / GAP-ANALYSIS-PROMPT 읽기 + §1/§6/§7 적용 기준 인용 |
| §3a Workspace 준비 | `mkdir -p $WORKSPACE/gaps` + 리포트 path 결정 (matrix `workspace_name_pattern` 사용) |
| §3b 위임 | subagent dispatch envelope + `<RESOLVED_REFS_DIR>` 치환 + GAP-ANALYSIS-PROMPT 9 heading verbatim 복사 + matrix `delegation_check_axis` / `delegation_target_wording` 분기 |
| §3c 직접 | GAP-FORMAT §9 10개 섹션 + matrix `snapshot_section` / `checks_section` 분기 |
| §3d Self-Check | 8개 항목 + matrix `guide_name` 분기 (1번만) |
| §4a Final Decision 표 | 7행 + matrix `split_asset_signals` 분기 (SPLIT_ASSET 행만) |
| §4b Finding 적용 순서 | 1-4 + matrix `severity_examples` 분기 (P0/P1/P2 예시만) |
| §4c Re-run gate | 라운드 카운트 3/5 + matrix `reroute_candidates` 분기 |
| §4d GUIDE_GAP | 본문 + matrix `guide_gap_candidates` 분기 (있는 자원만) |

Step 3 산출: `creator-gap-eval/SKILL.md` 의 *Capability Procedure* 골격 — Task 2 Step 1 의 skill-creator brief 입력.

- [ ] **Step 4: 호출 인터페이스 (args) 정의**

main session 이 `Skill` tool 로 호출 시 전달할 args:

```yaml
resource_type: skill | agent | hook   # 분기 키 (matrix lookup) + 파일명 prefix
draft_path:                            # 분석 대상
  - <abs path to draft asset>          # skill: SKILL.md / agent: .md / hook: script + registration
asset_name: <kebab-case name>          # 파일명 결정 (creator-gap-eval-workspace/gaps/<resource_type>-<asset_name>.GAP.md)
delegation_mode: delegate | inline     # §3b vs §3c 선택 (호출자가 비용 트레이드오프 결정)
reentry_count: 0                       # path-based self-application 카운터. 호출자는 0 으로 시작.
                                       # 본 skill 이 자기 자신 분석 시 1 씩 증가, 2 초과 시 NEEDS_REVIEW 반환
                                       # (추가 의견 — 무한 루프 방지 정책: 최대 재진입 2회)
```

호출자 (3 creator + 사용자 직접 호출) 의 진입 시점에 위 args 가 모두 결정되어 있어야 함 — Task 3 Step 2 의 stub 본문이 args 추출 절차를 명시. **사용자 직접 호출 시** args 부족하면 본 skill 의 §0 (Capture intent) 가 사용자에게 묻는다 (예: `/creator-gap-eval` 후 args 부재면 draft_path / asset_name 캡처).

**Workspace 정책 — 자체 결정 (호출자 위탁 없음, 후속 review 반영)**:

```text
workspace_path = ${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace
report_path    = ${workspace_path}/gaps/${resource_type}-${asset_name}.GAP.md
```

- 모든 호출 (3 creator chain + 사용자 직접 + bootstrap) 이 동일 디렉토리 — *plugin 단위 통합 GAP workspace*
- 호출자는 `workspace_path` args 를 *받지 않음* → 호출 인터페이스 단순화 (args 5개: `resource_type` / `draft_path` / `asset_name` / `delegation_mode` / `reentry_count`)
- 파일명 prefix (`skill-` / `agent-` / `hook-`) 가 자산 분리 — `ls .../gaps/skill-*` 로 자원-타입별 history 즉시 확인
- bootstrap 도 동일 패턴: `gaps/skill-creator-gap-eval.GAP.md` (creator-gap-eval 자체는 skill 자산)
- 이전 3 creator 의 분산 workspace (`agent-creator-workspace/gaps/`, `hook-creator-workspace/gaps/`) 는 Task 6 의 `git mv` 로 통합 — history 보존

- [ ] **Step 5: 반환 contract 정의**

`creator-gap-eval` 종료 시 호출자에게 반환:

```yaml
final_decision: PASS | PASS_WITH_NOTES | REVISE_ASSET | REVISE_GUIDE | SPLIT_ASSET | DEPRECATE_ASSET | NEEDS_REVIEW
report_path: <abs path to .GAP.md>   # 통합 workspace 의 절대 경로
                                      # = ${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/<resource_type>-<asset_name>.GAP.md
finding_counts:
  p0: <n>
  p1: <n>
  p2: <n>
  p3: <n>
round_count: <n>          # 0 if 첫 호출 (재호출 시 호출자가 증가)
reentry_count: <n>        # path-based self-application 카운터 echo (보통 0)
notes: <optional 1-2 lines for PASS_WITH_NOTES / REVISE_GUIDE / GUIDE_GAP>
```

호출자는 `final_decision` 으로 §5 (Output to caller) 또는 §3 재호출 (round_count 증가) 분기. `report_path` 는 절대 경로로 명시 — 호출자가 통합 workspace 의 위치를 알 필요 없이 즉시 Read 가능. (workspace_path 필드는 *제거됨* — 호출자가 결정·전달하지 않으므로 echo 도 불필요.)

---

## Task 2: skill-creator 로 creator-gap-eval 작성

**Files:**
- Create (skill-creator §2): `plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/creator-gap-eval/references/resource-type-matrix.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/creator-gap-eval/references/delegation-envelope.md`
- Create (skill-creator §3a): `plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/skill-creator-gap-eval.GAP.md`

- [ ] **Step 1: skill-creator 호출 (intent 사전 제공)**

호출: `/skill-creator`

첫 메시지 (intent brief):

```
name: creator-gap-eval
scope: plugin (plugins/bobs-plugin/skills/creator-gap-eval/)
책임: 3 creator (skill-creator / agent-creator / hook-creator) 의 §3 GAP 분석 + §4
  Self-feedback refine 절차를 단일 skill 로 통합. resource_type args 로 자원-타입
  분기 (GAP-FORMAT §11.X / §12.X snapshot + checks + guide 이름 + SPLIT_ASSET 신호).
호출 패턴:
  (a) 3 creator 의 §3 진입 시 main session 이 Skill tool 로 호출 (자동 chain)
  (b) 사용자가 임의 자산 검증 요청 시 직접 호출 (예: /creator-gap-eval + args 캡처)
  → Final Decision + finding 목록 반환 → 호출자 §5 진행 또는 사용자 보고
트리거 (description): "GAP 평가", "creator-gap-eval", "자산 GAP 검증",
  "skill/agent/hook 작성 후 평가", "GAP-FORMAT 적용"
user-invocable: true  # 사용자 직접 호출 허용 (추가 의견 반영). 단 trigger phrase 는
  creator chain 내부 호출이 압도적이라 일반 자동 활성화 빈도는 낮음. description
  본문에 "Typically called by skill-creator / agent-creator / hook-creator §3.
  Direct invocation supported when validating an arbitrary asset against GAP-FORMAT."
negative: 정적 rule 감사 (P0/P1/P2 + rule ID — agent-skill-auditor),
  runtime task log 사이클 (evaluation-loop-design / evaluation-loop-runner),
  자원 타입 결정 (resource-design), 코드/PR 리뷰
spec format: 호출자에게 yaml 반환 (final_decision / report_path / finding_counts /
  round_count / reentry_count) — 본 skill 은 spec 산출 아닌 *호출자 chain 의
  step skill*. report_path 는 절대 경로
effect gate: 파일 작성 *있음* — GAP report .md (통합 workspace
  ${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/) write 직전 경로·
  요약 1회 확인 (CONSTITUTION §3.3). 단 GAP report 는 *분석 산출* 이지
  대상 자원 수정이 아님 — 자원 수정은 호출자 (creator 또는 사용자) 책임
self-application 정책 (추가 의견 — 무한 루프 방지):
  - path-based 검출 — args.draft_path 가 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/`
    하위인지 확인
  - 허용하되 재진입 카운터 (args.reentry_count) 사용
  - reentry_count > 2 시 NEEDS_REVIEW 반환 + 사용자 보고 (early exit)
  - 정상 호출 (호출자 = 다른 자산) 은 reentry_count = 0 으로 시작, 카운터 미증가
references 2개 (main session 이 §2 SKILL.md draft 직후 mini-gate 거쳐 직접 작성):
  - references/resource-type-matrix.md (~80-120 lines, 분기 표)
  - references/delegation-envelope.md (~80-120 lines, §3b dispatch envelope + GAP-
    ANALYSIS-PROMPT 9 heading 복사 절차)
참고 자산 (변경 없음):
  - ${CLAUDE_PLUGIN_ROOT}/references/GAP-FORMAT.md (normative source)
  - ${CLAUDE_PLUGIN_ROOT}/references/GAP-ANALYSIS-PROMPT.md (위임 prompt 본문)
  - ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md §3 (effect gate 등)
호출 인터페이스 args: resource_type / draft_path / asset_name / delegation_mode /
  reentry_count — workspace_path 는 *없음* (creator-gap-eval 자체 결정, 위 Task 1
  Step 4 참고). 호출자가 통합 workspace 위치를 알 필요 없음
workspace 정책: ${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/ —
  plugin 단위 통합. 파일명 = <resource_type>-<asset_name>.GAP.md
반환 contract: final_decision / report_path (절대 경로) / finding_counts /
  round_count / reentry_count / notes (위 Task 1 Step 5 참고)
```

skill-creator §0 → §1 → §2 자체 흐름. §2 시점 A gate 에서 SKILL.md 경로 + frontmatter + 본문 골격 + workspace 경로 제시 후 사용자 명시 승인.

예상 SKILL.md 구조:

- Frontmatter: `name: creator-gap-eval`, description (creator chain 1차 호출자 + 사용자 직접 호출 허용 명시), `user-invocable: true` (추가 의견 반영 — 사용자 직접 호출 허용)
- `# Creator GAP Eval`
- `## When to Use` — (a) 3 creator §3 진입 시 자동 chain (b) 사용자가 임의 자산 검증 요청 시 직접 호출
- `## When NOT to Use` — 정적 감사 / runtime 사이클 / 자원 타입 결정 등 (위 negative trigger)
- `## Input Contract` — args 5개 (Task 1 Step 4 — workspace_path 제외)
  - 사용자 직접 호출 시 args 부재면 §0 (Capture intent) 가 사용자에게 물음
- `## Capability Procedure` (Task 1 Step 3 의 9 phase + Phase 0)
  - `### Phase 0: Self-application 검사` — `args.draft_path` 가 본 skill 디렉토리 하위면 reentry_count 검사 (> 2 시 NEEDS_REVIEW early exit)
  - `### Phase 1: Read Normative` — GAP-FORMAT / GAP-ANALYSIS-PROMPT
  - `### Phase 2: Workspace 준비 (자체 결정)` (구 §3a) — `workspace_path = ${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace` 고정. `mkdir -p $workspace_path/gaps`. `report_path = $workspace_path/gaps/${resource_type}-${asset_name}.GAP.md`
  - `### Phase 3: GAP 분석 — 위임` (구 §3b, matrix 분기)
  - `### Phase 4: GAP 분석 — 직접` (구 §3c, matrix 분기)
  - `### Phase 5: Self-Check` (구 §3d, matrix 분기 1번)
  - `### Phase 6: Final Decision 분기` (구 §4a, matrix 분기)
  - `### Phase 7: Finding 적용 순서` (구 §4b, matrix 분기)
  - `### Phase 8: Re-run gate` (구 §4c, matrix 분기)
  - `### Phase 9: GUIDE_GAP 처리` (구 §4d, matrix 분기)
- `## Output Contract` — Task 1 Step 5 의 yaml (report_path 절대 경로)
- `## Common Failures`
  - args 누락 (사용자 직접 호출 시 §0 가 물음)
  - matrix lookup 실패 (unknown resource_type)
  - **self-application 무한 재진입** (path-based — `args.draft_path` 가 `creator-gap-eval/` 하위인데 `reentry_count > 2` → NEEDS_REVIEW 거부)
  - `asset_name` 중복 — 같은 `<resource_type>-<asset_name>.GAP.md` 가 이미 존재 시 *덮어쓰기* (round 갱신) vs *round suffix* (`.round2.md`) 결정. 기존 패턴 (`skill-agent-creator.GAP.round2.md`) 을 따라 round 2+ 는 suffix 사용
  - GAP report 작성 후 호출자가 final_decision 무시
- `## References`

- [ ] **Step 2: references 작성 (skill-creator §2 SKILL.md draft 완료 직후)**

skill-creator 의 시점 A gate 는 SKILL.md 1 경로만 다루므로 references 는 mini-gate 거쳐 별도 write (Step 4 plan precedent 동일).

**(0) Mini-gate** — 사용자 승인 (or 묻지 말고 진행 모드 시 응답에 기록):

| 항목 | 내용 |
|---|---|
| 작성 경로 | 2 절대 경로 (`resource-type-matrix.md`, `delegation-envelope.md`) |
| Source 자료 | 현재 3 creator §3-§4 본문 (Task 1 Step 1-2 분석 결과) + GAP-ANALYSIS-PROMPT.md |
| Target length | resource-type-matrix.md ~80-120 lines / delegation-envelope.md ~80-120 lines |
| License / attribution | MIT in-house (3 creator 의 본문 통합 — 출처 표기 불요, 동일 plugin) |
| 작성 정책 | matrix.md = 표 형식 only (분기 lookup 용) / envelope.md = §3b dispatch payload + GAP-ANALYSIS-PROMPT 9 heading 복사 절차. 두 reference 모두 SKILL.md 본문 재생산 금지 — SKILL.md 는 *언제* references 를 lookup 할지만 명시 |

**(a) `references/resource-type-matrix.md` 작성**

source: Task 1 Step 2 의 분기 표
target length: ~80-120 lines
content:

1. 헤더 (출처: 본 plan + 3 creator 의 §3-§4 — MIT in-house)
2. matrix 표 (Task 1 Step 2 의 11 행 × 3 자원)
3. lookup 절차 — `resource_type` args 로 행 선택 + 호출자 (creator) 의 §3 진입 시점에 결정된 값 채움
4. 예시: skill / agent / hook 각 1 case 로 lookup 시뮬레이션
5. 알려진 한계 — matrix 에 없는 자원 타입은 `unknown_resource_type` 에러 반환

**(b) `references/delegation-envelope.md` 작성**

source: 3 creator §3b 본문 (`skill-creator/SKILL.md` line 164 의 "경로 resolve 책임" 절 + line 166-189 의 dispatch payload 예시 — `<RESOLVED_REFS_DIR>` placeholder 정의 위치) + GAP-ANALYSIS-PROMPT.md (9 heading 의 verbatim source)
target length: ~80-120 lines
content:

1. 헤더 (출처: 본 plan + 3 creator §3b — MIT in-house. GAP-ANALYSIS-PROMPT 인용)
2. dispatch envelope template (`subagent_type: "general-purpose"` + description + prompt block)
3. `<RESOLVED_REFS_DIR>` 치환 책임 — main session (호출자 creator 또는 본 skill) 이 절대 경로 resolve. 출처 원문: skill-creator/SKILL.md line 164 "**경로 resolve 책임** — 위임 prompt 의 cwd 필드는 main session 이 *절대 경로* 로 채워서 보낸다 (`${CLAUDE_PLUGIN_ROOT}/references` 우선, env 미설정 시 §Reference Loading Schedule 의 fallback `../../references/`)"
4. prompt 본문 구성 절차 — GAP-ANALYSIS-PROMPT.md 의 9 heading verbatim 복사 (matrix `delegation_check_axis` 분기)
5. 복사 *제외* 섹션 (5 개) 명시 — envelope 가 직접 지시하므로 중복 회피
6. envelope 의 *자원별 분기 슬롯* — `<TARGET_SECTION>` (matrix `delegation_target_wording` + `target_paths` 채움)
7. Common Failures — heading 누락, 분기 슬롯 미채움, envelope 가 cwd 외부 path 노출

작성 후 verify:

```bash
wc -l plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
       plugins/bobs-plugin/skills/creator-gap-eval/references/*.md
```

Expected:
- SKILL.md ≈ 250-350 lines
- resource-type-matrix.md ≈ 80-120 lines
- delegation-envelope.md ≈ 80-120 lines
- 총 references ≈ 160-240 lines

- [ ] **Step 3: skill-creator §3 GAP 분석 (interactive)**

skill-creator §3a 가 workspace 생성:

```bash
mkdir -p plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps
```

§3b (위임 권장) 또는 §3c (인라인) 로 GAP 분석. main session 은 위임 prompt 의 target 을 다음 3 경로로 확장:

```
분석 대상 (확장):
  - <SKILL_PATH>/SKILL.md
  - <SKILL_PATH>/references/resource-type-matrix.md
  - <SKILL_PATH>/references/delegation-envelope.md
각 파일을 같은 GAP-FORMAT §9 형식으로 평가. finding 의 evidence 필드에 어느
파일의 어느 위치인지 명시.
```

본 skill 의 *고유* 검증축:
- 호출 인터페이스 (args 5개) 가 호출자 chain 에서 *추출 가능* — 즉 3 creator 의 §3 stub 에서 모든 args 가 결정 가능한지 (+ 사용자 직접 호출 시 §0 가 args 캡처). **workspace_path 가 args 에 없는지** 확인 (호출자 위탁 제거)
- 반환 contract (final_decision yaml) 가 호출자 §5 분기에 *충분* — 호출자가 추가 정보 없이 §5 진행 가능한지. **report_path 가 절대 경로인지** + 통합 workspace 위치인지
- matrix lookup 의 *완전성* — 11 행 모두 채워졌고 unknown case 대응 있는지 (특히 hook 의 2 파일 분석 — script + registration 의 분기가 한 행으로 잡히는지)
- envelope 의 9 heading 복사 절차가 *원자적* — 누락 검출 가능한지
- **self-application path-based 검출 + 재진입 limit 2** — `args.draft_path` 가 `creator-gap-eval/` 하위인지 확인 → `args.reentry_count` 검사 → > 2 면 NEEDS_REVIEW early exit (Common Failures 명시)
- **사용자 직접 호출 시 §0 가 args 부재를 캡처** — main session 이 호출자가 아닌 경우 args 가 비어있을 수 있음 (CONSTITUTION §3.3 effect gate)
- **통합 workspace 경로 결정 로직** — `${CLAUDE_PLUGIN_ROOT}` env 미설정 시 fallback path (`../../../skills/creator-gap-eval-workspace`) 정의되어 있는지

skill-creator §4 Final Decision 분기 (기존 패턴):

- `PASS` → §5 진행
- `PASS_WITH_NOTES` → 옵션 적용 후 §5
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침) 후 §3 재실행
- 5 라운드 초과 → `NEEDS_REVIEW` 사용자 보고

- [ ] **Step 4: 추출 충실도 audit (skill-creator GAP 외 추가 검증)**

`creator-gap-eval/SKILL.md` 의 본문이 3 creator §3-§4 의 *공통 절차* 를 모두 포함하는지 + self-application 안전장치가 path-based 인지 검증:

```bash
echo "--- 추출 충실도 (Phase 키워드 매핑) ---"
for kw in "Workspace 준비" "위임" "직접" "Self-Check" "Final Decision" "Finding 적용" "Re-run gate" "GUIDE_GAP" "PASS_WITH_NOTES" "REVISE_ASSET" "REVISE_GUIDE" "SPLIT_ASSET" "DEPRECATE_ASSET" "NEEDS_REVIEW"; do
  grep -q "$kw" plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- self-application 안전장치 (path-based + reentry limit) ---"
for kw in "self-application" "draft_path.*creator-gap-eval" "reentry_count" "재진입" "NEEDS_REVIEW"; do
  grep -qE "$kw" plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- 자원별 분기 항목 (matrix 키 매핑) ---"
for kw in "snapshot_section" "checks_section" "guide_name" "delegation_check_axis" "target_paths" "workspace_name_pattern" "split_asset_signals" "severity_examples" "reroute_candidates"; do
  grep -q "$kw" plugins/bobs-plugin/skills/creator-gap-eval/references/resource-type-matrix.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- frontmatter user-invocable: true ---"
grep -q "^user-invocable: true" plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
  && echo "  ok" || echo "  MISSING — 사용자 직접 호출 차단됨"

echo "--- workspace 자체 결정 (호출자 위탁 없음) ---"
# workspace_path 가 args 에 없어야 함 (호출자 위탁 제거)
grep -qE "args.*workspace_path|workspace_path:.*args" plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
  && echo "  FAIL: workspace_path 가 args 에 남아 있음 (호출자 위탁 안 제거됨)" \
  || echo "  ok: workspace_path 는 args 아님"
# 통합 workspace 경로 본문에 명시
grep -q "creator-gap-eval-workspace/gaps" plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
  && echo "  ok: 통합 workspace 경로 명시됨" \
  || echo "  MISSING: 통합 workspace 경로 본문에 없음"
```

모두 `ok` 만 나와야 한다. `MISSING:` 발견 시 §2 시점 B gate 거쳐 보강.

- [ ] **Step 5: 호출 인터페이스 self-test (dry-run)**

3 creator 의 §3 진입 시점을 시뮬레이션해 args 추출 가능성 검증:

```bash
echo "--- skill-creator §3 진입 시점 args 추출 가능성 ---"
# skill-creator 의 §0-§2 가 SKILL_PATH / asset_name / WORKSPACE 를 main context 에 남기는지 확인
grep -nE "SKILL_PATH=|WORKSPACE=|asset_name|kebab-case" \
  plugins/bobs-plugin/skills/skill-creator/SKILL.md | head -10

echo "--- agent-creator §3 진입 시점 args 추출 가능성 ---"
grep -nE "AGENT_PATH=|AGENT_NAME=|WORKSPACE=" \
  plugins/bobs-plugin/skills/agent-creator/SKILL.md | head -10

echo "--- hook-creator §3 진입 시점 args 추출 가능성 ---"
grep -nE "HOOK_DIR=|SCRIPT_PATH=|REGISTRATION_PATH=|WORKSPACE=" \
  plugins/bobs-plugin/skills/hook-creator/SKILL.md | head -10
```

각 creator 의 §0-§2 가 `creator-gap-eval` 의 args 5개를 *결정* 가능해야 한다. 누락 시 Task 3 의 stub 본문에 추출 절차 명시.

- [ ] **Step 6: 길이·구조 verify**

```bash
wc -l plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
       plugins/bobs-plugin/skills/creator-gap-eval/references/*.md
```

Expected:
- SKILL.md ≈ 250-350 lines (3 creator §3-§4 합산 ~375 lines 보다 작아야 — 분기 표 추출 효과)
- references ≈ 160-240 lines (matrix + envelope)
- 총 ≈ 410-590 lines (3 creator §3-§4 단순 합산 ~1,125 lines 의 **40-50%** — 추출 효과 60%+ 확보)

총량이 600 lines 초과 시 *분기 표가 본문에 누수* 의심 — matrix 로 옮길 행 식별.

- [ ] **Step 7: Commit — 신규 skill + references + GAP report**

```bash
git add plugins/bobs-plugin/skills/creator-gap-eval/ \
        plugins/bobs-plugin/skills/creator-gap-eval-workspace/

git commit -m "$(cat <<'EOF'
Add creator-gap-eval skill (Step 4b — extraction prereq for Step 5)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 4b (Step 5 prerequisite)

3 creator (skill-creator / agent-creator / hook-creator) 의 §3-§4 실측 ~375 lines
중 ~70% 본질 중복 추출 → 단일 skill 통합. resource_type args 분기 + path-based
self-application 검출 + 재진입 최대 2회.

- skills/creator-gap-eval/SKILL.md (10-phase capability procedure: Phase 0
  self-application 검사 + Phase 1-9 + args 6개 / 반환 contract)
- references/resource-type-matrix.md (11 분기 행 × 3 자원)
- references/delegation-envelope.md (§3b dispatch payload + GAP-ANALYSIS-PROMPT
  9 heading 복사 절차)
- workspace/gaps/creator-gap-eval.GAP.md (bootstrap — Final Decision PASS /
  PASS_WITH_NOTES / REVISE_GUIDE)

user-invocable: true — 사용자 직접 호출 허용 + creator chain 자동 호출 모두 지원.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: 3 creator §3-§4 stub 교체

**Files:**
- Modify: `plugins/bobs-plugin/skills/skill-creator/SKILL.md` (§3-§4 → ~15 lines stub)
- Modify: `plugins/bobs-plugin/skills/agent-creator/SKILL.md` (§3-§4 → ~15 lines stub + Description optimization 절은 유지)
- Modify: `plugins/bobs-plugin/skills/hook-creator/SKILL.md` (§3-§4 → ~15 lines stub)

- [ ] **Step 1: Baseline 확인 — 각 creator 의 §3-§4 라인 범위**

```bash
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c ==="
  grep -n "^## 3\.\|^## 4\.\|^## 5\." "plugins/bobs-plugin/skills/$c/SKILL.md"
done
```

Expected (2026-05-17 실측 — Task 3 Step 3-5 Edit 직전 *반드시* 재실행. CONSTITUTION 수정 등으로 ±N lines drift 가능):
- skill-creator: §3=137 / §4=217 / §5=262 → §3-§4 = lines 137-261 (~125 lines)
- agent-creator: §3=146 / §4=237 / §5=282 → §3-§4 = lines 146-281 (~136 lines)
- hook-creator: §3=144 / §4=222 / §5=267 → §3-§4 = lines 144-266 (~123 lines)

위 line 번호는 *2026-05-17 시점 snapshot*. 실 작업 시점에 변할 수 있으니 Step 3-5 Edit 직전에 다시 `grep -n '^## '` 으로 refresh 후 사용.

- [ ] **Step 2: stub 본문 결정 — 3 creator 공통 골격**

각 creator §3-§4 → 다음 ~25 lines stub 로 교체. `<TYPE>` / `<draft_path>` 는 자원별 분기. **§4 헤더는 보존** (외부 ref 깨짐 방지 — review P1#7 결정: 선택지 b):

```markdown
## 3. GAP 분석 (creator-gap-eval 호출)

본 절차는 `creator-gap-eval` skill 이 통합 처리한다 (Step 4b 추출 결과). §0-§2 에서 결정된 다음 값으로 호출 — workspace 는 creator-gap-eval 이 자체 결정 (plugin 단위 통합 — `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/`).

```yaml
resource_type: <TYPE>          # skill | agent | hook
draft_path:                    # 자원별 분기
  - <SKILL_PATH>/SKILL.md      # skill 예시
asset_name: <kebab-case name>  # 파일명 = <resource_type>-<asset_name>.GAP.md
delegation_mode: delegate      # 기본 위임 (비용 절감 필요 시 inline)
reentry_count: 0               # 본 creator 가 호출하는 경로는 항상 0
```

호출 (Claude Code 환경): `Skill` tool 로 `creator-gap-eval` 활성화. 반환 yaml 의 `final_decision` 으로 분기 — 상세는 §4 참조. `report_path` 는 통합 workspace 의 절대 경로 반환.

## 4. Self-feedback refine — Final Decision 처리

`creator-gap-eval` 의 반환 yaml 을 받아 다음 분기:

- `PASS` / `PASS_WITH_NOTES` → §5 (Output to caller) 로 진행
- `REVISE_GUIDE` → 사용자 보고 후 §5 (자산은 일단 통과)
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침) 후 `creator-gap-eval` 재호출 (round_count 증가)
- `SPLIT_ASSET` → §0 으로 복귀, 책임 분리 재설계
- `DEPRECATE_ASSET` → 사용자 confirm 후 폐기 권고
- `NEEDS_REVIEW` → 사용자 입력 받기 (creator-gap-eval 의 reentry_count 한도 또는 round_count 한도 초과 포함)

라운드 5 초과 시 `creator-gap-eval` 이 `NEEDS_REVIEW` 반환 (round_count 한도). Finding 적용 / Re-run gate / GUIDE_GAP 의 상세 절차는 `creator-gap-eval/SKILL.md` Phase 7-9 와 `references/resource-type-matrix.md` 의 자원별 분기 행 참조.
```

위 stub 본문은 *§3 + §4 헤더 모두 보존* (외부 ref / 다른 plan 의 "§3 시점 B gate" 등 인용 안전). §3 = 호출 + args, §4 = Final Decision 분기. 절차 본문은 모두 `creator-gap-eval` 로 위임.

- [ ] **Step 3: skill-creator stub 적용**

**Edit 직전 line number refresh** (drift 방지):

```bash
grep -n "^## 3\.\|^## 4\.\|^## 5\." plugins/bobs-plugin/skills/skill-creator/SKILL.md
```

위 결과로 old_string 시작 line (§3) ~ 종료 line (§5 직전) 확정.

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator/SKILL.md`
- old_string: `## 3. GAP 분석` 부터 `## 5.` 직전 까지 전체 (refresh 결과 사용)
- new_string: Step 2 의 stub 본문 (skill 자원 분기 적용 — `<TYPE>` = `skill`, `draft_path` = `<SKILL_PATH>/SKILL.md`)

작성 후 verify:

```bash
wc -l plugins/bobs-plugin/skills/skill-creator/SKILL.md
# Expected: 337 - 100 = ~237 lines (현재 337 → stub 적용 후 약 230-240)

grep -n "^## " plugins/bobs-plugin/skills/skill-creator/SKILL.md
# Expected: §0/§1/§2/§3/§4/§5/§6 헤더 모두 보존 (§3 = creator-gap-eval 호출, §4 = Final Decision 처리)
```

- [ ] **Step 4: agent-creator stub 적용**

**Edit 직전 line number refresh**:

```bash
grep -n "^## 3\.\|^## 4\.\|^## 5\." plugins/bobs-plugin/skills/agent-creator/SKILL.md
```

Edit:
- old_string: `## 3. GAP 분석` 부터 `## 5.` 직전 까지 전체 (refresh 결과 사용)
- new_string: Step 2 의 stub 본문 (agent 자원 분기 — `<TYPE>` = `agent`, `draft_path` = `<AGENT_PATH>`)

특히 agent-creator 의 §3 첫머리에 있는 *"에이전트용 핵심 차이점" 표* (현재 line 157-161 부근) 는 `creator-gap-eval/references/resource-type-matrix.md` 의 `severity_examples` / `split_asset_signals` 행으로 흡수되었으므로 stub 에서 제거. agent-creator 의 §Description optimization (현재 line 343 부근) 은 *유지* (skill 추출 외).

- [ ] **Step 5: hook-creator stub 적용**

**Edit 직전 line number refresh**:

```bash
grep -n "^## 3\.\|^## 4\.\|^## 5\." plugins/bobs-plugin/skills/hook-creator/SKILL.md
```

Edit:
- old_string: `## 3. GAP 분석` 부터 `## 5.` 직전 까지 전체 (refresh 결과 사용)
- new_string: Step 2 의 stub 본문 (hook 자원 분기 — `<TYPE>` = `hook`, `draft_path` = `[<SCRIPT_PATH>, <REGISTRATION_PATH>]`)

- [ ] **Step 6: stub 적용 후 길이 verify**

```bash
wc -l plugins/bobs-plugin/skills/skill-creator/SKILL.md \
       plugins/bobs-plugin/skills/agent-creator/SKILL.md \
       plugins/bobs-plugin/skills/hook-creator/SKILL.md

# Expected (2026-05-17 실측 baseline 기준):
# skill-creator: 337 → ~237 lines  (-100, §3-§4 본문 ~125 → ~25 lines stub)
# agent-creator: 354 → ~244 lines  (-110)
# hook-creator:  362 → ~262 lines  (-100)
# 총 1053 → ~743 lines (-310 lines, ~30% 절감 / creator-gap-eval 약 +410-590 lines)
# 순 line count 는 증가 가능 — 본질 가치는 진실 source 1곳 (Goal 참고)
```

- [ ] **Step 7: 헤더 일관성 verify**

```bash
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c ==="
  grep -nE "^## [0-9]\." "plugins/bobs-plugin/skills/$c/SKILL.md"
done
```

Expected: 각 creator 가 §0/§1/§2/§3/§4/§5/§6 헤더 보존 (§3-§4 본문만 stub 으로 교체).

- [ ] **Step 8: Commit — 3 creator stub 교체**

```bash
git add plugins/bobs-plugin/skills/skill-creator/SKILL.md \
        plugins/bobs-plugin/skills/agent-creator/SKILL.md \
        plugins/bobs-plugin/skills/hook-creator/SKILL.md

git commit -m "$(cat <<'EOF'
Replace 3 creator §3-§4 with creator-gap-eval call (Step 4b)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 4b

3 creator (skill-creator / agent-creator / hook-creator) 의 §3 GAP 분석 + §4 Self-
feedback refine 본문 ~375 lines 를 ~75 lines stub (~25 × 3) 으로 교체. 상세 절차는
creator-gap-eval/SKILL.md + references/resource-type-matrix.md 가 통합 처리.

- §3 본문 = creator-gap-eval 호출 args (resource_type + draft_path + workspace +
  asset_name + delegation_mode + reentry_count) + Skill tool 호출 지시
- §4 헤더 유지 + 본문 = Final Decision 분기 (PASS / PASS_WITH_NOTES / REVISE_GUIDE
  → §5 진행, REVISE_ASSET → 재호출, SPLIT_ASSET → §0 복귀, DEPRECATE_ASSET / NEEDS_REVIEW
  → 사용자 보고)

자원별 specialization (GAP-FORMAT §11.X / §12.X / SPLIT_ASSET 신호 / Re-run gate
명단) 은 resource-type-matrix.md 에서 lookup.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: 3 creator self-eval — 새 chain 작동 검증

**Files:**
- (편집 없음 — 검증만)

stub 교체 후 새 chain 패턴이 실제 작동하는지 검증. 3 creator 가 *자기 자신을* `creator-gap-eval` 로 검증.

- [ ] **Step 1: skill-creator self-eval**

main session 에서 skill-creator 의 §3 진입 시뮬레이션 — `creator-gap-eval` 호출 시 args:

```yaml
resource_type: skill
draft_path:
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator/SKILL.md
asset_name: skill-creator
workspace_path: /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator-workspace
delegation_mode: delegate
```

`Skill` tool 로 `creator-gap-eval` 호출 (또는 dry-run 으로 수동 simulate). 반환 yaml 의 `final_decision` 확인:

- 기대: `PASS` 또는 `PASS_WITH_NOTES` (skill-creator 는 이미 PASS 받았던 자산 — 회귀 없어야)
- `REVISE_ASSET` 이면 stub 교체로 인한 regression — Task 3 stub 본문 재검토

- [ ] **Step 2: agent-creator self-eval**

동일 패턴, `resource_type: agent` + agent-creator path. 기대 결과 동일.

- [ ] **Step 3: hook-creator self-eval**

동일 패턴, `resource_type: hook` + hook-creator 의 script + registration path (현재 hook-creator 는 🚧 상태 — script 부재 시 NEEDS_INPUT 반환 확인).

- [ ] **Step 4: 회귀 비교 — stub 교체 전후**

각 creator 의 *원래* §3-§4 가 작동하던 시점의 GAP report 와 새 chain 결과 비교 가능 시 (없으면 spot-check):

```bash
# 이전 GAP report (있는 경우)
ls plugins/bobs-plugin/skills/skill-creator-workspace/gaps/ 2>/dev/null
ls plugins/bobs-plugin/skills/agent-creator-workspace/gaps/ 2>/dev/null
ls plugins/bobs-plugin/skills/hook-creator-workspace/gaps/ 2>/dev/null

# 새 chain 결과
ls plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/ 2>/dev/null
```

이전 결과와 새 결과의 `final_decision` 일치 확인 — 불일치 시 stub 본문이 args 추출을 누락하는지 점검.

- [ ] **Step 5: self-application 안전성 검증**

`creator-gap-eval` 이 *자기 자신* 을 분석하면? 위험 — 무한 루프 가능. SKILL.md 의 Common Failures 에 명시되어 있어야 한다.

```bash
grep -n "self-application\|자기 자신\|무한 루프" \
  plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md
```

Expected: 1-2 곳 (Common Failures 또는 When NOT to Use).

누락 시 §2 시점 B gate 거쳐 추가.

- [ ] **Step 6: Task 5 진행 gate (commit 없음 — 검증만)**

self-eval 결과는 호출자 workspace/gaps/ 에 누적되지만 본 Task 는 *검증* 이라 commit 없음.

**Task 5 진행 차단 조건** (review P1#6 반영):
- 3 creator 중 1 자원이라도 `final_decision` 이 `REVISE_ASSET` / `SPLIT_ASSET` / `DEPRECATE_ASSET` / `NEEDS_REVIEW` 면 Task 5 진행 금지. Task 3 stub 보강 또는 SKILL.md 본문 보강 (creator-gap-eval) 후 Task 4 재실행.
- `PASS` / `PASS_WITH_NOTES` / `REVISE_GUIDE` (자산 자체는 통과) 인 경우만 Task 5 진행 허용.
- 결정 기록: 본 Step 의 응답에 3 creator 각각의 final_decision 명시.

Rollback 비용이 큰 워크플로 (spec / workflow doc / meta 갱신) 가 Task 5 이므로 본 gate 가 마지막 안전망.

---

## Task 5: spec / workflow doc 갱신 + 메타 파일

**Files:**
- Modify: `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` (§7 Step 7 + §8 Asset Disposition)
- Modify: `plugins/bobs-plugin/references/harness-installation-workflow.md` (§5.1 채움 — creator skills 행에 `creator-gap-eval` 호출 언급)
- Modify: `plugins/bobs-plugin/.claude-plugin/plugin.json` (description)
- Modify: `.claude-plugin/marketplace.json` (description)
- Modify: `README.md` (file tree + skill 표 + namespace)
- Modify: `plugins/bobs-plugin/agents/agent-skill-auditor.md` (When NOT 절)

- [ ] **Step 1: spec §7 + §8 갱신**

`docs/specs/2026-05-17-harness-installation-design.md`:

§7 Migration Plan 에 *새 Step 으로 삽입* — **Step 4 (`evaluation-loop-design`) 다음, Step 5 (`evaluation-loop-runner`) 이전** (review P1#8 결정 — Step 7 안 sub-step 옵션은 기각, Step 4b 가 *Step 5 prerequisite* 이지 *Step 7 sub-step* 이 아님):

Edit:
- old_string: spec §7 의 `### Step 5. \`evaluation-loop-runner\` skill 작성` 헤더 직전 라인
- new_string:

```markdown
### Step 4b. `creator-gap-eval` 추출 (Step 5 prerequisite)

3 creator 의 §3-§4 (실측 ~375 lines, ~70% 본질 중복) 를 단일 skill 로 추출:

4b-1. 신규 skill `creator-gap-eval` (skill, plugin scope, `user-invocable: true`) — resource_type args 분기 + 사용자 직접 호출 허용.
4b-2. 3 creator §3-§4 → ~25 lines stub 로 교체 (Skill tool 호출 + args 전달 + Final Decision 분기). §3/§4 헤더는 보존.
4b-3. 3 creator self-eval — 새 chain 작동 검증. PASS / PASS_WITH_NOTES / REVISE_GUIDE 만 통과.
4b-4. workflow doc §5.1 + spec §8 Asset Disposition 갱신 + meta 파일.

본 Step 이 *Step 5 의 prerequisite* — Step 5 의 `evaluation-loop-runner` 가 creator chain 패턴 (creator-gap-eval 별도 skill) 을 인지한 채 자동 chain 설계해야 함. 본 Step 후 Step 7 (Creator skill spec 호환 확인) 의 *호환 대상* 도 정확해짐.

```

§8 Asset Disposition 표에 행 추가:

```markdown
| `creator-gap-eval` (신규) | 유지 — 3 creator chain 의 §3 호출 대상 + 사용자 직접 호출 (`user-invocable: true`). | Step 4b |
```

- [ ] **Step 2: workflow doc §5.1 갱신**

`references/harness-installation-workflow.md` §5.1 (현재 placeholder "TBD per Step 5") 의 일부를 본 Step 에서 *부분 채움* — creator chain 패턴만:

Edit:
- old_string: `- 5.1 \`skill-creator\` / \`agent-creator\` / \`hook-creator\` (이미 GAP-driven, spec 입력 받음)`
- new_string:

```
- 5.1 `skill-creator` / `agent-creator` / `hook-creator` (GAP-driven, spec 입력 받음). 각 creator 의 §3-§4 는 `creator-gap-eval` skill 호출 (Step 4b 추출) — `resource_type` args 로 분기, Final Decision 반환받아 §5 진행.
```

- [ ] **Step 3: plugin.json / marketplace.json description 갱신**

read 후 description 안에 `creator-gap-eval` 한 줄 추가 (Step 4 plan 의 wording-coordination precedent — 두 메타 파일 동기):

```bash
cat plugins/bobs-plugin/.claude-plugin/plugin.json | grep -A 2 description
```

Edit 두 곳 동일 어법:

> creator-gap-eval (3 creator §3-§4 통합 GAP 적용 절차, 직접 호출도 가능)

- [ ] **Step 4: README.md 갱신**

```bash
grep -n "skill-creator\|context-map-architecture" README.md | head -15
```

수정 위치:
- file tree — `creator-gap-eval` 행 추가
- skill 표 — `creator-gap-eval` 행 (책임 / scope / 호출 패턴 = creator chain + 사용자 직접 / user-invocable: true 표기)
- namespace 단락 — 한 줄 설명
- migration notes — Step 4b 신규 추출 명시 (있는 경우)

- [ ] **Step 5: agent-skill-auditor description When NOT 갱신**

```bash
grep -n "Do NOT use\|evaluation-loop-design" plugins/bobs-plugin/agents/agent-skill-auditor.md | head -5
```

Edit: 기존 Do NOT 절 (e.g., "Dead asset 감지(session-report)" 인근) 에 한 줄 추가:

> creation-time GAP 적용(creator-gap-eval) — 본 agent 는 *정적 rule 감사* (P0/P1/P2 + rule ID + confidence) 만, *GAP-FORMAT 적용 사이클* 은 creator-gap-eval 책임.

본 추가는 두 자산의 *layer 차이* (정적 rule audit vs creation-time GAP 적용) 를 명확히 함.

- [ ] **Step 6: 활성 참조 audit**

```bash
echo "--- creator-gap-eval 활성 참조 ---"
grep -rln "creator-gap-eval" \
  plugins/bobs-plugin/ \
  .claude-plugin/ \
  README.md 2>/dev/null | sort -u

# Expected:
#   .claude-plugin/marketplace.json
#   README.md
#   plugins/bobs-plugin/.claude-plugin/plugin.json
#   plugins/bobs-plugin/agents/agent-skill-auditor.md
#   plugins/bobs-plugin/docs/plans/2026-05-17-harness-installation-step4b.md
#   plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md
#   plugins/bobs-plugin/references/harness-installation-workflow.md
#   plugins/bobs-plugin/skills/agent-creator/SKILL.md
#   plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md
#   plugins/bobs-plugin/skills/creator-gap-eval/references/*.md
#   plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/*.md
#   plugins/bobs-plugin/skills/hook-creator/SKILL.md
#   plugins/bobs-plugin/skills/skill-creator/SKILL.md
```

placeholder 표기 (`예정` / `TBD`) 가 활성 routing 라인에 남아있지 않은지:

```bash
grep -rn "creator-gap-eval.*예정\|creator-gap-eval.*TBD\|creator-gap-eval.*planned" \
  plugins/bobs-plugin/ .claude-plugin/ README.md 2>/dev/null \
  | grep -v "docs/plans/\|workspace/gaps\|references/v1\|references/v2"

# Expected: 0 lines
```

- [ ] **Step 7: Commit**

```bash
git add plugins/bobs-plugin/docs/specs/ \
        plugins/bobs-plugin/references/harness-installation-workflow.md \
        plugins/bobs-plugin/.claude-plugin/plugin.json \
        .claude-plugin/marketplace.json \
        README.md \
        plugins/bobs-plugin/agents/agent-skill-auditor.md

git commit -m "$(cat <<'EOF'
Cross-ref creator-gap-eval + spec/workflow update (Step 4b)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 7 prerequisite refinement

- spec §7 Step 7 에 Step 4b sub-step 추가
- spec §8 Asset Disposition 표에 creator-gap-eval 행 추가
- workflow doc §5.1 — creator chain 패턴 명시 (creator-gap-eval 호출)
- plugin.json / marketplace.json / README.md: creator-gap-eval 등재
- agent-skill-auditor: When NOT 절에 creation-time GAP 라우팅 추가

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: 기존 분산 workspace → 통합 workspace 마이그레이션

**Files:**
- `git mv` (history 보존): `agent-creator-workspace/gaps/*.md` → `creator-gap-eval-workspace/gaps/`
- `git mv`: `hook-creator-workspace/gaps/*.md` → `creator-gap-eval-workspace/gaps/`
- Delete (빈 디렉토리): `agent-creator-workspace/`, `hook-creator-workspace/`
- (`skill-creator-workspace/` 는 부재 — 한 번도 생성 안 됨, 작업 없음)

기존 3 creator workspace 가 작성한 GAP report 를 통합 workspace 로 이동. history 보존을 위해 `git mv` 사용. 이전 디렉토리는 빈 채로 남으면 삭제.

- [ ] **Step 1: 현재 분산 GAP report 인벤토리**

```bash
echo "--- 이전 workspace GAP report ---"
find plugins/bobs-plugin/skills/agent-creator-workspace plugins/bobs-plugin/skills/hook-creator-workspace -name "*.GAP*.md" 2>/dev/null

# 2026-05-17 실측 baseline:
#   agent-creator-workspace/gaps/skill-agent-creator.GAP.md
#   agent-creator-workspace/gaps/skill-agent-creator.GAP.round2.md
#   hook-creator-workspace/gaps/skill-hook-creator.GAP.md
# 실행 시점에 추가 file 있을 수 있으니 find 결과 재확인
```

- [ ] **Step 2: `git mv` — agent-creator-workspace → 통합**

```bash
mkdir -p plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps

git mv plugins/bobs-plugin/skills/agent-creator-workspace/gaps/skill-agent-creator.GAP.md \
       plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/skill-agent-creator.GAP.md

git mv plugins/bobs-plugin/skills/agent-creator-workspace/gaps/skill-agent-creator.GAP.round2.md \
       plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/skill-agent-creator.GAP.round2.md
```

`asset_name` 충돌 없음 (creator-gap-eval-workspace 에는 bootstrap 자기 자신 GAP `skill-creator-gap-eval.GAP.md` 만 있을 것 — 다른 이름).

- [ ] **Step 3: `git mv` — hook-creator-workspace → 통합**

```bash
git mv plugins/bobs-plugin/skills/hook-creator-workspace/gaps/skill-hook-creator.GAP.md \
       plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/skill-hook-creator.GAP.md
```

- [ ] **Step 4: 빈 디렉토리 삭제**

```bash
# gaps/ 가 비었으면 삭제, workspace/ 도 빈 채면 삭제
rmdir plugins/bobs-plugin/skills/agent-creator-workspace/gaps 2>/dev/null
rmdir plugins/bobs-plugin/skills/agent-creator-workspace 2>/dev/null

rmdir plugins/bobs-plugin/skills/hook-creator-workspace/gaps 2>/dev/null
rmdir plugins/bobs-plugin/skills/hook-creator-workspace 2>/dev/null

ls -la plugins/bobs-plugin/skills/*-creator-workspace 2>/dev/null
# Expected: creator-gap-eval-workspace 만 존재 (또는 어떤 디렉토리가 다른 비-GAP 자산을 가지면 남음 — Step 1 결과로 사전 점검)
```

- [ ] **Step 5: Verify — 통합 workspace inventory**

```bash
ls plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/

# Expected (Task 2 의 bootstrap + Task 6 마이그레이션):
#   skill-creator-gap-eval.GAP.md         (bootstrap)
#   skill-agent-creator.GAP.md            (migrated)
#   skill-agent-creator.GAP.round2.md     (migrated)
#   skill-hook-creator.GAP.md             (migrated)
#   (이후 호출 누적될 자산 추가)
```

- [ ] **Step 6: Commit — workspace 마이그레이션**

```bash
git add plugins/bobs-plugin/skills/creator-gap-eval-workspace/ \
        plugins/bobs-plugin/skills/agent-creator-workspace/ \
        plugins/bobs-plugin/skills/hook-creator-workspace/

git commit -m "$(cat <<'EOF'
Migrate dispersed creator workspaces → unified creator-gap-eval-workspace (Step 4b)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 4b

이전 3 creator 의 분산 workspace 가 작성한 GAP report 를 plugin 단위 통합
workspace 로 이동. history 보존 (git mv). 이후 모든 GAP report 는 동일 위치
(${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/) 에 누적.

- agent-creator-workspace/gaps/{skill-agent-creator.GAP.md, .round2.md}
  → creator-gap-eval-workspace/gaps/ (git mv)
- hook-creator-workspace/gaps/skill-hook-creator.GAP.md
  → creator-gap-eval-workspace/gaps/ (git mv)
- 빈 디렉토리 (agent-creator-workspace/, hook-creator-workspace/) 삭제
- skill-creator-workspace/ 는 부재 (한 번도 생성 안 됨)

호출자는 workspace_path args 를 전달하지 않음 — creator-gap-eval 이 자체 결정.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Verification (전체 Plan 종료 후)

- [ ] **Step 1: 신규 skill 활성**

```bash
ls -la plugins/bobs-plugin/skills/creator-gap-eval/
ls -la plugins/bobs-plugin/skills/creator-gap-eval/references/
ls -la plugins/bobs-plugin/skills/creator-gap-eval-workspace/gaps/
```

Expected: SKILL.md + references/ (2 파일) + workspace/gaps/skill-creator-gap-eval.GAP.md 모두 존재.

- [ ] **Step 2: 3 creator §3-§4 stub 적용 확인**

```bash
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c §3 ==="
  sed -n '/^## 3\./,/^## 4\./p' "plugins/bobs-plugin/skills/$c/SKILL.md" | wc -l
done

# Expected: 각 ≈ 15-25 lines (stub 본문 + §4 헤더 직전까지)
```

- [ ] **Step 3: 호출 인터페이스 호환 — args 일관성**

```bash
echo "--- 3 creator stub 의 args 키 ---"
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c ==="
  grep -E "resource_type:|draft_path:|asset_name:|workspace_path:|delegation_mode:" \
    "plugins/bobs-plugin/skills/$c/SKILL.md"
done
```

Expected: 3 creator 모두 5 args 키 명시.

- [ ] **Step 4: 총 라인 절감 측정**

```bash
echo "--- stub 적용 전후 비교 ---"
wc -l plugins/bobs-plugin/skills/skill-creator/SKILL.md \
       plugins/bobs-plugin/skills/agent-creator/SKILL.md \
       plugins/bobs-plugin/skills/hook-creator/SKILL.md \
       plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md \
       plugins/bobs-plugin/skills/creator-gap-eval/references/*.md

# Expected (2026-05-17 baseline):
# 3 creator total ≈ 743 lines (이전 1053 → -310, -29%)
# creator-gap-eval total ≈ 410-590 lines
# 순 변화: -310 + (410~590) = +100 ~ +280 lines (단순 line count 는 증가 가능)
# 그러나 본질은 *중복 제거* — 1 자원 작성 시 main context 로드량 비교가 진짜 지표
```

순 line count 가 약간 증가해도 *진실 source 가 1 곳* + *1 자원 작성 시 main context 절감* (stub + lazy-load creator-gap-eval) 이 본질 가치.

- [ ] **Step 5: scope 일관성 (user-scope 가정 없음)**

```bash
grep -rn "~/.claude/" plugins/bobs-plugin/skills/creator-gap-eval/ 2>/dev/null

# Expected: 0 lines (Step 3 commit d41a649 scope decoupling 준수)
```

---

## Risks & Mitigations

| 위험 | 영향 | 완화 |
|---|---|---|
| stub 교체 후 main session 이 `creator-gap-eval` 호출을 누락 → §3-§4 작업 자체 사라짐 | creator 의 핵심 검증 절차 손실 | Task 4 self-eval 이 회귀 검출. stub 본문에 *호출 의무* 강조 ("§3 진입 시 반드시 호출" — CONSTITUTION §3.3 effect gate 인용) |
| `creator-gap-eval` 의 args 정의가 3 creator §0-§2 산출과 불일치 | args 추출 불가 → 호출 자체 실패 | Task 2 Step 5 dry-run 이 사전 검증. 불일치 발견 시 Task 3 stub 본문에 args 추출 절차 명시. **사용자 직접 호출 시** §0 가 누락 args 캡처 |
| matrix lookup miss (unknown resource_type) | runtime 에러 | Task 2 Step 4 audit 가 11 분기 행 모두 확인. SKILL.md 에 `unknown_resource_type` fallback (사용자 보고 + 종료) 명시 |
| **self-application 무한 재진입** — `creator-gap-eval` 이 자기 자신을 호출 (path-based detection 필요) | runtime 무한 진행 (resource_type=skill 만으론 검출 불가) | `args.draft_path` 가 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/` 하위인지 path-based 검출. 재진입 시 `args.reentry_count` 증가, > 2 면 NEEDS_REVIEW early exit (추가 의견 정책). SKILL.md Phase 0 + Common Failures 양쪽에 명시. Task 4 Step 5 가 검증 |
| GAP-ANALYSIS-PROMPT 9 heading 복사가 envelope 에서 누락 | 위임 prompt 가 불완전 → subagent 가 GAP report 작성 못함 | `delegation-envelope.md` 의 복사 절차에 verify step (9 heading 키워드 grep) 명시 |
| trigger-eval / red-green-refactor 의 자원별 specialization 이 *추출 가능* 으로 오인 | 분석 단계에서 잘못 통합 시도 → 자원-타입별 nuance 손실 | 본 plan §File Structure 의 "유지" 절에 명시 (diff 결과 인용). Task 1 Step 1 의 source 분석 시 §3-§4 *만* 추출 대상 |
| 3 creator 의 §0/§1/§2/§5/§6 도 *암묵적 중복* — 본 Step 후속 추출 압박 | scope creep | 본 plan §"Out of Scope" 에 명시 — §0-§2/§5-§6 추출은 별도 Step (필요 시) |
| `creator-gap-eval` 의 GAP report 가 *어느 workspace 에 저장되는지 혼란* | 호출자가 못 찾음 | **후속 review 반영 — 통합 workspace 채택**: `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/` 한 곳. 호출자 위탁 없음. 파일명 `<resource_type>-<asset_name>.GAP.md` 로 자산 분리. 반환 yaml 의 `report_path` 가 절대 경로. Task 6 의 `git mv` 가 기존 분산 workspace 마이그레이션 |
| **`asset_name` 충돌** — 같은 자산을 여러 라운드 검증 시 동일 GAP report 파일 덮어쓰기 | 이전 라운드 history 손실 | Common Failures + Task 6 Step 2 note 에 명시 — round 2+ 는 `.round2.md` suffix (기존 패턴 `skill-agent-creator.GAP.round2.md` 따름). `round_count` 반환 값으로 호출자가 suffix 결정 |
| Step 5 (`evaluation-loop-runner`) 작성 시 creator chain 패턴 모름 → 잘못된 자동 chain | runner 가 creator 호출 시 `creator-gap-eval` 인지 못함 | 본 Step 이 Step 5 이전 완료 필수 (Task 5 의 workflow doc §5.1 갱신이 prerequisite) |
| **`creator-gap-eval` 이 너무 generic — 자원-별 nuance 누수** (P2#10 후보 a) | hook 의 *2 파일 분석* (script + registration 쌍) 같은 자원별 검증축이 matrix 분기로 못 잡혀 PASS 받아도 실제로 hook 검증 부족 | Task 1 Step 2 분기 표 검토 시 *hook 의 2 파일 분기* 우선 점검. matrix 의 `target_paths` 행이 list 형 (1 vs 2) 명시. Task 4 Step 3 의 hook self-eval 결과를 *원래 hook-creator §3* 산출과 비교 |
| **5 args 가 부족 → 호출자 stub 이 추가 args 요구** (P2#10 후보 b — 인터페이스 break) | 3 creator 가 같은 인터페이스 못 쓰면 추출 가치 자체 무산 | Task 2 Step 5 dry-run 이 3 creator 모두에 대해 args 추출 가능성 검증. 부족 시 args 추가 후 Task 3 stub 통일. Done Criteria #3 self-eval 통과가 후행 검증 |

---

## Out of Scope

- 3 creator 의 §0 (Capture intent) / §1 (Choose scope) / §2 (Draft) / §5 (Output to caller) / §6 (Terminology and tone pass) 추출 — 자원-타입별 분기가 본질, 추출 효용 < 비용
- `trigger-eval.md` / `red-green-refactor.md` 통합 — diff 결과 byte-identical 아님, specialized
- `agent-creator/references/pressure-scenarios.md` 일반화 — agent 고유
- `hook-creator/references/matcher-pressure.md` 일반화 — hook 고유
- `hook-creator` 완성 (🚧 상태) — spec §7 Step 7 본문 작업
- `evaluation-loop-design` 의 runtime evaluation 사이클 (Step 4) — layer 다름
- `evaluation-loop-runner` (Step 5) — runtime 동작
- spec §4 의 spec_version v1 → v2 bump — 본 Step 은 호출 인터페이스 (creator chain) 만 변경, spec 인터페이스 (design skill 의 markdown structured section) 무변경

---

## Done Criteria

1. **신규 `creator-gap-eval` skill** — `plugins/bobs-plugin/skills/creator-gap-eval/` 에 SKILL.md + 2 references 존재. `creator-gap-eval-workspace/gaps/skill-creator-gap-eval.GAP.md` (bootstrap) Final Decision = `PASS` / `PASS_WITH_NOTES` / `REVISE_GUIDE` (자산 자체는 통과인 경우 모두 포함 — review P2#11 반영). `user-invocable: true` 명시 (사용자 직접 호출 허용).
2. **3 creator §3-§4 stub 교체** — `wc -l` 결과 3 creator total ≈ 712-740 lines (-310 ~ -338 lines, drift 허용). §3 + §4 헤더 모두 보존, 본문은 ~25 lines stub (호출 args + Final Decision 분기) × 3. **args 에서 `workspace_path` 없음** (호출자 위탁 제거).
3. **호출 chain 작동** — Task 4 self-eval 결과 3 creator 모두 `final_decision ∈ {PASS, PASS_WITH_NOTES, REVISE_GUIDE}` 반환. `REVISE_ASSET` / `SPLIT_ASSET` / `NEEDS_REVIEW` 발생 시 Done 미달.
4. **spec / workflow doc 동기** — spec §7 에 `Step 4b` 새 Step 으로 삽입 (Step 4 다음, Step 5 이전), §8 Asset Disposition 표에 행 추가. workflow doc §5.1 에 creator chain 패턴 (creator-gap-eval 호출) 명시.
5. **메타 파일 + agent 갱신** — plugin.json / marketplace.json / README.md / agent-skill-auditor 에 creator-gap-eval 등재. 활성 routing 일관성 (Verification Step 3) + placeholder 표기 0 (Verification Step 6).
6. **self-application 안전장치 작동** — Common Failures + Phase 0 가 path-based self call 검출 + `reentry_count > 2` 시 NEEDS_REVIEW 명시. 무한 루프 정책 (추가 의견) 적용 검증.
7. **통합 workspace 마이그레이션** — `git mv` 로 이전 `agent-creator-workspace/gaps/*.md` + `hook-creator-workspace/gaps/*.md` 가 `creator-gap-eval-workspace/gaps/` 로 이동. 빈 디렉토리 삭제. `ls .../creator-gap-eval-workspace/gaps/` 가 모든 GAP report 보여줌.

위 7개 모두 만족하면 Step 4b 종료, Step 5 (`evaluation-loop-runner`) 진행 가능.

---

## Reference: Step 4b 의 commit 순서 (예상 4 commits)

1. **Commit A** (Task 2 Step 7) — `Add creator-gap-eval skill (Step 4b — extraction prereq for Step 5)` — 신규 skill + 2 references + bootstrap GAP report
2. **Commit B** (Task 3 Step 8) — `Replace 3 creator §3-§4 with creator-gap-eval call (Step 4b)` — 3 creator stub 교체
3. **Commit C** (Task 5 Step 7) — `Cross-ref creator-gap-eval + spec/workflow update (Step 4b)` — spec / workflow / meta / agent 갱신
4. **Commit D** (Task 6 Step 6) — `Migrate dispersed creator workspaces → unified creator-gap-eval-workspace (Step 4b)` — git mv 로 history 보존하며 통합

Task 4 (self-eval) 는 검증만 — commit 없음. 회귀 발견 시 Commit B 보강 후 self-eval 재실행. Commit D 는 *Commit C 와 별도* — workspace 마이그레이션이 git history 에 명확히 표시되어야 함 (rollback 시 별도 revert 가능).
