# 스킬 작성 가이드

생성: 2026-05-16
상위 원칙: `CONSTITUTION.md`
근거 자료: `SIGNALS.md`, `skills/writing-skills/SKILL.md`, `skills/skill-creator/SKILL.md`

이 문서는 유저 스코프 또는 플러그인용 스킬을 만들고 개선할 때 쓰는 실무 가이드다.

---

## 1. 스킬을 만들 때

스킬은 재사용 가능한 판단 절차와 방법론을 담는다.

만들어도 좋은 경우:
- 같은 절차를 여러 프로젝트에서 반복한다.
- 일반 prompting 으로 자주 실패하는 행동을 교정해야 한다.
- 체크리스트, 단계, 승인 gate, 평가 기준이 있다.
- 사용자가 직접 `/skill-name` 으로 호출하거나 Claude 가 자동으로 적용하면 가치가 있다.
- 큰 reference, script, template 을 묶어 재사용할 수 있다.

만들지 말아야 하는 경우:
- 프로젝트 고유 규칙이다. 이 경우 CLAUDE.md 에 둔다.
- 한 번만 쓸 회고나 작업 로그다.
- regex, formatter, typechecker 로 강제할 수 있다. 이 경우 훅이 낫다.
- 별도 컨텍스트에서 specialist 가 일해야 한다. 이 경우 에이전트가 낫다.
- 여러 도메인과 책임이 한 파일에 섞인다.

---

## 2. Frontmatter

최소 구조:

```yaml
---
name: skill-name
description: Use when [trigger conditions, symptoms, contexts, near-misses]
---
```

선택 필드:

```yaml
tools: Read, Glob, Grep, Bash
disable-model-invocation: true
user-invocable: false
allowed-tools: Read, Grep
```

필드 원칙:
- `name` 은 kebab-case 로 쓴다.
- `description` 은 3인칭 trigger 조건으로 쓴다.
- frontmatter 전체는 짧게 유지한다. 기존 가이드 기준으로 1024자를 실질 상한으로 본다.
- `tools` 는 제한이 의미 있을 때만 명시한다. 표본에서는 스킬 2/6 만 tools 를 명시했다.
- 부수 효과가 큰 스킬은 자동 호출을 막거나 승인 gate 를 둔다.
- Claude-only 배경 지식 스킬은 사용자 직접 호출 여부를 제한할 수 있다.

---

## 3. Description 작성

description 은 "언제 쓸지" 를 말한다. "무엇을 어떻게 하는지" 를 요약하지 않는다.

좋은 description:

```yaml
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
```

좋은 특징:
- `Use when ...` 으로 시작한다.
- 사용자가 실제로 말할 상황을 담는다.
- 구체적 증상, 작업 종류, near-miss 를 포함한다.
- 검색될 만한 단어를 포함한다. 에러 메시지, 증상, 동의어, 도구명, 파일 형식이 좋은 신호다.
- workflow 요약이 없다.

나쁜 description:

```yaml
description: Use for skill creation - gather requirements, write SKILL.md, run evals, improve description, package the skill
```

문제:
- 절차를 요약한다.
- 본문을 읽지 않고 description 만 따라갈 위험이 있다.
- trigger 조건보다 내부 구현이 앞선다.

Description 체크:
- 이 스킬을 언제 읽어야 하는지 바로 보이는가?
- 비슷하지만 쓰면 안 되는 경우가 드러나는가?
- 본문 workflow 를 요약하지 않았는가?
- 1인칭으로 쓰지 않았는가? 예: `I can help...`
- 너무 추상적이지 않은가?
- 15-60 words 안에 들어오는가?

---

## 4. 본문 구조

권장 구조:

```markdown
# Skill Title

핵심 목적과 원칙을 1-2문장으로 설명한다.

## When to Use
- Trigger conditions
- When NOT to use
- Near-miss cases

## Workflow
### Phase 1: Discovery / Context
### Phase 2: Analysis / Draft / Execution
### Phase 3: Report / Verify / Iterate

## Output Format
보고서, 체크리스트, 변경 제안, 산출물 구조

## Common Issues / Anti-Patterns
실패 모드와 회피책

## References
필요할 때 읽을 reference/script/assets 포인터
```

