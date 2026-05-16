# GUIDE Rule Map

원본: `${CLAUDE_PLUGIN_ROOT}/references/agent-skill-best-practices-GUIDE.md` (snapshot — refresh by re-copying from research source and bumping plugin version).

이 파일은 설계 시 자주 쓰는 규칙만 압축한다. 원문과 충돌하면 원문이 우선한다.

## Constitution

- C1: 자동화는 Hooks / Subagents / Skills / Plugins / MCP Servers 로 분리한다.
- C2: 카테고리당 1-2개 권고를 기본으로 한다.
- C3: 스킬 invocation 은 User+Claude, User-only, Claude-only 로 통제한다.
- C4: 에이전트 tools/model 은 능력에 맞게 축소한다. sonnet 기본, opus 는 복잡 추론.

## Skill Rules

MUST:
- `name`, `description` 필수. `name` 은 kebab-case. (S-M1, S-M2)
- description 은 언제 쓸지 말한다. workflow 요약을 넣지 않는다. (S-M3, S-X1)
- 부수 효과가 있으면 `disable-model-invocation: true`. (S-M5)
- Claude-only 배경 지식은 `user-invocable: false`. (S-M6)
- 500 lines 초과 시 references 로 분리한다. (S-M7)

SHOULD:
- description 은 "Use when ..." 또는 동치 트리거로 시작. (S-S1)
- When to use / When NOT to use 를 분명히 한다. (S-S2)
- 본문은 가능한 짧게 두고 상세 규칙은 references 로 이동한다. (S-S3)

## Agent Rules

MUST:
- frontmatter 에 `name`, `description`, `model`. (A-M1)
- description 은 호출 조건과 negative case 를 포함한다. (A-M2, A-M3)
- 본문은 페르소나로 시작한다. (A-M4)
- Output Guidance 또는 Output Format 을 둔다. (A-M6)
- 부수 효과가 있으면 tools 를 명시 제한한다. (A-M5)

MUST NOT:
- 분석 + 자동 수정 + commit + push 를 한 에이전트에 모두 묶지 않는다. (A-X1)
- 모든 에이전트를 opus 로 고정하지 않는다. (A-X2)
- description 에 긴 호출 절차를 넣지 않는다. (A-X3)
- 다른 에이전트를 자동 디스패치하지 않는다. 오케스트레이션은 skill 또는 main session 책임이다. (A-X4)

SHOULD:
- 리뷰/분석 에이전트는 read-only. (A-S1)
- 리뷰류는 confidence cutoff 를 둔다. 기본 보고 기준은 confidence >= 80. (A-S4)
- 모호한 도메인만 description 에 `<example>` 를 1-3개 사용한다. (A-S5)

## Hook Rules

MUST:
- `settings.json` 의 `hooks` 절에 등록되어야 실행된다. (H-M1)
- matcher 로 대상 tool/event 를 좁힌다. (H-M2)
- 실패는 silent fail 이 기본이다. 차단 목적 PreToolUse 만 non-zero. (H-M3)
- 시크릿/락파일 보호는 정확한 path 매칭을 사용한다. (H-M4)

MUST NOT:
- long-running 작업을 hook 안에서 동기로 실행하지 않는다. (H-X1)
- hook JSON contract 를 무시하지 않는다. (H-X2)
- 사용자 모르게 외부로 데이터를 보내지 않는다. (H-X3)

SHOULD:
- formatter/linter 는 PostToolUse. (H-S1)
- routing hint 는 UserPromptSubmit `additionalContext` 1줄. (H-S3)
- cwd context 는 SessionStart 1회. (H-S4)

## Quantitative Checks

- skill description: 권고 <= 500 chars, frontmatter total <= 1024 chars. (GUIDE §6)
- skill body: 일반 권고 <= 500 words, 큰 메타 스킬은 예외 가능. 500 lines 초과 시 분리. (GUIDE §6, S-M7)
- agent description: 단순형 20-60 words, 예시형 <= 300 words, 절대 500 words 초과 금지. (GUIDE §6, A-N2)
- agent body: 권고 250-700 words, 1000 words 초과는 압축 검토. (GUIDE §6)
- hook: 1회 실행 권고 <= 500 ms, 절대 2 s. (GUIDE §6)

## Antipatterns

- Description-as-runbook: description 이 workflow 요약이 됨.
- All-tools agent: 리뷰/분석 에이전트가 모든 tools 를 가짐.
- Always-opus: 비용과 지연을 무시하고 opus 고정.
- Hook-as-validator-then-blocker: PostToolUse 실패가 사용자 작업을 막음.
- Skill calling skill calling skill: 깊은 중첩 호출.
- Description-bloat: description 이 2000 chars 이상이거나 examples 가 폭주.
- Persona in skill / no persona in agent.
- Dead asset: 호출 경로 또는 사용 로그가 없음.

## Severity Heuristic

- P0: 작동 불능, 과권한, 미통제 부수 효과, 보안/데이터 유출, hook 차단 사고.
- P1: contract drift, description-as-runbook, 책임 경계 위반, 큰 토큰 비용.
- P2: SHOULD 위반, 길이 권고 초과, naming/톤 일관성.
