# 서브에이전트 작성 가이드

생성: 2026-05-16
상위 원칙: `CONSTITUTION.md`
근거 자료: `SIGNALS.md`, `agents/`, `skills/claude-automation-recommender/references/subagent-templates.md`

이 문서는 유저 스코프 또는 플러그인용 서브에이전트를 만들고 개선할 때 쓰는 실무 가이드다.

---

## 1. 에이전트를 만들 때

에이전트는 별도 컨텍스트에서 특정 역할을 수행하는 specialist 다.

만들어도 좋은 경우:
- 분석, 리뷰, 생성 작업을 메인 세션과 분리해야 한다.
- 병렬로 돌릴 수 있는 독립 작업이다.
- tool 권한을 read-only 또는 특정 범위로 제한해야 한다.
- model 선택이 중요하다.
- 호출자에게 구조화된 산출물을 반환해야 한다.
- false positive 를 줄이기 위한 전문 판단 기준이 필요하다.

만들지 말아야 하는 경우:
- 단순 reference 나 절차다. 이 경우 스킬이 낫다.
- 프로젝트 고유 규칙이다. 이 경우 CLAUDE.md 가 낫다.
- 매 이벤트마다 자동 실행되어야 한다. 이 경우 훅이 낫다.
- scope 가 너무 넓어 "모든 것을 분석" 해야 한다.
- 다른 에이전트를 임의로 호출하는 orchestrator 역할이다.

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
---
```

필드 원칙:
- `name` 은 역할명으로 쓴다. 예: `code-reviewer`, `comment-analyzer`, `code-explorer`.
- `description` 은 호출 조건과 near-miss 를 담는다.
- `tools` 는 역할에 맞게 줄인다.
- `model` 은 명시한다. 표본의 커스텀 에이전트 7/7 이 model 을 명시했다.
- `color` 는 UI hint 이며 선택 사항이다. 표본에서는 4/7 이 사용했다.

---

## 3. Description 전략

description 은 호출자에게 "언제 이 에이전트를 써야 하는지" 알려주는 라우팅 계약이다.

세 가지 유형이 있다.

| 유형 | 길이 | 용도 |
|---|---:|---|
| 짧은 trigger형 | 20-80 words | 역할이 명확하고 near-miss 가 적을 때 |
| 긴 trigger 산문형 | 160 words 안팎 | 호출 조건과 scope 설명이 필요한 경우 |
| `<example>` 블록 임베드형 | 300 words 안쪽 권장 | 라우팅이 자주 헷갈리는 경우 |

기본은 짧은 trigger형이다. `<example>` 은 비용이 크므로 모호한 도메인에서만 쓴다.

좋은 description:

```yaml
description: Reviews code for bugs, logic errors, security vulnerabilities, code quality issues, and adherence to project conventions, using confidence-based filtering to report only high-priority issues that truly matter
```

더 명시적인 description:

```yaml
description: Use this agent when you need to analyze code comments for accuracy, completeness, and long-term maintainability. Use after generating large documentation comments, before finalizing a PR that modifies comments, or when checking for comment rot. Do not use for general code review.
```

Description 체크:
- 호출 조건이 구체적인가?
- 비슷하지만 호출하면 안 되는 경우가 있는가?
- 입력으로 무엇을 넘겨야 하는지 암시되는가?
- 본문에 있는 process 를 과하게 요약하지 않았는가?
- 너무 긴 예시로 카탈로그 비용을 늘리지 않았는가?
- 500 words 를 넘지 않는가? 그 이상이면 본문 `When to invoke` 로 옮긴다.

---

## 4. 본문 구조

권장 구조:

```markdown
You are an expert [role] specializing in [bounded domain].

## When to invoke
- Scenario 1
- Scenario 2
- Scenario 3

## Scope / Mission
기본 입력 범위와 제외 범위

## Core Responsibilities / Process
1. ...
2. ...
3. ...

## Confidence / Quality Gate
리뷰 계열이면 threshold, 생성 계열이면 verification contract

