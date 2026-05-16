# GAP 분석 위임 프롬프트

아래 프롬프트를 다른 LLM agent 에게 그대로 전달한다.

```markdown
현재 작업 디렉토리는 `/Users/macpro/.claude/research/agent-skill-best-practices` 이다.
너는 이 대화의 이전 컨텍스트를 전혀 모른다고 가정하고, 현재 cwd 안의 파일만 기준으로 GAP 분석을 수행한다.

## 목표

`v1/` 문서를 기준으로 `skills/`, `agents/` 아래의 실제 스킬/에이전트가 얼마나 잘 맞는지 점검하고, 자산별 GAP 리포트를 작성한다.

각 자산마다 하나의 리포트를 만든다.

- Skill: `v1/gaps/skill-<skill-name>.GAP.md`
- Agent: `v1/gaps/agent-<path-safe-agent-name>.GAP.md`
- 에이전트 경로의 `/` 는 `-` 로 치환한다.
  - 예: `agents/feature-dev/code-reviewer.md` -> `v1/gaps/agent-feature-dev-code-reviewer.GAP.md`

## 반드시 먼저 읽을 문서

1. `v1/GAP-FORMAT.md`
2. `v1/gaps/_SKILL_TEMPLATE.md`
3. `v1/gaps/_AGENT_TEMPLATE.md`
4. `v1/CONSTITUTION.md`
5. `v1/SKILL-GUIDE.md`
6. `v1/AGENT-GUIDE.md`

필요하면 `v1/README.md` 도 참고한다.

## 분석 대상

Skill 대상:

```text
skills/*/SKILL.md
```

Agent 대상:

```text
agents/**/*.md
```

단, 다음은 기본적으로 분석 대상에서 제외한다.

```text
agents/builtin/**
agents/**/README.md
```

## 작업 방식

1. 먼저 분석 대상 파일 목록을 확정한다.
2. 각 skill 은 `v1/gaps/_SKILL_TEMPLATE.md` 구조로 GAP 리포트를 작성한다.
3. 각 agent 는 `v1/gaps/_AGENT_TEMPLATE.md` 구조로 GAP 리포트를 작성한다.
4. 기존 GAP 리포트가 있으면 먼저 읽고, 수동 작성된 내용이 있으면 함부로 삭제하지 않는다.
5. 원본 자산(`skills/`, `agents/`)과 기준 문서(`v1/*.md`)는 수정하지 않는다.
6. 이번 작업에서 수정 가능한 범위는 원칙적으로 `v1/gaps/*.GAP.md` 뿐이다.

## 판정 원칙

보수적으로 판단한다.

GAP 은 단순히 "가이드와 다름"이 아니라 다음 중 하나일 때만 기록한다.

- 라우팅 실패 가능성이 있다.
- description 이 호출 조건이 아니라 workflow 설명으로 흐른다.
- 역할, scope, output contract 가 불명확하다.
- tool/model 권한이 역할 대비 과하거나 불명확하다.
- 안전, mutation, approval gate 관련 리스크가 있다.
- 실제 자산의 좋은 패턴이 v1 가이드에 빠져 있다.
- v1 가이드가 실제 우수 사례를 부당하게 위반으로 만들고 있다.

기록하지 않아도 되는 것:

- 단순 문체 차이
- 경미한 섹션명 차이
- 의도적이고 설명 가능한 예외
- 권장사항의 가벼운 미준수
- 표본 outlier 이지만 실제 위험이 낮은 경우

## Finding 유형

각 finding 은 아래 중 하나로 분류한다.

- `ASSET_GAP`: 자산이 v1 기준에 미달
- `GUIDE_GAP`: 자산의 좋은 패턴이 v1 가이드에 없음
- `AMBIGUITY`: 가이드 또는 자산 의도가 불명확
- `INTENTIONAL_EXCEPTION`: 가이드와 다르지만 정당화 가능
- `NO_GAP`: 의미 있는 GAP 없음

## Severity

- `P0`: 즉시 수정 필요. 보안, 위험한 부수 효과, 잘못된 자동 호출
- `P1`: 라우팅 또는 산출 품질에 직접 영향
- `P2`: 개선 권장. 누적되면 품질 저하
- `P3`: 낮은 우선순위의 문서 정리 또는 명확화

Severity 는 규칙 위반 개수가 아니라 영향도로 판단한다.

## Skill 점검 축

Skill 은 "방법론과 workflow 를 잘 패키징했는가"를 본다.

확인할 것:

- description 이 trigger 조건 중심인지
- description 에 workflow 요약이 과하게 들어가지 않았는지
- keyword coverage 가 있는지
- When to Use / When NOT to Use 또는 near-miss 가 있는지
- workflow/checklist 가 실행 가능한지
- output contract 가 필요한 경우 명확한지
- mutation 이 있으면 approval gate 가 있는지
- progressive disclosure 가 적절한지
- references/scripts/assets 사용이 적절한지
- project-specific leakage 가 없는지
- trigger eval 또는 테스트 경로가 가능한지

## Agent 점검 축

Agent 는 "특정 specialist role 을 격리된 컨텍스트에서 안정적으로 수행하는가"를 본다.

확인할 것:

- description 이 호출 조건을 명확히 담는지
- near-miss 또는 negative case 가 있는지
- description 이 과하게 길거나 runbook 화되어 있지 않은지
- persona / mission / scope 가 명확한지
- tool 권한이 least-privilege 인지
- model 이 명시되고 역할에 적절한지
- output contract 가 호출자에게 유용한지
- 리뷰/분석 계열이면 confidence gate 가 있는지
- 다른 에이전트나 스킬의 책임을 침범하지 않는지
- CLAUDE.md 또는 project convention 과의 관계가 필요한 경우 명확한지

## Evidence 작성 규칙

- 긴 원문을 붙여넣지 않는다.
- 짧은 phrase, 섹션명, frontmatter 값 중심으로 증거를 제시한다.
- 가능하면 source path 를 명시한다.
- 추측과 관측을 구분한다.
- "가이드 위반"만 쓰지 말고 실제 영향까지 쓴다.

## 최종 결정

각 리포트 마지막에는 반드시 하나를 선택한다.

- `PASS`
- `PASS_WITH_NOTES`
- `REVISE_ASSET`
- `REVISE_GUIDE`
- `SPLIT_ASSET`
- `DEPRECATE_ASSET`
- `NEEDS_REVIEW`

## 완료 보고

작업이 끝나면 다음을 요약한다.

1. 생성 또는 수정한 GAP 리포트 목록
2. 자산별 Final decision
3. 가장 중요한 P0/P1 finding
4. 가이드를 수정해야 할 가능성이 있는 `GUIDE_GAP`
5. 분석하지 못한 파일이 있으면 그 이유
```
