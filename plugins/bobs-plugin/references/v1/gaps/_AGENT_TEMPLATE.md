# Agent GAP Report: [agent-name]

작성일: YYYY-MM-DD
기준 버전: v1
검토자: [name/model]

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `[name]` |
| Source path | `agents/[path].md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | PASS / PASS_WITH_NOTES / REVISE_ASSET / REVISE_GUIDE / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW |

---

## 2. Executive Summary

- Overall fit:
- Highest severity:
- Main gap:
- Recommended next action:

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `[value]` |
| description | `[short summary or exact if brief]` |
| description words | `[n]` |
| tools | `[value / omitted]` |
| model | `[value / omitted]` |
| color | `[value / omitted]` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | `[n]` |
| body lines | `[n]` |
| main sections | `[list]` |
| starts with persona | yes / no / partial |
| has When to invoke | yes / no / partial |
| has scope boundary | yes / no / partial |
| has output contract | yes / no / partial |
| has confidence gate | yes / no / not applicable |
| has CLAUDE.md coupling | yes / no / not applicable |

---

## 4. Applicable v1 Criteria

### Constitution

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.2 Skills Package Methods; Agents Package Roles`
- `CONSTITUTION.md §2.3 Scope Is Quality Control`
- `CONSTITUTION.md §2.4 Output Is A Contract`

### Agent Guide

- `AGENT-GUIDE.md §2 Frontmatter`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §4 본문 구조`
- `AGENT-GUIDE.md §5 Scope 설계`
- `AGENT-GUIDE.md §6 Tool 권한`
- `AGENT-GUIDE.md §7 Model 선택`
- `AGENT-GUIDE.md §8 Output Contract`
- `AGENT-GUIDE.md §9 Confidence Gate`

검토 대상에 실제로 적용한 기준만 남기고 나머지는 삭제한다.

---

## 5. Agent-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description has invocation trigger | pass / gap / n/a | |
| Description has near-miss or negative case | pass / gap / n/a | |
| Description is not bloated | pass / gap / n/a | |
| Persona and mission are clear | pass / gap / n/a | |
| Scope boundary is explicit | pass / gap / n/a | |
| Tools are least-privilege | pass / gap / n/a | |
| Model is explicit and appropriate | pass / gap / n/a | |
| Output contract is actionable | pass / gap / n/a | |
| Confidence gate exists when needed | pass / gap / n/a | |
| Does not orchestrate other agents | pass / gap / n/a | |
| CLAUDE.md relationship is clear | pass / gap / n/a | |

---

## 6. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `AGENT-GUIDE.md §5` | ... | ... |

### GAP-001: [short title]

| Field | Value |
|---|---|
| Type | ASSET_GAP / GUIDE_GAP / AMBIGUITY / INTENTIONAL_EXCEPTION |
| Severity | P0 / P1 / P2 / P3 |
| Guide ref | `AGENT-GUIDE.md §...` |

**Expected**

v1 기준의 기대 상태.

**Actual**

현재 에이전트의 상태.

**Evidence**

```text
[short excerpt or section list]
```

**Impact**

라우팅, scope, tool safety, output 품질, false positive, 유지보수성 중 어떤 영향인지 설명한다.

**Recommendation**

에이전트 수정인지, 가이드 수정인지 분명히 쓴다.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| ... | ... |

없으면 `None`.

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] ...

### 8.2 Guide Changes

- [ ] ...

---

## 9. Follow-up Questions

- ...

없으면 `None`.

---

## 10. Final Decision

```text
PASS / PASS_WITH_NOTES / REVISE_ASSET / REVISE_GUIDE / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW
```

근거:

- ...

