# 커맨드 작성 가이드 v2.1

생성: 2026-05-17
상위 원칙: `CONSTITUTION.md`
성격: 사용자 명시 호출 workflow 와 얕은 orchestration 을 위한 타입별 실무 가이드

이 문서는 `CONSTITUTION.md` 의 공통 원칙을 커맨드에 적용하는 방법을 설명한다. 커맨드는 사용자가 명시적으로 호출하는 workflow entrypoint 이며, 필요한 문서 링크와 하위 자산 호출을 한곳에 모으는 context router 이다.

---

## 1. 커맨드의 역할

커맨드는 main context 안에서 시작되는 사용자 주도 workflow 다.

커맨드에 적합한 것:
- slash command 나 명시 이름으로 사용자가 직접 시작하는 작업
- 사용자 질문, 인자 수집, 선택지 확인, plan gate
- 여러 skill/agent/tool 을 순서대로 호출하는 얕은 orchestration
- 필요한 문서, spec, decision, context-map 링크를 모아 하위 agent/skill 에 전달하는 context 주입
- 작업이 main context 에 남아야 하는 진행 요약
- 반복하지만 자동 라우팅되면 안 되는 팀 workflow

커맨드에 부적합한 것:
- 모델이 자동으로 필요성을 판단해 읽어야 하는 능력 확장 모듈. 이 경우 스킬이 낫다.
- 별도 context 에서 수행해야 하는 specialist 판단. 이 경우 에이전트가 낫다.
- 매 tool/event 마다 보장해야 하는 차단/검증. 이 경우 훅이 낫다.
- 긴 reference 저장소. 이 경우 docs, skill references, runtime guide 로 분리한다.
- commit, push, deploy 까지 숨은 자동화로 이어지는 workflow.

커맨드는 "사용자가 시작했다" 는 사실 때문에 모든 부수 효과가 승인된 것으로 간주하지 않는다. 명시 호출은 workflow 시작 승인이지 모든 mutation 승인이나 권한 상승 승인이 아니다.

---

## 2. Command vs Skill vs Agent vs Hook

| 필요 | 선택 |
|---|---|
| 사용자가 직접 시작하는 workflow | 커맨드 |
| workflow 중 사용자 질문, plan gate, 단계 진행 | 커맨드 |
| 관련 문서 링크를 모아 context 로 주입 | 커맨드 |
| agent/skill/tool 호출 순서 조정 | 커맨드 |
| 자동 활성화되는 외부 인프라·도메인 능력 확장 | 스킬 |
| 별도 context specialist 판단 | 에이전트 |
| event 단위 deterministic guardrail | 훅 |
| 권한, memory, MCP, model 정책 | 런타임 설정 |

가벼운 선택 원칙:

1. 사용자가 지금 이 workflow 를 명시 호출했는가? 그러면 커맨드를 고려한다.
2. workflow 안에서 필요한 외부 인프라 지식, 도메인 특화 능력, provider/API 사용법이 자동 적용되어야 하는가? 그 부분은 스킬로 분리한다.
3. 대량 탐색, 독립 리뷰, 병렬 작업, 권한/model 격리가 필요한가? 그 부분은 에이전트로 분리한다.
4. 매번 자동 보장해야 하는가? 그 부분은 훅이나 runtime permission 으로 분리한다.

---

## 3. Frontmatter

권장 구조:

```yaml
---
name: workflow-name
description: Use when the user explicitly wants to run [workflow].
argument-hint: "[target path or option]"
allowed-tools: Read, Grep, Glob, Agent, Skill
model: sonnet
---
```

필드 원칙:
- `name` 은 사용자가 호출할 workflow 이름이다.
- `description` 은 command catalog 에서 사용자가 무엇을 실행하는지 판단하게 한다.
- `argument-hint` 는 필수 입력과 선택 입력을 짧게 드러낸다.
- `allowed-tools` 는 command 가 직접 쓸 수 있는 능력만 연다.
- `model` 과 `effort` 는 비용과 latency 의 선택이므로 이유를 설명할 수 있어야 한다.
- command 가 특정 agent/skill 로 위임한다면 본문에 위임 contract 를 둔다.

