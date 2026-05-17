# AGENTS.md 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference. 원본은 (deprecated) `agents-md-author` skill 의 SKILL.md + references/section-guide.md + references/template.md 본문을 한 파일로 통합했다. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

## Normative source

`${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.1 표 발췌 — 본 reference 는 *AGENTS.md 행* 만 다룬다.

| 문서 | 1차 독자 | 핵심 역할 | 포함할 것 | 포함하지 않을 것 |
|---|---|---|---|---|
| `README.md` | 사람·신규 참여자·에이전트 | 공개 진입점 | 프로젝트 목적, 빠른 시작, 전체 문서 링크, 주요 디렉터리 안내 | 에이전트별 행동 규칙, 긴 내부 의사결정, 도구별 프롬프트 |
| `AGENTS.md` | Codex / Claude / Gemini 등 공통 코딩 에이전트 | 작업 수행을 위한 공통 계약 | 작업 원칙, 파일 편집 규칙, 테스트/검증 명령, 문서 참조 순서, 금지 행동 | 특정 에이전트 제품 설정, 긴 철학, 상세 아키텍처 설명 |
| `CLAUDE.md` | Claude 계열 에이전트 | Claude 가 작업할 때 우선 흡수할 짧은 운용 지침 | 카파시식 간단 지침, 인간/에이전트 역할 경계, 판단 원칙, Claude 사용 시 주의점 | 프로젝트 전체 매뉴얼, 모든 컨벤션의 중복 사본, 긴 도메인 문서 |

본 reference 가 다루는 책임: 두 번째 행 — *공통 계약* 만.

## Phase 1 Inspect

작성 *전* 에 현재 repo 상태를 점검해 중복·누락을 막는다.

읽는다:

- `<repo>/AGENTS.md` (있으면)
- `<repo>/CLAUDE.md` (있으면) — 중복 / 책임 누수 확인
- `<repo>/README.md` (있으면) — 사람 진입점과 분리 확인
- `<repo>/package.json` · `Makefile` · `justfile` · `pyproject.toml` · `Cargo.toml` 중 존재하는 것 — 실제 작업 명령 추출
- `<repo>/.github/` (있으면) — workflow / PR 템플릿
- `<repo>/docs/` 또는 `<repo>/.cursor/` · `<repo>/.claude/` 등 에이전트 관련 디렉토리
- `docs/agent/context-map.md` (있으면 — harness 자산 모델 §4.5)

수집 항목:

| 카테고리 | 어디서 추출 | 예 |
|---|---|---|
| Build / test / lint 명령 | `package.json` scripts, Makefile, CI workflow | `pnpm test`, `make lint`, `cargo check` |
| 파일 편집 규칙 | linter config, 기존 README, 컨벤션 문서 | "한 PR 한 책임", "테스트 없이는 commit 금지" |
| 문서 참조 순서 | `docs/README.md`, 기존 인덱스 | "도메인 판단은 `docs/domain/` 먼저" |
| 금지 행동 | security 문서, hook 설정 | "`.env` 수정 금지", "force push 금지" |
| 도구 공통 작업 흐름 | CI, PR 템플릿, 회의록 | "PR 전 `pnpm verify` 실행" |

## Phase 2 Draft

골격은 아래 8-section template 을 기본으로 한다. 섹션별 *포함 / 제외* 기준은 §섹션별 가이드 표를 따른다.

### 8-section 골격 (template)

```markdown
# AGENTS.md

## Project context

<프로젝트가 무엇인지 1-3 문장. 도메인 / 사용자 / 핵심 흐름. 긴 설명은 `docs/` 로.>

## Quick start

```bash
<setup 명령 — 예: pnpm install>
<build 명령 — 예: pnpm build>
<run 명령 — 예: pnpm dev>
```

## Verification

작업 후 다음을 통과해야 한다:

```bash
<test 명령 — 예: pnpm test>
<lint 명령 — 예: pnpm lint>
<typecheck — 예: pnpm typecheck>
```

CI 가 추가로 실행하는 항목은 `.github/workflows/` 참조.

## Code editing rules

- 작업 시작 전 기존 코드를 먼저 읽는다.
- 요청 범위만 변경한다 — 무관한 리팩터·주석 추가·기능 확장 금지.
- <프로젝트 컨벤션 1>
- <프로젝트 컨벤션 2>
- <테스트 정책>

## Document reference order

작업 유형별 첫 참조:

| 작업 | 먼저 볼 문서 |
|---|---|
| 신규 기능 | `docs/architecture.md`, 관련 spec |
| 버그 수정 | 관련 테스트, `docs/decisions/` |
| 외부 연계 | `docs/integrations/`, `docs/security.md` |
| 도메인 판단 | `docs/domain/` |

## Forbidden actions

- `.env`, credential 파일 commit / 출력 금지
- main / master 에 force push 금지
- `git reset --hard`, `rm -rf` 등 destructive 명령은 사용자 명시 승인 후에만
- 외부 서비스로 코드·데이터 전송 금지 (지정된 CI / linter 외)
- <프로젝트 한정 금지 사항>

## Pull request expectations

- PR 제목: <컨벤션 예: `<type>(<scope>): <subject>`>
- 본문: 변경 요약 + 테스트 방법
- 통과해야 할 CI 작업: <목록>
- 리뷰어 지정: <팀 정책>

## When in doubt

