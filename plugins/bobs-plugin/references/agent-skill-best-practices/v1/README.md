# Agent / Skill / Hook Best Practices — Reference Collection

생성: 2026-05-16
용도: 유저 스콥 skill/agent/hook 최적화 작업의 1차 자료. 본격 작업 전, Anthropic 공식 및 Claude Code 플러그인 best practice 를 한 곳에서 참조하기 위한 사본.

원본 위치는 `~/.claude/plugins/cache/...` 아래이며, 플러그인 업데이트 시 덮어쓰일 수 있어 이 디렉토리에 스냅샷을 보관한다. 수정·재배포 금지 — read-only reference.

---

## 디렉토리 구조

```
agent-skill-best-practices/
├── README.md                          ← 이 파일 (인덱스)
├── CONSTITUTION.md                    ← 핵심 철학·역할 경계
├── SKILL-GUIDE.md                     ← 스킬 작성 실무 가이드
├── AGENT-GUIDE.md                     ← 서브에이전트 작성 실무 가이드
├── HOOK-GUIDE.md                      ← 훅 작성 실무 가이드
├── SIGNALS.md                         ← 참고 스킬/에이전트 시그널 분석
├── GUIDE.md                           ← 기존 통합 가이드
├── STATUS-2026-05-16.md               ← 진행 상태 기록
├── skills/
│   ├── brainstorming/                 superpowers 5.1.0
│   ├── claude-automation-recommender/ claude-code-setup 1.0.0
│   ├── claude-md-improver/            claude-md-management 1.0.0
│   ├── doc-coauthoring/               claude-api f458cee31a75
│   ├── skill-creator/                 claude-api f458cee31a75 (skill 작성 메타-가이드)
│   └── writing-skills/                superpowers 5.1.0
└── agents/
    ├── code-simplifier.md             code-simplifier 1.0.0
    ├── feature-dev/
    │   ├── code-architect.md
    │   ├── code-explorer.md
    │   └── code-reviewer.md
    ├── pr-review-toolkit/
    │   ├── code-reviewer.md
    │   ├── code-simplifier.md
    │   └── comment-analyzer.md
    └── builtin/
        └── README.md                  claude-code-guide / Explore / general-purpose
```

---

## 분석 산출물

| 문서 | 용도 |
|---|---|
| **README.md** | 자료 컬렉션 인덱스 |
| **SIGNALS.md** | 참고 스킬·서브에이전트에서 관측된 철학, 반복 패턴, 톤, 섹션 구성, 정량 지표 |
| **CONSTITUTION.md** | 스킬·에이전트 역할 경계와 핵심 원칙 |
| **SKILL-GUIDE.md** | 스킬 작성 템플릿, description 작성법, 테스트·체크리스트 |
| **AGENT-GUIDE.md** | 서브에이전트 작성 템플릿, tool/model/scope/output 설계 |
| **HOOK-GUIDE.md** | 훅 작성 템플릿, event/matcher/exit/security 설계 |
| **GUIDE.md** | 유저 스코프 스킬·에이전트·훅 작성/구성 가이드 |
| **STATUS-2026-05-16.md** | 현재 작업 목표, 진행 상태, 보류 항목 정리 |

권장 읽기 순서:

1. `SIGNALS.md` — 관측된 근거 확인
2. `CONSTITUTION.md` — 상위 원칙과 역할 경계 확인
3. `SKILL-GUIDE.md` / `AGENT-GUIDE.md` / `HOOK-GUIDE.md` — 실제 작성 규칙 적용
4. `GUIDE.md` — 기존 통합 가이드와 비교하며 재구성

---

## 스킬별 요점 — 무엇을 배우러 왔는가

