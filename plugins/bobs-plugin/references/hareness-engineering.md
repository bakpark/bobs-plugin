# Coding Agent Environment

## 1. 배경

하네스에서 중요한 것은 다음과 같다.

- Stateless한 에이전트에게
- 필요한 정보를
- 필요한 타이밍에 주입하여
- 수행 능력을 증강시키는 것

에이전트 환경 구축의 핵심은 "좋은 프롬프트를 한 번 작성하는 것"이 아니라, 에이전트가 실제 작업 중 필요한 맥락을 찾고 사용할 수 있도록 문서, 도구, 검증 루프를 설계하는 것이다.

## 2. 문제 정의

### 에이전트가 필요한 정보의 종류

#### 코드에서 얻을 수 있는 것

- 코드베이스 및 프로젝트 내부 아키텍처
- 스펙 히스토리와 변경 이력
- 내부 설정 방식
- 도메인 엔티티 스키마
- 모듈 간 의존성

#### 코드에서 얻을 수 없는 것

- 스펙 의사결정 과정과 근거
- 도메인 지식
- 외부 시스템 연계 아키텍처
- 프로젝트 컨벤션
- 워크플로우와 협업 방식
- 보안상 금지해야 하는 행동

### 에이전트마다 동작 방식이 달라서 생기는 문제

- 필요한 맥락을 수집하는 방식이 다름
- 적절한 도구를 찾고 트리거하는 방식이 다름
- 항상 로드되는 문서와 필요할 때 로드되는 문서를 구분하지 못할 수 있음
- 과거 의사결정의 근거가 코드에 남지 않으면 잘못된 리팩터링을 할 수 있음

## 3. 목표

이 프로젝트의 목표는 코딩 에이전트가 다음을 안정적으로 수행하도록 환경을 설계하는 것이다.

- 작업 시작 시 필요한 프로젝트 맥락을 빠르게 찾는다.
- 코드에서 알 수 없는 의사결정, 도메인 지식, 운영 규칙을 참조한다.
- 작업 유형에 맞는 문서, 스킬, 도구, 명령을 선택한다.
- 위험한 작업을 하기 전에 정책과 가드레일을 확인한다.
- 작업 결과를 로그화하고, 누락된 맥락을 다음 개선 항목으로 반영한다.

## 4. 구성요소 모델

앞으로 세팅할 구성요소는 `agents`, `skills`, `hooks`, `docs`이다.
각 구성요소는 같은 문제를 다른 방식으로 해결한다.

핵심 모델:

- `docs`는 지식의 원천이다.
- `agents`는 역할과 책임의 모델이다.
- `skills`는 반복 가능한 작업 절차이다.
- `hooks`는 자동 개입하는 가드레일과 관측 장치이다.
- `context map`은 이 구성요소들을 연결하는 라우터이다.

### 4.1 Docs: 지식의 원천

`docs`는 코드만으로 알 수 없는 맥락을 저장한다.
에이전트가 작업 중 참조해야 하는 프로젝트의 기억이다.

#### 담당할 것

- 프로젝트 개요
- 시스템 아키텍처
- 도메인 지식
- 외부 시스템 연계 방식
- 스펙 의사결정 과정과 근거
- 워크플로우와 협업 방식
- 보안 정책
- 에이전트 환경 개선 기록

#### 담당하지 않을 것

- 매번 자동 실행되어야 하는 검사
- 특정 작업의 긴 실행 절차
- 도구 호출 자체
- 임시 아이디어

#### 문서 배치

| 문서 | 역할 | 로드 방식 |
| --- | --- | --- |
| `README.md` | 사람과 에이전트 모두를 위한 프로젝트 진입점 | 필요 시 참조 |
| `AGENTS.md` | 모든 코딩 에이전트가 공유해야 하는 작업 계약 | 에이전트 작업 시 항상 참조 |
| `CLAUDE.md` | Claude 계열 에이전트를 위한 짧은 운용 지침 | Claude 사용 시 자동/우선 참조 |
| `docs/README.md` | 문서 인덱스 | 작업 시작 시 라우팅 |
| `docs/architecture.md` | 시스템 구조와 주요 흐름 | 구현/리팩터링 시 참조 |
| `docs/domain/` | 코드에 드러나지 않는 도메인 지식 | 도메인 판단 필요 시 참조 |
| `docs/specs/` | 상세 스펙 | 히스토리 참고 |
| `docs/plans/` | 상세 스펙 설계 문서 | 히스토리 참고 |
| `docs/decisions/` | ADR, 스펙 결정 근거 | 구조 변경 전 참조 |
| `docs/integrations/` | 외부 API, 인증, webhook, queue | 연동 작업 시 참조 |
| `docs/workflows/` | 리뷰, 릴리즈, 협업 규칙 | 절차 작업 시 참조 |
| `docs/security.md` | 금지 행동, 비밀정보, 권한 정책 | 위험 작업 전 참조 |

