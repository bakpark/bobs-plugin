# Agent GAP Report: pr-review-toolkit/comment-analyzer

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | agent |
| source_path | `agents/pr-review-toolkit/comment-analyzer.md` |
| compared_against | `CONSTITUTION.md`, `AGENT-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 본문이 advisory 역할을 명시("You analyze and provide feedback only. Do not modify code"), 호출 시나리오·검증 책임 5개·구조화된 output(Summary/Critical/Improvement/Removals/Positive)을 갖춤. v2 specialist role 패턴을 잘 충족.
- Highest severity: P2
- Main gap: advisory 역할인데 `tools` 가 frontmatter 에 명시되지 않아 권한 표면이 모호하다 (AMBIGUITY). near-miss 진술이 약하고, scope 의 pre-existing/comment-only 경계가 운영 신호 수준에서만 보인다.
- Recommended next action: `tools` 를 read-only 집합으로 명시하고, description 에 인접 역할(code-reviewer, doc-generator)과의 negative case 한 줄을 추가한다.

---

## 3. Asset Snapshot

| Field | Value |
|---|---|
| name | `comment-analyzer` |
| description | `Use this agent when you need to analyze code comments for accuracy, completeness, and long-term maintainability...` (한 단락, 약 95 단어) |
| description_words | ~95 |
| body_words | ~520 |
| body_lines | 80 |
| tools | omitted |
| model | `inherit` |
| color | `green` |
| has_scope | partial (분석 대상이 "comments and docstrings" 임이 본문 전체에 함의, 명시 boundary 한 줄은 약함) |
| has_output_contract | pass (Summary / Critical Issues / Improvement Opportunities / Recommended Removals / Positive Findings 명시) |
| has_quality_gate | partial (Critical / Improvement / Removal 그룹화 + advisory-only rule. confidence score 는 없음) |
| has_project_memory_coupling | n/a (general best practice 위주, 프로젝트-특화 컨벤션 하드코딩 없음) |

---

## 4. Applicable Criteria

Constitution:

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.2 Scope Controls Quality`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`

Agent Guide:

- `AGENT-GUIDE.md §2 Frontmatter`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §4 Body 설계`
- `AGENT-GUIDE.md §5 Scope 설계`
- `AGENT-GUIDE.md §6.1 Tools`
- `AGENT-GUIDE.md §6.2 Model`
- `AGENT-GUIDE.md §7 Output Contract`
- `AGENT-GUIDE.md §8 Quality Gate`
- `AGENT-GUIDE.md §10 Overlap And Reuse`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | description + "When to invoke" 세 시나리오. |
| Specialist role and mission are clear | pass | "meticulous code comment analyzer ... protect codebases from comment rot". |
| Scope and exclusions are clear | partial | comment/docstring 한정이 본문 전반에 함의. 명시적 boundary("Analyze comments and docstrings only.") 한 줄은 없음. |
| Capability surface matches responsibility | unknown | advisory 역할인데 `tools` 미명시. AMBIGUITY. |
| Model choice is explicit or justified | pass | `model: inherit` 은 명시적 선택. comment 분석은 caller 의 reasoning profile 과 일치할 때 자연스러움. |
| Output contract exists | pass | 구조화된 5섹션 output + location/issue/suggestion 형식. |
| Quality gate exists when needed | partial | "advisory only" + Critical/Improvement/Removal 그룹. confidence score 부재이나 false-positive 비용이 비교적 낮은 도메인(주석 검토)이라 P0/P1 으로 키울 정도는 아님. |
| Project memory coupling is appropriate | n/a | 프로젝트-특화 규칙 하드코딩 없음. CLAUDE.md 참조도 강요하지 않음. |
| Overlap with other agents is intentional | partial | code-reviewer 와 trigger·scope 가 다름. 그러나 description 에서 차이 진술 없음. |
| Behavior can be verified | pass | output 형식이 고정되어 반복 검증 가능. |

---

## 6. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | AMBIGUITY | P2 | `AGENT-GUIDE.md §6.1`, `CONSTITUTION.md §3.5` | advisory 역할인데 `tools` 미명시 | tools 를 read-only 집합으로 명시 |
| GAP-002 | ASSET_GAP | P3 | `AGENT-GUIDE.md §3`, `§10` | description 에 negative case 없음 (code-reviewer 와 갈리는 지점) | "Do not use for general code review" 한 줄 추가 |
| GAP-003 | ASSET_GAP | P3 | `AGENT-GUIDE.md §5` | scope 명시 boundary 한 줄 약함 | "Analyze comments and docstrings only" 한 줄로 명시 |

