# GAP 분석 위임 프롬프트 v2.1

아래 프롬프트를 다른 LLM agent 에게 그대로 전달한다.

````markdown
작업 root 는 호출자가 지정한 현재 작업 디렉토리다.
너는 이 대화의 이전 컨텍스트를 전혀 모른다고 가정하고, 먼저 cwd 와 기준 문서 위치를 확인한 뒤 작업 root 안의 파일만 기준으로 GAP 분석을 수행한다.
기준 문서가 root 에 없고 `references/` 아래에만 있으면 그 위치를 명시하고 계속한다. 기준 문서 위치를 확정할 수 없으면 분석을 중단하고 필요한 경로를 `Follow-up Questions` 에 남긴다.

## 작업 원칙

분석 전에 다음 전제를 명시한다.

- 현재 cwd 와 기준 문서 위치
- 분석할 자산 유형과 제외할 유형
- 불명확한 해석 또는 선택지가 있는 항목

불확실한 항목은 임의로 단정하지 않는다. 분석을 계속할 수 있으면 `AMBIGUITY` 또는 `Follow-up Questions` 로 남기고, 최종 결정에 영향을 주는 blocking ambiguity 이면 `NEEDS_REVIEW` 로 둔다.

수정은 최소 범위로 한다.

- 요청된 GAP 분석 범위와 직접 관련된 `v2/gaps/*.GAP.md` 만 생성 또는 갱신한다.
- 기존 리포트의 수동 작성 내용, 근거, 결정 이력을 함부로 삭제하지 않는다.
- 형식 정리, 문체 통일, 인접 리포트 개선은 현재 finding 을 이해하거나 갱신하는 데 필요할 때만 한다.
- `Suggested Changes` 는 실제 영향이 확인된 finding 을 해결하는 가장 작은 변경으로 작성한다. 장래 확장성이나 있으면 좋은 개선만으로 새 작업을 만들지 않는다.

완료 전에 검증한다.

- 분석 대상 목록과 제외 사유가 완료 보고에 남아 있는가?
- 각 리포트가 `GAP-FORMAT.md` 의 필수 섹션과 Final Decision 을 갖는가?
- P0/P1, `GUIDE_GAP`, `Constitution Review` 후보가 영향 근거와 함께 분리되어 있는가?
- 수정한 모든 줄이 이번 분석 범위와 직접 연결되는가?

## 목표

root 기준 문서(v2.1)를 사용해 실제 구성 자산과 기준 문서 사이의 GAP 을 분석하고, 자산별 GAP 리포트를 작성한다.

분석 대상 자산:
- skills
- agents
- commands
- hooks, 단 현재 repo 에 hook 자산이 있을 때만
- runtime/settings, 단 현재 repo 에 설정 자산이 있을 때만

각 자산마다 하나의 리포트를 만든다.

- Skill: `v2/gaps/skill-<skill-name>.GAP.md`
- Agent: `v2/gaps/agent-<path-safe-agent-name>.GAP.md`
- Command: `v2/gaps/command-<command-name>.GAP.md`
- Hook: `v2/gaps/hook-<hook-name>.GAP.md`
- Runtime: `v2/gaps/runtime-<settings-or-policy-name>.GAP.md`

경로에 `/` 가 있으면 `-` 로 치환한다.

예:

```text
skills/brainstorming/SKILL.md
-> v2/gaps/skill-brainstorming.GAP.md

agents/feature-dev/code-reviewer.md
-> v2/gaps/agent-feature-dev-code-reviewer.GAP.md

.claude/hooks/format-on-edit.sh
-> v2/gaps/hook-format-on-edit.GAP.md

.claude/settings.json
-> v2/gaps/runtime-project-settings.GAP.md
```

## 반드시 먼저 읽을 문서

문서 권위 순서대로 읽고 적용한다.

1. `CONSTITUTION.md`
2. `SKILL-GUIDE.md`
3. `AGENT-GUIDE.md`
4. `COMMAND-GUIDE.md`
5. `HOOK-GUIDE.md`
6. `RUNTIME-GUIDE.md`
7. `GAP-FORMAT.md`

