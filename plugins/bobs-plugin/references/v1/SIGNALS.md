# 스킬·서브에이전트 시그널 분석

생성: 2026-05-16
분석 대상:
- 스킬: `skills/*/SKILL.md` 6개
- 커스텀 서브에이전트: `agents/**/*.md` 7개 (`agents/builtin/` 제외)
- 빌트인 에이전트 설명: `agents/builtin/README.md` 의 `general-purpose`, `Explore`, `claude-code-guide` 3종

목적:
- 참고용 스킬과 서브에이전트에서 반복되는 작성 신호를 추출한다.
- 이후 `GUIDE.md` 를 "규칙 모음" 이 아니라 "관측 → 원칙 → 적용" 구조로 재검토하기 위한 입력 자료로 사용한다.

---

## 1. 요약

가장 강한 신호는 다음 5개다.

1. **description 은 라우터다.** 본문 요약이 아니라 "언제 로드할지" 를 결정하는 트리거 조건이다.
2. **스킬은 방법을 캡슐화하고, 에이전트는 역할을 캡슐화한다.** 스킬은 workflow/checklist/reference 중심이고, 에이전트는 persona/mission/output contract 중심이다.
3. **효과적인 자원은 범위가 좁다.** "최근 수정된 코드만", "CLAUDE.md 만", "comment changes only" 처럼 입력 범위를 고정한다.
4. **MUST 폭격보다 이유와 실패 모드를 적는 쪽이 강하다.** 강한 명령은 hard gate, safety, discipline 스킬에 제한적으로 쓰인다.
5. **산출 지시는 거의 항상 명시된다.** 좁은 의미의 `Output Guidance` / `Output Format` / `Report structure` 제목은 스킬 3/6, 에이전트 4/7 에서 확인된다. 더 넓게 보면 모든 표본이 workflow, process, report, confidence gate, document draft 같은 산출 지시를 본문에 둔다.

---

## 2. 스킬 분석의 핵심 철학

### 2.1 Description First

스킬의 frontmatter `description` 은 매 세션 카탈로그에 올라가는 가장 중요한 라우팅 신호다.

관측 신호:
- `writing-skills` 는 description 을 "what the skill does" 가 아니라 "when to use" 로 정의한다.
- 좋은 description 은 `Use when ...` 으로 시작하거나 동등하게 구체적인 트리거 조건을 담는다.
- 나쁜 description 은 workflow 를 요약한다. 이 경우 모델이 본문을 읽지 않고 description 만 따라 단축 실행할 수 있다.

작성 원칙:
- 문제 상황, 증상, 사용자가 실제로 말할 표현을 넣는다.
- 본문 절차, 단계 수, 내부 구현 방식은 description 에 넣지 않는다.
- near-miss 를 의식한다. 비슷한 키워드가 있어도 호출되면 안 되는 경우를 명시해야 한다.

### 2.2 Skills Are Tested Process Documentation

`writing-skills` 와 `skill-creator` 의 공통 철학은 "스킬 작성은 문서 작성이 아니라 behavior shaping" 이라는 점이다.

관측 신호:
- 베이스라인 실패를 먼저 보고, 그 실패를 막는 최소 지침을 쓰고, 다시 검증하는 RED-GREEN-REFACTOR 구조가 반복된다.
- `skill-creator` 는 2-3개 현실적 test prompt 를 만들고, 이후 description triggering eval 까지 확장한다.
- 개선은 최종 출력만 보지 않고 transcript 에서 모델이 낭비하거나 우회한 지점을 찾아 반영한다.

작성 원칙:
- "좋아 보이는 지침" 보다 "실제로 실패를 고치는 지침" 이 우선이다.
- 한두 예시에 과적합하지 말고 실패 원인을 일반화한다.
- 반복적으로 생성되는 스크립트나 템플릿은 `scripts/`, `assets/` 로 번들링한다.

### 2.3 Progressive Disclosure

스킬은 컨텍스트 예산을 전제로 설계된다.

관측 신호:
- `skill-creator` 는 세 단계 로딩 모델을 제시한다: metadata, `SKILL.md`, bundled resources.
- 큰 자료는 `references/` 로 분리하고, 본문에는 "언제 읽을지" 포인터를 둔다.
- `claude-automation-recommender`, `claude-md-improver`, `skill-creator` 모두 references/scripts 를 실제로 사용한다.

