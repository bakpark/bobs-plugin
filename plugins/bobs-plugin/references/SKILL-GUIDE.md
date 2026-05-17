# 스킬 작성 가이드 v2.1

생성: 2026-05-16
개정: 2026-05-17
상위 원칙: `CONSTITUTION.md`
성격: 스킬 작성과 개선을 위한 타입별 실무 가이드

이 문서는 `CONSTITUTION.md` 의 공통 원칙을 스킬에 적용하는 방법을 설명한다. 스킬은 모델이 필요를 감지했을 때 자동 활성화되는 능력 확장 모듈이다.

---

## 1. 스킬의 역할

스킬은 메인 에이전트나 하위 에이전트의 능력을 확장하는 재사용 가능한 capability module 이다. 기본값은 사용자 직접 workflow 가 아니라 모델 자동 활성화다.

스킬에 적합한 것:
- 프로젝트와 직접 결합되지 않는 외부 인프라, API, SDK, provider 사용 능력
- 도메인 특화 분석, 변환, 검증, 생성 능력
- 일반 prompting 으로 자주 실패하는 행동을 교정하는 재사용 절차
- 판단 기준, checklist, approval gate
- reference, script, template bundle
- command 나 agent 가 workflow 중 호출하는 helper capability
- 모델이 필요 시 자동 적용할 방법론
- trigger eval, pressure scenario, baseline comparison 으로 검증할 수 있는 행동

스킬에 부적합한 것:
- 프로젝트 고유 규칙이나 명령. 이 경우 CLAUDE.md 에 둔다.
- 사용자가 명시 호출하는 workflow entrypoint. 이 경우 커맨드를 고려한다.
- 사용자 질문, 인자 수집, plan gate, 단계 진행을 포함하는 팀 workflow. 이 경우 커맨드가 낫다.
- 프로젝트 문서 링크를 모아 context 를 주입하는 라우터. 이 경우 커맨드 또는 context map 이 낫다.
- 단발성 작업 기록이나 회고.
- formatter, regex, typecheck 로 결정론적으로 강제할 수 있는 일. 이 경우 훅을 고려한다.
- 별도 컨텍스트의 specialist 판단이 필요한 일. 이 경우 에이전트를 고려한다.
- 서로 다른 도메인과 책임이 한 skill body 에 섞이는 경우.

---

## 2. Skill Categories

스킬은 같은 형식의 파일이지만 책임 유형이 다를 수 있다. 유형을 먼저 정하면 scope, gate, references 설계가 쉬워진다.

| 유형 | 예 | 특히 확인할 것 |
|---|---|---|
| Library / API Reference | 특정 SDK, API 사용법 | version/source, provider별 차이 |
| Product Verification | browser, API, checkout flow 검증 능력 | 실제 검증 도구, 실패 증거 |
| Data Fetching / Analysis | 외부 데이터 수집과 요약 | network gate, freshness |
| Business Process Helper | 외부 시스템이나 표준 절차의 실행 보조 | command 와 role boundary |
| Scaffolding / Templates | 파일/구조 생성 | overwrite policy, output path |
| Code Quality / Review | 리뷰, 테스트, 리팩터링 기준 | false-positive gate |
| CI/CD / Deployment Helper | CI provider, release tool, deploy API 사용 | explicit invocation, rollback, audit |
| Runbook Helper | 장애 대응 도구나 외부 운영 절차 보조 | preconditions, stop path |
| Infrastructure Operations | cloud, container, permission 작업 | least privilege, approval gate |

분류는 taxonomy 일 뿐 hard rule 은 아니다. 그러나 business process, CI/CD, deployment, runbook 처럼 workflow 성격이 강한 유형은 command 가 entrypoint 를 맡고, skill 은 외부 도구·도메인 능력만 제공하는 구조를 먼저 검토한다. 부수 효과가 큰 유형은 자동 호출 제한과 승인 gate 를 기본으로 검토한다.

---

## 3. Skill vs Command Boundary

스킬과 커맨드가 모두 markdown 자산처럼 보여도 책임은 다르다.