`v1/`, `references/v2/` archive 문서는 역사적 참고물일 뿐이다. active GAP 분석의 기준으로 사용하지 않는다.

## 분석 대상

Skill 대상:

```text
skills/*/SKILL.md
```

Agent 대상:

```text
agents/**/*.md
```

Agent 제외:

```text
agents/builtin/**
agents/**/README.md
```

Command 대상은 repo 안에 존재할 때만 분석한다. 다음 후보를 확인한다.

```text
.claude/commands/**/*.md
commands/**/*.md
```

Hook 대상은 repo 안에 존재할 때만 분석한다. 다음 후보를 확인한다.

```text
.claude/settings.json
.claude/hooks/**
hooks/**
**/*hook*.sh
**/*hook*.js
**/*hook*.ts
```

hook 후보가 없으면 hook 분석은 생략하고 완료 보고에 `Hook assets: none found` 라고 쓴다.

Runtime/settings 대상은 repo 안에 존재할 때만 분석한다. 다음 후보를 확인한다.

```text
.claude/settings*.json
.mcp.json
settings.json
**/*settings*.json
```

runtime/settings 후보가 없으면 runtime 분석은 생략하고 완료 보고에 `Runtime assets: none found` 라고 쓴다.

## 수정 가능 범위

수정 가능한 파일:

```text
v2/gaps/*.GAP.md
```

필요하면 `v2/gaps/` 디렉토리를 생성한다.

수정하지 말 것:

```text
skills/**
agents/**
.claude/**
hooks/**
CONSTITUTION.md
SKILL-GUIDE.md
AGENT-GUIDE.md
COMMAND-GUIDE.md
HOOK-GUIDE.md
RUNTIME-GUIDE.md
GAP-FORMAT.md
v1/**
```

기존 `v2/gaps/*.GAP.md` 가 있으면 먼저 읽고, 수동 작성된 내용을 함부로 삭제하지 않는다. 업데이트가 필요하면 보존하면서 갱신한다.

## 작업 방식

1. cwd, 기준 문서 위치, 분석 범위의 전제를 기록한다.
2. 분석 대상 파일 목록을 확정한다.
3. 각 자산의 frontmatter 또는 설정 정보를 읽는다.
4. 자산 유형별로 적용할 기준 문서를 정한다.
   - skill: `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md`
   - agent: `CONSTITUTION.md`, `AGENT-GUIDE.md`, `GAP-FORMAT.md`
   - command: `CONSTITUTION.md`, `COMMAND-GUIDE.md`, `GAP-FORMAT.md`
   - hook: `CONSTITUTION.md`, `HOOK-GUIDE.md`, `GAP-FORMAT.md`
   - runtime/settings: `CONSTITUTION.md`, `RUNTIME-GUIDE.md`, `GAP-FORMAT.md`
5. `GAP-FORMAT.md` 의 리포트 구조를 따라 작성한다.
6. 형식 차이가 아니라 실제 영향을 중심으로 finding 을 만든다.
7. 완료 전 검증 항목을 확인하고 최종 완료 보고를 작성한다.

## 판정 원칙

보수적으로 판단한다.

GAP 은 "가이드와 다름"이 아니라 "차이가 실제 품질이나 안정성에 영향을 준다" 일 때만 기록한다.

우선 적용할 공통 원칙:

- activation signal 이 명확한가?
- scope 가 좁고 안정적인가?
- effect 에 gate 가 있는가?
- output contract 가 있는가?
- capability surface 가 responsibility 와 맞는가?
- reusable knowledge 와 local memory 가 분리되어 있는가?
- progressive disclosure 가 적절한가?
- strong language 가 실제 gate 에 쓰이는가?
- behavior 를 검증할 수 있는가?
- overlap 이 의도적으로 설명되어 있는가?

기록하지 않아도 되는 것:

- 단순 문체 차이
- 섹션명 차이
- word count / line count / example count 만의 차이
- 의도적이고 설명 가능한 예외
- 타입별 가이드의 권장 형식과 다르지만 헌법의 기능을 만족하는 경우
- platform behavior 를 확인하지 않고 단정해야만 성립하는 문제

## 원칙 강도

`CONSTITUTION.md §2` 의 강도를 따른다.

- Hard rule: 위반 시 finding 으로 기록. 보통 P0-P1.
- Design principle: 실제 영향이 있으면 finding 으로 기록. 보통 P1-P2.
- Heuristic: 자동 finding 이 아니다. 실제 영향이 있을 때만 기록.
- Local convention: reusable 자산에는 직접 적용하지 않는다. 필요하면 CLAUDE.md 관련 이슈로 기록.

주의:

- `Output Format` 제목이 없다는 이유만으로 GAP 처리하지 않는다.
- `When NOT to Use` 제목이 없다는 이유만으로 GAP 처리하지 않는다.
- `model: inherit` 은 model 미지정이 아니라 명시적 선택이다.
- `tools` 생략을 플랫폼 기본값 확인 없이 "전체 권한" 으로 단정하지 않는다.
- hook schema, exit code semantics, settings merge precedence 는 runtime 확인 전 단정하지 않는다.

## Finding 유형

각 finding 은 아래 중 하나로 분류한다.

- `ASSET_GAP`: 실제 자산이 v2 헌법 또는 타입별 가이드의 핵심 기대에 미달
- `GUIDE_GAP`: 실제 자산의 좋은 반복 패턴이 타입별 가이드에 반영되어 있지 않음
- `AMBIGUITY`: 자산 의도, 가이드 적용, platform behavior 가 불명확
- `INTENTIONAL_EXCEPTION`: 기준과 다르지만 목적과 영향이 설명 가능한 예외
- `NO_GAP`: 검토 결과 의미 있는 GAP 없음

`GUIDE_GAP` 은 신중하게 사용한다. 한 자산의 취향 차이가 아니라 반복 패턴, false positive 방지, platform behavior 명확화에 도움이 될 때만 사용한다.

헌법 수정 제안은 매우 드물게만 한다. command/skill/agent/hook/runtime 전반에 적용되는 공통 원칙일 때만 `Constitution Review` 에 적는다.

## Severity

- `P0`: 즉시 수정 필요. 안전, 데이터, destructive action 위험
- `P1`: 라우팅, 권한, 부수 효과, 산출 신뢰성에 직접 영향
- `P2`: 품질 저하 가능성이 크거나 반복되면 비용이 커짐
- `P3`: 낮은 우선순위의 정리 또는 명확화

Severity 는 규칙 위반 개수가 아니라 영향도로 판단한다.

## Skill 점검 축

Skill 은 "모델이 자동 활성화하는 외부 인프라·도메인 능력 확장 모듈" 로 본다.

확인할 것:

- activation signal 이 명확한가?
- description 이 workflow shortcut 을 만들지 않는가?
- 사용자 명시 workflow, 문서 링크 주입, plan gate 를 command 로 넘기고 있는가?
- scope 또는 near-miss 가 필요한 경우 보이는가?
- 외부 infra/API/provider/domain capability 절차가 실행 가능한가?
- mutation 가능성이 있으면 effect gate 가 있는가?
- output contract 가 있는가?
- progressive disclosure 가 적절한가?
- reusable 지식과 project memory 가 분리되어 있는가?
- behavior 를 검증할 수 있는가?
- 다른 command/skill/agent/hook 과 overlap 이 설명되는가?

## Command 점검 축

Command 는 "사용자가 명시 호출하는 workflow entrypoint 이자 context router" 로 본다.

확인할 것:

- explicit user invocation 이 필요한가?
- 입력과 missing-input 질문이 명확한가?
- scope 와 exclusion 이 명확한가?
- 하위 skill/agent 위임 contract 가 있는가?
- docs/specs/decisions/context-map 링크나 selector 를 bounded 하게 주입하는가?
- provider/API/domain 세부 사용법을 skill 로 분리하는가?
- capability surface 가 workflow 와 맞는가?
- mutation 가능성이 있으면 effect gate 가 있는가?
- output contract 가 있는가?
- fail-closed 와 no-op 경로가 있는가?
- main context 에 남기는 정보가 bounded 되어 있는가?
- behavior 를 검증할 수 있는가?

## Agent 점검 축

Agent 는 "별도 컨텍스트에서 실행되는 specialist role" 로 본다.

확인할 것:

- activation signal 이 명확한가?
- specialist role 과 mission 이 명확한가?
- scope 와 exclusion 이 명확한가?
- capability surface 가 responsibility 와 맞는가?
- model 선택이 명시되었거나 정당화 가능한가?
- output contract 가 있는가?
- review/diagnostic 역할이면 quality gate 가 있는가?
- CLAUDE.md 또는 project memory coupling 이 적절한가?
- 유사 agent 와 overlap 이 의도적으로 설명되는가?
- behavior 를 검증할 수 있는가?

## Hook 점검 축

Hook 은 "runtime event 에 자동 반응하는 deterministic guardrail" 로 본다.

확인할 것:

- event choice 가 목적과 맞는가?
- matcher 가 충분히 좁은가?
- input handling 이 방어적인가?
- effect 와 exit policy 가 명확한가?
- security-sensitive behavior 가 안전한가?
- external IO 가 없거나 정당화되는가?
- performance impact 가 bounded 되어 있는가?
- registration path 가 명확한가?
- version-sensitive assumption 이 표시되어 있는가?
- behavior 를 검증할 수 있는가?

## Runtime 점검 축

Runtime/settings 는 "권한, 모델, MCP, memory, context loading, budget 의 실행 정책" 으로 본다.

확인할 것:

- settings scope 가 공유성과 민감도에 맞는가?
- allow rules 가 좁게 제한되는가?
- deny/block rules 가 destructive action 을 막는가?
- ask rules 가 위험하지만 legitimate 한 작업을 다루는가?
- secret, credential, personal path 가 project-shared 설정에 없는가?
- MCP server 의 source 와 capability 가 설명되는가?
- memory/state lifecycle 이 명확한가?
- model/effort/budget 선택이 정당화되는가?
- auto/background behavior 에 opt-in, cap, stop path 가 있는가?
- version-sensitive assumption 이 표시되어 있는가?

## Evidence 작성 규칙

- 긴 원문을 붙여넣지 않는다.
- 짧은 phrase, heading, frontmatter 값, 설정 key, source path 중심으로 증거를 제시한다.
- 추측과 관측을 구분한다.
- platform default 를 모르면 `unknown` 또는 `AMBIGUITY` 로 둔다.
- "가이드 위반"만 쓰지 말고 실제 영향을 설명한다.
- guide reference 는 실제 존재하는 heading 만 사용한다.

## 리포트 구조

각 리포트는 `GAP-FORMAT.md` 의 순서를 따른다.

1. Metadata
2. Executive Summary
3. Asset Snapshot
4. Applicable Criteria
5. Checks
6. Findings
7. Acceptable Deviations
8. Suggested Changes
9. Follow-up Questions
10. Final Decision

필요 없는 섹션은 삭제하지 말고 `None` 으로 둔다.

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

1. 분석한 자산 목록
2. 생성 또는 수정한 GAP 리포트 목록
3. 자산별 Final decision
4. 가장 중요한 P0/P1 finding
5. `GUIDE_GAP` 목록
6. `Constitution Review` 후보가 있으면 그 이유
7. hook 자산을 찾지 못했으면 `Hook assets: none found`
8. command 자산을 찾지 못했으면 `Command assets: none found`
9. runtime/settings 자산을 찾지 못했으면 `Runtime assets: none found`
10. 분석하지 못한 파일이 있으면 그 이유
````
