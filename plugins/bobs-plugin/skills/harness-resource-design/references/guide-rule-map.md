# GUIDE Rule Map

원본: `${CLAUDE_PLUGIN_ROOT}/references/agent-skill-best-practices/{CONSTITUTION,SKILL-GUIDE,AGENT-GUIDE,COMMAND-GUIDE,HOOK-GUIDE,RUNTIME-GUIDE}.md` (v2.1 modular guide). 본 파일은 그 가이드들의 rule-ID 인덱스이자 압축본이다. 충돌 시 원문 가이드가 우선한다.

규칙 ID 매핑:
- S- prefix → `SKILL-GUIDE.md`
- A- prefix → `AGENT-GUIDE.md`
- CMD- prefix → `COMMAND-GUIDE.md`
- H- prefix → `HOOK-GUIDE.md`
- R- prefix → `RUNTIME-GUIDE.md`
- 공통 원칙 → `CONSTITUTION.md`

## Constitution

- C1: 자동화는 Hooks / Subagents / Skills / Plugins / MCP Servers 로 분리한다.
- C2: 사용자가 명시 호출하는 workflow 와 문서 링크/context 주입은 command 로 분리한다.
- C3: 스킬은 자동 활성화되는 외부 인프라·도메인 능력 확장 모듈이다. User-invocable 은 예외적 편의다.
- C4: 에이전트 tools/model 은 능력에 맞게 축소한다. sonnet 기본, opus 는 복잡 추론.
- C5: runtime permissions, MCP, memory, model, budget 은 capability surface 로 평가한다.
- C6: version-sensitive runtime 동작은 verified date/source 를 남긴다.

## Skill Rules

MUST:
- `name`, `description` 필수. `name` 은 kebab-case. (S-M1, S-M2)
- description 은 자동 활성화 조건을 말한다. workflow 요약을 넣지 않는다. (S-M3, S-X1)
- 부수 효과가 있으면 `disable-model-invocation: true`. (S-M5)
- Claude-only 배경 지식은 `user-invocable: false`. (S-M6)
- 500 lines 초과 시 references 로 분리한다. (S-M7)

SHOULD:
- description 은 "Use when ..." 또는 동치 트리거로 시작. (S-S1)
- When to use / When NOT to use 를 분명히 한다. (S-S2)
- 본문은 가능한 짧게 두고 상세 규칙은 references 로 이동한다. (S-S3)
- 외부 infra/API/provider/domain 능력과 project workflow 를 분리한다. workflow entrypoint 는 command 로 둔다. (S-S4)

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

## Command Rules

MUST:
- 사용자 명시 호출 workflow 여야 한다. 자동 라우팅되는 외부 인프라·도메인 capability 는 skill 로 이동한다. (CMD-M1)
- inputs, missing-input 질문, effect gate, output contract 를 둔다. (CMD-M2)
- 하위 agent/skill 을 호출하면 delegation contract 를 둔다. (CMD-M3)
- shell/network/mutation 권한은 workflow 범위로 제한한다. (CMD-M4)
- docs/specs/decisions/context-map 링크를 context selector 로 전달한다. 긴 본문을 복사하지 않는다. (CMD-M5)

MUST NOT:
- command 실행만으로 commit/push/deploy 를 숨겨서 진행하지 않는다. (CMD-X1)
- command 를 deep dispatcher 로 만들어 agent 가 agent 를 다시 dispatch 하게 하지 않는다. (CMD-X2)
- 하위 결과 전문을 main context 에 dump 하지 않는다. (CMD-X3)
- provider/API/domain 세부 사용법을 command 에 길게 구현하지 않는다. skill 로 분리한다. (CMD-X4)

SHOULD:
- main context 에는 결론, 증거 위치, 다음 행동만 남긴다. (CMD-S1)
- invalid 하위 결과는 fail closed 로 처리한다. (CMD-S2)

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
- on-demand hook 은 opt-in/cleanup 을 명시한다. (H-S5)

## Runtime Rules

MUST:
- broad wildcard permission 은 예외로 취급하고 이유와 보완 gate 를 둔다. (R-M1)
- project-shared settings 에 secret, 개인 credential, local-only path 를 넣지 않는다. (R-M2)
- auto/background loop 는 opt-in, cap, visibility, stop path 를 둔다. (R-M3)
- version-sensitive setting/hook/memory/MCP 동작은 verified date/source 를 남긴다. (R-M4)

MUST NOT:
- project scope 에 bypass/auto mode/broad permission 을 기본값으로 공유하지 않는다. (R-X1)
- 자연어 금지문만으로 destructive action 을 막는다고 가정하지 않는다. (R-X2)
- memory/state 파일을 cleanup 없이 누적하지 않는다. (R-X3)

SHOULD:
- allow 는 safe subcommand 단위로 좁힌다. (R-S1)
- MCP server 는 source, credential 위치, data access 를 문서화한다. (R-S2)
- context 가 커지면 Continue/Rewind/Compact/Clear/Subagent 중 하나를 선택한다. (R-S3)

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
- Command-as-skill: 사용자가 명시 호출해야 할 workflow 가 자동 skill 로 숨어 있음.
- Runtime overreach: read-only 역할인데 settings/MCP/memory/permission 이 과함.
- Context hoarding: docs/tools/memory 를 항상 로드해 main context 를 오염.

## Severity Heuristic

- P0: 작동 불능, 과권한, 미통제 부수 효과, 보안/데이터 유출, hook 차단 사고.
- P1: contract drift, description-as-runbook, 책임 경계 위반, 큰 토큰 비용.
- P2: SHOULD 위반, 길이 권고 초과, naming/톤 일관성.