| Skill | 핵심 패턴 (best practice 추출 대상) |
|---|---|
| **skill-creator** | 스킬 자체를 만드는 메타 스킬. frontmatter 규약, description triggering, references 디렉토리 분리, allowed-tools 축소 — 스킬 설계의 정전(canon). |
| **writing-skills** | superpowers 스타일 스킬 작성법. checklist / process flow / red flags 섹션 템플릿, "When to use / When NOT to use" 양면 명시 가이드. |
| **claude-automation-recommender** | hooks / subagents / skills / plugins / mcp servers 를 코드베이스 신호 기반으로 추천하는 규칙. **본 디렉토리에서 가장 직접적인 참조** — `references/hooks-patterns.md`, `references/subagent-templates.md`, `references/skills-reference.md`, `references/plugins-reference.md` 를 반드시 본다. |
| **claude-md-improver** | CLAUDE.md 품질 평가·개선 절차. 라우팅 매트릭스를 CLAUDE.md 에 넣는다면 이 기준이 출발점. |
| **brainstorming** | 본 작업의 진입 스킬. design gate / spec self-review / writing-plans 로 인계되는 라이프사이클 모범. |
| **doc-coauthoring** | Anthropic 공식 문서 공동 저술 워크플로우. spec / RFC 작성 톤·구조 참조. |

## 에이전트별 요점 — description / tools / model 결정 사례

| Agent | 배울 점 |
|---|---|
| **code-simplifier (plugin)** | "최근 수정된 코드만" 으로 범위 좁히기, 기능 보존 명시 — scope 제한이 description 에 박혀 있는 모범. |
| **feature-dev:code-architect** | 설계 에이전트가 코드 변경 없이 blueprint 만 반환하는 분리. 도구를 의도적으로 read-only 로 축소. |
| **feature-dev:code-explorer** | "execution path 추적 + 아키텍처 레이어 매핑" 처럼 책임을 단일 동사로 묶는 패턴. |
| **feature-dev:code-reviewer** | "confidence-based filtering" — 모든 이슈 보고가 아니라 신뢰도 기반 우선순위 필터링이 description 에 명시. |
| **pr-review-toolkit:code-reviewer** | "When to invoke" 절을 description 안에 직접 인용하는 패턴, CLAUDE.md 와 연동되는 컨벤션 체크. |
| **pr-review-toolkit:code-simplifier** | 다중 예시 (`<example>` 태그) 로 트리거 케이스를 description 에 임베드 — 라우팅 모호성 제거. |
| **pr-review-toolkit:comment-analyzer** | 코드 주석 자체에 대한 specialized 에이전트 — 좁은 책임 → 명확한 가치. |
| **builtin/** (general-purpose, Explore, claude-code-guide) | Anthropic 빌트인. 이름 짓기, 도구 축소, negative 케이스 명시, 재호출 가이드의 표준. |

---

## 본 작업(유저 스콥 최적화)에 적용할 후보 원칙

`claude-automation-recommender/references/` 를 1차 읽고, 본 작업의 설계에 반영할 후보 원칙(추출 예정):

1. **에이전트 description 의 negative 케이스 명시** (Explore / pr-review-toolkit 패턴).
2. **도구는 능력에 맞게 축소** (Explore: read-only).
3. **다중 `<example>` 태그로 트리거 케이스 임베드** (pr-review-toolkit:code-simplifier).
4. **CLAUDE.md 와의 연동을 description 에 명시** (pr-review-toolkit:code-reviewer).
5. **재사용/이어가기 가이드** (claude-code-guide: SendMessage 패턴).
6. **스킬 frontmatter 의 `disable-model-invocation` / `user-invocable` / `allowed-tools` 활용** (skill-creator).
7. **PostToolUse 훅으로 포맷·타입체크 자동화** (hooks-patterns.md).
8. **PreToolUse 훅으로 민감 파일·락파일 차단** (hooks-patterns.md).
9. **UserPromptSubmit 훅으로 컨텍스트 라우팅 힌트 주입** (claude-automation-recommender).

후속 단계에서 이 원칙들을 design 에 반영한다.
