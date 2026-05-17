# Trigger Evaluation (Description Optimization) — Agents

> 본 파일은 agent-creator 가 §Description optimization 에서 참조하는 trigger 정확도 측정 절차다.

## 목적

description 은 에이전트 dispatch 의 일차 신호다. orchestrator 가 `available_agents` 카탈로그에서 name + description 만 보고 *지금 이 에이전트를 dispatch 해야 할지* 결정한다. trigger 정확도 측정은 description 이 의도한 케이스에서 dispatch 되고 인접 sibling 케이스에서 dispatch 되지 않는지 확인한다.

스킬과 다른 점: **에이전트는 dispatch 후 별도 context 에서 실행되므로 잘못 라우팅되면 비용이 크다** (full context 로드 + tool 권한 충돌 + 산출 형식 mismatch). 스킬의 잘못된 트리거는 description 만 읽고 멈출 수도 있으나, 에이전트는 *전체 실행이 wasted* 된다. 따라서 trigger 정확도는 에이전트가 스킬보다 더 중요한 축이다.

## CSO 핵심 원칙 (에이전트 특화)

### 1. Description = When to Use, NOT What the Agent Does

description 은 *dispatch 조건* 만 담는다. 본문 절차를 요약하면 orchestrator 가 본문을 안 읽고 description 만 따라 단축 dispatch 한다 (Description-as-runbook 안티패턴).

```yaml
# ❌ BAD: workflow 요약 — orchestrator 가 description 만 따라 dispatch
description: Reviews PRs by reading diff, checking conventions, generating Korean comments, posting via gh

# ❌ BAD: Description-as-runbook
description: 1) Read diff 2) Classify severity 3) Write Korean comments 4) Post

# ✅ GOOD: trigger + negative case + sibling 이름
description: Use when the user wants Korean-only review comments on a PR's diff without auto-fixes. Do NOT use for full multi-agent PR reviews (use `pr-review-toolkit:review-pr`) or external model second opinions (use `codex-reviewer`).
```

### 2. Negative cases are non-negotiable for agents

스킬은 invocation slot 을 두고 경쟁하지만, **에이전트는 경쟁 *과* hand off** 한다. negative case 가 없으면 `agent-skill-auditor` 가 design 질문에 dispatch 되거나, `resource-design` 이 정적 audit 에 dispatch 된다. 가장 가까운 sibling 을 이름과 함께 명시한다.

### 3. Keyword Coverage (에이전트 특화)

orchestrator 가 검색할 만한 단어를 포함한다:
- **역할의 도메인** ("security", "accessibility", "type design")
- **artifact 이름** ("PR", "migration", "OpenAPI spec", "diff")
- **동의어와 다국어** ("review", "audit", "검토", "감사")
- **인접 sibling 이름** — orchestrator 가 키워드 매치로 잘못 선택하지 않도록 명시 부정

### 4. Descriptive Naming

verb-first kebab-case. `subagent_type: "<name>"` 으로 자연스럽게 읽혀야 한다.

```text
✅ code-reviewer, type-design-analyzer, silent-failure-hunter, pr-comment-reviewer
❌ reviewer1, helper, agent-for-prs, my-custom-thing
```

### 5. Third Person

description 은 system prompt 에 주입된다. 1인칭("I help with X") 사용 금지. 본 persona 의 "You are …" 와 description 의 시점은 다르다 — description 은 *외부 관찰자가 에이전트에 대해* 쓴 글이다.

## Trigger Eval 절차

description 이 인접 에이전트와 키워드 충돌이 의심되거나, sibling 4종 이상이 같은 도메인 (review / analyze / audit) 을 다룰 때 수행. 비용·시간이 들어가므로 사용자 동의 후에만.

### Step 1: should-trigger / should-not-trigger 쌍 작성

각 ≥10개. 사용자가 실제로 입력할 만한 *구체적이고 상황이 있는* 발화. 추상 명령이 아니라 구체적 파일명·동료 인용·작업 맥락 포함.

좋은 예 (should-trigger, PR review 에이전트 대상):

```text
"방금 GH PR #1234 올렸는데, 김씨가 한국어 코멘트 리뷰만 한 번 더 받고 싶다고 해.
auto fix 는 빼고 severity 만 표시해서 보고해줘. PR 코드는 services/auth 쪽 변경이야."
```

나쁜 예: `"Review this PR"` — 추상적이라 어떤 review 에이전트든 dispatch 가능.

should-not-trigger 의 가치는 *near-miss* — 키워드가 겹치지만 다른 에이전트가 적합한 케이스:

```text
"이 diff 전체를 multi-agent 로 한꺼번에 review 해줘. silent failure 도 보고 type design 도 봐줘."
→ pr-review-toolkit:review-pr 이 맞고 단일 한국어 코멘트 reviewer 는 아님
```

### Step 2: 측정

각 쿼리를 3회 dispatch 시도해 트리거 비율 계산. 60% train / 40% held-out test 분할 (overfitting 방지).

### Step 3: description 후보 생성·평가

train 점수 기반으로 description 후보를 만들고 train + test 점수로 채택. test 점수가 train 만큼 높은 후보만 선택. 후보 생성 시 자주 효과 있는 변형:

- sibling 이름을 negative case 에 더 명시적으로 추가
- 도메인 키워드 (artifact 이름·동의어) 보강
- "Use when …" / "Do NOT use for …" 두 절을 분리해 시각적 라우팅 표지 제공
- 본문 절차 요약 제거 (description bloat 축소)

### Step 4: 적용

best_description 으로 agent frontmatter 갱신. before/after 점수를 사용자에게 보고. 적용 후에는 정적 audit (`bobs-plugin:agent-skill-auditor`) 재실행 권장 — description 변화가 frontmatter 일관성에 영향이 갈 수 있음.

## 트리거 메커니즘 이해

orchestrator 는 `available_agents` 목록에서 name + description 을 보고 dispatch 여부를 결정한다. 단순 1-step 쿼리 ("read this file") 는 description 이 완벽하게 매치돼도 에이전트를 dispatch 안 할 수 있다 — orchestrator 가 직접 처리하기 때문.

따라서 trigger eval 쿼리는 *별도 context, 별도 도구, specialist 판단이 필요할 만큼* 복잡해야 한다. 단순 1-step 쿼리는 description 품질 무관하게 dispatch 되지 않으므로 나쁜 테스트 케이스.

## Description triggering 의 분리 검증

description 트리거는 본문 동작과 *별도로* 검증한다. 본문 persona·Output Guidance 가 완벽해도 description 이 잘못 dispatch 되면 무관한 호출이 쏟아진다. CSO + trigger eval 은 이 두 축을 분리해 측정한다:

| 축 | 검증 도구 | 통과 기준 |
|---|---|---|
| dispatch 정확도 | trigger eval (이 문서) | should-trigger ≥ 80%, should-not-trigger 거부 ≥ 80% |
| 행동 정확도 | RED-GREEN-REFACTOR (`red-green-refactor.md`) | pressure scenario 통과 |
| 형식 정확도 | static audit (`bobs-plugin:agent-skill-auditor`) | P0/P1 = 0 |

세 축은 서로 다른 실패 모드를 잡는다. 한 축만 통과시키고 ship 하면 다른 축에서 부서진다.
