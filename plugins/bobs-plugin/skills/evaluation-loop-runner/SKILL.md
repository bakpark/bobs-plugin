---
name: evaluation-loop-runner
description: Use when 작업 종료 후 사이클 진입 / task log 캡처 / 골든셋 비교 / 라우팅 결정이 필요할 때. 이전 design skill 산출 후 자동 chain 또는 사용자 `/evaluation-loop-runner` 명시 호출. `evaluation-loop-design` 가 작성한 `docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 명세를 *실행*. Do NOT use for 명세 작성 (`evaluation-loop-design`), 자원 작성 (creator skills), 자원 타입 결정 (`resource-design`), docs 인덱싱 (`context-map-architecture`), 정적 rule 감사 (`agent-skill-auditor`), creation-time GAP 적용 (`creator-gap-eval`), 코드/PR 리뷰.
tools: Read, Write, Bash
user-invocable: true
---

# Evaluation Loop Runner

`evaluation-loop-design` 가 작성한 *명세* (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md`) 를 *실행 시점* 에 적용한다. 한 호출당 task log entry write + golden-set case 비교 + Routing Decision 행 선택 + Next Action 반환 — 한 묶음. runner 는 *stateless* — 자동 chain + 라운드 카운트 + 종료 조건 enforce 는 *main session 책임*.

본 skill 은 *명세 실행자*. 명세 작성은 `evaluation-loop-design` (Step 4 산출).

## When to Use

활성화 trigger:

- 사용자 명시 호출 (`/evaluation-loop-runner` 또는 동등 command — spec §10 Decision 5 *명시 호출 우선*)
- "사이클 진입", "task log 캡처", "골든셋 비교", "라우팅 결정", "evaluation runner" 같은 발화
- 이전 design skill 산출 후 main session 의 자동 chain (이전 사이클의 Next Action 이 본 runner 를 가리킴)
- PR / commit 후 hook 트리거 (사전 등록된 PostCommit / Stop hook). hook = *raw 데이터 수집* 까지만, 의미 부여 (gap 분석 + 라우팅) 는 본 runner 의 명시 호출 (spec §9.2 경계)

## When NOT to Use

- 명세 작성 (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 신규/갱신) → `evaluation-loop-design`. 본 runner 는 *명세 실행자* 이지 *작성자* 아님
- 자원 (skill / agent / hook / command) 작성 → creator skills (`skill-creator` / `agent-creator` / `hook-creator`)
- 자원 타입 결정 / 책임 분리 / migration plan → `resource-design`
- docs 트리 / 인덱스 / 라우팅 (`AGENTS.md` / `CLAUDE.md` / `context-map.md`) → `context-map-architecture`
- 정적 rule 감사 (P0/P1/P2 + rule ID + confidence) → `agent-skill-auditor`
- creation-time GAP 적용 (creator 의 §3-§4 단계) → `creator-gap-eval`
- 코드 / PR 리뷰 → `pr-review-toolkit` / `codex-reviewer`

## Capability Procedure

3 phase — Phase 1 → Phase 2 → Phase 3 순서. 한 호출당 *한 사이클* 실행. main session 이 라운드 카운트 유지 + 종료 조건 enforce + Next Action 따라 다음 호출 결정.

### Phase 1: Task Log Capture

`docs/agent/task-log-template.md` schema 따라 `docs/agent/logs/YYYY-MM-DD-<slug>.md` entry write. 절차는 `references/log-entry-write.md` 적용.

**입력**: 실행한 작업의 transcript / 명령 / 참조 문서 (호출자가 본 runner 호출 시 첫 메시지로 전달)

**산출**: entry 절대 경로 — Phase 2 의 입력

**inspect** (호출 진입 시):
- `docs/agent/task-log-template.md` 존재 + schema 확인. 부재 시 `mode: blocked` + needs_input ("`evaluation-loop-design` 먼저 호출 — `task-log-template-write.md`")
- `docs/agent/logs/` 디렉토리 — 부재 시 첫 entry write 시 lazy mkdir (`task-log-template-write.md` §보존 정책)

**effect gate** (CONSTITUTION §3.3 이중):
- 1단계 (호출 자체) — runner 호출 자체가 명시 호출 또는 자동 chain. main session 이 호출 전 사용자 의도 확인 (자동 chain 중 종료 조건 enforce 가 1단계 역할)
- 2단계 (apply) — entry write 직전 경로·내용 요약 1회 응답 기록 (disclosure-only 가능)

### Phase 2: Gap Analysis

`docs/agent/golden-set.md` case 와 Phase 1 의 entry 비교. 5종 표면 분류 (PASS / FAIL / no-op / blocked / needs_input — `golden-set-write.md` 의 *PASS-only 회피* 안티패턴 따름).

**입력**: entry 절대 경로 (Phase 1 산출) + `docs/agent/golden-set.md` (case 정의)

**산출**:

```yaml
case_id: <case ID 또는 unknown (free-form task_type 일 때)>
result: PASS | FAIL | no-op | blocked | needs_input
summary: <한 줄>
```