#### 최상위 문서 역할 분리

`README.md`, `AGENTS.md`, `CLAUDE.md`는 모두 루트에 둘 수 있지만, 역할은 분리한다.
중복이 생기면 에이전트가 어느 문서를 우선해야 하는지 혼란스러워지므로 각 문서의 책임을 좁게 유지한다.

| 문서 | 1차 독자 | 핵심 역할 | 포함할 것 | 포함하지 않을 것 |
| --- | --- | --- | --- | --- |
| `README.md` | 사람, 신규 참여자, 에이전트 | 프로젝트의 공개 진입점 | 프로젝트 목적, 빠른 시작, 전체 문서 링크, 주요 디렉터리 안내 | 에이전트별 행동 규칙, 긴 내부 의사결정, 도구별 프롬프트 |
| `AGENTS.md` | Codex, Claude, Gemini 등 공통 코딩 에이전트 | 작업 수행을 위한 공통 계약 | 작업 원칙, 파일 편집 규칙, 테스트/검증 명령, 문서 참조 순서, 금지 행동 | 특정 에이전트 제품에만 해당하는 설정, 긴 철학, 상세 아키텍처 설명 |
| `CLAUDE.md` | Claude 계열 에이전트 | Claude가 작업할 때 우선 흡수할 짧은 운용 지침 | 카파시식 간단 지침, 인간/에이전트 역할 경계, 판단 원칙, Claude 사용 시 주의점 | 프로젝트 전체 매뉴얼, 모든 컨벤션의 중복 사본, 긴 도메인 문서 |

#### 검증 기준

- 에이전트가 작업 전에 필요한 문서를 찾을 수 있는가?
- 문서가 길어졌을 때 인덱스를 통해 필요한 부분만 찾을 수 있는가?
- 코드에 없는 판단 근거가 문서에 남아 있는가?
- 반복해서 설명하는 내용이 문서로 승격되는가?
- `README.md`, `AGENTS.md`, `CLAUDE.md`가 서로 중복되지 않고 각자의 독자를 만족시키는가?
- Claude가 `CLAUDE.md`만 읽어도 운용 철학을 이해하고, 실제 작업 규칙은 `AGENTS.md`로 이동하는가?

#### 안티패턴

- `AGENTS.md`에 모든 지식을 넣어 항상 로드 비용을 키우는 것
- `CLAUDE.md`를 두 번째 `AGENTS.md`처럼 만들어 같은 규칙을 중복하는 것
- `README.md`에 에이전트 전용 규칙을 섞어 사람용 진입점을 흐리는 것
- 결정 근거 없이 현재 상태만 문서화하는 것
- 구현과 동기화되지 않는 긴 설명을 방치하는 것
- `memo/`에 있어야 할 미정 아이디어를 정식 정책처럼 문서화하는 것

### 4.2 Agents: 역할과 책임

`agents`는 작업을 수행하는 주체의 역할 모델이다.
여기서 말하는 에이전트는 특정 제품의 런타임 기능만이 아니라, 작업을 어떤 역할로 나누고 어떤 책임을 부여할지에 대한 설계 단위이다.

#### 기본 구분

| 구분 | 역할 |
| --- | --- |
| 공통 에이전트 규칙 | `AGENTS.md`에 둔다. 모든 에이전트가 공유한다. |
| 역할별 에이전트 모델 | `docs/agent/roles.md`에 둔다. 작업 유형별 책임을 정의한다. |
| 도구별 설정 | Claude, Codex, Gemini 등 도구별 차이는 별도 파일이나 설정에 둔다. |

#### 후보 역할

