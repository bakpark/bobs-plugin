# Agent GAP Report: pr-review-toolkit/code-simplifier

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | agent |
| source_path | `agents/pr-review-toolkit/code-simplifier.md` |
| compared_against | `CONSTITUTION.md`, `AGENT-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | SPLIT_ASSET |

---

## 2. Executive Summary

- Overall fit: 본문은 root `agents/code-simplifier.md` 와 사실상 동일하다. PR-review toolkit 안에 위치하지만 body 에는 toolkit-특화 input/output 또는 PR diff 워크플로 진술이 없다. 결과적으로 두 에이전트의 책임이 같고 호출자가 어느 쪽을 부를지 결정할 단서가 부족하다.
- Highest severity: P1
- Main gap: `name: code-simplifier` 가 root 와 충돌(이름 중복) + 본문 동일 → routing ambiguity. 추가로 root 와 동일한 hidden mutation 위험, tools 미명시, output contract 부재가 누적.
- Recommended next action: SPLIT_ASSET — toolkit 컨텍스트에 맞게 trigger/scope/output 을 차별화하거나 한쪽을 deprecate. 그 후 root 리포트와 동일한 권한 표면/effect gate 정렬을 적용.

---

## 3. Asset Snapshot

| Field | Value |
|---|---|
| name | `code-simplifier` |
| description | YAML literal block (`|`), 호출 조건 산문 + 3개의 `<example>` 임베드, 약 350 단어 |
| description_words | ~350 |
| body_words | ~410 |
| body_lines | 89 |
| tools | omitted |
| model | `opus` |
| color | omitted |
| has_scope | partial (Focus Scope #5: "recently modified or touched in the current session") |
| has_output_contract | gap (없음 — "Document only significant changes" 한 줄만) |
| has_quality_gate | partial (Maintain Balance 보수 기준) |
| has_project_memory_coupling | gap (CLAUDE.md 인용하면서 ES modules / `function` keyword / React Props / try-catch 회피 등 프로젝트-특화 스타일 하드코딩) |

---

## 4. Applicable Criteria

Constitution:

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.2 Scope Controls Quality`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`
- `CONSTITUTION.md §3.10 Overlap Must Be Intentional`

Agent Guide:

- `AGENT-GUIDE.md §2 Frontmatter`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §5 Scope 설계`
- `AGENT-GUIDE.md §6.1 Tools`
- `AGENT-GUIDE.md §7 Output Contract`
- `AGENT-GUIDE.md §9 CLAUDE.md And Project Memory`
- `AGENT-GUIDE.md §10 Overlap And Reuse`
- `AGENT-GUIDE.md §11 Quantitative Heuristics` (description bloat)
- `AGENT-GUIDE.md §13 Anti-Patterns` (Hidden mutation, Description bloat, Unintentional duplicate)

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | partial | description 산문 + `<example>` 3개로 trigger 는 풍부하나 toolkit context (PR diff) 와의 연결이 명시되지 않음. |
| Specialist role and mission are clear | pass | "code simplification specialist". |
| Scope and exclusions are clear | partial | "recently modified" 외 제외 범위·no-op 케이스 없음. |
| Capability surface matches responsibility | gap | mutation 역할인데 `tools` 미명시. |
| Model choice is explicit or justified | partial | `opus` 명시이지만 비용·품질 정당화 없음. |
| Output contract exists | gap | toolkit 안에 있는데도 PR 컨텍스트에 맞는 output 형식 없음. |
| Quality gate exists when needed | partial | "Maintain Balance" 가 보수 기준. confidence/severity gate 없음. |
| Project memory coupling is appropriate | gap | 프로젝트-특화 스타일을 본문에 하드코딩. |
| Overlap with other agents is intentional | gap | root `code-simplifier.md` 와 본문 동일. toolkit 위치 외 차이 설명 없음. |
| Behavior can be verified | partial | 자동·proactive 실행 + output contract 부재로 반복 검증 어려움. |

---

## 6. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `CONSTITUTION.md §3.10`, `AGENT-GUIDE.md §10` | root `code-simplifier.md` 와 본문 동일, name 중복 → 호출 라우팅 모호 | SPLIT (toolkit-특화 차별화) 또는 한쪽 deprecate |
| GAP-002 | AMBIGUITY | P1 | `AGENT-GUIDE.md §6.1`, `CONSTITUTION.md §3.5` | mutation 역할인데 `tools` 미명시 | tools 명시 |
| GAP-003 | ASSET_GAP | P1 | `CONSTITUTION.md §3.3`, `AGENT-GUIDE.md §13` | 자동·proactive mutation 지시에 gate 없음 | 자동 실행 문구 제거 또는 advisory 로 정렬 |
| GAP-004 | ASSET_GAP | P2 | `AGENT-GUIDE.md §3`, `§11`, `CONSTITUTION.md §3.7` | description 에 `<example>` 3개 임베드로 카탈로그 비용 ↑ | 예시를 본문 "When to invoke" 로 이동 |
| GAP-005 | ASSET_GAP | P2 | `AGENT-GUIDE.md §7`, `CONSTITUTION.md §3.4` | output contract 없음 (특히 PR 컨텍스트 산출 형식) | PR 변경 요약·파일별 diff·no-op 케이스 명시 |
| GAP-006 | ASSET_GAP | P2 | `AGENT-GUIDE.md §9`, `CONSTITUTION.md §3.6` | 프로젝트 컨벤션이 본문에 하드코딩 | CLAUDE.md 참조로 위임 |