**절차**:
1. entry frontmatter 의 `task_type` 식별
2. `docs/agent/golden-set.md` 에서 해당 task_type 의 case 추출. free-form 이면 `case_id: unknown` + Phase 3 의 *case 후보 표기* follow-up
3. case 의 5종 표면 정의 (PASS 조건 / no-op 표면 / blocked 표면 / needs_input 표면 / FAIL 조건) 검사
4. 결과 분류

**inspect**: `docs/agent/golden-set.md` 부재 시 `mode: blocked` + needs_input

### Phase 3: Routing Decision + Next Action

`docs/agent/evaluation-loop.md` Routing Decision 표 *행 매핑*. **표 본문 재생산 금지** — `docs/agent/evaluation-loop.md` 가 진실 source. runner 는 매 호출마다 read 해서 행 선택.

**입력**: Phase 2 의 gap 분석 결과 + `docs/agent/evaluation-loop.md` Routing Decision 표

**산출**:

```yaml
routing_decision: <design skill name 또는 no-op>
next_action:
  target: <design skill name>      # routing_decision 이 no-op 이면 비움
  input:
    prior_task_log: <abs path>     # Phase 1 산출
    gap_summary: <한 줄>           # Phase 2 산출 summary
```

**절차**:
1. Phase 2 결과 분기:
   - `PASS` only → Routing Decision: `no-op` (개선 필요 자산 없음)
   - `FAIL` / `blocked` → Routing Decision: 해당 자원 갱신 책임의 design skill (Routing Decision 표 행 선택)
   - `needs_input` → Routing Decision: `no-op` + `needs_input` 전달 (main session 이 사용자에게 질문)
2. `docs/agent/evaluation-loop.md` Routing Decision 표 *행* 매핑 — 각 행은 *신호 → 환원 위치* 정의
3. Next Action 의 `target` + `input` 결정 (target 이 비면 사이클 종료 신호)

