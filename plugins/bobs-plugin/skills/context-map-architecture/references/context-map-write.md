# context-map.md 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference. 원본은 (deprecated) `context-map-builder` skill 의 SKILL.md + references/inventory-guide.md + references/template.md 본문을 한 파일로 통합했다. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

## Normative source

`${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.5 (Context Map: 구성요소를 연결하는 라우터) + §4.7 (자산 선택 기준). context-map 은 *작업 유형 → 우선 역할 → 먼저 볼 문서 → 사용할 skill → 관여 hook* 매핑 표로, 에이전트 환경에서 가장 중요한 인덱스 문서.

본 reference 의 출력은 표 1개와 그 표를 읽는 방법 — 자원 자체를 만들거나 역할을 정의하지 않는다.

## Phase 1 Inventory

라우팅 표를 채우려면 *어떤 자원이 실제 존재하는지* 와 *어떤 작업 유형이 있는지* 두 가지를 먼저 안다.

### Skill inventory

세 곳을 스캔:

```bash
ls -d <repo>/.claude/skills/*/ 2>/dev/null
ls -d <repo>/plugins/*/skills/*/ 2>/dev/null
ls -d ~/.claude/skills/*/ 2>/dev/null
```

각 디렉토리의 `SKILL.md` frontmatter 에서 추출:

- `name` — 표에 쓸 식별자
- `description` 첫 1–2 문장 — 어떤 작업 유형에 매핑될지 추정 단서
- source path — 추적용 (표에는 path 를 적지 않고 name 만 사용)

**충돌 처리**: 동일 `name` 이 여러 scope 에 있으면 user > project > plugin 순으로 우선되는 것이 일반적이지만 환경마다 다르다. 충돌은 별도 follow-up 으로 보고만 한다 — 본 표는 우선순위가 정해지면 그 한 개만 인용.

### Agent inventory

```bash
ls <repo>/.claude/agents/*.md 2>/dev/null
ls <repo>/plugins/*/agents/*.md 2>/dev/null
ls ~/.claude/agents/*.md 2>/dev/null
```

각 `.md` 에서 frontmatter:

- `name` 또는 파일명 (without `.md`)
- `description` 첫 문장
- 1차 책임 키워드

### Hook inventory

훅은 자원 파일과 등록 두 곳을 확인:

```bash
cat <repo>/.claude/settings.json 2>/dev/null
cat ~/.claude/settings.json 2>/dev/null
ls <repo>/.claude/hooks/ 2>/dev/null
ls ~/.claude/hooks/ 2>/dev/null
```

각 hook 마다:

- event (PreToolUse / PostToolUse / UserPromptSubmit / Stop / SessionStart 등)
- matcher 패턴
- script path
- exit behavior (block / warn / no-op)

**등록되지 않은 스크립트** 는 자원 아님 — settings.json 에 없는 `.sh` 는 inventory 에서 제외하고 follow-up 으로 보고.

### Doc inventory

```bash
ls <repo>/docs/ 2>/dev/null
find <repo>/docs -maxdepth 2 -name "*.md" 2>/dev/null
```

카테고리별로 분류:

| 카테고리 | 경로 패턴 |
|---|---|
| Architecture | `docs/architecture.md`, `docs/system-design/` |
| Decisions | `docs/decisions/`, `docs/adr/` |
| Domain | `docs/domain/` |
| Integrations | `docs/integrations/` |
| Workflows | `docs/workflows/`, `docs/process/` |
| Security | `docs/security.md`, `docs/security/` |
| Agent | `docs/agent/` (roles, context-map 자신 포함) |

context-map 의 *먼저 볼 문서* 컬럼은 카테고리 단위 (`docs/integrations/`) 또는 단일 파일 (`docs/security.md`) 로 인용.

### Role inventory

`docs/agent/roles.md` 가 있으면 정의된 역할 이름을 모두 추출:

```bash
grep -E "^##? " <repo>/docs/agent/roles.md 2>/dev/null
```

표에는 이 목록에 있는 이름만 사용한다. 새 역할이 필요하면 follow-up 으로 "`roles.md` 에 추가 필요" 로 보고하고 본 표 작성은 그 행을 임시로 비워둔다.

### Inventory 보고 형식

Phase 2 진입 전 caller (사용자) 에게 다음 형식으로 보고:

```
skills (<count>):
  - <name> · <source-scope> · <one-line desc>
agents (<count>):
  ...
hooks (<count>):
  - <name> · <event> · <matcher>
docs (<count>):
  ...
roles (<count>):
  - <name>
conflicts: <count> (skill names appearing in multiple scopes)
unregistered_hook_scripts: <count>
```

이 inventory 가 표의 *모든 셀 인용 후보 풀* 이다. 표에 등장하는 자원 이름은 이 보고와 1:1 대응되어야 한다.

### 작업 유형 inspect

- 기존 `docs/agent/context-map.md` 가 있으면 먼저 읽는다 (보존 / 갱신).
- 기존 `docs/agent/roles.md` 가 있으면 정의된 역할 이름을 추출.
- 프로젝트의 실제 작업 패턴 단서:
  - `.github/workflows/` 의 트리거 이벤트
  - `.github/PULL_REQUEST_TEMPLATE.md` 의 PR 유형
  - 최근 commit 로그의 prefix (`feat:` `fix:` `refactor:` 등)
  - `CONTRIBUTING.md`
- 사용자가 명시한 작업 유형이 있으면 그것을 우선.

## Phase 2 Map

작업 유형 후보 (표준):

| 작업 유형 | 흔한 신호 |
|---|---|
| 신규 기능 구현 | `feat:` commit, "implement", spec 추가 |
| 버그 수정 | `fix:` commit, issue tracker, 회귀 테스트 |
| 리팩터·정리 | `refactor:` `chore:` commit, 동작 변경 없음 |
| PR / 코드 리뷰 | review 요청, "second opinion" |
| 외부 시스템 연계 | `integrations/`, API 호출, webhook |
| 보안·권한·credential | `.env`, key, IAM 변경 |
| 문서 / 운영 정리 | `docs:` commit, README 변경 |
| 에이전트 환경 개선 | `docs/agent/` 변경, skill/agent/hook 추가 |

프로젝트 컨텍스트에 맞춰 행을 줄이거나 늘린다. 일반적으로 6–10 행이 권장 — 너무 적으면 라우팅 가치가 없고 너무 많으면 호출자가 어느 행에 해당하는지 판단 비용이 커진다.

각 행에 대해 4개 컬럼을 채운다 — *우선 역할 / 먼저 볼 문서 / 사용할 skill / 관여 hook*. 채울 자원이 없으면 빈 칸 대신 `—` 또는 `(없음 — 자산 후보)` 표시. 빈 칸은 "이 자원을 만들면 좋겠다" 는 *작성 후보 신호* 가 된다.

### 매핑 원칙

- **한 행 = 한 작업 유형 = 한 의도된 라우팅 경로.** 둘 이상의 자원을 같은 셀에 콤마로 늘어놓지 않는다. 분기가 진짜 필요하면 행을 둘로 나눈다.
- **role 은 정의가 아니라 *이름* 만 인용.** 역할 본문은 `docs/agent/roles.md` 의 책임. 본 표에 없는 역할 이름을 쓰지 않는다 — 그러면 그 역할을 먼저 `roles.md` 에 추가하라고 보고한다.
- **skill / agent 선택 가이드** — 같은 작업 유형에 둘 다 있으면, 메인 컨텍스트에서 호출되는 것은 skill, 별도 컨텍스트로 격리되는 것은 agent. 양쪽 모두 호출될 수 있으면 *주 자원 → 보조 자원* 순으로 둘 다 적고 사유 1줄.
- **hook 셀은 자주 비어있다.** hook 은 결정론적 가드레일이므로 모든 작업 유형에 붙지 않는다 — 비어있는 게 정상.

## 표 골격 (template)

```markdown
# Context Map

이 문서는 작업 유형마다 어떤 역할·문서·skill·hook 이 관여하는지 정리한 라우팅 표다.
호출자는 표를 보고 *어디서 시작할지* 를 결정하고, 빈 셀은 *작성 후보* 로 본다.

## 라우팅 표

| 작업 유형 | 우선 역할 | 먼저 볼 문서 | 사용할 skill | 관여 hook |
|---|---|---|---|---|
| 신규 기능 구현 | planner, implementer | `AGENTS.md`, `docs/architecture.md` | feature-implementation | docs-sync-check |
| 버그 수정 | implementer, reviewer | `AGENTS.md`, 관련 테스트 | bug-investigation | task-log-capture |
| PR / 코드 리뷰 | reviewer | `docs/workflows/review-process.md`, `docs/security.md` | code-review | — |
| 외부 시스템 연계 | planner, security-auditor | `docs/integrations/`, `docs/security.md` | integration-change | secret-access-warning |
| 보안 / credential | security-auditor | `docs/security.md` | — | secret-access-warning, dangerous-command-guard |
| 문서 / 운영 정리 | doc-maintainer | `docs/README.md` | docs-sync | — |
| 에이전트 환경 개선 | agent-env-maintainer | `docs/agent/` | agent-environment-audit | task-log-capture |

빈 셀 (`—`) 은 *해당 위치에 자원이 없음* 을 의미하며, 자원을 새로 만들 후보다.

## 읽는 방법

1. 작업 시작 시 작업 유형을 식별한다.
2. 해당 행을 찾는다. 정확히 맞는 행이 없으면 가장 가까운 행을 *시작점* 으로 쓰고, 새 행이 필요한지 보고한다.
3. *우선 역할* 의 책임 정의는 `docs/agent/roles.md` 에서 확인한다.
4. *먼저 볼 문서* 를 읽고, *사용할 skill* 을 호출한다.
5. *관여 hook* 은 자동으로 동작한다 — 호출자가 의식적으로 트리거할 필요 없음.

## 갱신

- 자원 (skill / agent / hook / docs) 이 추가·삭제될 때 표를 갱신한다.
- 새 작업 유형이 반복적으로 등장하면 행을 추가한다.
- 갱신은 `context-map-architecture` 스킬로 처리한다.
```

### 빈 칸 채우는 순서

1. **자원 inventory** — Phase 1 절차로 실제 존재하는 skill / agent / hook / doc 수집
2. **작업 유형 식별** — 프로젝트 PR 패턴 / commit prefix / `.github/PULL_REQUEST_TEMPLATE.md` 참조. 6–10 행 권장
3. **역할 매핑** — `docs/agent/roles.md` 에서 정의된 역할 이름만 인용. 없는 역할은 먼저 `roles.md` 에 추가
4. **자원 매핑** — 한 셀에 콤마로 늘어놓지 말고 *주 자원* 한 개. 분기가 필요하면 행을 나눈다
5. **hook 매핑** — 결정론적 가드레일이 정말 필요한 행에만. 비어있어도 정상
6. **읽는 방법 / 갱신 단락** — 표보다 길어지지 않게 1–2 문단

## Phase 3 Effect gate

`docs/agent/context-map.md` 를 새로 쓰거나 수정하기 *전* 에 다음 5가지를 한 번에 제시한다 (CONSTITUTION §3.3 Effects Require Gates).

1. **작성/수정 경로**: `<repo>/docs/agent/context-map.md` 절대 경로
2. **변경 종류**: 신규 / 부분 수정 / 전체 재작성
3. **표 변경 요약**: 추가·삭제·이동되는 행과 컬럼 셀 변화
4. **자산 후보 보고**: Phase 2 에서 빈 셀로 남은 위치 — "어떤 자원을 만들면 어느 셀이 채워지는가"
5. **잔여 follow-up**: 본 절차 범위 밖 — 예: "`docs/agent/roles.md` 에 새 역할 정의 필요", "참조한 skill `X` 가 실제로는 없음 — 작성 또는 표에서 제거 결정"

사용자가 "진행" / "go" / "proceed" 신호를 줄 때 파일을 쓴다. "묻지 말고 진행" 이 사전 합의된 경우만 확인 없이 진행한다.

write 후 즉시 verify:

- 행 수 / 빈 셀 수 / 인용된 자원 이름이 실제 inventory 와 일치하는지 재확인
- 표 외 prose 길이가 표 자체보다 길면 prose 를 줄인다 (라우팅 인덱스는 표가 본문)

## Output Contract

caller 에게 반환:

```
file: <repo>/docs/agent/context-map.md
mode: new | partial-edit | rewrite | no-op | blocked
rows: <count>
filled_cells: <count> / <total>
empty_cells: <count>
referenced_resources:
  skills: <list of names actually used in table>
  agents: <list>
  hooks: <list>
  docs: <list>
missing_resources:
  - <work-type row> · <column>: <자원 이름 if specified else "TBD">
follow_ups:
  - docs/agent/roles.md: <추가 정의가 필요한 역할이 있다면>
  - <자원이름>: <표에 인용되지만 실제로는 없는 자원>
```

**No-op case**: 기존 context-map 이 inventory 와 일치하고 행도 적절하면 `mode: no-op`. 사용자가 명시적 갱신을 요청한 경우가 아니면 수정하지 않는다.

**Blocked case**: inventory 가 비어있거나 (자원 0개), 작업 유형이 0개라 표를 채울 수 없으면 `mode: blocked` + 사유 + 권장 단계 (예: "먼저 `resource-design` 으로 첫 자원 결정").

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Ghost reference | 표에 인용한 skill/agent 가 실제로는 없음 | inventory 와 대조해 제거하거나 작성 후보로 보고 |
| Comma soup | 한 셀에 `skill-a, skill-b, skill-c` 같이 늘어놓음 | 행을 분리하거나 *주·보조* 표기 후 사유 1줄 |
| Role drift | 표에 새 역할 이름을 슬쩍 도입 | `docs/agent/roles.md` 에 먼저 추가 후 인용 |
| Hook noise | 모든 행에 형식적으로 hook 을 넣음 | 결정론적 가드레일이 진짜 필요한 행에만 |
| Over-rowed | 20+ 행으로 라우팅 결정이 더 어려워짐 | 작업 유형을 그룹으로 묶거나 너무 세분된 행 병합 |
| Prose dump | 표 위·아래 설명이 표보다 길어짐 | 라우팅 인덱스는 *표가 본문* — prose 는 1–2 문단 |
| Stale snapshot | 자원 추가·삭제 후 표가 갱신되지 않음 | inventory diff 를 commit hook 또는 정기 작업으로 |
| Convention smuggle | 프로젝트 고유 컨벤션 / 명령을 표에 끼워넣음 | `AGENTS.md` 또는 `CLAUDE.md` 로 이동 |

## 갱신 시 diff

기존 `docs/agent/context-map.md` 가 있으면:

```bash
grep -oE '`[a-z][a-z0-9-]+`' <repo>/docs/agent/context-map.md | sort -u
```

이 목록과 새 inventory 를 비교해:

- **사라진 자원** — 표에 있지만 inventory 에 없음. 제거 또는 표시
- **새 자원** — inventory 에 있지만 표에 없음. 적절한 행에 추가 검토
- **동일** — 변경 없음

diff 결과를 Phase 3 effect gate 의 *표 변경 요약* 에 그대로 포함.

## 길이 가이드

- 표 행: 6–10 행이 권장
- 표 외 prose: 5–15 줄 — 표보다 길면 줄인다
- 행 수 < 5: 작업 유형이 너무 압축됨. 분기 신호가 있는지 확인
- 행 수 > 15: 호출자가 라우팅 판단 비용이 커짐. 그룹화 또는 병합 검토
