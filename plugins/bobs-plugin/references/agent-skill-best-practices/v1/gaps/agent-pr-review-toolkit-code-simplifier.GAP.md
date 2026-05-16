# Agent GAP Report: code-simplifier (pr-review-toolkit)

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `code-simplifier` |
| Source path | `agents/pr-review-toolkit/code-simplifier.md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 부분적 준수. description 은 `<example>` 임베드형으로 trigger 는 구체적이지만 과장; tools 미지정; 본문에 프로젝트 규칙 하드코딩.
- Highest severity: P1 (tools 미지정, project convention 누출)
- Main gap: description 이 ~300 words 로 길고 example 과다; tools 미지정; agents/code-simplifier.md 와 내용 중복
- Recommended next action: tools 명시, 프로젝트 규칙 분리, description 압축, 중복 해결

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `code-simplifier` |
| description | ~300 words (`<example>` 3개 포함) |
| description words | ~300 |
| tools | omitted (default = *) |
| model | `opus` |
| color | omitted |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | ~450 |
| body lines | ~65 |
| main sections | persona + 5 numbered responsibilities + refinement process |
| starts with persona | yes |
| has When to invoke | no |
| has scope boundary | partial ("recently modified code") |
| has output contract | no |
| has confidence gate | not applicable |
| has CLAUDE.md coupling | yes (CLAUDE.md 참조) |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.9 CLAUDE.md Is Project Memory`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §6 Tool 권한`
- `AGENT-GUIDE.md §8 Output Contract`

---

## 5. Agent-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description has invocation trigger | pass | `<example>` 시나리오 구체적 |
| Description has near-miss or negative case | gap | 없음 |
| Description is not bloated | gap | ~300 words, 3 example — 비용 큼 |
| Persona and mission are clear | pass | |
| Scope boundary is explicit | partial | "recently modified code" |
| Tools are least-privilege | gap | 미지정 = default * |
| Model is explicit and appropriate | pass | opus |
| Output contract is actionable | gap | 없음 |
| Confidence gate exists when needed | n/a | 수정 에이전트 |
| Does not orchestrate other agents | pass | |
| CLAUDE.md relationship is clear | gap | CLAUDE.md 참조하나 본문에 프로젝트 규칙 하드코딩 병존 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `AGENT-GUIDE.md §6` | tools 미지정 = 전체 권한 노출 | Read, Write, Grep, Glob 명시 |
| GAP-002 | ASSET_GAP | P1 | `CONSTITUTION.md §2.9` | 본문에 프로젝트 특정 규칙 하드코딩 | CLAUDE.md 참조로만 유지 |
| GAP-003 | ASSET_GAP | P1 | `AGENT-GUIDE.md §8` | output contract 없음 | 추가 |
| GAP-004 | ASSET_GAP | P2 | `AGENT-GUIDE.md §3` | description ~300 words, `<example>` 3개 — 카탈로그 비용 과다 | 압축 또는 본문으로 이동 |
| GAP-005 | AMBIGUITY | P2 | `CONSTITUTION.md §3.4` | agents/code-simplifier.md 와 내용 거의 동일 | 중복 해결 |

### GAP-001 & GAP-002 & GAP-003: Same as agents/code-simplifier.md

tools 미지정 (P1), 프로젝트 규칙 누출 (P1), output contract 부재 (P1) — agents/code-simplifier.md 와 동일한 문제. 두 파일이 거의 동일한 내용임.

### GAP-004: Description Bloat with Examples

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §3` |

**Expected**: `<example>` 임베드형은 300 words 안쪽 권장, 기본 0.

**Actual**: ~300 words, `<example>` 3개 + `<commentary>` 3개. 카탈로그 노출 비용이 큼.

**Impact**: 매 세션 카탈로그에 ~300 words 노출. example 이 유용하지만 본문 "When to invoke" 로 이동하면 비용 절감.

**Recommendation**: description 을 짧은 trigger형으로 압축하고 example 을 본문 When to invoke 섹션으로 이동.

### GAP-005: Duplicate with agents/code-simplifier.md

본문 내용이 agents/code-simplifier.md 와 거의 동일함 (동일한 persona, 5 numbered responsibilities, refinement process). 두 파일 중 하나로 통합하거나 역할 분리 필요.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `<example>` 사용 | 라우팅이 헷갈리는 경우 권장 (§3). 다만 3개는 많음 — 1-2개로 압축 가능 |

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] `tools: Read, Write, Grep, Glob` 명시 (P1)
- [ ] 본문에서 프로젝트 특정 규칙 제거 (P1)
- [ ] Output Format 섹션 추가 (P1)
- [ ] description 을 짧은 trigger형으로 압축, example 을 본문으로 이동 (P2)
- [ ] agents/code-simplifier.md 와 중복 해결 (P2)

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

- agents/code-simplifier.md 와 pr-review-toolkit/code-simplifier.md 중 어떤 것을 canonical 로 할 것인가?

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거: tools 미지정 (P1), 프로젝트 규칙 누출 (P1), output contract 부재 (P1), description 과다 (P2), agents/code-simplifier.md 와 중복 (P2).
