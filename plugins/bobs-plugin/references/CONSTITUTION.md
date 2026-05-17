# AI Agent 하네스 구성 헌법 v2.1

생성: 2026-05-16
개정: 2026-05-17
성격: 스킬, 에이전트, 커맨드, 훅, 런타임 설정에 공통 적용되는 상위 원칙

이 문서는 AI agent 하네스 자산을 설계할 때 가장 먼저 적용하는 공통 헌법이다. 하위 문서는 이 원칙을 자산 유형별로 구체화한다.

문서 권위는 다음 방향으로 흐른다.

```text
CONSTITUTION.md
-> SKILL-GUIDE.md / AGENT-GUIDE.md / COMMAND-GUIDE.md / HOOK-GUIDE.md / RUNTIME-GUIDE.md
-> GAP-FORMAT.md
-> 개별 GAP 리포트
```

하위 문서는 헌법을 해석하고 적용할 수 있지만, 헌법의 원칙을 뒤집을 수 없다.

---

## 1. 공통 대상

스킬, 에이전트, 커맨드, 훅, 런타임 설정은 모두 AI agent 의 행동을 안정화하기 위한 하네스 구성 자산이다.

| 자산 | 공통 관점에서의 역할 |
|---|---|
| 스킬 | 필요할 때 로드되는 판단 절차와 방법론 |
| 에이전트 | 별도 컨텍스트에서 실행되는 specialist 역할 |
| 커맨드 | 사용자가 명시 호출하는 workflow entrypoint 와 orchestration |
| 훅 | runtime 이벤트에 자동 적용되는 결정론적 guardrail |
| 런타임 설정 | 권한, 모델, MCP, memory, context loading, budget 을 정하는 실행 환경 |

각 자산은 실행 방식이 다르지만 같은 질문에 답해야 한다.

- 언제 활성화되는가?
- 어떤 범위에만 적용되는가?
- 어떤 행동을 바꾸거나 보장하는가?
- 어떤 부수 효과가 있는가?
- 어떤 결과를 남기는가?
- 어떤 경우에는 쓰면 안 되는가?
- 어떤 context, memory, runtime capability 를 사용하거나 남기는가?

---

## 2. 원칙의 강도

모든 원칙은 같은 강도가 아니다.

| 강도 | 의미 | 예 |
|---|---|---|
| Hard rule | 어기면 안전, 라우팅, 부수 효과 위험이 직접 발생 | 승인 없는 mutation, secret 노출, destructive command 허용 |
| Design principle | 대부분 지켜야 하지만 목적 있는 예외 가능 | trigger 명확화, output contract, scope 제한 |
| Heuristic | 검토를 시작하게 하는 신호 | line count, word count, section name, example count |
| Local convention | 특정 프로젝트나 팀에만 맞는 규칙 | import style, directory path, framework preference |

헌법은 hard rule 과 design principle 을 다룬다. heuristic 과 local convention 은 하위 가이드나 프로젝트 memory 에 둔다.

### 2.1 Prompt Is Not A Harness Boundary

자연어 프롬프트는 중요한 지침이지만 실행 경계가 아니다.

프롬프트에 적을 수 있는 것:

- 판단 기준
- 협업 방식
- 출력 기대
- 사용자가 의도한 우선순위

하네스 primitive 로 설계해야 하는 것:

- 권한 제한
- 자동 차단
- 별도 컨텍스트 격리
- memory 와 state lifecycle
- tool/model/MCP 라우팅
- 반복 실행 상한과 budget
- 사용자 명시 호출 entrypoint

같은 내용을 프롬프트로 강조할 수는 있지만, 안전이나 부수 효과를 보장해야 한다면 runtime 설정, hook, command, agent, skill 의 책임으로 내려야 한다.

---

## 3. 공통 원칙

### 3.1 Activation Must Be Explicit

모든 자산은 언제 활성화되어야 하는지 명확해야 한다.

스킬과 에이전트는 description 또는 호출 설명으로 활성화 조건을 드러낸다. 훅은 event 와 matcher 로 활성화 조건을 드러낸다.

좋은 activation signal 은 다음을 포함한다.

- 사용자가 실제로 말할 작업 상황
- 대상 파일, 도구, 이벤트, 증상
- 주변 자산과 헷갈릴 수 있는 near-miss
- 적용하지 말아야 할 조건

형식보다 중요한 것은 라우팅이다. 특정 문구나 섹션명을 따랐는지가 아니라, agent/runtime 이 올바른 순간에 올바른 자산을 선택할 수 있는지가 핵심이다.