## Output Format
호출자에게 반환할 필드와 no-finding 케이스
```

본문 첫 문단:
- `You are ...` 로 역할을 선언한다.
- 전문 영역을 좁힌다.
- 가장 중요한 책임을 한 문장으로 말한다.

좋은 시작:

```markdown
You are an expert code reviewer specializing in modern software development across multiple languages and frameworks. Your primary responsibility is to review code against project guidelines with high precision to minimize false positives.
```

---

## 5. Scope 설계

에이전트 품질은 scope 로 결정된다.

좋은 scope:
- `By default, review unstaged changes from git diff.`
- `Only refine code that has been recently modified.`
- `Analyze comments and docstrings only.`
- `Trace this feature from entry points to data storage.`

나쁜 scope:
- `Review the whole codebase.`
- `Analyze everything thoroughly.`
- `Improve quality wherever possible.`
- `Find all possible issues.`

Scope 에 포함할 것:
- 기본 입력 범위
- 사용자가 override 할 수 있는 범위
- 제외할 작업
- pre-existing issue 처리 방식
- no-finding 처리 방식

---

## 6. Tool 권한

도구는 역할에 맞게 줄인다.

| 역할 | 권장 tools | 설명 |
|---|---|---|
| 검색/탐색 | `Read`, `Grep`, `Glob`, `LS` | read-only |
| 코드 리뷰 | `Read`, `Grep`, `Glob`, 선택적 `Bash` | 수정 권한 없음 |
| 문서/테스트 생성 | `Read`, `Write`, `Grep`, `Glob` | 생성 작업에 한정 |
| 마이그레이션 | `Read`, `Write`, `Grep`, `Glob`, `Bash` | 복잡하고 위험하므로 scope/gate 필요 |
| 범용 | `*` | 커스텀 에이전트에서는 가급적 피함 |

원칙:
- 리뷰/분석 에이전트는 read-only 로 둔다.
- 쓰기 권한이 있으면 어떤 파일을 쓸 수 있는지 mission 에서 좁힌다.
- `tools: *` 는 catch-all 역할이 명확할 때만 정당화된다.
- 권한이 넓을수록 output/approval gate 를 강하게 둔다.

---

## 7. Model 선택

기본은 `sonnet` 이다.

| Model | 적합한 작업 | Trade-off |
|---|---|---|
| `haiku` | 단순 반복 검사 | 빠르고 저렴하지만 덜 깊음 |
| `sonnet` | 대부분의 분석/리뷰 | 균형점 |
| `opus` | 복잡한 아키텍처, 마이그레이션, 높은 정밀도 리뷰 | 느리고 비쌈 |
| `inherit` | 호출자 모델과 일치해야 하는 보조 분석 | 결정성이 낮아질 수 있음 |

표본에서는 커스텀 에이전트 7/7 이 model 을 명시했다. 새 에이전트도 model 을 명시하고, 왜 그 model 인지 설명할 수 있어야 한다.

---

## 8. Output Contract

에이전트는 호출자에게 쓸 수 있는 결과를 반환해야 한다.

리뷰 에이전트 예시:

```markdown
## Output Format

Start by stating what you reviewed. For each high-confidence issue provide:

- Clear description and confidence score
- File path and line number
- Specific project guideline reference or bug explanation
- Concrete fix suggestion

Group issues by severity. If no high-confidence issues exist, say so clearly.
```

탐색 에이전트 예시:

```markdown
## Output Guidance

Include:
- Entry points with file:line references
- Step-by-step execution flow
- Key components and responsibilities
- Essential files to read next
```

Output contract 에 포함할 것:
- scope summary
- findings 또는 result fields
- file/line reference 형식
- confidence/severity 기준
- no-finding case
- follow-up recommendation 여부

---

## 9. Confidence Gate

리뷰/분석 에이전트는 false positive 를 줄여야 한다.

권장 패턴:

```markdown
## Confidence Scoring

Rate each issue from 0-100.

- 0-25: likely false positive or pre-existing issue
- 26-50: minor nitpick
- 51-75: valid but low-impact
- 76-90: important issue
- 91-100: critical bug or explicit guideline violation

