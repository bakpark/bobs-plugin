# docs/* 트리 skeleton 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference. 흡수 source 없음 — 본 plan (Step 2, P1#4 보강) 에서 새로 작성. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

## 책임 경계

`harness-principles` §4.1 (Docs) + §4.2 (Agents — `docs/agent/roles.md`) 가 정의한 docs 트리의 6 카테고리 *skeleton* 만 다룬다:

- `docs/architecture.md`
- `docs/decisions/` (ADR 디렉토리)
- `docs/domain/`
- `docs/integrations/`
- `docs/workflows/`
- `docs/security.md`

**Skeleton 정의**: *섹션 헤더 + 각 섹션 1-2 줄 placeholder + 무엇을 채워야 하는지 안내 코멘트*. 본문 prose 자체는 작성하지 않음 — 본문은 사람 / 후속 작업.

`docs/README.md` 인덱스, `docs/agent/context-map.md`, `docs/agent/roles.md` 스켈레톤은 다른 reference 가 다룸:

- `docs/agent/context-map.md` → `context-map-write.md`
- `docs/agent/roles.md` skeleton → context-map-architecture SKILL.md Phase 1 의 role inventory 보고 후 작성 follow-up (본 reference 범위 밖)
- `docs/README.md` 인덱스 → `agents-md-write.md` Phase 1 inspect 결과로 생성 (또는 follow-up)

## Phase 1 Inspect

현재 docs 디렉토리 구조 점검:

```bash
ls <repo>/docs/ 2>/dev/null
find <repo>/docs -maxdepth 2 -type f -name "*.md" 2>/dev/null
```

수집 항목 (6 카테고리 × 존재 여부):

| 카테고리 | 경로 | 존재? | skeleton 필요? |
|---|---|---|---|
| Architecture | `docs/architecture.md` | y/n | (없으면 y) |
| Decisions | `docs/decisions/` 또는 `docs/adr/` | y/n | (없으면 y, 첫 ADR `0001-record-architecture-decisions.md` 도 함께) |
| Domain | `docs/domain/` | y/n | (없으면 y — 디렉토리 + `docs/domain/README.md`) |
| Integrations | `docs/integrations/` | y/n | (없으면 y — 디렉토리 + `docs/integrations/README.md`) |
| Workflows | `docs/workflows/` | y/n | (없으면 y — 디렉토리 + `docs/workflows/README.md`) |
| Security | `docs/security.md` 또는 `docs/security/` | y/n | (없으면 y, 단일 파일 우선) |

이미 존재하면 *본문 prose 가 있는지* 만 확인 — 있으면 skeleton 강제 덮어쓰지 않음 (follow-up 으로 보고). 빈 파일·placeholder 만 있으면 skeleton 강화 후보.

## Phase 2 Skeleton write

각 카테고리별 skeleton template. 작성 시 `<...>` placeholder 와 `<!-- TODO: ... -->` 안내 코멘트는 그대로 유지 — 사용자가 채우는 위치 표시.

### docs/architecture.md

```markdown
# Architecture

<!-- TODO: 본 문서는 시스템의 모듈·데이터흐름·외부 의존을 한 곳에서 본다.
     세부 결정 근거는 `docs/decisions/`, 도메인 규칙은 `docs/domain/`. -->

## Overview

<프로젝트가 어떤 시스템인지 1-2 단락. 입력·출력·핵심 기능.>

## Modules

<주요 모듈/디렉토리 단위로 1-2 줄씩. 책임·소유 팀.>

| Module | Path | Responsibility |
|---|---|---|
| <name> | `<path>` | <한 줄> |

## Data Flow

<요청·이벤트 흐름. 다이어그램 또는 짧은 단계 목록.>

## Dependencies

<외부 시스템 / 주요 라이브러리. 자세한 통합 절차는 `docs/integrations/` 로.>

## Build & Deploy

<빌드 / 배포 파이프라인 요약. 명령은 `AGENTS.md` 의 Quick start 참조.>
```

### docs/decisions/

디렉토리 + 첫 ADR 파일. ADR 한 개당 한 파일 패턴.

`docs/decisions/README.md`:

```markdown
# Architecture Decision Records

본 디렉토리는 ADR (Architecture Decision Record) 을 저장한다. ADR 한 개 = 한 파일.

## 파일명 규칙

`<NNNN>-<kebab-case-title>.md` — 예: `0001-record-architecture-decisions.md`.

## 작성 시점

다음 중 하나에 해당하면 ADR 작성:

- 기존 구조와 다른 접근을 채택할 때
- 명백한 후보가 둘 이상이고 선택 근거가 코드에 남지 않을 때
- 향후 되돌리기 비싼 결정 (DB 스키마, public API, 보안 모델)

## 인덱스

<!-- TODO: 새 ADR 추가 시 아래에 한 줄 추가 -->

- `0001-record-architecture-decisions.md` — ADR 도입 자체에 대한 결정
```

`docs/decisions/0001-record-architecture-decisions.md`:

```markdown
# 0001. Record architecture decisions

- **Status**: Accepted
- **Date**: <YYYY-MM-DD>

## Context

<왜 ADR 이 필요한가 — 1-2 단락. 코드에 결정 근거가 남지 않아 생긴 문제, 또는 향후 결정의 일관된 기록 필요.>

## Decision

본 프로젝트의 아키텍처 결정은 `docs/decisions/` 디렉토리에 ADR 형식으로 기록한다. 형식은 위 4 섹션 (Context / Decision / Consequences + Status/Date 메타).

## Consequences

<채택 시 trade-off — 어떤 작업이 쉬워지고 어떤 비용이 생기는지.>
```

### docs/domain/

디렉토리 + `README.md`. 도메인 규모에 따라 파일 1-N 개.

`docs/domain/README.md`:

```markdown
# Domain knowledge

본 디렉토리는 *코드에서 드러나지 않는 도메인 지식* 을 저장한다 — 용어 정의, 비즈니스 룰, 사용자 / 이해관계자 모델.

## 파일 배치

- 도메인이 작으면 본 README 한 파일에 모두.
- 도메인이 크면 영역별로 파일 분리 (`<area>.md`) — 예: `pricing.md`, `subscriptions.md`, `accounts.md`.
- 용어집은 `glossary.md` 권장.

## 작성 원칙

- *왜 그렇게 되어 있는지* 를 기록 (코드는 *무엇* 만 보여줌).
- 외부 정책 / 법규 / 계약상 제약은 출처와 함께.
- 변경 시 ADR (`docs/decisions/`) 과 cross-link.

<!-- TODO: 첫 도메인 항목 추가 -->

## Glossary

<용어 정의는 여기에 또는 별도 `glossary.md` 로>
```

### docs/integrations/

디렉토리 + `README.md`. 외부 시스템 1개당 1 파일 권장.

`docs/integrations/README.md`:

```markdown
# Integrations

본 디렉토리는 외부 시스템 연계 (API, webhook, queue, 외부 DB) 절차·계약을 저장한다.

## 파일 배치

외부 시스템 1개당 1 파일. 파일명: `<system-kebab-name>.md` — 예: `stripe.md`, `slack-webhook.md`, `internal-billing-api.md`.

## 각 파일 권장 섹션

- **Overview** — 무엇을 어떻게 연계하는지 1-2 단락
- **Authentication** — 자격증명 위치, 갱신 주기
- **API Contract** — endpoint / payload / 응답 / 에러 코드
- **Webhook / Event** — 들어오는 이벤트 종류와 처리 경로
- **Failure modes** — 흔한 실패와 복구 방법
- **Observability** — 로그·메트릭 위치

<!-- TODO: 첫 integration 파일 추가 -->
```

### docs/workflows/

디렉토리 + `README.md`. 운영 절차 1개당 1 파일.

`docs/workflows/README.md`:

```markdown
# Workflows

본 디렉토리는 *팀이 따르는 절차* 를 저장한다 — 리뷰, 릴리즈, 온콜, 인시던트 대응.

## 파일 배치

절차 1개당 1 파일. 파일명: `<workflow-kebab-name>.md` — 예: `review-process.md`, `release.md`, `oncall.md`, `incident-response.md`.

## 각 파일 권장 섹션

- **When** — 절차가 발동되는 조건
- **Roles** — 책임자 / 보조자 (이름은 `docs/agent/roles.md` 와 1:1 대응)
- **Steps** — 순서대로 단계 (각 단계 = 액터·도구·산출물)
- **Definition of Done** — 완료 조건
- **Escalation** — 막힐 때 누구에게

<!-- TODO: 첫 workflow 파일 추가 -->
```