주의:
- command description 에 전체 절차를 넣지 않는다.
- broad shell/network/edit 권한은 workflow 범위와 gate 없이는 열지 않는다.
- command 가 호출하는 agent/skill 의 권한을 command 권한으로 우회하지 않는다.

---

## 4. Body 설계

커맨드 본문은 workflow 를 실행하는 entrypoint 로 읽혀야 한다.

권장 구조:

```markdown
# Command Name

사용자가 이 workflow 를 명시 호출했을 때 수행할 목적.

## Inputs
- required:
- optional:
- ask user if missing:

## Workflow
1. Validate inputs.
2. Gather minimal context.
3. Ask for approval when needed.
4. Delegate bounded work to skill/agent/tool.
5. Summarize result and next action.

## Delegation Contract
- agent/skill:
- input:
- expected output:
- failure handling:

## Context Links
- docs/specs/decisions to pass:
- why each link is relevant:
- what not to load:

## Effect Gates
- mutation:
- external IO:
- commit/push/deploy:

## Output Contract
- what was done
- what changed or did not change
- what still needs user decision
```

필수 기능:
- 시작 조건과 입력
- 사용자에게 물어야 할 정보
- 문서 링크와 context 주입 범위
- 위임할 자산과 직접 처리할 작업의 경계
- 부수 효과 gate
- 실패, no-op, 사용자 중단 처리
- 최종 output contract

---

## 5. Orchestration Boundary

커맨드는 orchestration 을 할 수 있지만, 깊은 dispatcher 가 되면 안 된다.

허용되는 orchestration:
- 사용자 선호나 대상 경로를 확인한다.
- 필요한 context 를 소량 수집하고 관련 문서 링크를 정리한다.
- 하나 이상의 agent/skill 을 순서대로 호출한다.
- 하위 agent/skill 에 필요한 문서 링크와 요약된 맥락만 전달한다.
- 각 결과를 검증하고 사용자에게 다음 선택지를 제시한다.

피해야 할 orchestration:
- command 가 모든 하위 판단을 직접 구현한다.
- command 가 agent 안에서 또 다른 agent dispatch 를 요구한다.
- command 가 긴 문서 본문 전체를 main context 에 복사한다.
- 실패 시 무한 재시도하거나 Stop hook/auto loop 를 숨겨서 발동한다.
- command 가 permission mode 나 broad tool 권한을 전제로 안전 gate 를 생략한다.

위임 contract 에 포함할 것:
- 호출 대상
- 넘길 입력
- 전달할 문서 링크 또는 context selector
- 기대하는 결과 형식
- 실패 또는 invalid output 처리
- caller 가 통합 판단을 맡는다는 사실

---

## 6. Effects And Gates

커맨드가 부수 효과를 만들 수 있으면 gate 가 필요하다.

부수 효과:
- 파일 수정
- 설정 변경
- hook 등록
- 외부 요청
- 테스트/빌드 실행
- commit, push, deploy
- permission, memory, MCP 설정 변경

기본 흐름:

1. inputs 확인
2. inspect
3. plan 또는 proposal 출력
4. 사용자 승인 또는 이미 명시된 범위 확인
5. execute
6. verify
7. result summary

특히 commit, push, deploy, package publish, permission 확대는 command 내부 자동 진행을 기본값으로 두지 않는다.

---

## 7. Output Contract

커맨드는 사용자가 workflow 진행 상태를 이해할 수 있게 끝나야 한다.

포함할 것:
- 입력과 실제 적용 범위
- 호출한 agent/skill/tool
- 변경 또는 산출물
- 검증 결과
- 실패 또는 no-op 사유
- 사용자가 결정해야 할 다음 단계

긴 agent 결과를 그대로 붙여넣지 않는다. main context 에는 결론, 증거 위치, 다음 행동만 남긴다.

---

## 8. Context Injection

커맨드는 문서 본문을 저장하는 곳이 아니라, workflow 에 필요한 context 를 찾고 연결하는 곳이다.

