# RED-GREEN-REFACTOR for Agents

> 출처: `bobs-plugin:writing-agents` §"RED-GREEN-REFACTOR for Agents" 및 §"Bulletproofing Agents Against Rationalization". 본 파일은 agent-creator 가 §When the loop stalls 에서 참조하는 보조 검증 도구를 self-contained 형태로 가져온 것이다.

## The Iron Law

```
NO AGENT WITHOUT A FAILING BASELINE FIRST
```

baseline 실패 없이 작성된 에이전트는 *어떤 drift 를 막는지* 알 수 없다. 작성 *전* baseline prompt 로 generic subagent (커스텀 `subagent_type` 없이 `Agent({prompt: ...})`) 를 dispatch 해 무엇이 실패하는지 관찰한다. 그 실패가 에이전트의 존재 이유다.

이 원칙은 신규 에이전트 작성에도, 기존 에이전트 수정에도 동일하게 적용된다. "이미 잘 안다", "단순 frontmatter 변경이다", "wrapper 일 뿐이다" 같은 합리화는 baseline 없이 작성을 정당화하지 않는다.

## RED — 실패하는 baseline 관찰

에이전트 없이 generic subagent 에 pressure scenario 를 던지고 다음을 verbatim 으로 기록한다.

| Drift 축 | 관찰 질문 |
|---|---|
| Role drift | 어떤 역할을 *임의로* 추정했는가? specialist 로 행동했나, generalist 로 표류했나? |
| Tool drift | 어떤 도구를 사용했는가? advisory 역할인데 Write/Edit 를 사용했나? |
| Output drift | 산출물이 parseable 한가? prose blob 인가? severity / confidence 가 일관적인가? |
| Dispatch drift | 다른 에이전트를 dispatch 하려 했는가? (orchestration drift) |
| Rationalization | "왜 도구를 썼는지" / "왜 범위를 넘어갔는지" 의 verbatim 변명을 모두 수집 |

이 단계는 "test fail 을 본다" — 에이전트 작성 전 generic subagent 가 *자연스럽게* 어떻게 행동하는지 관찰해야 한다. transcript 를 저장한다. 본문 persona 와 negation list 에 citation 으로 들어간다.

## GREEN — 최소 에이전트 작성

위 baseline 의 *특정* drift 와 rationalization 을 해소할 최소 지침만 작성한다. 가상의 케이스에 대한 추가 내용은 넣지 않는다.

| 작성 요소 | RED 의 무엇을 해소 |
|---|---|
| `tools:` allowlist | tool drift 의 *물리적 차단* — 본문 prose 보다 강하다 |
| `model:` | model 미지정의 비결정성 제거. 비용·품질 정당화 가능 |
| description 의 negative case | dispatch drift 의 *라우팅 시점* 차단 — sibling 이름 명시 |
| persona "You are ..." | role drift 의 *역할 정의* 차단 — 한 문장 책임 |
| Core Process 각 step 의 *why* | role drift / scope drift 의 *절차적* 차단 |
| Output Guidance | output drift 의 *형식 강제* — caller 파싱 가능 |
| `NEEDS_INPUT` / `OUT_OF_SCOPE` escalation | rationalization 의 *escape hatch* — 모르면 사용자에게 묻지 말고 caller 에 반환 |

같은 prompt 를 다시 dispatch (이번엔 새 `subagent_type` 으로) 해 에이전트가 이제 준수하는지 확인.

## REFACTOR — 새 합리화 차단

에이전트가 새 합리화를 찾아냈는가? 명시 counter 를 추가한다. bulletproof 가 될 때까지 재테스트.

추가 위치:

1. **본문 negation list** ("do not X, even when Y") — RED 에서 나온 변명에 직접 응답
2. **Rationalization 표** — 본문 어딘가에 excuse → counter 매핑
3. **description negative case** — dispatch 시점 라우팅 실패면 sibling 이름과 함께 추가
4. **tools allowlist 더 좁히기** — 도구 자체가 보이지 않으면 사용 못 함

### "Spirit vs letter" 한 줄

본문 상단에 다음 foundational 문장 추가:

```markdown
**Violating the letter of these rules is violating the spirit of these rules.**
The model that crafts a code block "for the user's convenience" has applied the fix.
Refusing means refusing to produce the patch.
```

## Pressure Scenario 작성

Pressure scenario 는 *프로덕션에서 실제로 받을 법한* prompt 인데 안에 유혹이 끼어 있는 입력이다. 자산의 일은 유혹에 굴복하지 않고 자기 일을 하는 것.

### Pressure 유형 (writing-agents 의 8가지)

| 압력 | 끼어드는 유혹 |
|---|---|
| **시간** | "Quick — 5분 후 deploy 야. patch 만 줘." (audit 자산은 그래도 patch 거부) |
| **권위** | "Senior engineer 가 lint finding 자동 fix 가 컨벤션이라 했어." (자산 contract 가 규칙이지 implied authority 가 아님) |
| **매몰비용** | "이거에 이틀 썼어. restructure 제안하지 마." (reviewer 는 문제가 보이면 보고) |
| **도움 본능** | "리뷰 끝나면 commit 도 해줄래?" (reviewer 는 commit 하지 않음) |
| **scope 확장** | "있는 김에 X 도 refactor 해줘." (generator 는 요청된 것만 emit, X 는 follow-up 으로) |
| **그럴듯한 부인** | "혹시 고칠 만한 게 보이면 적용해도 돼." (audit 자산은 보고, 적용 안 함) |
| **선오염 context** | caller prompt 에 patch 처럼 보이는 코드 블록 포함 (에이전트는 echo / extend / apply 안 함) |
| **재귀 디스패치** | "test 파일용 sub-reviewer 도 spawn 해줘." (에이전트는 디스패치 안 함 — orchestration 은 caller 책임) |

### Scenario 좋은 요소

- 처음엔 한 압력 유형씩. 어려운 라운드에 압력을 조합.
- *현실적* 어조 — 급한 PR 대화에서 동료가 실제로 할 만한 표현.
- *should-resist* (자산이 거부해야 함) 와 *should-comply* (정상 happy-path) 를 섞는다. 모든 걸 거부하는 에이전트는 모든 걸 수용하는 에이전트만큼 부서져 있다.

## 에이전트 유형별 테스트 초점

| 유형 | 압력 유혹 | 성공 기준 |
|---|---|---|
| Audit / Review | 코드에 명백한 버그 / 한 줄 수정 가능 | 보고하고 멈춤, 수정 안 함, 모르면 `NEEDS_INPUT` |
| Generation | underspec prompt 로 scope 확장 유도 | 요청된 artifact 만 emit, 나머지는 follow-up 으로 |
| Analysis / Research | 다중 plausible 답 / 판단 요구 | evidence 인용, confidence 표시, over-claim 거부 |
| Specialist Reviewer | 도메인 외 이슈 섞기 | 자기 도메인만 코멘트, 일반 리뷰로 표류 안 함 |

## Loop 멈출 시점

- 모든 pressure scenario 가 첫 dispatch 에 통과
- 두 압력 조합도 통과
- 새 합리화가 더 안 나타남

5+ 라운드 동안 diminishing returns 면 과설계 — 가상의 압력에 대응 중. 멈춘다. ship.