### docs/security.md

단일 파일 (조직이 크면 `docs/security/` 디렉토리로 분리 가능).

```markdown
# Security

<!-- TODO: 본 문서는 위협 모델·권한 경계·사고 대응을 한 곳에서 본다.
     일반 코딩 규칙은 `AGENTS.md` 의 Forbidden actions 섹션 참조. -->

## Threat model

<주요 자산·공격면·신뢰 경계 — 1-2 단락.>

## Permission boundaries

<누가/무엇이 어떤 자원에 접근 가능한지. service account / 사용자 role / hook 경계.>

| Principal | Resource | Allowed | Notes |
|---|---|---|---|
| <name> | <name> | read/write | <한 줄> |

## Secret handling

<자격증명 저장 위치, 회전 주기, 노출 시 절차.>

## Incident response

<인시던트 발생 시 단계 — 차단 → 통보 → 조사 → 사후 ADR.>

## Forbidden in code

- 자격증명 commit / 로그 출력 금지
- main / master force push 금지
- 외부 서비스로 코드·데이터 전송 금지 (지정된 CI / linter 외)
- <프로젝트 한정 추가 항목>
```

## Phase 3 Effect gate

Phase 2 가 다수 파일을 새로 만들 수 있으므로 작성 *직전* 다음 4가지를 사용자에게 한 번에 제시 (CONSTITUTION §3.3 Effects Require Gates):

1. **작성할 파일 목록** — 카테고리별 절대 경로 (디렉토리 새로 만드는 것도 명시)
2. **각 파일 종류** — skeleton (placeholder + 안내 코멘트) / `README.md` 인덱스 / 첫 ADR
3. **이미 존재하는 파일 처리** — 덮어쓰기 / skip / merge 결정
4. **잔여 follow-up** — 본 reference 범위 밖 항목 (예: "본문 prose 채움", "`docs/agent/roles.md` 정의 필요")

사용자가 "진행" / "go" / "proceed" 신호를 줄 때 write. "묻지 말고 진행" 사전 합의 시 확인 없이 진행하되 위 4 항목은 응답에 기록.

write 후 즉시 verify:

- 각 파일 존재 확인 (`ls`)
- 각 파일 줄 수 합리적인가 (skeleton 은 보통 20-80 줄 — 더 길면 본문 prose 가 섞임)
- placeholder (`<...>`, `<!-- TODO: ... -->`) 가 의도된 위치에 모두 있는가

## Output Contract

caller 에게 반환:

```
files_created:
  - docs/architecture.md (skeleton, <N> lines)
  - docs/decisions/README.md (<N> lines)
  - docs/decisions/0001-record-architecture-decisions.md (<N> lines)
  - docs/domain/README.md (<N> lines)
  - docs/integrations/README.md (<N> lines)
  - docs/workflows/README.md (<N> lines)
  - docs/security.md (skeleton, <N> lines)
files_skipped:
  - <path>: <reason — 이미 본문 prose 있음 / 사용자 요청으로 제외>
follow_ups:
  - docs/architecture.md: 본문 prose 작성 필요 — Overview / Modules / Data Flow 채움
  - docs/domain/<area>.md: 첫 도메인 항목 추가
  - docs/integrations/<system>.md: 첫 통합 파일 추가
  - docs/workflows/<process>.md: 첫 절차 파일 추가
mode: applied | plan-only | no-op | blocked
```

**No-op case**: 6 카테고리가 모두 존재 + 본문 prose 가 비어있지 않음 → `mode: no-op`.

**Blocked case**: 사용자가 effect gate 에서 거부 / 대규모 기존 docs 와 충돌 → `mode: blocked` + 사유.

## 길이 / 책임 누수 점검

- skeleton 1 파일 ≈ 20-80 줄. 더 길면 본문 prose 가 섞였다는 신호 — 분리.
- `docs/architecture.md` 에 도메인 본문이 들어가면 → `docs/domain/` 으로 환원.
- `docs/architecture.md` 에 AGENTS.md 책임 (build / test 명령) 이 들어가면 → `agents-md-write.md` 의 책임으로 환원.
- ADR 한 파일이 여러 결정을 다루면 → 분할 (한 파일 = 한 결정).
- `docs/integrations/<system>.md` 에 도메인 정의가 섞이면 → `docs/domain/` 로 환원.
