# Agent GAP Report: code-reviewer (pr-review-toolkit)

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `code-reviewer` |
| Source path | `agents/pr-review-toolkit/code-reviewer.md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 전반적으로 v1 준수. description 이 trigger 중심, confidence gate 명확, output contract 있음. tools 미지정이 유일한 P2 GAP.
- Highest severity: P2 (tools 미지정)
- Main gap: tools 미지정으로 권한 범위가 불명확; feature-dev/code-reviewer 와 중복
- Recommended next action: tools 명시, feature-dev 와의 책임 경계 명확화

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `code-reviewer` |
| description | `"Use this agent when you need to review code for adherence to project guidelines..."` |
| description words | ~120 (긴 trigger 산문형) |
| tools | omitted (default = *) |
| model | `opus` |
| color | `green` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | ~350 |
| body lines | ~65 |
| main sections | persona, When to invoke, Review Scope, Core Review Responsibilities, Issue Confidence Scoring, Output Format |
| starts with persona | yes |
| has When to invoke | yes (3 시나리오) |
| has scope boundary | yes ("unstaged changes from git diff") |
| has output contract | yes |
| has confidence gate | yes (>= 80) |
| has CLAUDE.md coupling | yes |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.3 Scope Is Quality Control`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §6 Tool 권한`
- `AGENT-GUIDE.md §9 Confidence Gate`

---

## 5. Agent-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description has invocation trigger | pass | "Use this agent when you need to review code..." |
| Description has near-miss or negative case | partial | 시나리오 포함 있으나 명시적 negative case 없음 |
| Description is not bloated | pass | ~120 words, 긴 trigger 산문형 범위 내 |
| Persona and mission are clear | pass | |
| Scope boundary is explicit | pass | "unstaged changes from git diff" |
| Tools are least-privilege | gap | 미지정 = default * |
| Model is explicit and appropriate | pass | opus — 정밀 리뷰에 적절 |
| Output contract is actionable | pass | severity grouping + no-finding case 포함 |
| Confidence gate exists when needed | pass | >= 80, 0-100 scale 명확 |
| Does not orchestrate other agents | pass | |
| CLAUDE.md relationship is clear | yes | |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `AGENT-GUIDE.md §6` | tools 미지정 = 전체 권한 노출 | read-only 도구 명시 |
| GAP-002 | AMBIGUITY | P2 | `CONSTITUTION.md §3.4` | feature-dev/code-reviewer 와 책임 경계 불명확 | 둘 중 하나로 통합 또는 역할 분리 |

### GAP-001: Tools Not Specified

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §6` |

**Expected**: 리뷰 에이전트는 read-only 도구 명시.

**Actual**: tools 미지정 = default *.

**Impact**: 리뷰 에이전트가 쓰기/실행 도구에 접근 가능. 다만 본문에 쓰기 금지 언급은 없음.

**Recommendation**: `tools: Read, Grep, Glob, LS` 명시.

### GAP-002: Duplicate with feature-dev/code-reviewer

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.4 결정 프레임워크` |

**Expected**: 각 에이전트가 고유한 책임 범위를 가져야 함.

**Actual**: feature-dev/code-reviewer 와 거의 동일한 내용 (동일한 persona, Review Scope, Core Review Responsibilities, Confidence Scoring). 차이점:
- model: sonnet vs opus
- color: red vs green
- pr-review-toolkit 버전이 "When to invoke" 섹션과 3 시나리오 포함
- pr-review-toolkit 버전의 description 이 더 trigger 중심

**Impact**: 두 에이전트가 동시에 카탈로그에 있으면 라우팅 충돌 가능.

**Recommendation**: pr-review-toolkit 버전을 canonical 로 유지 (더 v1 준수). feature-dev 버전을 제거하거나 역할 분리 (예: feature-dev/code-reviewer 를 "lightweight inline review" 용도로 재정의).

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| 긴 description (~120 words) | AGENT-GUIDE.md §3 "긴 trigger 산문형: 160 words 안팎" 범위 내 |
| When to invoke + 3 시나리오 | 좋은 패턴. v1 가이드가 권장하는 호출 조건 구체화 방식 |
| model: opus | 정밀 리뷰에는 opus 적절 (§7) |

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] `tools: Read, Grep, Glob, LS` 명시 (P2)
- [ ] feature-dev/code-reviewer 와의 중복 해결 — 둘 중 하나로 통합 또는 역할 분리 (P2)

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

- pr-review-toolkit/code-reviewer 와 feature-dev/code-reviewer 중 어떤 것을 canonical 로 할 것인가? 아니면 각각 다른 호출 맥락에서 쓰이는가?

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거: description trigger 중심, confidence gate 명확, output contract 좋음, When to invoke 시나리오 포함. tools 미지정 (P2) 과 feature-dev 중복 (P2) 만 존재.
