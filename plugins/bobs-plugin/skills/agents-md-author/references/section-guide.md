# AGENTS.md section guide

> 각 섹션별 *포함 / 제외* 기준. 책임 누수 (다른 파일에 있어야 할 내용이 AGENTS.md 에 섞이는 것) 방지가 목적.

## Normative source

`${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.1 표 발췌:

| 문서 | 1차 독자 | 핵심 역할 | 포함할 것 | 포함하지 않을 것 |
|---|---|---|---|---|
| `README.md` | 사람·신규 참여자·에이전트 | 공개 진입점 | 프로젝트 목적, 빠른 시작, 전체 문서 링크, 주요 디렉터리 안내 | 에이전트별 행동 규칙, 긴 내부 의사결정, 도구별 프롬프트 |
| `AGENTS.md` | Codex, Claude, Gemini 등 공통 코딩 에이전트 | 작업 수행을 위한 공통 계약 | 작업 원칙, 파일 편집 규칙, 테스트/검증 명령, 문서 참조 순서, 금지 행동 | 특정 에이전트 제품 설정, 긴 철학, 상세 아키텍처 설명 |
| `CLAUDE.md` | Claude 계열 에이전트 | Claude 가 작업할 때 우선 흡수할 짧은 운용 지침 | 카파시식 간단 지침, 인간/에이전트 역할 경계, 판단 원칙, Claude 사용 시 주의점 | 프로젝트 전체 매뉴얼, 모든 컨벤션의 중복 사본, 긴 도메인 문서 |

본 스킬은 위 표의 **AGENTS.md 행** 만 다룬다.

## 섹션별 가이드

### 1. Project context

| 포함 | 제외 |
|---|---|
| 한 문단 (1-3 문장) 으로 "이 프로젝트가 무엇이고 누가 쓰는가" | 비즈니스 배경 / 회사 소개 (README) |
| 코딩 에이전트가 작업 범위를 가늠할 수 있는 도메인 키워드 | 상세 아키텍처 (`docs/architecture.md` 로) |

### 2. Quick start

| 포함 | 제외 |
|---|---|
| `setup` / `build` / `run` 명령 — 복붙 가능한 형태 | 환경 세팅 튜토리얼 (README) |
| 필수 환경 변수 이름 (값 X) | `.env` 예시 / 실제 값 |
| OS 별 차이가 있으면 명시 | 도구별 IDE 설정 |

### 3. Code editing rules

| 포함 | 제외 |
|---|---|
| 작업 원칙 (예: "요청 범위만 변경") | 일반적인 좋은 코딩 글귀 |
| 코딩 컨벤션의 *링크* 또는 *간결한 요약* | 전체 스타일 가이드 본문 (CONTRIBUTING / docs) |
| 테스트 정책 (예: "동작 변경 시 테스트 필수") | 테스트 프레임워크 사용법 |
| 공통 모듈 사용·재사용 정책 | 모듈 카탈로그 (docs) |

### 4. Verification

| 포함 | 제외 |
|---|---|
| 통과해야 할 명령 (`pnpm test`, `pnpm lint`) | 상세 CI 파이프라인 설명 (`.github/workflows/`) |
| 로컬에서 빠르게 실행할 단축 명령 | benchmark 결과 / 성능 기준 |

### 5. Document reference order

| 포함 | 제외 |
|---|---|
| 작업 유형 → 먼저 볼 문서 매핑 (표 또는 짧은 목록) | 전체 문서 인덱스 (`docs/README.md` 로 링크) |
| `docs/` 가 없으면 *없음을 명시하거나 행 삭제* | 미작성 문서의 placeholder |

### 6. Forbidden actions

| 포함 | 제외 |
|---|---|
| 최소 3개: secret 접근·force push·destructive 명령 | 일반적인 보안 가이드 (security.md) |
| 프로젝트 한정 금지 사항 (예: 특정 API 직접 호출 금지) | 위협 모델·정책 본문 (docs/security.md) |
| 우회 시 결과 (예: "CI 차단됨") | hook 구현 세부 |

### 7. Pull request expectations

| 포함 | 제외 |
|---|---|
| 제목·본문 형식 | 리뷰 프로세스 본문 (CONTRIBUTING / docs/workflows) |
| 통과해야 할 CI 작업 이름 | 워크플로우 yaml 내용 |
| 리뷰어 지정 정책 | 팀 멤버 명단 |

### 8. When in doubt

| 포함 | 제외 |
|---|---|
| escalation 경로 (1-2 줄) — 어디서 묻고 누구에게 ping | 회의 일정·연락처 |
| 추정 금지 원칙 | 길게 풀어쓴 의사결정 매뉴얼 |

## 책임 누수 점검 표

작성 중·검토 중 다음 패턴이 보이면 다른 파일로 이동한다.

| 패턴 | 이동 대상 |
|---|---|
| "Claude 는 …" / "Claude 한정 …" | `CLAUDE.md` |
| "Codex 사용 시 …" / `.codexrc` 설정 | 도구 설정 파일 |
| "이 프로젝트의 특별한 점은 …" / 회사 / 팀 소개 | `README.md` |
| 시스템 구조 / 모듈 의존 / 데이터 흐름 | `docs/architecture.md` |
| 도메인 용어 정의 / 비즈니스 룰 | `docs/domain/` |
| 외부 API 인증 / webhook 흐름 | `docs/integrations/` |
| ADR / 의사결정 근거 | `docs/decisions/` |
| 보안 정책 본문 | `docs/security.md` |
| 사람용 onboarding | `README.md`, `CONTRIBUTING.md` |

## 길이 진단

| 줄 수 | 진단 |
|---|---|
| < 50 | 명령·금지 항목이 부족할 가능성. Phase 1 inspect 결과를 다시 확인 |
| 50–100 | 가벼운 프로젝트면 정상. 큰 프로젝트면 verification·forbidden actions 보강 |
| 100–250 | 정상 범위 |
| 250–400 | 검토 신호. 책임 누수 표로 점검 |
| > 400 | 분리 필요 — `docs/` 로 빼낼 항목이 있다 |

## 도구 공통성 검증

작성 후 다음 질문:

- AGENTS.md 만 읽고 Codex / Claude / Gemini / Cursor 가 *동일하게* 작업할 수 있는가?
- 특정 도구 이름이 본문에 등장하는가? 등장한다면 그 도구만 가능한 일을 다루는가, 아니면 공통 항목인데 도구 이름이 새어든 것인가?
- 도구별 설정 파일이 따로 있어야 하는 내용을 본문이 흡수하고 있지 않은가?

위 3개 중 하나라도 "아니오 / 그렇다" 면 책임 누수.