작성 원칙:
- `SKILL.md` 는 선택자와 실행 절차에 집중한다.
- 긴 표, API 목록, 세부 rubric 은 reference 파일로 분리한다.
- 스크립트는 모델이 재작성할 필요가 없는 deterministic 작업에 쓴다.

### 2.4 Judgment Goes In Skills, Guarantees Go In Hooks

참고 자료는 스킬, 에이전트, 훅의 책임을 분리한다.

출처 성격: reference-derived / normative. 이 절은 `claude-automation-recommender` 와 `references/hooks-patterns.md` 의 분류 권고에서 도출한 원칙이며, 스킬·에이전트 표본 자체의 직접 관측만은 아니다.

분류 참조 신호:
- `claude-automation-recommender` 는 자동화를 Hooks / Subagents / Skills / Plugins / MCP Servers 로 나눈다.
- hook reference 는 formatter, typechecker, sensitive-file block 처럼 결정론적 이벤트 반응을 다룬다.
- skill reference 는 판단, 절차, 사용자 협업, 산출물 품질 같은 자연어 판단을 다룬다.

작성 원칙:
- 매번 자동으로 실행되어야 하는 것은 훅이다.
- 전문 역할과 별도 컨텍스트가 필요한 것은 에이전트다.
- 반복 가능한 판단 절차와 도메인 지식은 스킬이다.

### 2.5 Scope Is Quality Control

스킬과 에이전트 모두 작업 범위를 좁히는 문장이 강하게 반복된다.

관측 신호:
- `code-simplifier`: 최근 수정된 코드만 다룸.
- `code-reviewer`: 기본은 `git diff` 또는 사용자가 지정한 파일.
- `comment-analyzer`: comments/docstrings 에 한정.
- `claude-md-improver`: CLAUDE.md 파일 발견, 평가, 승인 후 수정.

작성 원칙:
- 분석 대상, 수정 대상, 비대상 범위를 frontmatter 또는 초반 섹션에서 확정한다.
- broad review 보다 bounded review 가 에이전트 품질을 높인다.
- 범위가 넓어지면 에이전트보다 orchestrator + 여러 specialist 조합이 낫다.

---

## 3. 반복되는 패턴

### 3.1 Frontmatter as Routing Contract

반복 구조:

```yaml
---
name: kebab-case-name
description: Use when [specific trigger, symptoms, contexts]
tools: Read, Glob, Grep, Bash  # optional; only when restriction matters
model: sonnet                  # agents; observed in 7/7 custom agents
color: green                   # optional agent UI hint; observed in 4/7
---
```

관측:
- 스킬 6/6은 `name`, `description` 을 가진다.
- 커스텀 에이전트 7/7은 `model` 을 명시한다.
- feature-dev 에이전트 3개는 `tools` 를 10개로 명시하고 쓰기 도구를 제외한다.
- pr-review-toolkit 에이전트는 description 에 worked scenario 를 많이 넣어 라우팅 모호성을 줄인다.

적용:
- 새 스킬은 description trigger 품질이 본문보다 먼저 검토되어야 한다.
- 새 에이전트는 `model`, `tools`, `color` 의 의도를 설명할 수 있어야 한다.

### 3.2 Negative Case

반복 구조:
- "Do NOT use it for ..."
- "Don't create for ..."
- "Avoid ..."
- "Only report ..."

관측:
- 빌트인 `Explore` 는 "code review, design-doc auditing, open-ended analysis" 에 쓰지 말라고 명시한다.
- `writing-skills` 는 "Don't create for one-off solutions" 를 둔다.
- review 계열 에이전트는 confidence gate 를 둬 낮은 신뢰도 이슈를 보고하지 않게 한다.

적용:
- description 또는 본문 초반에 "이 자원을 쓰면 안 되는 경우" 를 1개 이상 둔다.
- near-miss 를 막는 negative case 가 가장 가치 있다.

### 3.3 Phase / Stage / Step Workflow

