# 스킬·에이전트·훅 구성 헌법 v2

생성: 2026-05-16
성격: 스킬, 에이전트, 훅에 공통 적용되는 상위 원칙

이 문서는 스킬, 에이전트, 훅을 설계할 때 가장 먼저 적용하는 공통 헌법이다. 하위 문서는 이 원칙을 자산 유형별로 구체화한다.

문서 권위는 다음 방향으로 흐른다.

```text
CONSTITUTION.md
-> SKILL-GUIDE.md / AGENT-GUIDE.md / HOOK-GUIDE.md
-> GAP-FORMAT.md
-> 개별 GAP 리포트
```

하위 문서는 헌법을 해석하고 적용할 수 있지만, 헌법의 원칙을 뒤집을 수 없다.

---

## 1. 공통 대상

스킬, 에이전트, 훅은 모두 AI agent 의 행동을 안정화하기 위한 구성 자산이다.

| 자산 | 공통 관점에서의 역할 |
|---|---|
| 스킬 | 필요할 때 로드되는 판단 절차와 방법론 |
| 에이전트 | 별도 컨텍스트에서 실행되는 specialist 역할 |
| 훅 | runtime 이벤트에 자동 적용되는 결정론적 guardrail |

세 자산은 실행 방식이 다르지만 같은 질문에 답해야 한다.

- 언제 활성화되는가?
- 어떤 범위에만 적용되는가?
- 어떤 행동을 바꾸거나 보장하는가?
- 어떤 부수 효과가 있는가?
- 어떤 결과를 남기는가?
- 어떤 경우에는 쓰면 안 되는가?

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

스킬의 tool 제한, 에이전트의 tools/model, 훅의 event/matcher/command 는 모두 capability surface 다.

원칙:

- advisory 역할은 mutation 능력을 기본으로 갖지 않는다.
- 자동 실행되는 훅은 최소 권한과 짧은 실행 경로를 가진다.
- specialist 에이전트는 역할에 필요한 도구만 가진다.
- mutation 능력이 필요하면 scope 와 gate 가 함께 있어야 한다.
- 비용이 큰 model/runtime 선택은 품질 필요성과 설명 가능성이 있어야 한다.

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

---

## 4. 선택 원칙

새 자산을 만들기 전에 가장 작은 적절한 형태를 고른다.

| 필요 | 선택 |
|---|---|
| 프로젝트 고유 규칙, 명령, 맥락 | CLAUDE.md |
| 반복 가능한 판단 절차 | 스킬 |
| reference/script/template bundle | 스킬 |
| 별도 컨텍스트의 specialist 판단 | 에이전트 |
| 병렬 작업, model/tool 격리 | 에이전트 |
| 자동 실행되는 deterministic guardrail | 훅 |
| 여러 구성 자산의 설치·배포 묶음 | 플러그인 |

판단 순서:

1. 프로젝트 고유 정보인가? 그러면 CLAUDE.md.
2. 매 이벤트마다 자동 보장되어야 하는가? 그러면 훅.
3. 별도 컨텍스트, 병렬성, specialist role 이 필요한가? 그러면 에이전트.
4. 반복 가능한 판단 절차나 reference bundle 인가? 그러면 스킬.
5. 어디에도 명확히 해당하지 않으면 새 자원을 만들지 않는다.

---

## 5. 하위 문서의 역할

헌법은 공통 원칙만 둔다.

하위 문서는 다음을 담당한다.

- `SKILL-GUIDE.md`: 스킬 frontmatter, body structure, trigger eval, bundled resources 작성법
- `AGENT-GUIDE.md`: 에이전트 role, scope, tools/model, output contract 작성법
- `HOOK-GUIDE.md`: hook event, matcher, exit behavior, security guardrail 작성법
- `GAP-FORMAT.md`: 헌법과 가이드를 기준으로 실제 자산을 평가하는 리포트 형식

하위 문서가 추가하는 규칙은 헌법의 공통 원칙을 구체화해야 한다. 하위 문서에서 발견한 문제를 이유로 헌법을 바꾸려면, 그것이 특정 자산 유형의 세부 규칙이 아니라 세 자산 모두에 적용되는 공통 원칙인지 먼저 확인한다.
