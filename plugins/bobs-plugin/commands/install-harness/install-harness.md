---
name: install-harness
description: Use when the user explicitly wants to install or refresh the harness — design skill 호출, spec 승인 gate, creator dispatch, runner cycle 까지 전체 orchestration entrypoint.
argument-hint: "[optional: 자연어 요청 또는 design skill 명시]"
allowed-tools: Read, Skill, Agent
model: sonnet
---

# install-harness

사용자가 명시 호출할 때 하네스 이식 전체 orchestration 의 단일 entrypoint. routing + design + spec gate + creator dispatch + runner cycle + 종료 조건 enforce + 사용자 보고를 한 command 책임으로 통합.

CONSTITUTION §2.1 ("Prompt Is Not A Harness Boundary") 의 *사용자 명시 호출 entrypoint* primitive — workflow doc 의 라우팅·gate·종료 조건이 main session 프롬프트가 아닌 본 command body 에 wrap.

## Outcomes (성공 기준)

본 command 호출의 가능한 outcome — spec-schema §2.1 의 mode 6종 + cycle outcome 1종:

| outcome | 의미 | command 후처리 |
|---|---|---|
| `created` | 신규 자원 (skill / agent / hook) 작성 spec → creator dispatch 완료 | §4 Created |
| `applied` | design skill 본문이 docs/specs 등 파일 write 완료 | §4 Applied (사후 승인 gate) |
| `plan-only` | spec 만 산출, 사용자 검토 대기 | §4 Plan-only |
| `no-op` | 기존 자원으로 충분 — 변경 불요 | §5 Report 후 종료 |
| `needs_input` | 사용자 추가 정보 필요 | §5 Report (질문) 후 design skill 재호출 |
| `blocked` | 의존 자원 부재 또는 권한 부족 | §5 Report (의존 자원 안내) 후 종료 |
| `cycled` | runner cycle 진입 — 자동 chain 후 위 outcome 중 하나로 수렴 | §5 Report (라운드 결과 요약) |

각 outcome 의 spec 형식 / payload 본문 / 후처리 분기는 spec-schema (`${CLAUDE_PLUGIN_ROOT}/references/spec-schema.md`) §2-§4 에 정의 — 본 command 는 *outcome 매핑 + 후처리 분기* 만 명시.

## Hard Constraints

- **spec gate** (CONSTITUTION §3.3 Effects Require Gates) — design skill 산출 spec 사용자 승인 없이 creator dispatch 금지. mode: `created` 의 1단계 effect gate.
- **applied 사후 승인 gate** — mode: `applied` 는 design skill 이 이미 파일 write 완료. command 가 변경 사항 사용자에게 보고 + 명시 승인 요구. design skill 의 effect gate 미통과 시 거부.
- **cycle 종료 조건 4종** — main session (본 command body) 의 cycle counter 가 enforce. runner 본문 외부 책임. fingerprint 비교는 `${CLAUDE_PLUGIN_ROOT}/skills/evaluation-loop-runner/references/runtime-protocol.md` §2.1.
- **backward compatibility** — v0.2 workflow doc 직접 호출 패턴 차단 안 함. 사용자가 design skill 직접 호출 (`/resource-design` 등) 해도 동작.
- **권한 격리** (COMMAND-GUIDE :81) — command 자체는 orchestration 만. 모든 file mutation 은 design skill / creator skill / runner 의 자체 권한으로 수행. command 의 `allowed-tools: Read, Skill, Agent` 가 mutation 권한 우회 차단.
- **outcome-first** (CONSTITUTION §3.7.1) — 본 command body 는 outcome contract + escalation 만 명시. design skill / creator skill 내부 절차는 자율 (Claude 가 판단).

## Inputs

- **optional** `argument` — 자연어 요청 또는 design skill 명시
  - 자연어 예: "AGENTS.md 만들어줘", "테스트 자동 실행 hook 추가", "검증 인프라 셋업"
  - 명시 예: "/install-harness resource-design", "/install-harness context-map-architecture"
- **ask user if missing** — argument 비었으면 첫 발화에서 자원 유형 / 작업 의도 / 적용 범위 묶어서 한 번에 질문

## Workflow

본 §Workflow 는 *outcome 분기 + escalation* 만 명시. 각 단계의 *어떤 도구를 어느 순서로* 는 Claude 가 outcome 보고 판단 (CONSTITUTION §3.7.1).

1. **Routing** — workflow doc §2 routing 표 *행 선택* (재생산 X). 사용자 발화 + 프로젝트 상태로 첫 design skill 결정. 동시에 둘 이상 후보면 *제일 명시적 신호* 우선.

