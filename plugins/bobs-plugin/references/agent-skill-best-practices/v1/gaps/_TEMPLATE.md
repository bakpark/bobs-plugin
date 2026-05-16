# GAP Report: [asset-name]

작성일: YYYY-MM-DD
기준 버전: v1
검토자: [name/model]

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill / agent |
| Asset name | `[name]` |
| Source path | `[skills/.../SKILL.md or agents/...md]` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` or `AGENT-GUIDE.md` |
| Final decision | PASS / PASS_WITH_NOTES / REVISE_ASSET / REVISE_GUIDE / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW |

---

## 2. Executive Summary

한두 문단으로 결론을 먼저 쓴다.

- Overall fit:
- Highest severity:
- Main issue:
- Recommended next action:

---

## 3. Asset Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `[value]` |
| description | `[short summary or exact if brief]` |
| description words | `[n]` |
| tools | `[value / omitted]` |
| model | `[agent only]` |
| color | `[agent only]` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | `[n]` |
| body lines | `[n]` |
| main sections | `[list]` |
| has output contract | yes / no / partial |
| has negative case | yes / no / partial |
| has scope boundary | yes / no / partial |
| has references/scripts | yes / no |

---

## 4. Applicable v1 Criteria

이 자산에 적용한 기준만 적는다.

### Constitution

- `CONSTITUTION.md §...`

### Skill Guide

스킬인 경우만 작성.

- `SKILL-GUIDE.md §...`

### Agent Guide

에이전트인 경우만 작성.

- `AGENT-GUIDE.md §...`

---

## 5. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `...` | ... | ... |

### GAP-001: [short title]

| Field | Value |
|---|---|
| Type | ASSET_GAP / GUIDE_GAP / AMBIGUITY / INTENTIONAL_EXCEPTION |
| Severity | P0 / P1 / P2 / P3 |
| Guide ref | `CONSTITUTION.md §...` |

**Expected**

v1 기준으로 기대되는 상태를 쓴다.

**Actual**

현재 자산의 상태를 쓴다.

**Evidence**

짧은 인용 또는 구조적 증거를 쓴다.

```text
[short excerpt or section list]
```

**Impact**

이 차이가 왜 중요한지 쓴다. 라우팅, 안전, output 품질, 유지보수성 중 어디에 영향이 있는지 명시한다.

**Recommendation**

구체적인 수정 방향을 쓴다. 자산 수정인지 가이드 수정인지 분명히 한다.

---

## 6. Acceptable Deviations

가이드와 다르지만 정당화 가능한 부분을 적는다. 없으면 `None`.

| Deviation | Why acceptable |
|---|---|
| ... | ... |

---

## 7. Suggested Changes

### 7.1 Asset Changes

자산을 수정해야 한다면 작성한다.

- [ ] ...

### 7.2 Guide Changes

v1 가이드가 보완되어야 한다면 작성한다.

- [ ] ...

---

## 8. Follow-up Questions

추가 판단이 필요한 질문을 적는다. 없으면 `None`.

- ...

---

## 9. Final Decision

선택:

```text
PASS / PASS_WITH_NOTES / REVISE_ASSET / REVISE_GUIDE / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW
```

근거:

- ...

