---
name: agents-md-author
description: |-
  Use when authoring, scaffolding, refining, or auditing a project's `AGENTS.md` — the tool-common coding-agent contract read by Codex, Claude, Gemini, Cursor, and similar. Triggers on "make AGENTS.md", "create the agents file", "AGENTS.md 작성", "에이전트 계약 문서", "scaffold an AGENTS.md", "audit our AGENTS.md", "프로젝트에 AGENTS 도입". Do NOT use for CLAUDE.md (use claude-md-improver — Claude-specific brief), README or wider docs tree (hand-edit; docs-architect skill 도입 시 그쪽으로 위임), individual subagent definitions (use agent-creator), or per-tool config files (settings.json / .codexrc / .geminirc).
---

# agents-md-author

프로젝트 루트의 `AGENTS.md` 를 만들고 다듬는 절차 스킬. `AGENTS.md` 는 도구를 가리지 않는 코딩 에이전트 공통 작업 계약이다 — Codex, Claude, Gemini, Cursor 등이 작업 시 가장 먼저 읽는 파일.

핵심 책임 분리는 `harness-principles` 자산 모델 §4.1 표를 그대로 따른다:

| 파일 | 1차 독자 | 핵심 역할 |
|---|---|---|
| `README.md` | 사람·신규 참여자·에이전트 | 공개 진입점 — 프로젝트 목적, 빠른 시작, 문서 링크 |
| `AGENTS.md` | **공통 코딩 에이전트** | **작업 수행을 위한 공통 계약** |
| `CLAUDE.md` | Claude 계열 에이전트 | 짧은 운용 철학 + Claude 한정 주의점 |

본 스킬은 두 번째 행 — *공통 계약* 만 다룬다.

## When to Use

**Trigger**:
- 빈 프로젝트에 처음 `AGENTS.md` 를 도입할 때
- 기존 `AGENTS.md` 가 길거나 (>300 lines), Claude 만 가리키거나, 사람을 위한 README 와 섞여있어 정리가 필요할 때
- 새로운 코딩 에이전트 (예: Codex 추가) 가 합류해 도구 공통 계약을 명확히 해야 할 때

**When NOT to use**:
- CLAUDE.md 작성·개선 → `claude-md-improver`. CLAUDE.md 는 Claude 한정 짧은 운용 철학.
- README.md 정비 / `docs/` 구조 → `docs-architect` (예정) 또는 직접 편집. README 는 사람 진입점.
- 개별 subagent `.md` 정의 → `agent-creator`. `AGENTS.md` 는 공통 계약이고 개별 specialist 가 아니다.
- 도구별 설정 (`settings.json`, `.codexrc`, IDE 플러그인 설정) → 도구 문서 참조. `AGENTS.md` 는 도구 중립.

## Workflow

### Phase 1: Inspect

작성 *전* 에 현재 repo 상태를 점검해 중복·누락을 막는다.

읽는다:
- `<repo>/AGENTS.md` (있으면)
- `<repo>/CLAUDE.md` (있으면) — 중복 / 책임 누수 확인
- `<repo>/README.md` (있으면) — 사람 진입점과 분리 확인
- `<repo>/package.json` · `Makefile` · `justfile` · `pyproject.toml` · `Cargo.toml` 중 존재하는 것 — 실제 작업 명령 추출
- `<repo>/.github/` (있으면) — workflow / PR 템플릿
- `<repo>/docs/` 또는 `<repo>/.cursor/`, `<repo>/.claude/` 등 에이전트 관련 디렉토리

`docs/agent/context-map.md` 가 있으면 함께 읽는다 (harness 자산 모델 §4.5).

수집 항목:

| 카테고리 | 어디서 추출 | 예 |
|---|---|---|
| Build / test / lint 명령 | `package.json` scripts, Makefile, CI workflow | `pnpm test`, `make lint`, `cargo check` |
| 파일 편집 규칙 | linter config, 기존 README, 컨벤션 문서 | "한 PR 한 책임", "테스트 없이는 commit 금지" |
| 문서 참조 순서 | `docs/README.md`, 기존 인덱스 | "도메인 판단은 `docs/domain/` 먼저" |
| 금지 행동 | security 문서, hook 설정 | "`.env` 수정 금지", "force push 금지" |
| 도구 공통 작업 흐름 | CI, PR 템플릿, 회의록 | "PR 전 `pnpm verify` 실행" |

### Phase 2: Draft

