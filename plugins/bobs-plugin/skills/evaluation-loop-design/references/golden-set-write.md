# Golden Set Write — docs/agent/golden-set.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/golden-set.md`.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.7 (자산 선택 기준 — 작업 유형 ↔ 자원 매핑) + `${CLAUDE_PLUGIN_ROOT}/references/GAP-FORMAT.md` §7 (Severity P0-P3 — vocabulary borrow only, GAP report 본문 형식은 재사용 아님). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

`docs/agent/golden-set.md` 는 *평가 case* 의 명세 — 작업 유형별 PASS / no-op / blocked / needs_input 표면 정의. evaluation-loop 의 사이클 단계 #2 (gap 분석) 에서 case 비교의 source.

본 reference 는 `evaluation-loop-design` Phase 3 의 세 번째 단계 wrapper. roles.md body 가 확정된 후에 호출 (의존성: role 의 *실패 표면* 이 case 의 PASS 정의 source).

---

## Phase 1: Inspect

`evaluation-loop-design` Phase 1 의 inventory 결과 + Phase 3 의 앞선 2 자산 (roles.md body, task-log-template.md) 상태를 입력으로 받는다. 추가로 다음을 확인:

- `<repo>/docs/agent/golden-set.md` 존재 여부 + 기존 case 수
- 작업 유형 후보 풀:
  - 이미 발생한 task log (`docs/agent/logs/*.md`) 의 작업 유형 빈도 (frequency 통계)
  - `harness-principles.md` §4.7 사례 표 — *역할 쌍* 별 작업 유형 예시
  - 사용자 발화에서 추출한 패턴 (반복 / 일회성 / 회귀 위험)
- roles.md body 의 각 role 별 *실패 표면* 정의 — case 의 PASS 정의 source
- 기존 PR / commit 회고 — *비싼 실패* 의 source

본 reference 가 의존하는 자산이 없으면 Phase 1 에서 blocked 로 보고:

```
mode: needs_input
category: inventory
items:
  - docs/agent/roles.md body 미작성 — roles-write.md 먼저 진입 (실패 표면 정의 source)
  - docs/agent/task-log-template.md 미작성 — task-log-template-write.md 먼저 진입
```

task log entry 가 0건이면 golden-set 은 *toy 예제* 가 되기 쉬움 — `harness-principles.md` §4.7 사례 표 인용 + follow-up 으로 *실제 task log 누적 후 case 갱신* 표기.

---

## Phase 2: Draft

`docs/agent/golden-set.md` template:

```markdown
# Golden Set

> Author: evaluation-loop-design
> Date: <iso8601>
> Used by: evaluation-loop.md 사이클 단계 #2 (gap 분석)

본 문서는 *평가 case* 의 명세. 각 case 는 작업 유형 + 입력 + 기대 산출 + 실패 표면 + 라우팅 정답 5가지를 정의.

## Case 선정 기준

다음 중 하나 이상을 만족하는 작업 유형을 case 로 등록:

1. **자주 발생** — task log 에서 N회 이상 (default N=3)
2. **실패가 비싼** — 회고에서 *비싼 실패* (rework / 외부 영향 / 데이터 손실) 사례
3. **라우팅 모호** — 어느 design skill 로 환원해야 할지 결정 모호 (사이클 단계 #3 가 헷갈리는 경우)
4. **Severity P0-P1 회귀 위험** — 이전 PR 에서 P0/P1 finding 으로 잡힌 작업 유형 (GAP-FORMAT §7 어휘 — vocabulary borrow only)

총 case 수는 **3-10 권장**. 10건 초과 시 maintenance 부담 — 우선순위로 압축.

## Case schema

```
### case-<id>: <작업 유형 한 줄>

**작업 유형**: <한 줄 — 동사 + 명사>
**입력 예시**: <자원 / 문서 / 사용자 발화 예>
**기대 산출 (PASS)**: <PASS 조건 — roles.md 의 role 별 실패 표면 reference>
**no-op 표면**: <어떤 조건에서 작업 자체가 불필요 — 호출자가 의도 변경>
**blocked 표면**: <어떤 조건에서 실행 불가 — 외부 의존 누락 등>
**needs_input 표면**: <어떤 조건에서 사용자 입력 필요>
**실패 표면 (FAIL)**: <PASS 조건 미충족 — 구체적 검사 가능한 조건>
**라우팅 정답**: <FAIL 시 환원할 design skill (evaluation-loop.md Routing Decision 표 행)>
**source**: <PR / commit / 회고 / harness-principles §4.7 행>
```

---

## Case 목록

(이하 case 별 동일 형식 반복)
```