적합한 context 주입:
- 관련 docs/specs/decisions/context-map 경로를 나열한다.
- 하위 agent/skill 이 읽어야 할 파일과 읽지 말아야 할 파일을 구분한다.
- 사용자 요청과 문서 링크 사이의 관련성을 한 줄로 설명한다.
- main context 에는 짧은 요약과 링크만 남긴다.

부적합한 context 주입:
- 긴 문서 본문 전체를 command 에 복사한다.
- 프로젝트별 규칙을 command 에 영구 저장한다.
- 모든 workflow 에 같은 문서 묶음을 강제 주입한다.
- skill 이 자동으로 판단해야 할 provider/API/domain reference 를 command 에 중복한다.

문서 링크는 command 의 orchestration 입력이다. 장기 지식은 docs 에, 자동 능력 확장은 skill 에, 별도 판단은 agent 에 둔다.

---

## 9. Verification

커맨드는 다음 케이스로 검증한다.

- required argument 가 있을 때 바로 실행되는가?
- argument 가 없을 때 사용자에게 필요한 질문만 하는가?
- near-miss 에서 다른 skill/agent 를 호출하지 않는가?
- 필요한 문서 링크를 제공하되 긴 본문을 주입하지 않는가?
- 하위 agent/skill 결과가 invalid 할 때 fail closed 하는가?
- mutation 전 gate 가 작동하는가?
- no-op 또는 사용자 취소가 명확히 끝나는가?

커맨드가 팀 workflow 의 entrypoint 라면 샘플 호출과 expected transcript 를 reference 로 둘 수 있다.

---

## 10. Checklist

작성 전:
- [ ] 사용자가 명시 호출하는 workflow 인가?
- [ ] 스킬이나 에이전트가 아니라 command 가 필요한 이유가 있는가?
- [ ] 반복 지식과 specialist 판단을 하위 자산으로 분리했는가?
- [ ] command 가 문서 링크/context selector 역할을 맡는가?

Frontmatter:
- [ ] `name` 이 호출 이름으로 적합한가?
- [ ] `description` 이 catalog signal 로 충분한가?
- [ ] `argument-hint` 가 필요한 입력을 드러내는가?
- [ ] `allowed-tools` 가 workflow 보다 넓지 않은가?

본문:
- [ ] inputs 와 missing-input 질문이 있는가?
- [ ] Context Links 또는 동등한 context 주입 지시가 있는가?
- [ ] delegation contract 가 있는가?
- [ ] effect gate 가 있는가?
- [ ] output contract 가 있는가?
- [ ] fail-closed 와 no-op 경로가 있는가?

운영:
- [ ] command 가 자동 권한 상승 경로가 되지 않는가?
- [ ] main context 에 남길 정보와 버릴 정보가 구분되는가?
- [ ] long-running/background 작업에 cap, visibility, stop path 가 있는가?

---

## 11. Anti-Patterns

| Anti-pattern | 증상 | 수정 |
|---|---|---|
| Command-as-skill | 자동 적용될 절차를 사용자가 매번 호출해야 함 | 스킬로 이동 |
| Command-as-agent | 별도 context specialist 판단을 main context 에서 수행 | 에이전트로 이동 |
| Hidden mutation | command 실행만으로 파일/설정 변경 | plan/proposal/approval gate 추가 |
| Deep dispatcher | command 가 여러 단계의 agent dispatch 정책을 가짐 | orchestration 을 얕게 유지, 역할별 자산 분리 |
| Broad shell command | `Bash(*)` 류 권한 전제 | safe subcommand 와 runtime permission 으로 제한 |
| Output dump | 하위 결과 전문을 main context 에 복사 | summary, evidence path, next action 만 남김 |
| No argument handling | 입력 누락 시 임의 추정 | 짧게 사용자에게 질문 |
| Auto ship | review 없이 commit/push/deploy | 별도 명시 승인과 verify 단계 |
| Context hoarding | 긴 문서 본문을 command 에 저장하거나 항상 주입 | 링크, selector, 짧은 이유만 남김 |
| Capability in command | provider/API/domain 사용법을 command 에 구현 | 자동 활성화 skill 로 분리 |