반복 구조:
- `Workflow`
- `Phase 1/2/3`
- `Stage 1/2/3`
- numbered process
- checklist

관측:
- `brainstorming`: 9-step checklist + process flow.
- `claude-automation-recommender`: Phase 1 analysis, Phase 2 recommendations, Phase 3 report.
- `claude-md-improver`: discovery, assessment, report, targeted updates, apply.
- `doc-coauthoring`: context gathering, refinement, reader testing.
- 에이전트도 `Core Process`, `Analysis Approach`, `Your refinement process` 를 둔다.

적용:
- 복잡한 스킬은 상태 전이를 명시한다.
- 단계마다 입력, 작업, 산출물을 분리한다.
- 승인 gate 가 필요한 단계는 "보고 후 수정" 순서로 명시한다.

### 3.4 Output Contract

반복 구조:
- `Output Guidelines`
- `Output Guidance`
- `Output Format`
- `Report structure`
- severity/confidence grouping

관측:
- 명시적 Output/Report 제목 기준으로는 스킬 3/6, 에이전트 4/7 이 출력 구조를 둔다.
- 제목 없이 본문 process 안에 산출 지시를 넣는 경우까지 포함하면 모든 표본이 산출 지시를 갖는다.
- 분석/리뷰 에이전트는 특히 출력 구조를 명시적으로 드러내는 경향이 강하다.
- `code-reviewer` 계열은 severity 와 confidence score 를 함께 쓴다.
- `claude-md-improver` 는 보고서 템플릿을 먼저 출력하고 승인 후 수정한다.

적용:
- 호출자가 결과를 바로 사용할 수 있게 출력 필드를 고정한다.
- review 계열은 "findings first" 와 confidence threshold 를 둔다.
- no-issue 케이스의 출력도 명시한다.

### 3.5 Approval Gate Before Mutation

반복 구조:
- read-only analysis first
- report before update
- design approval before implementation

관측:
- `brainstorming` 은 design approval 전 구현 금지 hard gate 를 둔다.
- `claude-md-improver` 는 quality report 를 먼저 내고 승인 후 수정한다.
- `claude-automation-recommender` 는 read-only 로 추천만 한다.

적용:
- 파일 수정, 설정 변경, 훅 등록처럼 부수 효과가 있는 스킬은 report/approval 단계를 둔다.
- read-only 스킬은 frontmatter tools 와 본문 모두에서 쓰기 금지를 일관되게 표현한다.

### 3.6 Confidence Gate

반복 구조:
- score 0-100
- threshold >= 80
- false positive 최소화

관측:
- `feature-dev/code-reviewer` 와 `pr-review-toolkit/code-reviewer` 모두 confidence threshold 를 둔다.
- 낮은 확신의 스타일 nit 은 보고하지 않는 방향이다.

적용:
- 리뷰 에이전트에는 "무엇을 보고하지 않을지" 를 수치로 둔다.
- confidence 기준은 severity 와 분리한다.

### 3.7 CLAUDE.md Coupling

반복 구조:
- "check against project guidelines in CLAUDE.md"
- "project conventions"
- "established patterns"

관측:
- code-reviewer, code-simplifier 는 CLAUDE.md 를 프로젝트 규칙의 source of truth 로 취급한다.
- `claude-md-improver` 는 CLAUDE.md 자체의 품질을 관리한다.

적용:
- 유저 스코프 라우팅을 설계할 때 CLAUDE.md 는 "프로젝트별 컨텍스트", 스킬/에이전트는 "재사용 가능한 절차/역할" 로 나눠야 한다.

---

## 4. 효과적인 톤 및 어조

### 4.1 스킬의 톤

스킬은 대체로 페르소나보다 절차와 판단 기준을 앞세운다.

효과적인 톤:
- 객관적이고 지시적이되, 이유를 설명한다.
- "무엇을 해야 하는가" 보다 "왜 이 순서가 중요한가" 를 함께 적는다.
- 사용자 협업이 필요한 경우 부드럽게 선택권을 둔다.
- discipline 이 필요한 경우에만 `MUST`, `NEVER`, hard gate 를 쓴다.

좋은 문장 패턴:
- `Use when ...`
- `Start by ...`
- `If user declines, work freeform.`
- `Output the report before making updates.`
- `Keep SKILL.md under ...; if approaching this limit, split into references.`

