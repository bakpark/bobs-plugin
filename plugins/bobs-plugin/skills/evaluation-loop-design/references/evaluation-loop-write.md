# Evaluation Loop Write — docs/agent/evaluation-loop.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/evaluation-loop.md`.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.5 (Context Map 라우팅) + `${CLAUDE_PLUGIN_ROOT}/docs/specs/2026-05-17-harness-installation-design.md` §4.4 (`evaluation-loop-runner` runtime 동작). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

`docs/agent/evaluation-loop.md` 는 평가 사이클의 *명세* — 진입 조건 / 사이클 단계 / 종료 조건 / Routing Decision 표 (어디로 환원할지). 본 문서는 *design time* spec — runtime 실행은 `evaluation-loop-runner` (planned as of 2026-05-17, target Step 5 of `harness-installation-workflow.md` — 본 reference 적용 시 runner 자산 존재 여부 재확인 필요).

본 reference 는 `evaluation-loop-design` Phase 3 의 마지막 단계 wrapper. roles + golden-set + task-log-template 이 모두 확정된 후에 호출 (의존성: roles 의 실패 표면 + golden-set 의 case + task-log-template 의 entry schema 모두 인용).

---

## Phase 1: Inspect

`evaluation-loop-design` Phase 1 의 inventory 결과 + Phase 3 의 앞선 3 자산 (roles.md body, golden-set.md, task-log-template.md) 상태를 입력으로 받는다. 추가로 다음을 확인:

- `<repo>/docs/agent/evaluation-loop.md` 존재 여부 + 기존 사이클 패턴 (수동 / 자동 chain)
- 현재 자원 inventory + role 매핑 — Routing Decision 표의 *환원 종착* 자원이 존재하는지
- sibling design skill 4종 활성 여부 — `context-map-architecture` / `resource-design` / 본 skill / `agent-skill-auditor` (Routing Decision 표의 환원 candidates)
- (있다면) `evaluation-loop-runner` skill 존재 여부 — runtime chain 의 hand-off 대상

본 reference 가 의존하는 자산이 없으면 Phase 1 에서 *blocked* 로 보고:

```
mode: needs_input
category: inventory
items:
  - docs/agent/roles.md body 미작성 — roles-write.md 먼저 진입
  - docs/agent/golden-set.md 미작성 — golden-set-write.md 먼저 진입
  - docs/agent/task-log-template.md 미작성 — task-log-template-write.md 먼저 진입
```

---

## Phase 2: Draft

`docs/agent/evaluation-loop.md` template:

```markdown
# Evaluation Loop

> Author: evaluation-loop-design
> Date: <iso8601>
> Runtime executor: evaluation-loop-runner (planned)

본 문서는 *평가 사이클* 의 명세. design time spec — runtime 동작은 `evaluation-loop-runner` skill 이 본 명세를 따라 실행.

## 진입 조건

다음 중 하나일 때 사이클 진입:

1. 사용자가 작업 종료 후 명시 호출 (`/evaluate` 또는 동등 command)
2. `evaluation-loop-runner` 가 자동 chain (이전 사이클의 Routing Decision 이 *다음 design skill* 을 가리킴)
3. PR / commit 후 hook 트리거 (사전 등록된 PostCommit / Stop hook)

## 사이클 단계

| # | 단계 | 입력 | 산출 | 자원 |
|---|---|---|---|---|
| 1 | task log 캡처 | 작업 transcript / 명령 / 참조 문서 | `docs/agent/logs/YYYY-MM-DD-*.md` entry | `task-log-template.md` schema |
| 2 | gap 분석 | task log entry + golden-set | gap report (어느 case 가 PASS / FAIL / no-op / blocked / needs_input) | `golden-set.md` case |
| 3 | 환원 위치 결정 | gap 분석 결과 + role 매핑 | Routing Decision (다음 design skill 또는 no-op) | 본 문서 Routing Decision 표 |
| 4 | 다음 design skill 진입 | Routing Decision | 다음 사이클 진입 또는 사이클 종료 | 4 sibling design skill |

## Routing Decision 표

| 신호 | 환원 위치 | rationale |
|---|---|---|
| 문서 인덱스 / 라우팅 / context-map 불일치 | `context-map-architecture` | docs-tree 갱신 |
| 자원 (skill / agent / hook / command) 결정 모호 / 책임 분리 / 새 자원 필요 | `resource-design` | 자원 타입 결정 |
| 검증 인프라 (roles body / evaluation-loop / golden-set / task-log-template) 갱신 필요 | 본 skill (`evaluation-loop-design`) | 검증 자산 갱신 |
| 기존 자원의 정적 rule 위반 (P0/P1/P2 + rule ID) | `agent-skill-auditor` | 정적 감사 (read-only) |
| 코드 / PR 리뷰 필요 | `pr-review-toolkit` / `codex-reviewer` | 본 사이클 범위 밖 — 외부 자원 |
| gap 분석 결과 PASS 만 / 환원할 위치 없음 | (없음 — 종료) | Routing Decision: no-op |

## 종료 조건

다음 중 하나일 때 자동 chain 중단:

1. **Routing Decision: no-op** — gap 분석 결과 환원할 위치 없음 (개선 필요한 자산 없음)
2. **사용자 명시 종료** — "stop" / "충분" / "지금까지" / "그만"
3. **같은 design skill 2회 연속 호출** — 재진입 무한 루프 신호 (예: `resource-design` → `resource-design` 연속)
4. **누적 라운드 5회 초과** — `NEEDS_REVIEW` 로 사용자에게 핸드오프

종료 후 사이클 결과는 마지막 task log entry 에 기록 + 사용자에게 요약 응답.

## golden-set 비교 절차

gap 분석 단계 (사이클 단계 #2) 의 세부:

1. 현재 task log entry 의 *작업 유형* 식별
2. golden-set 에서 해당 작업 유형의 case 추출
3. 각 case 의 *실패 표면* (roles.md 의 role 별 실패 정의) 검사
4. 결과 분류: `PASS` / `FAIL` / `no-op` / `blocked` / `needs_input`
5. FAIL 또는 blocked → 다음 단계 (환원 위치 결정) 로
6. PASS only → Routing Decision: no-op

## task-log entry 갱신

사이클 단계 #1 에서 캡처한 entry 에 사이클 단계 #2-#3 결과를 append:

```
## Gap Analysis
<case ID>: <PASS/FAIL/no-op/blocked/needs_input>
<...>

