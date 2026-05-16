# Agent GAP Report: comment-analyzer

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | agent |
| Agent name | `comment-analyzer` |
| Source path | `agents/pr-review-toolkit/comment-analyzer.md` |
| Compared against | `CONSTITUTION.md`, `AGENT-GUIDE.md` |
| Final decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 전반적으로 v1 준수. description 이 trigger 중심, When to invoke 시나리오 명확, output contract 있음. model 이 inherit 인 점이 유일한 GAP.
- Highest severity: P2 (model inherit)
- Main gap: model 이 inherit 로 호출자 모델과 일치 — comment 분석에는 sonnet 으로 고정하는 것이 비용/품질 균형에 더 좋음
- Recommended next action: model 을 sonnet 으로 변경 고려

---

## 3. Agent Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `comment-analyzer` |
| description | `"Use this agent when you need to analyze code comments for accuracy..."` |
| description words | ~60 |
| tools | omitted (default = *) |
| model | `inherit` |
| color | `green` |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | ~550 |
| body lines | ~90 |
| main sections | persona, When to invoke, 5 numbered analysis responsibilities, output structure |
| starts with persona | yes |
| has When to invoke | yes (3 시나리오) |
| has scope boundary | partial |
| has output contract | yes (Summary/Critical Issues/Improvement Opportunities/Removals/Positive Findings) |
| has confidence gate | not applicable (분석 에이전트이나 confidence scoring 없음) |
| has CLAUDE.md coupling | no |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.3 Scope Is Quality Control`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §6 Tool 권한`
- `AGENT-GUIDE.md §7 Model 선택`
- `AGENT-GUIDE.md §8 Output Contract`

---

## 5. Agent-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description has invocation trigger | pass | "Use this agent when you need to analyze code comments..." |
| Description has near-miss or negative case | partial | "(1)(2)(3)(4)" 케이스 구체적이나 명시적 negative case 없음 |
| Description is not bloated | pass | ~60 words, 짧은 trigger형 범위 내 |
| Persona and mission are clear | pass | "meticulous code comment analyzer" |
| Scope boundary is explicit | partial | comment 분석에 한정하나 입력 범위 구체적이지 않음 |
| Tools are least-privilege | gap | 미지정 = default *. read-only 에이전트이므로 Read, Grep, Glob 권장 |
| Model is explicit and appropriate | gap | inherit — 호출자 모델과 일치하면 opus 도 가능. 비용/결정성 문제 |
| Output contract is actionable | pass | 5-category 구조 명확 |
| Confidence gate exists when needed | partial | 분석 에이전트이나 confidence scoring 없음 |
| Does not orchestrate other agents | pass | |
| CLAUDE.md relationship is clear | n/a | comment 분석이므로 CLAUDE.md coupling 필수 아님 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `AGENT-GUIDE.md §7` | model: inherit — comment 분석에는 sonnet 으로 고정 권장 | sonnet 변경 고려 |
| GAP-002 | ASSET_GAP | P2 | `AGENT-GUIDE.md §6` | tools 미지정. read-only 에이전트 | Read, Grep, Glob 명시 |
| GAP-003 | ASSET_GAP | P3 | `AGENT-GUIDE.md §9` | 분석 에이전트이나 confidence gate 없음 | "Critical/Improvement"分级이 confidence 역할을 하지만 formal scoring 없음 |

### GAP-001: Model inherit for Comment Analysis

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §7` |

**Expected**: model 을 명시하고 역할에 맞게 선택. 기본은 sonnet.

**Actual**: `model: inherit` — 호출자 모델과 일치. 호출자가 opus 를 쓰면 comment 분석도 opus 로 실행됨.

**Impact**: comment 정확성 검증은 복잡한 추론이 아닌 pattern matching+논리 검사. sonnet 이 충분하며 opus 로 실행하면 불필요한 비용 발생. inherit 은 "결정성이 낮아질 수 있음" (§7).

**Recommendation**: `model: sonnet` 으로 변경. comment 분석은 균형 모델로 충분.

### GAP-002: Tools Not Specified for Read-Only Agent

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §6` |

**Expected**: 분석 에이전트는 read-only 도구 명시.

**Actual**: tools 미지정 = default *. 본문 마지막에 "Do not modify code or comments directly. Your role is advisory" 언급 있으나 frontmatter 에서 권한 제한 없음.

**Impact**: advisory 역할임에도 쓰기 도구에 접근 가능.

**Recommendation**: `tools: Read, Grep, Glob` 명시.

### GAP-003: No Formal Confidence Gate

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `AGENT-GUIDE.md §9` |

**Expected**: 리뷰/분석 에이전트는 confidence gate 로 false positive 를 줄임.

**Actual**: output 구조에 "Critical Issues" / "Improvement Opportunities" / "Recommended Removals"分级은 있으나 formal confidence scoring 없음.

**Impact**: 경미.分级이 confidence 역할을 일부 수행하나, "건강한 회의적 시각"만으로는 false positive 필터링이 불충분할 수 있음.

**Recommendation**: 각 finding 에 confidence score(0-100) 추가하거나 "Critical Issues" 만 보고하도록 gate 설정.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| output 구조 5-category | Summary/Critical/Improvement/Removals/Positive — 호출자에게 유용한 구조. v1 가이드의 Output Format 권장과 일치 |
| When to invoke + 3 시나리오 | 좋은 패턴. AGENT-GUIDE.md §4 권장 구조와 일치 |
| "advisory only" 명시 | 역할 경계가 명확함. good pattern |

---

## 8. Suggested Changes

### 8.1 Agent Changes

- [ ] `model: sonnet` 으로 변경 (P2)
- [ ] `tools: Read, Grep, Glob` 명시 (P2)
- [ ] formal confidence scoring 또는 reporting gate 추가 고려 (P3)

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

근거: description trigger 중심, When to invoke 시나리오 명확, output contract 좋음. model inherit (P2) 과 tools 미지정 (P2) 만 존재. 분석 에이전트로서 구조가 잘 설계됨.