피해야 할 톤:
- 근거 없는 `ALWAYS` / `NEVER` 반복
- 추상적 미덕 나열: "be helpful", "make it better"
- 과거 회고형 narrative
- description 에 workflow 요약

### 4.2 에이전트의 톤

에이전트는 거의 항상 역할 선언으로 시작한다.

효과적인 톤:
- `You are an expert ... specializing in ...`
- mission, scope, output 을 빠르게 좁힌다.
- 높은 전문성을 부여하되, 결과는 구체적이고 검증 가능하게 만든다.
- skeptical, high-precision, false-positive filtering 같은 판단 기준을 명시한다.

좋은 문장 패턴:
- `Your primary responsibility is ...`
- `By default, review ...`
- `Only report issues with confidence >= 80.`
- `Include file paths and line numbers.`
- `Do not modify code directly. Your role is advisory.`

피해야 할 톤:
- 모든 것을 다 하는 generalist 표현
- "가능하면", "적절히" 같은 검증 불가능한 지시만 있는 표현
- output contract 없이 "analyze thoroughly" 만 말하는 표현

### 4.3 명령 강도 분포

강한 지시어는 스킬에 몰려 있고, 에이전트에는 적다.

| 그룹 | MUST | NEVER | ALWAYS | SHOULD | DO NOT / Don't |
|---|---:|---:|---:|---:|---:|
| 스킬 6개 합계 | 11 | 6 | 12 | 38 | 43 |
| 에이전트 7개 합계 | 2 | 2 | 2 | 11 | 2 |

해석:
- 스킬, 특히 메타 스킬은 workflow discipline 을 만들기 위해 금지/강제 표현을 많이 쓴다.
- 에이전트는 persona + mission + output contract 로 제어하고, 강한 명령은 핵심 gate 에만 쓴다.
- `skill-creator` 의 권고처럼, 일반 규칙은 `MUST` 보다 이유 설명이 낫다.

---

## 5. 섹션 구성

### 5.1 효과적인 스킬 섹션 템플릿

관측된 스킬 구성을 합치면 다음 구조가 가장 안정적이다.

```markdown
---
name: skill-name
description: Use when [trigger conditions, symptoms, near-misses]
tools: [only if tool restriction matters]
---

# Skill Title

1-2문장 목적 / 핵심 원칙

## When to Use
- Trigger conditions
- When NOT to use

## Workflow
### Phase 1: Discovery / Context
### Phase 2: Analysis / Draft / Execution
### Phase 3: Report / Verify / Iterate

## Output Format
정해진 보고서 또는 산출물 형식

## Common Issues / Anti-Patterns
실패 모드와 회피책

## References
필요할 때 읽을 reference/script/assets 포인터
```

정량 메모: 스킬 표본에서 `tools` 를 명시한 것은 2/6 뿐이다. `tools` 는 필수 필드가 아니라 부수 효과 제한, read-only 보장, 도구 접근 축소가 의미 있을 때만 넣는 신호로 봐야 한다.

변형:
- 협업형 스킬: `Stage 1/2/3`, 사용자 질문, 승인 gate.
- 메타 스킬: testing/evals, iteration loop, description optimization.
- 추천형 스킬: detection table, recommendation table, report template.

### 5.2 효과적인 에이전트 섹션 템플릿

관측된 에이전트 구성을 합치면 다음 구조가 가장 안정적이다.

```markdown
---
name: specialist-name
description: Use this agent when [specific invocation triggers]. Do not use when [near-miss].
tools: Read, Grep, Glob
model: sonnet
color: green  # optional
---

You are an expert [role] specializing in [bounded domain].

## When to invoke
- Scenario 1
- Scenario 2
- Scenario 3

## Scope / Mission
기본 입력 범위와 책임 경계

## Core Responsibilities / Process
1. ...
2. ...
3. ...

## Confidence / Quality Gate
리뷰 계열이면 threshold, 생성 계열이면 verification contract

## Output Format
호출자에게 반환할 필드와 no-finding 케이스
```