### GAP-001: root `code-simplifier.md` 와 본문 동일, name 중복

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §3.10 Overlap Must Be Intentional`, `AGENT-GUIDE.md §10 Overlap And Reuse` |

**Expected**

비슷한 에이전트가 공존하면 trigger / scope / output / capability / 대상 toolkit / 실행 시점이 차별화되고, 그 차이가 description 또는 본문에 보여야 한다. 같은 `name` 을 사용하면 라우팅 충돌 위험이 커진다.

**Actual**

- frontmatter `name: code-simplifier` 가 root `agents/code-simplifier.md` 와 동일.
- 본문 persona·5개 원칙·refinement process 6단계·자동 실행 진술이 root 와 한 단락도 다르지 않음.
- 차이는 description 형식뿐 (toolkit 버전은 YAML literal block + `<example>` 3개).
- toolkit 디렉토리에 들어 있음에도 본문에 PR diff input / PR comment output / toolkit 워크플로 진술이 없음.

**Evidence**

- `agents/pr-review-toolkit/code-simplifier.md:43-88` 본문
- `agents/code-simplifier.md:7-52` 본문 — 완전 동일

**Impact**

호출자/runtime 이 두 에이전트 중 어느 것을 호출해야 할지 결정할 단서가 없다. 같은 `name` 으로 인해 디스커버리 카탈로그 상의 충돌 가능성도 있다. 한쪽을 업데이트하면 다른 쪽이 stale 해질 위험이 누적된다.

**Recommendation**

Asset 수정 (SPLIT 또는 통합):
- 옵션 A (SPLIT): toolkit 버전은 PR diff 를 입력으로 받고, "각 hunk 별 simplification suggestion" 같은 PR-친화 output contract 로 본문을 재작성. description 도 "Use this agent as the final step of the PR review toolkit when..." 로 좁힘.
- 옵션 B (통합): toolkit 버전을 deprecate 하고 root 버전만 유지. toolkit README 에서 root 에이전트를 호출하도록 안내.

---

### GAP-002: `tools` 미명시로 권한 표면 불명확

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P1 |
| Guide ref | `AGENT-GUIDE.md §6.1 Tools`, `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility` |

**Expected**

mutation 역할은 `tools` 에 필요한 도구만 명시한다. 위험 도구(Bash, MultiEdit)는 의도적으로 제외/포함된다.

**Actual**

frontmatter 에 `tools` 없음. 본문은 "refining code immediately after it's written or modified" 라고 mutation 을 가정.

**Evidence**

`agents/pr-review-toolkit/code-simplifier.md:1-41` frontmatter — `name`, `description`, `model` 만 존재.

**Impact**

플랫폼 default 가 "전체 권한" 일 경우 mutation + 외부 IO + shell 권한이 모두 열린다. AGENT-GUIDE.md §6.1 가 platform default 단정을 막으므로 AMBIGUITY 로 두지만, mutation 역할에서는 안전·라우팅 양쪽에 직접 영향이라 P1.

**Recommendation**

Asset 수정. 최소 권한 명시(예: `Read, Edit, Grep, Glob`). advisory 로 전환할 거면 Write/Edit 제외.

---

### GAP-003: 자동·proactive mutation 지시에 gate 없음

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §3.3 Effects Require Gates`, `AGENT-GUIDE.md §13 Anti-Patterns (Hidden mutation)` |

**Expected**

부수 효과가 있는 자산은 inspect → propose → approval → mutate → verify 흐름을 따른다. 자동 실행 표현은 hard gate 가 동반되어야 한다.

**Actual**

본문 마지막 문장: "You operate autonomously and proactively, refining code immediately after it's written or modified without requiring explicit requests." 사용자 승인 단계 없이 직접 mutation 권장.

**Evidence**

`agents/pr-review-toolkit/code-simplifier.md:88` 동일 진술 (root 와 같음).

**Impact**

호출자/사용자가 의도하지 않은 시점에 코드를 변형할 수 있고, 특히 PR 컨텍스트에서는 자동 simplification 이 PR scope 외부 코드를 건드릴 위험이 있다.

**Recommendation**

Asset 수정. 자동 실행 문구를 제거하거나, PR diff scope 안의 변경만 propose 하고 사용자 승인 후에만 적용하도록 본문을 정렬.

---

