# Runtime Protocol — Main Session 의 자동 chain + 종료 조건 enforce

> 본 문서는 `evaluation-loop-runner` skill 의 reference. runner 본문은 *한 사이클* (Phase 1-3 한 묶음) 실행만, *자동 chain* 은 main session 책임 — 본 reference 가 그 절차를 정의.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/docs/specs/2026-05-17-harness-installation-design.md` §4.4 (종료 조건 4종 + 자동 chain) + §9.6 (무한 사이클 완화) + §10 Decision 5 (명시 호출 우선). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.

본 reference 는 *main session 코드 패턴* 명시 — runner 호출 직후 main session 이 따라야 할 절차. runner 본문은 *stateless* 라 호출 측의 chain 제어가 필수.

---

## 1. 자동 chain 절차

runner 첫 호출 (명시 호출 또는 hook 트리거 또는 design skill 산출 후 자동) 직후 main session 의 흐름:

```
1. runner 호출 → Output Contract (mode + task_log_entry + gap_analysis + routing_decision + next_action + round)
2. mode 분기:
   - cycled: Next Action 처리 (단계 3 진입)
   - no-op: 사이클 종료 + 사용자 보고 (단계 6)
   - needs_input: 사용자 질문 (단계 5)
   - blocked: 의존 자원 부재 안내 + evaluation-loop-design 호출 권고 (단계 5)
3. Next Action 처리 (cycled 만):
   3a. 종료 조건 enforce (§2 참조) — 위반 시 즉시 단계 6
   3b. next_action.target 의 design skill 호출 — input 으로 next_action.input 전달
