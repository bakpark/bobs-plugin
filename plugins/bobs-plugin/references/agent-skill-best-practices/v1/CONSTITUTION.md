# 스킬·에이전트 구성 헌법

생성: 2026-05-16
근거: `SIGNALS.md` 의 관측 결과와 `writing-skills`, `skill-creator`, `claude-automation-recommender` 계열 참고 자료

이 문서는 유저 스코프의 스킬과 서브에이전트를 설계할 때 우선 적용할 상위 원칙이다. 세부 작성 규칙은 `SKILL-GUIDE.md` 와 `AGENT-GUIDE.md` 에 둔다.

---

## 1. 문서 체계

| 문서 | 역할 |
|---|---|
| `SIGNALS.md` | 참고 자원에서 관측한 증거와 수치 |
| `CONSTITUTION.md` | 증거에서 도출한 안정 원칙과 역할 경계 |
| `SKILL-GUIDE.md` | 스킬 작성 실무 가이드 |
| `AGENT-GUIDE.md` | 서브에이전트 작성 실무 가이드 |
| `HOOK-GUIDE.md` | 훅 작성 실무 가이드 |
| `GUIDE.md` | 기존 통합 가이드. 향후 위 문서들을 기준으로 재구성 대상 |

출처 성격은 세 단계로 구분한다.

- **Observed**: 현재 표본에서 직접 관측된 패턴
- **Normative**: `writing-skills`, `skill-creator`, Anthropic/Claude 계열 작성 지침에서 나온 규범
- **Inferred**: 관측과 규범을 유저 스코프 최적화에 적용한 판단

적용 우선순위는 다음 순서로 둔다.

1. 사용자 직접 지시
2. 프로젝트 로컬 CLAUDE.md
3. 유저 스코프 CLAUDE.md
4. `CONSTITUTION.md`
5. `SKILL-GUIDE.md` / `AGENT-GUIDE.md` / `HOOK-GUIDE.md`
6. `SIGNALS.md` 의 관측 데이터
7. `GUIDE.md` 의 기존 통합 메모

상위 지시와 하위 가이드가 충돌하면 상위 지시가 이긴다. 단, 보안·데이터 유출·권한 관련 안전 규칙은 별도 검토 없이 낮추지 않는다.

---

## 2. 핵심 원칙

### 2.1 Description Is The Router

`description` 은 설명문이 아니라 라우팅 계약이다.

스킬과 에이전트의 `description` 은 매 세션 카탈로그에 노출되어 "지금 이 자원을 로드하거나 호출해야 하는가" 를 결정한다. 따라서 description 에는 내부 workflow 요약이 아니라 trigger 조건, 사용자가 실제로 말할 표현, 적용될 상황, near-miss 를 넣어야 한다.

잘못된 description 은 본문을 우회하게 만든다. 절차를 description 에 요약하면 모델이 본문을 읽지 않고 description 만 따라 단축 실행할 수 있다.

### 2.2 Skills Package Methods; Agents Package Roles

스킬은 방법을 캡슐화한다.

- 반복 가능한 절차
- 판단 기준
- 체크리스트
- 참고 자료
- 검증 루프
- 사용자 협업 흐름

에이전트는 역할을 캡슐화한다.

- 별도 컨텍스트 창에서 일하는 specialist
- 명확한 mission 과 scope
- 제한된 tool 권한
- 선택된 model
- 호출자에게 돌려줄 output contract

스킬은 "어떻게 판단하고 진행할지" 를 가르친다. 에이전트는 "이 역할의 전문가가 이 입력을 받아 무엇을 반환할지" 를 수행한다.

### 2.3 Scope Is Quality Control

좋은 스킬과 에이전트는 범위가 좁다.

"최근 수정된 코드", "`git diff`", "CLAUDE.md 파일", "주석 변경", "특정 feature execution path" 처럼 대상 범위가 좁을수록 결과 품질이 안정된다. 넓은 요청은 한 자원에 모두 넣기보다 orchestrator 가 여러 specialist 를 호출하도록 나누는 편이 낫다.

