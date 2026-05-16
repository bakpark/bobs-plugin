# Skill GAP Report: claude-md-improver

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill |
| Skill name | `claude-md-improver` |
| Source path | `skills/claude-md-improver/SKILL.md` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` |
| Final decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: v1 준수 수준. description 이 trigger 중심, mutation gate 존재, reference 분리 적절.
- Highest severity: P2 (When NOT to Use 없음)
- Main gap: negative case 부재, output contract 가 Phase 3 에 내장됨
- Recommended next action: When NOT to Use 추가

---

## 3. Skill Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `claude-md-improver` |
| description | `"Audit and improve CLAUDE.md files in repositories..."` |
| description words | 42 |
| tools | `Read, Glob, Grep, Bash, Edit` |
| invocation controls | none |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | 869 |
| body lines | 179 |
| main sections | Workflow (Phase 1-5), Templates, Common Issues to Flag, User Tips, What Makes a Great CLAUDE.md |
| has When to Use | partial (description) |
| has When NOT to Use | no |
| has workflow/checklist | yes (5 Phase) |
| has output contract | partial (Phase 3 report template) |
| has approval gate | yes ("ask user for confirmation before updating") |
| has references | yes (references/quality-criteria.md, references/templates.md) |
| has scripts/assets | no |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.8 Mutation Requires A Gate`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 본문 구조`
- `SKILL-GUIDE.md §7 Output Contract`

---

## 5. Skill-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description is trigger-only | partial | "Scans for all CLAUDE.md files, evaluates quality..." — 절차 요약 약간 포함 |
| No workflow summary in description | gap | "outputs quality report, then makes targeted updates" 는 절차 요약 |
| Keyword coverage exists | pass | "CLAUDE.md", "audit", "improve", "maintenance" |
| Has negative case or near-miss | gap | 없음 |
| Workflow/checklist is actionable | pass | 5 Phase 구조 명확 |
| Output contract is clear | partial | Phase 3 report template 있으나 formal 섹션 아님 |
| Approval gate for mutation | pass | "ALWAYS output the quality report BEFORE making any updates" + user confirmation |
| Progressive disclosure is appropriate | pass | references/ 분리 |
| Avoids project-specific leakage | pass | 프로젝트 중립적 |
| Test/trigger eval path is possible | n/a | |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §4` | When NOT to Use 없음 | negative case 추가 |
| GAP-002 | ASSET_GAP | P3 | `SKILL-GUIDE.md §3` | description 에 절차 요약 약간 포함 ("outputs quality report, then makes targeted updates") | trigger-only 로 다듬기 |

### GAP-001: No When NOT to Use

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §4` |

**Expected**: 언제 쓰지 말아야 하는지 명시.

**Actual**: 없음.

**Impact**: CLAUDE.md 가 없는 프로젝트에서 불필요하게 호출될 수 있음.

**Recommendation**: "When NOT to Use: General code review (use code-reviewer agent), initial CLAUDE.md creation from scratch" 추가.

### GAP-002: Description Has Slight Workflow Summary

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §3` |

**Expected**: description 에 절차 요약 없음.

**Actual**: "Scans for all CLAUDE.md files, evaluates quality against templates, outputs quality report, then makes targeted updates." — 4단계 절차 요약 포함.

**Impact**: 경미. 핵심 trigger 는 명확하나 모델이 description 만 따라 단축 실행할 가능성 낮음 (본문이 필수적임).

**Recommendation**: `"Use when user asks to check, audit, update, improve, or fix CLAUDE.md files. Also triggers on 'CLAUDE.md maintenance' or 'project memory optimization'."` 형태로 다듬기.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `tools: Edit` 명시 | 쓰기 권한을 가진 스킬이므로 적절 (§6 Tool 권한). approval gate 도 존재 |
| Quality Score grading (A-F) | recommendation skill 의 특성상 유용한 판단 기준 |

---

## 8. Suggested Changes

### 8.1 Skill Changes

- [ ] When NOT to Use 추가 (P2)
- [ ] description 에서 절차 요약 부분 제거 (P3)

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

근거: mutation gate 적절, reference 분리 우수, workflow 명확. description 에 절차 요약 약간 포함 (P3), negative case 부재 (P2).