- 의사결정 근거가 필요하면 `docs/decisions/` 확인
- 컨벤션이 불분명하면 가장 가까운 기존 코드를 따른다
- 그래도 모호하면 PR 또는 이슈로 묻는다 — 추정으로 진행하지 않는다
```

### 작성 원칙

- 한 섹션 = 한 책임. 각 섹션은 *어떤 작업 상황에서 이 규칙이 필요한지* 가 드러나야 한다.
- 명령은 그대로 복붙해 실행 가능해야 한다 (e.g., `pnpm test` not "run the tests").
- 한 줄 = 한 규칙. 긴 설명은 `docs/` 로 보내고 본문에는 링크.
- 톤은 명령형 (imperative). "한다 / 하지 않는다" 패턴.
- 길이 heuristic: 100–250 줄. 300 줄 초과면 reference dump 신호.

### 빈 칸 채우는 순서

1. **Quick start / Verification 명령** — `package.json` scripts, Makefile, CI yaml 에서 그대로 복사
2. **Document reference order** — `docs/` 디렉토리 매핑, 없으면 작성 후 채움 (또는 행 자체 삭제)
3. **Forbidden actions** — 최소 3개: secret 접근 / force push / destructive 명령
4. **Project context** — 한 문단. 긴 설명은 README · `docs/architecture.md` 로
5. **Code editing rules / PR expectations** — `CONTRIBUTING.md` 또는 PR 템플릿 발췌

## 섹션별 가이드 (포함 / 제외)

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

## 책임 누수 점검

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

작성 후 *중복 / 책임 누수 점검* — Phase 1 에서 모은 CLAUDE.md / README.md / docs 와 비교:

| 발견 | 처리 |
|---|---|
| 같은 규칙이 CLAUDE.md 에도 있다 | AGENTS.md 에 두고 CLAUDE.md 의 사본은 제거 (단일 출처) |
| Claude 한정 주의점이 AGENTS.md 에 섞여있다 | CLAUDE.md 로 이동 |
| 사람용 onboarding 문구가 들어있다 | README 로 이동 |
| 긴 아키텍처 설명이 들어있다 | `docs/architecture.md` 로 이동, 본문에는 한 줄 링크 |
| 도메인 지식이 들어있다 | `docs/domain/` 로 이동 |
| 도구별 설정 (Claude/Codex/Gemini 한정) | 각 도구 설정 파일로 이동 |

## Phase 3 Effect gate

`AGENTS.md` 를 새로 쓰거나 수정하기 *전* 에 사용자에게 다음 4가지를 한 번에 제시한다 (CONSTITUTION §3.3 Effects Require Gates).

1. **작성/수정 경로**: `<repo>/AGENTS.md` 절대 경로
2. **변경 종류**: 신규 작성 / 부분 수정 / 전체 재작성
3. **섹션 변경 요약**: 추가·제거·이동되는 섹션 목록 + 다른 파일 (CLAUDE.md / README) 에서 이동되는 항목 표
4. **잔여 follow-up**: 본 절차 범위 밖 항목 (예: "`docs/architecture.md` 작성 필요", "CLAUDE.md 의 X 섹션 제거 권장")

사용자가 "진행" / "go" / "proceed" 같은 명시 신호를 줄 때 실제 파일을 쓴다. "묻지 말고 진행" 이 사전 합의된 경우만 확인 없이 진행한다.

write 후 즉시 verify:

- 길이 (줄 수) 와 섹션 수 보고
- Phase 1 에서 모은 명령들이 본문에 모두 들어갔는지 확인
- 다른 파일에서 옮긴 항목이 있으면 *원본에서 제거 commit 도 필요함* 을 사용자에게 보고

## Output Contract

caller 에게 반환:

```
file: <repo>/AGENTS.md
mode: new | partial-edit | rewrite
sections: <count> (<list>)
lines: <count>
moved_from:
  - <source-file>: <항목 요약>
follow_ups:
  - <repo>/CLAUDE.md: <제거 권장 섹션>
  - <repo>/README.md: <이동 권장 섹션>
  - docs/<file>: <신규 작성 권장>
duplication_report: <중복 발견 / 없음>
```

**No-op case**: 기존 `AGENTS.md` 가 이미 적절한 책임·길이·구조를 갖추고 있고 누락된 명령·규칙이 없으면 `mode: no-op` 으로 종료. 사용자가 명시적 재작성을 요청한 경우가 아니면 수정하지 않는다.

**Blocked case**: 사용자가 gate 에서 거부하거나 follow-up 이 너무 많아 단일 작성으로 처리 불가하면 `mode: blocked` + 차단 사유.

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Claude-only AGENTS | "Claude 가 …" 문장이 다수 | Claude 한정 항목은 CLAUDE.md 로, 공통 항목만 남긴다 |
| README clone | 프로젝트 소개·설치법이 본문 절반 | README 로 이동, AGENTS.md 는 한 줄 링크 |
| Architecture dump | 시스템 구조 / 도메인 설명이 길게 들어있음 | `docs/architecture.md` 로 이동 |
| No commands | "테스트하고 빌드해라" 같은 추상 지시만 있음 | 실제 명령 (`pnpm test`) 복붙 가능하게 |
| Per-tool config leak | `.codexrc` / `settings.json` 내용이 본문에 | 도구 설정 파일로 이동 |
| Reference dump | 가이드라인을 단락 단위로 인용 | 핵심 규칙 한 줄 + `docs/` 링크 |
| Stale commands | 더 이상 동작하지 않는 명령이 남아있음 | Phase 1 의 실제 manifest 와 대조해 갱신 |
| Missing forbidden actions | 금지 행동이 비어있다 | 최소한 secret 접근·force push·destructive 명령 3가지는 명시 |

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