| 역할 | 책임 | 주로 참조할 문서 |
| --- | --- | --- |
| `planner` | 작업 범위 정의, 필요한 맥락 식별, 단계 분해 | `docs/README.md`, `context-map.md` |
| `implementer` | 코드 변경, 테스트, 로컬 검증 | `AGENTS.md`, `architecture.md` |
| `reviewer` | 결함, 회귀, 누락 테스트 탐지 | `workflows/review-process.md`, `security.md` |
| `security-auditor` | 권한, 비밀정보, 위험 명령, 외부 연계 점검 | `security.md`, `integrations/` |
| `doc-maintainer` | 변경된 지식의 문서 반영 | `docs/README.md`, `decisions/` |
| `agent-env-maintainer` | 에이전트 실패 패턴 분석과 환경 개선 | `docs/agent/` |

#### 검증 기준

- 작업 유형에 따라 필요한 역할이 명확히 선택되는가?
- 역할별로 봐야 할 문서와 사용해야 할 skill이 분리되어 있는가?
- 역할이 겹칠 때 책임 경계가 무너지지 않는가?
- 에이전트가 자기 역할 밖의 판단을 할 때 사람이 개입할 지점이 있는가?

#### 안티패턴

- 모든 에이전트에게 모든 책임을 주는 것
- 역할 설명이 추상적이라 실제 작업 지침이 되지 않는 것
- 역할별 참조 문서가 없어 매번 맥락 탐색을 새로 하는 것
- 리뷰어와 구현자의 관점을 분리하지 않는 것

### 4.3 Skills: 반복 가능한 작업 절차

`skills`는 특정 작업 유형에서 반복되는 절차를 캡슐화한다.
항상 로드되는 지식이 아니라, 필요할 때 로드되는 실행 지침이다.

#### 담당할 것

- 반복되는 작업 순서
- 작업 시작 전 확인할 문서
- 사용할 명령과 도구
- 산출물 형식
- 완료 기준
- 흔한 실패 패턴과 대응 방식

#### 담당하지 않을 것

- 프로젝트 전체 지식
- 항상 적용되는 보안 정책
- 장기적인 의사결정 근거
- 특정 기능의 임시 구현 메모

#### 초기 후보 skill

| skill | 사용 시점 | 목적 |
| --- | --- | --- |
| `agent-environment-audit` | 에이전트 작업 실패 후 | 누락된 맥락과 개선 위치를 분류 |
| `feature-implementation` | 신규 기능 구현 시 | 요구사항, 설계, 구현, 테스트 흐름 표준화 |
| `bug-investigation` | 버그 수정 시 | 재현, 원인 분석, 회귀 테스트 추가 |
| `code-review` | PR 또는 로컬 변경 리뷰 시 | 결함, 회귀, 보안 위험, 테스트 누락 탐지 |
| `docs-sync` | 코드나 정책 변경 후 | 문서 업데이트 필요 여부 점검 |
| `integration-change` | 외부 시스템 연계 변경 시 | 인증, 권한, 장애, 관측 포인트 확인 |

#### 검증 기준

- 같은 유형의 작업에서 매번 반복 설명이 줄어드는가?
- skill이 필요한 문서를 올바르게 찾아가게 하는가?
- skill 실행 후 산출물 형식이 안정적인가?
- 실패 패턴이 skill 개선으로 환원되는가?

#### 안티패턴

- 너무 많은 내용을 skill에 넣어 문서 저장소처럼 쓰는 것
- 한 번만 쓸 절차를 skill로 만드는 것
- 프로젝트마다 달라야 하는 내용을 전역 skill로 고정하는 것
- 완료 기준이 없어 실행 품질을 평가할 수 없는 것

### 4.4 Hooks: 가드레일과 관측

`hooks`는 에이전트가 도구를 쓰는 순간 자동으로 개입하는 장치이다.
복잡한 판단보다는 차단, 경고, 기록, 자동 주입처럼 작고 명확한 역할을 맡긴다.

#### 담당할 것

- 위험 명령 차단
- 비밀정보 접근 또는 유출 가능성 경고
- 특정 키워드 기반 문서 참조 안내
- 작업 로그 자동 기록
- 테스트/포맷/문서 동기화 누락 감지
- 권한 요청 패턴 관측

#### 담당하지 않을 것

- 긴 설명 제공
- 복잡한 설계 판단
- 에이전트의 모든 작업 자동 승인
- 문서 전체를 강제로 주입하는 것

#### 초기 후보 hook

