# Skill GAP Report: skill-creator

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill |
| Skill name | `skill-creator` |
| Source path | `skills/skill-creator/SKILL.md` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` |
| Final decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 메타 스킬로서 v1 준수. description 은 trigger 중심, eval/iteration 구조가 명확함.
- Highest severity: P2 (body lines 과다)
- Main gap: 485 lines / 5205 words 로 길이나 메타 스킬 특성과 eval 구조로 정당화 가능
- Recommended next action: references 분리로 압축 고려

---

## 3. Skill Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `skill-creator` |
| description | `"Create new skills, modify and improve existing skills, and measure skill performance..."` |
| description words | 35 |
| tools | omitted |
| invocation controls | none |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | 5205 |
| body lines | 485 |
| main sections | Communicating with the user, Creating a skill, Running and evaluating test cases, Improving the skill, Advanced, Description Optimization, Claude.ai-specific, Cowork-Specific, Reference files |
| has When to Use | partial (description) |
| has When NOT to Use | no |
| has workflow/checklist | yes (상세 eval loop) |
| has output contract | partial (.skill file packaging) |
| has approval gate | not needed |
| has references | yes (references/schemas.md, agents/grader.md 등) |
| has scripts/assets | yes (scripts/, eval-viewer/) |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.6 Progressive Disclosure Protects Context`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §6 Progressive Disclosure`
- `SKILL-GUIDE.md §9 정량 기준`

---

## 5. Skill-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description is trigger-only | pass | "Use when users want to create a skill from scratch..." trigger 중심 |
| No workflow summary in description | pass | 절차 요약 없음 |
| Keyword coverage exists | pass | "create", "modify", "optimize", "evals", "benchmark" |
| Has negative case or near-miss | gap | 없음 |
| Workflow/checklist is actionable | pass | eval loop 상세하고 명확 |
| Output contract is clear | partial | .skill file packaging 명시 |
| Approval gate for mutation | not needed | |
| Progressive disclosure is appropriate | gap | 485 lines 과다. 메타 스킬로 정당화 가능하나 분리 여지 있음 |
| Avoids project-specific leakage | pass | 프로젝트 중립적 |
| Test/trigger eval path is possible | pass | 자체적으로 trigger eval 구조 포함 (모범 사례) |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §9` | 485 lines / 5205 words | 메타 스킬로 정당화 가능하나 reference 분리 고려 |
| GAP-002 | ASSET_GAP | P3 | `SKILL-GUIDE.md §4` | When NOT to Use 없음 | 추가 고려 |

### GAP-001: Body Long But Justifiable for Meta-Skill

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §9` |

**Expected**: 메타 스킬은 3000+ words 가능하나 eval/iteration/reference 구조가 있을 때만 정당화.

**Actual**: 5205 words, 485 lines. eval loop, description optimization, 환경별 변형(Claude.ai/Cowork) 포함. references/scripts 분리 존재.

**Impact**: 컨텍스트 예산 소모가 크나 메타 스킬 특성상 빈번하지 않게 호출됨.

**Recommendation**: 환경별 지침(Claude.ai-specific, Cowork-Specific)을 references/ 로 분리하면 본문 약 150 lines 절약 가능. 낮음 우선순위.

### GAP-002: No When NOT to Use

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §4` |

**Expected**: 언제 쓰지 말아야 하는지 명시.

**Actual**: 없음.

**Impact**: 경미. 메타 스킬 특성상 near-miss 가능성이 낮음.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| body lines 과다 (485) | 메타 스킬이고 eval/iteration/reference 구조가 명확 (§9 "메타 스킬 3000+ words 가능") |
| 환경별 분기 지침 | Claude.ai / Cowork / Claude Code 환경에서 동작 차이를 명확히 함. 좋은 패턴 |
| 대화체 톤 ("Cool? Cool.") | 메타 스킬의 성격에 적합. v1 가이드의 "객관적이고 지시적" 권장과 다르지만 기능적 영향 없음 |

---

## 8. Suggested Changes

### 8.1 Skill Changes

- [ ] 환경별 지침을 references/ 로 분리하여 본문 압축 고려 (P2, 낮음 우선순위)
- [ ] When NOT to Use 추가 고려 (P3)

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

None.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거: description trigger 중심, eval/iteration 구조 우수, reference 분리 적절. body lines 과다이나 메타 스킬로 정당화 가능 (P2). trigger eval 구조 포함은 모범 사례 (§8 Testing And Iteration).
