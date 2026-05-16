# Agent GAP Report: pr-review-toolkit/code-reviewer

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | agent |
| source_path | `agents/pr-review-toolkit/code-reviewer.md` |
| compared_against | `CONSTITUTION.md`, `AGENT-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 본문 구조(When to invoke / Review Scope / Core Responsibilities / Confidence Scoring / Output Format)가 v2 의 specialist role + scope + quality gate + output contract 패턴을 잘 만족한다.
- Highest severity: P2
- Main gap: read-only review 역할인데 `tools` 가 frontmatter 에 명시되지 않아 권한 표면이 모호하다 (AMBIGUITY). description 이 길고 호출 시나리오를 본문과 중복 설명하는 약한 bloat 가 있다.
- Recommended next action: 권한 표면을 명시(`Read, Grep, Glob, LS`)하고, description 의 시나리오 나열을 본문 "When to invoke" 로 통합해 카탈로그 비용을 줄인다.

---

## 3. Asset Snapshot

| Field | Value |
|---|---|
| name | `code-reviewer` |
| description | `Use this agent when you need to review code for adherence to project guidelines...` (긴 호출 산문, 약 170 단어) |
| description_words | ~170 |
| body_words | ~330 |
| body_lines | 57 |
| tools | omitted |
| model | `opus` |
| color | `green` |
| has_scope | pass ("Review Scope" 섹션: "By default, review unstaged changes from `git diff`") |
| has_output_contract | pass (Output Format: 항목·severity grouping·no-finding case) |
| has_quality_gate | pass (Confidence Scoring 0-100, only report ≥80) |
| has_project_memory_coupling | pass (CLAUDE.md 명시적 인용) |

---

## 4. Applicable Criteria

Constitution:

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.2 Scope Controls Quality`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`

Agent Guide:

- `AGENT-GUIDE.md §2 Frontmatter`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §4 Body 설계`
- `AGENT-GUIDE.md §5 Scope 설계`
- `AGENT-GUIDE.md §6.1 Tools`
- `AGENT-GUIDE.md §6.2 Model`
- `AGENT-GUIDE.md §7 Output Contract`
- `AGENT-GUIDE.md §8 Quality Gate`
- `AGENT-GUIDE.md §9 CLAUDE.md And Project Memory`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | description + "When to invoke" 가 세 시나리오 명시. near-miss 는 약함. |
| Specialist role and mission are clear | pass | "expert code reviewer ... review against project guidelines in CLAUDE.md with high precision". |
| Scope and exclusions are clear | partial | 기본 입력(unstaged `git diff`) 명시. pre-existing 처리·no-finding 케이스는 가벼움. |
| Capability surface matches responsibility | unknown | read-only review 인데 `tools` 미명시. AMBIGUITY. |
| Model choice is explicit or justified | partial | `opus` 명시. 비용 정당화(false-positive 최소화) 본문에 함의되어 있으나 명시 설명은 없음. |
| Output contract exists | pass | "Output Format" + severity grouping + no-finding 명시. |
| Quality gate exists when needed | pass | 0-100 confidence, ≥80 report 강제. |
| Project memory coupling is appropriate | pass | "explicit project rules in CLAUDE.md or equivalent" 명시. |
| Overlap with other agents is intentional | partial | 동 toolkit 내 `code-simplifier`, `comment-analyzer` 와 trigger·scope 가 다름. 그러나 description 에 명시는 없음. |
| Behavior can be verified | pass | confidence gate + output format 으로 반복 검증 가능. |

---

## 6. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | AMBIGUITY | P2 | `AGENT-GUIDE.md §6.1`, `CONSTITUTION.md §3.5` | read-only review 인데 `tools` 미명시 | tools 를 read-only 도구로 명시 |
| GAP-002 | ASSET_GAP | P3 | `AGENT-GUIDE.md §3`, `CONSTITUTION.md §3.7` | description 시나리오 나열이 본문과 중복 → 카탈로그 비용 | 시나리오를 본문으로 일원화, description 은 trigger 한 단락 |
| GAP-003 | ASSET_GAP | P3 | `AGENT-GUIDE.md §5` | no-finding/pre-existing/override 처리 진술이 약함 | "Pre-existing issues outside diff are excluded unless ..." 한 줄 추가 |

