# Skill GAP Report: doc-coauthoring

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill |
| Skill name | `doc-coauthoring` |
| Source path | `skills/doc-coauthoring/SKILL.md` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` |
| Final decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: v1 준수 수준. description 이 trigger 중심, workflow 가 단계별로 명확함.
- Highest severity: P2 (body lines 과다, When NOT to Use 부재)
- Main gap: 375 lines 로 빈번 호출 스킬에 비해 장황, negative case 없음
- Recommended next action: 본문 압축 및 negative case 추가

---

## 3. Skill Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `doc-coauthoring` |
| description | `"Guide users through a structured workflow for co-authoring documentation..."` |
| description words | 47 |
| tools | omitted |
| invocation controls | none |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | 2466 |
| body lines | 375 |
| main sections | When to Offer, Stage 1-3, Final Review, Tips for Effective Guidance |
| has When to Use | yes ("When to Offer This Workflow") |
| has When NOT to Use | no |
| has workflow/checklist | yes (3 Stage) |
| has output contract | partial (산출물 구조 명시적이지 않음) |
| has approval gate | not needed (문서 생성) |
| has references | no |
| has scripts/assets | no |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.6 Progressive Disclosure Protects Context`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 본문 구조`
- `SKILL-GUIDE.md §6 Progressive Disclosure`
- `SKILL-GUIDE.md §9 정량 기준`

---

## 5. Skill-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description is trigger-only | pass | "Trigger when user mentions writing docs..." trigger 중심 |
| No workflow summary in description | pass | 절차 요약 없음 |
| Keyword coverage exists | pass | "documentation", "proposals", "technical specs", "decision docs" |
| Has negative case or near-miss | gap | 없음 |
| Workflow/checklist is actionable | pass | 3 Stage 구조 상세하고 명확 |
| Output contract is clear | partial | 산출물 구조 명시적이지 않음 |
| Approval gate for mutation | not needed | |
| Progressive disclosure is appropriate | gap | 375 lines, 빈번 호출 스킬에 대해 과다 |
| Avoids project-specific leakage | pass | 프로젝트 중립적 |
| Test/trigger eval path is possible | n/a | |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §9` | body lines 375로 빈번 호출 스킬에 과다 | 압축 또는 reference 분리 |
| GAP-002 | ASSET_GAP | P2 | `SKILL-GUIDE.md §4` | When NOT to Use 없음 | negative case 추가 |

### GAP-001: Body Too Long for Frequent Skill

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §9`, `CONSTITUTION.md §2.6` |

**Expected**: 빈번 호출 스킬은 150-200 words 목표, 일반 스킬도 가능하면 500 lines 이하.

**Actual**: 375 lines, 2466 words. Stage 2 가 특히 상세함 (각 section 마다 6 step).

**Impact**: 컨텍스트 예산 소모. 매 호출마다 큰 본문을 읽어야 함.

**Recommendation**: Stage 2 의 반복적 패턴을 references/stage-2-template.md 로 분리. 본문은 index+핵심 원칙만 남김.

### GAP-002: No When NOT to Use

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §4` |

**Expected**: 언제 쓰지 말아야 하는지 명시.

**Actual**: 없음. "When to Offer" 에 trigger 조건은 있으나 negative case 없음.

**Impact**: 간단한 메모나 1-2문장 답변에 대해 이 workflow 가 과도하게 호출될 수 있음.

**Recommendation**: "When NOT to Use: Brief notes, single-paragraph responses, quick email drafts" 추가.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| 상세한 Stage-by-Stage 절차 | 협업형 스킬의 특성상 상세 지침이 필요함 (§4 변형 참고). 다만 압축 여지는 있음 |
| sub-agent 분기 (Reader Testing) | 환경별 대체 경로 제공은 좋은 패턴. v1 가이드에 명시되지 않았으나 유용 |

---

## 8. Suggested Changes

### 8.1 Skill Changes

- [ ] Stage 2 반복 템플릿을 references/ 로 분리하여 본문 압축 (P2)
- [ ] When NOT to Use 추가 (P2)

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

근거: description 이 trigger 중심, workflow 구조 우수. 본문이 과장 (P2), negative case 부재 (P2).
