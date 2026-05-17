# Log Entry Write — docs/agent/logs/*.md entry 작성 절차

> 본 문서는 `evaluation-loop-runner` skill 의 reference. Phase 1 (Task Log Capture) 의 wrapper — `docs/agent/task-log-template.md` schema 따라 `docs/agent/logs/YYYY-MM-DD-<slug>.md` entry write.
> Normative source: project-side `docs/agent/task-log-template.md` (evaluation-loop-design 가 작성, schema 정의 source). 부재 시 `mode: blocked` 보고. 본 절차는 *template 적용 절차*, template 자체는 design 책임.

본 reference 가 의존하는 자원이 *project-side* (`docs/agent/task-log-template.md`) — plugin 외부. 본 reference 는 *적용 절차* 만 정의.

---

## 1. Phase 1 진입 시 inspect

```
1. ls docs/agent/task-log-template.md      # template 존재?
2. ls docs/agent/logs/                     # 로그 디렉토리 존재?
```

- template 부재 → runner 의 `mode: blocked` (Common Failures 항목 #8 따름) + needs_input ("`evaluation-loop-design` 먼저 호출 — `task-log-template-write.md`")
- 로그 디렉토리 부재 → 첫 entry write 시 lazy mkdir (`task-log-template-write.md` §보존 정책 — 디렉토리 생성은 runtime 책임 명시)

---

## 2. Entry 파일명 결정

```
docs/agent/logs/YYYY-MM-DD-<slug>.md
```

- `YYYY-MM-DD`: 작업 시작일 (ISO 8601, 사용자 timezone 기준)
- `<slug>`: 작업의 짧은 kebab-case 식별자 (예: `fix-auth-redirect`, `add-evaluation-loop-runner`)

같은 날 다중 entry → slug 로 구분. 동일 slug 가 같은 날 존재 시 `-<n>` suffix (예: `fix-auth-redirect-2`).

---

## 3. Entry write 절차 (fetch then apply)

**매 entry write 마다 `docs/agent/task-log-template.md` read → schema 그대로 적용**. schema 자체 (frontmatter 필드 / body 섹션 / 보존 정책 / append 필드) 는 design skill (`evaluation-loop-design`) 의 `task-log-template-write.md` 가 *진실 source* — 본 reference 가 본문에 재생산하지 않는다 (drift-avoidance).

최소 형식 (`docs/agent/task-log-template.md` 의 schema 갱신 시 자동 따름):
- frontmatter: yaml — design schema 의 필드 모두
- body: markdown — design schema 의 섹션 모두
- 누락 섹션은 placeholder (`<없음>`) 로 채움 (template 명시)

template 부재 시 runner 의 `mode: blocked` (Common Failures #8 따름).

---

## 4. Append 필드 — 본문 immutability

runner 의 Phase 2 + Phase 3 산출이 entry 본문 *뒤에* append. **본문은 immutable** — Edit 의 *body 영역* 수정 금지, *file 끝 append* 만.

append 필드 형식 (필드명 + 산출 source) 는 design skill 의 `task-log-template-write.md §entry schema` 진실 source. 본 reference 는 *append 위치 규약* (file 끝) 과 *immutability 강제* 만 정의:

- `Gap Analysis` append — Phase 2 의 `gap_analysis` 산출 source
- `Routing Decision` append — Phase 3 의 `routing_decision` + `next_action` 산출 source

각 필드의 sub-field 형식은 design schema 따름 — 본 reference 가 재생산 안 함.

---

## 5. 보존 정책

`docs/agent/task-log-template.md` 의 *보존 정책 섹션* 이 진실 source. 본 reference 가 재생산 안 함. 매 entry write 시 template read 로 정책 적용:
- git 추적 / append only / 길이 권장 / 비밀 redaction — 모두 template 명시 따름

runner 의 Common Failures (#7 비밀 entry 기록 / #4 append 영역 본문 침범) 가 정책 위반 안티패턴.

---

## 6. effect gate (entry write 직전)

runner 본문의 effect gate 2단계 중 2단계. User mode "묻지 말고 진행" 시 disclosure-only.

disclosure 항목 — *최소* (경로 + 작업 종류 + entry 식별자):
- 경로: `<abs path to entry>`
- 작업 종류: new / update
- task_type: `<frontmatter 값>`

추가 항목 (status / 참조 자원 / 호출 자원 / 회고 요약 등) 은 *template schema 의 필드 따라* — design source 가 갱신되면 자동 따름. 본 reference 가 항목 리스트 재생산 안 함.

User mode default (강한 gate) 시 사용자 승인 후 write. "묻지 말고 진행" 시 disclosure-only + 즉시 write.

---

## 7. 산출

본 reference 적용 완료 시 runner 의 Phase 1 산출:
- `task_log_entry`: 작성된 entry 의 *절대 경로* (runner Output Contract 의 `task_log_entry` 필드 source)

Phase 2 진입 시 본 entry 를 read 해서 `task_type` + `회고` + `실패 원인` 등을 case 비교 입력으로 사용.

---

## 8. Common Failures (runner 본문의 안티패턴 일부 — Phase 1 한정)

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| schema 불일치 | template 의 frontmatter 5 fields / body 7 sections 일부 누락 | runner 가 누락 섹션은 placeholder (`<없음>`) 로 채움 (`task-log-template-write.md` 명시) |
| 회고 누락 | entry 에 회고 섹션 없음 | 회고 한 줄 강제 — *가장 중요한 데이터* (`task-log-template-write.md` §필드별 의미) |
| 비밀 평문 기록 | API 토큰 / 자격 증명이 평문 | placeholder / redacted 표기 강제 |
| append 영역 본문 침범 | Phase 2-3 결과를 entry 본문 *안에* inline 수정 | 본문 immutable, *file 끝에 append* 만 (§4 강제) |
| lazy mkdir 누락 | `docs/agent/logs/` 부재 시 write 실패 silent | runner 가 첫 entry write 직전 `mkdir -p docs/agent/logs/` 실행 (§1 명시) |
| template read 생략 | runner 가 template read 없이 hardcoded schema 적용 | 매 entry write 마다 template read — schema 갱신 반영 + drift 방지 |