변형:
- explorer/architect 계열: `Core Process`, `Analysis Approach`, `Implementation Map`.
- reviewer 계열: `Review Scope`, `Core Review Responsibilities`, `Confidence Scoring`, `Output Format`.
- advisory-only 계열: "Do not modify code directly" 를 끝에 명시.

### 5.3 섹션 배치 신호

| 신호 | 스킬 | 에이전트 |
|---|---|---|
| 첫 문단 | 목적/핵심 원칙 | `You are ...` 페르소나 |
| 초반 섹션 | when to use, workflow | mission, when to invoke, scope |
| 중반 섹션 | phases/stages, checklist, tables | responsibilities, process, checks |
| 후반 섹션 | references, anti-patterns, testing | output format, advisory constraint |
| 가장 중요한 contract | description trigger | output + scope |

---

## 6. 정량적 지표

### 6.1 원본별 크기

단어/라인 수는 frontmatter 를 제외한 본문 기준이다. description 은 frontmatter 값 기준이다.

| 종류 | 파일 | 본문 words | 본문 lines | desc chars | desc words | tools 수 | model | `<example>` |
|---|---|---:|---:|---:|---:|---:|---|---:|
| agent | `agents/code-simplifier.md` | 405 | 47 | 172 | 21 | 0 | opus | 0 |
| agent | `agents/feature-dev/code-architect.md` | 230 | 27 | 230 | 27 | 10 | sonnet | 0 |
| agent | `agents/feature-dev/code-explorer.md` | 250 | 44 | 195 | 23 | 10 | sonnet | 0 |
| agent | `agents/feature-dev/code-reviewer.md` | 378 | 39 | 208 | 27 | 10 | sonnet | 0 |
| agent | `agents/pr-review-toolkit/code-reviewer.md` | 368 | 50 | 972 | 161 | 0 | opus | 0 |
| agent | `agents/pr-review-toolkit/code-simplifier.md` | 405 | 47 | 2270 | 321 | 0 | opus | 3 |
| agent | `agents/pr-review-toolkit/comment-analyzer.md` | 610 | 73 | 492 | 75 | 0 | inherit | 0 |
| skill | `skills/brainstorming/SKILL.md` | 1522 | 160 | 198 | 26 | 0 | - | 0 |
| skill | `skills/claude-automation-recommender/SKILL.md` | 1443 | 283 | 354 | 55 | 4 | - | 0 |
| skill | `skills/claude-md-improver/SKILL.md` | 810 | 174 | 338 | 48 | 5 | - | 0 |
| skill | `skills/doc-coauthoring/SKILL.md` | 2404 | 371 | 428 | 57 | 0 | - | 0 |
| skill | `skills/skill-creator/SKILL.md` | 5151 | 481 | 319 | 49 | 0 | - | 0 |
| skill | `skills/writing-skills/SKILL.md` | 3193 | 651 | 97 | 14 | 0 | - | 0 |

중복 표본 메모: `agents/code-simplifier.md` 와 `agents/pr-review-toolkit/code-simplifier.md` 는 frontmatter description 이 다르지만 본문은 동일하다. 따라서 에이전트 표본은 파일 기준 7개, 본문 텍스트 다양성 기준으로는 실질 6개다.

### 6.2 집계

| 지표 | 스킬 6개 | 에이전트 7개 |
|---|---:|---:|
| 본문 words 범위 | 810-5151 | 230-610 |
| 본문 words 중앙값 | 1963 | 378 |
| 본문 lines 범위 | 160-651 | 27-73 |
| 본문 lines 중앙값 | 327 | 47 |
| desc words 범위 | 14-57 | 21-321 |
| desc words 중앙값 | 48.5 | 27 |
| tools 명시 | 2/6 | 3/7 |
| model 명시 | 0/6 | 7/7 |
| description 내 `<example>` 사용 | 0/6 | 1/7 |
| 명시적 Output/Report 제목 | 3/6 | 4/7 |

해석:
- 스킬은 에이전트보다 훨씬 길다. 절차, reference pointer, user collaboration, eval loop 를 담기 때문이다.
- 에이전트 본문은 250-700 words 안에 대부분 들어온다.
- 스킬 description 은 14-57 words 로 비교적 안정적이다.
- 에이전트 description 은 세 계열로 갈린다: 짧은 trigger형(21-75 words), 긴 trigger 산문형(161 words, `<example>` 없음), `<example>` 블록 임베드형(321 words, `<example>` 3개).
- 커스텀 에이전트는 model 명시가 사실상 필수 패턴이다.

