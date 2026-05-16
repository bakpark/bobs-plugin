# Agent GAP Report: code-reviewer (feature-dev)

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `code-reviewer` |
| Source path | `agents/feature-dev/code-reviewer.md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 부분적 준수. confidence gate 와 output guidance 는 우수하나 tools 가 과하고 description 이 trigger 중심이 아님.
- Highest severity: P1 (tools 과다 — 리뷰 에이전트에 shell 권한)
- Main gap: BashOutput/KillShell/WebSearch 불필요; description 이 역할 설명임
- Recommended next action: tools read-only 로 축소, description trigger 형식으로 변경

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `code-reviewer` |
| description | `"Reviews code for bugs, logic errors, security vulnerabilities..."` |
| description words | 24 |
| tools | `Glob, Grep, LS, Read, NotebookRead, WebFetch, TodoWrite, WebSearch, KillShell, BashOutput` |
| model | `sonnet` |
| color | `red` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | ~280 |
| body lines | ~55 |
| main sections | persona, Review Scope, Core Review Responsibilities, Confidence Scoring, Output Guidance |
| starts with persona | yes |
| has When to invoke | no |
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
| Description has invocation trigger | gap | "Reviews code for bugs..." 역할 설명 |
| Description has near-miss or negative case | partial | "confidence-based filtering to report only high-priority issues" 포함 |
| Description is not bloated | pass | 24 words |
| Persona and mission are clear | pass | |
| Scope boundary is explicit | pass | "unstaged changes from git diff" |
| Tools are least-privilege | gap | 리뷰 에이전트에 BashOutput/KillShell 포함 |
| Model is explicit and appropriate | pass | sonnet — 리뷰에 적절 |
| Output contract is actionable | pass | |
| Confidence gate exists when needed | pass | >= 80, 0-100 scale 명확 |
| Does not orchestrate other agents | pass | |
| CLAUDE.md relationship is clear | yes | "project guidelines in CLAUDE.md" |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `AGENT-GUIDE.md §6` | 리뷰 에이전트에 BashOutput/KillShell 포함 | read-only 로 제한 |
| GAP-002 | ASSET_GAP | P2 | `AGENT-GUIDE.md §3` | description 이 역할 설명, trigger 아님 | trigger 형식으로 변경 |

### GAP-001: Review Agent Has Shell Execution Tools

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `AGENT-GUIDE.md §6` |

**Expected**: 리뷰/분석 에이전트는 read-only 로 둠. 권장: Read, Grep, Glob, LS.

**Actual**: BashOutput, KillShell, WebSearch 포함. 코드 리뷰 에이전트가 shell 프로세스를 제어할 필요가 없음.

**Impact**: 리뷰 에이전트가 Bash 를 통해 의도치 않은 명령 실행 가능. CONSTITUTION.md §6 "All-tools reviewer" 안티패턴에 해당.

**Recommendation**: `tools: Glob, Grep, LS, Read` 로 축소.

### GAP-002: Description Is Role Description

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §3` |

**Expected**: description 이 호출 조건을 담음.

**Actual**: `"Reviews code for bugs, logic errors, security vulnerabilities, code quality issues, and adherence to project conventions..."` — 역할+범위 설명.

**Impact**: 라우팅에는 기능적이나 trigger 형식 권장과 다름.

**Recommendation**: AGENT-GUIDE.md §3 의 모범 사례와 거의 일치하므로 큰 변경 필요 없음. `"Use this agent when you need to review code for bugs, logic errors, security vulnerabilities..."` 형태로 trigger 형식으로 미세 조정.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| Confidence Scoring 0-100 scale + >= 80 gate | AGENT-GUIDE.md §9 의 권장 패턴과 일치. 모범 사례 |
| CLAUDE.md coupling 명확 | "project guidelines in CLAUDE.md" 명시적 참조 |
| Scope boundary ("unstaged changes from git diff") | AGENT-GUIDE.md §5 의 좋은 scope 예시와 일치 |

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] tools 를 `Glob, Grep, LS, Read` 로 축소 (P1)
- [ ] description 을 "Use this agent when..." trigger 형식으로 미세 조정 (P2)

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

- pr-review-toolkit/code-reviewer.md 와의 책임 경계는? 두 에이전트가 동시에 호출되면 안 되는가?

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거: 리뷰 에이전트에 shell 권한 노출 (P1). confidence gate, scope boundary, output contract 는 우수함. tools 만 수정하면 거의 v1 완벽 준수.