| hook | 트리거 | 목적 |
| --- | --- | --- |
| `dangerous-command-guard` | shell command 실행 전 | `rm -rf`, `sudo`, `git reset --hard`, `curl | sh` 등 차단 |
| `secret-access-warning` | `.env`, key, credential 접근 시 | 비밀정보 취급 경고 |
| `context-hint` | 특정 키워드 감지 시 | 관련 문서 참조 안내 |
| `task-log-capture` | 작업 종료 시 | 참조 문서, 실행 명령, 실패 원인 기록 |
| `docs-sync-check` | 코드 변경 후 | 문서 업데이트 필요 여부 경고 |

#### 검증 기준

- 위험 행동을 실제로 차단하거나 경고하는가?
- 정상 작업의 흐름을 과도하게 방해하지 않는가?
- hook 로그가 개선 루프에 사용할 만큼 구조화되어 있는가?
- 우회 가능한 패턴에 대해 최소한의 방어층을 제공하는가?

#### 안티패턴

- 모든 명령을 과도하게 막아 생산성을 떨어뜨리는 것
- hook 안에 긴 정책 설명을 넣는 것
- 경고만 많고 개선 루프와 연결되지 않는 것
- 자동 승인 범위를 넓혀 보안 경계를 흐리는 것

### 4.5 Context Map: 구성요소를 연결하는 라우터

`context map`은 작업 유형에 따라 어떤 문서, 역할, skill, hook이 관여해야 하는지 연결한다.
에이전트 환경에서 가장 중요한 인덱스 문서가 된다.

#### 기본 형태

| 작업 유형 | 우선 역할 | 먼저 볼 문서 | 사용할 skill | 관여 hook |
| --- | --- | --- | --- | --- |
| 신규 기능 구현 | `planner`, `implementer` | `AGENTS.md`, `architecture.md` | `feature-implementation` | `docs-sync-check` |
| 버그 수정 | `implementer`, `reviewer` | `AGENTS.md`, 관련 테스트 | `bug-investigation` | `task-log-capture` |
| PR 리뷰 | `reviewer` | `review-process.md`, `security.md` | `code-review` | 없음 |
| 외부 API 연동 | `planner`, `security-auditor` | `integrations/`, `security.md` | `integration-change` | `secret-access-warning` |
| 문서 정리 | `doc-maintainer` | `docs/README.md` | `docs-sync` | 없음 |
| 에이전트 환경 개선 | `agent-env-maintainer` | `docs/agent/` | `agent-environment-audit` | `task-log-capture` |

#### 검증 기준

- 작업 유형만 보고 필요한 맥락을 찾을 수 있는가?
- 에이전트가 불필요한 문서를 과하게 읽지 않는가?
- 실패 후 어느 구성요소를 고쳐야 하는지 바로 판단되는가?
- 새로운 작업 유형이 생겼을 때 행을 추가하는 방식으로 확장 가능한가?

### 4.6 개선 위치 결정 규칙

검증 루프에서 발견한 문제는 아래 기준으로 반영 위치를 정한다.

| 발견된 문제 | 개선 위치 |
| --- | --- |
| 에이전트가 항상 알아야 할 규칙을 몰랐다 | `AGENTS.md` |
| 특정 작업 절차를 반복해서 설명해야 했다 | `skills/` |
| 위험한 명령이나 행동을 시도했다 | `hooks/` |
| 코드에 없는 도메인 지식을 몰랐다 | `docs/domain/` |
| 과거 의사결정 근거를 몰랐다 | `docs/decisions/` |
| 어디서 정보를 찾아야 할지 몰랐다 | `docs/README.md`, `docs/agent/context-map.md` |
| 역할별 책임이 불명확했다 | `docs/agent/roles.md` |
| 외부 시스템 제약을 놓쳤다 | `docs/integrations/`, `docs/security.md` |
| 작업 결과를 재현하거나 평가할 수 없었다 | `docs/agent/evaluation-loop.md`, task log |

### 4.7 자산 선택 기준

새로운 자동화 자산을 만들기 전에 가장 작은 적절한 형태를 고른다.
목표는 많은 자산을 만드는 것이 아니라, 필요한 순간에 필요한 자산이 정확히 작동하게 하는 것이다.