### GAP-001: read-only review 에이전트가 `tools` 를 명시하지 않음

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §6.1 Tools`, `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility` |

**Expected**

advisory/review 에이전트는 `tools` 를 `Read, Grep, Glob, LS` 같은 read-only 도구로 좁힌다. mutation 가능한 도구는 책임에 맞아야 한다.

**Actual**

frontmatter 에 `tools` 가 없다. 본문은 "advisory only" 라고 직접 선언하지는 않지만 출력은 "issue + suggestion" 형식의 advisory 다.

**Evidence**

`agents/pr-review-toolkit/code-reviewer.md:1-6` frontmatter — `name`, `description`, `model`, `color` 만 존재.

**Impact**

플랫폼 default 가 "전체 권한" 일 경우 advisory 역할이 Write/Edit/Bash 까지 접근 가능해진다. AGENT-GUIDE.md §6.1 가 platform default 단정 금지를 명시하므로 finding 은 AMBIGUITY 로 남기지만, advisory 역할 + 광범위 권한 조합은 hidden mutation 위험이라 P2.

**Recommendation**

Asset 수정. `tools: Read, Grep, Glob, LS` 와 같이 read-only 집합으로 명시.

---

### GAP-002: description 시나리오 나열이 본문과 중복

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `AGENT-GUIDE.md §3 Description 전략`, `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context` |

**Expected**

description 은 호출 조건/입력/near-miss 를 짧게 보여주는 router 다. 시나리오를 카탈로그에 노출할 필요가 큰 경우가 아니면 본문 `When to invoke` 로 옮긴다.

**Actual**

description 이 약 170 단어. "Typical triggers include the user asking for a review of a feature they just implemented, the assistant proactively reviewing its own newly-written code before declaring a task done, and a final pre-PR check before opening a pull request." 같은 시나리오 나열이 본문 `When to invoke` 와 거의 동일하게 반복된다.

**Evidence**

- `agents/pr-review-toolkit/code-reviewer.md:3` description 마지막 문장
- 같은 파일 `:11-16` 본문 "When to invoke" 세 시나리오와 사실상 동일

**Impact**

카탈로그(모든 description 이 항상 노출되는 영역) 비용이 증가하고, 향후 시나리오 수정 시 두 곳을 동기화해야 한다. 라우팅 자체에는 큰 영향이 없어 P3.

**Recommendation**

Asset 수정. description 은 trigger 핵심(20-60 단어)으로 줄이고, 시나리오는 본문 `When to invoke` 에만 둔다.

---

### GAP-003: scope 의 pre-existing / no-finding 처리 진술이 약함

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `AGENT-GUIDE.md §5 Scope 설계` |

**Expected**

scope 에 기본 입력, 제외, override, pre-existing 처리, no-finding 처리가 보이면 false positive 가 줄어든다.

**Actual**

"Review Scope" 는 한 문장. confidence gate 가 "26-50 nitpick" 으로 pre-existing 을 부분적으로 흡수하지만, diff 범위 외부의 기존 코드 처리 정책은 명시되지 않는다. "If no high-confidence issues exist" 케이스는 있음 (good).

**Evidence**

`agents/pr-review-toolkit/code-reviewer.md:21` "By default, review unstaged changes from `git diff`. The user may specify different files or scope to review."

**Impact**

pre-existing 코드의 문제를 새 diff 처럼 보고할 가능성이 있어 false positive 비용이 누적될 수 있다. 본 에이전트의 confidence gate 가 P0 으로 키우지는 않는다.

**Recommendation**

Asset 수정. "Issues outside the diff are excluded unless the caller explicitly requests broader review." 한 줄 추가.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `model: opus` 비용 정당화 명시 안 됨 | 본문 전반이 high precision / false positive 최소화 mission 이고, confidence gate 가 강한 review 역할에 opus 선택은 §6.2 의 정당화 범위에 들어옴. |
| description 이 가이드 권장 길이(20-80 단어) 초과 | 호출 조건과 입력 범위를 본문 외에서도 노출하려는 의도로 보임. P3 가 별도로 다루므로 Acceptable 로 분류. |

---

## 8. Suggested Changes

### Asset Changes

- [ ] `tools: Read, Grep, Glob, LS` 같이 read-only 집합 명시.
- [ ] description 을 trigger 한 단락으로 축소 (현재 본문 "When to invoke" 와 중복 제거).
- [ ] Review Scope 섹션에 pre-existing / out-of-diff 처리 한 줄 추가.

### Guide Changes

- [ ] None.

### Constitution Review

- [ ] None.

---

## 9. Follow-up Questions

- 플랫폼 default 가 "tools 생략 = 전체 권한" 인지, 아니면 "tools 생략 = 기본 read-only" 인지 운영 환경 확인 필요. 결과에 따라 GAP-001 의 severity 가 달라질 수 있음.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- Specialist role / scope / confidence gate / output contract / project memory coupling 이 모두 v2 핵심 기대를 충족.
- 가장 큰 finding 은 `tools` 미명시에 따른 AMBIGUITY (P2). advisory 역할의 권한 표면을 좁히면 즉시 PASS 로 격상 가능.
- 나머지는 P3 정리 수준이라 asset 의 목적과 충돌하지 않음.