### GAP-001: advisory 역할인데 `tools` 미명시

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §6.1 Tools`, `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility` |

**Expected**

advisory/review 에이전트는 `tools` 를 `Read, Grep, Glob, LS` 같은 read-only 도구로 좁힌다. 본문 advisory-only 진술과 권한 표면이 일치해야 한다.

**Actual**

frontmatter 에 `tools` 가 없다. 본문 마지막에 "IMPORTANT: You analyze and provide feedback only. Do not modify code or comments directly. Your role is advisory" 라고 강하게 advisory 선언.

**Evidence**

- `agents/pr-review-toolkit/comment-analyzer.md:1-6` frontmatter
- 같은 파일 `:79` "IMPORTANT: You analyze and provide feedback only. Do not modify code or comments directly."

**Impact**

본문 지시는 advisory 인데 권한 표면이 그것을 보장하지 않는다. AGENT-GUIDE.md §6.1 가 platform default 단정을 막으므로 AMBIGUITY 로 두지만, advisory + 광범위 권한 조합은 hidden mutation 위험이 있어 P2.

**Recommendation**

Asset 수정. `tools: Read, Grep, Glob, LS` 명시. 본문 advisory 선언과 권한 표면이 양방향으로 강제되도록.

---

### GAP-002: description 에 negative case 없음

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `AGENT-GUIDE.md §3 Description 전략`, `§10 Overlap And Reuse` |

**Expected**

description 은 호출 조건 + 입력 + near-miss 를 보여 인접 역할(code-reviewer, doc-generator)과의 라우팅 차이를 드러낸다.

**Actual**

description 은 "when to use" 만 명시하고, "do not use" 가 없다. 본문도 "비교 대상이 무엇이 아닌지" 진술은 약함.

**Evidence**

`agents/pr-review-toolkit/comment-analyzer.md:3` description 한 단락.

**Impact**

code-reviewer 와의 호출 경계가 모호. 일반 코드 리뷰 요청에 잘못 호출될 가능성 (낮음 → P3).

**Recommendation**

Asset 수정. "Do not use for general code review, bug detection, or generating new documentation." 한 줄 추가.

---

### GAP-003: scope 명시 boundary 한 줄이 약함

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `AGENT-GUIDE.md §5 Scope 설계` |

**Expected**

scope 에 기본 입력, 제외, pre-existing 처리, no-finding 케이스가 보이면 false positive 가 줄어든다.

**Actual**

분석 대상이 "comments and docstrings" 임은 본문 전반에서 명확하지만, 한 줄짜리 boundary 진술 ("Analyze comments and docstrings only; exclude code logic review.") 가 없어 호출자가 scope override 여부를 판단하기 어렵다. no-finding 케이스는 "Positive Findings (if any)" 로 약하게 처리.

**Evidence**

`agents/pr-review-toolkit/comment-analyzer.md:19-22` 본문 도입부 — mission 진술은 있으나 scope boundary 한 줄은 명시 안 됨.

**Impact**

scope override 가능 여부와 no-finding 처리가 약해 호출자/runtime 이 매번 다른 행동을 받을 가능성. 영향은 낮음(P3).

**Recommendation**

Asset 수정. "Analyze comments and docstrings only. Exclude code logic, design, and architectural review unless the caller explicitly requests it." 한 줄 추가. no-finding 케이스를 "Summary 에 'No comment issues found' 로 명시" 등으로 명확화.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `model: inherit` | caller 의 reasoning profile 과 일치하는 보조 역할로 §6.2 의 inherit 정당화 범위에 들어옴. comment 검토는 caller 가 작성/수정한 도메인 컨텍스트를 그대로 사용하는 편이 정확도에 유리. |
| confidence score 부재 | comment rot 검출은 factual accuracy 가 중심이며 group 분류(Critical/Improvement/Removal)와 advisory-only rule 이 quality gate 역할. false-positive 비용이 reviewer 대비 낮음. |
| description 에 시나리오 산문 + 본문 "When to invoke" 중복 | 약한 중복(코드 리뷰어 대비 짧음), 카탈로그 비용 영향 미미. finding 으로 승격하지 않음. |

---

## 8. Suggested Changes

### Asset Changes

- [ ] `tools: Read, Grep, Glob, LS` 같이 read-only 집합 명시.
- [ ] description 또는 본문에 negative case 추가 ("Do not use for general code review/bug detection").
- [ ] scope boundary 한 줄 명시 ("Analyze comments and docstrings only").
- [ ] no-finding 케이스 명확화 (Summary 에 'No comment issues found' 명시).

### Guide Changes

- [ ] None.

### Constitution Review

- [ ] None.

---

## 9. Follow-up Questions

- 플랫폼 default 가 "tools 생략 = 전체 권한" 인지 확인 필요. advisory 선언이 강하므로 default 가 read-only 라면 GAP-001 severity 를 P3 으로 낮출 수 있음.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- Specialist role, advisory-only 선언, 구조화된 output contract, 명확한 mission 모두 v2 기준을 충족.
- 가장 큰 finding 은 advisory 역할의 권한 표면 미명시(P2 AMBIGUITY). 본문 advisory 선언이 강해 실제 위험은 제한적이나 frontmatter 와의 일관성을 위해 정렬 권장.
- 나머지 finding(P3) 은 정리·명확화 수준이며 자산 목적과 충돌하지 않음.
