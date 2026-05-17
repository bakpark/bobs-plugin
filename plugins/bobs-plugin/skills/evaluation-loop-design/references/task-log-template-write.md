# Task Log Template Write — docs/agent/task-log-template.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/task-log-template.md`.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` (line 294 — task-log-capture pair + line 381 — task log 가 `evaluation-loop.md` 의 입력). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

`docs/agent/task-log-template.md` 는 *작업 종료 시 캡처할 entry 의 schema* — evaluation-loop 사이클 단계 #1 의 산출 형식. runtime (`evaluation-loop-runner` skill — `${CLAUDE_PLUGIN_ROOT}/skills/evaluation-loop-runner/`, Step 5 완료 — 2026-05-17 시점 존재 확정) 이 본 template 을 따라 `docs/agent/logs/YYYY-MM-DD-*.md` 를 생성. runner 미호출 시 본 template 은 *수동* 사용 가능 (사용자가 직접 entry 작성).

본 reference 는 `evaluation-loop-design` Phase 3 의 *첫 단계* wrapper. 다른 자산 (roles / golden-set / evaluation-loop) 이 본 template 의 entry schema 를 인용 — 의존성 root.

---

## Phase 1: Inspect

`evaluation-loop-design` Phase 1 의 inventory 결과를 입력으로 받는다. 추가로 다음을 확인:

- `<repo>/docs/agent/task-log-template.md` 존재 여부 + 기존 schema
- `<repo>/docs/agent/logs/` 디렉토리 존재 여부 + entry 수
- 기존 task log entry 가 있다면 schema drift 진단 (필드 누락 / 추가 / 형식 불일치)
- 현재 PR / commit / 회고가 어디 기록되는지 — 보존 위치 식별 (`docs/agent/logs/` vs PR description vs 외부 위키)

`docs/agent/logs/` 디렉토리 생성 책임:
- 본 reference 는 *template 명세* 만 작성 — 디렉토리 생성은 *runtime* (`evaluation-loop-runner`) 이 첫 entry write 시 mkdir
- 디렉토리 미존재 자체는 blocked 아님 — runtime 이 lazy create

---

## Phase 2: Draft

`docs/agent/task-log-template.md` template:

````markdown
# Task Log Template

> Author: evaluation-loop-design
> Date: <iso8601>
> Used by: evaluation-loop.md 사이클 단계 #1 (task log 캡처)
> Runtime executor: evaluation-loop-runner (planned — 본 template 을 따라 logs/ 에 entry write)

본 문서는 `docs/agent/logs/YYYY-MM-DD-<slug>.md` entry 의 schema. runtime 이 본 template 을 따라 entry 생성.

## 파일명 규칙

```
docs/agent/logs/YYYY-MM-DD-<slug>.md
```

- `YYYY-MM-DD`: 작업 시작일 (ISO 8601, 사용자 timezone)
- `<slug>`: 작업의 짧은 kebab-case 식별자 (예: `fix-auth-redirect`, `add-evaluation-loop`)

같은 날 다중 entry 시 slug 로 구분.

## Entry schema

```markdown
---
date: <YYYY-MM-DDTHH:MM:SS+TZ>
task_type: <golden-set case ID 또는 free-form>
duration_minutes: <int 또는 unknown>
status: completed | partial | aborted
---

# <작업 제목 한 줄>

## 참조 문서
- <docs / commits / PR 링크>

## 실행 명령
```bash
<주요 실행 명령 — 최대 10 줄>
```

## 호출 자원
- <skill / agent / hook / command 이름 + 회수>

## 산출
- <commit hash + 메시지 한 줄>
- <PR 번호 + 제목>
- <생성/수정 파일 목록>

## 실패 원인 (있다면)
- <한 줄 — 어디서 어떻게 실패>
- <근본 원인 — 인접 자원 / 가이드 / 환경 어느 쪽>

## 회고 (한 줄)
<왜 이렇게 했는가 / 다음에 무엇이 달라져야 하는가 — 가장 중요한 데이터>

## Gap Analysis (사이클 단계 #2 후 append)
<case ID>: <PASS/FAIL/no-op/blocked/needs_input>
<...>

## Routing Decision (사이클 단계 #3 후 append)
target: <design skill name 또는 no-op>
rationale: <gap 분석 결과 한 줄>
```

## 필드별 의미

| 필드 | 의미 | golden-set 연결 |
|---|---|---|
| `task_type` | golden-set case ID (있다면) 또는 free-form 작업 유형 | case 비교의 매핑 키 — free-form 이면 case 후보 |
| `duration_minutes` | 작업 소요 시간 | 효율 회귀 검출 (case 의 *시간 한도* 표면) |
| `status` | completed / partial / aborted | partial / aborted 면 자동 FAIL 후보 |
| `참조 문서` | 작업 중 읽은 docs / commit / PR | ghost reference 검출 (인용한 자원이 inventory 에 있는지) |
| `실행 명령` | 주요 명령 (최대 10 줄) | 재현성 — 사이클이 *재현 불가* 면 자동 blocked |
| `호출 자원` | 자원 이름 + 회수 | role 매핑 갱신 source (자원이 자주 호출되면 role 후보) |
| `실패 원인` | 한 줄 + 근본 원인 위치 | gap 분석의 *어느 자원 갱신* 결정 source |
| `회고` | 한 줄 — 다음 회 차이점 | *가장 중요한 데이터*. golden-set case 갱신의 source |
| `Gap Analysis` / `Routing Decision` | append 필드 — runtime 이 사이클 단계 #2-#3 후 추가 | evaluation-loop.md 의 사이클 단계 결과 보존 |