변형:
- 협업형 스킬: `Stage 1`, `Stage 2`, `Stage 3` 와 사용자 질문/승인 gate 를 둔다.
- 추천형 스킬: detection table, recommendation table, report template 을 둔다.
- 메타 스킬: test cases, eval loop, description optimization 을 둔다.

본문 첫 부분에서 해야 할 일:
- 이 스킬이 다루는 문제를 설명한다.
- 핵심 원칙을 짧게 제시한다.
- 읽는 사람이 바로 workflow 로 들어갈 수 있게 한다.

---

## 5. 톤과 문체

스킬은 페르소나보다 절차와 판단 기준을 앞세운다.

권장 톤:
- 객관적이고 지시적이다.
- 규칙의 이유를 설명한다.
- 사용자의 선택과 승인 지점을 명확히 한다.
- 강한 명령은 실제 gate 에만 쓴다.

좋은 문장 패턴:
- `Start by ...`
- `If the user declines, work freeform.`
- `Output the report before making updates.`
- `Use this when ...`
- `Do not proceed until ...` 단, 승인이나 safety gate 에만 사용

피해야 할 문장:
- `Always be helpful.`
- `Make it better.`
- `Use your best judgment.` 만 단독으로 쓰기
- 근거 없는 `MUST` / `NEVER` 반복
- 과거 작업 회고

---

## 6. Progressive Disclosure

스킬은 세 단계로 로드된다고 가정한다.

| 단계 | 내용 | 설계 원칙 |
|---|---|---|
| Metadata | name + description | 항상 노출되므로 짧고 정확하게 |
| `SKILL.md` | 주요 절차와 판단 기준 | 호출 시 읽히므로 작고 실행 가능하게 |
| Bundled resources | references/scripts/assets | 필요할 때만 읽거나 실행하게 |

분리 기준:
- 300 lines 이상 reference 는 별도 파일로 분리한다.
- 여러 provider/framework 변형은 `references/aws.md`, `references/gcp.md` 처럼 나눈다.
- 반복적으로 생성되는 helper 는 `scripts/` 에 둔다.
- 템플릿, 이미지, 예시 파일은 `assets/` 에 둔다.
- `@path/to/file` 식 자동 로딩 링크는 피한다. 큰 파일을 의도치 않게 컨텍스트에 올릴 수 있다.

`SKILL.md` 는 reference 전체를 복사하는 곳이 아니라, 어떤 조건에서 어떤 자료를 읽을지 알려주는 index 이기도 하다.

---

## 7. Output Contract

스킬은 사용 후 무엇을 내야 하는지 알려줘야 한다.

예시:

```markdown
## Output Format

Return:
- Summary of what was inspected
- Findings grouped by severity
- Proposed changes
- Questions or approval needed before mutation
```

수정 가능한 스킬은 report before mutation 을 기본값으로 둔다.

```markdown
## Update Gate

1. Inspect files
2. Output a quality report
3. Propose targeted updates
4. Apply updates only after approval
```

no-op 케이스도 명시한다.

```markdown
If no changes are needed, say so and list the evidence checked.
```

---

## 8. Testing And Iteration

스킬은 행동을 바꾸기 위해 작성한다.

권장 루프:

1. 스킬 없이 baseline prompt 를 실행해 실패를 관찰한다.
2. 실패 원인과 합리화 패턴을 기록한다.
3. 그 실패를 막는 최소 지침을 쓴다.
4. 같은 prompt 로 다시 실행해 통과 여부를 본다.
5. near-miss 와 pressure scenario 를 추가한다.
6. description triggering 을 별도로 검증한다.

테스트 프롬프트:
- 2-3개 현실적인 prompt 로 시작한다.
- should-trigger 와 should-not-trigger 를 모두 만든다.
- negative case 는 완전히 무관한 prompt 가 아니라 헷갈릴 만한 near-miss 로 만든다.

Trigger eval 을 만들 때는 20개 안팎을 기준으로 삼는다.

