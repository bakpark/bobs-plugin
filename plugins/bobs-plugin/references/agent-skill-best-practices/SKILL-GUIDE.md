# 스킬 작성 가이드 v2

생성: 2026-05-16
상위 원칙: `CONSTITUTION.md`
성격: 스킬 작성과 개선을 위한 타입별 실무 가이드

이 문서는 `CONSTITUTION.md` 의 공통 원칙을 스킬에 적용하는 방법을 설명한다. 스킬은 필요할 때 로드되는 판단 절차와 방법론이다.

---

## 1. 스킬의 역할

스킬은 메인 에이전트의 행동 방식을 바꾸는 재사용 가능한 방법론이다.

스킬에 적합한 것:
- 여러 프로젝트에서 반복되는 workflow
- 일반 prompting 으로 자주 실패하는 행동을 교정하는 절차
- 판단 기준, checklist, approval gate
- reference, script, template bundle
- 사용자가 직접 호출하거나 모델이 필요 시 자동 적용할 방법론
- trigger eval, pressure scenario, baseline comparison 으로 검증할 수 있는 행동

스킬에 부적합한 것:
- 프로젝트 고유 규칙이나 명령. 이 경우 CLAUDE.md 에 둔다.
- 단발성 작업 기록이나 회고.
- formatter, regex, typecheck 로 결정론적으로 강제할 수 있는 일. 이 경우 훅을 고려한다.
- 별도 컨텍스트의 specialist 판단이 필요한 일. 이 경우 에이전트를 고려한다.
- 서로 다른 도메인과 책임이 한 skill body 에 섞이는 경우.

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
- `name` 은 짧고 검색 가능한 kebab-case 로 쓴다.
- `description` 은 activation signal 이다. 스킬을 언제 읽어야 하는지 드러내야 한다.
- `tools` 는 capability surface 를 줄이는 의미가 있을 때 명시한다.
- 부수 효과가 큰 스킬은 자동 호출 제한, 사용자 직접 호출, approval gate 중 하나를 설명한다.
- frontmatter 는 항상 노출되는 metadata 이므로 짧게 유지한다.

주의:
- `tools` 명시는 필수 필드가 아니다. 다만 read-only 나 mutation 제한이 중요하면 명시하는 편이 낫다.
- description 길이는 진단 신호다. 긴 description 이 항상 실패는 아니지만, workflow 를 대신 실행하게 만들면 문제다.

---

## 3. Description 작성

description 은 스킬을 설명하는 홍보문이 아니라 activation signal 이다.

좋은 description 이 답하는 질문:
- 어떤 사용자 요청에서 이 스킬이 필요해지는가?
- 어떤 증상, 파일, 작업 종류, 도구명이 trigger 인가?
- 비슷하지만 다른 스킬이 맞는 near-miss 는 무엇인가?
- 본문을 읽지 않고도 workflow 를 실행하게 만들 정도로 절차를 요약하고 있지는 않은가?

권장 패턴:

```yaml
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
```

피해야 할 패턴:

```yaml
description: Use for skill creation - gather requirements, write SKILL.md, run evals, improve description, package the skill
```

문제는 `Use when` 여부가 아니라 workflow shortcut 이다. description 이 내부 절차를 나열하면 모델이 본문을 읽지 않고 description 만 따라갈 수 있다.

체크:
- 스킬을 언제 읽어야 하는지 바로 보이는가?
- 본문 workflow 를 요약하지 않는가?
- 1인칭 홍보문이 아닌가?
- 검색될 단어가 있는가?
- near-miss 가 실제로 있다면 드러나는가?

---

## 4. Body 설계

스킬 본문은 반드시 특정 섹션명을 가져야 하는 것은 아니다. 다만 아래 기능은 보여야 한다.

필수 기능:
- 목적과 핵심 원칙
- activation 조건 또는 use cases
- workflow 또는 판단 절차
- output contract
- 부수 효과가 있으면 gate
- 실패 모드 또는 anti-pattern
- 필요한 reference/script/assets 로 가는 선택자