### 2.4 Output Is A Contract

스킬과 에이전트는 결과 형태를 약속해야 한다.

특히 에이전트는 호출자에게 돌아오는 산출물이므로 `Output Guidance`, `Output Format`, severity grouping, confidence threshold, no-finding case 를 명확히 둬야 한다. 스킬도 report, checklist, approval gate, document structure 같은 산출 지시를 본문에 포함해야 한다.

### 2.5 Explain Why; Do Not Must-Bomb

강한 명령은 제한적으로 쓴다.

`MUST`, `NEVER`, hard gate 는 안전, 승인, discipline, false-positive gate 처럼 실제로 우회되면 문제가 되는 곳에 써야 한다. 일반 지침은 이유를 설명하는 편이 더 강하다. 모델은 규칙만 나열했을 때보다, 왜 그 순서와 제한이 중요한지 이해했을 때 더 안정적으로 행동한다.

### 2.6 Progressive Disclosure Protects Context

`SKILL.md` 와 에이전트 본문은 항상 컨텍스트 예산 안에서 읽힌다.

자주 로드되는 내용은 작아야 한다. 큰 rubric, API 문서, 템플릿, 스크립트, 예시는 `references/`, `scripts/`, `assets/` 로 분리한다. 본문은 언제 무엇을 읽을지 알려주는 선택자와 실행 절차 역할을 해야 한다.

### 2.7 Test Behavior, Not Aesthetics

스킬은 예쁜 문서가 아니라 행동을 바꾸는 장치다.

베이스라인 실패를 관찰하고, 그 실패를 막는 최소 지침을 쓰고, 다시 검증해야 한다. 실패 없이 작성한 스킬은 실제 문제를 고치는지 알 수 없다. description 도 should-trigger / should-not-trigger 케이스로 검증해야 한다.

### 2.8 Mutation Requires A Gate

파일 수정, 설정 변경, hook 등록, 배포, commit 같은 부수 효과는 분석과 보고 뒤에 와야 한다.

read-only 분석 스킬은 쓰기 도구를 제한하고 본문에서도 쓰기 금지를 명시한다. 수정 가능한 스킬은 report 또는 proposal 을 먼저 제시하고, 승인 후 변경한다.

### 2.9 CLAUDE.md Is Project Memory; Skills And Agents Are Reusable Assets

CLAUDE.md 는 프로젝트별 규칙과 맥락을 담는다.

스킬과 에이전트는 프로젝트를 넘나드는 반복 절차와 specialist 역할을 담는다. 프로젝트 고유 명령, 디렉토리 구조, 팀 규칙은 CLAUDE.md 에 둔다. 여러 프로젝트에서 반복되는 판단 절차는 스킬로 만들고, 별도 컨텍스트와 tool/model 격리가 필요한 specialist 는 에이전트로 만든다.

---

## 3. 기대 역할

### 3.1 스킬의 기대 역할

스킬은 호출된 메인 에이전트의 행동 방식을 바꾸는 재사용 가능한 방법론이다.

스킬이 해야 하는 일:
- 언제 적용되는지 description 으로 정확히 알려준다.
- 본문에서 절차, 판단 기준, 예외, 산출물을 명시한다.
- 큰 자료는 필요할 때만 읽도록 분리한다.
- 사용자와 협업해야 하는 지점과 승인 gate 를 표시한다.
- 검증 가능한 경우 테스트 프롬프트와 eval 루프를 가진다.

스킬이 하면 안 되는 일:
- 단발성 회고나 프로젝트 기록을 담는다.
- description 에 workflow 를 요약해 본문을 우회하게 만든다.
- deterministic enforcement 를 문서로만 해결하려 한다.
- 한 스킬에 여러 도메인, 여러 책임, 여러 자동화를 섞는다.
- 부수 효과가 있는데도 자동 호출을 허용한다.