## Routing Decision
target: <design skill name 또는 no-op>
rationale: <gap 분석 결과 한 줄>
```

## 자원 호출 contract

각 환원 위치 (design skill) 호출 시 본 evaluation-loop entry 를 입력으로 전달:

```
input:
  trigger: "evaluation-loop runner — round <N>"
  prior_task_log: <path>
  gap_summary: <한 줄>
```

각 design skill 의 §0 (intent capture) 가 위 input 을 받아 자체 흐름 진행.
```

template 작성 가이드:

1. **진입 조건 3종** 모두 포함 (수동 호출 / 자동 chain / hook 트리거) — 사이클 활성화 경로 모호하면 trigger 누락.
2. **사이클 단계 4개** 의 입출력 + 자원 명시 — 각 단계가 어느 자산을 입력으로 받고 어느 자산을 산출하는지 표로.
3. **Routing Decision 표** 는 *6 행* (4 sibling skill + 외부 + no-op) 권장. sibling skill 책임을 표로 명세하면 환원 결정이 결정적.
4. **종료 조건 4종** 강제 — 무한 사이클 안티패턴 회피. spec §4.4 precedent.
5. **golden-set 비교 절차** 와 **task-log entry 갱신** 은 runtime (`evaluation-loop-runner`) 가 따를 contract — design time 에 명세.
6. **자원 호출 contract** 는 환원된 design skill 의 §0 intent capture 가 받아야 할 input 형식. 4 design skill 모두 동일 형식 받음.

---

## Phase 3: Effect Gate

본 reference 가 호출되어 `docs/agent/evaluation-loop.md` 를 write 직전, 다음을 한 묶음으로 caller 에게 disclose:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `<repo>/docs/agent/evaluation-loop.md` (절대 경로) |
| 작업 종류 | new (없던 파일) 또는 update (기존 사이클 명세 갱신) |
| 진입 조건 수 | 3 (명시 호출 / 자동 chain / hook) |
| 사이클 단계 수 | 4 (task log 캡처 / gap 분석 / 환원 결정 / 다음 진입) |
| 종료 조건 수 | 4 (no-op / 명시 종료 / 같은 skill 2회 / 누적 5회) |
| Routing Decision 표 행 수 | <N> 행 (4 sibling skill + 외부 + no-op = 6 권장) |
| 인용 자산 | docs/agent/roles.md + golden-set.md + task-log-template.md 의 실제 절차 인용 (의존성 확정) |

"진행" / "go" / "proceed" 신호 시 write. "묻지 말고 진행" 모드는 disclosure-only.

---

## Verify (write 후 즉시)

- 진입 조건 3종 / 종료 조건 4종 / 사이클 단계 4개 모두 명시
- Routing Decision 표의 *환원 종착* 자원 (`context-map-architecture` / `resource-design` / `evaluation-loop-design` / `agent-skill-auditor`) 이 실제 존재 (ghost reference 검사)
- 인용 자산 (`roles.md` / `golden-set.md` / `task-log-template.md`) 이 실제 존재 — Phase 3 의 1-3 단계 산출과 일치
- runtime 자원 (`evaluation-loop-runner`) 은 *planned* 로 표기 — 존재하지 않아도 ok (Step 5 작성 예정)

---

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| 무한 사이클 | 종료 조건 누락 (특히 *같은 design skill 2회* 누락) → 사이클이 영원히 돌음 | 종료 조건 4종 강제 (spec §4.4 precedent) |
| Routing Decision 누락 | 어디로 환원할지 정의 없음 → 사이클 단계 #3 가 답 없음 | 4 sibling skill + 외부 + no-op 6 행 명세 |
| Ghost target | Routing Decision 표가 존재하지 않는 자원 가리킴 | Verify 단계의 ghost reference 검사 강제 |
| 의존성 위반 | `roles.md` body / `golden-set.md` / `task-log-template.md` 미작성 상태에서 본 reference 진행 | Phase 1 에서 blocked 로 보고. Phase 3 순서 1→4 강제 |
| Runtime 책임 흡수 | gap 분석 / 환원 결정 절차를 본 design time spec 이 *실행* 하려고 함 | runtime 동작은 `evaluation-loop-runner` (Step 5). 본 spec 은 *명세* 만 |
| 사용자 명시 종료 무시 | "stop" / "충분" 입력에도 사이클 계속 | 종료 조건 #2 강제. runtime 이 user input 수신 시 즉시 break |
| golden-set 비절차 | 사이클이 golden-set 비교 없이 *주관 평가* 만 함 | 사이클 단계 #2 강제. PASS / FAIL / no-op / blocked / needs_input 5종 분류 |
| 단계 누락 | 사이클이 task log 캡처 없이 gap 분석부터 시작 | 단계 #1-#4 순차 강제. task log 가 입력이 되어야 분석 가능 |
