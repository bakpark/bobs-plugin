# Inventory guide

> `context-map-builder` Phase 1 에서 사용할 자원 수집 절차. 모든 자원은 *현재 repo + 사용자 설정* 양쪽을 스캔한다. 누락된 자원이 표에 인용되면 ghost reference 가 되므로 절차를 그대로 따른다.

## Skill inventory

세 곳을 스캔:

```bash
# 1. project-level
ls -d <repo>/.claude/skills/*/ 2>/dev/null

# 2. plugin-level (bundle 된 skill)
ls -d <repo>/plugins/*/skills/*/ 2>/dev/null

# 3. user-level (모든 프로젝트 공통)
ls -d ~/.claude/skills/*/ 2>/dev/null
```

각 디렉토리의 `SKILL.md` frontmatter 에서 다음 추출:

- `name` — 표에 쓸 식별자
- `description` 첫 1–2 문장 — 어떤 작업 유형에 매핑될지 추정 단서
- source path — 추적용 (표에는 path 를 적지 않고 name 만 사용)

**충돌 처리**: 동일 `name` 이 여러 scope 에 있으면 user > project > plugin 순으로 우선되는 것이 일반적이지만 환경마다 다르다. 충돌은 별도 follow-up 으로 보고만 한다 — 본 표는 우선순위가 정해지면 그 한 개만 인용.

## Agent inventory

```bash
ls <repo>/.claude/agents/*.md 2>/dev/null
ls <repo>/plugins/*/agents/*.md 2>/dev/null
ls ~/.claude/agents/*.md 2>/dev/null
```

각 `.md` 에서 frontmatter:

- `name` 또는 파일명 (without `.md`)
- `description` 첫 문장
- 1차 책임 키워드

## Hook inventory

훅은 자원 파일과 등록 두 곳을 확인:

```bash
# 등록
cat <repo>/.claude/settings.json 2>/dev/null
cat ~/.claude/settings.json 2>/dev/null

# 스크립트
ls <repo>/.claude/hooks/ 2>/dev/null
ls ~/.claude/hooks/ 2>/dev/null
```

각 hook 마다:

- event (PreToolUse / PostToolUse / UserPromptSubmit / Stop / SessionStart 등)
- matcher 패턴
- script path
- exit behavior (block / warn / no-op)

**등록되지 않은 스크립트** 는 자원 아님 — settings.json 에 없는 `.sh` 는 inventory 에서 제외하고 follow-up 으로 보고.

## Doc inventory

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

## Role inventory

`docs/agent/roles.md` 가 있으면 정의된 역할 이름을 모두 추출:

```bash
grep -E "^##? " <repo>/docs/agent/roles.md 2>/dev/null
```

표에는 이 목록에 있는 이름만 사용한다. 새 역할이 필요하면 follow-up 으로 "`roles.md` 에 추가 필요" 로 보고하고 본 표 작성은 그 행을 임시로 비워둔다.

## Inventory 보고 형식

Phase 2 진입 전 caller (사용자) 에게 다음 형식으로 보고:

```
skills (<count>):
  - <name> · <source-scope> · <one-line desc>
  ...
agents (<count>):
  ...
hooks (<count>):
  - <name> · <event> · <matcher>
  ...
docs (<count>):
  ...
roles (<count>):
  - <name>
  ...
conflicts: <count> (skill names appearing in multiple scopes)
unregistered_hook_scripts: <count>
```

이 inventory 가 표의 *모든 셀 인용 후보 풀* 이다. 표에 등장하는 자원 이름은 이 보고와 1:1 대응되어야 한다.

## 갱신 시 diff

기존 `docs/agent/context-map.md` 가 있으면:

```bash
# 표에서 인용되는 자원 이름 추출
grep -oE '`[a-z][a-z0-9-]+`' <repo>/docs/agent/context-map.md | sort -u
```

이 목록과 새 inventory 를 비교해:

- **사라진 자원** — 표에 있지만 inventory 에 없음. 제거 또는 표시
- **새 자원** — inventory 에 있지만 표에 없음. 적절한 행에 추가 검토
- **동일** — 변경 없음

diff 결과를 Phase 3 effect gate 의 *표 변경 요약* 에 그대로 포함.