```json
[
  {"query": "사용자가 실제로 입력할 법한 should-trigger prompt", "should_trigger": true},
  {"query": "비슷한 키워드가 있지만 다른 자원이 맞는 near-miss", "should_trigger": false}
]
```

좋은 eval 은 구체적인 파일명, 작업 맥락, 약간의 모호함을 포함한다. 너무 쉬운 negative case 는 description 품질을 검증하지 못한다.

검증할 것:
- 스킬이 예상 상황에서 호출되는가?
- 본문을 읽고 workflow 를 따르는가?
- 승인 gate 를 지키는가?
- 불필요하게 장황하거나 반복 작업을 만들지 않는가?
- 다른 스킬/에이전트와 책임이 겹치지 않는가?

---

## 9. 정량 기준

| 항목 | 권장 |
|---|---|
| description | 15-60 words |
| 일반 스킬 본문 | 가능하면 500 lines 이하 |
| 빈번 호출 스킬 | 150-200 words 목표 |
| 일반 스킬 단어 수 | 새로 만들 때는 필요한 만큼만. 표본은 800-2500 words 가 많음 |
| 메타 스킬 | 3000+ words 가능하나 eval/iteration/reference 구조가 있을 때만 정당화 |
| tools 명시 | 제한이 의미 있을 때만. 표본은 2/6 |
| `<example>` in description | 기본 0 |
| flowchart | 비자명한 결정 지점에만 사용 |

`writing-skills` 처럼 500 lines 를 넘는 메타 스킬은 outlier 다. 새 스킬이 이 길이에 접근하면 references 분리를 먼저 검토한다.

---

## 10. 체크리스트

작성 전:
- [ ] 이 정보가 CLAUDE.md 가 아니라 스킬에 들어가야 하는가?
- [ ] hook 으로 결정론적으로 강제할 수 없는가?
- [ ] 별도 specialist 에이전트가 필요한 작업은 아닌가?
- [ ] 여러 프로젝트에서 재사용되는가?

Frontmatter:
- [ ] `name` 은 kebab-case 인가?
- [ ] `description` 은 trigger 조건인가?
- [ ] description 에 workflow 요약이 없는가?
- [ ] near-miss 또는 negative case 가 보이는가?
- [ ] 부수 효과가 있으면 invocation control 이 있는가?

본문:
- [ ] When to Use / When NOT to Use 가 있는가?
- [ ] Workflow 단계가 입력, 작업, 산출물로 나뉘는가?
- [ ] Output Format 또는 report structure 가 있는가?
- [ ] approval gate 가 필요한 경우 명시했는가?
- [ ] 큰 자료를 references/scripts/assets 로 분리했는가?
- [ ] anti-pattern 과 common mistake 를 적었는가?

검증:
- [ ] baseline 실패를 관찰했는가?
- [ ] should-trigger / should-not-trigger 케이스가 있는가?
- [ ] no-op 케이스가 정의되어 있는가?
- [ ] 다른 스킬이나 에이전트와 책임이 겹치지 않는가?

---

## 11. 안티패턴

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Description-as-runbook | description 이 절차 요약 | trigger 조건만 남긴다 |
| Narrative skill | 과거 작업 회고 중심 | reusable rule/process 로 바꾼다 |
| Must-bombing | MUST/NEVER 반복 | 이유와 실패 모드 설명으로 바꾼다 |
| Reference dump | SKILL.md 에 긴 자료 복사 | references 로 분리한다 |
| Auto-load link | `@path` 로 큰 파일을 자동 로딩 | 필요 시 읽을 reference 포인터로 바꾼다 |
| Multi-language dilution | 같은 예시를 여러 언어로 반복 | 가장 좋은 예시 하나만 남긴다 |
| Multi-domain sprawl | 한 스킬이 여러 도메인 처리 | selector + references 또는 별도 스킬로 분리 |
| No output contract | 실행 후 무엇을 낼지 불명확 | Output Format 추가 |
| Hidden mutation | 보고 없이 파일 수정 | report/approval gate 추가 |
| Project convention leak | 프로젝트 고유 규칙 포함 | CLAUDE.md 로 이동 |