### 6.3 권고 임계값

이 값은 표본 측정과 작성 가이드의 규범을 함께 반영한 실무 기준이다.

| 대상 | 지표 | 권고 |
|---|---|---|
| 스킬 description | words | 15-60 words. process summary 없이 trigger 중심 |
| 스킬 본문 | lines | 일반 스킬은 가능하면 500 lines 이하. 메타/헌법 스킬은 예외 가능하지만 `writing-skills` 651 lines 처럼 초과하면 outlier 로 취급하고 references 분리를 검토 |
| 빈번 호출 스킬 | words | 더 짧게 유지. getting-started 류는 150-200 words 목표 |
| 일반 스킬 | words | 표본상 800-2500 words 가 많지만, 새로 만들 때는 필요한 만큼만 |
| 메타 스킬 | words/lines | 3000+ words 가능. `skill-creator` 는 5151 words / 481 lines, `writing-skills` 는 3193 words / 651 lines. eval/iteration/reference 구조가 있을 때만 정당화 |
| 에이전트 description | words | 단순형 20-80 words, 긴 산문형은 160 words 안팎, `<example>` 임베드형도 가능하면 300 words 안쪽 |
| 에이전트 본문 | words | 250-700 words |
| 리뷰 confidence cutoff | score | >= 80 만 보고 |
| description examples | count | 0 기본, 모호한 라우팅에서만 1-3개 |

---

## 7. GUIDE.md 검토 입력

`GUIDE.md` 는 이미 많은 내용을 담고 있지만, 현재 구조는 "관측된 시그널" 과 "작성 규칙" 이 섞여 있다. 다음 개선 전에 아래 관점으로 재검토하는 것이 좋다.

### 7.1 잘 된 점

- `writing-skills` 와 `skill-creator` 를 작성 권위로 둔 것은 적절하다.
- 정량 데이터, 지시어 빈도, frontmatter 사용을 직접 측정하려는 접근이 좋다.
- 스킬/에이전트/훅의 책임 경계를 나눈 점이 실제 최적화 작업에 유용하다.
- self-review checklist 와 anti-pattern catalog 는 적용 단계에서 바로 쓸 수 있다.

### 7.2 개선 필요 지점

1. **관측과 규범을 분리해야 한다.**
   - 예: "표본에서 관측됨", "공식/참조 권고", "추론" 을 섹션 단위로 분리하면 신뢰도가 올라간다.

2. **정량값 일부를 재검산해야 한다.**
   - 본문 단어/라인 기준이 frontmatter 포함인지 제외인지 명시되어야 한다.
   - 이 문서 기준으로 스킬 본문 중앙값은 1963 words, 에이전트 본문 중앙값은 378 words 다.

3. **`MUST/SHOULD` 규칙이 너무 앞에 나온다.**
   - 현재 `GUIDE.md` 는 철학보다 규칙이 강하게 보인다.
   - `skill-creator` 의 "MUST 폭격보다 why 설명" 원칙과 톤이 일부 충돌한다.

4. **시그널 digest 가 부족하다.**
   - 사용자가 빠르게 이해할 수 있는 "핵심 철학 / 반복 패턴 / 톤 / 섹션 구성 / 지표" 요약이 앞단에 있어야 한다.

5. **훅 섹션은 표본 관측이 아니라 파생 권고다.**
   - 현재 분석 표본은 스킬/에이전트 중심이다.
   - 훅은 `claude-automation-recommender/references/hooks-patterns.md` 기반 파생 원칙으로 표시하는 편이 정확하다.

6. **에이전트 description 전략을 더 분리해야 한다.**
   - 짧은 trigger형, 긴 trigger 산문형, `<example>` 블록 임베드형은 장단점이 다르다.
   - 셋을 같은 권고로 취급하면 description bloat 를 유도할 수 있다.

