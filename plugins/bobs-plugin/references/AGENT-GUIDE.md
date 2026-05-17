# 서브에이전트 작성 가이드 v2.1

생성: 2026-05-16
개정: 2026-05-17
상위 원칙: `CONSTITUTION.md`
성격: 에이전트 작성과 개선을 위한 타입별 실무 가이드

이 문서는 `CONSTITUTION.md` 의 공통 원칙을 서브에이전트에 적용하는 방법을 설명한다. 에이전트는 별도 컨텍스트에서 실행되는 specialist role 이다.

---

## 1. 에이전트의 역할

에이전트는 메인 세션에서 분리해 맡길 가치가 있는 역할을 캡슐화한다.

에이전트에 적합한 것:
- 별도 컨텍스트에서 수행해야 품질이 올라가는 분석, 리뷰, 생성 작업
- 병렬로 실행할 수 있는 독립 작업
- tool 권한이나 model 선택을 역할 단위로 제한해야 하는 작업
- 호출자에게 구조화된 결과를 반환해야 하는 specialist 판단
- false positive 를 줄이는 전문 기준이 필요한 review/diagnostic 작업

에이전트에 부적합한 것:
- 단순 reference 나 절차. 이 경우 스킬이 낫다.
- 프로젝트 고유 규칙 자체. 이 경우 CLAUDE.md 가 낫다.
- 사용자가 명시 호출하는 workflow entrypoint. 이 경우 커맨드가 낫다.
- 매 이벤트마다 자동 실행되어야 하는 guardrail. 이 경우 훅이 낫다.
- 권한, memory, MCP, budget 같은 공유 실행 정책 자체. 이 경우 런타임 설정이 낫다.
- 분석, 수정, commit, 배포를 모두 수행하는 generalist 역할.
- 다른 에이전트를 임의로 orchestrate 하는 역할.

---

## 2. Frontmatter

권장 구조:

```yaml
---
name: specialist-name
description: Use this agent when [specific invocation trigger]. Do not use when [near-miss].
tools: Read, Grep, Glob
model: sonnet
color: green
permissionMode: default
maxTurns: 5
skills:
  - domain-reference
mcpServers:
  - docs-server
memory: user
background: false
effort: medium
isolation: workspace
---
```

필드 원칙:
- `name` 은 역할을 드러낸다. 예: `code-reviewer`, `comment-analyzer`, `code-explorer`.
- `description` 은 activation signal 이다. 호출 조건, 입력 범위, near-miss 를 담는다.
- `tools` 는 capability surface 를 역할에 맞게 줄인다.
- `model` 은 가능하면 명시한다. `inherit` 도 명시적 선택이다.
- `color` 는 선택적 UI hint 이며 의미를 과하게 부여하지 않는다.
- `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `memory`, `background`, `effort`, `isolation` 은 runtime capability 이므로 역할 책임과 함께 설명한다.

주의:
- `tools` 생략의 의미는 플랫폼 기본값에 따라 달라질 수 있다. 생략할 경우 의도적으로 생략했는지 설명 가능해야 한다.
- advisory 역할이면 본문 지시뿐 아니라 tools 도 advisory 책임에 맞아야 한다.
- platform 별 frontmatter 지원 여부는 version-sensitive 하다. 확인하지 못한 필드는 hard rule 이 아니라 runtime 확인 대상으로 둔다.

---

## 3. Description 전략

description 은 호출자에게 "언제 이 에이전트를 써야 하는지" 알려준다.

좋은 description 이 답하는 질문:
- 어떤 상황에서 호출해야 하는가?
- 어떤 입력을 넘겨야 하는가?
- 무엇을 하지 않는가?
- 주변 에이전트나 스킬과 어디서 갈리는가?

형식은 유연하다.

짧은 trigger형:

```yaml
description: Reviews code for bugs, logic errors, security vulnerabilities, and project convention violations using confidence-based filtering.
```

긴 trigger 산문형:

```yaml
description: Use this agent when you need to analyze code comments for accuracy, completeness, and long-term maintainability. Use after generating large documentation comments, before finalizing a PR that modifies comments, or when checking for comment rot. Do not use for general code review.
```

`<example>` 임베드형은 라우팅이 자주 헷갈리는 경우에만 쓴다. 예시는 카탈로그 비용이 크므로 본문 `When to invoke` 로 옮길 수 있으면 옮긴다.

체크:
- 호출 조건이 구체적인가?
- 입력 범위가 암시되는가?
- near-miss 가 필요한 경우 보이는가?
- 본문 process 를 과도하게 요약하지 않는가?
- 비슷한 에이전트와 overlap 이 설명되는가?

---

## 4. Body 설계

에이전트 본문은 역할, 범위, 수행 기준, 산출물을 빠르게 알려야 한다.

권장 구조:

```markdown
You are an expert [role] specializing in [bounded domain].