| 질문 | 선택 |
| --- | --- |
| 프로젝트 고유 기억, 규칙, 명령, 맥락인가? | `docs`, `AGENTS.md` |
| 반복 가능한 판단 절차나 작업 방법론인가? | `skills` |
| reference, script, template bundle 이 필요한가? | `skills` |
| 별도 컨텍스트에서 specialist 판단이 필요한가? | `agents` |
| 병렬 작업, model/tool 격리, 독립 리뷰가 필요한가? | `agents` |
| 매 이벤트마다 자동 보장되어야 하는가? | `hooks` |
| 파일 수정 전 차단해야 하는가? | `PreToolUse` hook |
| 파일 수정 후 best-effort 정리나 기록이 필요한가? | `PostToolUse` hook |
| 외부 시스템 연동을 묶어야 하는가? | plugin 또는 MCP |

판단 순서:

1. 프로젝트 고유 정보면 먼저 `docs` 또는 `AGENTS.md`에 둔다.
2. 자동 보장이 필요하면 `hook`을 고려한다.
3. 별도 컨텍스트와 specialist 판단이 필요하면 `agent`를 고려한다.
4. 반복 가능한 절차와 판단 기준이면 `skill`을 고려한다.
5. 어느 쪽도 명확하지 않으면 새 자산을 만들지 않는다.

### 4.8 공통 검증 축

`agents`, `skills`, `hooks`는 실행 방식이 다르지만 같은 기준으로 검증할 수 있어야 한다.
검증 루프에서는 아래 축을 기준으로 gap을 기록한다.

| 검증 축 | 질문 | 적용 대상 |
| --- | --- | --- |
| Activation | 언제 활성화되는가? trigger가 명확한가? | `agents`, `skills`, `hooks` |
| Scope | 어떤 입력, 파일, 작업 범위에만 적용되는가? | `agents`, `skills`, `hooks` |
| Near-miss | 비슷하지만 쓰면 안 되는 경우가 정의되어 있는가? | `agents`, `skills` |
| Output contract | 실행 후 무엇을 남기는가? 호출자가 다음 행동을 결정할 수 있는가? | `agents`, `skills`, `hooks` |
| Capability surface | 가진 권한이 책임보다 넓지 않은가? | `agents`, `skills`, `hooks` |
| Effect gate | 파일 수정, 설정 변경, 외부 요청 같은 부수 효과 전에 승인 또는 명시적 호출이 있는가? | `agents`, `skills`, `hooks` |
| Verification | should-trigger, should-not-trigger, no-op, 실패 케이스를 검증할 수 있는가? | `agents`, `skills`, `hooks` |
| Overlap | 비슷한 자산과 trigger, scope, output 차이가 설명되는가? | `agents`, `skills`, `hooks` |

#### 자산별 보강 기준

| 자산 | 반드시 확인할 것 |
| --- | --- |
| `skills` | activation signal, workflow, output contract, approval gate, bundled resource 분리 |
| `agents` | specialist role, 기본 입력 범위, tools/model 범위, quality gate, no-finding case |
| `hooks` | event, matcher, settings 등록 위치, script 위치, exit behavior, 빠른 no-op, 보안 경계 |

#### gap 기록 기준

다음 중 하나가 실제 작업 품질, 안전, 라우팅에 영향을 주면 gap으로 기록한다.

- 활성화 조건이 불명확해 잘못 호출될 수 있다.
- scope가 넓거나 모호해 결과 품질이 흔들린다.
- 부수 효과가 있는데 gate가 없다.
- 권한 범위가 책임보다 넓다.
- output contract가 없어 결과를 평가하기 어렵다.
- 프로젝트 고유 기억과 재사용 가능한 절차가 섞여 있다.
- 자주 로드되는 자산에 긴 reference가 섞여 context 비용을 키운다.
- 비슷한 자산과 차이가 설명되지 않는다.
- no-op 또는 no-finding 상황을 처리하지 못한다.

### 4.9 1차 적용 원칙

처음부터 모든 구성요소를 완성하지 않는다.
설계 문서, 런타임 자산, 검증 루프가 최소 단위로 연결되는지 먼저 확인한다.

1차 적용은 다음 원칙을 따른다.

- 문서 인덱스와 context map을 먼저 만든다.
- skill과 hook은 각각 하나씩만 먼저 만든다.
- agent는 역할 모델을 먼저 정의하고, 실제 subagent 승격은 검증 후 결정한다.
- 실제 작업 로그를 남기고 golden-set과 비교한다.
- 발견된 gap은 `docs`, `agents`, `skills`, `hooks` 중 하나로 환원한다.

구체적인 생성 순서는 `5.7 1차 MVP 생성 순서`에서 관리한다.

## 5. 배치 설계

