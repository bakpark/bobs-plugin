# Skill GAP Report: claude-automation-recommender

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill |
| Skill name | `claude-automation-recommender` |
| Source path | `skills/claude-automation-recommender/SKILL.md` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` |
| Final decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 전반적으로 v1 준수. description 은 trigger 중심이며 read-only 성격을 명확히 함. reference 분리가 적절함.
- Highest severity: P2 (output contract 구체성 부족)
- Main gap: Output Format 의 구체성이 약하고, When NOT to Use 명시적이지 않음.
- Recommended next action: output contract 구체화 및 negative case 추가

---

## 3. Skill Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `claude-automation-recommender` |
| description | `"Analyze a codebase and recommend Claude Code automations..."` |
| description words | 42 |
| tools | `Read, Glob, Grep, Bash` |
| invocation controls | none |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | 1508 |
| body lines | 288 |
| main sections | Output Guidelines, Automation Types Overview, Workflow (Phase 1-3), Decision Framework, Configuration Tips |
| has When to Use | partial (description 에 포함) |
| has When NOT to Use | no |
| has workflow/checklist | yes (3 Phase 구조) |
| has output contract | partial (Phase 3 template 있으나 formal Output Format 섹션 아님) |
| has approval gate | not needed (read-only) |
| has references | yes (references/mcp-servers.md 등) |
| has scripts/assets | no |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.6 Progressive Disclosure Protects Context`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 본문 구조`
- `SKILL-GUIDE.md §7 Output Contract`

---

## 5. Skill-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description is trigger-only | pass | "Use when user asks for automation recommendations..." trigger 중심 |
| No workflow summary in description | pass | 절차 요약 없음 |
| Keyword coverage exists | pass | "automation", "hooks", "subagents", "skills", "plugins", "MCP" 포함 |
| Has negative case or near-miss | gap | 없음 |
| Workflow/checklist is actionable | pass | 3 Phase 구조 명확 |
| Output contract is clear | partial | Phase 3 에 template 있으나 formal 섹션 아님 |
| Approval gate for mutation | pass | read-only 명시 |
| Progressive disclosure is appropriate | pass | references/ 분리 적절 |
| Avoids project-specific leakage | pass | 프로젝트 중립적 |
| Test/trigger eval path is possible | n/a | |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §4` | When NOT to Use 명시적이지 않음 | negative case 추가 |
| GAP-002 | ASSET_GAP | P3 | `SKILL-GUIDE.md §7` | Output Format 이 Phase 3 내장됨. 별도 섹션 아님 | formal Output Format 섹션으로 분리 고려 |

### GAP-001: No Explicit When NOT to Use

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §4` |

**Expected**: 본문에 명시적 "When NOT to Use" 또는 near-miss 케이스.

**Actual**: description 에 trigger条件是 있으나, 언제 쓰지 말아야 하는지에 대한 명시적 설명 없음.

**Impact**: 이미 자동화가 잘 구축된 프로젝트에서 불필요하게 호출될 수 있음.

**Recommendation**: "When NOT to Use: Project already has comprehensive .claude/ setup with no gaps" 등 추가.

### GAP-002: Output Contract Embedded in Phase 3

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §7` |

**Expected**: 별도 Output Format 섹션으로 산출물 구조 명시.

**Actual**: Output template 이 Phase 3 "Output Recommendations Report" 내에 내장됨.

**Impact**: 경미. template 이 존재하므로 기능적 문제는 없음. 구조적 명확성만 낮음.

**Recommendation**: formal Output Format 섹션으로 분리 고려 (낮은 우선순위).

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| Decision Framework 섹션 | recommendation type 의 특성상 판단 기준이 핵심. v1 가이드에 명시된 구조는 아니지만 유용성 높음 |
| 큰 reference 표 포함 | progressive disclosure 로 references/ 에 분리되어 있음. 본문은 index 역할 |

---

## 8. Suggested Changes

### 8.1 Skill Changes

- [ ] When NOT to Use 또는 near-miss 케이스 추가 (P2)
- [ ] Output Format 을 별도 섹션으로 분리 고려 (P3)

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

근거: description 이 trigger 중심이며 read-only 성격 명확, reference 분리 적절. 경미한 구조적 개선안만 존재 (P2-P3).