## When to invoke
- Scenario 1
- Scenario 2
- Near-miss or do-not-use case

## Scope / Mission
기본 입력 범위, 제외 범위, override 조건

## Core Responsibilities
1. ...
2. ...
3. ...

## Quality Gate
confidence, filtering, verification, advisory-only rule

## Output Contract
호출자에게 반환할 fields, no-finding case, follow-up
```

필수 기능:
- persona 또는 specialist role
- mission 과 scope
- 수행 책임
- capability 와 권한의 의미
- output contract
- 필요한 경우 confidence/quality gate

섹션명은 유연하다. `Output Guidance`, `Report`, `Return`, `Analysis Output` 도 output contract 로 인정된다.

---

## 5. Scope 설계

에이전트 품질은 scope 로 결정된다.

좋은 scope:
- `By default, review unstaged changes from git diff.`
- `Only refine code that has been recently modified.`
- `Analyze comments and docstrings only.`
- `Trace this feature from entry points to data storage.`
- `Review only the files supplied by the caller.`

나쁜 scope:
- `Review the whole codebase.`
- `Analyze everything thoroughly.`
- `Improve quality wherever possible.`
- `Find all possible issues.`

Scope 에 포함할 것:
- 기본 입력 범위
- 제외할 작업
- 사용자가 override 할 수 있는 범위
- pre-existing issue 처리 방식
- no-finding 처리 방식

넓은 scope 가 필요하면 단계화하거나, explorer/architect/reviewer 처럼 역할을 분리한다.

---

## 6. Capability Surface

에이전트의 `tools`, `model`, runtime 접근은 역할의 책임과 맞아야 한다.

### 6.1 Tools

권장 방향:

| 역할 | 보통 필요한 tools | 주의 |
|---|---|---|
| 탐색/분석 | `Read`, `Grep`, `Glob`, `LS` | read-only 유지 |
| 코드 리뷰 | `Read`, `Grep`, `Glob`, `LS` | 수정 권한 없음 |
| 코드 생성/수정 | `Read`, `Write`, `Grep`, `Glob` | scope 와 gate 필요 |
| 마이그레이션 | `Read`, `Write`, `Grep`, `Glob`, `Bash` | 위험하므로 좁은 mission 필요 |
| 외부 문서 조사 | `WebFetch` 또는 `WebSearch` | 네트워크 사용 이유 필요 |

주의할 도구:
- `Write`, `Edit`, `MultiEdit`: 직접 mutation 가능.
- `Bash`: 임의 명령 실행 가능.
- `WebSearch`, `WebFetch`: 외부 네트워크와 데이터 노출 고려.
- `TodoWrite`: 사용자 작업 상태에 영향을 줄 수 있음.
- `BashOutput`, `KillShell`: long-running command 제어 권한.

원칙:
- advisory/review/analysis 역할은 read-only 를 기본으로 한다.
- 쓰기 권한이 있으면 어떤 파일을 쓸 수 있는지 mission 에서 좁힌다.
- 넓은 권한이 필요하면 output/approval/verification gate 를 강화한다.
- 플랫폼 기본값을 모르면 tools 생략을 "전체 권한" 으로 단정하지 않는다. 대신 ambiguity 로 취급한다.

### 6.2 Model

model 은 품질, 비용, latency 의 선택이다.

| Model | 적합한 작업 | 주의 |
|---|---|---|
| `haiku` | 단순 반복 검사, 저위험 분류 | 깊은 추론에는 약함 |
| `sonnet` | 일반 분석, 리뷰, 생성 | 기본 균형점 |
| `opus` | 높은 정밀도 리뷰, 복잡한 architecture, migration | 비용과 latency 증가 |
| `inherit` | 호출자 모델과 일관성이 필요한 보조 역할 | 호출자 모델에 비용/품질이 종속 |

`inherit` 은 model 미지정이 아니다. 호출자 모델과 같은 reasoning profile 이 필요한 경우, plugin/runtime 정책상 일관성이 중요한 경우, 또는 agent 가 caller 의 판단을 보조하는 경우 정당화될 수 있다.

새 에이전트는 model 선택을 설명할 수 있어야 한다.

### 6.3 Runtime Capability Fields

일부 runtime 은 에이전트에 추가 실행 필드를 제공한다. 이 필드들은 편의 설정이 아니라 capability surface 다.

| 필드 | 의미 | 검토 질문 |
|---|---|---|
| `permissionMode` | 권한 요청/승인 방식 | 역할보다 넓은 권한을 자동 승인하지 않는가? |
| `maxTurns` | 독립 실행 상한 | 실패 루프와 비용 누적을 막는가? |
| `skills` | 시작 시 preload 되는 지식 | 필요한 skill 만 로드하는가? |
| `mcpServers` | 외부 tool/data 접근 | 출처, credential, data exposure 가 설명되는가? |
| `hooks` | 에이전트 실행 중 자동 개입 | on-demand hook 의 범위와 실패 정책이 있는가? |
| `memory` | agent-specific persistent context | scope, owner, cleanup 이 설명되는가? |
| `background` | main flow 밖 장기 실행 | cap, progress, stop path 가 있는가? |
| `effort` | reasoning 비용/깊이 | 작업 복잡도와 맞는가? |
| `isolation` | workspace/context 격리 | 병렬 write scope 와 통합 책임이 분명한가? |

이 필드가 지원되는지, 이름이 같은지, 병합 precedence 가 어떤지는 runtime 별로 달라질 수 있다. 문서나 자산에 단정할 때는 확인일과 source 를 남긴다.

### 6.4 Parent Integration Responsibility

에이전트는 독립 작업을 수행할 수 있지만, 최종 통합 판단은 호출자에게 남는 것이 기본이다.

원칙:
- 에이전트는 scope 안의 결론, patch, report, evidence 를 반환한다.
- main session 또는 command 는 결과를 검토하고 통합한다.
- 병렬 agent 는 서로의 작업을 직접 덮어쓰지 않는다.
- write-capable agent 는 파일/모듈 ownership 을 입력으로 받아야 한다.
- agent 결과를 그대로 신뢰하기보다 output contract 와 verification 결과를 확인한다.

subagent 는 병렬성뿐 아니라 context 격리 장치다. 대량 탐색이나 긴 출력이 필요하지만 main context 에 결론만 필요하면 에이전트를 고려한다.

---

## 7. Output Contract

에이전트는 호출자가 바로 사용할 수 있는 결과를 반환해야 한다.

포함할 것:
- scope summary
- findings 또는 result fields
- file/line reference 형식
- confidence/severity 기준
- no-finding case
- follow-up recommendation 또는 next files

리뷰 에이전트 예:

```markdown
Start by stating what you reviewed. For each high-confidence issue provide:

- Description and confidence score
- File path and line number
- Specific rule or bug explanation
- Concrete fix suggestion

If no high-confidence issues exist, say so clearly.
```

탐색 에이전트 예:

```markdown
Include:
- Entry points with file:line references
- Step-by-step execution flow
- Key components and responsibilities
- Essential files to read next
```

Output contract 는 제목이 아니라 기능이다. 호출자가 다음 행동을 결정할 수 있으면 충분하다.

---

## 8. Quality Gate

리뷰/진단 에이전트는 false positive 를 줄이는 gate 가 필요하다.

대표 패턴:

```markdown
Rate each issue from 0-100.

- 0-25: likely false positive or pre-existing issue
- 26-50: minor nitpick
- 51-75: valid but low-impact
- 76-90: important issue
- 91-100: critical bug or explicit guideline violation

Only report issues with confidence >= 80.
```

숫자 score 가 항상 필요한 것은 아니다. 다음도 quality gate 가 될 수 있다.
- Critical / Important 만 보고
- advisory-only 역할 명시
- factual accuracy 만 보고 style nit 제외
- no-finding case 명시
- pre-existing issue 제외

false positive 비용이 큰 역할일수록 gate 를 강하게 둔다. 단순 요약/분류 에이전트에는 가벼운 기준이면 충분하다.

---

## 9. CLAUDE.md, Agent Memory, And Project Memory

프로젝트 convention 검사 에이전트는 CLAUDE.md 또는 equivalent project memory 를 source of truth 로 취급한다.

권장 문장:

```markdown
Review code against explicit project rules in CLAUDE.md or equivalent project memory.
```

주의:
- CLAUDE.md 에 없는 스타일 선호를 강제하지 않는다.
- 프로젝트 규칙과 일반 best practice 를 구분한다.
- pre-existing issue 는 새 변경과 분리한다.
- 특정 프로젝트의 import style, framework pattern, path convention 을 reusable 에이전트 본문에 하드코딩하지 않는다.

agent memory 를 지원하는 runtime 에서는 memory scope 를 별도 설계한다.

| Memory scope | 용도 | 주의 |
|---|---|---|
| user | agent 역할의 cross-project 학습 | 개인화가 팀 정책처럼 보이지 않게 한다 |
| project | 팀이 공유할 agent-specific 지식 | review 가능해야 하며 secret 금지 |
| local | 개인 프로젝트 작업 기억 | git ignore 와 cleanup 필요 |

원칙:
- memory 는 에이전트 역할 범위 안의 반복 학습에만 쓴다.
- reusable agent body 에 mutable history 를 넣지 않는다.
- memory 가 길어지면 index 와 topic file 로 분리한다.
- memory 작성 권한은 mutation 권한이므로 capability surface 로 평가한다.
- runtime 이 memory 를 어떻게 주입하는지는 version-sensitive 하다.

---

## 10. Overlap And Reuse

비슷한 에이전트가 공존할 수 있다. 다만 차이가 설명되어야 한다.

차이의 예:
- `code-reviewer`: general code review
- `comment-analyzer`: comment/docstring accuracy only
- `code-explorer`: how existing feature works
- `code-architect`: how new feature should be designed
- toolkit-specific reviewer: PR workflow 에 최적화된 output

중복 점검:
- trigger 가 다른가?
- scope 가 다른가?
- output 이 다른가?
- tools/model 이 다른가?
- 하나가 다른 하나를 대체하는가?

차이가 설명되지 않으면 routing ambiguity 가 생긴다.

---

## 11. Quantitative Heuristics

수치는 hard rule 이 아니라 진단 신호다.

| 항목 | 진단 기준 |
|---|---|
| 짧은 description | 20-80 words 정도면 보통 충분 |
| 긴 trigger 산문 | 복잡한 호출 조건이 있을 때 사용 |
| `<example>` description | 라우팅 혼선이 큰 경우에만 |
| body | specialist role, scope, output 을 빠르게 찾을 수 있어야 함 |
| tools | 역할과 책임에 맞는지 확인 |
| model | 비용/품질 이유를 설명할 수 있어야 함 |

수치가 문제가 되는 경우:
- description 이 카탈로그 비용을 키우고도 routing 을 개선하지 않는다.
- 본문에서 mission/scope/output 을 찾기 어렵다.
- 예시가 많아 본문으로 옮기는 편이 낫다.
- 긴 본문이 여러 역할을 섞고 있다.

---

## 12. Checklist

작성 전:
- [ ] 스킬이 아니라 에이전트가 필요한 이유가 있는가?
- [ ] 커맨드가 아니라 에이전트가 필요한 이유가 있는가?
- [ ] 별도 컨텍스트, specialist role, tool/model 격리가 필요한가?
- [ ] 프로젝트 고유 규칙이 아니라 재사용 가능한 역할인가?
- [ ] scope 를 좁힐 수 있는가?

Frontmatter:
- [ ] `name` 이 역할을 드러내는가?
- [ ] `description` 이 호출 조건을 말하는가?
- [ ] near-miss 가 필요한 경우 드러나는가?
- [ ] `tools` 가 책임보다 넓지 않은가?
- [ ] `model` 선택을 설명할 수 있는가?
- [ ] runtime capability fields 가 있으면 역할과 lifecycle 이 설명되는가?

본문:
- [ ] role 과 mission 이 초반에 있는가?
- [ ] 기본 입력 범위와 제외 범위가 있는가?
- [ ] output contract 가 있는가?
- [ ] no-finding/no-op case 가 있는가?
- [ ] review/diagnostic 역할이면 quality gate 가 있는가?
- [ ] CLAUDE.md 와의 관계가 필요한 경우 명확한가?

운영:
- [ ] mutation 권한이 있다면 gate 가 있는가?
- [ ] write-capable agent 라면 파일/모듈 ownership 이 입력으로 전달되는가?
- [ ] 다른 에이전트와 overlap 이 설명되는가?
- [ ] pre-existing issue 와 새 변경을 구분하는가?
- [ ] 호출자가 다음 행동을 결정할 수 있는 결과를 받는가?
- [ ] memory/background/MCP 사용이 필요 최소한인가?

---

## 13. Anti-Patterns

| Anti-pattern | 증상 | 수정 |
|---|---|---|
| Generalist agent | 분석/수정/배포를 모두 수행 | specialist 로 분리 |
| All-tools reviewer | advisory 역할에 mutation/shell 권한 | read-only 로 제한 |
| No scope | 전체 코드베이스를 막연히 분석 | 기본 입력과 제외 범위 지정 |
| No output contract | 결과 형식이 매번 다름 | caller 가 쓸 fields 정의 |
| Low-confidence spam | 추측과 nit 을 많이 보고 | quality gate 추가 |
| Description bloat | 예시가 많아 카탈로그 비용 증가 | 본문 `When to invoke` 로 이동 |
| Agent as runbook | 단순 절차를 별도 agent 로 만듦 | 스킬로 이동 |
| Hidden mutation | advisory 역할인데 파일 수정 | role 과 tools 를 정렬 |
| Project convention leak | 특정 프로젝트 style 하드코딩 | CLAUDE.md 참조로 전환 |
| Unintentional duplicate | 비슷한 agent 간 차이가 없음 | trigger/scope/output 분리 또는 통합 |
| Always-opus | 모든 에이전트가 `model: opus` — 비용·지연 누적 | `sonnet` 기본, 정당화 가능할 때만 `opus` 승격 |
| Orchestrator agent | 본문에서 다른 에이전트를 dispatch | orchestration 을 caller (skill / main session) 로 이동 |
| Persona drift mid-body | 본문 시작과 후반의 책임이 다름 — 한 파일에 두 역할 | persona 별로 분리, 각자 단일 책임 |
| Auto-merge generator | 코드 생성 + commit + push 까지 단일 에이전트 | generator 는 diff 만 산출, commit·push 결정은 caller |
| No negative case | description 에 positive trigger 만 있음 — 라우팅 모호 | sibling 명시한 `Do NOT use for …` ≥1 추가 |
| Multi-language persona | 본문이 섹션마다 언어 변경 — 출력 형식 불안정 | 본문 단일 언어, 다국어는 description trigger 에만 |
| Runtime overreach | read-only 역할인데 `permissionMode`, MCP, memory, background 가 과함 | `RUNTIME-GUIDE.md` 기준으로 축소 |
| Memory as project docs | agent memory 에 팀 정책이나 도메인 문서 전체 저장 | docs/CLAUDE.md 로 이동하고 memory 는 역할별 학습만 유지 |
| Background without stop path | 장기 실행 agent 에 cap, progress, stop 경로 없음 | maxTurns/budget/visibility/stop path 추가 |
| Unowned parallel writer | 병렬 agent 가 write scope 없이 파일 수정 | 파일/모듈 ownership 과 caller integration contract 추가 |