template 작성 가이드:

1. **PASS only 회피** — 각 case 는 PASS + no-op + blocked + needs_input + FAIL 5종 표면 모두 정의. PASS 만 정의하면 사이클이 *실패가 아닌 경우* 를 구분 못함 (no-op / blocked 도 *비-FAIL* 이지만 라우팅 다름).
2. **실패 표면 검사 가능성** — *주관* 평가 (예: "코드가 좋다") 가 아닌 *검사 가능* (예: "테스트 통과 + lint 0 finding") 으로 정의. roles.md 의 role 별 실패 표면 reference 직접 인용.
3. **라우팅 정답** 은 `evaluation-loop.md` 의 Routing Decision 표 행 중 하나. ghost reference 회피.
4. **source** 표기 — case 가 *toy* 가 아니라 실제 발생 작업임을 표시. PR / commit / 회고 hash 또는 `harness-principles.md` §4.7 의 행 인용.
5. **case 수 3-10** — 너무 적으면 회귀 표면 부족, 너무 많으면 maintenance 부담.

case 가 toy 예제로 보이면 (모든 source 가 *합성* 또는 *예시*) follow-up 으로:

```
follow_ups:
  - golden-set 의 N 개 case 가 toy 예제 (실제 task log 없음) — task log 누적 후 case 갱신
```

---

## Phase 3: Effect Gate

본 reference 가 호출되어 `docs/agent/golden-set.md` 를 write 직전, 다음을 한 묶음으로 caller 에게 disclose:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `<repo>/docs/agent/golden-set.md` (절대 경로) |
| 작업 종류 | new (없던 파일) 또는 update (기존 case 갱신/추가) |
| case 수 | <N> 개 (3-10 권장) |
| toy ratio | <toy/total> (source 가 *합성* 인 case 비율 — 1.0 이면 모두 toy) |
| 5종 표면 검증 | 모든 case 가 PASS + no-op + blocked + needs_input + FAIL 정의 (bool) |
| 인용 source | roles.md 의 role <n> 개 인용 / `harness-principles.md` §4.7 사례 <n>개 인용 |

"진행" / "go" / "proceed" 신호 시 write. "묻지 말고 진행" 모드는 disclosure-only.

---

## Verify (write 후 즉시)

- case 수 (heuristic: 3-10 권장. 1-2 건 시 작업 유형 다양성 부족 가능성 경고. 10건 초과 시 maintenance 비용 검토. *hard fail 아님* — 초기 프로젝트에서 실제 발생 작업 유형이 적으면 N = 실제 수)
- 모든 case 가 PASS + no-op + blocked + needs_input + FAIL 5종 표면 정의
- 모든 case 의 *라우팅 정답* 이 `evaluation-loop.md` Routing Decision 표 행 중 하나 (ghost reference 검사)
- 모든 case 의 *실패 표면* 이 roles.md 의 role 별 실패 표면 reference 와 일치
- source 가 *toy* 인 case 비율 보고 (1.0 이면 follow-up 강제)

---

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Toy golden-set | 모든 case 의 source 가 합성 (실제 task log 없음) | task log 누적 후 case 갱신 follow-up 강제. 초기 시점에선 `harness-principles.md` §4.7 인용으로 minimal seed |
| PASS-only case | case 가 PASS 조건만 정의, no-op / blocked / needs_input / FAIL 표면 없음 | 5종 표면 모두 강제. 사이클이 *비-FAIL* 을 구분해야 라우팅 결정 가능 |
| 검사 불가 실패 표면 | "코드가 좋다" 같은 주관 정의 | roles.md 의 role 별 실패 표면 (검사 가능 조건) 직접 인용 |
| Case 와 자원 미연결 | case 의 *라우팅 정답* 이 design skill 명이 아님 또는 ghost | Verify 단계의 Routing Decision 표 cross-check 강제 |
| Case 과다 | 10건 초과 → maintenance 부담 + 비교 시간 증가 | 우선순위로 압축. 자주 발생 + 비싼 실패 case 우선 |
| Case 부족 | 1-2건만 정의 → 회귀 표면 부족 | 최소 3건 권장 — 작업 유형 다양성 확보 |
| Severity 오해 | P0-P3 어휘를 GAP report 본문 형식과 혼용 | GAP-FORMAT 은 *vocabulary borrow only* — Severity 어휘만 재사용, body schema 는 본 reference 의 case schema |
| 회고 source 부재 | 모든 case 의 source 가 단순 *예시* (PR / commit 인용 없음) | PR / commit hash 또는 회고 인용 강제. *실제 발생* 표면 확보 |