### GAP-004: description 에 `<example>` 3개 임베드로 카탈로그 비용 증가

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §3 Description 전략`, `§11 Quantitative Heuristics`, `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context` |

**Expected**

`<example>` 임베드형은 라우팅이 자주 헷갈리는 경우에만 사용한다. 가능하면 본문 `When to invoke` 로 이동.

**Actual**

description 이 YAML literal block 으로 약 350 단어, `<example>` 3개를 포함. 모든 예시는 trigger 메타-설명("Now let me use the code-simplifier agent...") 수준.

**Evidence**

`agents/pr-review-toolkit/code-simplifier.md:3-39` description — context/user/assistant/commentary 패턴의 예시 3개.

**Impact**

description 은 항상 카탈로그에 로드되므로 매 세션마다 context cost 가 누적된다. 또한 예시들이 trigger 변별 정보를 거의 추가하지 못한다(어떤 코딩 작업 후에도 호출 가능하다는 메시지).

**Recommendation**

Asset 수정. description 은 trigger 핵심(20-60 단어)으로 축소. 예시는 본문 "When to invoke" 섹션으로 옮긴다.

---

### GAP-005: Output contract 부재 (특히 PR 컨텍스트)

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §7 Output Contract`, `CONSTITUTION.md §3.4 Output Is A Contract` |

**Expected**

호출자가 결과를 해석하고 다음 행동을 결정할 수 있어야 한다. PR-review toolkit 안에 있다면 PR comment / hunk 단위 simplification suggestion / no-op 케이스가 정의되는 것이 자연스럽다.

**Actual**

본문 refinement process 6번 "Document only significant changes that affect understanding" 한 줄만 있음.

**Evidence**

`agents/pr-review-toolkit/code-simplifier.md:86` "Document only significant changes that affect understanding".

**Impact**

호출자가 simplifier 의 변경 결과를 PR review 흐름에 어떻게 통합해야 할지 모르고, no-op 케이스 식별이 어려움.

**Recommendation**

Asset 수정. 변경 파일 목록 / 파일별 요약 / 영향 받지 않은 부분 / no-simplification-needed 케이스를 명시.

---

### GAP-006: 프로젝트 컨벤션 본문 하드코딩

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §9 CLAUDE.md And Project Memory`, `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate` |

**Expected**

reusable 에이전트는 일반 원칙만 본문에 두고 프로젝트 스타일은 CLAUDE.md 로 위임.

**Actual**

본문 #2 "Apply Project Standards" 가 ES modules / `function` keyword / explicit return types / React Props / try-catch 회피를 직접 열거.

**Evidence**

`agents/pr-review-toolkit/code-simplifier.md:49-56`.

**Impact**

Python·CommonJS·다른 스타일 채택 프로젝트에서는 적용 불가한 규칙이 강제됨. PR-review toolkit 이 multi-project 에서 쓰일수록 부정 영향이 큼.

**Recommendation**

Asset 수정. "Follow the explicit rules in CLAUDE.md / project memory" 로 위임, 본문은 일반 원칙(가독성·과도한 추상화 회피 등)만 유지.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `color` 미명시 | UI hint 이며 라우팅·안전 영향 미미. |

---

## 8. Suggested Changes

### Asset Changes

- [ ] root 와의 차별점 결정: SPLIT (toolkit-특화 trigger/scope/output) 또는 DEPRECATE.
- [ ] `tools` 명시 (최소 권한).
- [ ] "operate autonomously and proactively" 문구 제거 또는 사용자 승인 gate 도입.
- [ ] description 의 `<example>` 임베드를 본문 `When to invoke` 로 이동, description 은 trigger 핵심으로 축소.
- [ ] PR 컨텍스트에 맞는 output contract 섹션 추가.
- [ ] 프로젝트 컨벤션 항목을 CLAUDE.md 참조로 위임.

### Guide Changes

- [ ] None.

### Constitution Review

- [ ] None.

---

## 9. Follow-up Questions

- 이 에이전트와 root `agents/code-simplifier.md` 중 어느 것이 canonical 인가?
- PR-review toolkit 워크플로 상 simplifier 의 입력이 PR diff 인지, 또는 reviewer 의 산출인지 명확한 정의가 있는가?

---

## 10. Final Decision

```text
SPLIT_ASSET
```

근거:

- root 동명 에이전트와 본문 동일 + 같은 `name` 으로 인한 라우팅 ambiguity (P1).
- toolkit 디렉토리 안에 있으면서도 PR-friendly trigger/scope/output 이 없음 → 별도 자산으로 존재할 가치가 거의 없음.
- 본문 자체의 mutation 권한·자동 실행·output contract 문제는 root 리포트와 동일하므로, SPLIT 으로 toolkit 책임을 분리하든 DEPRECATE 하든 root 와의 정렬이 선행되어야 함.
- SPLIT 을 우선 권장하는 이유: toolkit 컨텍스트(PR diff 단위 simplification)는 실제로 차별화 가치가 있고, root 는 general-purpose 로 남겨두는 편이 라우팅에 유리.