Only report issues with confidence >= 80.
```

Confidence 는 severity 와 다르다.

- severity: 문제가 발생했을 때 영향이 얼마나 큰가
- confidence: 이 문제가 실제로 존재한다는 확신이 얼마나 높은가

낮은 confidence 의 critical-sounding issue 는 보고하지 않는다. high-signal review 가 low-signal exhaustive review 보다 낫다.

---

## 10. CLAUDE.md 연동

코드 리뷰, 코드 단순화, 프로젝트 convention 검사 에이전트는 CLAUDE.md 를 source of truth 로 취급해야 한다.

권장 문장:

```markdown
Review code against explicit project rules in CLAUDE.md or equivalent project memory.
```

주의:
- CLAUDE.md 에 없는 스타일 선호를 강제하지 않는다.
- 프로젝트 규칙과 일반 best practice 를 구분한다.
- pre-existing issue 는 새 변경과 분리한다.
- CLAUDE.md 자체를 개선하는 일은 별도 스킬이나 에이전트로 분리한다.

---

## 11. 정량 기준

| 항목 | 권장 |
|---|---|
| 본문 | 250-700 words |
| 짧은 description | 20-80 words |
| 긴 trigger 산문 | 160 words 안팎 |
| `<example>` 임베드 description | 가능하면 300 words 안쪽 |
| `<example>` 개수 | 기본 0, 모호할 때 1-3 |
| description 절대 상한 | 500 words 미만 |
| model | 명시. 표본 7/7 |
| tools | 역할에 맞게 축소. 표본 3/7 명시 |
| confidence cutoff | 리뷰 계열은 >= 80 |
| 명시적 Output/Report 제목 | 권장. 표본 4/7 |

비싼 에이전트나 장기 분석 에이전트는 재사용 가능성을 description 또는 본문에 적을 수 있다. 같은 주제의 에이전트가 이미 실행 중이거나 최근 완료되었다면 새로 만들지 말고 이어서 쓰는 방식이 비용과 컨텍스트 중복을 줄인다.

---

## 12. 체크리스트

작성 전:
- [ ] 스킬이 아니라 에이전트가 필요한 이유가 있는가?
- [ ] 별도 컨텍스트, specialist role, tool/model 격리가 필요한가?
- [ ] 프로젝트 고유 정보가 아니라 재사용 가능한 역할인가?
- [ ] scope 를 좁힐 수 있는가?

Frontmatter:
- [ ] `name` 이 역할을 드러내는가?
- [ ] `description` 이 호출 조건을 말하는가?
- [ ] near-miss 또는 negative case 가 있는가?
- [ ] `model` 이 명시되어 있는가?
- [ ] `tools` 가 과하지 않은가?
- [ ] `color` 를 쓴다면 선택적 UI hint 로만 쓰는가?

본문:
- [ ] `You are ...` 로 시작하는가?
- [ ] mission 과 scope 가 초반에 나오는가?
- [ ] 기본 입력 범위가 명시되어 있는가?
- [ ] Core responsibilities 가 3-5개 안에 들어오는가?
- [ ] Output Format 또는 Output Guidance 가 있는가?
- [ ] no-finding case 가 있는가?
- [ ] 리뷰/분석 계열이면 confidence gate 가 있는가?

운영:
- [ ] 다른 에이전트를 임의로 호출하지 않는가?
- [ ] 수정 권한이 있다면 승인 또는 제한이 있는가?
- [ ] CLAUDE.md 와의 관계가 명확한가?
- [ ] pre-existing issue 와 새 변경을 구분하는가?

---

## 13. 안티패턴

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Generalist agent | 모든 분석/수정/리뷰를 다 함 | specialist 로 분리 |
| All-tools reviewer | 리뷰 에이전트가 Write/Bash 전권 보유 | read-only 로 제한 |
| No model choice | model 생략 | role 에 맞는 model 명시 |
| No scope | 전체 코드베이스를 막연히 분석 | 입력 범위와 제외 범위 지정 |
| No output contract | 결과 형식이 매번 달라짐 | Output Format 추가 |
| Low-confidence spam | nit 과 추측을 많이 보고 | confidence >= 80 gate |
| Description bloat | 예시가 너무 많아 카탈로그 비용 증가 | 본문으로 이동하거나 1-3개 제한 |
| Agent as runbook | 단순 절차를 에이전트로 만듦 | 스킬로 이동 |
| Hidden mutation | advisory 역할인데 파일 수정 | role 을 advisory 로 고정하거나 worker 로 분리 |
| Dead asset | 정의는 있지만 호출 경로가 없음 | 라우팅 설명을 고치거나 제거 후보로 표시 |