| 질문 | Command | Skill |
|---|---|---|
| 누가 시작하는가? | 사용자가 직접 호출 | 모델이 필요를 감지해 자동 활성화 |
| 주 책임 | workflow 진행, 사용자 질문, plan gate | 외부 인프라·도메인 특화 능력 확장 |
| context 역할 | 문서 링크와 selector 를 모아 주입 | 자체 references/scripts/assets 를 필요 시 로드 |
| orchestration | agent/skill/tool 호출 순서 조정 | command/agent 에서 호출되는 helper capability |
| 프로젝트 결합도 | 프로젝트 workflow 와 문서 구조를 알아도 됨 | 프로젝트 고유 기억은 피하고 범용 능력으로 유지 |

경계 규칙:
- 사용자가 "이 workflow 를 실행해줘" 라고 말하면 command 를 먼저 고려한다.
- 사용자가 특정 API, provider, 도메인 작업을 하며 모델이 능력 확장을 필요로 하면 skill 을 고려한다.
- command 는 관련 문서 링크를 넘기고, skill 은 그 링크를 영구 정책처럼 저장하지 않는다.
- skill 이 사용자 질문, 단계 승인, agent dispatch 를 직접 관리하기 시작하면 command 로 승격하거나 분리한다.
- command 가 provider/API/domain 세부 사용법을 길게 담기 시작하면 skill 로 분리한다.

---

## 4. Frontmatter

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
context: fork
paths:
  - references/provider-a.md
hooks:
  - .claude/hooks/skill-specific-hook.sh
shell:
  command: scripts/helper.sh
```

필드 원칙:
- `name` 은 짧고 검색 가능한 kebab-case 로 쓴다.
- `description` 은 activation signal 이다. 스킬을 언제 읽어야 하는지 드러내야 한다.
- `tools` 는 capability surface 를 줄이는 의미가 있을 때 명시한다.
- `context: fork` 는 main context 오염을 줄일 필요가 있을 때만 사용하고, 반환할 결론 형식을 본문에 둔다.
- `paths`, references, scripts 는 필요한 순간 읽을 selector 를 본문에 둔다.
- `hooks` 나 `shell` 은 on-demand automation 이므로 부수 효과, runtime 호환성, failure behavior 를 설명한다.
- 부수 효과가 큰 스킬은 자동 호출 제한, 사용자 직접 호출, approval gate 중 하나를 설명한다.
- frontmatter 는 항상 노출되는 metadata 이므로 짧게 유지한다.

주의:
- `user-invocable` 은 예외적 편의다. 사용자가 시작하는 workflow 는 기본적으로 command 로 만든다.
- `tools` 명시는 필수 필드가 아니다. 다만 read-only 나 mutation 제한이 중요하면 명시하는 편이 낫다.
- platform 별 frontmatter 필드는 runtime 변화에 민감하다. 지원 여부를 확인하지 못했으면 hard rule 로 평가하지 않는다.
- description 길이는 진단 신호다. 긴 description 이 항상 실패는 아니지만, workflow 를 대신 실행하게 만들면 문제다.

---

## 5. Description 작성

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

## 6. Body 설계

스킬 본문은 반드시 특정 섹션명을 가져야 하는 것은 아니다. 다만 아래 기능은 보여야 한다.

필수 기능:
- 목적과 핵심 원칙
- activation 조건 또는 use cases
- capability procedure 또는 판단 절차
- output contract
- 부수 효과가 있으면 gate
- 실패 모드 또는 anti-pattern
- 자주 틀리는 gotchas
- 필요한 설정이나 credential 이 있다면 setup/config 확인법
- 필요한 reference/script/assets 로 가는 선택자

권장 구조:

```markdown
# Skill Title

1-2문장으로 목적과 핵심 원칙.

## When to Use
- Trigger conditions
- Near-miss or when not to use

## Capability Procedure
### Phase 1: Context
### Phase 2: Analysis / Execution
### Phase 3: Report / Verify / Iterate

## Output Contract
보고서, 체크리스트, 변경 제안, 승인 요청, no-op 형식