권장 구조:

```markdown
# Skill Title

1-2문장으로 목적과 핵심 원칙.

## When to Use
- Trigger conditions
- Near-miss or when not to use

## Workflow
### Phase 1: Context
### Phase 2: Analysis / Execution
### Phase 3: Report / Verify / Iterate

## Output Contract
보고서, 체크리스트, 변경 제안, 승인 요청, no-op 형식

## Common Failures
실패 모드와 회피책

## References
필요할 때 읽을 bundled resource
```

허용되는 변형:
- 협업형 스킬: `Stage 1`, `Stage 2`, `Stage 3` 과 사용자 선택 지점.
- 추천형 스킬: detection table, decision framework, recommendation template.
- 메타 스킬: baseline, pressure scenario, eval loop, description optimization.
- 교육형 스킬: 핵심 원칙, 예시, common rationalization, verification loop.

형식보다 중요한 것은 읽은 뒤 바로 행동이 바뀌는가다.

---

## 5. Effects And Gates

스킬이 파일 수정, 설정 변경, 외부 요청, hook 등록, commit 같은 부수 효과를 만들 수 있다면 gate 를 둔다.

기본 흐름:

```markdown
1. Inspect
2. Report findings or proposal
3. Ask for approval or require explicit invocation
4. Apply changes
5. Verify
```

read-only 스킬:
- frontmatter 또는 본문에서 read-only 성격을 명확히 한다.
- 변경 제안은 가능하지만 직접 mutation 하지 않는다.
- no-op 또는 no-finding case 를 둔다.

수정 가능한 스킬:
- 어떤 파일이나 설정을 바꿀 수 있는지 좁힌다.
- report-before-mutation 을 기본으로 둔다.
- 사용자가 이미 명시적으로 수정을 요청한 경우와 자동 호출되는 경우를 구분한다.

---

## 6. Progressive Disclosure

스킬은 세 단계로 노출된다고 가정한다.

| 단계 | 내용 | 설계 기준 |
|---|---|---|
| Metadata | name + description | 항상 노출되므로 짧고 정확하게 |
| `SKILL.md` | 핵심 workflow 와 판단 기준 | 호출 시 읽히므로 실행 가능하게 |
| Bundled resources | references/scripts/assets | 필요할 때만 읽거나 실행 |

분리할 것:
- 긴 reference 문서
- schema, API 문서, provider별 차이
- 반복 실행하는 script
- template, image, sample output
- 여러 변형 중 일부 상황에서만 필요한 자료

본문에 남길 것:
- 언제 어떤 resource 를 읽을지
- 핵심 판단 기준
- failure mode
- gate 와 output contract

`@path` 같은 자동 로딩 링크는 신중히 쓴다. 큰 파일이 의도치 않게 context 에 올라갈 수 있다.

---

## 7. Output Contract

스킬은 실행 후 무엇을 남길지 알려야 한다.

Output contract 는 꼭 `Output Format` 제목일 필요가 없다. workflow 내부의 report template, update gate, checklist, no-op 지시도 가능하다.

좋은 output contract:

```markdown
Return:
- What was inspected
- Findings grouped by severity
- Proposed changes
- Approval needed before mutation
- Evidence for no-op if no changes are needed
```

수정형 스킬의 gate 예:

```markdown
1. Output a quality report.
2. Propose targeted updates.
3. Apply updates only after user approval.
4. Verify the result.
```

---

## 8. Verification

스킬은 행동을 바꾸기 위해 작성한다. 가능하면 검증 루프를 둔다.

권장 루프:
1. 스킬 없이 baseline prompt 를 실행해 실패를 관찰한다.
2. 실패 원인과 합리화 패턴을 기록한다.
3. 그 실패를 막는 최소 지침을 쓴다.
4. 같은 prompt 로 다시 실행해 통과 여부를 본다.
5. near-miss 와 pressure scenario 를 추가한다.
6. description triggering 을 별도로 검증한다.

