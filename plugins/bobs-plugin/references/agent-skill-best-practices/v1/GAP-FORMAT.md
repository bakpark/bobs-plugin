# GAP 리포트 포맷

생성: 2026-05-16
기준 문서:
- `CONSTITUTION.md`
- `SKILL-GUIDE.md`
- `AGENT-GUIDE.md`
- `HOOK-GUIDE.md`

목적:
- `skills/`, `agents/` 아래 참고 자산을 v1 기준 문서와 대조한다.
- 각 스킬/에이전트마다 GAP 리포트 하나를 작성한다.
- 문서가 틀린 것인지, 자산이 개선 대상인지, 의도적 예외인지 분리한다.

---

## 1. 파일 배치

GAP 리포트는 `v1/gaps/` 아래에 둔다.

권장 파일명:

```text
v1/gaps/skill-<skill-name>.GAP.md
v1/gaps/agent-<path-safe-agent-name>.GAP.md
```

예시:

```text
v1/gaps/skill-brainstorming.GAP.md
v1/gaps/skill-claude-md-improver.GAP.md
v1/gaps/agent-code-simplifier.GAP.md
v1/gaps/agent-feature-dev-code-reviewer.GAP.md
v1/gaps/agent-pr-review-toolkit-comment-analyzer.GAP.md
```

경로에 `/` 가 있는 에이전트는 `-` 로 치환한다.

---

## 2. 판정 원칙

GAP 은 "가이드와 다름" 자체가 아니라, 다음 중 하나에 해당할 때 기록한다.

- 자산이 가이드의 핵심 원칙을 위반한다.
- 자산이 가이드의 기대 역할을 불명확하게 만든다.
- 자산의 description, scope, output, tool/model 설정이 라우팅 실패를 만들 수 있다.
- 자산에는 좋은 패턴이 있는데 가이드에 반영되어 있지 않다.
- 가이드가 너무 엄격해서 실제 우수 사례를 부당하게 위반으로 만든다.

기록하지 않아도 되는 것:
- 단순한 문체 차이
- 의도적이고 설명 가능한 예외
- 현재 가이드가 권장만 하는 항목의 경미한 미준수
- 표본 특성상 생긴 outlier 이지만 실제 위험이 낮은 경우

---

## 3. GAP 유형

| 유형 | 의미 |
|---|---|
| `ASSET_GAP` | 실제 스킬/에이전트가 v1 가이드 기준에 미달 |
| `GUIDE_GAP` | 실제 자산의 좋은 패턴이 v1 가이드에 없음 |
| `AMBIGUITY` | 가이드 또는 자산의 의도가 불명확 |
| `INTENTIONAL_EXCEPTION` | 가이드와 다르지만 정당화 가능한 예외 |
| `NO_GAP` | 점검 결과 기록할 GAP 없음 |

---

## 4. Severity

| Severity | 의미 | 예시 |
|---|---|---|
| `P0` | 즉시 수정 필요. 잘못된 호출, 위험한 부수 효과, 보안 위험 | 자동 호출 가능한 deploy 스킬, 리뷰 에이전트에 무제한 write 권한 |
| `P1` | 라우팅 또는 산출 품질에 직접 영향 | description 이 workflow runbook, output contract 없음 |
| `P2` | 개선 권장. 누적되면 품질 저하 | negative case 없음, scope 가 약함, examples 과다 |
| `P3` | 낮은 우선순위. 문서 정리 또는 명확화 | naming 약간 불명확, 섹션명 불일치 |

Severity 는 영향 기준이다. 단순 규칙 위반 수가 아니라 사용자 경험, 안전성, 라우팅 정확도, 유지보수성으로 판단한다.

---

## 5. Guide Reference 표기

각 GAP 은 기준 문서 위치를 참조한다.

표기 예:

```text
CONSTITUTION.md §2.1 Description Is The Router
SKILL-GUIDE.md §3 Description 작성
AGENT-GUIDE.md §6 Tool 권한
HOOK-GUIDE.md §7 보안 원칙
```

가이드 자체의 보완점이면 `Guide target` 을 적는다.

```text
Guide target: AGENT-GUIDE.md §3 Description 전략
```