스킬은 "판단이 필요한 반복 작업" 에 적합하다.

### 3.2 에이전트의 기대 역할

에이전트는 격리된 컨텍스트에서 특정 역할을 수행하는 specialist 다.

에이전트가 해야 하는 일:
- description 에 호출 조건과 near-miss 를 명시한다.
- 본문 첫머리에서 role, domain, mission 을 좁힌다.
- 기본 입력 범위와 제외 범위를 정한다.
- tool 권한과 model 선택이 역할에 맞아야 한다.
- output contract 를 명확히 해서 호출자가 바로 사용할 수 있게 한다.
- 리뷰/분석 에이전트는 confidence gate 로 false positive 를 줄인다.

에이전트가 하면 안 되는 일:
- 분석, 수정, commit, push, 배포까지 모두 수행한다.
- 모든 tool 권한을 기본값처럼 노출한다.
- 단순 절차나 참고 자료를 위해 별도 에이전트를 만든다.
- 다른 에이전트를 임의로 연쇄 호출한다.
- scope 없이 "thoroughly analyze everything" 같은 넓은 임무를 가진다.

에이전트는 "별도 컨텍스트, 병렬 작업, specialist 판단, tool/model 격리" 가 필요할 때 적합하다.

### 3.3 훅의 기대 역할

훅은 이 문서의 주 대상은 아니지만 책임 경계 때문에 함께 둔다.

훅은 판단보다 보장에 적합하다.

- formatter 실행
- typecheck 실행
- sensitive file 수정 차단
- lockfile 직접 편집 차단
- session/user prompt context 주입

매 이벤트마다 결정론적으로 실행되어야 한다면 스킬이나 에이전트가 아니라 훅을 고려한다.

---

## 4. 결정 프레임워크

| 필요 | 선택 |
|---|---|
| 반복 가능한 판단 절차, workflow, checklist | 스킬 |
| 사용자가 직접 호출하거나 Claude 가 알아서 적용할 방법론 | 스킬 |
| 별도 컨텍스트에서 specialist 가 분석/리뷰/생성 | 에이전트 |
| 병렬 작업, tool 제한, model 선택이 중요 | 에이전트 |
| 매번 자동 실행되어야 하는 결정론적 작업 | 훅 |
| 프로젝트 고유 규칙, 명령, 디렉토리 맥락 | CLAUDE.md |
| 여러 자원을 설치·배포하는 묶음 | 플러그인 |

트리거 메커니즘도 선택 기준에 포함한다.

| 자원 | 트리거 주체 | 트리거 신호 | 사용자 직접 호출 |
|---|---|---|---|
| 스킬 | Claude 또는 사용자 | frontmatter `description`, `/skill-name` | 가능 |
| 에이전트 | 호출자 Claude 또는 orchestrator | agent description + 호출 입력 | 불가 |
| 훅 | Claude Code runtime | event + matcher | 불가 |

간단한 판단 순서:

1. 프로젝트 고유 정보인가? 그러면 CLAUDE.md.
2. 매 이벤트마다 자동 실행되어야 하는가? 그러면 훅.
3. 별도 컨텍스트와 specialist role 이 필요한가? 그러면 에이전트.
4. 반복 가능한 절차나 판단 기준인가? 그러면 스킬.
5. 위 어디에도 명확히 들어가지 않으면 새 자원을 만들지 않는다.

---

## 5. 품질 기준

좋은 자원은 다음 질문에 답할 수 있어야 한다.

- 언제 활성화되는가?
- 언제 활성화되면 안 되는가?
- 어떤 입력 범위를 다루는가?
- 어떤 산출물을 반환하는가?
- 부수 효과가 있는가?
- tool/model 권한이 과하지 않은가?
- project-specific 정보와 reusable 지식이 섞이지 않았는가?
- 검증 방법이 있는가?

이 질문에 답하지 못하면 자원은 아직 설계되지 않은 것이다.