4. design skill 산출 후 다시 runner 호출 (자동 chain, round 증가)
5. 종료 조건 충족 또는 needs_input / blocked 까지 단계 1 반복
6. 사이클 종료 — 사용자에게 결과 요약 (단계별 round 수 + 마지막 task log entry path + 최종 mode)
```

라운드 카운트 (`round` 필드) 는 main session 이 유지 — runner 는 매 호출 stateless. 첫 호출 시 `round: 1`, chain 마다 증가.

---

## 2. 종료 조건 4종 enforce

각 라운드 단계 3a 에서 main session 이 검사. 위반 시 즉시 사이클 종료 + 사유 보고.

| # | 조건 | 검출 방법 | 보고 형식 |
|---|---|---|---|
| 1 | `Routing Decision: no-op` | runner 의 `routing_decision == "no-op"` | "사이클 종료 — 개선 필요 자산 없음 (PASS)" |
| 2 | 사용자 명시 종료 | 사용자 발화에 "stop", "충분", "지금까지", "그만" 또는 동등 신호 | "사이클 종료 — 사용자 명시 종료 후 라운드 N 에서 중단" |
| 3 | 같은 design skill 2회 연속 | 직전 호출의 `next_action.target` 과 현재 호출의 `next_action.target` 동일 | "사이클 종료 — `<skill>` 2회 연속 호출 (재진입 무한 루프 신호)" |
| 4 | 누적 5회 초과 | `round > 5` | "NEEDS_REVIEW — 누적 5 라운드 초과, 사용자 핸드오프" |

조건 #3 검출을 위해 main session 은 *직전 라운드의 target* 만 유지하면 됨 (chain 이력 전체 X). 라운드 카운트는 정수 1개.

---

## 3. Next Action dispatch 형식

`mode: cycled` 일 때 main session 이 design skill 호출 시 input 형식:

```yaml
trigger: "evaluation-loop-runner 자동 chain — round <N>"
prior_task_log: <abs path>      # runner Output Contract 의 task_log_entry
gap_summary: <한 줄>             # runner Output Contract 의 gap_analysis.summary
```

호출 대상 design skill 의 §0 (intent capture) 가 이 input 을 받아 자체 흐름 진행. 4 design skill (`resource-design` / `context-map-architecture` / `evaluation-loop-design` / `agent-skill-auditor`) 모두 동일 형식 받음 — Step 7 의 §0 args 호환 정렬과 별개 입력 채널 (chain trigger 는 args 가 아닌 첫 메시지).

---

## 4. Hook 트리거 vs 명시 호출 경계 (spec §9.2 + §10 Decision 5)

| 호출 source | 책임 범위 | 후속 |
|---|---|---|
| Hook (PostCommit / Stop / 등) | *raw task log 캡처 신호* 만 — 사용자에게 알림 발생 | runner 호출은 사용자 또는 main session 결정 (hook → runner 자동 호출 금지) |
| 사용자 명시 호출 (`/evaluation-loop-runner`) | 한 사이클 전체 (Phase 1-3) | 자동 chain 진입 (단계 3) |
| 자동 chain (이전 design skill 산출 후) | 한 사이클 전체 + chain 계속 | 종료 조건 enforce (§2) |

**현재 정책 (spec §10 Decision 5 *명시 호출 우선*)**: runner 의 모든 호출은 *명시* (사용자 또는 main session 의 자동 chain 결정). hook 은 *runner 호출 금지* — 사용자에게 알림만 보냄 ("작업 종료 — `/evaluation-loop-runner` 진입 권장").

이 정책은 무한 사이클 위험 회피 + spec §9.2 의 *hook = raw 데이터 수집, 의미 부여는 명시 호출* 경계 직접 적용. runner 본문은 *3 phase 한 묶음* 만 — `phase: 1-only` 같은 부분 실행 옵션 없음 (Output Contract 단순화).

---

## 5. self-application 처리 (무한 사이클 방지)

runner 가 자기 자신 작성/수정 작업의 entry 를 평가하는 경우 — 평가 결과가 *runner 본문 갱신* 을 가리키면 다시 runner 작성 → 다시 평가 → 무한 루프.

검출 패턴 (main session 책임):
- entry 의 `task_type` 또는 `호출 자원` 에 `evaluation-loop-runner` 본문 작성 흔적
- gap 분석 결과 `routing_decision` 이 `evaluation-loop-design` 또는 `resource-design` 으로 runner 자체 갱신을 요구

대응:
- 첫 사이클 — 정상 진행 가능 (한 번의 자기 평가 허용)
- 2회 이상 self-application 검출 — 즉시 `NEEDS_REVIEW` 사용자 핸드오프, 자동 chain 중단

본 검출은 종료 조건 #4 (누적 5회) 외 *추가 안전장치*. 종료 조건 #3 (같은 design skill 2회 연속) 도 self-application 대부분 잡지만, *서로 다른 design skill 을 순환* 하는 self-application 은 #3 miss — 본 §5 가 보완.

---

## 6. 사용자 보고 형식 (사이클 종료 시)

main session 이 사이클 종료 시 사용자에게 보고할 한 줄 + 상세 옵션:

**한 줄 요약** (필수):
```
사이클 종료 (총 <N> 라운드, 최종 mode: <mode>) — <종료 사유>
마지막 task log entry: <abs path>
```

**상세 (사용자 요청 시)**:
```
| 라운드 | task log entry | gap result | routing_decision |
|---|---|---|---|
| 1 | <path> | PASS/FAIL/... | <design skill or no-op> |
| 2 | ... | ... | ... |
| ... |
```

상세는 *모든 라운드의 task_log_entry* 가 보존 (`docs/agent/logs/`) — 사용자가 직접 read 가능. main session 이 메모리에 라운드 이력 보관할 필요 없음 (round 카운트 + 직전 target 만 유지).

---

## 7. needs_input / blocked 처리

| mode | 사용자에게 전달할 내용 |
|---|---|
| `needs_input` | runner 의 `gap_analysis.summary` + 5종 표면 중 어떤 표면 (needs_input 의 source 가 case 정의 또는 inspect 단계인지) |
| `blocked` | 부재 자원 명시 (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 중 어느 것) + 권고 ("`evaluation-loop-design` 호출 — `<해당 reference>-write.md`") |

사용자 입력 후 main session 이 재호출 결정:
- needs_input 응답 받음 → runner 재호출 (round 유지, gap_analysis 갱신용 추가 입력)
- blocked 해결됨 (의존 자원 작성 완료) → runner 재호출 (round 유지 또는 새 사이클 round=1)
- 사용자가 종료 요청 → 종료 조건 #2

---

## 8. main session 책임 vs runner 책임 (책임 분리 요약)

| 책임 | 주체 |
|---|---|
| Phase 1-3 실행 (entry write + gap 분석 + routing decision) | runner |
| Output Contract 산출 4 섹션 | runner |
| 명세 read (`docs/agent/*.md`) | runner (매 호출) |
| 라운드 카운트 (`round` 필드) 유지 | main session |
| 종료 조건 4종 enforce (no-op / 사용자 명시 / 2회 연속 / 5회 초과) | main session |
| self-application 검출 (§5) | main session |
| Next Action 의 design skill 호출 + input 전달 | main session |
| 사이클 종료 후 사용자 보고 | main session |
| hook 트리거 시 명시 호출 의도 신호만 | hook + main session (자동 chain 결정 main session) |

본 분리가 무너지면 — runner 가 자체 chain 시도 / 종료 조건 무시 / stateful 시도 — Common Failures 안티패턴.
