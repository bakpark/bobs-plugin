# Agent GAP Report: code-explorer

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `code-explorer` |
| Source path | `agents/feature-dev/code-explorer.md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 부분적 준수. output guidance 는 우수하나 tools 가 과하고 description 이 trigger 중심이 아님.
- Highest severity: P1 (tools 과다)
- Main gap: BashOutput/KillShell/WebSearch 불필요; description 이 역할 설명임
- Recommended next action: tools 축소, description trigger 형식으로 변경

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `code-explorer` |
| description | `"Deeply analyzes existing codebase features by tracing execution paths..."` |
| description words | 22 |
| tools | `Glob, Grep, LS, Read, NotebookRead, WebFetch, TodoWrite, WebSearch, KillShell, BashOutput` |
| model | `sonnet` |
| color | `yellow` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | ~200 |
| body lines | ~45 |
| main sections | persona, Core Mission, Analysis Approach (1-4), Output Guidance |
| starts with persona | yes |
| has When to invoke | no |
| has scope boundary | partial |
| has output contract | yes |
| has confidence gate | not applicable |
| has CLAUDE.md coupling | no |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.3 Scope Is Quality Control`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §6 Tool 권한`

---

## 5. Agent-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description has invocation trigger | gap | "Deeply analyzes..." 역할 설명 |
| Description has near-miss or negative case | gap | 없음 |
| Description is not bloated | pass | 22 words |
| Persona and mission are clear | pass | "expert code analyst" |
| Scope boundary is explicit | partial | "specific feature" 언급 있으나 formal scope 섹션 아님 |
| Tools are least-privilege | gap | BashOutput, KillShell, WebSearch 불필요 |
| Model is explicit and appropriate | pass | sonnet — 탐색에 적절 |
| Output contract is actionable | pass | Output Guidance 상세 |
| Confidence gate exists when needed | n/a | 탐색 에이전트 |
| Does not orchestrate other agents | pass | |
| CLAUDE.md relationship is clear | n/a | 탐색 에이전트이므로 필수 아님 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `AGENT-GUIDE.md §6` | BashOutput, KillShell, WebSearch 불필요하게 포함 | read-only 도구로 축소 |
| GAP-002 | ASSET_GAP | P2 | `AGENT-GUIDE.md §3` | description 이 역할 설명, trigger 아님 | trigger 형식으로 변경 |
| GAP-003 | ASSET_GAP | P2 | `AGENT-GUIDE.md §3` | near-miss 또는 negative case 없음 | 추가 |

### GAP-001: Tools Overly Broad (Same as code-architect)

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `AGENT-GUIDE.md §6` |

**Expected**: 탐색/분석 에이전트는 read-only 로 둠. 권장: Read, Grep, Glob, LS.

**Actual**: 10개 도구 중 BashOutput, KillShell, WebSearch 는 코드 탐색에 불필요.

**Impact**: shell 제어 권한 노출. code-architect 와 동일한 문제.

**Recommendation**: `tools: Glob, Grep, LS, Read` 로 축소. feature-dev/** 하위 에이전트가 모두 동일한 과도한 tools 세트를 사용하는 것으로 보아 공통 설정에서 비롯된 것으로 추정 — 근본 원인 확인 필요.

### GAP-002 & GAP-003: Description Issues

description 이 `"Deeply analyzes existing codebase features by tracing execution paths..."` 로 역할 설명임. trigger 형식으로 변경하고 "Do not use for designing new features (use code-architect)" 같은 near-miss 추가 필요.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| Output Guidance 상세함 | 탐색 에이전트의 산출물이 호출자에게 중요하므로 적절 |
| Analysis Approach 4단계 구조 | 명확하고 실행 가능 |

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] tools 를 `Glob, Grep, LS, Read` 로 축소 (P1)
- [ ] description 을 trigger 형식으로 변경 (P2)
- [ ] near-miss 추가: "Do not use for designing new features (use code-architect)" (P2)

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

- feature-dev/** 하위 에이전트 3개(code-architect, code-explorer, code-reviewer)가 모두 동일한 과도한 tools 세트를 사용함. 공통 템플릿에서 비롯된 것인가?

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거: tools 과다 (P1), description 이 trigger 중심 아님 (P2). Output Guidance 와 Analysis Approach 구조는 우수함.