테스트 케이스:
- should-trigger
- should-not-trigger
- near-miss
- pressure scenario
- no-op case

Rationalization table 은 discipline 이 필요한 스킬에서 특히 유용하다.

```markdown
| Rationalization | Counter-instruction | Test case |
|---|---|---|
| "This is too small to need the workflow" | Small tasks still need the gate if mutation follows | ... |
```

이 패턴은 모든 스킬에 필수는 아니다. 모델이 우회하거나 shortcut 을 만들 가능성이 큰 스킬에 쓴다.

---

## 9. Quantitative Heuristics

수치는 hard rule 이 아니라 검토 신호다.

| 항목 | 진단 기준 |
|---|---|
| description | 보통 15-60 words 면 충분하다 |
| 빈번 호출 스킬 | 짧을수록 좋다. 150-200 words 수준을 목표로 할 수 있다 |
| 일반 스킬 본문 | 가능하면 핵심 workflow 중심으로 유지한다 |
| 긴 메타/교육형 스킬 | eval, reference, verification 구조가 있으면 길 수 있다 |
| tools | 제한이 의미 있을 때 명시한다 |
| flowchart | 비자명한 분기에서만 쓴다 |

길이가 문제가 되는 경우:
- 핵심 workflow 를 찾기 어렵다.
- reference 로 분리 가능한 자료가 본문을 압도한다.
- 자주 호출되는데 context 비용이 크다.
- 같은 지침이 반복되어 행동 개선 없이 노이즈가 된다.

---

## 10. Checklist

작성 전:
- [ ] 이 정보가 CLAUDE.md 가 아니라 스킬에 들어갈 재사용 절차인가?
- [ ] hook 으로 결정론적으로 강제할 수 없는가?
- [ ] 별도 specialist 에이전트가 필요한 작업은 아닌가?
- [ ] activation 조건이 분명한가?

Frontmatter:
- [ ] `name` 이 짧고 검색 가능한가?
- [ ] `description` 이 activation signal 인가?
- [ ] workflow shortcut 을 만들지 않는가?
- [ ] capability 제한이 필요하면 tools/invocation control 이 있는가?

본문:
- [ ] 목적과 핵심 원칙이 초반에 있는가?
- [ ] workflow 가 실행 가능한가?
- [ ] output contract 가 있는가?
- [ ] 부수 효과가 있으면 gate 가 있는가?
- [ ] 큰 resource 는 분리되어 있는가?
- [ ] near-miss 또는 anti-pattern 이 필요한 경우 들어 있는가?

검증:
- [ ] should-trigger / should-not-trigger 를 생각했는가?
- [ ] no-op case 가 있는가?
- [ ] 다른 스킬, 에이전트, 훅과 overlap 이 설명되는가?
- [ ] 긴 스킬이라면 길이를 정당화하는 구조가 있는가?

---

## 11. Anti-Patterns

| Anti-pattern | 증상 | 수정 |
|---|---|---|
| Description-as-runbook | description 이 절차를 나열 | trigger 조건만 남긴다 |
| Narrative skill | 과거 작업 회고 중심 | reusable method 로 바꾼다 |
| Unscoped workflow | 무엇에 적용되는지 불명확 | scope 와 near-miss 추가 |
| Must-bombing | 모든 지침이 MUST/NEVER | gate 와 일반 원칙을 분리 |
| Reference dump | `SKILL.md` 에 긴 자료 복사 | references 로 분리 |
| Hidden mutation | 보고 없이 파일 수정 | report/approval gate 추가 |
| Project convention leak | 프로젝트 고유 규칙 포함 | CLAUDE.md 로 이동 |
| No output contract | 실행 후 결과가 매번 다름 | report/no-op 형식 추가 |
| Dead skill | 호출 조건이 없어 발견되지 않음 | activation signal 재작성 또는 제거 후보 |