## 보존 정책

- `docs/agent/logs/` 디렉토리는 git 추적 (`.gitignore` 제외) — entry 가 *재현 가능한 사이클 데이터* 의 source
- entry 파일은 *append only* — 사이클 단계 #2-#3 결과만 append, 본문은 immutable
- entry 길이 권장: 50-300 lines. 300 줄 초과 시 회고 흡수 어려움 — 작업 분할 신호
- 비밀 / 자격 증명 / 외부 토큰은 entry 에 직접 기록 금지 — placeholder 또는 redacted 표기

## golden-set 과의 연결

각 entry 의 `task_type` 이 golden-set case ID 면 사이클 단계 #2 가 case 비교 수행. free-form 이면:

1. evaluation-loop runner 가 작업 유형 빈도 누적 → N=3 초과 시 golden-set-write.md 갱신 follow-up
2. *비싼 실패* (회고에 *비싼* 표기) 발생 시 즉시 golden-set case 후보로 표기
3. 누적된 entry 가 골든셋 갱신 round 의 source — `evaluation-loop-design` 재진입 trigger
````

template 작성 가이드:

1. **frontmatter (YAML)** 5필드 (`date` / `task_type` / `duration_minutes` / `status` / 추가 free-form) — runtime 이 mechanically 파싱 가능.
2. **본문 7섹션 (참조 / 실행 / 호출 / 산출 / 실패 / 회고 / append 필드)** — 누락된 섹션은 runtime 이 placeholder 로 채움 (`<없음>`).
3. **회고는 한 줄** — 길어지면 회고 흡수 어려움. *왜 + 다음 회 차이점* 만.
4. **append 필드 분리** — `Gap Analysis` / `Routing Decision` 은 runtime 이 사이클 단계 #2-#3 후 추가. 본문은 immutable.
5. **보존 정책** 명시 — git 추적 / append only / 길이 권장 / 비밀 금지 4종.
6. **golden-set 연결** 명시 — entry 가 case 갱신의 source 임을 명시. free-form `task_type` 이 누적되어 case 후보 발견.

---

## Phase 3: Effect Gate

본 reference 가 호출되어 `docs/agent/task-log-template.md` 를 write 직전, 다음을 한 묶음으로 caller 에게 disclose:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `<repo>/docs/agent/task-log-template.md` (절대 경로) |
| 작업 종류 | new (없던 파일) 또는 update (기존 schema 갱신) |
| frontmatter 필드 수 | 5 (date / task_type / duration_minutes / status / +free-form) |
| 본문 섹션 수 | 7 (참조 / 실행 / 호출 / 산출 / 실패 / 회고 / append) |
| 보존 정책 명시 | git 추적 + append only + 길이 권장 + 비밀 금지 4종 |
| golden-set 연결 명시 | task_type ↔ case ID 매핑 + 자유형 누적 → case 후보 표시 |

"진행" / "go" / "proceed" 신호 시 write. "묻지 말고 진행" 모드는 disclosure-only.

---

## Verify (write 후 즉시)

- frontmatter 5필드 + 본문 7섹션 모두 정의
- 파일명 규칙 (`YYYY-MM-DD-<slug>.md`) 명시
- 보존 정책 4종 모두 명시
- golden-set 과의 연결 명시 (task_type 매핑 + 누적 갱신 절차)
- 기존 entry 가 있다면 schema drift 검사 — 본 template 과 일치하지 않으면 마이그레이션 follow-up 표기

---

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Schema 일관성 부재 | entry 마다 필드 누락 / 추가 / 형식 불일치 | template 의 frontmatter + 본문 7섹션 강제. runtime 이 누락 섹션은 placeholder 로 채움 |
| 회고 누락 | entry 에 회고 섹션 없음 → *왜* 데이터 손실 | 회고 한 줄 강제 — 가장 중요한 데이터 (golden-set 갱신 source) |
| Golden-set 무관 log | task_type 이 free-form 만, 누적·갱신 절차 없음 | task_type 누적 빈도 추적 + N=3 초과 시 case 후보 표기 (golden-set-write.md follow-up) |
| 너무 긴 entry | 300 줄 초과 → 회고 흡수 어려움 | 작업 분할 신호. 길이 권장 50-300 명시 |
| 비밀 직접 기록 | API 토큰 / 자격 증명 / 외부 비밀이 entry 에 평문 | placeholder / redacted 표기 강제. 보존 정책 4종 중 *비밀 금지* 명시 |
| 디렉토리 생성 책임 혼동 | 본 reference 가 `docs/agent/logs/` 디렉토리 생성 시도 | template 명세만 작성. 디렉토리 mkdir 은 runtime 이 첫 entry write 시 lazy create |
| Append 필드 충돌 | 본문이 immutable 인데 사이클 단계 #2-#3 결과가 본문 안에 inline 수정 | append 필드 (`Gap Analysis` / `Routing Decision`) 분리 강제. 본문은 immutable |
| 재현 명령 누락 | `실행 명령` 섹션 없음 → 사이클이 *재현 불가* 자동 blocked | 실행 명령 (최대 10 줄) 강제. 재현성이 evaluation-loop 의 base |
