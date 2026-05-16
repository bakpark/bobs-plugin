---
name: context-map-builder
description: |-
  Use when authoring, scaffolding, or refreshing a project's `docs/agent/context-map.md` — the routing index that maps work types to roles, docs, skills, and hooks. Triggers on "build context map", "라우팅 표 만들어줘", "agent 라우팅 인덱스", "어떤 skill 을 언제 써야할지 정리", "context map 갱신", "harness 자원 라우팅 표". Do NOT use for deciding whether something should be a skill/agent/hook (use `agent-skill-designer` subagent), authoring the individual skill/agent/hook files (use skill-creator, agent-creator, hook-creator), AGENTS.md or CLAUDE.md (use agents-md-author, claude-md-improver), or role-definition body for `docs/agent/roles.md` (hand-edit; this skill only references roles, not defines them).
---

# context-map-builder

`docs/agent/context-map.md` 를 만들고 갱신하는 절차 스킬. context-map 은 *작업 유형 → 우선 역할 → 먼저 볼 문서 → 사용할 skill → 관여 hook* 매핑 표로, `harness-engineering` 자산 모델 §4.5 가 "에이전트 환경에서 가장 중요한 인덱스 문서" 로 규정한다.

본 스킬의 출력은 표 1개와 그 표를 읽는 방법 — 자원 자체를 만들거나 역할을 정의하지 않는다.

## When to Use

**Trigger**:
- 빈 프로젝트에 처음 context-map 을 도입할 때
- 새로운 작업 유형 (예: "외부 모델 리뷰") 이 들어와 라우팅 표 갱신이 필요할 때
- 자원 (skill / agent / hook) 이 추가·제거되어 표의 셀이 변할 때
- 라우팅이 모호해 같은 작업을 매번 다르게 처리한다는 신호가 있을 때

**When NOT to use**:
- 자원 타입 결정 (skill / agent / hook / docs 중 무엇?) → `agent-skill-designer` subagent (참고: `harness-resource-design` skill 도 동일 도메인의 reference 자료)
- 개별 skill·agent·hook *내용* 작성 → `skill-creator` / `agent-creator` / `hook-creator`
- `AGENTS.md` (도구 공통 계약) → `agents-md-author`
- `CLAUDE.md` (Claude 한정 운용 철학) → `claude-md-improver`
- `docs/agent/roles.md` 역할 *정의* — 본 스킬은 roles 의 이름을 *참조* 하지 정의 본문을 쓰지 않음
- `docs/README.md` 인덱스 / `docs/architecture.md` 등 docs 트리 일반 → `docs-architect` (도입 시) 또는 직접 편집

## Workflow

### Phase 1: Inventory & inspect

라우팅 표를 채우려면 *어떤 자원이 실제 존재하는지* 와 *어떤 작업 유형이 있는지* 두 가지를 먼저 안다.

자원 inventory — 다음을 모두 스캔한다:

```bash
ls -d <repo>/.claude/skills/*/ 2>/dev/null
ls -d <repo>/plugins/*/skills/*/ 2>/dev/null
ls ~/.claude/skills/ 2>/dev/null
ls <repo>/.claude/agents/*.md <repo>/plugins/*/agents/*.md 2>/dev/null
cat <repo>/.claude/settings.json 2>/dev/null
cat <repo>/docs/agent/roles.md 2>/dev/null
ls <repo>/docs/ 2>/dev/null
```

상세 절차는 `references/inventory-guide.md`. 각 자원에 대해 다음을 수집:

| 자원 | 수집 항목 |
|---|---|
| Skill | `name` (frontmatter), description 첫 줄, source path |
| Agent | `name`, 1차 책임, source path |
| Hook | event, matcher, script path |
| Doc | 카테고리 (architecture / decisions / domain / integrations / workflows / security), path |

작업 유형 inspect:

- 기존 `docs/agent/context-map.md` 가 있으면 먼저 읽는다 (보존 / 갱신).
- 기존 `docs/agent/roles.md` 가 있으면 정의된 역할 이름을 추출.
- 프로젝트의 실제 작업 패턴 단서:
  - `.github/workflows/` 의 트리거 이벤트
  - `.github/PULL_REQUEST_TEMPLATE.md` 의 PR 유형
  - 최근 commit 로그의 prefix (`feat:` `fix:` `refactor:` 등)
  - `CONTRIBUTING.md`
- 사용자가 명시한 작업 유형이 있으면 그것을 우선.

### Phase 2: Map

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

매핑 원칙:

- **한 행 = 한 작업 유형 = 한 의도된 라우팅 경로.** 둘 이상의 자원을 같은 셀에 콤마로 늘어놓지 않는다. 분기가 진짜 필요하면 행을 둘로 나눈다.
- **role 은 정의가 아니라 *이름* 만 인용.** 역할 본문은 `docs/agent/roles.md` 의 책임. 본 표에 없는 역할 이름을 쓰지 않는다 — 그러면 그 역할을 먼저 `roles.md` 에 추가하라고 보고한다.
- **skill / agent 선택 가이드** — 같은 작업 유형에 둘 다 있으면, 메인 컨텍스트에서 호출되는 것은 skill, 별도 컨텍스트로 격리되는 것은 agent. 양쪽 모두 호출될 수 있으면 *주 자원 → 보조 자원* 순으로 둘 다 적고 사유 1줄.
- **hook 셀은 자주 비어있다.** hook 은 결정론적 가드레일이므로 모든 작업 유형에 붙지 않는다 — 비어있는 게 정상.

### Phase 3: Effect gate & write

`docs/agent/context-map.md` 를 새로 쓰거나 수정하기 *전* 에 다음 5가지를 한 번에 제시한다 (CONSTITUTION §3.3 Effects Require Gates).

1. **작성/수정 경로**: `<repo>/docs/agent/context-map.md` 절대 경로
2. **변경 종류**: 신규 / 부분 수정 / 전체 재작성
3. **표 변경 요약**: 추가·삭제·이동되는 행과 컬럼 셀 변화
4. **자산 후보 보고**: Phase 2 에서 빈 셀로 남은 위치 — "어떤 자원을 만들면 어느 셀이 채워지는가"
5. **잔여 follow-up**: 본 스킬 범위 밖 — 예: "`docs/agent/roles.md` 에 새 역할 정의 필요", "참조한 skill `X` 가 실제로는 없음 — 작성 또는 표에서 제거 결정"

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

**Blocked case**: inventory 가 비어있거나 (자원 0개), 작업 유형이 0개라 표를 채울 수 없으면 `mode: blocked` + 사유 + 권장 단계 (예: "먼저 `agent-skill-designer` 로 첫 자원 결정").

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

## References

- `references/template.md` — context-map.md 골격 (표 헤더 + 빈 행 + 사용 안내 텍스트)
- `references/inventory-guide.md` — 자원 inventory 절차 (skill / agent / hook / doc 스캔 방법)

Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-engineering.md` §4.5 (Context Map: 구성요소를 연결하는 라우터), §4.7 (자산 선택 기준). `${CLAUDE_PLUGIN_ROOT}` 미설정 환경에서는 현재 SKILL.md 기준 `../../references/` 를 fallback 으로 사용한다 (plugin 디렉토리 구조 가정).

본 스킬은 본문에 규칙을 복사하지 않는다 — *어디서 무엇을 수집하고 어떻게 매핑·검증·기록할지* 만 정의한다.