골격은 `references/template.md` 의 8개 섹션을 기본으로 한다. 섹션별 *포함 / 제외* 기준은 `references/section-guide.md` 의 표를 따른다.

기본 골격:

```
# AGENTS.md
1. Project context (한 문단)
2. Quick start commands (build/test/lint/run)
3. Code editing rules
4. Verification commands (어떻게 통과를 확인하나)
5. Document reference order (어디서 정보를 찾나)
6. Forbidden actions (금지 행동)
7. Pull request expectations
8. When in doubt (escalation)
```

원칙:
- 한 섹션 = 한 책임. 각 섹션은 *어떤 작업 상황에서 이 규칙이 필요한지* 가 드러나야 한다.
- 명령은 그대로 복붙해 실행 가능해야 한다 (e.g., `pnpm test` not "run the tests").
- 한 줄 = 한 규칙. 긴 설명은 `docs/` 로 보내고 본문에는 링크.
- 톤은 명령형 (imperative). "한다 / 하지 않는다" 패턴.
- 길이 heuristic: 100–250 줄. 300 줄 초과면 reference dump 신호.

**중복 / 책임 누수 점검** — Phase 1 에서 모은 CLAUDE.md / README.md / docs 와 비교:

| 발견 | 처리 |
|---|---|
| 같은 규칙이 CLAUDE.md 에도 있다 | AGENTS.md 에 두고 CLAUDE.md 의 사본은 제거 (단일 출처) |
| Claude 한정 주의점이 AGENTS.md 에 섞여있다 | CLAUDE.md 로 이동 |
| 사람용 onboarding 문구가 들어있다 | README 로 이동 |
| 긴 아키텍처 설명이 들어있다 | `docs/architecture.md` 로 이동, 본문에는 한 줄 링크 |
| 도메인 지식이 들어있다 | `docs/domain/` 로 이동 |
| 도구별 설정 (Claude/Codex/Gemini 한정) | 각 도구 설정 파일로 이동 |

### Phase 3: Effect gate

`AGENTS.md` 를 새로 쓰거나 수정하기 *전* 에 사용자에게 다음 4가지를 한 번에 제시한다 (CONSTITUTION §3.3 Effects Require Gates).

1. **작성/수정 경로**: `<repo>/AGENTS.md` 절대 경로
2. **변경 종류**: 신규 작성 / 부분 수정 / 전체 재작성
3. **섹션 변경 요약**: 추가·제거·이동되는 섹션 목록 + 다른 파일 (CLAUDE.md / README) 에서 이동되는 항목 표
4. **잔여 follow-up**: 본 스킬 범위 밖 항목 (예: "`docs/architecture.md` 작성 필요", "CLAUDE.md 의 X 섹션 제거 권장")

사용자가 "진행" / "go" / "proceed" 같은 명시 신호를 줄 때 실제 파일을 쓴다. "묻지 말고 진행" 이 사전 합의된 경우만 확인 없이 진행한다.

write 후 즉시 verify:
- 길이 (줄 수) 와 섹션 수 보고
- Phase 1 에서 모은 명령들이 본문에 모두 들어갔는지 확인
- 다른 파일에서 옮긴 항목이 있으면 *원본에서 제거 commit 도 필요함* 을 사용자에게 보고

## Output Contract

caller (사용자 또는 상위 스킬) 에게 반환하는 형식:

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

**No-op case**: 기존 `AGENTS.md` 가 이미 적절한 책임·길이·구조를 갖추고 있고 누락된 명령·규칙이 없으면 `mode: no-op` 으로 종료하고 *변경 없음* 을 보고한다. 사용자가 명시적으로 재작성을 요청한 경우가 아니면 수정하지 않는다.

**Blocked case**: 사용자가 gate 에서 거부하거나 follow-up 이 너무 많아 단일 작성으로 처리 불가하면 `mode: blocked` + 차단 사유를 반환한다.

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

## References

- `references/template.md` — 8개 섹션 골격 (그대로 시작용으로 복사 가능)
- `references/section-guide.md` — 섹션별 포함 / 제외 기준 + harness-principles §4.1 표 발췌

Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.1 (`README.md` / `AGENTS.md` / `CLAUDE.md` 역할 분리), §5.7 (1차 MVP 생성 순서).

본 스킬은 본문에 표준 규칙을 복사하지 않는다 — *어디서 무엇을 읽고 어떻게 작성·검증할지* 만 정의한다.