2. **Design phase** — 선택된 design skill (Skill tool) 호출. design skill 의 inspect → spec 산출. spec 의 mode 필드 (top-level discriminator) read.

3. **Spec gate (1단계 effect gate)** — mode 가 `created` / `plan-only` 면 사용자에게 spec 본문 (또는 spec_path) 제시 + 승인 신호 ("진행" / "go" / "approve") 대기. 명시 거부 시 design skill 재호출 또는 종료.

4. **Outcome 분기** — mode 별 후처리:
   - `created` → §4.1 Created (creator dispatch)
   - `applied` → §4.2 Applied (사후 승인 gate)
   - `plan-only` → §4.3 Plan-only (사용자 결정 보류)
   - `no-op` → §5 Report 후 종료
   - `needs_input` → §5 Report (질문) → design skill 재호출 (round 유지)
   - `blocked` → §5 Report (의존 자원 안내) 후 종료

5. **Cycle** — Phase 2 후처리 완료 후 자동 chain 진입. `evaluation-loop-runner` 호출 → cycle counter 유지 + 종료 조건 4종 enforce (§5 Cycle 참조).

6. **Report** — 최종 outcome + 라운드 수 + 산출물 path + 잔여 follow-up 한 줄 요약 (§5 Report 참조).

### 4.1 Created (creator dispatch)

spec.execution_plan 항목 (target / args / rationale) 별:

- target 의 creator skill (`skill-creator` / `agent-creator` / `hook-creator`) 호출 — args 를 첫 메시지로 전달
- creator §0 가 args 키 누락 시 사용자에게 누락된 키만 질문 (workflow doc §5.1)
- creator §2 effect gate (apply) 가 실제 파일 write 직전 사용자 승인 (2단계 effect gate)
- creator §5 Output Contract `gap: PASS / PASS_WITH_NOTES` 면 다음 항목 진행. `blocked: needs revision` 면 chain 중단 + 사용자 보고

### 4.2 Applied (사후 승인 gate)

design skill (context-map-architecture / evaluation-loop-design) 이 이미 파일 write 완료. command 책임:

- spec.applied_changes 본문 사용자에게 보고 — 변경 파일 목록 + summary
- "이대로 진행하시겠습니까?" 명시 승인 요구
- 사용자 거부 시 — git revert 권고 + chain 종료. 사용자 승인 시 — §5 Cycle 진입
- design skill 본문이 effect gate 통과 후 write 했는지 사후 검증 (gate 우회 시 Risk 12.4 완화)

### 4.3 Plan-only (사용자 결정 보류)

spec.proposed_plan 본문 사용자에게 제시:

- 변경 파일 목록 + action + rationale + preview
- 사용자 결정 — 승인 시 design skill 재호출 (→ `applied` 또는 `created`). 거부 시 chain 종료

## Cycle (runner chain)