### 3.2 Scope Controls Quality

모든 자산은 적용 범위를 좁힐수록 안정적이다.

좋은 scope 는 다음을 말한다.

- 기본 입력 범위
- 제외 범위
- 사용자가 override 할 수 있는 범위
- pre-existing 문제를 다루는 방식
- 완료 또는 no-op 조건

넓은 scope 가 필요하다면 단계화, 사용자 확인, 더 강한 output contract, 또는 여러 자산으로 분리하는 설계가 필요하다.

### 3.3 Effects Require Gates

부수 효과가 있는 자산은 gate 가 필요하다.

부수 효과의 예:

- 파일 수정
- 설정 변경
- hook 등록
- 외부 요청
- 테스트/빌드 실행
- commit, push, deploy
- 권한 변경

기본 흐름:

1. inspect
2. report or proposal
3. approval or explicit invocation
4. mutate or execute
5. verify

read-only 자산은 권한 표면과 본문 지시가 모두 read-only 여야 한다. advisory 역할이면서 mutation 경로를 열어두는 것은 역할과 권한이 충돌하는 상태다.

### 3.4 Output Is A Contract

모든 자산은 실행 후 무엇을 남기는지 알려야 한다.

output contract 는 꼭 특정 섹션명일 필요가 없다. 다음 형태 모두 가능하다.

- report template
- output guidance
- phase 마지막의 산출 지시
- severity 또는 confidence grouping
- no-finding / no-op case
- approval 요청 형식
- hook 의 allow/warn/block 결과

중요한 것은 호출자나 runtime 이 결과를 해석하고 다음 행동을 결정할 수 있는가다.

### 3.5 Capability Surface Must Match Responsibility

자산이 사용할 수 있는 능력은 책임에 맞아야 한다.

스킬의 tool 제한, 에이전트의 tools/model, 커맨드의 allowed tools, 훅의 event/matcher/command, 런타임의 permission/model/MCP/memory 설정은 모두 capability surface 다.

원칙:

- advisory 역할은 mutation 능력을 기본으로 갖지 않는다.
- 자동 실행되는 훅은 최소 권한과 짧은 실행 경로를 가진다.
- specialist 에이전트는 역할에 필요한 도구만 가진다.
- 커맨드는 사용자가 명시 호출한 workflow 범위 안에서만 orchestration 한다.
- mutation 능력이 필요하면 scope 와 gate 가 함께 있어야 한다.
- 비용이 큰 model/runtime 선택은 품질 필요성과 설명 가능성이 있어야 한다.
- background 실행, max turns, permission mode, memory scope 는 역할 책임과 lifecycle 이 설명되어야 한다.

권한은 단지 쓰기 도구만의 문제가 아니다. 외부 검색, shell 제어, long-running command 제어, network access 도 책임과 맞아야 한다.

### 3.6 Reusable Knowledge And Local Memory Must Stay Separate

재사용 가능한 지식과 프로젝트 고유 기억은 분리한다.

재사용 자산에 둘 것:

- 반복 가능한 판단 절차
- 일반화 가능한 workflow
- 여러 프로젝트에서 쓰는 role
- 보안 또는 품질 원칙
- 검증 방법

CLAUDE.md 또는 project memory 에 둘 것:

- 프로젝트 디렉토리 구조
- 팀 coding convention
- 특정 명령
- 특정 서비스/배포 환경
- 일회성 결정과 작업 기록

스킬, 에이전트, 훅은 project memory 를 읽을 수는 있지만, 프로젝트 고유 규칙을 일반 규칙처럼 하드코딩하면 재사용성이 떨어진다.

### 3.7 Progressive Disclosure Protects Context

자산은 필요한 정보만 필요한 시점에 드러내야 한다.

공통 패턴:

- 항상 노출되는 metadata 는 짧고 정확하게 둔다.
- 본문은 핵심 판단과 workflow 를 담는다.
- 큰 reference, schema, example, script, asset 은 별도 파일로 분리한다.
- 환경 의존 기능은 fallback 경로를 제공한다.

길이 자체는 실패가 아니다. 문제는 자주 로드되는 정보가 핵심 행동을 가리거나, 선택적으로 읽어도 되는 자료가 항상 context 를 차지하는 것이다.

### 3.7.1 Context Is A Managed Resource

컨텍스트는 무한한 저장소가 아니라 관리해야 하는 자원이다.