---

## 6. 개별 리포트 구조

각 GAP 리포트는 다음 순서로 작성한다.

1. Metadata
2. Executive Summary
3. Asset Snapshot
4. Applicable v1 Criteria
5. Findings
6. Acceptable Deviations
7. Suggested Changes
8. Final Decision

실제 작성 템플릿은 자산 유형별로 나눠 사용한다.

```text
v1/gaps/_SKILL_TEMPLATE.md
v1/gaps/_AGENT_TEMPLATE.md
```

`v1/gaps/_TEMPLATE.md` 는 공통 구조 참고용으로만 둔다.

---

## 7. Asset Snapshot 필드

스킬:

```text
type: skill
source_path: skills/<name>/SKILL.md
name:
description_words:
body_words:
body_lines:
tools:
has_references:
has_scripts:
```

에이전트:

```text
type: agent
source_path: agents/<path>.md
name:
description_words:
body_words:
body_lines:
tools:
model:
color:
has_output_contract:
has_confidence_gate:
```

수치는 필수는 아니지만, 라우팅/길이/권한 관련 GAP 이 있으면 기록한다.

---

## 8. 유형별 점검 축

### 8.1 Skill GAP 축

스킬은 "방법론과 workflow 를 잘 패키징했는가" 를 본다.

핵심 점검 축:
- description 이 trigger 조건인지, workflow 요약인지
- skill body 가 실제 절차와 판단 기준을 담는지
- When to Use / When NOT to Use 가 있는지
- progressive disclosure 가 적절한지
- references/scripts/assets 사용이 적절한지
- 부수 효과가 있다면 approval/invocation gate 가 있는지
- 테스트 또는 trigger eval 이 가능한 구조인지
- project-specific 정보가 섞였는지

주요 기준 문서:
- `CONSTITUTION.md`
- `SKILL-GUIDE.md`

### 8.2 Agent GAP 축

에이전트는 "특정 specialist role 을 격리된 컨텍스트에서 안정적으로 수행하는가" 를 본다.

핵심 점검 축:
- description 이 호출 조건과 near-miss 를 담는지
- persona / mission / scope 가 명확한지
- tool 권한이 역할에 맞게 제한되었는지
- model 선택이 적절하고 명시되었는지
- output contract 가 호출자에게 유용한지
- 리뷰/분석 계열이면 confidence gate 가 있는지
- 다른 에이전트나 스킬의 책임을 침범하지 않는지
- CLAUDE.md 와 project convention 의 관계가 명확한지

주요 기준 문서:
- `CONSTITUTION.md`
- `AGENT-GUIDE.md`

---

## 9. Findings 작성 규칙

각 finding 은 하나의 문제만 다룬다.

필수 필드:
- `id`: `GAP-001`
- `type`: `ASSET_GAP` / `GUIDE_GAP` / `AMBIGUITY` / `INTENTIONAL_EXCEPTION`
- `severity`: `P0`-`P3`
- `guide_ref`
- `expected`
- `actual`
- `evidence`
- `impact`
- `recommendation`

Evidence 는 짧게 쓴다. 긴 원문 복사는 피하고, 필요한 줄 또는 phrase 만 인용한다.

---

## 10. Final Decision

리포트 마지막에 하나를 선택한다.

| 결정 | 의미 |
|---|---|
| `PASS` | 의미 있는 GAP 없음 |
| `PASS_WITH_NOTES` | 경미한 예외만 있음 |
| `REVISE_ASSET` | 스킬/에이전트 수정 권장 |
| `REVISE_GUIDE` | v1 가이드 수정 권장 |
| `SPLIT_ASSET` | 책임 분리 필요 |
| `DEPRECATE_ASSET` | 호출 경로 또는 가치가 낮아 제거 후보 |
| `NEEDS_REVIEW` | 추가 판단 필요 |

---

## 11. 작성 톤

- findings first 로 작성한다.
- 추측보다 증거를 우선한다.
- 가이드와 다르다는 이유만으로 과잉 보고하지 않는다.
- 좋은 예외는 `Acceptable Deviations` 로 남긴다.
- 자산을 고칠지, 가이드를 고칠지 구분한다.
