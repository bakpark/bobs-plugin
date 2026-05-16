# Trigger Evaluation (Description Optimization)

> 출처: `bobs-plugin:writing-skills` (vendored from `claude-plugins-official/superpowers`, MIT). 본 파일은 skill-creator 가 §Description optimization 에서 참조하는 trigger 정확도 측정 절차를 self-contained 형태로 가져온 것이다. 원문은 `${CLAUDE_PLUGIN_ROOT}/../writing-skills/SKILL.md` §"Claude Search Optimization (CSO)".

## 목적

description 은 스킬 발견의 일차 신호다. 호출자가 catalog 에서 스킬을 보고 *지금 읽어야 할지* 결정한다. trigger 정확도 측정은 description 이 의도한 케이스에서 트리거되고 다른 케이스에서 트리거되지 않는지 확인한다.

## CSO 핵심 원칙

### 1. Description = When to Use, NOT What the Skill Does

description 은 *트리거 조건* 만 담는다. 본문 절차를 요약하면 호출자가 본문을 안 읽고 description 만 따라 단축 실행한다 (Description-as-runbook 안티패턴).

```yaml
# ❌ BAD: workflow 요약 — Claude 가 description 만 따라 실행
description: Use for skill creation - gather requirements, write SKILL.md, run evals, improve description, package the skill

# ✅ GOOD: 트리거 조건만
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
```

### 2. Keyword Coverage

Claude 가 검색할 만한 단어를 포함한다:
- 에러 메시지, 증상, 동의어, 도구·라이브러리·파일 타입

### 3. Descriptive Naming

active voice, verb-first kebab-case. `creating-skills` 가 `skill-creation` 보다 낫다.

### 4. Third Person

description 은 system prompt 에 주입된다. 1인칭("I help with X") 사용 금지.

## Trigger Eval 절차

description 이 인접 스킬과 키워드 충돌이 의심되거나, 호출자가 사용자 발화 어휘와 거리가 멀 가능성이 있을 때 수행. 비용·시간이 들어가므로 사용자 동의 후에만.

### Step 1: should-trigger / should-not-trigger 쌍 작성

각 ≥10개. 사용자가 실제로 입력할 만한 *구체적이고 상황이 있는* 발화. 추상 명령이 아니라 구체적 파일명·동료 인용·작업 맥락 포함.

좋은 예 (should-trigger):
```
"boss 가 보낸 xlsx 가 downloads 에 있어 ('Q4 sales final FINAL v2.xlsx' 같은 거).
profit margin 비율 컬럼 추가해야 해 — 매출은 C 컬럼, 비용은 D 컬럼인 듯."
```

나쁜 예: `"Format this data"` — 추상적이라 어떤 스킬이든 트리거 가능.

should-not-trigger 의 가치는 *near-miss* — 키워드가 겹치지만 다른 스킬이 적합한 케이스.

### Step 2: 측정

각 쿼리를 3회 dispatch 해 트리거 비율 계산. 60% train / 40% held-out test 분할 (overfitting 방지).

### Step 3: description 후보 생성·평가

train 점수 기반으로 description 후보를 만들고 train + test 점수로 채택. test 점수가 train 만큼 높은 후보만 선택.

### Step 4: 적용

best_description 으로 skill frontmatter 갱신. before/after 점수를 사용자에게 보고.

## 트리거 메커니즘 이해

Claude 는 `available_skills` 목록에서 name + description 을 보고 스킬 호출 여부를 결정한다. 단순 1-step 쿼리 ("read this PDF") 는 description 이 완벽하게 매치돼도 스킬을 트리거 안 할 수 있다 — Claude 가 기본 도구로 직접 처리하기 때문.

따라서 trigger eval 쿼리는 *Claude 가 스킬 참조로 이득을 볼 만큼* 복잡해야 한다. 단순 1-step 쿼리는 description 품질 무관하게 트리거되지 않으므로 나쁜 테스트 케이스.

## Description triggering 의 분리 검증

description 트리거는 본문 동작과 *별도로* 검증한다. 본문이 완벽해도 description 이 잘못 트리거하면 무관한 호출이 쏟아진다. CSO + trigger eval 은 이 두 축을 분리해 측정한다.