4번이 구성요소의 개념 모델이라면, 5번은 실제 파일과 디렉터리에 어떻게 배치할지 정한다.
핵심 원칙은 설계 문서와 런타임 자산을 분리하는 것이다.

- `docs/agent/`는 에이전트 환경 설계의 source of truth이다.
- `.claude/agents`, `.claude/skills`, `.claude/hooks`는 Claude 런타임에서 실제 실행되는 자산이다.
- `AGENTS.md`는 도구 공통 작업 계약이다.
- `CLAUDE.md`는 Claude용 짧은 운용 철학이다.
- `memo/`는 아직 정식 정책으로 승격되지 않은 아이디어를 둔다.

### 5.1 전체 디렉터리 구조

초기 목표 구조:

```text
.
├── README.md
├── AGENTS.md
├── CLAUDE.md
├── docs/
│   ├── README.md
│   ├── architecture.md
│   ├── security.md
│   ├── agent/
│   │   ├── README.md
│   │   ├── context-map.md
│   │   ├── roles.md
│   │   ├── evaluation-loop.md
│   │   ├── golden-set.md
│   │   ├── task-log-template.md
│   │   └── logs/
│   ├── decisions/
│   ├── domain/
│   ├── integrations/
│   └── workflows/
├── .claude/
│   ├── settings.json
│   ├── agents/
│   ├── skills/
│   └── hooks/
└── memo/
    └── what-to-do.md
```

### 5.2 Docs 배치

`docs`는 에이전트가 참조할 프로젝트 지식과 운영 원칙을 둔다.
런타임에서 실행되는 파일이 아니라, 실행 자산이 참조해야 하는 기준 문서이다.

| 경로 | 역할 |
| --- | --- |
| `docs/README.md` | 문서 인덱스. 작업 유형별로 어떤 문서를 볼지 안내 |
| `docs/architecture.md` | 시스템 구조, 주요 모듈, 데이터 흐름 |
| `docs/security.md` | 비밀정보, 권한, 위험 명령, 외부 연계 보안 정책 |
| `docs/agent/README.md` | 에이전트 환경 문서의 진입점 |
| `docs/agent/context-map.md` | 작업 유형별 문서, 역할, skill, hook 라우팅 |
| `docs/agent/roles.md` | 역할별 agent 모델과 실제 subagent 승격 기준 |
| `docs/agent/evaluation-loop.md` | 실행 기록, gap 분석, 개선 반영 루프 |
| `docs/agent/golden-set.md` | 작업 유형별 기대 context와 기대 행동 |
| `docs/agent/task-log-template.md` | 작업 후 기록할 항목 템플릿 |
| `docs/agent/logs/` | 실제 작업 로그와 gap 기록 |
| `docs/decisions/` | ADR과 스펙 의사결정 근거 |
| `docs/domain/` | 코드에 드러나지 않는 도메인 지식 |
| `docs/integrations/` | 외부 API, 인증, webhook, queue 구조 |
| `docs/workflows/` | 리뷰, 릴리즈, 협업, 코딩 컨벤션 |

### 5.3 Agents 배치

`docs/agent/roles.md`에는 역할 모델을 둔다.
`.claude/agents/`에는 실제 Claude subagent로 승격된 specialist만 둔다.

역할 모델과 런타임 agent를 분리하는 이유:

- 모든 역할이 별도 subagent일 필요는 없다.
- `planner`, `implementer`처럼 기본 작업 흐름에 가까운 역할은 처음에는 문서나 skill로 충분할 수 있다.
- `reviewer`, `security-auditor`, `agent-env-maintainer`처럼 별도 컨텍스트와 specialist 판단이 필요한 역할부터 agent로 승격한다.

초기 배치 후보:

| 경로 | 상태 | 역할 |
| --- | --- | --- |
| `docs/agent/roles.md` | 설계 문서 | 모든 역할 정의와 승격 기준 |
| `.claude/agents/reviewer.md` | 후보 | 변경사항의 결함, 회귀, 테스트 누락 탐지 |
| `.claude/agents/security-auditor.md` | 후보 | 권한, 비밀정보, 위험 명령, 외부 연계 점검 |
| `.claude/agents/agent-env-maintainer.md` | 후보 | 에이전트 실패 패턴과 환경 개선안 분석 |

agent로 승격할 때 필요한 항목:

- activation 조건
- 기본 입력 범위와 제외 범위
- 사용할 tools/model 범위
- output contract
- no-finding case
- review/diagnostic 역할의 quality gate