7. **적용 순서가 필요하다.**
   - GUIDE 는 원칙을 잘 모았지만, "유저 스코프 최적화에서 무엇부터 바꿀지" 우선순위가 약하다.

8. **STATUS 문서와의 정보 흐름도 점검해야 한다.**
   - `STATUS-2026-05-16.md` 는 작업 목표와 현재 환경 스냅샷, `SIGNALS.md` 는 참고 자원에서 뽑은 작성 시그널, `GUIDE.md` 는 적용 가능한 작성 가이드로 역할을 나누는 편이 좋다.
   - `STATUS` 와 `GUIDE` 에 같은 관측치가 중복될 경우, `STATUS` 는 현재 상태/결정 이력만 남기고 시그널·규범은 `SIGNALS`/`GUIDE` 로 이동시키는 것이 낫다.

### 7.3 제안하는 GUIDE.md 재구성

```markdown
# 효과적 스킬·에이전트·훅 구성 가이드

## 0. Scope / Evidence
- 분석 대상
- 출처 등급: observed / normative / inferred

## 1. Signals From Reference Assets
- 핵심 철학
- 반복 패턴
- 톤과 어조
- 섹션 구성
- 정량 지표

## 2. Decision Framework
- Skill vs Agent vs Hook
- routing / invocation / side-effect 기준

## 3. Authoring Rules
- Skills
- Agents
- Hooks
- Plugins/MCP는 필요 시 별도

## 4. Quantitative Thresholds
- description, body, tools, model, confidence gate

## 5. Review Checklist
- 작성 후 self-review
- anti-pattern catalog

## 6. Application To User Scope
- 현재 유저 스코프 자산에 적용할 우선순위
- keep / merge / remove / rewrite / add-hook 후보
```

### 7.4 다음 개선 작업의 순서

1. 이 `SIGNALS.md` 의 수치와 `GUIDE.md` §1 정량 데이터를 맞춘다.
2. `GUIDE.md` 앞부분에 "Signals From Reference Assets" 섹션을 추가하거나 본 문서를 링크한다.
3. `GUIDE.md` 의 MUST/SHOULD 표는 뒤로 보내고, 앞에는 철학과 결정 프레임워크를 둔다.
4. 훅 원칙은 "관측" 이 아니라 "reference-derived" 로 라벨링한다.
5. `STATUS-2026-05-16.md` 와 중복되는 환경 스냅샷/진행 상태는 `STATUS` 에만 남기고, `GUIDE.md` 는 재사용 가능한 가이드로 유지한다.
6. 마지막에 실제 유저 스코프 최적화 체크리스트를 붙인다.

---

## 8. 재현 명령

분석 수치 재현용:

```bash
ruby -ryaml -e 'files=(Dir["skills/*/SKILL.md"]+Dir["agents/**/*.md"].reject{|p|p.include?("/builtin/")}).sort; puts ["kind","path","words","lines","desc_chars","desc_words","tools_count","model","color","examples"].join("\t"); files.each do |p| s=File.read(p); fm=s[/\A---\n(.*?)\n---/m,1]; y=fm ? YAML.safe_load(fm, aliases: true) : {}; body=fm ? s.sub(/\A---\n.*?\n---\n/m,"") : s; kind=p.start_with?("skills/") ? "skill" : "agent"; tools=(y["tools"]||"").to_s.split(/[ ,]+/).reject(&:empty?); puts [kind,p,body.scan(/\S+/).size,body.lines.size,(y["description"]||"").to_s.length,(y["description"]||"").to_s.split.size,tools.size,(y["model"]||"-"),(y["color"]||"-"),s.scan(/<example>/).size].join("\t"); end'
```

```bash
ruby -e 'files=(Dir["skills/*/SKILL.md"]+Dir["agents/**/*.md"].reject{|p|p.include?("/builtin/")}).sort; puts ["path","MUST","NEVER","ALWAYS","SHOULD","DO_NOT"].join("\t"); files.each do |p| s=File.read(p); counts=[/\bMUST\b/i,/\bNEVER\b/i,/\bALWAYS\b/i,/\bSHOULD\b/i,/(?:DO NOT|Don.t|do not)/i].map{|rx|s.scan(rx).size}; puts ([p]+counts).join("\t"); end'
```