자산은 필요할 때 다음 중 무엇을 담당하는지 설명할 수 있어야 한다.

- 어떤 정보를 항상 노출하는가?
- 어떤 reference 를 lazy-load 하는가?
- 어떤 작업을 별도 컨텍스트로 격리하는가?
- 어떤 결론만 main context 로 돌려보내는가?
- 어떤 memory 나 state 를 남기며 언제 정리하는가?

새 작업, 잘못된 방향 전환, 긴 탐색, 대량 출력이 섞이면 context 품질이 낮아질 수 있다. 이때는 continue, rewind, compact, clear, subagent 위임 중 하나를 선택해야 하며, 선택 기준은 runtime/session 가이드가 정의한다.

### 3.8 Strong Language Belongs To Real Gates

강한 표현은 실제 gate 에 쓴다.

적합한 위치:

- 안전 차단
- 승인 전 mutation 금지
- secret 보호
- destructive action 방지
- false-positive filtering
- 테스트 discipline 처럼 우회되기 쉬운 절차

부적합한 위치:

- 취향
- 설명 가능한 일반 권장
- 프로젝트별 style preference
- 단순 강조

문제는 `MUST` 나 `NEVER` 의 존재가 아니라, hard gate 와 일반 지침이 섞여 우선순위가 흐려지는 것이다.

### 3.9 Behavior Must Be Verifiable

좋은 자산은 행동으로 검증할 수 있어야 한다.

검증 질문:

- 예상 상황에서 활성화되는가?
- near-miss 에서 활성화되지 않는가?
- 권한과 gate 를 지키는가?
- 산출물이 contract 를 따른다?
- no-op 또는 no-finding 상황을 올바르게 처리하는가?
- 반복 실행 시 안정적인가?

검증 방식은 자산 유형마다 다를 수 있다. 스킬은 trigger eval 이나 pressure scenario, 에이전트는 sample invocation 과 output review, 훅은 event/matcher test 로 검증한다.

### 3.10 Overlap Must Be Intentional

비슷한 자산은 공존할 수 있지만 차이가 설명되어야 한다.

차이를 만드는 요소:

- trigger
- scope
- output
- capability surface
- 대상 프로젝트 또는 toolkit
- 실행 시점

중복 자체가 문제가 아니다. 문제는 호출자나 runtime 이 어떤 자산을 선택해야 할지 알 수 없는 상태다.

### 3.11 User-Initiated Workflows Need Commands

사용자가 명시적으로 호출하는 workflow 는 스킬이나 에이전트로 숨기지 않는다.

핵심 경계:

- 커맨드는 사용자가 직접 트리거하는 workflow 와 context router 다.
- 커맨드는 subagent 호출, skill trigger, 문서 링크/context selector 주입을 조정한다.
- 스킬은 모델이 자동 활성화하는 능력 확장 모듈이다.
- 스킬은 프로젝트와 직접 결합되지 않는 외부 인프라, API, provider, 도메인 특화 능력을 담는다.

커맨드에 적합한 것:

- 사용자가 slash command 또는 명시 이름으로 시작하는 workflow
- 사용자 질문, 인자 수집, plan gate, 단계 진행
- 여러 skill/agent 를 호출하는 얕은 orchestration
- 관련 docs/specs/decisions/context-map 링크를 모아 하위 자산에 전달하는 context 주입
- main context 에 남아야 하는 작업 요약과 다음 행동

커맨드에 부적합한 것:

- 자동 라우팅되어야 하는 외부 인프라·도메인 capability. 이 경우 스킬이 낫다.
- 별도 컨텍스트에서 수행할 specialist 판단. 이 경우 에이전트가 낫다.
- 매 이벤트마다 보장해야 하는 guardrail. 이 경우 훅이 낫다.
- 프로젝트 memory 전체를 저장하는 역할. 이 경우 docs 또는 CLAUDE.md 가 낫다.

커맨드는 workflow entrypoint 이지 권한 우회 장치가 아니다. 커맨드가 mutation, network, shell, agent dispatch 를 허용하면 scope, approval, output contract 를 함께 가져야 한다.

스킬은 command 의 대체 entrypoint 가 아니다. 스킬이 사용자 질문, plan gate, 단계 진행, 문서 링크 수집을 맡기 시작하면 command 로 승격하거나 command + skill 로 분리한다.

### 3.12 Runtime Policy Is Shared Infrastructure

