# Skill GAP Report: [skill-name]

작성일: YYYY-MM-DD
기준 버전: v1
검토자: [name/model]

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill |
| Skill name | `[name]` |
| Source path | `skills/[name]/SKILL.md` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` |
| Final decision | PASS / PASS_WITH_NOTES / REVISE_ASSET / REVISE_GUIDE / SPLIT_ASSET / DEPRECATE_ASSET / NEEDS_REVIEW |

---

## 2. Executive Summary

- Overall fit:
- Highest severity:
- Main gap:
- Recommended next action:

---

## 3. Skill Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `[value]` |
| description | `[short summary or exact if brief]` |
| description words | `[n]` |
| tools | `[value / omitted]` |
| invocation controls | `disable-model-invocation / user-invocable / allowed-tools / none` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | `[n]` |
| body lines | `[n]` |
| main sections | `[list]` |
| has When to Use | yes / no / partial |
| has When NOT to Use | yes / no / partial |
| has workflow/checklist | yes / no / partial |
| has output contract | yes / no / partial |
| has approval gate | yes / no / not needed |
| has references | yes / no |
| has scripts/assets | yes / no |

---

## 4. Applicable v1 Criteria

### Constitution

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.2 Skills Package Methods; Agents Package Roles`
- `CONSTITUTION.md §2.6 Progressive Disclosure Protects Context`
- `CONSTITUTION.md §2.7 Test Behavior, Not Aesthetics`

### Skill Guide

- `SKILL-GUIDE.md §2 Frontmatter`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 본문 구조`
- `SKILL-GUIDE.md §6 Progressive Disclosure`
- `SKILL-GUIDE.md §8 Testing And Iteration`

검토 대상에 실제로 적용한 기준만 남기고 나머지는 삭제한다.

---

## 5. Skill-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description is trigger-only | pass / gap / n/a | |
| No workflow summary in description | pass / gap / n/a | |
| Keyword coverage exists | pass / gap / n/a | |
| Has negative case or near-miss | pass / gap / n/a | |
| Workflow/checklist is actionable | pass / gap / n/a | |
| Output contract is clear | pass / gap / n/a | |
| Approval gate for mutation | pass / gap / n/a | |
| Progressive disclosure is appropriate | pass / gap / n/a | |
| Avoids project-specific leakage | pass / gap / n/a | |
| Test/trigger eval path is possible | pass / gap / n/a | |

---

## 6. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `SKILL-GUIDE.md §3` | ... | ... |

### GAP-001: [short title]

| Field | Value |
|---|---|
| Type | ASSET_GAP / GUIDE_GAP / AMBIGUITY / INTENTIONAL_EXCEPTION |
| Severity | P0 / P1 / P2 / P3 |
| Guide ref | `SKILL-GUIDE.md §...` |

**Expected**

v1 기준의 기대 상태.

**Actual**

현재 스킬의 상태.

**Evidence**

```text
[short excerpt or section list]
```

**Impact**

라우팅, workflow 준수, 안전, 출력 품질, 유지보수성 중 어떤 영향인지 설명한다.

**Recommendation**

스킬 수정인지, 가이드 수정인지 분명히 쓴다.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| ... | ... |

없으면 `None`.

---

## 8. Suggested Changes

### 8.1 Skill Changes

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

