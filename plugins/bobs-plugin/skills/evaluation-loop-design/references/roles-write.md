# Roles Write — docs/agent/roles.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/roles.md` *body* (skeleton 은 `context-map-architecture` 가 seed).
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.1 (Docs 책임 — `docs/agent/`) + §4.7 (자산 선택 기준 — 작업 유형 ↔ 자원 매핑). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

`docs/agent/roles.md` 는 *작업 단위 책임* (role) 을 정의하고 자원 (skill / agent / hook / command) 에 매핑한다. role 은 *책임* 단위로 정의되며 자원-role 매핑은 1:N / N:1 / N:M 모두 허용 (1:1 강제 금지 — role inflation 안티패턴).

본 reference 는 `evaluation-loop-design` Phase 3 의 첫 단계 wrapper. skeleton 부재 시 *blocked* 로 `context-map-architecture` 호출 follow-up 보고.

---

## Phase 1: Inspect

`evaluation-loop-design` Phase 1 의 inventory 결과를 입력으로 받는다. 추가로 다음을 확인:

- `<repo>/docs/agent/roles.md` 존재 여부 + skeleton 상태 (`context-map-architecture` 가 seed 한 헤더 / placeholder)
- 자원 inventory — skill / agent / hook / command / runtime settings frontmatter / settings.json
- 기존 작업 흐름 — 자주 발생하는 작업 유형 (task log 가 있으면 frequency 통계)
- 페어 패턴 확인 — `harness-principles.md` §4.7 의 *역할 쌍* 표 (예: implementer ↔ reviewer / planner ↔ implementer / agent-env-maintainer 단독)

skeleton 부재 (`docs/agent/roles.md` 자체가 없음) 시 본 reference 진행 *불가* — `evaluation-loop-design` Output Contract 의 `mode: needs_input` + `category: inventory` 로 보고:

```
mode: needs_input
category: inventory
items:
  - docs/agent/roles.md skeleton 부재 — context-map-architecture 먼저 호출
```

---

## Phase 2: Draft

`docs/agent/roles.md` body template:

```markdown
# Roles

> Skeleton seed: context-map-architecture
> Body author: evaluation-loop-design
> Date: <iso8601>

본 문서는 프로젝트의 *작업 단위 책임* (role) 을 정의한다. role 은 자원 (skill / agent / hook / command) 호출 패턴의 명세이며, 자원-role 매핑은 1:N / N:1 / N:M 가능.

## Role 목록

각 role 은 한 줄 책임 + 페어 (해당 role 과 함께 호출되는 다른 role) + 입력 / 산출 / 실패 표면 4가지를 정의.

### <role-name>

**책임**: <한 줄 — 동사 + 명사 + 결과>
**페어**: <함께 호출되는 role 또는 *없음* (단독)>
**입력**: <자원 / 문서 / 사용자 발화>
**산출**: <파일 / 응답 / commit / log entry>
**실패 표면**: <어떤 조건에서 실패로 정의되는지 — golden-set 의 PASS 정의 source>
**호출 자원**: <skill / agent / hook / command 이름 — 1:N 매핑>

---

(이하 각 role 별 동일 형식 반복)
```

template 작성 가이드:

1. **role 발견** — 자원 inventory + 작업 흐름에서 추출. 자원이 *어떤 책임* 을 수행하는지 자원-책임 그래프 그림. 같은 책임을 수행하는 자원은 한 role 로 묶음.
2. **페어 매핑** — `harness-principles.md` §4.7 사례 표 인용. 예시 페어:
   - implementer ↔ reviewer (구현 + 검토)
   - planner ↔ implementer (계획 + 실행)
   - bug-investigator ↔ implementer (조사 + 수정)
   - agent-env-maintainer (환경 개선, 단독)
   - context-map-curator ↔ docs-author (인덱싱 + 본문)
3. **실패 표면** — golden-set 의 PASS / no-op / blocked 정의 source. role 마다 어떤 조건이 실패인지 (예: implementer 의 실패 = 테스트 미통과, reviewer 의 실패 = P0 finding 누락) 명시.
4. **호출 자원** — 자원 이름을 *frontmatter name* 또는 *settings.json hook 명* 으로 정확히 인용 (ghost reference 회피).

골격 위주 작성 — body 가 본문 prose 로 늘어지면 *Body-prose drift* 안티패턴 (context-map-architecture 와 동일). role 정의는 표 + bullet 위주.

---

## Phase 3: Effect Gate

본 reference 가 호출되어 `docs/agent/roles.md` 를 write 직전, 다음을 한 묶음으로 caller (`evaluation-loop-design` Phase 3) 에게 disclose:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `<repo>/docs/agent/roles.md` (절대 경로) |
| 작업 종류 | new body (skeleton 만 있던 파일에 body 채움) 또는 update (기존 body 갱신) |
| role 수 | <N> 개 |
| 페어 매핑 요약 | <role-A ↔ role-B>, <role-C 단독>, ... |
| 자원 매핑 요약 | skill <n>개 / agent <n>개 / hook <n>개 / command <n>개 (자원-role 매핑 표) |
| 변경 영향 | golden-set 의 PASS 정의 source 갱신 → 후속 `golden-set-write.md` 진입 시 case 검토 필요 |

"진행" / "go" / "proceed" 신호 시 write. "묻지 말고 진행" 모드는 disclosure-only.

---

## Verify (write 후 즉시)

- role 수 ≥ 1 (skeleton 만 있던 상태 → body 채움 확인)
- 모든 role 의 4 필드 (책임 / 페어 / 입력 / 산출 / 실패 표면 / 호출 자원) 채워짐 — placeholder `<...>` 잔존 없음
- 호출 자원 이름이 실제 inventory 와 일치 (ghost reference 검사: `grep -E "skill|agent|hook|command" docs/agent/roles.md | <inventory 와 cross-check>`)
- role 이 자원 1:1 매핑으로만 정의되지 않음 (role inflation 검사)

---

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Role inflation | 자원 수만큼 role 정의 (자원-role 1:1 매핑 강제) | role 은 *책임* 단위. 한 role 이 여러 자원 호출 (1:N) 또는 N:1 허용 |
| Skeleton 가정 위반 | `context-map-architecture` 가 seed 하지 않은 상태에서 본 reference 가 처음부터 파일 생성 | Phase 1 에서 needs_input (category: inventory) 로 보고. ownership 분리 — skeleton = context-map-architecture, body = evaluation-loop-design |
| 페어 없는 role 만 정의 | 모든 role 이 *단독* 으로 표기 | `harness-principles.md` §4.7 사례 표 인용. 페어 패턴이 실제 작업 흐름의 base |
| 실패 표면 누락 | role 정의에 *어떤 조건이 실패인지* 없음 | golden-set 의 PASS 정의 source 부재 — golden-set-write.md 가 case 정의 불가 |
| Ghost reference | role 이 인용하는 자원이 실제 inventory 에 없음 | Verify 단계의 cross-check 강제. inventory 갱신 또는 role 에서 제거 |
| Body-prose drift | role 정의가 표 대신 prose 단락으로 늘어남 | body 는 표 + bullet 위주. 한 role 당 5-10 lines 권장 |