## Common Failures
실패 모드와 회피책

## Gotchas
모델이 기본 행동으로 틀리기 쉬운 구체적 함정

## Setup / Config
필요한 설정, 없을 때 물어볼 질문, secret 을 두면 안 되는 위치

## References
필요할 때 읽을 bundled resource
```

허용되는 변형:
- 협업형 스킬: `Stage 1`, `Stage 2`, `Stage 3` 과 사용자 선택 지점.
- 추천형 스킬: detection table, decision framework, recommendation template.
- 메타 스킬: baseline, pressure scenario, eval loop, description optimization.
- 교육형 스킬: 핵심 원칙, 예시, common rationalization, verification loop.

형식보다 중요한 것은 읽은 뒤 바로 행동이 바뀌는가다.

본문은 capability 가 보장해야 할 결과와 제약을 먼저 둔다. routine path 는 과도하게 고정하지 않는다. 예를 들어 "반드시 A 파일을 읽고 B 명령을 실행한 뒤 C를 작성" 같은 route 는 안전 gate, protocol contract, 반복 실패 방지처럼 경로 자체가 중요한 경우에만 둔다. 그 외에는 입력 판단 기준, hard constraints, output contract, escalation 조건을 명확히 하고 실행 순서는 호출 시점의 맥락에 맡긴다.

Gotchas 는 장식 섹션이 아니다. 모델이 기본값으로 이미 잘하는 내용이나 일반론을 반복하지 말고, 실제 실패를 줄이는 정보만 둔다. 스킬이 외부 계정, API key, project config, plugin data 를 필요로 하면 setup/config 경로와 missing-config 질문을 명시한다.

---

## 7. Effects And Gates

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
- deploy, publish, permission 변경, infra 변경은 명시 호출과 별도 승인 gate 를 둔다.

---

## 8. Progressive Disclosure

스킬은 세 단계로 노출된다고 가정한다.

| 단계 | 내용 | 설계 기준 |
|---|---|---|
| Metadata | name + description | 항상 노출되므로 짧고 정확하게 |
| `SKILL.md` | 핵심 capability procedure 와 판단 기준 | 호출 시 읽히므로 실행 가능하게 |
| Bundled resources | references/scripts/assets | 필요할 때만 읽거나 실행 |

분리할 것:
- 긴 reference 문서
- schema, API 문서, provider별 차이
- 반복 실행하는 script
- template, image, sample output
- 여러 변형 중 일부 상황에서만 필요한 자료
- 큰 gotcha catalog 나 product verification transcript

본문에 남길 것:
- 언제 어떤 resource 를 읽을지
- 핵심 판단 기준
- failure mode
- gate 와 output contract

`@path` 같은 자동 로딩 링크는 신중히 쓴다. 큰 파일이 의도치 않게 context 에 올라갈 수 있다.

스킬 디렉토리는 설치나 업데이트 중 삭제될 수 있다. 스킬이 mutable data 를 남겨야 한다면 runtime 이 제공하는 안정적인 plugin data/state 경로를 사용하고, cleanup 과 migration 방식을 설명한다.

---

## 9. Output Contract

스킬은 실행 후 무엇을 남길지 알려야 한다.

Output contract 는 꼭 `Output Format` 제목일 필요가 없다. capability procedure 내부의 report template, update gate, checklist, no-op 지시도 가능하다.

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

## 10. Verification

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
- missing-config case
- stale-reference case

Rationalization table 은 discipline 이 필요한 스킬에서 특히 유용하다.

```markdown
| Rationalization | Counter-instruction | Test case |
|---|---|---|
| "This is too small to need the procedure" | Small tasks still need the gate if mutation follows | ... |
```

이 패턴은 모든 스킬에 필수는 아니다. 모델이 우회하거나 shortcut 을 만들 가능성이 큰 스킬에 쓴다.

---

## 11. Quantitative Heuristics

수치는 hard rule 이 아니라 검토 신호다.

| 항목 | 진단 기준 |
|---|---|
| description | 보통 15-60 words 면 충분하다 |
| 빈번 호출 스킬 | 짧을수록 좋다. 150-200 words 수준을 목표로 할 수 있다 |
| 일반 스킬 본문 | 가능하면 핵심 capability procedure 중심으로 유지한다 |
| 긴 메타/교육형 스킬 | eval, reference, verification 구조가 있으면 길 수 있다 |
| tools | 제한이 의미 있을 때 명시한다 |
| flowchart | 비자명한 분기에서만 쓴다 |

길이가 문제가 되는 경우:
- 핵심 capability procedure 를 찾기 어렵다.
- reference 로 분리 가능한 자료가 본문을 압도한다.
- 자주 호출되는데 context 비용이 크다.
- 같은 지침이 반복되어 행동 개선 없이 노이즈가 된다.

---

## 12. Checklist

작성 전:
- [ ] 이 정보가 CLAUDE.md 가 아니라 스킬에 들어갈 재사용 절차인가?
- [ ] 사용자가 직접 시작하는 workflow 라면 command 가 더 적합하지 않은가?
- [ ] hook 으로 결정론적으로 강제할 수 없는가?
- [ ] 별도 specialist 에이전트가 필요한 작업은 아닌가?
- [ ] activation 조건이 분명한가?
- [ ] skill category 와 부수 효과 수준이 설명 가능한가?

Frontmatter:
- [ ] `name` 이 짧고 검색 가능한가?
- [ ] `description` 이 activation signal 인가?
- [ ] workflow shortcut 을 만들지 않는가?
- [ ] capability 제한이 필요하면 tools/invocation control 이 있는가?

본문:
- [ ] 목적과 핵심 원칙이 초반에 있는가?
- [ ] capability procedure 가 실행 가능한가?
- [ ] output contract 가 있는가?
- [ ] 부수 효과가 있으면 gate 가 있는가?
- [ ] gotchas 와 setup/config 가 필요하면 들어 있는가?
- [ ] 큰 resource 는 분리되어 있는가?
- [ ] near-miss 또는 anti-pattern 이 필요한 경우 들어 있는가?
- [ ] mutable data 를 남기면 저장 위치와 lifecycle 이 있는가?

검증:
- [ ] should-trigger / should-not-trigger 를 생각했는가?
- [ ] no-op case 가 있는가?
- [ ] 다른 스킬, 에이전트, 훅과 overlap 이 설명되는가?
- [ ] 긴 스킬이라면 길이를 정당화하는 구조가 있는가?

---

## 13. Anti-Patterns

| Anti-pattern | 증상 | 수정 |
|---|---|---|
| Description-as-runbook | description 이 절차를 나열 | trigger 조건만 남긴다 |
| Narrative skill | 과거 작업 회고 중심 | reusable method 로 바꾼다 |
| Unscoped capability | 무엇에 적용되는지 불명확 | scope 와 near-miss 추가 |
| Must-bombing | 모든 지침이 MUST/NEVER | gate 와 일반 원칙을 분리 |
| Reference dump | `SKILL.md` 에 긴 자료 복사 | references 로 분리 |
| Hidden mutation | 보고 없이 파일 수정 | report/approval gate 추가 |
| Project convention leak | 프로젝트 고유 규칙 포함 | CLAUDE.md 로 이동 |
| No output contract | 실행 후 결과가 매번 다름 | report/no-op 형식 추가 |
| Dead skill | 호출 조건이 없어 발견되지 않음 | activation signal 재작성 또는 제거 후보 |
| Obvious advice dump | 모델이 이미 아는 일반론 반복 | 실제 gotcha 와 실패 교정만 남김 |
| Missing setup path | config/credential 필요하지만 확인법 없음 | Setup / Config 와 missing-config 질문 추가 |
| Skill data in install dir | mutable data 를 skill directory 에 저장 | 안정적인 plugin data/state 경로로 이동 |
| User workflow hidden as skill | 사용자가 명시 호출해야 할 workflow 를 자동 skill 로 둠 | `COMMAND-GUIDE.md` 기준으로 command 분리 |