### 5.4 Skills 배치

`skills`는 반복 가능한 작업 절차를 둔다.
프로젝트 고유 지식은 skill 본문에 직접 넣지 않고, `docs`와 `AGENTS.md`를 참조하게 한다.

초기 배치 후보:

| 경로 | 역할 |
| --- | --- |
| `.claude/skills/agent-environment-audit/SKILL.md` | 작업 실패 후 누락 context와 개선 위치 분류 |
| `.claude/skills/feature-implementation/SKILL.md` | 신규 기능 구현 흐름 표준화 |
| `.claude/skills/bug-investigation/SKILL.md` | 버그 재현, 원인 분석, 회귀 테스트 흐름 |
| `.claude/skills/code-review/SKILL.md` | 리뷰 수행 기준과 보고 형식 |
| `.claude/skills/docs-sync/SKILL.md` | 코드/정책 변경 후 문서 동기화 점검 |
| `.claude/skills/integration-change/SKILL.md` | 외부 연계 변경 시 인증, 장애, 관측 포인트 확인 |

skill을 만들 때 필요한 항목:

- activation signal
- when not to use 또는 near-miss
- workflow
- output contract
- 부수 효과가 있는 경우 approval gate
- should-trigger, should-not-trigger, no-op 검증 케이스
- 필요한 references, scripts, templates 분리

### 5.5 Hooks 배치

`hooks`는 Claude runtime event에 자동 반응하는 guardrail과 관측 장치이다.
hook은 스크립트 파일만 있어서는 동작하지 않고, `.claude/settings.json`에 등록되어야 한다.

초기 배치 후보:

| 경로 | event | 목적 | 기본 동작 |
| --- | --- | --- | --- |
| `.claude/hooks/dangerous-command-guard.sh` | `PreToolUse` | 위험 shell command 차단 | block |
| `.claude/hooks/secret-access-warning.sh` | `PreToolUse` | 민감 파일 접근 경고 또는 차단 | warn 또는 block |
| `.claude/hooks/context-hint.sh` | `UserPromptSubmit` | 짧은 routing hint 주입 | non-blocking |
| `.claude/hooks/task-log-capture.sh` | `PostToolUse` 또는 session 종료 시점 | 작업 기록 보조 | non-blocking |
| `.claude/hooks/docs-sync-check.sh` | `PostToolUse` | 코드 변경 후 문서 동기화 필요성 경고 | non-blocking |

hook을 만들 때 필요한 항목:

- event와 matcher
- settings 등록 위치
- script 위치
- block/warn/no-op exit behavior
- 입력 JSON의 방어적 파싱
- path quoting
- 빠른 no-op
- 외부 전송 금지
- false positive 수정 절차

### 5.6 검증 로그와 골든셋 배치

검증 루프는 실제 에이전트 실행 기록과 기대 행동을 비교한다.
이를 위해 `golden-set`과 `task log`를 분리한다.

| 경로 | 역할 |
| --- | --- |
| `docs/agent/golden-set.md` | 작업 유형별 기대 context, 기대 절차, 기대 산출물 |
| `docs/agent/task-log-template.md` | 작업 실행 후 기록할 공통 템플릿 |
| `docs/agent/logs/YYYY-MM-DD-*.md` | 실제 작업 실행 기록 |
| `docs/agent/evaluation-loop.md` | golden-set과 log를 비교해 개선 위치를 결정하는 절차 |

task log에 남길 최소 항목:

- 작업 유형
- 사용한 agent, skill, hook
- 참조한 문서
- 실행한 명령
- 기대 context와 실제 참조 context의 차이
- 실패 또는 비효율의 원인
- 개선 대상
- no-op 판단 근거

### 5.7 1차 MVP 생성 순서

처음에는 문서와 런타임 자산을 동시에 많이 만들지 않는다.
먼저 라우팅과 검증 루프가 돌아가는 최소 구조를 만든다.

1. `AGENTS.md`
2. `CLAUDE.md`
3. `docs/README.md`
4. `docs/agent/context-map.md`
5. `docs/agent/roles.md`
6. `docs/agent/evaluation-loop.md`
7. `docs/agent/golden-set.md`
8. `docs/agent/task-log-template.md`
9. `.claude/skills/agent-environment-audit/SKILL.md`
10. `.claude/hooks/dangerous-command-guard.sh`
11. `.claude/settings.json`