`evaluation-loop-runner` 호출 + main session (본 command body) 의 cycle counter 유지 + 종료 조건 4종 enforce. 세부 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/evaluation-loop-runner/references/runtime-protocol.md` §1-§8 참조.

**종료 조건** (runtime-protocol §2 인용 — 재생산 X):
1. `Routing Decision: no-op`
2. 사용자 명시 종료 ("stop", "충분", "그만" 등)
3. 같은 target + 같은 gap fingerprint 2회 연속 (runtime-protocol §2.1 fingerprint = `(target, case_id, result, summary_hash)`)
4. 누적 라운드 5회 초과 (`NEEDS_REVIEW`)

**command body 책임**: round counter 정수 1개 + 직전 라운드 `(target, gap_fingerprint)` tuple 1개 유지. runner 는 stateless — `round` 필드 매 호출마다 command 가 전달.

**self-application 처리**: runner 가 자기 자신 작성 entry 평가 시 — runtime-protocol §5 (2회 이상 self-application → NEEDS_REVIEW).

## Delegation Contract

본 command 가 위임하는 자원의 input / expected output / failure handling:

| 위임 대상 | input | expected output | failure handling |
|---|---|---|---|
| design skill (3종 — `resource-design` / `context-map-architecture` / `evaluation-loop-design`) | 사용자 발화 (자연어) 또는 chain 시 prior_task_log + gap_summary | spec (spec-schema §2 schema 따름) | `mode: blocked` / `needs_input` → 사용자 안내 후 chain 종료 또는 재호출 |
| creator skill (3종 — `skill-creator` / `agent-creator` / `hook-creator`) | spec.execution_plan 항목 (target / args / rationale) | created/updated path + GAP Final Decision | `blocked: needs revision` → 다음 항목 진행 안 함, 사용자 보고 |
| `evaluation-loop-runner` | 작업 transcript + round counter | 4 섹션 (task_log_entry / gap_analysis / routing_decision / next_action) | `mode: blocked` → `evaluation-loop-design` 호출 권고 |
| `agent-skill-auditor` (선택) | 신규 자원 path | P0/P1/P2 finding + rule_excerpt | P0 발견 시 chain 중단 |

## Context Links

- `${CLAUDE_PLUGIN_ROOT}/references/harness-installation-workflow.md` — overview (§1) + §2 routing + §5.1 creator args + §6 cycle + §7 anti-patterns
- `${CLAUDE_PLUGIN_ROOT}/references/spec-schema.md` — spec 형식 (top-level mode discriminator + outcome-specific payload)
- `${CLAUDE_PLUGIN_ROOT}/skills/evaluation-loop-runner/references/runtime-protocol.md` — cycle 절차 + 종료 조건 + fingerprint 정의
- `${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md` §2.1 (Prompt Is Not A Harness Boundary) + §3.3 (Effects Gates) + §3.7.1 (Outcomes And Constraints Before Routes)

## Effect Gates

본 command 는 *orchestrator* — 직접 파일 mutation 없음. 모든 mutation 은 design skill / creator skill / runner 의 자체 effect gate 가 처리.

command 책임 gate:

| gate | 시점 | 형식 |
|---|---|---|
| **1단계 spec gate** | mode: `created` / `plan-only` 의 design skill 산출 직후 | spec 본문 (또는 spec_path) 사용자에게 제시 + 명시 승인 |
| **사후 applied gate** | mode: `applied` 의 design skill 산출 직후 | applied_changes 본문 사용자에게 보고 + 명시 승인. 거부 시 git revert 권고 |
| **cycle 종료 보고** | 종료 조건 4종 중 하나 trigger | 한 줄 요약 + 라운드 결과 + 사용자 follow-up 안내 |

## Output Contract

command 종료 시 사용자에게 한 줄 보고:

```yaml
outcome: created | applied | plan-only | no-op | needs_input | blocked | cycled
rounds: <N>     # cycle 진입 시
artifacts:
  - <abs path>: <type — created/edited/proposed>
follow_ups:
  - <description>
```

`outcome` 이 `blocked` 또는 `needs_input` 이면 `recommended_action` 추가 — design skill 재호출 또는 사용자 직접 조치 안내.

## Common Failures

| # | 안티패턴 | 증상 | 수정 |
|---|---|---|---|
| 1 | spec gate 우회 | design skill 산출 spec 사용자 승인 skip 후 creator dispatch | §3 Spec gate 강제 (CONSTITUTION §3.3) |
| 2 | mode 추정 | spec mode 필드 누락 시 dispatch / created 추정 | spec-schema §5 파싱 규칙 — mode 누락 시 `needs_input` 으로 강제 전환 (사용자에게 안내) |
| 3 | applied gate 누락 | mode: `applied` 의 사후 승인 gate skip | §4.2 Applied 강제 |
| 4 | cycle 종료 조건 무시 | 같은 target+fingerprint 2 연속 또는 5 라운드 초과 chain 계속 | runtime-protocol §2 4 종료 조건 enforce — command body 의 cycle counter 책임 |
| 5 | workflow doc 직접 호출 차단 | 사용자가 design skill 직접 호출 시 command 가 차단 시도 | backward-compat (spec-schema §6) — 직접 호출 패턴 유지 |
| 6 | references 본문 재생산 | command body 가 spec-schema / workflow doc / runtime-protocol 의 표 본문 복사 | drift-avoidance — *인용 path* 만, 본문 재생산 금지 |
| 7 | route-prescriptive command body | command body 가 "1. yq install → 2. parse → 3. ..." 같은 절차 hard-code | outcome contract + escalation 만 명시 — 절차는 Claude 자율 (CONSTITUTION §3.7.1) |

## References

- `${CLAUDE_PLUGIN_ROOT}/references/harness-installation-workflow.md` (전체)
- `${CLAUDE_PLUGIN_ROOT}/references/spec-schema.md` (전체)
- `${CLAUDE_PLUGIN_ROOT}/references/COMMAND-GUIDE.md` §3 (frontmatter) + §4 (body 구조) + §13 (anti-patterns)
- `${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md` §2.1 / §3.3 / §3.4 / §3.7.1
- `${CLAUDE_PLUGIN_ROOT}/skills/evaluation-loop-runner/references/runtime-protocol.md` §1-§8