**Routing Decision 표는 *행 매핑* 만**. 표 본문 (`| 신호 | 환원 위치 | rationale |` 6 행) 을 runner 본문에 복사하면 *drift 원인*. 매 호출마다 명세 파일을 read 해서 행 선택 (Common Failures 항목 #2 참조).

**inspect**: `docs/agent/evaluation-loop.md` 부재 시 `mode: blocked` + needs_input

## Output Contract

본 runner 한 호출의 산출 — spec §4.4 4 섹션 정확:

```yaml
mode: cycled | no-op | needs_input | blocked
task_log_entry: <abs path to docs/agent/logs/*.md>     # Phase 1 산출
gap_analysis:                                          # Phase 2 산출
  case_id: <golden-set case ID 또는 unknown>
  result: PASS | FAIL | no-op | blocked | needs_input
  summary: <한 줄>
routing_decision: <design skill name 또는 no-op>       # Phase 3 산출
next_action:                                           # Phase 3 산출
  target: <design skill name>     # no-op 일 때 비움
  input:
    prior_task_log: <abs path>
    gap_summary: <한 줄>
round: <N>     # main session 이 stateless runner 에 매 호출마다 증가시켜 전달
follow_ups:                                            # 선택
  - <case 갱신 follow-up 등>
```

`mode` 값 의미:

| mode | 의미 | main session 후속 동작 |
|---|---|---|
| `cycled` | 사이클 정상 완료 + Next Action 결정됨 | 자동 chain — Next Action 의 design skill 호출 (라운드 카운트 + 종료 조건 enforce) |
| `no-op` | Phase 2 결과 PASS only 또는 개선 필요 자산 없음 | 사이클 종료 + 사용자에게 결과 요약 |
| `needs_input` | Phase 2 의 5종 표면 중 `needs_input` 또는 inspect 단계 의존 자원 부재 (자원 부재는 blocked 우선) | 사용자에게 질문 후 재호출 결정 |
| `blocked` | 의존 자원 부재 (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 중 하나라도 부재) | needs_input 으로 어느 자원 부재인지 안내 + `evaluation-loop-design` 호출 권고 |

**복수 신호 동시 발생 시 우선순위**: `blocked` > `needs_input` > `no-op` > `cycled` (자원 부재가 가장 강한 신호 — case 정의의 `needs_input` 표면과 의존 자원 부재가 겹치면 `blocked` 우선 + needs_input 으로 부재 자원 안내).

main session 의 자동 chain 책임 (runner 외부 — `references/runtime-protocol.md` 참조):
- 라운드 카운트 유지 (runner 는 stateless — `round` 필드를 매 호출마다 main session 이 전달)
- 종료 조건 4종 enforce (no-op / 사용자 명시 종료 / 같은 target+fingerprint 2회 연속 / 누적 5회 초과) — fingerprint 정의는 `references/runtime-protocol.md` §2.1
- Next Action 의 design skill 호출 + `input` 전달
- 종료 후 사이클 결과 사용자 보고

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| 명세 작성 시도 | runner 가 `docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 본문 작성 시도 | runner 는 *명세 실행자*. 명세 작성은 `evaluation-loop-design` — 의존 자원 부재 시 `mode: blocked` 보고 |
| Routing Decision 표 본문 재생산 | runner 본문 또는 references 가 `docs/agent/evaluation-loop.md` Routing Decision 표 6 행 (`| 신호 | 환원 위치 | rationale |`) 본문 복사 | 표 *행 매핑* 만, 본문 재생산 금지 (drift-avoidance). 매 호출마다 명세 read |
| stateful runner | runner 가 이전 호출 상태 (라운드 카운트 / 사이클 이력) 자체 유지 시도 | runner 는 stateless. `round` 필드는 main session 이 매 호출마다 전달. 종료 조건 enforce 도 main session 책임 |
| 5종 표면 일부만 | Phase 2 가 PASS / FAIL 만 분류, no-op / blocked / needs_input 누락 | 5종 표면 모두 (`golden-set-write.md` 의 case 5종 표면 정의 따름) |
| 종료 조건 위반 | 같은 target+fingerprint 2회 연속 또는 5회 초과 chain 계속 | main session 의 cycle 카운터가 enforce — runner 외부 책임. runner 는 매 호출 stateless. fingerprint 정의는 `references/runtime-protocol.md` §2.1 |
| Phase 1 entry write 누락 | gap 분석만 수행, entry write 안 함 | Phase 1 강제 — entry 가 Phase 2 의 입력 source + 재현 가능성의 base |
| 비밀 entry 기록 | API 토큰 / 자격 증명이 entry 에 평문 기록 | placeholder / redacted 표기 강제 (`task-log-template-write.md` §보존 정책 4종 중 *비밀 금지*) |
| 의존 자원 부재 silent fail | `docs/agent/*.md` 부재 시 silent skip + dummy 결과 반환 | `mode: blocked` + needs_input 보고 — silent 진행 금지 |
| 자동 trigger 가 의미 부여 침범 | hook 이 runner 본문까지 실행 (gap 분석 + 라우팅 자동) | hook = raw task log 캡처까지, 의미 부여는 본 runner 명시 호출 (spec §9.2 + spec §10 Decision 5) |
| 명세 read 생략 | runner 가 `docs/agent/evaluation-loop.md` read 없이 routing decision (캐시된 mental model 사용) | 매 호출마다 명세 read 강제 — 명세 갱신 반영 + drift 방지 |
| 자동 chain 결정 runner 측에서 | runner 가 `next_action.target` 의 design skill 자체 호출 | runner 는 결정 *반환* 만, 실행은 main session. chain 책임 누수 방지 |

## References

- `references/runtime-protocol.md` — main session 의 자동 chain + 라운드 카운트 + 종료 조건 4종 enforce 절차 + Next Action dispatch 형식 + hook 트리거 vs 명시 호출 경계
- `references/log-entry-write.md` — Phase 1 의 task log entry write 절차 (`task-log-template.md` schema 적용 + lazy mkdir + append 필드 처리 + 비밀 redaction)

**Normative source** (본문 재생산 금지 — 매 호출 read 또는 인용만):

- `${CLAUDE_PLUGIN_ROOT}/docs/specs/2026-05-17-harness-installation-design.md` §4.4 (산출 4 섹션 + 종료 조건 4종) + §9.2 (hook vs runner 경계) + §9.6 (무한 사이클 완화) + §10 Decision 5 (명시 호출 우선)
- `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.5 (Context Map 라우팅) + line 294 (task-log-capture pair) + line 381 (evaluation-loop.md 가 runner 입력)
- `${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md` §3.1 (Activation Explicit — trigger 3종) + §3.3 (Effects Gates — 이중 gate) + §3.4 (Output Contract — 산출 4 섹션) + §3.13 (Freshness — runtime behavior 표기)

**Project-side runtime read 대상** (Step 4 의 `evaluation-loop-design` 산출, 부재 시 `mode: blocked`):

- `docs/agent/task-log-template.md` (Phase 1 schema)
- `docs/agent/golden-set.md` (Phase 2 case 비교 source)
- `docs/agent/evaluation-loop.md` (Phase 3 Routing Decision 표)

## Limits

- 본 runner 는 한 호출당 *한 사이클* (Phase 1 → Phase 2 → Phase 3 한 묶음) 만 실행. 자동 chain 은 main session 책임
- 명세 (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md`) 부재 시 `mode: blocked` + needs_input 보고 — 명세 작성 시도 금지 (책임 분리)
- 라운드 카운트 / 종료 조건 enforce / chain 결정 모두 main session 책임 — runner 는 stateless
- self-application 처리: runner 가 자기 자신 작성 작업을 평가하는 사이클은 무한 사이클 신호 — main session 이 검출 시 `NEEDS_REVIEW` 사용자 핸드오프 (`runtime-protocol.md` 참조)
- Capability surface: `Read` (명세 + entry source), `Write` (`docs/agent/logs/YYYY-MM-DD-<slug>.md` entry), `Bash` (`mkdir -p docs/agent/logs/` lazy create). Web / MCP / 외부 모델 / 자동 commit / 자동 push 미사용
