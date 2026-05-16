# Agent GAP Report: code-architect

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `code-architect` |
| Source path | `agents/feature-dev/code-architect.md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 부분적 준수. persona/output guidance 는 우수하나 tools 가 과하고 description 이 trigger 중심이 아님.
- Highest severity: P1 (tools 과다)
- Main gap: tools 에 Write/Edit 없이 Read 계열이지만 BashOutput/KillShell/WebSearch 포함; description 이 역할 설명임
- Recommended next action: tools 축소, description trigger 형식으로 변경

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `code-architect` |
| description | `"Designs feature architectures by analyzing existing codebase patterns..."` |
| description words | 27 |
| tools | `Glob, Grep, LS, Read, NotebookRead, WebFetch, TodoWrite, WebSearch, KillShell, BashOutput` |
| model | `sonnet` |
| color | `green` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | ~250 |
| body lines | ~45 |
| main sections | persona, Core Process (1-3), Output Guidance |
| starts with persona | yes |
| has When to invoke | no |
| has scope boundary | partial |
| has output contract | yes ("Output Guidance") |
| has confidence gate | not applicable |
| has CLAUDE.md coupling | yes (CLAUDE.md guidelines 참조) |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.3 Scope Is Quality Control`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §6 Tool 권한`
- `AGENT-GUIDE.md §8 Output Contract`

---

## 5. Agent-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description has invocation trigger | gap | "Designs feature architectures..." 역할 설명 |
| Description has near-miss or negative case | gap | 없음 |
| Description is not bloated | pass | 27 words |
| Persona and mission are clear | pass | "senior software architect" |
| Scope boundary is explicit | partial | codebase 분석 범위 명시적이지 않음 |
| Tools are least-privilege | gap | BashOutput, KillShell, WebSearch 불필요 |
| Model is explicit and appropriate | pass | sonnet — 아키텍처 설계에 적절 |
| Output contract is actionable | pass | Output Guidance 상세 |
| Confidence gate exists when needed | n/a | 설계 에이전트 |
| Does not orchestrate other agents | pass | |
| CLAUDE.md relationship is clear | partial | 참조 언급 있으나 formal coupling 없음 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `AGENT-GUIDE.md §6` | BashOutput, KillShell, WebSearch 불필요하게 포함 | read-only 도구로 축소 |
| GAP-002 | ASSET_GAP | P2 | `AGENT-GUIDE.md §3` | description 이 역할 설명, trigger 아님 | trigger 형식으로 변경 |
| GAP-003 | ASSET_GAP | P2 | `AGENT-GUIDE.md §5` | near-miss 또는 negative case 없음 | 추가 |

### GAP-001: Tools Overly Broad

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `AGENT-GUIDE.md §6` |

**Expected**: 아키텍처 설계 에이전트는 read-only 도구만 필요.

**Actual**: `Glob, Grep, LS, Read, NotebookRead, WebFetch, TodoWrite, WebSearch, KillShell, BashOutput` — 10개 도구. BashOutput, KillShell, WebSearch 는 코드 아키텍처 설계에 불필요.

**Impact**: BashOutput/KillShell 은 shell 프로세스 제어 권한. 설계 에이전트가 이를 사용할 경우 의도치 않은 부수 효과 가능.

**Recommendation**: `tools: Glob, Grep, LS, Read` 로 축소. WebFetch/WebSearch 는 외부 문서 참조가 꼭 필요하다면 유지.

### GAP-002: Description Is Role Description

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §3` |

**Expected**: description 이 호출 조건을 담음.

**Actual**: `"Designs feature architectures by analyzing existing codebase patterns and conventions, then providing comprehensive implementation blueprints..."` — 역할+산출 설명.

**Impact**: 라우팅 시 "feature architecture design" 의도에는 trigger 될 수 있으나 구체적 호출 조건이 부족함.

**Recommendation**: `"Use this agent when designing a new feature's architecture, before implementation begins. Provides implementation blueprints with specific files, components, and build sequences. Do not use for bug fixes or simple code changes."` 형태로 변경.

### GAP-003: No Near-Miss or Negative Case

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §3`, `AGENT-GUIDE.md §5` |

**Expected**: 비슷하지만 호출하면 안 되는 경우 명시.

**Actual**: 없음.

**Impact**: code-explorer 와 혼동 가능 (둘 다 코드베이스 분석).

**Recommendation**: description 또는 본문에 "Do not use for tracing existing feature implementation (use code-explorer)" 추가.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| TodoWrite 포함 | 아키텍처 설계가 다단계 작업이므로 일정 관리 도구는 합리적 |
| Output Guidance 상세함 | 설계 에이전트의 산출물이 호출자에게 중요하므로 적절 |

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] tools 를 `Glob, Grep, LS, Read` (+ optionally WebFetch) 로 축소 (P1)
- [ ] description 을 trigger 형식으로 변경, near-miss 추가 (P2)
- [ ] 본문에 When to invoke 섹션 추가 (P2)

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

None.

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거: tools 과다로 Bash 제어 권한 노출 (P1), description 이 trigger 중심 아님 (P2). Output Guidance 와 persona 는 우수함.