이후 실제 작업 3개를 실행해 `golden-set`과 `logs`를 비교하고, gap을 `docs`, `agents`, `skills`, `hooks` 중 하나로 환원한다.

## 6. 체크리스트

### 문서 배치

- [ ] `README.md`, `AGENTS.md`, `CLAUDE.md`의 역할이 중복되지 않는가?
- [ ] `docs/README.md`가 문서 인덱스 역할을 하는가?
- [ ] `docs/agent/context-map.md`가 작업 유형별 라우팅을 제공하는가?
- [ ] `docs/agent/roles.md`가 역할 모델과 subagent 승격 기준을 분리하는가?
- [ ] `docs/agent/evaluation-loop.md`가 log와 golden-set 비교 절차를 정의하는가?
- [ ] `docs/agent/golden-set.md`가 작업 유형별 기대 context를 정의하는가?

### 맥락 참조

- [ ] 에이전트가 작업 시작 시 `AGENTS.md`를 참조하는가?
- [ ] Claude는 `CLAUDE.md`에서 운용 철학을 얻고, 실제 작업 규칙은 `AGENTS.md`로 이동하는가?
- [ ] 문서 인덱스를 통해 필요한 상세 문서로 이동하는가?
- [ ] 코드에 없는 의사결정 근거를 `docs/decisions/`에서 찾을 수 있는가?
- [ ] 도메인 지식과 외부 연계 맥락이 각각 `docs/domain/`, `docs/integrations/`로 분리되는가?

### 자산 선택

- [ ] 프로젝트 고유 기억을 skill이나 agent에 하드코딩하지 않는가?
- [ ] 반복 절차는 skill로 분리되는가?
- [ ] 별도 컨텍스트 specialist 판단이 필요한 경우만 agent로 승격하는가?
- [ ] 매 이벤트마다 자동 보장해야 하는 것만 hook으로 두는가?
- [ ] 외부 시스템 연동은 plugin 또는 MCP 후보로 분리해 검토하는가?

### Skills

- [ ] `agent-environment-audit` skill의 activation signal이 명확한가?
- [ ] skill마다 workflow, output contract, no-op case가 있는가?
- [ ] 부수 효과가 있는 skill에는 approval gate가 있는가?
- [ ] should-trigger, should-not-trigger 검증 케이스가 있는가?

### Agents

- [ ] `docs/agent/roles.md`의 역할과 실제 `.claude/agents/` 후보가 분리되어 있는가?
- [ ] agent 후보마다 scope, tools/model, output contract가 있는가?
- [ ] reviewer/security-auditor 같은 진단 역할에 quality gate가 있는가?
- [ ] advisory agent가 불필요한 mutation 권한을 갖지 않는가?

### Hooks

- [ ] hook script와 `.claude/settings.json` 등록이 함께 정의되어 있는가?
- [ ] hook마다 event와 matcher가 좁게 잡혀 있는가?
- [ ] block, warn, no-op 동작이 구분되어 있는가?
- [ ] hook input을 방어적으로 파싱하고 path를 quote하는가?
- [ ] non-blocking hook이 사용자 작업을 차단하지 않는가?
- [ ] 외부 전송이나 long-running 작업이 hook에 들어가지 않는가?

### 검증 루프

- [ ] 실제 작업 로그가 `docs/agent/logs/`에 남는가?
- [ ] task log가 golden-set과 비교 가능한 형식인가?
- [ ] gap이 `docs`, `agents`, `skills`, `hooks` 중 하나로 분류되는가?
- [ ] 개선 후 같은 유형의 작업으로 재검증하는가?

## 7. 다음 단계

1. `AGENTS.md` 초안을 만든다.
2. `CLAUDE.md` 초안을 만든다.
3. `docs/README.md`에 문서 인덱스를 만든다.
4. `docs/agent/context-map.md`를 만든다.
5. `docs/agent/roles.md`를 만든다.
6. `docs/agent/evaluation-loop.md`를 만든다.
7. `docs/agent/golden-set.md`를 만든다.
8. `docs/agent/task-log-template.md`를 만든다.
9. `.claude/skills/agent-environment-audit/SKILL.md` 초안을 만든다.
10. `.claude/hooks/dangerous-command-guard.sh`와 `.claude/settings.json` 초안을 만든다.
11. 실제 작업 3개를 샘플로 실행하고 log와 golden-set을 비교한다.
