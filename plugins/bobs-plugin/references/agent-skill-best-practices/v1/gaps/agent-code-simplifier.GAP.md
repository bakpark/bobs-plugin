# Agent GAP Report: code-simplifier (agents/code-simplifier.md)

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `code-simplifier` |
| Source path | `agents/code-simplifier.md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 부분적 준수. model 은 명시했으나 tools 가 누락, description 이 trigger 중심이 아님, output contract 부재.
- Highest severity: P1 (tools 미지정, project convention 누출)
- Main gap: tools 미지정으로 권한 범위가 불명확; 본문에 ES modules/React 등 프로젝트 특정 규칙 하드코딩; output contract 없음
- Recommended next action: tools 명시(read-only 또는 Write 제한), 프로젝트 규칙 분리, output contract 추가

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `code-simplifier` |
| description | `"Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality..."` |
| description words | 23 |
| tools | omitted (default = *) |
| model | `opus` |
| color | omitted |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | ~450 |
| body lines | ~60 |
| main sections | persona + 5 numbered responsibilities + refinement process |
| starts with persona | yes ("You are an expert code simplification specialist") |
| has When to invoke | no |
| has scope boundary | partial ("recently modified code") |
| has output contract | no |
| has confidence gate | not applicable |
| has CLAUDE.md coupling | yes (CLAUDE.md 참조) |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.3 Scope Is Quality Control`
- `CONSTITUTION.md §2.9 CLAUDE.md Is Project Memory`
- `AGENT-GUIDE.md §2 Frontmatter`
- `AGENT-GUIDE.md §6 Tool 권한`
- `AGENT-GUIDE.md §8 Output Contract`

---

## 5. Agent-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description has invocation trigger | gap | "Simplifies and refines code..." — 역할 설명, trigger 아님 |
| Description has near-miss or negative case | gap | 없음 |
| Description is not bloated | pass | 23 words, 짧음 |
| Persona and mission are clear | pass | "expert code simplification specialist" |
| Scope boundary is explicit | partial | "recently modified code" 언급 있으나 formal scope 섹션 아님 |
| Tools are least-privilege | gap | tools 미지정 = default * (전체 권한) |
| Model is explicit and appropriate | pass | opus — 코드 단순화에는 적절 |
| Output contract is actionable | gap | 없음 |
| Confidence gate exists when needed | n/a | 수정 에이전트이므로 confidence 아님 |
| Does not orchestrate other agents | pass | |
| CLAUDE.md relationship is clear | gap | CLAUDE.md 참조하나 본문에 프로젝트 특정 규칙 하드코딩 병존 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `AGENT-GUIDE.md §6` | tools 미지정 = 전체 권한 노출 | Read, Write, Grep, Glob 으로 제한 |
| GAP-002 | ASSET_GAP | P1 | `CONSTITUTION.md §2.9` | 본문에 ES modules/React 등 프로젝트 특정 규칙 하드코딩 | CLAUDE.md 참조로만 유지, 구체적 규칙 제거 |
| GAP-003 | ASSET_GAP | P1 | `AGENT-GUIDE.md §8` | output contract 없음 | Output Format 섹션 추가 |
| GAP-004 | ASSET_GAP | P2 | `AGENT-GUIDE.md §3` | description 이 역할 설명, trigger 아님 | "Use when code has been written or modified and needs simplification" 형태로 변경 |

### GAP-001: Tools Not Specified = Full Access

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `AGENT-GUIDE.md §6` |

**Expected**: 도구 역할에 맞게 줄임. 코드 단순화 에이전트는 Read, Write, Grep, Glob 권장.

**Actual**: tools 미지정 = default * (전체 권한). Bash, Edit 등 불필요한 권한 포함.

**Impact**: 코드 수정 에이전트가 Bash 등을 통해 의도치 않은 부수 효과 발생 가능.

**Recommendation**: `tools: Read, Write, Grep, Glob` 명시.

### GAP-002: Project Convention Leakage in Body

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §2.9` |

**Expected**: 프로젝트 고유 규칙은 CLAUDE.md 에 둠. 에이전트는 재사용 가능한 역할만 담음.

**Actual**: 본문에 "Use ES modules with proper import sorting", "Prefer function keyword over arrow functions", "Follow proper React component patterns" 등 구체적 프로젝트 규칙 하드코딩.

**Impact**: 다른 프로젝트(React 가 아닌, ES modules 가 아닌)에서 재사용 시 규칙이 부적절함. CLAUDE.md 참조와 중복/모순 가능.

**Recommendation**: 구체적 규칙 제거하고 "Follow the established coding standards from CLAUDE.md" 만으로 유지.

### GAP-003: No Output Contract

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `AGENT-GUIDE.md §8` |

**Expected**: 호출자에게 반환할 산출물 구조 명시.

**Actual**: output contract 없음. "Document only significant changes that affect understanding" 언급 있으나 형식 미정의.

**Impact**: 호출자가 에이전트 결과를 어떻게 해석해야 하는지 불명확.

**Recommendation**: Output Format 섹션 추가 (예: 변경 파일 목록, diff 요약, 기능 보존 확인).

### GAP-004: Description Is Role Description, Not Trigger

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §3` |

**Expected**: description 이 호출 조건과 near-miss 를 담음.

**Actual**: `"Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality."` — 역할 설명임.

**Impact**: 라우팅 시 "code simplification" 의도만으로는 trigger 될 수 있으나, 구체적 호출 조건이 부족함.

**Recommendation**: `"Use this agent when code has been written or modified and needs simplification for clarity while preserving functionality. Do not use for architectural refactoring or new feature development."` 형태로 변경.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| model: opus 사용 | 코드 단순화는 정밀도가 중요한 작업. 비싸지만 역할에 적합 (§7 Model 선택) |
| "operate autonomously and proactively" 문구 | 자동 실행 에이전트의 특성상 의도적일 수 있음. 다만 invocation control 과의 관계는 명확해야 함 |

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] `tools: Read, Write, Grep, Glob` 명시 (P1)
- [ ] 본문에서 프로젝트 특정 규칙 제거, CLAUDE.md 참조만 유지 (P1)
- [ ] Output Format 섹션 추가 (P1)
- [ ] description 을 trigger 형식으로 변경 (P2)

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

- 이 에이전트가 자동으로 실행되는가, 아니면 명시적으로 호출되는가? 자동 실행이라면 approval gate 고려 필요.

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거: tools 미지정으로 전체 권한 노출 (P1), 프로젝트 규칙 누출 (P1), output contract 부재 (P1). pr-review-toolkit/code-simplifier.md 와 내용 중복도 확인 필요.