settings, permissions, MCP, memory, model routing, budget 은 개별 자산의 배경 설정이 아니라 공유 인프라다.

원칙:

- deterministic policy 는 자연어 금지문보다 settings/hook 으로 둔다.
- `deny`/block 계층은 `allow` 보다 우선해야 한다.
- broad wildcard permission 은 예외이며, 이유와 보완 gate 가 필요하다.
- auto approval, auto mode, background loop 는 user opt-in, cap, visibility, stop path 가 있어야 한다.
- credential, personal preference, local-only memory 는 project-shared 설정과 분리한다.
- version-sensitive runtime 동작은 검증일, runtime 이름, version/source 를 남긴다.

런타임 정책은 자산이 "할 수 있는 일"의 상한을 정한다. 자산 본문이 안전하더라도 런타임 권한이 과하면 capability mismatch 로 기록한다.

### 3.13 Freshness Requires Evidence

AI agent runtime 은 빠르게 변한다. hook schema, frontmatter 필드, permission mode, MCP loading, memory 동작은 시간이 지나면 바뀔 수 있다.

버전 민감 정보를 문서화할 때는 다음을 남긴다.

- 확인한 날짜
- 확인한 runtime 또는 제품 이름
- 확인한 version 또는 source
- 재검증해야 하는 조건

확인하지 못한 platform behavior 는 hard rule 로 쓰지 않는다. 이 경우 `unknown`, `needs verification`, `implementation-time check required` 로 표시한다.

---

## 4. 선택 원칙

새 자산을 만들기 전에 가장 작은 적절한 형태를 고른다.

| 필요 | 선택 |
|---|---|
| 프로젝트 고유 규칙, shell 명령, 맥락 | CLAUDE.md |
| 사용자가 명시 호출하는 workflow entrypoint | 커맨드 |
| 인자 수집, 사용자 질문, plan gate, 얕은 orchestration | 커맨드 |
| 문서 링크/context selector 를 모아 하위 자산에 주입 | 커맨드 |
| 자동 활성화되는 외부 인프라·API·provider 능력 | 스킬 |
| 도메인 특화 분석·변환·검증 능력 | 스킬 |
| reference/script/template bundle 로 능력 확장 | 스킬 |
| 별도 컨텍스트의 specialist 판단 | 에이전트 |
| 병렬 작업, model/tool 격리 | 에이전트 |
| 자동 실행되는 deterministic guardrail | 훅 |
| 권한, 모델, MCP, memory, budget, context loading 정책 | 런타임 설정 |
| 여러 구성 자산의 설치·배포 묶음 | 플러그인 |

판단 순서:

1. 프로젝트 고유 정보인가? 그러면 CLAUDE.md.
2. 권한, 모델, MCP, memory, budget, tool loading 정책인가? 그러면 런타임 설정.
3. 사용자가 명시 호출하는 workflow entrypoint 인가? 그러면 커맨드.
4. 매 이벤트마다 자동 보장되어야 하는가? 그러면 훅.
5. 별도 컨텍스트, 병렬성, specialist role 이 필요한가? 그러면 에이전트.
6. 자동 활성화되는 외부 인프라·도메인 능력이나 reference bundle 인가? 그러면 스킬.
7. 어디에도 명확히 해당하지 않으면 새 자원을 만들지 않는다.

---

## 5. 하위 문서의 역할

헌법은 공통 원칙만 둔다.

하위 문서는 다음을 담당한다.

- `SKILL-GUIDE.md`: 스킬 frontmatter, body structure, trigger eval, bundled resources 작성법
- `AGENT-GUIDE.md`: 에이전트 role, scope, tools/model, output contract 작성법
- `COMMAND-GUIDE.md`: 사용자 명시 호출 workflow, 인자 수집, orchestration, gate 작성법
- `HOOK-GUIDE.md`: hook event, matcher, exit behavior, security guardrail 작성법
- `RUNTIME-GUIDE.md`: settings, permissions, MCP, memory, session/context, version-sensitive runtime 정책 작성법
- `GAP-FORMAT.md`: 헌법과 가이드를 기준으로 실제 자산을 평가하는 리포트 형식

하위 문서가 추가하는 규칙은 헌법의 공통 원칙을 구체화해야 한다. 하위 문서에서 발견한 문제를 이유로 헌법을 바꾸려면, 그것이 특정 자산 유형의 세부 규칙이 아니라 하네스 자산 전반에 적용되는 공통 원칙인지 먼저 확인한다.
